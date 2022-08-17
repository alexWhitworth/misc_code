install.packages(c(
    "lme4", "HLMdiag", "devtools", "merTools",  "Rcpp", "RcppArmadillo", "RcppEigen",
    "tidyverse", "lubridate", "ggvis", "magrittr", "profr", "pryr",  "RColorBrewer", "viridis",
    "quantmod", "zoo", "xts", "forecast", "astsa", "prophet", 
    "roxygen2", "foreign", "xtable", "testthat", "knitr", "gridExtra",
    "scales", "mclust", "rstan", "rstanarm", "brms",
    "microbenchmark", "clustvarsel", "Rmixmod", "RCurl",
    "gtools", "rsconnect", "Hmisc", "rms", "optimx", "lbfgs", "quadprog", "kernlab",
    "XML", "scrapeR", "xgboost", "ranger", "interpret", "dbarts",
    "fredr", "acs",
), dependencies = c("Depends", "Imports"))

library(RCurl)
library(httr)
set_config( config( ssl_verifypeer = 0L ) )

devtools::install_github("alexwhitworth/emclustr")

Sys.setenv("PKG_CXXFLAGS"="-std=c++0x")
devtools::install_github("alexwhitworth/imputation")
