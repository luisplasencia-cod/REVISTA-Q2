
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Gait Kinematics Prediction Toolbox version 1.01 for GNU Octave and Matlab%
%                                                                         %  
%  Copyright (c) 2011-2013 Youngmok Yun (yunyoungmok@gmail.com)           %
%                                          All rights reserved.           %
%                                                                         %
%                                                                         %
%  Input: database_dir_name                                               %
%  Output: file out optimized hyperparameter set                          %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Gait_Model(database_dir_name)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% GPR startup
addpath('GP');
addpath('GP\Util');
pause(1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameter setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% file name setting
x_file_name = [database_dir_name '/Data_x.mat'];
y_file_name = [database_dir_name '/Data_y.mat'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Hyperparameter Optimization Start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load(x_file_name);
load(y_file_name);

Subject_List = [1:108]';

disp('Hyperparameter Optimization Start ...');

for M=1:14

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Data preprocessing
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    pre_x = Data_x(:,1:14);
    N= length(Subject_List);

    for i = 1:N 
        d(:,i) = Data_y{Subject_List(i)}(:,M);
    end

    % Build data X 
    Total_time_frame = length( d(:,1) );
    t=[1:1:Total_time_frame];
    Big_Ones = ones( N );

    for i=1 : N
        for j=1:Total_time_frame  
            x( (i-1)*Total_time_frame + j,:) = [ pre_x(i,:), j];
        end
    end

    Dim_of_X = length( x(1,:));

    for i=1 : N
        for j=1:Total_time_frame  
            y( (i-1)*Total_time_frame + j,:) = d( j,i);
        end
    end
    avg_d=mean(d')';
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% GP algorithm start
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    hyp=[-7*ones(14,1);5;8;2];
    hyp_op = minimize(hyp,@gp01lik,100,x,y);
    %Optimization

    SaveFileName = [ 'hyp_op' int2str(M) ];
    save(SaveFileName,'hyp_op')
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Hyperparameter optimization for gait period prediction 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hyp=[-7*ones(14,1);8;2];
hyp_op = minimize(hyp,@gp01lik,100,pre_x,Data_y_period);
    
SaveFileName = [ 'hyp_op_P' ];
save(SaveFileName,'hyp_op')
        
disp('Optimization end');

