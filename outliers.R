## Author:  Alex Whitworth
## Date:	December 2012

#' @title Identify Data Outliers
#' @description	
#' Determine if the specified columns of a data-frame have outliers. User can use
#' either IQR or quantiles to identify outliers. Can additionally choose to
#' remove or cap min and/or max outliers. 
#' @param df An input data frame.
#' @param cols A vector of indices.
#' @param method List of length two. either c("boxplot", coef= X) or 
#' c("quantile", q= c(min, max))

find.outliers <- function(df, cols, method= list(...)) {
  if (min(cols) < 1) {
    stop("you have entered invalid columns. Please correct your inputs.")
  } else if (max(cols) > length(df)) {
    stop("you have entered invalid columns. Please correct your inputs.")
  }
  if (method[[1]] != "boxplot" & method[[1]] != "quantile") {
    stop(cat("You have entered an invalid method for identifying outliers. 
             Please correct your call.", fill=T))
  }
  if (method[[1]] == "boxplot" & method[[2]][1] < 0) {
    stop(cat("You have entered an invalid coefficient, Please correct your call.", fill=T))
  } else if (method[[1]] == "quantile" & length(method$q) != 2) {
    stop(cat("You have entered invalid quantiles, Please correct your call.", fill=T))
  }
  
  iqr <- matrix(nrow = length(cols), ncol= 4, 
                dimnames= list(names(df[cols]), 
                c("min bound", "max bound", "min outliers?", "max outliers?")))
  n <- 1
  ## determine outliers based on method= selection
  if (method[[1]] == "boxplot") {
    for (i in cols) {
      iqr[n, 1] <- boxplot.stats(df[, i], coef= method[[2]])$stats[1]
      iqr[n, 2] <- boxplot.stats(df[, i], coef= method[[2]])$stats[5]
      if (min(df[, i]) < boxplot.stats(df[, i], coef= method[[2]])$stats[1]) {
        iqr[n, 3] <- T
      } else iqr[n, 3] <- F
      if (max(df[, i]) > boxplot.stats(df[, i], coef= method[[2]])$stats[5]) {
        iqr[n, 4] <- T
      } else iqr[n, 4] <- F
      
      n <- n + 1
    }
  } else if (method[[1]] == "quantile") {
  for (i in cols) {
    iqr[n, 1] <- quantile(df[, i], probs= method$q[1])
    iqr[n, 2] <- quantile(df[, i], probs= method$q[2])
    if (min(df[, i]) < quantile(df[, i], probs= method$q[1])) {
      iqr[n, 3] <- T
    } else iqr[n, 3] <- F
    if (max(df[, i]) > quantile(df[, i], probs= method$q[2])) {
      iqr[n, 4] <- T
    } else iqr[n, 4] <- F
    
    n <- n + 1
    }
  } 
  return(iqr)
}

#' @title Identify Data Outliers
#' @description  
#' Determine if the specified columns of a data-frame have outliers. User can use
#' either IQR or quantiles to identify outliers. Can additionally choose to
#' remove or cap min and/or max outliers. 
#' @param df An input data frame.
#' @param cols A vector of indices.
#' @param method List of length two. either c("boxplot", coef= X) or 
#' c("quantile", q= c(min, max))
#' @param rm Logical vector of 2. remove min / max outliers
#' @param cap Logical vector of 2. cap min / max outliers
#' @param sure Logical. confirm you want to remove or cap outliers.
#' @return If sure= FALSE, a message. If sure= TRUE, a dataframe with outliers either
#' removed or capped
remove.outliers <- function(df, cols, method= list(...), 
                            rm= c(min= F, max= F), 
                            cap= c(min= F, max= F), sure= F) {

  if (min(cols) < 1) {
    stop("you have entered invalid columns. Please correct your inputs.")
  } else if (max(cols) > length(df)) {
    stop("you have entered invalid columns. Please correct your inputs.")
  }
  if ((rm[[1]] == F & rm[[2]] == F) & (cap[[1]] == F & cap[[2]] == F)) {
    stop(cat("You have not chosen to remove or cap any outliers. You're data frame will not change.", fill=T))
  }
  if ((rm[[1]] == T || rm[[2]] == T) & (cap[[1]] == T || cap[[2]] == T)) {
    stop(cat("Please only remove or cap outliers. You have selected both. Use two steps if needed", fill= T))
  }
  
  mat <- find.outliers(df, cols, method= method)
  df2 <- df
  cnt <- 1
  
  # remove or cap outliers based on selection
   if (rm[[1]] == T || rm[[2]] == T) {
    # remove outliers
    if (rm[[1]] == T & rm[[2]] == T) {
      for (i in cols) {
        if (mat[cnt, 3] == 1 & mat[cnt, 4] == 1) {
          df2 <- df2[df2[, i] >= mat[cnt, 1] & df2[, i] <= mat[cnt, 2], ]  
        } else if (mat[cnt, 3] == 1 & mat[cnt, 4] == 0) {
          df2 <- df2[df2[, i] >= mat[cnt, 1], ]
        } else if (mat[cnt, 3] == 0 & mat[cnt, 4] == 1) {
          df2 <- df2[df2[, i] <= mat[cnt, 2], ]
        }
        cnt <- cnt + 1
      }
    } else if (rm[[1]] == T & rm[[2]] == F) {
      for (i in cols) {
        if (mat[cnt , 3] == 1) {
          df2 <- df2[df2[, i] >= mat[cnt, 1], ]  
        }
        cnt <- cnt + 1
      }
    } else if (rm[[1]] == F & rm[[2]] == T) {
      for (i in cols) {
        if (mat[cnt , 4] == 1) {
          df2 <- df2[df2[, i] <= mat[cnt, 2], ]
        }
        cnt <- cnt + 1
      }
    }
   } else if (cap[[1]] == T || cap[[2]] == T) {
     # cap outliers
     if (cap[[1]] == T & cap[[2]] == T) {
       for (i in cols) {
         if (mat[cnt, 3] == 1 & mat[cnt, 4] == 1) {
           df2[, i] <- ifelse(df2[, i] < mat[cnt, 1], mat[cnt, 1], df2[, i])
           df2[, i] <- ifelse(df2[, i] > mat[cnt, 2], mat[cnt, 2], df2[, i])  
         } else if (mat[cnt, 3] == 1 & mat[cnt, 4] == 0) {
           df2[, i] <- ifelse(df2[, i] < mat[cnt, 1], mat[cnt, 1], df2[, i])
         } else if (mat[cnt, 3] == 0 & mat[cnt, 4] == 1) {
           df2[, i] <- ifelse(df2[, i] > mat[cnt, 2], mat[cnt, 2], df2[, i])
         }
         cnt <- cnt + 1
       }
     } else if (cap[[1]] == T & cap[[2]] == F) {
       for (i in cols) {
         if (mat[cnt , 3] == 1) {
           df2[, i] <- ifelse(df2[, i] < mat[cnt, 1], mat[cnt, 1], df2[, i])
         }
         cnt <- cnt + 1
       }
     } else if (cap[[1]] == F & cap[[2]] == T) {
       for (i in cols) {
         if (mat[cnt , 4] == 1) {
           df2[, i] <- ifelse(df2[, i] > mat[cnt, 2], mat[cnt, 2], df2[, i])
         }
         cnt <- cnt + 1
       }
     }
   }

  obs.df <- nrow(df)
  obs.df2 <- nrow(df2)
  if (sure == F) {
    if (obs.df > obs.df2) {
      stop(cat("You are about to delete", obs.df - obs.df2, 
             "observations. Are you sure?", fill= T))
    } else stop(cat("You have indicated your are not sure you wish to proceed.", fill= T))
  } else if (sure == T) {
    if (obs.df > obs.df2) {
      print(cat("You have deleted", obs.df - obs.df2, "observations.", fill= T))
    }
    return(df2)
  }
}

## needed functions for vectorized version
box.stat   <- function(vec, coef2) {
  bnd <- boxplot.stats(vec, coef= coef2)$stats[c(1,5)]
  min <- min(vec) < bnd[1]
  max <- max(vec) > bnd[2]
  return(c(bnd, min, max))
}

quant.stat <- function(vec, probs2= c(.025, .975)) {
  bnd <- quantile(vec, probs= probs2)
  min <- min(vec) < bnd[1]
  max <- max(vec) > bnd[2]
  return(c(bnd, min, max))  
}

#' @title Identify Data Outliers - vectorized
#' @description  
#' Determine if the specified columns of a data-frame have outliers. User can use
#' either IQR or quantiles to identify outliers. Can additionally choose to
#' remove or cap min and/or max outliers. This version has been vectorized. However, no
#' improvement in run time shown in tests.
#' @param df An input data frame.
#' @param cols A vector of indices.
#' @param method List of length two. either c("boxplot", coef= X) or 
#' c("quantile", q= c(min, max))
find.outliers2 <- function(df, cols, method= list(...)) {
  if (min(cols) < 1) {
    stop("you have entered invalid columns. Please correct your inputs.")
  } else if (max(cols) > length(df)) {
    stop("you have entered invalid columns. Please correct your inputs.")
  }
  if (method[[1]] != "boxplot" & method[[1]] != "quantile") {
    stop(cat("You have entered an invalid method for identifying outliers. 
             Please correct your call.", fill=T))
  }
  if (method[[1]] == "boxplot" & method[[2]][1] < 0) {
    stop(cat("You have entered an invalid coefficient, Please correct your call.", fill=T))
  } else if (method[[1]] == "quantile" & length(method[[2]]) != 2) {
    stop(cat("You have entered invalid quantiles, Please correct your call.", fill=T))
  }
    
  ## determine outliers based on method= selection
  if (method[[1]] == "boxplot") {  
    # apply functions 
    iqr <- t(apply(df[, cols], 2, box.stat, coef2= method[[2]]))
  } else if (method[[1]] == "quantile") {  
    # apply functions 
    iqr <- t(apply(df[, cols], 2, quant.stat), probs2= method[[2]])
  }
  # name and return
  dimnames(iqr) <- list(names(df)[cols], c("min bound", "max bound", "min outliers?", "max outliers?"))
  return(iqr)
}
