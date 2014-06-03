/*****************************************************************/
%macro impute_missing(dsn, var_miss, var_response);
/*  Author:  Alex Whitworth
    Date:    May, 2013
    DESC:    for a given dataset and variable, calculate the level
      for which missing values have the most similar response rate.

   **Arguments:**
    dsn = a dataset
    var_miss = variable in the dataset for which you want to impute
          missing values.
    var_response = the response variable
******************************************************************/

proc summary data= &dsn nway missing;
  var &var_response;
  class &var_miss;
  output out= temp_miss1 mean(&var_response) = success_rate;
run;

data _null_;
  set temp_miss1;
  if _n_ = 1 then call symput('macro_miss_val', success_rate);
run;

data temp_miss2;
  set temp_miss1;
  if _n_ = 1 then do;
    abs_diff = .; end;
  else abs_diff = abs(success_rate - &macro_miss_val.);
run;

/* save recode level as macro variable for use in %impute_all_missing */
%global macro_recode_value;
proc sql noprint;
select &var_miss into: macro_recode_value
from temp_miss2 a 
  inner join (select min(abs_diff) as min
              from temp_miss2) b
    on a.abs_diff = b.min;
quit;

%mend impute_missing;

/*****************************************************************/
%macro impute_all_missing(dsn, var_response, varlist, numvars,
    export_loc= '');
/*  Author:  Alex Whitworth
    Date:    May, 2013
    DESC:    calculate the level for which missing values have the 
      most similar response rate for each variable in a given 
      variable list and dataset.
      Then replace missing values for each of these variables with
      the associated level.
    Note:   Also outputs a scorecode dataset (WORK lib) for reference.

   **Arguments:**
    dsn = a dataset
    var_response = the response variable
    varlist = a list of variables in the dataset for which you
      want summary statistics calculated.
    numvars = number of vars in &varlist
    export_loc = file location you would imputed score code saved
******************************************************************/

/* for each variable, calculate and store the level with a response
    rate that corresponds most closely to the missing level. */
%do i= 1 %to &numvars;
  %let var_&i = %scan(&varlist, &i);
  %impute_missing(dsn= &dsn, var_miss= &&var_&i., var_response= &var_response);
  %let macro_recode_&i = &macro_recode_value;
%end;

data &dsn._imputed;
  set &dsn;

  /* recode / impute all the missing values */
  %do i= 1 %to &numvars;
    if &&var_&i. = . then &&var_&i. = &&macro_recode_&i.; 
  %end;
run;

/* save imputed scorecode */
data impute_scores;
  length var_name $32 recode 8.;

  do _N_ = 1 to &numvars;
    var_name = symget('var_' || left(_N_));
    recode = symget('macro_recode_' || left(_N_));
    output;
  end;
run;

/* if user specified an export location, export the imputed score codes */
%if &export_loc ~= '' %then %do;
proc export data= impute_scores
  dbms= csv replace
  outfile= &export_loc;
run;
%end;

/* delete the base tables */
proc sql;
  drop table temp_miss1;
  drop table temp_miss2;
quit;

%mend impute_all_missing;


/*****************************************************************/
%macro impute_all_zero(dsn, value, varlist, numvars);
/*  Author:  Alex Whitworth
    Date:    May, 2013
    DESC:    replace missing values for each of the variables in
      varlist with the value given.

   **Arguments:**
    dsn = a dataset
    value = the value you wish to set missing values to
    varlist = a list of variables in the dataset for which you
      want summary statistics calculated.
    numvars = number of vars in &varlist
******************************************************************/

/* scan the variable list */
%do i= 1 %to &numvars;
  %let var_&i = %scan(&varlist, &i);
%end;

data &dsn;
  set &dsn;
  /* recode / impute all the missing values */
  %do i= 1 %to &numvars;
    if &&var_&i. = . then &&var_&i. = &value; 
  %end;
run;

%mend impute_all_zero;
