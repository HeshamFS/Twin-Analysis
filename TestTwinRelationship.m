function [group,typeout] = TestTwinRelationship(mori,tol,twins);
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
    %Assume not twin and not to be grouped unless proven to be a twin type
    typeout=zeros(length(mori),1,'int8'); %non-zero describes twin type
    group=zeros(length(mori),1,'logical');
    for i=1:length(twins)
        grouptmp=(angle(mori,twins{i})' < tol)';
        typeout(grouptmp)=i; 
        group=logical(grouptmp+group);        
    end
    
end


