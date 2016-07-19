# SFM06HAR_model
[<img src="https://github.com/QuantLet/Styleguide-and-Validation-procedure/blob/master/pictures/banner.png" alt="Visit QuantNet">](http://quantlet.de/index.php?p=info)

## [<img src="https://github.com/QuantLet/Styleguide-and-Validation-procedure/blob/master/pictures/qloqo.png" alt="Visit QuantNet">](http://quantlet.de/) **SFM09var_block_max_params** [<img src="https://github.com/QuantLet/Styleguide-and-Validation-procedure/blob/master/pictures/QN2.png" width="60" alt="Visit QuantNet 2.0">](http://quantlet.de/d3/ia)

```yaml
Name of QuantLet : SFM06HAR_model

Published in : Statistics of Financial Markets 

Description : 'Realized volatility analysis using harModel of Dow Jones Industrial Index'

Keywords : Volatility, graphical representation, time-series, log returns, variance

Author : Dexuan Tang, Ziyuan Fang, Ke Huang, Liang Tang

Submitted : Tue, July 19 2016 by Dexuan Tang

```

![Picture1](HAR_model_SAS.png)

# SAS code
```sas
libname proj1 'Z:\SFM';

/*import the data*/
proc import out=proj1.RV
datafile="Z:\SFM\OxfordManRealizedVolatilityIndices.csv"
dbms=csv replace;
run;

/*select DJIA data from Jun,1,2015 to Jun,30,2016*/
data proj1.DJIA_rv;
set proj1.RV;
where DateID>=20150601 and DateID<=20160630;
RV_daily= DJI2_rv;
if RV_daily="" then delete;
keep DateID RV_daily;
run;

/*create two labels for time and transform DateID into a date variable*/
data proj1.DJIA_rv;
set proj1.DJIA_rv;
t1=_n_;
t2=_n_;
DateID=input(put(DateID,z8.),yymmdd10.);
format DateID yymmdd10.;
keep t1 t2 DateID RV_daily;
run;

/*create leading 1 day daily realized volatility time sequence*/
data proj1.lead_RV_daily;
set proj1.DJIA_rv;
t2=t1+1;
lead_RV_daily=RV_daily;
keep t2 lead_RV_daily;
run;

/*calculate  weekly and monthly realized volatility for each DateID*/
%macro cal_RV_weekly_and_monthly(a,b);
%do x= &a %to &b;
  data proj1.temp1;
  set proj1.DJIA_RV;
  where &x-4<=t2<=&x;
  run;

  proc means data=proj1.temp1 noprint mean;
  var RV_daily;
  output out=proj1.temp2;
  run;

  data proj1.temp3;
  set proj1.temp2;
  if _STAT_='MEAN' then RV_weekly=RV_daily;
  if RV_weekly=.  then delete;
  t2=&x;
  keep t2 RV_weekly;
  run;

  %if &x=&a %then %do;
    data proj1.RV_weekly;
	set proj1.temp3;
	run;
  %end;

  proc append base=proj1.RV_weekly data=proj1.temp3;

  data proj1.temp4;
  set proj1.DJIA_RV;
  where &x-21<=t2<=&x;
  run;

  proc means data=proj1.temp4 noprint mean;
  var RV_daily;
  output out=proj1.temp5;
  run;

  data proj1.temp6;
  set proj1.temp5;
  if _STAT_='MEAN' then RV_monthly=RV_daily;
  if RV_monthly=.  then delete;
  t2=&x;
  keep t2 RV_monthly;
  run;

  %if &x=&a %then %do;
    data proj1.RV_monthly;
	set proj1.temp6;
	run;
  %end;

  proc append base=proj1.RV_monthly data=proj1.temp6;
%end;

proc sort nodupkey data=proj1.RV_weekly;
by t2;
run;

proc sort nodupkey data=proj1.RV_monthly;
by t2;
run;

quit;
%mend;

%cal_RV_weekly_and_monthly(22,275);

/*prepare the data for runing the HAR-RV model regression*/
data proj1.reg_rv;
merge proj1.DJIA_rv proj1.lead_RV_daily proj1.RV_weekly proj1.RV_monthly;
by t2;
if RV_monthly=""  then delete;
keep DateID t2 lead_RV_daily RV_daily RV_weekly RV_monthly;
run;

/*run the HAR-RV model regression*/
proc reg data=proj1.reg_rv noprint outest=proj1.betas;
model lead_RV_daily = RV_daily RV_weekly RV_monthly;
run;
quit;

/*get the coefficients of the HAR-RV model regression*/
data proj1.betas;
set proj1.betas;
call symput ("beta_daily",RV_daily);
call symput ("beta_weekly",RV_weekly);
call symput ("beta_monthly",RV_monthly);
call symput ("Int",Intercept);
run;

/*simulate the realized volatility by the HAR-RV model regression*/
data proj1.temp;
set proj1.reg_rv;
lead_RV_daily_est=&beta_daily.*RV_daily+&beta_weekly.*RV_weekly+&beta_monthly.*RV_monthly+&Int.;
keep DateID lead_RV_daily_est lead_RV_daily;
run;

/*prepare the data for ploting the observed RV and forecasted RV*/
proc expand data=proj1.temp out=proj1.plot method=none;
convert DateID = lead_DateID /transformout = (lead 1);
run;

data proj1.plot;
set proj1.plot;
Observed_RV=lead_RV_daily;
Forecasted_RV=lead_RV_daily_est;
keep lead_DateID Observed_RV Forecasted_RV;
run;

/*plot the observed RV and forecasted RV*/
proc sgplot data=proj1.plot;
title "Observed and forecasted RV based on HAR model: HARRV";
yaxis grid label ="Realized volatility";
xaxis grid label ="Time";
series x=lead_DateID y=Observed_RV;
series x=lead_DateID y=Forecasted_RV;
run;
```

![Picture1](HAR_model_Matlab.jpg)

# Matlab code
```matlab
