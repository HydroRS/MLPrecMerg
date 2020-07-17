function net_best = ELM_optimization( hiddenSizes, radon_run, temp_in, temp_out_regression )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%       radon_run=3;
%                     hiddenSizes=[5,10,15];
                    performance=zeros(length(hiddenSizes),radon_run);
                    net_all=cell(length(hiddenSizes),radon_run);
                    for ii=1:length(hiddenSizes)
                        % Initial
                        hiddenSizes(ii) ;         
                        parfor kk=1:radon_run
                           
                            % 70% train, 30% validation
                            train_length=fix(length(temp_out_regression)*0.60);
                         
                            
                            model = elm_train_base(temp_out_regression(1:train_length,:),temp_in(1:train_length,:),0,hiddenSizes(ii),'sig');
                            
                              y_temp_velidation = elm_predict(temp_in(train_length:end,:),model);
                              
                              observe=temp_out_regression(train_length:end,:);
                              
                               perf=sqrt(mse(observe - y_temp_velidation'));
                         
%                             perf= perftrc.best_vperf;
                             
                            net_all{ii,kk}=model;
                            performance(ii,kk)=perf;
                            
                        end
                    end
                    

                   % ensemble the most best 10 nets
                   temp_performance=sort(reshape(performance,1,length(hiddenSizes)*radon_run));     
                    [m,n]=find(performance<=temp_performance(10),10);
                    index=[m,n];
                    net_best=cell(length(index),1);
                    for jj=1:length(index)
                        net_best{jj}=net_all{index(jj,1),index(jj,2)};
                    end
                    
%                     [best_row,best_col]=find(performance==min(min(performance)));
%                     net_best=net_all{best_row,best_col};
%                     net.IW{1,1}=net_best.IW{1,1};
%                     net.b{1}= net_best.b{1};
%                     net.LW{2,1}= net_best.LW{2,1};
%                     net.b{2}=net_best.b{2};
%                     net= train(net,temp_in',temp_out_regression','UseParallel','yes');
                    
%                       y_temp_ = net(temp_in','UseParallel','yes');
%                       perf = perform(net,temp_out_regression',y_temp_');

end

