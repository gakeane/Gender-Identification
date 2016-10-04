close all;
clear all;

addpath('YIN')
addpath('DATA');

% ----------------------------------------------------------------------- %
% This code estimates pitch for 300 male and 300 female utterances using
% the YIN algorithm, it then fits a GMM to each the male and female data
% ----------------------------------------------------------------------- %

    %% File I/O parameters (Male Utterances)
FileLength = 300;                               % number fo male utterances    
FID = fopen('TrainingMale.txt');                % contains addresses of all male utterances
filenames = textscan(FID, '%s');
fclose(FID);
files = filenames{1};

num_mixtures = 5;                      % this can be used to specify number of components in GMM models instead of AIC algorithm
    %% Standard Parameters
L = 400;                    % we want sampleperiod between 10 ms and 40 ms (with FS = 16000 we get 25 ms sample period)
R = L/4;                    % we have window shift so we have 75 % overlap
FS = 16000;                 % Sample frequency of speech
P = struct('minf0', 80, 'maxf0', 200, 'thresh', 0.1, 'relfag', 1, 'hop', R, 'range', [], 'bufsize', 10000, 'sr', FS, 'wsize', L, 'lpf', 900, 'shift', 0);
% declare YIN Structure (gives much better preformance from YIN)

averagePitch = zeros(1, FileLength);        % Holds pitch value of each utterances

    %% Estimae Pitch using YIN Algorithm (male)
for fileNO = 1:FileLength
    
    F = files{fileNO};          % read speech waveform into memory
    [Y, FS] = audioread(F);
    R = yin(Y, P);              % calculate pitch using YIN

        %% Calculate Pitch with most accurate pitch estimates
    Best = 440*exp(R.f0*log(2));
    Best(find(R.ap0 > R.plotthreshold)) = 0;        % clip fundemental frequencies that are obviously wrong

    % figure(fileNO);title('Pitch Tracker Showing Fundemental Frequency');xlabel('time (s)');ylabel('frequency (Hz)')
    % plot((1:length(Best))/(R.sr/R.hop), Best, 'red');hold off;

    Best(isnan(Best)) = [];     % Remove NaNs
    Best = Best(Best ~= 0);     % Remove zeros

    averagePitch(fileNO) = mean(Best);
end

    % plot histogram of male pitches
figure(1);hist(averagePitch, 20);
h1 = findobj(gca,'Type','patch');
set(h1,'FaceColor','r','EdgeColor','k','facealpha',0.75)
hold on;

MeanMalePitch = mean(averagePitch);
MalePitchSD = std(averagePitch);

    % Use AIC algorithm to get best fit GMM 
% AIC = zeros(1, 5);
% GMModels = cell(1, 5);
% options = statset('MaxIter', 500);       % need grater number of iterations for convergence as number of coefficinets increase
% for k = 1:5
%     cInd = kmeans(averagePitch', k, 'Options', options, 'EmptyAction', 'singleton');
%     GMModels{k} = fitgmdist(averagePitch', k, 'Options', options, 'CovType', 'full', 'SharedCov', false, 'Regularize', 0.01, 'Start', cInd);
%     AIC(k)= GMModels{k}.AIC;
% end
% 
% [minAIC, numComponents] = min(AIC);
% BestModelMale = GMModels{numComponents};

    % specify number of components in GMM
options = statset('MaxIter', 500);              % max number of itterations allowed to converge
cInd = kmeans(averagePitch', num_mixtures, 'Options', options, 'EmptyAction', 'singleton');         % use k-nearest neighbour clustering to initalise
BestModelMale = fitgmdist(averagePitch', num_mixtures, 'Options', options, 'CovType', 'full', 'SharedCov', false, 'Regularize', 0.01, 'Start', cInd);       % calculate GMM
    
AveragePitchMale = averagePitch;



    %% File I/O parameters (Female Utterances)
FileLength = 300;                                 % number fo male utterances    
FID = fopen('Trainingfemale.txt');                % contains addresses of all male utterances
filenames = textscan(FID, '%s');
fclose(FID);
files = filenames{1};

    %% Standard Parameters
L = 200;                    % we want sampleperiod between 10 ms and 40 ms (with FS = 16000 we get 12.5 ms sample period)
R = L/4;                    % we have window shift so we have 75 % overlap
FS = 16000;                 % Sample frequency of speech
P = struct('minf0', 140, 'maxf0', 300, 'thresh', 0.1, 'relfag', 1, 'hop', R, 'range', [], 'bufsize', 10000, 'sr', FS, 'wsize', L, 'lpf', 900, 'shift', 0);
% declare YIN Structure (gives much better preformance from YIN)

averagePitch = zeros(1, FileLength);

    %% Estimae Pitch using YIN Algorithm (female)
for fileNO = 1:FileLength
    
    F = files{fileNO};
    [Y, FS] = audioread(F);
    R = yin(Y, P);

        %% Calculate Pitch with most accurate pitch estimates
    Best = 440*exp(R.f0*log(2));
    Best(find(R.ap0 > R.plotthreshold)) = 0;        % clip fundemental frequencies that are obviously wrong

    % figure(fileNO);title('Pitch Tracker Showing Fundemental Frequency');xlabel('time (s)');ylabel('frequency (Hz)')
    % plot((1:length(Best))/(R.sr/R.hop), Best, 'red');hold off;

    Best(isnan(Best)) = [];     % Remove NaNs
    Best = Best(Best ~= 0);     % Remove zeros

    averagePitch(fileNO) = mean(Best);
end

    % plot Histogram of Female Speech
figure(1);hist(averagePitch, 20);hold off;
h2 = findobj(gca,'Type','patch');
set(h2,'facealpha',0.75);
title('Pitch of Male and Female Speakers');xlabel('Pitch');ylabel('Frequency');
legend('Male Speakers', 'Female Speakers');

MeanFemalePitch = mean(averagePitch);
FemalePitchSD = std(averagePitch);

% AIC = zeros(1, 5);
% GMModels = cell(1, 5);
% options = statset('MaxIter', 500);       % need grater number of iterations for convergence as number of coefficinets increase
% for k = 1:5
%     cInd = kmeans(averagePitch', k, 'Options', options, 'EmptyAction', 'singleton');
%     GMModels{k} = fitgmdist(averagePitch', k, 'Options', options, 'CovType', 'full', 'SharedCov', false, 'Regularize', 0.01, 'Start', cInd);
%     AIC(k)= GMModels{k}.AIC;
% end
% 
% [minAIC, numComponents] = min(AIC);
% BestModelFemale = GMModels{numComponents};

    % Calculate GMM for female pitch data
options = statset('MaxIter', 500);
cInd = kmeans(averagePitch', num_mixtures, 'Options', options, 'EmptyAction', 'singleton');
BestModelFemale = fitgmdist(averagePitch', num_mixtures, 'Options', options, 'CovType', 'full', 'SharedCov', false, 'Regularize', 0.01, 'Start', cInd);
AveragePitchFemale = averagePitch;