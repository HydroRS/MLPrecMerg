function [ monthly_data ] = Daily2monthly( daiy_rawdata, Model_start_year,Model_end_year)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% User difined Parmaters

monthly_data=[];
crrent_day=1;
for year = Model_start_year:Model_end_year
     
    for month = 1:12   
        month_day = eomday(year, month);
        data_temp=mean(daiy_rawdata(crrent_day:(crrent_day+month_day-1)));
        monthly_data=[monthly_data;[year,month,data_temp]];
        crrent_day=crrent_day+month_day;
    end
      
end



