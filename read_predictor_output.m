function [ IMERG,SM2RAIN_ASCAT,PERSIANN,GsMap,CMD_obs,Distance ] = read_predictor_output( topography_fold,SPP_Folder,IMERG_Folder,SW2RAIN_ASCAT_Folder,PERSIANN_Folder,GsMAP_Folder,...
                                                                                         CMD_Folder,mete_station_name,start_day,end_day,...
                                                                                         IMERG_exist,SM2RAIN_exist,PRESIANN_exist,GsMap_exist,Distance_exist,CMD_exist )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%% ========================== Predictor read ============================
    %    ---------2007-2017--------
    % topography
%     if Distance_exist==0;
%         Distance = distance_calculation(topography_fold,mete_station_name );
%     else
%         Distance=load([topography_fold,'distance_met_station.mat']);
%         Distance=Distance.Distance;
%     end
%   
  Distance=0;
  
    % IMERG
    if IMERG_exist==0;
        IMERG = read_IMERG( IMERG_Folder,SPP_Folder, mete_station_name,...
            start_day, end_day );
        IMERG=IMERG';
    else
        IMERG=load([SPP_Folder,'IMERG.mat'],'IMERG');
        IMERG=(IMERG.IMERG)';
    end
    
    %SM2RAIN
    if SM2RAIN_exist==0;
        SM2RAIN_ASCAT=read_SM2RAIN_ASCAT( SW2RAIN_ASCAT_Folder,SPP_Folder,...
            IMERG_Folder,mete_station_name, start_day, end_day);
        SM2RAIN_ASCAT=SM2RAIN_ASCAT';
    else
        SM2RAIN_ASCAT=load([SPP_Folder,'SM2RAIN_ASCAT.mat'],'SM2RAIN_ASCAT');
        SM2RAIN_ASCAT=(SM2RAIN_ASCAT.SM2RAIN_ASCAT)';
    end
    
    %PRESIANN
    if  PRESIANN_exist==0;
        [ PERSIANN ] = read_PRESIANN( PERSIANN_Folder,SPP_Folder,...
            IMERG_Folder,mete_station_name, start_day, end_day);
        PERSIANN=PERSIANN';
    else
        PERSIANN=load([SPP_Folder,'PERSIANN.mat'],'PERSIANN');
        PERSIANN=(PERSIANN.PERSIANN)';
    end
    
    %GsMap
    if  GsMap_exist==0;
        [GsMap] = read_GsMap( GsMAP_Folder,SPP_Folder,IMERG_Folder,...
            mete_station_name, start_day, end_day );
        GsMap=GsMap';
    else
        GsMap=load([SPP_Folder,'GsMap.mat'],'GsMap');
        GsMap=(GsMap.GsMap)';
    end
    
    
    % CMD observations
    if  CMD_exist==0;
        CMD_obs=CMD_Station_Data_Extraction(topography_fold,...
            mete_station_name,start_day,end_day);
        CMD_obs=CMD_obs';
    else
        CMD_obs=load([topography_fold,'CMD_obs.mat'],'CMD_obs');
        CMD_obs=(CMD_obs.CMD_obs)';
    end
    


end

