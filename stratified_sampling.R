
#----------------------------------------------------------
# Author: Alex Whitworth
# Date:   August-2016
# Description: functions for stratified sampling. Done via recursion.
#----------------------------------------------------------
split_df <- function(d, var) {
  if (is.factor(get(var, as.environment(d))) || is.character(get(var, as.environment(d))) ||
      is.logical(get(var, as.environment(d)))) {
    return(base::split(d, get(var, as.environment(d))))
  } else {
    v <- gtools::quantcut(get(var, as.environment(d)), q= 10, na.rm=T)
    return(base::split(d, v))
  }
}

# @title Take a sample of the rows of a data.table
# @param dt_l A list with each element containing a data.table
# @param sample_pct A numberic in (0,1] for the sample percentage desired
# @param seed An integer seed for reproducibility
sample_dt <- function(dt_l, sample_pct = 0.1, seed= sample.int(1000L, 1L, replace=FALSE)) {
  if (sample_pct <= 0 | sample_pct > 1) stop("sample_pct must be in (0,1].")
  
  # A. Sample and recombine
  dt <- rbindlist(lapply(dt_l, function(l) {
    nr <- nrow(l)
    if (nr == -0) return(NULL)
    set.seed(seed)
    idx <- sample.int(nr, size= round(nr * sample_pct, 0), replace= FALSE)
    return(l[idx,])
  }))
  return(dt)  
}

# @title Take a stratified sample of a data.table
# @description Take a stratified sample of a data.table based on a set of stratification variables.
# @param dt a \code{data.table} object
# @param strat_varlist A character vector of variable names contained in \code{dt}
# @param sample_pct A numberic in (0,1] for the sample percentage desired
# @param seed An integer seed for reproducibility
strat_sample <- function(dt, strat_varlist= NULL, sample_pct= 0.1, seed= sample.int(1000L, 1L, replace=FALSE)) {
  if (sample_pct <= 0 || sample_pct > 1) stop("sample_pct must be in (0,1].")
  if (is.null(strat_varlist) || !is.character(strat_varlist) ||
      !all(sapply(strat_varlist, function(x, n) {x %in% n}, n= names(dt))))
    stop("strat_varlist must be a character vector of variable names in dt.")
  
  if (nrow(dt) == 0) return(NULL)
  if (length(strat_varlist) > 1) {
    dt <- split_df(dt, strat_varlist[1])
    strat_varlist <- strat_varlist[-1]
    dt <- rbindlist(lapply(dt, strat_sample, strat_varlist= strat_varlist, sample_pct= sample_pct, seed= seed))
  } else {
    dt_l <- split_df(dt, strat_varlist[1])
    return(sample_dt(dt_l, sample_pct= sample_pct, seed= seed))
  }
  return(sample_dt= dt)
}
