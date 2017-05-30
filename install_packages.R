install.packages(c("lme4", "devtools", "merTools",  "randomForest", "Rcpp", "dplyr", "data.table", 
                   "ggplot2", "lubridate", "ggvis", "quantmod", "zoo", "xts", "nnet", "HLMdiag", 
                   "roxygen2", "foreign", "leaflet", "magrittr", "htmlwidgets", "shinydashboard",
                   "stringr", "car", "shiny", "xtable", "testthat", "tidyr", "scales",
                   "profr", "party", "kernlab", "e1071", "mclust", "reshape2", "testthat",
                   "microbenchmark", "clustvarsel", "Rmixmod", "RColorBrewer", "RCurl",
                   "gtools", "forecast", "RcppArmadillo", "RcppEigen", "rsconnect",
                   "acs", "XML", "scrapeR", "xgboost"), 
                 dependencies = c("Depends", "Imports"))

library(RCurl)
library(httr)
set_config( config( ssl_verifypeer = 0L ) )

devtools::install_github("alexwhitworth/imputeMulti")
devtools::install_github("alexwhitworth/glmEnsemble")
devtools::install_github("alexwhitworth/emclustr")
devtools::install_github("alexwhitworth/synthACS")

Sys.setenv("PKG_CXXFLAGS"="-std=c++0x")
devtools::install_github("alexwhitworth/imputation")
