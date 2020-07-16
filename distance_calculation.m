% calculate the distance from one point to all the points
% A, B,C: A->A; A->B; A->C; B->A; B->B; B->C; C->A; C->B; C->C


function Distance = distance_calculation(topography_fold,mete_station_name )

mete_infor=xlsread([topography_fold,mete_station_name]);
Distance=zeros(length(mete_infor),length(mete_infor));


distance_temp=zeros(1,length(mete_infor));
for i=1:length(mete_infor)
    current_station=mete_infor(i,[3,2]);
    for kk=1:length(mete_infor)
        estimate_sation=mete_infor(kk,[3,2]);
        distance_temp(kk)=SphereDist2(current_station,estimate_sation);
    end
    Distance(:,i)=distance_temp';
end


save([topography_fold,'Distance.mat'],'Distance');

end
