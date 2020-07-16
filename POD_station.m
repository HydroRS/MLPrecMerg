function POD= POD_station(X, Y, threshold)
% X is the evaluated value
% Y is the observations  [ POD, FAR, CSI ]

temp_X=X(Y>threshold);
id_detected_X=find(temp_X>threshold);
POD=length(id_detected_X)/length(temp_X);


temp_Y=Y(X>threshold);
id_detected_Y=find(temp_Y<=threshold);
FAR=length(id_detected_Y)/length(temp_Y);

CSI=length(id_detected_X)/(length(temp_X)+length(id_detected_Y));


end

