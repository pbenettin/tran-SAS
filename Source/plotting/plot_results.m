% script to plot the results of a model single-run. This script is 
% standalone but it can be automatically called at the end of the model
% starter if any plot_flag is set to 1

disp('plotting results...')

%--------------------------------------------------------------------------
% load the data
%--------------------------------------------------------------------------
% reload the results if not already done in the model starter
if ~exist('C_Q','var')
    
    % edit here if you want to modify the selected output file or the plot flags
    case_study = fscanf(fopen(fullfile('..','..','case_study_name.txt')),'%s');
    load(fullfile('..','..','case_studies',case_study,'results','all_output')) %loading the default output file 'all_output'
    flag_plot.Cout = 1;    %main plot with the full concentration timeseries
    flag_plot.TTDs = 1;    %plot TTDs for selected days
    flag_plot.agestats = 1;      %plot with additional age timeseries
end


% some useful stuff:
% - check if spinup is to be shown or not 
% data.show_spinup = 0; 
if data.show_spinup==0
    t_1=data.dates(1)+data.ini_shift*data.dt/24; %avoid showing the spinup
    C_Q(1:data.ini_shift) = NaN; %discard results during spinup
    Fyw(1:data.ini_shift,:) = NaN; %discard results during spinup
    med(1:data.ini_shift,:) = NaN; %discard results during spinup
else
    t_1=data.dates(1);
end
t_2=data.dates(end);

%--------------------------------------------------------------------------
% CALL THE FIGURE SCRIPTS
%--------------------------------------------------------------------------

% FIGURE: SHOW OUTPUT C_Q
if flag_plot.Cout==1
    run('plot_Cout.m')
end

% FIGURE: SHOW THE SELECTED TTDs
if flag_plot.TTDs==1 && ~isempty(data.index_datesel)==1
    run('plot_TTDs.m') 
end
    
% FIGURE: ADDITIONAL AGE STATISTICS
if flag_plot.agestats==1
    run('plot_agestats.m')  
end

%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%  END OF FILE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%