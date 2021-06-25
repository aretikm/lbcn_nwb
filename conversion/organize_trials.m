function [organized_trials] = organize_trials(sbj_name, fsample, block_name, dirs, ext_name, data)
%ORGANIZED_TRIALS trial info
%   returns TimeIntervals type with trial information from specific block
%
%   INPUT: 
%       sbj_name: subject name
%       fsample: sampling rate
%       block_name: block to be analyzed
%       dirs: directories pointing to files of interest (generated by InitializeDirs)
%       ext_name: extended version of sbj_name (used for accessing correct
%                 folders/files)
%
%   Laboratory of Behavioral and Cognitive Neuroscience, Stanford University
%   Authors: Pedro Pinheiro-Chagas, Areti Majumdar
%   Copyright: MIT License 2021  


%% load files
% file and folder names need to be deidentified
sbj_file = [dirs.psych_root filesep ext_name{1} filesep block_name{1} filesep 'trialinfo_' block_name{1} '.mat'];
load(sbj_file)

%% create trials object and initialize column names
organized_trials = types.core.TimeIntervals();

% colnames shouldn't include start & stop time, these are part of the
% object itself
variables = trialinfo.Properties.VariableNames;
organized_trials.colnames = variables;

%% find start and stop times

% add start & stop time to trialinfo table
trialinfo.start_time = (trialinfo.allonsets * fsample); %dont hardcode

%iterate through each row of trialinfo to check stoptimes
for curr_row = 1:height(trialinfo)
    if trialinfo.condNames{curr_row} == "rest"
        RT = (trialinfo.start_time(curr_row+1) - trialinfo.stop_time(curr_row-1))/fsample -1; % to avoid cloggin while we find the precise duration of rest trials
    elseif trialinfo.RT(curr_row) == 0
        RT = 15;
    else
        RT = trialinfo.RT(curr_row);
    end
    
    trialinfo.stop_time(curr_row) = (trialinfo.allonsets(curr_row) + RT) * fsample;
end

%% Correct non strings in keys 
for i = 1:size(trialinfo,1)
   if isempty(trialinfo.keys{i})
       trialinfo.keys{i} = 'noanswer';
   else
   end
end

%% create trials from trialinfo

descrip = append(sbj_name, ' block: ', block_name); %general description
organized_trials.description = descrip;

organized_trials.id = types.hdmf_common.ElementIdentifiers('data', 0:height(trialinfo));


%redefine variables to include start & stop time to iterate through entire
%   trialinfo table
variables = trialinfo.Properties.VariableNames;
variable_descriptions = trialinfo.Properties.VariableNames;

% iterate through trialinfo and add data
for i = 1:length(variables)
    if strcmp(sbj_name, 'S12_38') == 1 && strcmp(variables{i}, 'keys') == 1
        trialinfo.keys{8} = '2';
    end
    if strcmp(sbj_name, 'S12_41') == 1 && strcmp(variables{i}, 'keys') == 1
        trialinfo.keys{144} = '1';
    end
    
    
    if variables{i} == "start_time"
        organized_trials.start_time = types.hdmf_common.VectorData('data', trialinfo.start_time, 'description', variable_descriptions{i});
    elseif variables{i} == "stop_time"
        organized_trials.stop_time = types.hdmf_common.VectorData('data', trialinfo.stop_time, 'description', variable_descriptions{i});
    else
        curr_col = variables{i};
        if iscell(trialinfo.(variables{i})) == 1
            organized_trials.vectordata.set(curr_col, types.hdmf_common.VectorData('data', char(trialinfo.(variables{i})), 'description', variable_descriptions{i}));
        else
            organized_trials.vectordata.set(curr_col, types.hdmf_common.VectorData('data', trialinfo.(variables{i}), 'description', variable_descriptions{i}));
        end
        
    end
end

organized_trials.colnames{end + 1} = 'Pdio';
organized_trials.vectordata.set('Pdio', types.hdmf_common.VectorData('data', data.pdio, 'description', 'photodiode channel'));