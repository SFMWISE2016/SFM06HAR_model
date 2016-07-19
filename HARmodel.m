clear all

% Import the data
DJAI = csvread('DJIA_for_Matlab.csv');

% Read the sequences
Date = DJAI(:,1);
YYYY = fix(Date/10000);
MM = fix((Date-10000*YYYY)/100);
DD = mod(Date,100);
Date_NO = datenum(YYYY,MM,DD);
YYYYMM = 1000*YYYY + MM;
RV_Day = DJAI(:,2);
Returns = DJAI(:,3);

% Get RV(d)_{t+1} and RV(d)_{t}
Returns_t = Returns(2:end);
Returns_lagt = Returns(1:end-1);

% Get RV(w)_{t} and RV(m)_{t}
L = length(Date);
RV_week = zeros(L,1);
RV_month = zeros(L,1);

count = [];
for ii= 1:(L-1)
    if Date_NO(ii+1)-Date_NO(ii)==1
        count = [count ii];
    else
        count = [count ii];
        RV_week_temp = (Returns_t(count)-Returns_lagt(count))' *(Returns_t(count)-Returns_lagt(count));
        RV_week(count) = RV_week_temp;
        count = [];
    end
end
RV_week_temp = Returns(count)' *Returns(count);
RV_week(count) = RV_week_temp;

count = [];
for ii= 1:(L-1)
    if YYYYMM(ii+1)==YYYYMM(ii)
        count = [count ii];
    else
        count = [count ii];
        RV_month_temp = Returns(count)' *Returns(count);
        RV_month(count) = RV_month_temp;
        count = [];
    end
end
RV_month_temp = (Returns_t(count)-Returns_lagt(count))' *(Returns_t(count)-Returns_lagt(count));
RV_month(count) = RV_month_temp;

% HAR regression
Y = RV_Day(2:end);
X = [ones(L-1,1) RV_Day(1:end-1) RV_week(1:end-1) RV_month(1:end-1)];
b = (X'*X)\(X'*Y);
Forecasted_Y = X*b;

% Plot the sequences
Date_string = datestr(Date_NO(2:end));
plot(Date_NO(2:end),Y,'b-',Date_NO(2:end),Forecasted_Y,'r-')
datetick('x','yyyymm','keeplimits')
title('Observed and forecasted RV based on HAR model: HARRV')
xlabel('Time')
ylabel('Realized Volatility')
legend('Observed RV','Forecasted RV')