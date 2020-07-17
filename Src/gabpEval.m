function [ result ] = gabpEval(Y,X, x,v )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

options = ['-v ',num2str(v),' -c ', num2str(2^x(1)), ' -g ', num2str(2^x(2)) , ' -s 3 -p 0.1 -q'];
        result = svmtrain(Y,X,options);

end

