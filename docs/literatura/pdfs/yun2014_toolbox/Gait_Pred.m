%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                          %
% Gait Kinematics Prediction Toolbox version 1.01 for GNU Octave and Matlab%
%                                                                          %  
%  Copyright (c) 2011-2013 Youngmok Yun (yunyoungmok@gmail.com)            %
%                                          All rights reserved.            %
%                                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Gait_Kinematics = Gait_Pred(test_body_parameter,database_dir_name,hyp_dir_name)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OCTAVE = exist('OCTAVE_VERSION') ~= 0;        % check if we run Matlab or Octave

% GPR startup
addpath('GP');
pause(1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameter setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% file name setting
x_file_name = [database_dir_name '/Data_x.mat'];
y_file_name = [database_dir_name '/Data_y.mat'];

% Visualization setting
set(0,'defaultTextFontName', 'Times New Roman')
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',14)
set(0,'DefaultTextFontSize',14)

% Plotting setting
title_str_set = {'Pelvis X Disp.', 'Pelvis Y Disp.', 'Pelvis Z Disp.', 'Pelvis Rot.',...
    'R. Hip Adduction','R. Hip Extension','R. Hip Medial Rot.','R. Knee Flexion',...
    'R. Ankle P.flex.','L. Hip Abduction.','L. Hip Extension', 'L. Hip Lateral Rot.',...
    'L. Knee Flexion','L. Ankle P. Flex.'};
y_axis_str_set = {'mm', 'mm', 'mm', 'deg',...
    'deg','deg','deg','deg',...
    'deg','deg','deg', 'deg',...
    'deg','deg'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Gait Pattern Prediction Start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load(x_file_name);
load(y_file_name);
Subject_List = [1:108]';
disp('regression start ...');

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
    %% Regression start
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Parameter loading
    LoadFileName_Hyp= [ hyp_dir_name '/hyp_op' int2str(M) ];
    load(LoadFileName_Hyp);

    for i=1:Total_time_frame
        x_s(i,:) = [test_body_parameter, i];
    end


    [ys, yv2] = gp01pred(hyp_op,x,y,x_s);
    
    save(int2str(M),'ys','yv2');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Plot result
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    close all;
    f=figure('position',[100 100 600 400]);
    grid on; hold on;
    title(title_str_set{M})

        
    if OCTAVE %Octave
        i=1;	
        pg=plot(t/Total_time_frame,d(:,i),'color',[0.20 0.20 0.20],'linewidth',0.2,';Database;');
        for i=2:N-1
              pg=plot(t/Total_time_frame,d(:,i),'color',[0.20 0.20 0.20],'linewidth',0.2);
        end

        pm=plot(t/Total_time_frame,avg_d,'color','m','LineWidth',5,';Average;');
        pb=plot(t/Total_time_frame,ys,'color','b','LineWidth',5,';Predicted;');
        pgr=plot(t/Total_time_frame,ys-sqrt(yv2),'color','g','LineWidth',2,';Std;');
        plot(t/Total_time_frame,ys+sqrt(yv2),'color','g','LineWidth',2)

        %legend([pb,pgr,pm,pg],'Predicted','Std','Average','Database')
        ylabel(y_axis_str_set{M});
        xlabel('time/gait period')

        SaveFileName = [ num2str(M) '.png'];
        print(f,SaveFileName)

        

    else % Matlab
        for i=1:N-1
          pg=plot(t/Total_time_frame,d(:,i),'color',[0.20 0.20 0.20],'linewidth',0.2);
        end
        pm=plot(t/Total_time_frame,avg_d,'-m','LineWidth',5);
        pb=plot(t/Total_time_frame,ys,'-b','LineWidth',5);
        pgr=plot(t/Total_time_frame,ys-sqrt(yv2),'-g','LineWidth',2);
        plot(t/Total_time_frame,ys+sqrt(yv2),'-g','LineWidth',2)

        legend([pb,pgr,pm,pg],'Predicted','Std','Average','Database')
        ylabel(y_axis_str_set(M));
        xlabel('time/gait period')

        SaveFileName = [ num2str(M)];
        saveas(f,SaveFileName ,'png')
    end
    
    disp(['saving Figure for ' title_str_set{M} ' to ' num2str(M) '.png']);

    Gait_Kinematics{M}.mean = ys;
    Gait_Kinematics{M}.std = yv2;
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Gait Period Prediction Start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load([hyp_dir_name '/hyp_op_P']);
[ys, yv2] = gp01pred(hyp_op,pre_x,Data_y_period,test_body_parameter);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot result
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
disp(['saving Figure for Gait Period to 15.png']);
f=figure('position',[100 100 600 400]);
title('Gait Period')
hold on;

if OCTAVE
    bar_var_x = [1 6 [12:12+N-1]];
    bar_var_y = [ys; mean(Data_y_period); Data_y_period];
    bar(bar_var_x,bar_var_y);
    set(gca,'XTick',[1,6,55]);
    set(gca,'XTickLabel',{'P','A','Database'})
    ylabel('sec')

    SaveFileName = [ num2str(15) '.png'];
    print(f,SaveFileName)
    close all;
    
else %matlab
 
    b1=bar(1,ys,5,'b');
%     b2=bar(6,mean(Data_y_period),5,'m');
    b2=bar(6,1.12,5,'m');
    b3=bar([12:12+N-1],Data_y_period,1,'facecolor',[0.7 0.7 0.7]);
 
    axis([-10 130 0 1.5])
    set(gca,'XTickLabel',{''})
    set(gca,'YGrid','on')
    ylabel('sec')

    annotation(f,'textbox',...
    [0.1885 0.77 0.26 0.09],...
    'String',{['Std=' num2str(yv2,2) 's']},...
    'BackgroundColor',[1 1 1]);

    legend([b1,b2,b3],'Predicted','Average','Database')

    saveas(f,'15','png')
%     close all;
end

Gait_Kinematics{15}.ys = ys;
Gait_Kinematics{15}.yv2 = yv2;

disp('regression end');


