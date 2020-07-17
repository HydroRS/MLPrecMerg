function [ bestc,bestg ] = SVM_optimization( Y,X,c_range,grange,v )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
if nargin < 5
    v=3;
end
    

results_all=zeros(length(c_range),length(grange));
for log2c =1:length(c_range)
    parfor log2g =1:length(grange)
        % -v 交叉验证参数：在训练的时候需要，测试的时候不需要，否则出错
        options = ['-v ',num2str(v),' -c ', num2str(2^c_range(log2c)), ' -g ', num2str(2^grange(log2g)) , ' -s 3 -p 0.1 -q'];
        result = svmtrain(Y,X,options);
        results_all(log2c,log2g)=result;
    end
end

[id_best01,id_best02]=find(results_all==min(min(results_all)));

bestc=c_range(id_best01);
bestg=grange(id_best02);

bestc_range=(bestc-2):0.2:(bestc+2);
bestg_range=(bestg-2):0.2:(bestg+2);
results_all=zeros(length(bestc_range),length(bestg_range));
for log2c =1:length(bestc_range)
    parfor log2g =1:length(bestg_range)
        % -v 交叉验证参数：在训练的时候需要，测试的时候不需要，否则出错
        options = ['-v ',num2str(v),' -c ', num2str(2^bestc_range(log2c)), ' -g ', num2str(2^bestg_range(log2g)) , ' -s 3 -p 0.1 -q'];
        result = svmtrain(Y,X,options);
        results_all(log2c,log2g)=result;
    end
end

[id_best01,id_best02]=find(results_all==min(min(results_all)));

bestc=bestc_range(id_best01);
bestg=bestg_range(id_best02);
        
end

