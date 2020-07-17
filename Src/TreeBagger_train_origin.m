function [ Performance,y,y_vali,y_vali01,Weights ] = TreeBagger_train_origin( start_day,end_day,...
            train_period,In,Out,Out_regression, In_vali,Out_vali, In_vali01,Out_vali01,...
            leaf,ntrees, fboot,surrogate,paroptions,train_data,validation_data,validation_data01,pcp_threshold,subregion_RF)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

Performance=[];
switch train_period
    
    % ===============================================
    case 1
        current_day=0;
        current_day_vali=0;
        y=[];
        y_vali=[];
        Weights=[];
        for year = start_day(1):end_day(1)
            disp( num2str(year))
            
            temp_in=In((current_day+1):current_day+yeardays(year)*length(train_data),:);
            temp_in_vali=In_vali((current_day_vali+1):current_day_vali+yeardays(year)*length(validation_data),:);
            
            temp_out=Out((current_day+1):current_day+yeardays(year)*length(train_data),:);
            
            
            b = TreeBagger(...
                ntrees,...
                temp_in,temp_out,...
                'Method','regression',...
                'oobvarimp','on',...
                'surrogate',surrogate,...
                'minleaf',leaf,...
                'FBoot',fboot,...
                'Options',paroptions...
                );
            
            % training
            y_temp=predict(b, temp_in);
            y=[y;y_temp];
            
            % vlidation
            y_temp_vali=predict(b, temp_in_vali);
            y_vali=[y_vali;y_temp_vali];
            
            current_day=current_day+yeardays(year)*length(train_data);
            current_day_vali=current_day_vali+yeardays(year)*length(validation_data);
            
            weight=b.OOBPermutedVarDeltaError;
            Weights=[Weights;weight];
        end
        
        % ===============================================
    case 2
        current_day=0;
        current_day_vali=0;
        y=[];
        y_vali=[];
        Weights=[];
        for year = start_day(1):end_day(1)
            % end month
            if year==end_day(1)
                end_month=end_day(2);
            else
                end_month=12;
            end
            
            for month = 1:end_month
                disp( [num2str(year),'-',num2str(month)])
                
                temp_in=In(current_day+1:current_day+eomday(year, month)*length(train_data),:);
                temp_out=Out(current_day+1:current_day+eomday(year, month)*length(train_data),:);
                
                temp_in_vali=In_vali(current_day_vali+1:current_day_vali+eomday(year, month)*length(validation_data),:);
             
                
              % first classification
                b = TreeBagger(...
                    ntrees,...
                    temp_in,temp_out,...
                    'Method','regression',... %classification or regression
                    'oobvarimp','on',...
                    'surrogate',surrogate,...
                    'minleaf',leaf,...
                    'FBoot',fboot,...
                    'Options',paroptions...
                    );
                % training
                y_temp=predict(b, temp_in);
                y=[y;y_temp];
                
                % vlidation
                y_temp_vali=predict(b, temp_in_vali);
            y_vali=[y_vali;y_temp_vali];
            
            
            current_day=current_day+eomday(year, month)*length(train_data);
            current_day_vali=current_day_vali+eomday(year, month)*length(validation_data);
                
                weight=b.OOBPermutedVarDeltaError;
                Weights=[Weights;weight];
            
                
            end
            
        end
        
        % ===============================================
    case 3
        current_day=0;
        current_day_vali=0;
        current_day_vali01=0;
        y=[];
        y_vali=[];
        y_vali01=[];
        Weights=[];
        
        
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
                    temp_in=In(current_day+1:(current_day+length(train_data)*1),:); % daily
                    temp_out=Out(current_day+1:(current_day+length(train_data)*1),:);
                    
                   temp_out_regression=Out_regression(current_day+1:(current_day+length(train_data)*1),:);
                    
                    temp_in_vali=In_vali(current_day_vali+1:(current_day_vali+length(validation_data)*1),:); % daily
                    temp_in_vali01=In_vali01(current_day_vali01+1:(current_day_vali01+length(validation_data01)*1),:); % daily

                    %---------------------------
                    % 2:regression second
                    
                      c = TreeBagger(...
                        ntrees,...
                        temp_in,temp_out_regression,...
                        'Method','regression',...%classification or regression
                        'oobvarimp','on',...
                        'surrogate',surrogate,...
                        'minleaf',leaf,...
                        'FBoot',fboot,...
                        'Options',paroptions...
                        );
                         % trainin
                    y_temp_=predict(c, temp_in);
                    y=[y;y_temp_];
                    
                   
%                     c=  fitensemble(temp_in,temp_out_regression,'LSBOOST',100,'Tree');
 
 

                     y_temp_vali_=predict(c, temp_in_vali); % regression
                      y_temp_vali_01=predict(c, temp_in_vali01); % regression
                     
                      

                    % combining
                     y_vali=[y_vali;y_temp_vali_];
                     y_vali01=[y_vali01;y_temp_vali_01];
                                         
                  weight=c.OOBPermutedVarDeltaError;
                Weights=[Weights;weight];
                     
                    current_day=current_day+1*length(train_data);
                    current_day_vali=current_day_vali+1*length(validation_data);
                     current_day_vali01=current_day_vali01+1*length(validation_data01);
                end
            end
            
        end
      
end

% if subregion_RF==0
[ Performance01 ] = performance_evaluation(Out_regression,In,y, Out_vali,In_vali,y_vali,pcp_threshold);
[ Performance02 ] = performance_evaluation(Out_regression,In,y, Out_vali01,In_vali01,y_vali01,pcp_threshold);
Performance=[Performance01,Performance02];
% else
%     Performance=0;
% end
%          
% save('y.mat','y','-v7.3');
% save('y_vali.mat','y_vali','-v7.3');
end

