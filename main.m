%% Predictive Simulations of Human Gait

% This script starts the predictive simulation of human movement. The
% required inputs are necessary to start the simulations. Optional inputs,
% if left empty, will be taken from getDefaultSettings.m.

clear
close all
clc
% path to the repository folder
[pathRepo,~,~] = fileparts(mfilename('fullpath'));
% path to the folder that contains the repository folder
[pathRepoFolder,~,~] = fileparts(pathRepo);

%% casadi path
% add casadi path
addpath(genpath())

%% Initialize S
addpath(fullfile(pathRepo,'DefaultSettings'))

[S] = initializeSettings('Falisse_et_al_2022');

%% Settings

% name of the subject
S.subject.name = 'Falisse_et_al_2022';

% path to folder where you want to store the results of the OCP
S.misc.save_folder  = fullfile(pathRepoFolder,'PredSimResults',S.subject.name); 

% either choose "quasi-random" or give the path to a .mot file you want to use as initial guess
% use default as first guess
S.solver.IG_selection = fullfile(S.misc.main_path,'OCP','IK_Guess_Full_GC.mot');
S.solver.IG_selection_gaitCyclePercent = 100;
% S.solver.IG_selection = 'quasi-random';

% give the path to the osim model of your subject
osim_path = fullfile(pathRepo,'Subjects',S.subject.name,[S.subject.name '.osim']);

%% Van Wouwe 2024 Kinematic Bounds
S.bounds.Qs = {'lumbar_extension',-20,20,'lumbar_rotation',-38.1,37.7,...
        'lumbar_bending',-25.5,30.4,'hip_flexion_l',-109.9,121.4,'hip_flexion_r',-109.9,121.4,...
        'hip_adduction_l',-36.6,41.2,'hip_adduction_r',-36.6,41.2,...
        'hip_rotation_l',-10,10,'hip_rotation_r',-10,10,...
        'knee_angle_r',-175,10, 'knee_angle_l',-175,10,...
        'ankle_angle_r',-81.2,77.6,'ankle_angle_l',-81.2,77.6,...
        'subtalar_angle_r',-90, 90,'subtalar_angle_l',-90, 90,...
        'mtp_angle_r',-90, 90,'mtp_angle_l',-90, 90,...
        'elbow_flex_l',0,115,'elbow_flex_r',0,115,...
        'arm_add_l',-42.6,5,'arm_add_r',-42.6,5,...
        'arm_rot_l',-13.2,19.4,'arm_rot_r',-13.2,19.4,...
        'arm_flex_l',-70,50,'arm_flex_r',-70,50,...
        'pelvis_tx',-0.5,10,'pelvis_tz',-0.5,0.5,'pelvis_ty',0.6,1.2,...
        'pelvis_rotation',-45,45,'pelvis_tilt',-45,15,'pelvis_list',-23.9,20.7};
S.bounds.Qdots={'pelvis_tilt',-1000,1000,'pelvis_list',-1000,1000,...
        'pelvis_rotation',-1000,1000,'pelvis_tx',-3,20,'pelvis_tz',-4,4,...
        'pelvis_ty',-4,4,'lumbar_extension',-1000,1000,...
        'lumbar_rotation',-1000,1000,'lumbar_bending',-1000,1000,...
        'hip_flexion_l',-2000,2000,'hip_flexion_r',-2000,2000,...
        'hip_adduction_l',-2000,2000,'hip_adduction_r',-2000,2000,...
        'hip_rotation_l',-2500,2500,'hip_rotation_r',-2500,2500,...
        'knee_angle_r',-2500,2500, 'knee_angle_l',-2500,2500,...
        'ankle_angle_r',-5000,5000,'ankle_angle_l',-5000,5000,...
        'subtalar_angle_r',-5000,5000,'subtalar_angle_l',-5000,5000,...
        'mtp_angle_r',-5000,5000,'mtp_angle_l',-5000,5000,...
        'elbow_flex_l',-5000,5000,'elbow_flex_r',-5000,5000,...
        'arm_add_l',-5000,5000,'arm_add_r',-5000,5000,...
        'arm_rot_l',-5000,5000,'arm_rot_r',-5000,5000,...
        'arm_flex_l',-5000,5000,'arm_flex_r',-5000,5000,...
        };
S.bounds.Qdotdots={'pelvis_tilt',-100000,100000,'pelvis_list',-100000,100000,...
        'pelvis_rotation',-100000,100000,'pelvis_tx',-100,100,'pelvis_tz',-200,200,...
        'pelvis_ty',-300,300,'lumbar_extension',-100000,100000,...
        'lumbar_rotation',-100000,100000,'lumbar_bending',-100000,100000,...
        'hip_flexion_l',-150000,150000,'hip_flexion_r',-150000,150000,...
        'hip_adduction_l',-150000,150000,'hip_adduction_r',-150000,150000,...
        'hip_rotation_l',-1000000,1000000,'hip_rotation_r',-1000000,1000000,...
        'knee_angle_r',-1000000,1000000, 'knee_angle_l',-1000000,1000000,...
        'ankle_angle_r',-4000000,4000000,'ankle_angle_l',-4000000,4000000,...
        'subtalar_angle_r',-2000000,2000000,'subtalar_angle_l',-2000000,2000000,...
        'mtp_angle_r',-2000000,2000000,'mtp_angle_l',-2000000,2000000,...
        'elbow_flex_l',-400000,400000,'elbow_flex_r',-400000,400000,...
        'arm_add_l',-400000,400000,'arm_add_r',-400000,400000,...
        'arm_rot_l',-400000,400000,'arm_rot_r',-400000,400000,...
        'arm_flex_l',-400000,400000,'arm_flex_r',-400000,400000,...
        };

%% Van Wouwe 2024 MTP joint stiffness + damping
S.subject.set_stiffness_coefficient_selected_dofs = {'mtp_angle',40};
S.subject.set_damping_coefficient_selected_dofs = {'mtp_angle',0.4};

%% Inter-penetration constraints (default Falisse_et_al_2022 values)

S.bounds.distanceConstraints(1).point1 = 'calcn_r';
S.bounds.distanceConstraints(1).point2 = 'calcn_l';
S.bounds.distanceConstraints(1).direction = 'xz';
S.bounds.distanceConstraints(1).lower_bound = 0.09;
S.bounds.distanceConstraints(1).upper_bound = 4;

S.bounds.distanceConstraints(2).point1 = 'hand_r';
S.bounds.distanceConstraints(2).point2 = 'femur_r';
S.bounds.distanceConstraints(2).direction = 'xz';
S.bounds.distanceConstraints(2).lower_bound = 0.18;
S.bounds.distanceConstraints(2).upper_bound = 4;

S.bounds.distanceConstraints(3).point1 = 'hand_l';
S.bounds.distanceConstraints(3).point2 = 'femur_l';
S.bounds.distanceConstraints(3).direction = 'xz';
S.bounds.distanceConstraints(3).lower_bound = 0.18;
S.bounds.distanceConstraints(3).upper_bound = 4;

S.bounds.distanceConstraints(4).point1 = 'tibia_r';
S.bounds.distanceConstraints(4).point2 = 'tibia_l';
S.bounds.distanceConstraints(4).direction = 'xz';
S.bounds.distanceConstraints(4).lower_bound = 0.08;
S.bounds.distanceConstraints(4).upper_bound = 4;

S.bounds.distanceConstraints(5).point1 = 'toes_r';
S.bounds.distanceConstraints(5).point2 = 'toes_l';
S.bounds.distanceConstraints(5).direction = 'xz';
S.bounds.distanceConstraints(5).lower_bound = 0.1;
S.bounds.distanceConstraints(5).upper_bound = 4;

%% Final time + step length bounds
S.bounds.t_final.lower=0.1;
S.bounds.t_final.upper=2;
S.bounds.SLL.upper=4;
S.bounds.SLR.upper=4;

%% Run predictive simulations
for speed=[2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9]
   
    S.misc.forward_velocity=speed;
    [savename] = runPredSim(S, osim_path);
    % Use result .mot as initial guess for next run
    IG_file_name=[savename,'.mot'];
    % add path to PredSimResults folder next line
    S.solver.IG_selection = fullfile('C:\Users\\PredSimResults\Falisse_et_al_2022',IG_file_name);
    S.solver.IG_selection_gaitCyclePercent = 200;
end

%% Plot results
% see .\PlotFigures\run_this_file_to_plot_figures.m for more

if ~S.solver.run_as_batch_job

    % set path to reference result
    result_paths{1} = fullfile(pathRepo,'Tests','ReferenceResults',...
        'Falisse_et_al_2022','Falisse_et_al_2022_paper.mat');
    
    % set path to saved result
    result_paths{2} = fullfile(S.misc.save_folder,[savename '.mat']);
    
    % Cell array with legend name for each result
    legend_names = {'Reference result', 'Your first simulation'};
    
    % add path to subfolder with plotting functions
    addpath(fullfile(pathRepo,'PlotFigures'))
    
    figure_settings(1).name = 'all_angles';
    figure_settings(1).dofs = {'all_coords'};
    figure_settings(1).variables = {'Qs'};
    figure_settings(1).savepath = [];
    figure_settings(1).filetype = {};
    
    % call plotting function
    plot_figures(result_paths, legend_names, figure_settings);

end
