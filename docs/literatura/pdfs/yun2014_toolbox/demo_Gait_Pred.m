%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%  Gait Kinematics Prediction Toolbox version 1.01 for GNU Octave/Matlab  %
%                                                                         %  
%  Copyright (c) 2011-2013 Youngmok Yun (yunyoungmok@gmail.com)           %
%                                           All rights reserved           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;close all;clc;

% Body parameter for gait prediction
% 1. Age 2. Height(cm) 3. Mass(kg) 4. Gender(0:f 1:m) 5. Thigh Length (mm) 
% 6. Calf Length (mm) 7. Bi-trochanteric Width (mm)	8. Bi-iliac Width (mm) 9. ASIS Breath (mm) 
% 10. Knee Diameter (mm) 11. Foot Length (mm)	12. Malleolus Height (mm) 13. Malleolus Width (mm) 14. Foot Breath (mm)

%% An arbitrary subject's body parameter data 
test_body_parameter = [30,173,70.2,1,32.8,42.4,32.8,29.7,25.5,10,24,7.30,7.10,9.80];

%%  An arbitrary short subject's body parameter
% test_body_parameter =[49,151,50.9,0,31.2,32.6,32.5,28.4,24.4,10.3,21.2,6.30,6.20,9.17];

%%  An arbitrary tall subject's body parameter
% test_body_parameter = [34,188,86.4,1,40.2,45.0,35.2,32.5,26,12,28.2,6.70,7.55,10.4];

%% An unrealistic subject's body parameter data 
% test_body_parameter = 5*[32,187,89.4,1,40,45.2,35,32.5,26,12,28.9,6.70,7.70,10.5];

database_dir_name = 'database';
hyp_dir_name = 'hyp';

Pred_Gait_Kinematics= Gait_Pred(test_body_parameter,database_dir_name,hyp_dir_name);

