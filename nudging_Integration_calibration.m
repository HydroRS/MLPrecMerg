function [ Optimaized_value ] = nudging_Integration_calibration( temp_predict, temp_out_vali,X_ini)

if nargin<=3 
    [m,n]=size(temp_predict);
    X_ini=repmat(1/n,1,n);
end

% paramters optimization
% [RES,FVAL,EXITFLAG,OUTPUT]=fmincon(@calibration_ok, X_ini,[],[],[],[],...
%      0,1,[],[],TMPA,SW2R,CMD);
% %  
%  [RES,FVAL,EXITFLAG,OUTPUT]=fmincon(@calibration_ok, X_ini,[],[],[],[],...
%      0,1,[],optimset('Display','iter','MaxIter',100,'MaxFunEvals',500,...
%      'TolFun',1E-8,'Largescale','off','Algorithm','active-set'),...
%      TMPA,SW2R,CMD);

Aeq=ones(1,n);
beq=1;
% OPTS=optimset('LargeScale','off','display','iter','Algorithm','interior-point');
        OPTS=optimset('Algorithm','interior-point');
      problem= createOptimProblem('fmincon','objective', @(x)  calibration_ok (x,temp_predict, temp_out_vali), 'x0', X_ini, ...
            'Aineq', [], 'bineq', [], 'Aeq', Aeq, 'beq', beq, 'lb', 0, 'ub', 1,...
            'nonlcon',[], 'options',OPTS);
    % Glogbal search
        gs = GlobalSearch;
        Optimaized_value= run(gs,problem);% optimized parmater
        
 
%  [R2, RMSE, NSE, integrated_PCP] = nudging_Integration (TMPA, SW2R, CMD, Optimaized_value );
 
 
end

function Objective = calibration_ok (x, temp_predict, temp_out_vali)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
 [R2, RMSE, NSE, integrated_PCP] = nudging_Integration (temp_predict, temp_out_vali, x );
 
Objective=RMSE; 
 % Objective=1-NSE; 

end


