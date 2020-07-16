function [ paroptions ] = Parellel_set( )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

ngpus=gpuDeviceCount;
disp([num2str(ngpus) ' GPUs found'])
if ngpus>0
    lgpu=1;
    disp('GPU found')
    useGPU='yes';
else
    lgpu=0;
    disp('No GPU found')
    useGPU='no';
end

% Find number of cores
ncores=feature('numCores');
disp([num2str(ncores) ' cores found'])

% Find number of cpus
import java.lang.*;
r=Runtime.getRuntime;
ncpus=r.availableProcessors;
disp([num2str(ncpus) ' cpus found'])

if ncpus>1
    useParallel='yes';
else
    useParallel='no';
end

[archstr,maxsize,endian]=computer;
disp([...
    'This is a ' archstr ...
    ' computer that can have up to ' num2str(maxsize) ...
    ' elements in a matlab array and uses ' endian ...
    ' byte ordering.'...
    ])

%% Set up the size of the parallel pool if necessary
npool=ncores;

% Opening parallel pool
if ncpus>1
    tic
    disp('Opening parallel pool')
    
    % first check if there is a current pool
    poolobj=gcp('nocreate');
    
    % If there is no pool create one
    if isempty(poolobj)
        command=['parpool(' num2str(npool) ');'];
        disp(command);
        eval(command);
    else
        poolsize=poolobj.NumWorkers;
        disp(['A pool of ' poolsize ' workers already exists.'])
    end
    
    % Set parallel options
    paroptions = statset('UseParallel',true);
    toc
    
end

end

