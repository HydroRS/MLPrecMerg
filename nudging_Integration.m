function [R2, RMSE, NSE, integrated_PCP ] = nudging_Integration (temp_predict, temp_out_vali, Parm_K )
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

 [m,n]=size(temp_predict);
 Parm_K=repmat(Parm_K,m,1);
 integrated_PCP=sum(temp_predict.*Parm_K,2);
 
% integrated_PCP=TMPA+Parm_K.*(SW2R-TMPA);

R2=(corr(integrated_PCP(:,end) , temp_out_vali(:,end)));
RMSE=nanmean((integrated_PCP(:,end)-temp_out_vali(:,end)).^2).^0.5;
NSE=1-nansum((integrated_PCP(:,end)-temp_out_vali(:,end)).^2)/nansum((temp_out_vali(:,end)-nanmean(temp_out_vali(:,end))).^2);

end

