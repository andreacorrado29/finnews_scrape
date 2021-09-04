## Financial News Web Scraping
This project has been built to automate the daily scrape of the latest financial news from a variety of sources and topics. The information retrieved is processed from another (proprietary) project in to produce a sentiment score on the daily news and make investment decisions.

## Project settings
- The file `sources.csv` contains the sources from which we scrape the data from and the type of object to be targeted for each website. 

- The file `companies.csv` contains the word to filter for each topic. Project allows for synonyms to be separated from a comma: eg `word1, word2`

- The file `settings.R` contains different settings such as  the number of cores to be used for the parallel computation and the word you wish to remove from the news scraped.

## Packages Installation & Execution

The process is run mainly by the library `rvest`for web scraping and the package `tm` for text mining. In order to install these packages, and other useful for the analysis, run the `packages_install.R` by running:
- `cd <project_folder>` 
- `Rscript ./master/packages_install.R`

Once the environment is set up, you can start the process by running:
- `cd <project_folder>`
- `Rscript main.R`

This script will load the necessary settings `settings.R`, functions `functions_source.R` and run the main code `financial_scrape.R`. The news retrieved will be store into the `.csv` files in the `./data` folder and available for further analysis.

## Project Details

Within the main code we:
- scrape the news from the sources specified in `./master/sources.csv`
- cleans the strings by making usage of `regex`
- apply word stemming and other technique to reduce the news title to a root form
- filter the news according to the topic specified in `./master/companies.csv`
- produce a data set for each topic filtering out the repeated mews within a certain period

At the end of the execution, each topic will have a dedicated data set `./data/<topic>.csv` containing the date and title of the news. The data set is now ready for further analysis.

As a bonus, we produce a `wordcloud` to inspect daily most used word and potentially identifiy new interesting topics to look at. 

## R installation instruction

#### R
The whole project is coded in `R`. R is an open source language for statistical analysis.

On a Linux Debian based machine, R can be easily installed from the terminal by running
`sudo apt-get install r-base`

#### RStudio
*The RStudio IDE is a set of integrated tools designed to help you be more productive with R and Python. It includes a console, syntax-highlighting editor that supports direct code execution, and a variety of robust tools for plotting, viewing history, debugging and managing your workspace.*
You can download `RStudio` from <https://www.rstudio.com/products/rstudio/download/#download> and install it by running the executable.

