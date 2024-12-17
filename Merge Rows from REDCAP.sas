
*Import data file AFTER manually saving csv export from REDCap as excel workbook;
proc import out=duplicates
datafile="FILE PATH WHERE REDCAP EXPORT IS SAVED\FILE NAME.xlsx"
dbms=xlsx replace;
run;


*Split dataset into two sets, one for each event;

**Create baseline event dataset;
data baseline (replace=yes);
set duplicates;
if redcap_event_name = 'baseline_arm_1' then output;
event_name2 = "";
run;

**Create endpoint event dataset;
data link (replace=yes);
set duplicates;
if redcap_event_name = 'link_to_care_arm_1' then output;
rename redcap_event_name=event_name2; *rename 2nd event variable before merge;
drop screening_id last_name first_name dob ethnicity race gender primary_num texting_allowed phone_num2 texting_allowed_2 phone_num3 
texting_allowed_3 email_address address zip_code address_2 zip_code_2 active_mychart insurance___0 insurance___1 insurance___2 insurance___3 insurance_name 
inspire referral_to_specialist_obt___1 referral_to_specialist_obt___2 referral_to_specialist_obt___3 date_referred enrolled_inspire 
leap_cc_patient_id notes_pt_info patient_information_complete coinfection comorbid_diabetes; *drop all variables that are included in baseline event arm--
must do this or they will be overwritten by missing values in this dataset during merge;
run;

*Sort before merge;
proc sort data=baseline;
by record_id;
run;

proc sort data=link;
by record_id;
run;

*Merge datasets to have one observation per patient;
data linkage;
merge baseline link;
by record_id;
run;

*Export to Excel file;
proc export data=linkage
dbms=xlsx
outfile ="DESIRED OUTPUT LOCATION\FILE NAME" replace;
run;
