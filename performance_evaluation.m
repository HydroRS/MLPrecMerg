function [ Performance ] = performance_evaluation(Out_regression,In,y, Out_vali,In_vali,y_vali,pcp_threshold )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% training performance
% y= str2num(char(y));
[R2_train,type]= Performance_statstic(3, Out_regression, y);
[RMSE_train,type]= Performance_statstic(4, Out_regression, y);
[ POD_train, FAR_train, CSI_train ] = POD(y, Out_regression, pcp_threshold); % threshold=1mm

% IMERG
[R2_train_01,type]= Performance_statstic(3, Out_regression, In(:,1));
[RMSE_train_01,type]= Performance_statstic(4, Out_regression, In(:,1));
[ POD_train_01, FAR_train_01, CSI_train_01] = POD(In(:,1), Out_regression, pcp_threshold); % threshold=1mm

% SM2RASCAT
[R2_train_02,type]= Performance_statstic(3, Out_regression, In(:,2));
[RMSE_train_02,type]= Performance_statstic(4, Out_regression, In(:,2));
[ POD_train_02, FAR_train_02, CSI_train_02] = POD(In(:,2), Out_regression, pcp_threshold); % threshold=1mm

% PERSIANN
[R2_train_03,type]= Performance_statstic(3, Out_regression, In(:,3));
[RMSE_train_03,type]= Performance_statstic(4, Out_regression, In(:,3));
[ POD_train_03, FAR_train_03, CSI_train_03] = POD(In(:,3), Out_regression, pcp_threshold); % threshold=1mm

% GsMap
[R2_train_04,type]= Performance_statstic(3, Out_regression, In(:,4));
[RMSE_train_04,type]= Performance_statstic(4, Out_regression, In(:,4));
[ POD_train_04, FAR_train_04, CSI_train_04] = POD(In(:,4), Out_regression, pcp_threshold); % threshold=1mm

% validation performance
% y_vali= str2num(char(y_vali));
[R2_vali,type]= Performance_statstic(3, Out_vali, y_vali);
[RMSE_vali,type]= Performance_statstic(4, Out_vali, y_vali);
[ POD_vali, FAR_vali, CSI_vali ] = POD(y_vali, Out_vali, pcp_threshold); % threshold=1mm

% IMERG
[R2_vali_01,type]= Performance_statstic(3, Out_vali, In_vali(:,1));
[RMSE_vali_01,type]= Performance_statstic(4, Out_vali, In_vali(:,1));
[ POD_vali_01, FAR_vali_01, CSI_vali_01 ] = POD(In_vali(:,1), Out_vali, pcp_threshold); % threshold=1mm
% SM2RASCAT
[R2_vali_02,type]= Performance_statstic(3, Out_vali, In_vali(:,2));
[RMSE_vali_02,type]= Performance_statstic(4, Out_vali, In_vali(:,2));
[ POD_vali_02, FAR_vali_02, CSI_vali_02 ] = POD(In_vali(:,2), Out_vali, pcp_threshold); % threshold=1mm
% PERSIANN
[R2_vali_03,type]= Performance_statstic(3, Out_vali, In_vali(:,3));
[RMSE_vali_03,type]= Performance_statstic(4, Out_vali, In_vali(:,3));
[ POD_vali_03, FAR_vali_03, CSI_vali_03 ] = POD(In_vali(:,3), Out_vali, pcp_threshold); % threshold=1mm
% GsMap
[R2_vali_04,type]= Performance_statstic(3, Out_vali, In_vali(:,4));
[RMSE_vali_04,type]= Performance_statstic(4, Out_vali, In_vali(:,4));
[ POD_vali_04, FAR_vali_04, CSI_vali_04 ] = POD(In_vali(:,4), Out_vali, pcp_threshold); % threshold=1mm

Performance=[R2_train,R2_train_01,R2_train_02,R2_train_03,R2_train_04;...
             R2_vali,R2_vali_01,R2_vali_02,R2_vali_03,R2_vali_04;...
             
             RMSE_train,RMSE_train_01,RMSE_train_02,RMSE_train_03,RMSE_train_04;...
             RMSE_vali,RMSE_vali_01,RMSE_vali_02,RMSE_vali_03,RMSE_vali_04;...
             
             POD_train,POD_train_01,POD_train_02,POD_train_03,POD_train_04;...
             POD_vali,POD_vali_01,POD_vali_02,POD_vali_03,POD_vali_04;...
             
             FAR_train,FAR_train_01,FAR_train_02,FAR_train_03,FAR_train_04;...
             FAR_vali,FAR_vali_01,FAR_vali_02,FAR_vali_03,FAR_vali_04;...
             
             CSI_train,CSI_train_01,CSI_train_02,CSI_train_03,CSI_train_04;...
             CSI_vali,CSI_vali_01,CSI_vali_02,CSI_vali_03,CSI_vali_04;...
             ];

end

