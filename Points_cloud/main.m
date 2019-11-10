clc; clear; close all;

%% import data

% -- CHOOSE between H2, alpha__4, H1, L4  L2,--
parameter = 'H1';
% %alpha__4
% param_1 = pi/9;
% param_2 = pi/6;
% param_3 = pi/5;
%H1
param_1 = 0.1;
param_2 = 0.25;
param_3 = 0.4;
% %H2
% param_1 = 0.4;
% param_2 = 0.6;
% param_3 = 0.8;
% %L2
% param_1 = 0.8;
% param_2 = 1  ;
% param_3 = 1.2;
% % L4
% param_1 = 0.5;
% param_2 = 0.7;
% param_3 = 0.9;


path = strcat('../Points_cloud/Points_cloud_', parameter, '_variable');
num_files = (length(dir(sprintf(path))) - 2)/1;
% initialize cell structure
points_clouds = cell(1, num_files);

% fill each cell of the structure with points cloud.
for k = 1:num_files
  filename = sprintf(strcat(path, '/ws_%d.csv'), k);
  points_clouds{1,k} = load(filename);
end
%file_extremes = sprintf(strcat(path, '/extremes_of_', parameter, '.csv'));
%extremes = load(file_extremes);

% alone example with points_cloud_0.csv
points_cloud_0 = load('points_cloud_0.csv');
position = [points_cloud_0(:,1), points_cloud_0(:,2)];
x = position(:,1);
y = position(:,2);
angle = points_cloud_0(:,3);

%% 2D: EE__x, EE__y

% the structure is filled in this way:
    % --> original cloud
    % --> bound indexes of the 2D cloud (x, y)
    % --> bound of the 2D cloud (x,y)
    % --> area of the bounded 2D cloud
    % --> bound indexes of the 2D cloud (x, angle)
    % --> bound of the 2D cloud (x,angle)
    % --> area of the bounded 2D cloud
    % --> bound indexes of the 2D cloud (y, angle)
    % --> bound of the 2D cloud (y,angle)
    % --> area of the bounded 2D cloud
    % --> bound indexes of the 3D cloud (x, y, angle)
    % --> bound of the 3D cloud (x,y,angle)
    % --> volume of the bounded 3D cloud 
shrink_coeff = 0.1;
for k = 1:num_files
  cell_k = points_clouds(1,k);
  matr_k = cell2mat(cell_k);
  x_k = matr_k(:,1);
  y_k = matr_k(:,2);
  angle_k = matr_k(:,3);
  % --> x, y
  [ points_clouds{2,k}, points_clouds{4,k}  ] = boundary( matr_k(:,1), matr_k(:,2), shrink_coeff)
  cell_ind_k = points_clouds(2,k);
  ind_k = cell2mat(cell_ind_k);
  points_clouds{3,k} = [x_k(ind_k), y_k(ind_k)];
  % --> x, angle
  [ points_clouds{5,k}, points_clouds{7,k}  ] = boundary( matr_k(:,1), matr_k(:,3), shrink_coeff)
  cell_ind_k_xangle = points_clouds(5,k);
  ind_k_xangle = cell2mat(cell_ind_k_xangle);
  points_clouds{6,k} = [x_k(ind_k_xangle), angle_k(ind_k_xangle)];
  % --> y, angle
  [ points_clouds{8,k}, points_clouds{10,k}  ] = boundary( matr_k(:,2), matr_k(:,3), shrink_coeff)
  cell_ind_k_yangle = points_clouds(8,k);
  ind_k_yangle = cell2mat(cell_ind_k_yangle);
  points_clouds{9,k} = [y_k(ind_k_yangle), angle_k(ind_k_yangle)];
  % 3D
  [ points_clouds{11,k}, points_clouds{13,k}  ] = boundary( x_k, y_k, angle_k)
  cell_ind_vol_k = points_clouds(11,k);
  ind_vol_k = cell2mat(cell_ind_vol_k);
  points_clouds{12,k} = [x_k(ind_vol_k), y_k(ind_vol_k), angle_k(ind_vol_k)];
end
%% useful matrices for Origin plots
xy_1 = cell2mat(points_clouds(3,1));
xy_2  = cell2mat(points_clouds(3,2));
xy_3 = cell2mat(points_clouds(3,3));

xangle_1 = cell2mat(points_clouds(6,1));
xangle_2  = cell2mat(points_clouds(6,2));
xangle_3 = cell2mat(points_clouds(6,3));

yangle_1 = cell2mat(points_clouds(9,1));
yangle_2  = cell2mat(points_clouds(9,2));
yangle_3 = cell2mat(points_clouds(9,3));

vol_1 = cell2mat(points_clouds(12,1));
vol_2  = cell2mat(points_clouds(12,2));
vol_3 = cell2mat(points_clouds(12,3));


% delta area
max_area_xy = max(cell2mat(points_clouds(4, :)));
min_area_xy = min(cell2mat(points_clouds(4, :)));
delta_area_xy = max_area_xy - min_area_xy;
max_area_xangle = max(cell2mat(points_clouds(7, :)));
min_area_xangle = min(cell2mat(points_clouds(7, :)));
delta_area_xangle = max_area_xangle - min_area_xangle;
max_area_yangle = max(cell2mat(points_clouds(10, :)));
min_area_yangle = min(cell2mat(points_clouds(10, :)));
delta_area_yangle = max_area_yangle - min_area_yangle;
max_volume = max(cell2mat(points_clouds(13, :)));
min_volume = min(cell2mat(points_clouds(13, :)));
delta_volume = max_volume - min_volume;

% sensitivity coefficients

coeff_xy = (delta_area_xy/min_area_xy)/((param_3-param_1)/param_3);
coeff_xangle = (delta_area_xangle/min_area_xangle)/((param_3-param_1)/param_3);
coeff_yangle = (delta_area_yangle/min_area_yangle)/((param_3-param_1)/param_3);
coeff_volume = (delta_volume/min_volume)/((param_3-param_1)/param_3);


% exporting the values of area and coefficients
save(strcat('Workspaces at variable parameters/Workspaces_at_',parameter,'_variable.mat'), ...
  'xy_1', 'xy_2', 'xy_3', 'xangle_1', 'xangle_2', 'xangle_3', 'yangle_1', 'yangle_2', 'yangle_3', ...
  'vol_1', 'vol_2', 'vol_3', ...
  'coeff_xy', 'coeff_xangle', 'coeff_yangle', 'coeff_volume')

% example with points_cloud_0.csv
[bound_idx, area_0] = boundary(x,y, shrink_coeff);
position_bound = [ x(bound_idx), y(bound_idx) ];

% plot of x y workspace

figure(1)
for k = 1:num_files
  hold on
  cell_k = points_clouds(1,k);
  matr_k = cell2mat(cell_k);
  x_k = matr_k(:,1);
  y_k = matr_k(:,2);
  cell_ind_k = points_clouds(2,k);
  ind_k = cell2mat(cell_ind_k);
  plot(x_k(ind_k), y_k(ind_k))
end

title 'X - Y workspace'
xlabel('EE_x [m]')
ylabel('EE_y [m]')

% plot of x - angle workspace
figure(2)
for k = 1:num_files
  hold on
  cell_k = points_clouds(1,k);
  matr_k = cell2mat(cell_k);
  x_k = matr_k(:,1);
  angle_k = matr_k(:,3);
  cell_ind_k = points_clouds(5,k);
  ind_k = cell2mat(cell_ind_k);
  plot(x_k(ind_k), angle_k(ind_k))
end
legend
title 'X - roll workspace'
xlabel('EE_x [m]')
ylabel('Roll angle [rad]')

% plot of y - angle workspace
figure(3)
for k = 1:num_files
  hold on
  cell_k = points_clouds(1,k);
  matr_k = cell2mat(cell_k);
  y_k = matr_k(:,2);
  angle_k = matr_k(:,3);
  cell_ind_k = points_clouds(8,k);
  ind_k = cell2mat(cell_ind_k);
  plot(y_k(ind_k), angle_k(ind_k))
end
legend
title 'Y - roll workspace'
xlabel('EE_y [m]')
ylabel('Roll angle [rad]')

% plot of example with points_cloud_0.csv
figure(4)
plot(points_cloud_0(:,1), points_cloud_0(:,2), 'o')
hold on
plot(x(bound_idx), y(bound_idx))
title('Workspace of position')
xlabel('EE_x')
ylabel('EE_y')

%% 3D: EE__x, EE__y, EE__angle

[bound_pose_idx, volume_0] = boundary(x,y,angle);
pose_bound = [ x(bound_pose_idx), y(bound_pose_idx), angle(bound_pose_idx) ];

figure(5)
for k = 1:num_files
  hold on
  cell_k = points_clouds(1,k);
  matr_k = cell2mat(cell_k);
  x_k = matr_k(:,1);
  y_k = matr_k(:,2);
  angle_k = matr_k(:,3);
  cell_ind_vol_k = points_clouds(11,k);
  ind_vol_k = cell2mat(cell_ind_vol_k);
  trisurf(ind_vol_k, x_k, y_k, angle_k, 'Facecolor', rand(1,3))
end
legend
title('Workspace of total pose')
xlabel('EE_x')
ylabel('EE_y')
zlabel('EE_{angle}')

figure(6)
plot3( x(bound_pose_idx(:,1), 1),y(bound_pose_idx(:,2),1), angle(bound_pose_idx(:,3),1), 'o')
% trisurf(bound_pose_idx, x, y, angle, 'Facecolor','red')
title('Workspace of total pose')
xlabel('EE_x')
ylabel('EE_y')
zlabel('EE_{angle}')

%% output
area_0
volume_0