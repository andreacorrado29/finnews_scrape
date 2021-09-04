# main.R

# Author: Andrea Corrado
# Last update: 2021-09-01

# ------------------------------------------------------------------ #
# --------------------- financial news scrap ----------------------- #
# ------------------------------------------------------------------ #

rm(list = ls()) # clean env 

path <- "/home/ndrecord/Dropbox/r_FINSCRAPE" # set path
setwd(path)

source('./master/packages_install.R') # run for packages installation (only first time)
source('./master/settings.R') # run to laod settings
source('./master/financial_scrape.R') # execute

# clean env and garbage collection
rm(list = ls())
gc()