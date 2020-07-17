function net_best = ANN_optimization( hiddenSizes, radon_run,temp_in, temp_out_regression )
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
                           
                            net=fitnet(hiddenSizes(ii),'trainlm');
                            net.divideParam.trainRatio=0.6;
                            net.divideParam.valRatio=0.2;
                            net.divideParam.testRatio=0.2;
                           net.trainParam.showWindow=false;  %关闭nntraintool窗口
                           
                           % 采用tansig是因为降水不能小于0
                            net.layers{2}.transferFcn='tansig';
                            [net,trc] = train(net,temp_in',temp_out_regression');%,'UseParallel','yes');
                            
                            % prediciton
                            y_temp_ = net(temp_in');%,'UseParallel','yes');
                            perf = perform(net,temp_out_regression',y_temp_);
                         
%                             perf= perftrc.best_vperf;
                             
                            net_all{ii,kk}=net;
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

