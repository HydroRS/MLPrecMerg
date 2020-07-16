function [ Prediction_sub_test01_vali_new,Prediction_sub_test02_vali_new ] = ensemble_modeling( start_day, end_day,validation_subset01,...
    validation_subset02,Out_vali,Prediction_sub_test01_vali,Out_vali01,...
    Prediction_sub_test02_vali,Ensemble_method)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
current_day_vali=0;
current_day_vali01=0;
Performance_all_second_stage=[];
Prediction_sub_test01_vali_new=[];
Prediction_sub_test02_vali_new=[];
for year = start_day(1):end_day(1)
    % end month
    if year==end_day(1)
        end_month=end_day(2);
    else
        end_month=12;
    end
    
    for month = 1:end_month
        if month==end_day(2)&&year==end_day(1)
            num_day=end_day(3);
        else
            num_day=eomday(year, month);
        end
        for  month_day =1:num_day
            disp( [num2str(year),'-',num2str(month),'-',num2str(month_day)])
            temp_out_vali=Out_vali(current_day_vali+1:(current_day_vali+length(validation_subset01)*1),:); % outvali is observations
            temp_predict = Prediction_sub_test01_vali(current_day_vali+1:(current_day_vali+length(validation_subset01)*1),:); % predicitions by the 3 ML methods
            
            
            temp_out_vali01=Out_vali01(current_day_vali01+1:(current_day_vali01+length(validation_subset02)*1),:);
            temp_predict01 = Prediction_sub_test02_vali(current_day_vali01+1:(current_day_vali01+length(validation_subset02)*1),:); % predicitions by the 3 ML methods
            
            
            if Ensemble_method==1 % mean
                output=mean(temp_predict,2);
                output01=mean(temp_predict01,2);
                Prediction_sub_test01_vali_new=[Prediction_sub_test01_vali_new;output];
                Prediction_sub_test02_vali_new=[Prediction_sub_test02_vali_new;output01];
                
                
            elseif Ensemble_method==2 % Inverse Weight Error Weight
                [m, n]=size(temp_predict);
                obs=repmat(temp_out_vali,1,n);
                bias=temp_predict-obs; % error
                e2=1./std(bias,0,1).^2;   % error variance
                weight=e2./sum(e2);
                output=sum(repmat(weight,m,1).*temp_predict,2);
                
                [m1,n1]=size(temp_predict01);
                output01=sum(repmat(weight,m1,1).*temp_predict01,2);
                
                Prediction_sub_test01_vali_new=[Prediction_sub_test01_vali_new;output];
                Prediction_sub_test02_vali_new=[Prediction_sub_test02_vali_new;output01];
            elseif Ensemble_method==3 %nuging method
                
                % optimization
                [ Optimaized_value ] = nudging_Integration_calibration( temp_predict, temp_out_vali);
                
                [R2, RMSE, NSE, output ] = nudging_Integration (temp_predict, temp_out_vali, Optimaized_value );
                [R2, RMSE, NSE, output01 ] = nudging_Integration (temp_predict01, temp_out_vali01, Optimaized_value );
                
                Prediction_sub_test01_vali_new=[Prediction_sub_test01_vali_new;output];
                Prediction_sub_test02_vali_new=[Prediction_sub_test02_vali_new;output01];
                
            elseif  Ensemble_method==4 % Outlier average
                
                [m, n]=size(temp_predict);
                obs=repmat(temp_out_vali,1,n);
                
                RMSE=sum(power(temp_predict-obs,2),1)/m; % error
                
                id=RMSE<max(RMSE);
                id_repmat=repmat(id,m,1);
                output=mean(id_repmat.*temp_predict,2)*n/(n-1);
                
                [m1,n1]=size(temp_predict01);
                id_repmat=repmat(id,m1,1);
                output01=mean(id_repmat.*temp_predict01,2)*n1/(n1-1);
                
                Prediction_sub_test01_vali_new=[Prediction_sub_test01_vali_new;output];
                Prediction_sub_test02_vali_new=[Prediction_sub_test02_vali_new;output01];
                
            elseif  Ensemble_method==5 % Outlier average
                
                leaf=5;
                ntrees=30;
                fboot=1;
                surrogate='off';
                paroptions = statset('UseParallel',true);
                b = TreeBagger(...
                    ntrees,...
                    temp_predict,temp_out_vali,...
                    'Method','regression',... %classification or regression
                    'oobvarimp','on',...
                    'surrogate',surrogate,...
                    'minleaf',leaf,...
                    'FBoot',fboot,...
                    'Options',paroptions...
                    );
                
                output=predict(b, temp_predict);
                output01=predict(b, temp_predict01);
                
                Prediction_sub_test01_vali_new=[Prediction_sub_test01_vali_new;output];
                Prediction_sub_test02_vali_new=[Prediction_sub_test02_vali_new;output01];
                
            elseif  Ensemble_method==6 % regress average
                [m, n]=size(temp_predict);
                regress_para=regress(temp_out_vali,[temp_predict,ones(m,1)]);
                regress_para_all=repmat(regress_para',m,1);
                %                  output=sum(regress_para_all.*temp_predict,2);
                output=sum(regress_para_all.*[temp_predict,ones(m,1)],2);
                
                [m1,n1]=size(temp_predict01);
                regress_para_all=repmat(regress_para',m1,1);
                %                   output01=sum(regress_para_all.*temp_predict01,2);
                output01=sum(regress_para_all.*[temp_predict01,ones(m1,1)],2);
                
                Prediction_sub_test01_vali_new=[Prediction_sub_test01_vali_new;output];
                Prediction_sub_test02_vali_new=[Prediction_sub_test02_vali_new;output01];
                
            elseif Ensemble_method==7 % BMA
                method = 'GRA';
                
                %                 options.PDF = 'normal';      % gamma distribution
                %                 options.VAR = '2';          % individual non-constant variance
                %                 options.alpha = 0.95;       % prediction intervals of BMA model (0.90/0.95/0.99)
                options.print = 'No';      % print output (figures, tables) to screen
                %                 [ beta , ouput_structure ] = MODELAVG ( method , temp_predict , temp_out_vali , options );
                options.p=[2,2,2];
                [ beta ] = MODELAVG ( method , temp_predict , temp_out_vali,options );
                
                [m, n]=size(temp_predict);
                output=sum(repmat(beta,m,1).*temp_predict,2);
                
                [m1, n1]=size(temp_predict01);
                output01=sum(repmat(beta,m1,1).*temp_predict01,2);
                
                Prediction_sub_test01_vali_new=[Prediction_sub_test01_vali_new;output];
                Prediction_sub_test02_vali_new=[Prediction_sub_test02_vali_new;output01];
            end
            
            current_day_vali=current_day_vali+1*length(validation_subset01);
          current_day_vali01=current_day_vali01+1*length(validation_subset02);
     
        end
        
        
    end
end
end


