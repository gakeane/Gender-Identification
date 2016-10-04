clear all;
close all;

% ----------------------------------------------------------------------- %
% This code plots the CDF of the male and female GMMs
% ----------------------------------------------------------------------- %

addpath('DATA');
addpath('MATRICIES');
addpath('YIN');

    % Load the Precomputed GMMs
MaleGMM = load('BestMaleGMM(Full).mat');
MalePitch = load('MalePitch(Full).mat');
FemaleGMM = load('BestFemaleGMM(Full).mat');
FemalePitch = load('FemalePitch(Full).mat');

    % extract the GMM from the structure
MaleGMM = MaleGMM.BestModelMale;
MalePitch = MalePitch.averagePitch;
FemaleGMM = FemaleGMM.BestModelFemale;
FemalePitch = FemalePitch.averagePitch;

figure(1);
x = cdf(MaleGMM, (0:300)');     % calculate male CDF
y = cdf(FemaleGMM, (0:300)');   % claculate female CDF
a1 = x(162);                    % points to plot line at threshold (162 Hz)
a2 = y(162);

h1 = cdfplot(MalePitch);                    % plot male CDF
set(h1,'color','r', 'LineWidth', 2);
hold on;
h2 = cdfplot(FemalePitch);                  % plot Feamle CDF
set(h2,'color','b', 'LineWidth', 2);
hold on;
plot([162, 162], [0, 1], 'k', 'LineWidth', 2);                                  % plot Threshold
plot([0, 300], [a1, a1], 'r--');                                                % Correctly classified male
plot([0, 300], [a2+0.006, a2+0.006], 'b--');hold off;grid off;                  % Incorectly Classified Female
title('CDF of male and Female Pitch data Distributions');xlabel('Pitch');ylabel('CDF');
legend('Male CDF', 'Female CDF');
