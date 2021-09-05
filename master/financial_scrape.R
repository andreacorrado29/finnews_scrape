
source('./master/functions_source.R') # load useful functions

# load useful packages
suppressMessages(library(doParallel))
suppressMessages(library(wordcloud))
suppressMessages(library(foreach))
suppressMessages(library(stringr))
suppressMessages(library(rvest))
suppressMessages(library(tm))
options(warn=-1)

# download data from sources -------------------------------------------------

# in this section we scrape the web link specified in sources.csv 
# and apply pre processing step to the news title retreived

# set parallel workers
workers <- makeCluster(ncore)
registerDoParallel(workers)

all_title <- c() # initialize vector host 
sources <- read.csv('./master/sources.csv') # load sources to be scraped
if(NROW(sources) == 0) stop('no source to scrape') # check presence of sources

# run parallel process
cat('\n 1. retreiving news from', NROW(sources), 'sources \n ')
x <- foreach(i = 1:nrow(sources)) %dopar% {
  
  i.url <- sources$url[i] # extract url
  i.node_type <- sources$node_type[i] # extract node type
  
  # function to scrape news from the source
  # making usage of the rvest library
  my_titles_raw <- news_retreive(url = i.url, node_type = i.node_type)
  
  if((length(my_titles_raw) > 0)){ # check for news presence
    
    all_title <- unique(
      c(
        all_title,
        
        # function to clean the text scraped from the web
        # we apply regex, keep only those within a certain amount of characters,
        # convert to lower case, remove duplicate and return the object
        
        text_prepro(x = my_titles_raw) # apply text pre-processing
        )
      ) # remove duplicates
    
  } else {
    warning(paste("\n source", i, "couldn't be queried"))
  }
  all_title # return object to main environment
}

stopCluster(workers) # stop parallel workers
all_title <- unique(unlist(x)) # store results in all_ttile 

# look for trend -------------------------------------------------------------

# in this section we create a corpus from all the titles scraped
# then we remove certain words and apply pre procession step
# one we have a clean result, we produce a word clud to graphically present
# the daily wording trend

corpus <- iconv(all_title) # convert character vector
corpus <- Corpus(VectorSource(corpus)) # create corpus
corpus <- tm_map(corpus, stemDocument) # check for stem words
corpus <- tm_map(corpus, removeWords, stopwords('english')) # check for stop words
corpus <- tm_map(corpus, removeWords, to_rem) # check for words specified in settings.R
tdm <- as.matrix(TermDocumentMatrix(corpus)) # convert into incidence matrix
word_count <- apply(tdm, 1, sum) # count word frequency
word_count <- word_count[word_count > 5 & word_count < 20] # keep those between a certain range

# render word cloud
png('today_trend.png') 
wordcloud(words = names(word_count),
          freq = word_count,
          max.words = 150,
          random.order = F,
          min.freq = 5,
          colors = brewer.pal(8, 'Dark2'),
          scale = c(5, 0.3),
          rot.per = 0.7)
# stop rendering
dev.off()


# filter data ----------------------------------------------------------------

# in this section we filter the news retrieved according to the words (and synonym)
# specified in companies.csv

my_news <- list() # initialize list
of_interest <- read.csv('./master/companies.csv')[,1] # load wording of interest
of_interest <- strsplit(of_interest, ', ') # create vectors of synonyms (if present)
if (NROW(of_interest) == 0) stop('no topic to look for') # check for presence

cat('\n\n 2. filtering out news \n')
pb <- txtProgressBar(min = 0, max = NROW(of_interest), style = 3, width = 50, char = "=") 

# loop over the topics
for(i in 1:NROW(of_interest)){
  
  idx <- c() # initialize vector
  
  # loop over each topic words
  for(j in 1:NROW(of_interest[[i]])){
    # extract title index containing the word
    word_j <- paste0(' ', of_interest[[i]][j], ' ')
    idx <- c(idx, grep(word_j, all_title))
  }
  
  # extract titles according to the index identified and remove duplicates
  i.titles <- unique(all_title[idx])
  
  # if any, attach to final list
  if(length(i.titles) > 0) my_news[[of_interest[[i]][1]]] <- i.titles
  setTxtProgressBar(pb, i) # update progress bar
}



# write results to file -------------------------------------------------------

# within this section we write the results in separate files for different topics

days <- 7 # date range for older news
dates <- Sys.Date() - days:0

path <- './data/'

# extract names of the file to be written
filename <- sapply(names(my_news), function(x) paste0(x, '.csv'))
files <- list.files(path) # list available files

cat('\n\n 3. writing results \n ')
pb <- txtProgressBar(min = 0, max = NROW(filename), style = 3, width = 50, char = "=") 

# for each topic
for(i in 1:length(my_news)){
  
  # if file exits, load and append
  if (filename[i] %in% files){
    
    i.dat <- read.csv(paste0(path, filename[i]))[,-1] # load data
    i.dat.title <- i.dat[as.Date(i.dat$time) %in% dates, 'title'] # extract today's title
    my_news[[i]] <- my_news[[i]][!(my_news[[i]] %in% i.dat.title)] # check existence of the news
    
    if(NROW(my_news[[i]]) > 0){ # if there are new titles
      i.dat <- rbind(
        data.frame(
          time = rep(Sys.Date(), NROW(my_news[[i]])), 
          title = my_news[[i]]
          ), 
        i.dat # add new titles
        )
      write.csv(i.dat, paste0(path, filename[i])) # write files
    }
    
  } else { # file doesn't exist, create
    write.csv(
      data.frame(
          time = rep(Sys.Date(), NROW(my_news[[i]])), 
          title = my_news[[i]]
          ),
      paste0(path, filename[i])) # create new file
  }

  setTxtProgressBar(pb, i) # update progress bar
}

#  log activity and return final message ---------------------------------------
log <- read.csv('./master/log')[,-1]
log <- rbind(c(as.character(Sys.time()),'job executed'), log)
write.csv(log, './master/log')


cat('\n\n process executed correctly \n\n ')









