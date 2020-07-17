function  D2 = DISTFUN(ZI, ZJ)
    D2=zeros(length(ZJ),1);
    for mm=1:length(ZJ)
         D2(mm)=SphereDist2(ZI,ZJ(mm,:));
    end
    
    
end

