function [electrode_table, tbl] = get_electrodes(dirs, ext_name, cfg, block_name)
%GET_ELECTRODES creates electrode table
%   creates table of electrodes that generated data. Returns both table of
%   electrode info (tbl) for visualization purposes and dynamic table of 
%   same information and categories for nwb file
%
%   INPUT:
%       dirs: directories pointing to files of interest (generated by InitializeDirs)
%       ext_name: extended version of sbj_name (used for accessing correct
%                 folders/files)
%
%   Laboratory of Behavioral and Cognitive Neuroscience, Stanford University
%   Authors: Pedro Pinheiro-Chagas, Areti Majumdar
%   Copyright: MIT License 2021  


 subj_file = [dirs.original_data filesep ext_name{1} filesep 'subjVar_' ext_name{1} '.mat'];
 load(subj_file);
 
 glob_file = [cfg.dirs.original_data filesep ext_name{1} filesep 'global_MMR_' ext_name{1} '_' block_name{1} '.mat'];
load(glob_file);

% add to variables as you add more info
variables = {'x_fsaverage', 'y_fsaverage', 'z_fsaverage', 'x_subject', 'y_subject', 'z_subject', 'LvsR', 'imp', 'location',  'filtering', 'label'};
tbl = cell2table(cell(0, length(variables)), 'VariableNames', variables);

% iterate through subjVar for electrode info 
for ielec = 1:height(subjVar.elinfo)
    x_fsaverage = subjVar.elinfo.MNI_coord(ielec,1,1);
    y_fsaverage = subjVar.elinfo.MNI_coord(ielec,2,1);
    z_fsaverage = subjVar.elinfo.MNI_coord(ielec,3,1);
    
    x_subject = subjVar.elinfo.LEPTO_coord(ielec,1,1);
    y_subject = subjVar.elinfo.LEPTO_coord(ielec,2,1);
    z_subject = subjVar.elinfo.LEPTO_coord(ielec,3,1);
    
    
    imp = 'NaN';
    location = subjVar.elinfo.DK_long_josef{ielec,1};
    filtering = 'common average';
    LvsR = subjVar.elinfo.LvsR{ielec};
    label = subjVar.elinfo.FS_label{ielec};
    
    tbl = [tbl; {x_fsaverage, y_fsaverage, z_fsaverage, x_subject, y_subject, z_subject, LvsR, imp, location,  filtering, label}];
end

%adds photodiode channel
%tbl = [tbl; [repmat({NaN},9,1); repmat({'Pdio'},1,1)]']; makes nwb file
%not save

tbl = [tbl; {NaN, NaN, NaN, NaN, NaN, NaN, 'NaN', 'NaN', 'NaN', 'NaN', 'Pdio'}];

%add noisy channels
 noisy_channel = ismember((1:height(subjVar.elinfo)), globalVar.badChan)';
 tbl.noisy_channels = [double(noisy_channel); NaN];
 %tbl.noisy_channels = double(noisy_channel);

electrode_table = util.table2nwb(tbl, 'all electrodes');