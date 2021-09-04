# packages_install.R

# list all packages
pkgs <- installed.packages()[,1]

# packages for the code
useful <- c(
  'doParallel',
  'wordcloud',
  'foreach',
  'stringr',
  'rvest',
  'tm'
)
# install those not available
i <- 0
for (p in useful){
  if (!(p %in% pkgs)){
    install.packages(p)
    i <- i + 1
  }
} 

if(i > 0){
  cat('\n\n', i, 'new packages installed\n\n')
  } else {
    cat('\n\n no new package installed\n\n')
  }


