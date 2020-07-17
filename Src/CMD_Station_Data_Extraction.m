% ----------------------------------------------------------------------------------------
%This codes are used to extract the PCP data for each station from the
% CMD dataset
% Created by Ling, zhanglingky@lzb.ac.cn.
% Created in 2019.6/21
% ----------------------------------------------------------------------------------------

% clc;clear

% data folder
function [CMD_obs]=CMD_Station_Data_Extraction(CMD_Folder,mete_station_name,start_day,end_day)
% CMD_Folder='F:\Data_ZL\CMD-PCP\raw_PCP_data\';

CMD_Station_Prefix='SURF_CLI_CHN_MUL_DAY-PRE-13011-';
CMD_Staion_Postix='.txt';
% current_folder='D:\Work_2020\Papers\PCP_merge\output\';
% start_day=[2007,1,1];
% end_day=[2007,12,31];
delta = datenum(end_day)-datenum(start_day)+1;
% mete_station_name='Station_location_Degree_new.xlsx';
CMD_Station_Location=xlsread([CMD_Folder,mete_station_name]);
Station_Name=CMD_Station_Location(:,1);
%% Reading CMD sation data
CMD_PCP_Data_All=[];

for Years=start_day(1):end_day(1)
    for Month_Id=1:12
        
        Month_Same_Length=num2str(Month_Id,'%02d');
        PCP_File_Name=strcat(CMD_Station_Prefix,num2str(Years),Month_Same_Length,CMD_Staion_Postix);
        
        % Reading data
        CMD_PCP_Data_Temp=load(strcat(CMD_Folder,PCP_File_Name));
        CMD_PCP_Data_All=[CMD_PCP_Data_All;CMD_PCP_Data_Temp];
        
    end
end

%% Precipitaion Data Extraction 
% 20£º00-8£º00

Prec_data=CMD_PCP_Data_All(:,8);

% 32744,empty;32700,microcale;32766, missing
ID_Nodata=find (Prec_data==32744);
Prec_data(ID_Nodata)=0; %#ok<FNDSB>
ID_Nodata=find (Prec_data==32700);
Prec_data(ID_Nodata)=0; %#ok<FNDSB>
ID_Nodata=find (Prec_data==32766);
Prec_data(ID_Nodata)=0;

% 31(xxx),30(xxx),snow and rain;32(xxx),fog,dew,frost
ID_Snow=find (Prec_data>30000);
Prec_data(ID_Snow)=( Prec_data(ID_Snow)-floor(Prec_data(ID_Snow)/1000)*1000);

% Unit coversion 0.1 mm to 1 mm
Prec_data=Prec_data.*0.1 ;

% 8£º00-20£º00
Prec_data_new=CMD_PCP_Data_All(:,9);

% 32744,empty;32700,microcale;32766, missing
ID_Nodata=find (Prec_data_new==32744);
Prec_data_new(ID_Nodata)=0; %#ok<FNDSB>
ID_Nodata=find (Prec_data_new==32700);
Prec_data_new(ID_Nodata)=0; %#ok<FNDSB>
ID_Nodata=find (Prec_data_new==32766);
Prec_data_new(ID_Nodata)=0;

% 31(xxx),30(xxx),snow and rain;32(xxx),fog,dew,frost
ID_Snow=find (Prec_data_new>30000);
Prec_data_new(ID_Snow)=( Prec_data_new(ID_Snow)-floor(Prec_data_new(ID_Snow)/1000)*1000);

% Unit coversion 0.1 mm to 1 mm
Prec_data_new=Prec_data_new.*0.1 ;


% Final used CMD data
CMD_Prec_data=[CMD_PCP_Data_All(:,1:7), Prec_data,Prec_data_new];

% save the data
%  save('CMD_Station_Prec_data.mat','CMD_Prec_data')

%%

CMD_Prec_All_Station=zeros(delta,length(CMD_Station_Location));

for i=1:length(Station_Name)
    Station_Name(i)
    ID_Temp=find(CMD_Prec_data(:,1)==Station_Name(i));
    Station_Temp=CMD_Prec_data(ID_Temp,:);
    
    % just save the defined period
    Station_Temp((delta+1):end,:)=[]; 
    
    % covert local Beijing Time to UTC time
    before_today=Station_Temp(:,8);
    after_today=Station_Temp(:,9);
    
    before_today(1)=[];
    before_today(end+1)=after_today(end);
    today_UTC=before_today+after_today;
    
    Daily_Temp=[Station_Temp(:,5:7),today_UTC];
   
    CMD_Prec_All_Station(:,i)=Daily_Temp(:,end);
end

CMD_obs=CMD_Prec_All_Station;

save([CMD_Folder,'CMD_obs.mat'],'CMD_obs');
end
    
 
    



