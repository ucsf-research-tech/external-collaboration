/*
.SYNOPSIS
  Exports all data from REDCap project to single data SAS set.

.DESCRIPTION
  Uses PROC HTTP call to REDCap RESTful API to extract all columns for all
  records from a designated REDCap project, stores raw data in temp file,
  then copies data from temp file to analysis-ready dataset with extracted
  column names correctly assigned.

  Note: Makes no attempt to match field types or labels with REDCap front-end
  SAS export method.

.INPUTS
  Valid API token in alphanumeric format stored in [my_token] variable

.OUTPUTS
  temp.my_in -- HTTP POST command to be passed to REDCap API
  temp.status -- response code from HTTP POST to REDCap API
  temp.my_in -- raw response values (dataset) returned from REDCap API
  work.my_data -- analysis-ready dataset (with column names)

.NOTES
  Version:        1.1
  Author:         Remi Frazier
  Creation Date:  2020-08-17
  Purpose/Change: Updated to make endpoint generic
.EXAMPLE
  n/a
*/

*---------------------------------------------------------[Script Parameters]------------------------------------------------------;
*** Project- and user-specific token obtained from REDCap ***;
*** Insert your API token from your project's "API" page below - no quotes ***;
%let my_token = XXXXXXXXXXXXXXXXXXXXXXX;

*** Note that this is an insecure method for executing a query against data containing PHI. ***;
*** API tokens should be passed by a calling script at execution using user input or a keystore when possible. ***;

*---------------------------------------------------------[Initialisations]--------------------------------------------------------;

/*Import Modules & Snap-ins*/

*----------------------------------------------------------[Declarations]----------------------------------------------------------;

/*Global Declarations of file sources*/
filename status temp;
filename my_out temp;
filename my_in temp;

/*Project-specific connection strings*/
%let my_url = "https://<YOUR INSTITUTION'S ENDPOINT>/api/";

*** Note that this variable sometimes historically has pass incorrectly to the PROC HTTP below. ***;
*** If you have this issue, replace the call to my_url below with the string for your endpoint above. ***;

*-----------------------------------------------------------[Functions]------------------------------------------------------------;
/*Writes response code to disk*/
%macro echoResp(fn=);
data _null_;
 infile &fn;
 input;
 put _infile_;
run;
%mend;



*-----------------------------------------------------------[Execution]------------------------------------------------------------;
 /**********************************************************
Step 2. Request all observations (CONTENT=RECORDS) with one
row per record (TYPE=FLAT).
******************************************************/
*** Create the text file to hold the API parameters. ***;
data _null_ ;
file my_in ;
put "%NRStr(content=record&type=flat&format=csv&csvDelimiter='|'&token=)&my_token";
run; 

*** For additional API export wizardry - exporting specific forms, ***;
*** reports, or individual record, consult your project's API Playground page.***;
***-----------------------------------------------------------***;


***-----------------------------------------------------------***;
*** PROC HTTP call. Everything except HEADEROUT= is required. ***;
proc http
 in= my_in
 out= my_out
 headerout = status
 url = my_url 
    ***^^^^^^ or replace with "https://<YOUR INSTITUTION'S ENDPOINT>/api/" ***;
 method="POST";
run; 

%echoResp(fn=status);
%echoResp(fn=my_out);

proc import datafile=my_out out=my_data dbms=csv replace;
    getnames=yes;
run;

proc contents data=my_data;
run;
