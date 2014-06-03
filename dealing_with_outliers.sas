options source2;
filename source1 url 'https://github.com/crossfitAL/resume_ex_code/distribution_Macros.sas';
%include source1;


/******************************************************************/
%macro outliers_max(dsn_in= , dsn_out= &dsn_in.2,
                quant_list= 1 50 99, varlist= ,
                max_quant= 99,
                numvars= , cap= 'T');
/*  
  Author:  Alex Whitworth
  Date:    May, 2013
  DESC:    determine outlier values (max-side) based on user input.
        Allow user to cap outliers as desired. If so, cap them
  NOTE:    Does NOT currently allow for outlier removal.

**Arguments:**
  dsn_in      = input dataset
  dsn_out     = output dataset (with capped outliers)
  quant_list  = list of quantiles to determine
  varlist     = a list of variables in the dataset for which you
                wish to calculate / cap outliers.
  max_quant   = specifies outlier criteria
  numvars     = number of vars in &varlist
  cap         = logical- do you want to cap outliers
******************************************************************/

/* calculate quantiles for dsn_in and given varlist.
   output dsn= qSum_stats. */
%cust_quants(dsn= &dsn_in, quant_list= &quant_list,
             varlist= &varlist, numvars= &numvars);

/* output outliers values */
data outliers_max;
  set qsum_stats(keep= var_name q_&max_quant);
run;

/* if cap has been requested, cap variables */
%if &cap = 'T' %then %do;
  /* create macros specifying max-outlier value */
  proc sql noprint;
    select q_&max_quant into: max_1 -: max_999
    from qsum_stats;
  quit;

/* create new dataset with capped variables */
  data &dsn_out;
    set &dsn_in;
    /* if given variable > max, cap variable */
      %do i= 1 %to &numvars;
        if %scan(&varlist, &i) > &&max_&i. then %scan(&varlist, &i) = &&max_&i.;
      %end;  
  run; 
%end;

%mend outliers_max;

/******************************************************************/
%macro outliers_min(dsn_in= , dsn_out= &dsn_in.2,
                quant_list= 1 50 99, varlist= ,
                min_quant= 1,
                numvars= , cap= 'T');
/*  
  Author:  Alex Whitworth
  Date:    May, 2013
  DESC:    determine outlier values (min-side) based on user input.
        Allow user to cap outliers as desired. If so, cap them.
  NOTE:    Does NOT currently allow for outlier removal.

**Arguments:**
  dsn_in      = input dataset
  dsn_out     = output dataset (with capped outliers)
  quant_list  = list of quantiles to determine
  varlist     = a list of variables in the dataset for which you
                wish to calculate / cap outliers.
  max_quant   = specifies outlier criteria
  numvars     = number of vars in &varlist
  cap         = logical- do you want to cap outliers
******************************************************************/

/* calculate quantiles for dsn_in and given varlist.
   output data to dsn= qSum_stats. */
%cust_quants(dsn= &dsn_in, quant_list= &quant_list,
             varlist= &varlist, numvars= &numvars);

/* output outliers values */
data outliers_max;
  set qsum_stats(keep= var_name q_&min_quant);
run;

/* if cap has been requested, cap variables */
%if &cap = 'T' %then %do;
  /* create macros specifying min-outlier value */
  proc sql noprint;
    select q_&min_quant into: min_1 -: min_999
    from qsum_stats;
  quit;

  /* create new dataset with capped variables */
  data &dsn_out;
    set &dsn_in;

    /* if given variable < min, cap variable */
    %do i= 1 %to &numvars;
      if %scan(&varlist, &i) < &&min_&i. then %scan(&varlist, &i) = &&min_&i.;
    %end; 
  run;
%end;

%mend outliers_min;

%macro outliers_max_min(dsn_in= , dsn_out= &dsn_in.2,
                quant_list= 1 50 99, varlist= ,
                min_quant= 1,
                max_quant= 99,
                numvars= , cap= 'T');
/*  
  Author:  Alex Whitworth
  Date:    May, 2013
  DESC:    determine outlier values (max and min) based on user input.
        Allow user to cap outliers as desired. If so, cap them.
  NOTE:    Does NOT currently allow for outlier removal.

**Arguments:**
  dsn_in      = input dataset
  dsn_out     = output dataset (with capped outliers)
  quant_list  = list of quantiles to determine
  varlist     = a list of variables in the dataset for which you
                wish to calculate / cap outliers.
  min_quant   = specifies outlier criteria
  max_quant   = specifies outlier criteria
  numvars     = number of vars in &varlist
  cap         = logical- do you want to cap outliers
******************************************************************/
%cust_quants(dsn= &dsn_in, quant_list= &quant_list,
             varlist= &varlist, numvars= &numvars);

/* output outliers values */
data outliers;
  set qsum_stats(keep= var_name q_&min_quant q_&max_quant);
run;

/* if cap has been requested, cap variables */
%if &cap = 'T' %then %do;
  /* create macros specifying min-outlier value */
  proc sql noprint;
    select q_&min_quant, q_&max_quant
      into: min_1 -: min_999,
          : max_1 -: max_999
    from qsum_stats;
  quit;

  /* create new dataset with capped variables */
  data &dsn_out;
    set &dsn_in;

    /* if given variable < min or > max, cap variable */
    %do i= 1 %to &numvars;
      if %scan(&varlist, &i) < &&min_&i. then %scan(&varlist, &i) = &&min_&i.;
      else if %scan(&varlist, &i) > &&max_&i. then %scan(&varlist, &i) = &&max_&i.;
    %end; 
  run;
%end;

%mend outliers_max_min;
