function data_all = concatBlocks(sbj_name, project_name, block_names,dirs,el,freq_band,datatype,concatfields, ext_name)

% this function concatenates data (either spectral or single timecourse) across blocks for a single electrode
%% INPUTS:
%       sbj_name: subject name
%       block_names: blocks to be analyed (cell of strings)
%       dirs: directories pointing to files of interest (generated by InitializeDirs)
%       el: electrode number
%       datatype: 'CAR','HFB',or 'Spec'
%       concatfields: cell of field(s) in data to concatenate (e.g.
%                     'phase', 'wave') in addition to trialinfo
%       tag: tag in filename between data type and block name, specifying which type of data to load (e.g. 'stimlock_bl_corr')
%       concatParams.run_blc: true or false (whether to run baseline correction)
%                   .bl_win: time window (in sec) to use for baseline
%                   .power: true or false

%%

for i = 1:length(concatfields)
    data_all.(concatfields{i}) = [];
end

data_all.trialinfo = [];
for bi = 1:length(block_names)
    bn = block_names{bi};
    dir_in = [dirs.data_root,filesep,datatype,'Data',filesep,freq_band,filesep,ext_name{1},filesep,bn];
    load(sprintf('%s/%siEEG%s_%.2d.mat',dir_in,freq_band,bn,el))
    
    % concatenante EEG data across blocks
    for i = 1:length(concatfields)
            data_all.(concatfields{i}) = cat(1,data_all.(concatfields{i}),data.(concatfields{i}));
    end
end

% add all additional info back to concatenated data structure (e.g. channame, time, freq)
allfields = setdiff(fieldnames(data),{'wave'});
for fi = 1:length(allfields)
    data_all.(allfields{fi})=data.(allfields{fi});
end