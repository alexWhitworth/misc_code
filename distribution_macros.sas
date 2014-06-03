
/********************************************************/
%macro sum_stats(dsn, varlist, numvars);
/*  Author:  Alex Whitworth
    Date: Jan, 2013
    DESC: calculates summary statistics for a given dataset
      and given variables w/in the dataset. Summary statistics are
      output to a single dataset.
    
    **Arguments:**
    dsn = a dataset
    varlist = a list of variables in the dataset for which you
      want summary statistics calculated.
    numvars = number of vars in &varlist
******************************************************************/

/* get summary stats for each var in varlist from the dsn */
%do i=1 %to &numvars.;
  %let var_&i = %scan(&varlist, &i);
  proc summary data = &dsn p1 p5 median p95 p99 std;
    output out = ss_&&var_&i.
      p1= p1c
      p5= p5c
      p95= p95c 
      p99= p99c
      median= median_c
      std= std_c 
    ;
    var &&var_&i.;
  run;

/* add an identifying name to the summary stats for each var */
  data ss_&&var_&i.;
    set ss_&&var_&i.;
    var_name = symget('var_' || left(&i.));
    drop _TYPE_;
  run;

%end;

/* merge the datasets into a single summary dsn */
  %macro set_list;
    %do i=1 %to &numvars;
      ss_&&var_&i.
    %end;
  %mend set_list;

  data sum_stats;
    length var_name $32.;
    set %set_list;
  run;

/* delete the excess base tables */
  proc sql;
    %do i= 1 %to &numvars;
      %let var_&i = %scan(&varlist, &i);
      drop table ss_&&var_&i;
    %end;
  quit;
%mend sum_stats;



/********************************************************/
%macro cust_quants(dsn, quant_list, varlist, numvars);
/*  Author:  Alex Whitworth
    Date: Jan, 2013  
    DESC: calculates custom quantiles for a given dataset
      and given variables w/in the dataset. Summary statistics are
      output to a single dataset.
    
    **Arguments:**
    dsn = a dataset
    quant_list = list of quantiles you want to find
    varlist = a list of variables in the dataset for which you
      want summary statistics calculated.
    numvars = number of vars in &varlist
******************************************************************/

%do i= 1 %to &numvars.;
  %let var_&i = %scan(&varlist, &i);
  /* calc quantile statistics for each variable */
  proc univariate data= &dsn noprint;
    var &&var_&i;
    output out= qs_&&var_&i 
      pctlpts= &quant_list
      pctlpre= q_;
  run;

/* add an identifying name to the summary stats for each var */
  data qs_&&var_&i.;
    set qs_&&var_&i.;
    var_name = symget('var_' || left(&i.));
  run;
%end;

/* merge the datasets into a single summary dsn */
  %macro set_list;
    %do i=1 %to &numvars;
      qs_&&var_&i.
    %end;
  %mend set_list;

  data qSum_stats;
    length var_name $32.;
    set %set_list;
  run;

/* delete the excess base tables */
  proc sql;
    %do i= 1 %to &numvars;
      %let var_&i = %scan(&varlist, &i);
      drop table qs_&&var_&i;
    %end;
  quit;

%mend cust_quants;



/********************************************************/
%macro data_distribution(dsn, quant_list, varlist, numvars);
/*  Author:  Alex Whitworth
    Date: April, 2013
    Desc: Calculates distributional statistics for the specified
      variables in a dataset and combines output into a summary
      table. Statistics include quantiles, min, max, skew, and STD.

    **Arguments:**
      dsn = a dataset
      quant_list = list of quantiles you want to find
      varlist = a list of variables in the dataset for which you
        want summary statistics calculated.
      numvars = number of vars in &varlist
******************************************************************/

%do i= 1 %to &numvars.;
  %let var_&i = %scan(&varlist, &i);
  /* calculate distributional statistics for each variable */
  proc univariate data= &dsn noprint;
    var &&var_&i;
    output out= qs_&&var_&i 
      skewness= skew
      std= std_dev
      min= min
      max= max
      pctlpts= &quant_list
      pctlpre= q_;
  run;

/* add an identifying name to the summary stats for each var */
  data qs_&&var_&i.;
    set qs_&&var_&i.;
    var_name = symget('var_' || left(&i.));
  run;
%end;

/* merge the datasets into a single summary dsn */
  %macro set_list;
    %do i=1 %to &numvars;
      qs_&&var_&i.
    %end;
  %mend set_list;

  data dist_stats;
    length var_name $32.;
    set %set_list;
  run;

/* delete the excess base tables */
  proc sql;
    %do i= 1 %to &numvars;
      %let var_&i = %scan(&varlist, &i);
      drop table qs_&&var_&i;
    %end;
  quit;

%mend data_distribution;
