function [ output ] = One_outlier_mean( input )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[m,n]=size(input);
temp=mean(input,2);
temp= repmat(temp,1,n);

diff=input-temp;
max_diff=max(abs(diff)')';
max_diff=repmat(max_diff,1,n);

id=abs(diff)<max_diff;


output=mean(id.*input,2)*n/(n-1);
end

