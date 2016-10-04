clear all;
close all;

% ----------------------------------------------------------------------- %
% this code calculates the MFCCs for male and female training data and fits
% and GMM to the first two MFCCs. This is meant to graphically display the
% seperability of MFCCS
% ----------------------------------------------------------------------- %

addpath('VOICEBOX');
addpath('DATA');
FileLength = 50;        % number of utterances used
c1 = 7;                 % coefficinets to be plotted
c2 = c1 + 1;

        %% MALE GMM
% load in male training database
FID = fopen('LargeMaleDataBase.txt');
filenames = textscan(FID, '%s');
fclose(FID);
files = filenames{1};
MaleMFCCs = [];

    % Get MFCCs for males
for i = 1:FileLength
    
    F = files{i};
    [speech, fs] = audioread(F);                    % read in each file
    MFCCs = melcepst(speech, fs, 'Mtaz', 12, 26);   % Mtaz uses default parameters, 12 coefficints and 26 filterbanks
    MaleMFCCs = [MaleMFCCs; MFCCs];                 % combine all MFCCs into single matrix
end

MaleMFCCs = MaleMFCCs(:, c1:c2);            % we're only concerned with the bivariate case here

    % Determine best fit GMM using AIC algorithm
AIC = zeros(1, 5);
GMModels = cell(1, 5);
options = statset('MaxIter', 500); 
for k = 1:5
    cInd = kmeans(MaleMFCCs(:,1:2), k, 'Options', options, 'EmptyAction', 'singleton');                         % use k-means to getstarting point of GMMs
    GMModels{k} = fitgmdist(MaleMFCCs(:,1:2), k, 'Options', options, 'CovType', 'diagonal', 'Start', cInd);     % calculate GMM using diferent number of components
    AIC(k)= GMModels{k}.AIC;                                                                                    % estimae the fit of the GMM model
end

[minAIC, numComponents] = min(AIC);
BestModelMale = GMModels{numComponents};        % chose best fitting GMM model

        %% FEMALE GMM
FID = fopen('LargeFemaleDataBase.txt');         % Load in Female Database
filenames = textscan(FID, '%s');
fclose(FID);
files = filenames{1};
FemaleMFCCs = [];

    % Get MFCCs for Females
for i = 1:FileLength

    F = files{i};
    [speech, fs] = audioread(F);                        % read in each file
    MFCCs = melcepst(speech, fs, 'Mtaz', 12, 26);       % Mtaz uses default parameters, 12 coefficints and 26 filterbanks
    FemaleMFCCs = [FemaleMFCCs; MFCCs];                 % combine all MFCCs into single matrix
end

FemaleMFCCs = FemaleMFCCs(:, c1:c2);        % we're only concerned with the bivariate case here

    % Determine best fit GMM using AIC algorithm
AIC = zeros(1, 5);
GMModels = cell(1, 5);
options = statset('MaxIter', 500); 
for k = 1:5
    cInd = kmeans(FemaleMFCCs, k, 'Options', options, 'EmptyAction', 'singleton');                          % use k-means to getstarting point of GMMs
    GMModels{k} = fitgmdist(FemaleMFCCs, k, 'Options', options, 'CovType', 'diagonal', 'Start', cInd);      % calculate GMM using diferent number of components
    AIC(k)= GMModels{k}.AIC;                                                                                % estimae the fit of the GMM model
end

[minAIC, numComponents] = min(AIC);
BestModelFemale = GMModels{numComponents};      % chose best fitting GMM model


    %% PLOTS
% plot the male and female GMM distributions over the scatter plot of the
% data using eazy contour function
figure(1);
ezcontour(@(x1,x2)pdf(BestModelMale, [x1 x2]), [-10 10], [-10 10]);
h1 = findobj(gca,'Type','patch');
set(h1,'FaceColor','r','EdgeColor','r','facealpha',0.75,'LineWidth',2)
hold on;

scatter(MaleMFCCs(:,1), MaleMFCCs(:,2), 5);hold on;

figure(2);
ezcontour(@(x1,x2)pdf(BestModelFemale, [x1 x2]), [-10 10], [-10 10]);
h2 = findobj(gca,'Type','patch');
set(h2,'FaceColor','r','EdgeColor','r','facealpha',0.75,'LineWidth',2)
hold on;

scatter(FemaleMFCCs(:,1), FemaleMFCCs(:,2), 5);hold off;

    %% calculate Contour plots ourselves
[X, Y] = meshgrid(-10:0.1:10, -10:0.1:10);              % grid which data will be plotted over

Data = [];
for i = 1:201
    Data = [Data ; [X(:,i) , Y(:,1)]];                  % Refine data grid to single 2 column vector
end

ProbM = pdf(BestModelMale, Data);               % calutale male distribution at points in column vector (result will be a 2 column vector)
ProbF = pdf(BestModelFemale, Data);             % calutale female distribution at points in column vector (result will be a 2 column vector)
PBM = zeros(201,201);
PBF = zeros(201,201);
% Convert 2 column verctor back back to square grid so it can be plotted
for i = 1:201
    PBM(i,:) = ProbM((201*(i - 1) + 1):(201*i));        
    PBF(i,:) = ProbF((201*(i - 1) + 1):(201*i));
end
figure(3);contour(PBM');title('Male');xlabel('C3');ylabel('C2');
figure(4);contour(PBF');title('Female');xlabel('C4');ylabel('C2');

    % plot Surface plot of bivaratie GMM
figure(5);
h1 = surf(PBM');set(h1,'FaceColor',[1 0 0],'FaceAlpha',0.75);hold on;
h2 = surf(PBF');set(h2,'FaceColor',[0 0 1],'FaceAlpha',0.75);hold off;
title('GMM distribution plots of 7th and 8th MFCC coefficinets for male and female utterance');xlabel('C7');ylabel('C8');zlabel('PDF');
legend('Male GMM', 'Female GMM');