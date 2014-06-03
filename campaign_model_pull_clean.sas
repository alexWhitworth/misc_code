/**********************************************************************/
/*  Author:   Alex Whitworth                                          */
/*  Date:      April-2013                                              */
/*  Desc:      This code provides a generalized macro applicable to    */
/*    up to 3 campaigns for the production code  located in:            */
/*    <redacted>  */
/**********************************************************************/

/* source macros for model pull */
options source2 LRECL= 32767;
%include '<redacted>';
%include '<redacted>';
%include '<redacted>';

%macro generalModelPull(
          out_folder1= '\\Smpsasp02\tsas\RETAINED\Alex\',
          out_folder2= '\\Smpsasp02\tsas\RETAINED\Alex\',
          out_folder3= '\\Smpsasp02\tsas\RETAINED\Alex\',
          initials= 'AW', 
          camp_code1= , camp_code2= , camp_code3= ,
          camp_date1= , camp_date2= , camp_date3= ,
          product_codes= ,
          product_groups=,
          samp_perc= ,
          policy_beg_date=, 
          allMailings_beg_date=, 
          allMailingsFU_beg_date=, 
          marketingEvent_beg_date=          
          );

/* run for campaign 1 */
%if (%sysevalf(%superq(camp_code1) ~= , boolean) 
    and %sysevalf(%superq(camp_date1) ~= , boolean)) %then
  %generalModelPull_sub(out_folder= &out_folder1,
                        initials= &initials,
                        camp_code= &camp_code1, 
                        product_codes= &product_codes, product_groups=&product_groups,
                        policy_beg_date= &policy_beg_date,
                        allMailings_beg_date= &allMailings_beg_date,
                        allMailingsFU_beg_date= &allMailingsFU_beg_date,
                        marketingEvent_beg_date= &marketingEvent_beg_date);;

%policyMerge_sub(
    out_folder= &out_folder1,
    initials= &initials,
    camp_code= &camp_code1
    );

%ModelRollups_sub(
    out_folder= &out_folder1,
    initials= &initials,
    camp_code= &camp_code1,
    camp_date= &camp_date1,
    product_codes= &product_codes,
    samp_perc= &samp_perc
    );

/* run for campaign 2 */
%if (%sysevalf(%superq(camp_code2) ~= , boolean) 
    and %sysevalf(%superq(camp_date2) ~= , boolean)) %then
  %generalModelPull_sub(out_folder= &out_folder2,
                        initials= &initials,
                        camp_code= &camp_code2, 
                        product_codes= &product_codes, product_groups=&product_groups,
                        policy_beg_date= &policy_beg_date,
                        allMailings_beg_date= &allMailings_beg_date,
                        allMailingsFU_beg_date= &allMailingsFU_beg_date,
                        marketingEvent_beg_date= &marketingEvent_beg_date);;

%policyMerge_sub(
    out_folder= &out_folder2,
    initials= &initials,
    camp_code= &camp_code2
    );

%ModelRollups_sub(
    out_folder= &out_folder2,
    initials= &initials,
    camp_code= &camp_code2,
    camp_date= &camp_date2,
    product_codes= &product_codes,
    samp_perc= &samp_perc
    );


/* run for campaign 3 */
%if (%sysevalf(%superq(camp_code3) ~= , boolean) 
    and %sysevalf(%superq(camp_date3) ~= , boolean)) %then
%generalModelPull_sub(out_folder= &out_folder3,
                        initials= &initials,
                        camp_code= &camp_code1, 
                        product_codes= &product_codes, product_groups=&product_groups,
                        policy_beg_date= &policy_beg_date,
                        allMailings_beg_date= &allMailings_beg_date,
                        allMailingsFU_beg_date= &allMailingsFU_beg_date,
                        marketingEvent_beg_date= &marketingEvent_beg_date);;

%policyMerge_sub(
    out_folder= &out_folder3,
    initials= &initials,
    camp_code= &camp_code3
    );

%ModelRollups_sub(
    out_folder= &out_folder3,
    initials= &initials,
    camp_code= &camp_code3,
    camp_date= &camp_date3,
    product_codes= &product_codes,
    samp_perc= &samp_perc
    );

%mend generalModelPull;


%macro merge_final(out_folder1= ,
                   out_folder2= ,
                   out_folder3= ,
                   dsn1= , dsn2=, dsn3=,
                   by_var=);
/**************************************************************/
/* Arguments:
    out_folder = location where data resides and will be merged.
    dsn1 - 3 = names of 3 datasets to be merged
    by_var = unique id for sorting */
/**************************************************************/

/* library declaration */
libname out1 &out_folder1;
libname out2 &out_folder2;
libname out3 &out_folder3;

/* sort */
proc sort data= out1.&dsn1;
  by &by_var;
run;

proc sort data= out2.&dsn2;
  by &by_var;
run;

proc sort data= out3.&dsn3;
  by &by_var;
run;

/* merge */
data out1.combined_final;
  set out1.&dsn1 out2.&dsn2 out3.&dsn3;
run;

%mend merge_final;
