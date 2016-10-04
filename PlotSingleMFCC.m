clear all;
close all;

% ----------------------------------------------------------------------- %
% this code calculates the MFCCs for male and female training data and fits
% and GMM to the first MFCC. This is meant to graphically display the
% seperability of MFCCS
% ----------------------------------------------------------------------- %

addpath('VOICEBOX');
addpath('DATA');
FileLength = 50;
coefficient = 6;
titles{1} = 'PDF of 6th MFCC';

        %% MALE GMM
FID = fopen('LargeMaleDataBase.txt');
filenames = textscan(FID, '%s');
fclose(FID);
files = filenames{1};
MaleMFCCs = [];

    % Get MFCCs
for i = 1:FileLength
    
    F = files{i};
    [speech, fs] = audioread(F);
    MFCCs = melcepst(speech, fs, 'Mtaz', 12, 26);   
    MaleMFCCs = [MaleMFCCs; MFCCs];
end

    % Determine best fit GMM
AIC = zeros(1, 5);
GMModels = cell(1, 5);
options = statset('MaxIter', 500); 
for k = 1:5
    cInd = kmeans(MaleMFCCs(:,coefficient), k, 'Options', options, 'EmptyAction', 'singleton');
    GMModels{k} = fitgmdist(MaleMFCCs(:,coefficient), k, 'Options', options, 'CovType', 'diagonal', 'Start', cInd);
    AIC(k)= GMModels{k}.AIC;
end

[minAIC, numComponents] = min(AIC);
BestModelMale = GMModels{numComponents};

    % Calculate PDF
Range = -10:0.1:10;
MalePlot = pdf(BestModelMale, Range');







        %% FEMALE GMM
FID = fopen('LargeFemaleDataBase.txt');
filenames = textscan(FID, '%s');
fclose(FID);
files = filenames{1};
FemaleMFCCs = [];

    % Get MFCCs
for i = 1:FileLength

    F = files{i};
    [speech, fs] = audioread(F);
    MFCCs = melcepst(speech, fs, 'Mtaz', 12, 26);  
    FemaleMFCCs = [FemaleMFCCs; MFCCs];
end

    % Determine best fit GMM
AIC = zeros(1, 5);
GMModels = cell(1, 5);
options = statset('MaxIter', 500); 
for k = 1:5
    cInd = kmeans(FemaleMFCCs(:,coefficient), k, 'Options', options, 'EmptyAction', 'singleton');
    GMModels{k} = fitgmdist(FemaleMFCCs(:,coefficient), k, 'Options', options, 'CovType', 'diagonal', 'Start', cInd);
    AIC(k)= GMModels{k}.AIC;
end

[minAIC, numComponents] = min(AIC);
BestModelFemale = GMModels{numComponents};

    % Calculate PDF
Range = -10:0.1:10;
FemalePlot = pdf(BestModelFemale, Range');






    %% plot the Distributions
    
figure(1);
plot(Range, MalePlot, 'r', 'LineWidth', 2);hold on;
plot(Range, FemalePlot, 'b', 'LineWidth', 2);hold on;

[f, x] = hist(MaleMFCCs(:,coefficient), 20);
bar(x, f/trapz(x, f))
h1 = findobj(gca,'Type','patch');
set(h1,'FaceColor','r','EdgeColor','k','facealpha',0.75)
hold on;

[f, x] = hist(FemaleMFCCs(:,coefficient), 20);
bar(x, f/trapz(x, f))
h2 = findobj(gca,'Type','patch');
set(h2,'facealpha',0.75)
hold off;

title(titles(1));xlabel('MFCC Value');ylabel('PDF');
legend('Male', 'Female', [80,260,50, 20]);