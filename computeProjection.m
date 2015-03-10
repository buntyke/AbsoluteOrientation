% Program demonstrating absolute orientation
% Author: Nishanth Koganti
% Date: 2015/2/18

function computeProjection(fileName)

% Plot variables
close all;
fontSize = 12;
markerSize = 5;

%% Load the T-Rex point cloud
rawPC = load(fileName);
rawPC = [rawPC(:,3) rawPC(:,2) rawPC(:,1)];

% Process the raw point cloud
nPoints = size(rawPC,1);
rawPCMean = mean(rawPC,1);
rawPCSTD = mean(std(rawPC));

PC = transpose(rawPC - repmat(rawPCMean,nPoints,1));

% Plot the point cloud
figure;
hold on;
xlabel('X [m]', 'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('Y [m]', 'FontSize', fontSize, 'FontWeight', 'bold');
zlabel('Z [m]', 'FontSize', fontSize, 'FontWeight', 'bold');
title('T-Rex Point Cloud',  'FontSize', fontSize, 'FontWeight', 'bold');
set(gca, 'FontSize', fontSize, 'FontWeight', 'bold');
view([105 15]);
            
plot3(PC(1,:), PC(2,:), PC(3,:), '.b', 'MarkerSize', markerSize);
hold off;
waitforbuttonpress;

%% Modify T-Rex point cloud

% Generating random but valid rotation matrix
[RTarget,~] = qr(randn(3));

% Genrating random translation vector
tTarget = 300*randn(3,1);

% Generating random scale parameter
cTarget = rand();

% Get the modified point cloud
modPC = cTarget*RTarget*PC + repmat(tTarget,1,nPoints);

% Add noise to both point clouds
modPC = modPC + 0.1*cTarget*rawPCSTD*randn(3,nPoints);
PC = PC + 0.1*rawPCSTD*randn(3,nPoints);

figure;
hold on;
xlabel('X [m]', 'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('Y [m]', 'FontSize', fontSize, 'FontWeight', 'bold');
zlabel('Z [m]', 'FontSize', fontSize, 'FontWeight', 'bold');
title('T-Rex Point Cloud with Modification',  'FontSize', fontSize, 'FontWeight', 'bold');
set(gca, 'FontSize', fontSize, 'FontWeight', 'bold');
view([105 15]);
            
plot3(PC(1,:), PC(2,:), PC(3,:), '.b', 'MarkerSize', markerSize);
plot3(modPC(1,:), modPC(2,:), modPC(3,:), '.r', 'MarkerSize', markerSize);
hold off;
waitforbuttonpress;

%% Compute transformation matrix
[ROut,tOut,cOut,err,modPCOut] = absoluteOrientationSVD(modPC, PC);

transOut = [(1/cOut)*ROut'; 0 0 0];
transOut = [transOut [-(ROut'*tOut)/cOut; 1]];

transTarget = [cTarget*RTarget; 0 0 0];
transTarget = [transTarget [tTarget; 1]];

% Save and print the results
dlmwrite('TransTarget', transTarget);
dlmwrite('TransOut', transOut);
fprintf('Error: %f\n',err);
    
% Plot 
figure;
hold on;
xlabel('X [m]', 'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('Y [m]', 'FontSize', fontSize, 'FontWeight', 'bold');
zlabel('Z [m]', 'FontSize', fontSize, 'FontWeight', 'bold');
title('T-Rex point cloud after transformation',  'FontSize', fontSize, 'FontWeight', 'bold');
set(gca, 'FontSize', fontSize, 'FontWeight', 'bold');
view([105 15]);
            
plot3(PC(1,:), PC(2,:), PC(3,:), '.b', 'MarkerSize', markerSize);
plot3(modPCOut(1,:), modPCOut(2,:), modPCOut(3,:), '.r', 'MarkerSize', markerSize);
hold off;