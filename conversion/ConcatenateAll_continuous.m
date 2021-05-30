function data_all = ConcatenateAll_continuous(sbj_name, project_name, block_names, dirs, elecs, datatype, freq_band, ext_name)
%CONCATENATEALL_CONTINUOUS  concatenate eeg data across electrodes
%   function concatenates eeg data from all electrodes and returns a struct 
%   containing the concatenated eeg data and sampling rate. 
%   
%   INPUTS:
%       sbj_name: subject name
%       project_name: project name (eg. 'MMR')
%       block_names: block to be analyed (string)
%       dirs: directories pointing to files of interest (generated by InitializeDirs)
%       elecs: electrode number
%       datatype: 'CAR','HFB',or 'Spec'
%       freq_band: frequency band
%       ext_name: extended version of sbj_name (used for accessing correct
%                 folders/files)
%   
%   Laboratory of Behavioral and Cognitive Neuroscience, Stanford University
%   Authors: Pedro Pinheiro-Chagas, Areti Majumdar
%   Copyright: MIT License 2021   

%% Define electrodes
load([dirs.original_data filesep ext_name{1} filesep 'subjVar_' ext_name{1} '.mat'])
if isempty(elecs)
    elecs = 1:size(subjVar.elinfo,1);
end

if ~isfield(subjVar, 'elinfo')
    data_format = GetFSdataFormat(sbj_name, 'Stanford');
    subjVar = CreateSubjVar(sbj_name, dirs, data_format);
else
end

%% loop through electrodes
concatfields = {'wave'}; % type of data to concatenate
for ei = 1:length(elecs)
    el = elecs(ei);
    
    data_bn = concatBlocks_continuous(sbj_name,block_names,dirs,el,freq_band,datatype,concatfields, ext_name);
    elecnans(ei) = sum(sum(isnan(data_bn.wave)));
    
    % Concatenate all subjects all trials
    data_all.wave(ei,:) = data_bn.wave;
    data_all.fsample = data_bn.fsample;
end

end
