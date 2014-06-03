options source2;
filename source1 url 'https://github.com/crossfitAL/resume_ex_code/distribution_Macros.sas';
%include source1;


/****Information Value Macro for continuous variables***/
%macro inf_cont(dsn, rank_var, resp_var, bins);
/* arguments:
  dsn       = dataset
  rank_var  = variable to analyze VOI
  resp_var   = your response variable / Dependent Var (ie- buy flag)
  bins      = # of bins to split a continuous variable into
*/

/* bin variable of interest */
proc sort data= &dsn(keep= &rank_var &resp_var) out= ranked;
  by descending &rank_var;
run;

data ranked;
  set ranked nobs= numobs;
  bin = ceil(_n_ * &bins / (numobs + 1));
  keep &rank_var &resp_var bin;
run;

/* transform response variable from long-to-wide */
data temp;
  set ranked;
  if &resp_var = 1 then do;
    buyer = 1;
    nonbuyer = 0; end;
  else do;
    buyer = 0;
    nonbuyer = 1; end;
run;

/* summarize responses by bin */
proc summary data=temp missing;
  var buyer nonbuyer;
  class bin;
  output out= bin_sum;
run;

/* split summary data by bin and total */
data bins total;
  set bin_sum;
  if _type_ = 0 then output total;
  else if _type_ = 1 then output bins;
run;

/* rename vars for VOI calc */
data total (keep= bin totbuyer totnonbuyer _type_);
  set total;
  totbuyer = buyer;
  totnonbuyer = nonbuyer;
run;

/* calc VOI */
data bin_voi;
  if _N_ = 1 then set total;
  set bins;

  pct_buys = buyer / totbuyer;
  pct_nonbuys = nonbuyer / totnonbuyer;

  if (pct_buys / pct_nonbuys ~= 0) then
    inf = (pct_buys - pct_nonbuys) * log(pct_buys / pct_nonbuys);
  else 
    inf = 0;
run;

proc sql;
  create table &rank_var. as
  select sum(inf) as inf, "&rank_var" as name
  from bin_voi;
run;

%Mend inf_cont;


/****Information Value Macro for flag variables***/
%macro inf_flag(dsn, rank_var, resp_var);
/* arguments:
  dsn       = dataset
  rank_var  = variable to analyze VOI
  resp_var   = your response variable / Dependent Var (ie- buy flag)
*/

/* sort variable of interest */
proc sort data= &dsn(keep= &rank_var &resp_var) out= ranked;
  by descending &rank_var;
run;

/* transform response variable from long-to-wide */
data temp;
  set ranked;
  if &resp_var = 1 then do;
    buyer = 1;
    nonbuyer = 0; end;
  else do;
    buyer = 0;
    nonbuyer = 1; end;
run;

/* summarize responses by bin */
proc sql;
create table bin_sum as
select &rank_var, sum(buyer) as buyer, sum(nonbuyer) as nonbuyer
from temp
group by &rank_var
union 
select . as &rank_var, sum(buyer) as buyer, sum(nonbuyer) as nonbuyer 
from temp;
quit;

/* split summary data by bin and total */
data bins total;
  set bin_sum;
  if &rank_var = . then output total;
  else output bins;
run;

/* rename vars for VOI calc */
data total(keep= &rank_var totbuyer totnonbuyer);
  set total;
  totbuyer = buyer;
  totnonbuyer = nonbuyer;
run;

/* calc VOI */
data bin_voi;
  if _N_ = 1 then set total;
  set bins;

  pct_buys = buyer / totbuyer;
  pct_nonbuys = nonbuyer / totnonbuyer;

  if (pct_buys / pct_nonbuys ~= 0) then
    inf = (pct_buys - pct_nonbuys) * log(pct_buys / pct_nonbuys);
  else 
    inf = 0;
run;

proc sql;
  create table &rank_var. as
  select sum(inf) as inf, "&rank_var" as name
  from bin_voi;
run;

%Mend inf_flag;



%macro comb_info(dsn, resp_var, bins, numvars, varlist);
/* arguments:
  dsn       = dataset
  resp_var   = your response variable / Dependent Var (ie- buy flag)
  bins      = # of bins to split a continuous variable into
  numvars   = # of variables in the varlist
  varlist    = variable-list of variables to analyze VOI
*/

/* 1. */
/* summarize data - to determine variable distribution.
    Then separate variables by type and create macro-lists
    of each set of variables. */
%data_distribution(dsn= &dsn,
             quant_list= 1 50 99,
              varlist= &varlist,  
              numvars= &numvars);


data integer norm;
  set dist_stats;

  if (
    (min = 0 and max = 1) /* flag variables */
    or ((min = 0 or min = 1) and q_99 <= 10) /* count / leveled-categorical variables */
    )  then output integer;
  else output norm; /* approximately normal continuous variables */

run;

/* 1.B */
/* macro-lists of variable sets */
data _null_;
  set integer nobs= ob_num;
  call symput('i_cnt', ob_num);
run;
data _null_;
  set norm nobs= ob_num;
  call symput('j_cnt', ob_num);
run;

proc sql noprint;
  select var_name into: int_list separated by " "
  from integer;
quit;

proc sql noprint;
  select var_name into: norm_list separated by " "
  from norm;
quit;

/* 2. */
/* run value of information macro on flag / integer variables */
%do i= 1 %to &i_cnt;
  %let var_&i = %scan(&int_list, &i);
  %inf_flag(dsn= &dsn, rank_var= &&var_&i., resp_var= &resp_var);
%end;

/* run value of information macro on normal / skewed variables */
%do j= 1 %to &j_cnt;
  %let var_&j = %scan(&norm_list, &j);
  %inf_cont(dsn= &dsn, rank_var= &&var_&j. , resp_var= &resp_var, bins= &bins);
%end;

/* merge the datasets into a single summary dsn */

  %macro set_list;
    &int_list &norm_list
  %mend set_list;

  data combined_VOI;
    length name $32.;
    set %set_list;
  run;

/* sort by value of information */
  proc sort data= combined_VOI;
    by descending inf;
  run;

/* delete the base tables */
  proc sql;
    %do i=1 %to &numvars;
      %let var_&i = %scan(&varlist, &i);
      drop table &&var_&i;
    %end;
      drop table integer;
      drop table norm;
      drop table ranked; 
      drop table temp;
      drop table bin_sum;
      drop table bins;
      drop table total;
      drop table bin_voi;
  quit;

%mend comb_info;


