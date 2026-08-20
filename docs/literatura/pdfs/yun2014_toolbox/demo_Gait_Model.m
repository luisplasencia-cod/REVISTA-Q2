
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%  Gait Kinematics Prediction Toolbox version 1.01 for GNU Octave/Matlab  %
%                                                                         %  
%  Copyright (c) 2011-2013 Youngmok Yun (yunyoungmok@gmail.com)           %
%                                           All rights reserved           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;close all;clc;

database_dir_name = 'database';

%% Warning: The optimization may take very long time (more than one or two days).
Gait_Model(database_dir_name);

