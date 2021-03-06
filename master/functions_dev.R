# functions

news_retreive <- function(url, node_type){
  suppressMessages(require(rvest))
  link <- read_html(url) # query the link 
  html_nodes_extract <- html_nodes(link, node_type) # extract data
  mytitle_raw <- html_text(html_nodes_extract) # convert data into text
  mytitle_raw
}

text_prepro <- function(x, min.length = 40, max.length = 100){
  mytitle <- trimws(gsub("[^A-Za-z0-9, ]", "", x)) # clean text
  mytitle <- mytitle[sapply(mytitle, function(x) nchar(gsub(' ', '', x)) > min.length)] # keep only long titles
  mytitle <- mytitle[sapply(mytitle, function(x) nchar(gsub(' ', '', x)) < max.length)] # keep only long titles
  mytitle <- gsub(' +', ' ', mytitle) # substitute multiple blank space
  mytitle <- tolower(mytitle) # lower case
  mytitle <- unique(mytitle) # remove duplicates
  mytitle
}

get_individual_sentiment <- function(x){
  my_cleantitle <- unlist(x)[which(names(unlist(x)) != 'meta.language')]
  # result <- get_nrc_sentiment(my_cleantitle)
  # result$choice <- result$positive - result$negative
  result <- analyzeSentiment(my_cleantitle)
  result
}


get_sentiment <- function(x, language = 'english'){
  
  suppressMessages(require(syuzhet))
  suppressMessages(require(SentimentAnalysis))
  
  # sentiment preparation ------------------------------------------------------
  corpus <- Corpus(VectorSource(x)) # convert into corpus obje
  corpus <- tm_map(corpus, removePunctuation)
  corpus  <- tm_map(corpus, content_transformer(tolower))
  cleanset <- tm_map(corpus, removeWords, stopwords(language))
  cleanset <- tm_map(cleanset, stemDocument) # word stemming: reduce to root form
  cleanset <- tm_map(cleanset, stripWhitespace)
  
  # words sentiment -----------------------------------------------------------
  result <- get_individual_sentiment(cleanset)
  data.frame(time = Sys.Date(),
             title = x,
             sentiment = result[,c('SentimentGI', 'SentimentQDAP' )])
}


# daily aggregation -----------------------------------------------------------

period_aggr <- function(comp, f, aggr, period = c(7, 30, 365), dest_path = './score/'){
  #browser()
  
  c.filename <- paste0(comp, '.csv')
  i.dat <- read.csv(paste0(path, c.filename))[,-1]
  
  if(nrow(i.dat) > 0){ # if there are records in it
    
    days.ago <- Sys.Date() - as.Date('2021-06-26') # start date
    j.times <- data.frame(time = as.character(Sys.Date() - days.ago : 0)) # full time
    i.dat <- merge(i.dat, j.times, by = 'time', all.y = TRUE) # outer join
    i.dat$title[is.na(i.dat$title)] <- '' # no value
    i.dat$sentiment.SentimentGI[is.na(i.dat$sentiment.SentimentGI)] <- 0 # no value
    i.dat$sentiment.SentimentQDAP[is.na(i.dat$sentiment.SentimentQDAP)] <- 0 # no value
    i.dat.aggr <- 
      data.frame(
        unique(i.dat$time),
        tapply(i.dat[, 3], i.dat[,1], f), # aggregation function
        tapply(i.dat[, 4], i.dat[,1], f) # aggregation function
      )[nrow(j.times):1,] # reverse order
    names(i.dat.aggr) <- names(i.dat[,-2])
    i.dat.aggr$mean.sentiment <- apply(i.dat.aggr[,c(2,3)], 1, aggr) # sentiment aggr
    
    # cumsum
    p <- ncol(i.dat.aggr)
    i.names <- c(names(i.dat.aggr), paste0('mean.sentiment', period))
    for(j in 1:length(period)){
      for(k in 1: ( nrow(i.dat.aggr) - period[j])) {
        to_cumsum <- min(nrow(i.dat.aggr), period[j])
        # i.dat.aggr[1:to_cumsum, p+j] <- cumsum(i.dat.aggr[to_cumsum:1,'mean.sentiment'])[to_cumsum:1]
        i.dat.aggr[1:to_cumsum, p+j] <- cumsum(i.dat.aggr[to_cumsum:1,'mean.sentiment'])[to_cumsum:1]
        
      }
    }
    
    
    # write file
    names(i.dat.aggr) <- i.names # assign names according to period
    write.csv(i.dat.aggr, paste0(dest_path, c.filename))
  } else {
    stop(cat('\n no records found for', comp, '\n'))
  }
  invisible(i.dat.aggr)
}

# sentiment plot function ------------------------------------------------------

period_plot <- function(comp, metric, file, dim_pic = 1200, path = './score/', ...){
  #browser()
  
  png(file = file, width = dim_pic*1.5, height = dim_pic) # start image
  
  for(i in 1:length(comp)){
    i.dat <- read.csv(paste0(path, comp[i], '.csv'))[,-1]
    N <- nrow(i.dat)
    i.dat <- i.dat[N:1,]
    i.times <- sort(i.dat$time)
    l.times <- length(i.times)
    if(i == 1){
      par(las = 2 )
      plot(1:l.times, i.dat[,metric], pch = 19, type = 'b',
           xaxt = 'n', xlab = '', ylab = 'sentiment', ...)
      axis(1, at = 1:l.times, labels = substr(i.times, 6, 10)) 
    } else {
      lines(1:l.times, i.dat[,metric], pch = 19, type = 'b', col = i)
    }
  }
  abline(h = 0, col = 'red', lty = 2, lwd = 2) # add line
  legend('topleft', legend = comp, fill = 1:length(comp), bty = 'n') # add legend
  dev.off()
}



# ---------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------- #
# ------------------------- development functions ---------------------------- #
# ---------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------- #

# compute gain ----------------------------------------------------------------

gain.p <- function(x){ # define function for gian
  N <- length(x)
  y <- vector('logical', N - 1)
  for(i in 2:N) y[i-1] <- x[i]/x[i-1]
  c(NA, 1 - y)
}


























