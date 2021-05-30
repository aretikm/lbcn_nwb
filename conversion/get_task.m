function [task, general_keywords, session_start] = get_task(sbj_name)
%GET_TASK   task information
%   [T, G, St] = GET_TASK(S) is the task name, keywords and session start
%   data (or date of acquisition) that subject S completed. Information 
%   taken from google spreadsheet. 
%
%   INPUTS:
%       sbj_name: subject name
%
%   Laboratory of Behavioral and Cognitive Neuroscience, Stanford University
%   Authors: Pedro Pinheiro-Chagas, Areti Majumdar
%   Copyright: MIT License 2021   


% Load sheet
[DOCID,GID] = getGoogleSheetInfo_nwb('nwb_meta_data', 'cohort');
sheet = GetGoogleSpreadsheet(DOCID, GID);

task = sheet.task{strcmp(sheet.subject_name, sbj_name)};
general_keywords = sheet.general_keywords{strcmp(sheet.subject_name, sbj_name)};

% date stored in month/day/year format
% deidentified date of acquisition
session_start = datetime(1900, 1, 1);

end

