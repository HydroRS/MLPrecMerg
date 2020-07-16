function IMERG = read_IMERG( IMERG_Folder,current_Folder, mete_station_name, start_day, end_day )

% ----------------------------------------------------------------------------------------
%This codes are used to extract the PCP data from IMERG
% for each station from the CMD.
% Created by Ling, zhanglingky@lzb.ac.cn.
% Created in 2020/5/5
% ----------------------------------------------------------------------------------------

% clc;clear

% data folder
% IMERG_Folder='F:\Data_ZL\GPM_IMERG\Early_Run\';
% current_Folder='D:\Work_2020\Papers\PCP_merge\predictor\SSPs\';

%% Reading CMD station location
CMD_Station_Location=xlsread([current_Folder,mete_station_name]);
lon=CMD_Station_Location(:,3);
lat=CMD_Station_Location(:,2);
Station_Name=CMD_Station_Location(:,1);


% Basic info of the IMERG Early Run data
namefile='3B-DAY-E.MS.MRG.3IMERG.20000601-S000000-E235959.V06.nc4.nc4';
lon_=ncread([IMERG_Folder,namefile],'lon');
lat_=ncread([IMERG_Folder,namefile],'lat');

% data length
% start_day=[2007,1,1];
% end_day=[2017,1,3];
delta = datenum(end_day)-datenum(start_day)+1;

% reading data
IMERG_Prec_All_Station=zeros(delta,length(CMD_Station_Location));
kk=1;
for year = start_day(1):end_day(1)
    
    % end month
    if year==end_day(1)
        end_month=end_day(2);
    else
        end_month=12;
    end
    
    for month = 1:end_month
        
        % end day
        if month==end_day(2)&&year==end_day(1) 
            num_day=end_day(3);
        else
            num_day=eomday(year, month);
        end
        
        for  month_day =1:num_day
            
            month_samlength=num2str(month,'%02d'); % the number of month with the same length
            day_samlength=num2str(month_day,'%02d'); % the number of day with the same length
            
            % IMERG data for Current day
             IMERG_read = ncread([IMERG_Folder,'3B-DAY-E.MS.MRG.3IMERG.',num2str(year),...
                 month_samlength,day_samlength,'-S000000-E235959.V06.nc4.nc4'],'precipitationCal');
             [IMERG_Folder,'3B-DAY.MS.MRG.3IMERG.',num2str(year),month_samlength,day_samlength,'-S000000-E235959.V06.nc4.nc4']
            % Coordinates of the station you want to extract
            %  lon_stat=100.43; lat_stat=38.93; % 52652
            PCP_day=[];
            parfor i=1:length(lon)
                lon_stat=lon(i);
                lat_stat=lat(i);
                %Extraction of the pixel closest to the selected coordinates
                ID_lon=knnsearch(lon_,lon_stat);
                ID_lat=knnsearch(lat_,lat_stat);
                PCP_Temp=IMERG_read(ID_lat,ID_lon ); % read data for current station
                PCP_day=[PCP_day,PCP_Temp];
            end
            IMERG_Prec_All_Station(kk,:)=PCP_day;
            kk=kk+1;           
        end
    end
end
IMERG=IMERG_Prec_All_Station;
save([current_Folder,'IMERG.mat'],'IMERG');


end

