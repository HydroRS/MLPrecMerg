function [ Performance,y,y_vali,y_vali01 ] = SVM_train( start_day,end_day,...
            train_period,In,Out,Out_regression,In_vali,Out_vali,In_vali01,Out_vali01,train_data,...
            validation_data,validation_data01,pcp_threshold,c_range,grange,v)
           
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

Performance=[];
switch train_period
    
%     % ===============================================
%     case 1
%         current_day=0;
%         current_day_vali=0;
%         y=[];
%         y_vali=[];
%         Weights=[];
%         for year = start_day(1):end_day(1)
%             disp( num2str(year))
%             
%             temp_in=In((current_day+1):current_day+yeardays(year)*length(train_data),:);
%             temp_in_vali=In_vali((current_day_vali+1):current_day_vali+yeardays(year)*length(validation_data),:);
%             
%             temp_out=Out((current_day+1):current_day+yeardays(year)*length(train_data),:);
%             
%             
%             b = TreeBagger(...
%                 ntrees,...
%                 temp_in,temp_out,...
%                 'Method','regression',...
%                 'oobvarimp','on',...
%                 'surrogate',surrogate,...
%                 'minleaf',leaf,...
%                 'FBoot',fboot,...
%                 'Options',paroptions...
%                 );
%             
%             % training
%             y_temp=predict(b, temp_in);
%             y=[y;y_temp];
%             
%             % vlidation
%             y_temp_vali=predict(b, temp_in_vali);
%             y_vali=[y_vali;y_temp_vali];
%             
%             current_day=current_day+yeardays(year)*length(train_data);
%             current_day_vali=current_day_vali+yeardays(year)*length(validation_data);
%             
%             weight=b.OOBPermutedVarDeltaError;
%             Weights=[Weights;weight];
%         end
        
        % ===============================================
    case 2
%         current_day=0;
%         current_day_vali=0;
%         y=[];
%         y_vali=[];
%         Weights=[];
%         for year = start_day(1):end_day(1)
%             % end month
%             if year==end_day(1)
%                 end_month=end_day(2);
%             else
%                 end_month=12;
%             end
%             
%             for month = 1:end_month
%                 disp( [num2str(year),'-',num2str(month)])
%                 
%                 temp_in=In(current_day+1:current_day+eomday(year, month)*length(train_data),:);
%                 temp_out=Out(current_day+1:current_day+eomday(year, month)*length(train_data),:);
%                   temp_out_regression=Out_regression(current_day+1:current_day+eomday(year, month)*length(train_data),:); 
%                   
%                     temp_out_vali=Out_vali(current_day_vali+1:current_day_vali+eomday(year, month)*length(validation_data),:);
%                 temp_in_vali=In_vali(current_day_vali+1:current_day_vali+eomday(year, month)*length(validation_data),:);
%                 
%                       % normilization
%                     [temp_in,PS01]=mapminmax(temp_in',0,1);
%                     temp_in=temp_in';
%                     [temp_out_regression,PS02]=mapminmax(temp_out_regression',-1,1);
%                     temp_out_regression=temp_out_regression';
%                     
%                     % apply normilization to test data
%                     temp_in_vali= mapminmax('apply',temp_in_vali',PS01);
%                     temp_in_vali=temp_in_vali';
%                      temp_out_vali= mapminmax('apply',temp_out_vali',PS02);
%                      temp_out_vali=temp_out_vali';
%                     
%                      % paramter optimatiztion
% %                       c_range=-8:1:8;
% %                       grange=-8:1:8;
% %                       v=3;
% %                     [ bestc,bestg] = SVM_optimization( temp_out_regression,temp_in,c_range,grange,v );
% %                %      bestc=-1;bestg=1;
% %                     options = ['-c ', num2str(power(2,bestc)), ' -g ', num2str(2,bestg) , ' -s 3 -p 0.1 -q'];
%                           options = [' -t 0' , ' -s 3 -e 0.0001 -q'];
%                        model = svmtrain(temp_out_regression,temp_in,options);
%                        
%                       y_temp_ = svmpredict(temp_out_regression,temp_in,model);
%                       y_temp_vali_ = svmpredict(temp_out_vali,temp_in_vali,model);
%                       
%                         % 反归一化
%                      y_temp_=mapminmax('reverse',y_temp_,PS02);
%                       y_temp_vali_=mapminmax('reverse',y_temp_vali_,PS02);
%                       
%                 % training
%                
%                 y=[y;y_temp_];
%                 
%                 % vlidation
%              
%             y_vali=[y_vali;y_temp_vali_];
%             
%             current_day=current_day+eomday(year, month)*length(train_data);
%             current_day_vali=current_day_vali+eomday(year, month)*length(validation_data);
%                 
% %                 weight=b.OOBPermutedVarDeltaError;
% %                 Weights=[Weights;weight];
% %             
%                 
%             end
%             
%         end
        
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
                    temp_out=Out(current_day+1:(current_day+length(train_data)*1),:); % class (降水与否）
                    
                   temp_out_regression=Out_regression(current_day+1:(current_day+length(train_data)*1),:); 
                    
                    temp_in_vali=In_vali(current_day_vali+1:(current_day_vali+length(validation_data)*1),:); % daily
                    temp_out_vali=Out_vali(current_day_vali+1:(current_day_vali+length(validation_data)*1),:);
					
					  temp_in_vali01=In_vali01(current_day_vali01+1:(current_day_vali01+length(validation_data01)*1),:); % daily
					  temp_out_vali01=Out_vali01(current_day_vali01+1:(current_day_vali01+length(validation_data01)*1),:);

                    % SVM  
                   
                    % normilization
                    [temp_in,PS01]=mapminmax(temp_in',-1,1);
                    temp_in=temp_in';
                    [temp_out_regression,PS02]=mapminmax(temp_out_regression',-1,1);
                    temp_out_regression=temp_out_regression';
                    
                    % apply normilization to test data
                    temp_in_vali= mapminmax('apply',temp_in_vali',PS01);
                    temp_in_vali=temp_in_vali';
                     temp_out_vali= mapminmax('apply',temp_out_vali',PS02);
                     temp_out_vali=temp_out_vali';
					 
					 temp_in_vali01= mapminmax('apply',temp_in_vali01',PS01);
                    temp_in_vali01=temp_in_vali01';
                     temp_out_vali01= mapminmax('apply',temp_out_vali01',PS02);
                     temp_out_vali01=temp_out_vali01';
                    
                     % paramter optimatiztion
%                       c_range=-8:1:8;
%                       grange=-8:1:8;
%                       v=3;
  % output的数据不能完全一致
                     if  all (~(diff(temp_out_regression)))
                         temp_out_regression(1)=0.5; 
                     end
                    [ bestc,bestg] = SVM_optimization( temp_out_regression,temp_in,c_range,grange,v );
                    clc;
					
               
                    
                  
% options1 = optimset('outputfcn',@outfun,'display','iter',...
% 'Algorithm','active-set','UseParallel', true);
% options.TolFun=2;
%  options= gaoptimset('Generations',16);
%  [x,FVAL,EXITFLAG,OUTPUT] = ga(@(x) gabpEval(temp_out_regression,temp_in, x,v ),2,[],[],[],[],[],[],[],options1 );          
 
%                      
                       options = ['-c ', num2str(power(2,bestc)), ' -g ', num2str(power(2,bestg)) , ' -s 3 -p 0.1 -q'];
                  
                     %   options = ['-t 1 -g 0.071' , ' -s 3 -e 0.0001 -q'];
                       model = svmtrain(temp_out_regression,temp_in,options);
                       
                      y_temp_ = svmpredict(temp_out_regression,temp_in,model);
                      y_temp_vali_ = svmpredict(temp_out_vali,temp_in_vali,model);
					  y_temp_vali_01 = svmpredict(temp_out_vali01,temp_in_vali01,model);
                      
                        % 反归一化
                     y_temp_=mapminmax('reverse',y_temp_,PS02);
                      y_temp_vali_=mapminmax('reverse',y_temp_vali_,PS02);
					  y_temp_vali_01=mapminmax('reverse',y_temp_vali_01,PS02);
                     
                      
                      % combing results
                      y=[y;y_temp_];
                     y_vali=[y_vali;y_temp_vali_];
					  y_vali01=[y_vali01;y_temp_vali_01];

%                    y_temp_ = net_best(temp_in');%,'UseParallel','yes'); 
%                     y=[y;y_temp_'];
    
                    % validation
%                     y_temp_vali_=net_best(temp_in_vali');%,'UseParallel','yes');
% 
%                     y_temp_vali_=mean(y_temp_vali_all,2);
                    % combining
%                      y_vali=[y_vali;y_temp_vali_'];
                    
                     
                    current_day=current_day+1*length(train_data);
                    current_day_vali=current_day_vali+1*length(validation_data);
					current_day_vali01=current_day_vali01+1*length(validation_data01);
                end
            end
            
        end
      
        y(y<0)=0;
         y_vali(y_vali<0)=0;
          y_vali01(y_vali01<0)=0;
end

% if subregion_RF==0
[ Performance01 ] = performance_evaluation(Out_regression,In,y, Out_vali,In_vali,y_vali,pcp_threshold);
[ Performance02 ] = performance_evaluation(Out_regression,In,y, Out_vali01,In_vali01,y_vali01,pcp_threshold);
Performance=[Performance01,Performance02];
% else
%     Performance=0;
% end
         
% save('y.mat','y','-v7.3');
% save('y_vali.mat','y_vali','-v7.3');
end

