install.packages(c(
    "lme4", "devtools", "merTools",  "randomForest", "Rcpp", "dplyr", "data.table", 
    "ggplot2", "lubridate", "ggvis", "quantmod", "zoo", "xts", "nnet", "HLMdiag", 
    "roxygen2", "foreign", "leaflet", "magrittr", "stringr", "shiny", "xtable", "testthat", 
    "scales", "profr", "mclust", "reshape2", "viridis", "httr", "rstan", "rstanarm",
    "microbenchmark", "clustvarsel", "Rmixmod", "RColorBrewer", "RCurl",
    "gtools", "forecast", "RcppArmadillo", "RcppEigen", "rsconnect",
    "acs", "XML", "scrapeR", "xgboost", "imputeMulti", "synthACS"
), dependencies = c("Depends", "Imports"))

library(RCurl)
library(httr)
set_config( config( ssl_verifypeer = 0L ) )

devtools::install_github("alexwhitworth/emclustr")

Sys.setenv("PKG_CXXFLAGS"="-std=c++0x")
devtools::install_github("alexwhitworth/imputation")
