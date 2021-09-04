# functions

# function to scrape news from the source
# making usage of the rvest library
news_retreive <- function(url, node_type){
  
  suppressMessages(require(rvest))
  link <- read_html(url) # query the link 
  html_nodes_extract <- html_nodes(link, node_type) # extract data
  mytitle_raw <- html_text(html_nodes_extract) # convert data into text
  mytitle_raw # return result
  
}

# function to clean the text scraped from the web
# we apply regex, keep only those within a certain amount of characters,
# convert to lower case, remove duplicate and return the object

text_prepro <- function(x, min.length = 40, max.length = 100){
  mytitle <- trimws(gsub("[^A-Za-z0-9, ]", "", x)) # clean text with regex
  mytitle <- mytitle[sapply(mytitle, function(x) nchar(gsub(' ', '', x)) > min.length)] # keep only long titles
  mytitle <- mytitle[sapply(mytitle, function(x) nchar(gsub(' ', '', x)) < max.length)] # keep only long titles
  mytitle <- gsub(' +', ' ', mytitle) # substitute multiple blank space with single blank space
  mytitle <- tolower(mytitle) # lower case
  mytitle <- unique(mytitle) # remove duplicates
  mytitle # return object
}

