clear all;
close all;

% Trains GMM for each male and female training utterances from TIMIT
% MFCCs are used as features
% Classifies new utterances as either male or female based on GMMs

addpath('VOICEBOX');
addpath('DATA');
FileLength = 300;               % Number of files in test data
NUM_MFCCs = 12;                 % number of MFCC coeffients to use
NUM_MIXTURES = 6;               % numbre of mixtures in GMMs

% FID = fopen('CorrectLabels.txt');       % Read in correct labels for test data
FID = fopen('TestData2Labels.txt');       % Read in correct labels for test data
filenames = textscan(FID, '%s');
fclose(FID);
Labels = filenames{1};

    % Keeps track of correct and incorrect classifications
IncorrectCount = 0;
IncorrectMale = 0;
IncorrectFemale = 0;
CorrectMale = 0;
CorrectFemale = 0;

        %% Create MALE GMM
FID = fopen('TrainingMale.txt');
filenames = textscan(FID, '%s');
fclose(FID);
files = filenames{1};
MaleMFCCs = [];

    % Get MFCCs
for i = 1:FileLength
    
    F = files{i};
    [speech, fs] = audioread(F);
    MFCCs = melcepst(speech, fs, 'Mtaz', NUM_MFCCs, 26);   
    MaleMFCCs = [MaleMFCCs; MFCCs];
end

    % Determine best fit GMM with AIC algorithm
% AIC = zeros(1, 5);
% GMModels = cell(1, 5);
% options = statset('MaxIter', 1000); 
% for k = 1:5
%     cInd = kmeans(MaleMFCCs, k, 'Options', options, 'EmptyAction', 'singleton');
%     GMModels{k} = fitgmdist(MaleMFCCs, k, 'Options', options, 'CovType', 'diagonal', 'Start', cInd);
%     AIC(k)= GMModels{k}.AIC;
% end
% 
% [minAIC, numComponents] = min(AIC);
% BestModelMale = GMModels{numComponents};

    % Fit GMM model to MFCCs
options = statset('MaxIter', 1000);         % limit max itterations without convergence

    % use kNN to initalise and set covariance type to diagonal
cInd = kmeans(MaleMFCCs, NUM_MIXTURES, 'Options', options, 'EmptyAction', 'singleton');
BestModelMale = fitgmdist(MaleMFCCs, NUM_MIXTURES, 'Options', options, 'CovType', 'diagonal', 'Start', cInd);

        %% create FEMALE GMM
FID = fopen('TrainingFemale.txt');
filenames = textscan(FID, '%s');
fclose(FID);
files = filenames{1};
FemaleMFCCs = [];

    % Get MFCCs
for i = 1:FileLength

    F = files{i};
    [speech, fs] = audioread(F);
    MFCCs = melcepst(speech, fs, 'Mtaz', NUM_MFCCs, 26);  
    FemaleMFCCs = [FemaleMFCCs; MFCCs];
end

    % Determine best fit GMM with AIC algorithm
% AIC = zeros(1, 5);
% GMModels = cell(1, 5);
% options = statset('MaxIter', 1000); 
% for k = 1:5
%     cInd = kmeans(FemaleMFCCs, k, 'Options', options, 'EmptyAction', 'singleton');
%     GMModels{k} = fitgmdist(FemaleMFCCs, k, 'Options', options, 'CovType', 'diagonal', 'Start', cInd);
%     AIC(k)= GMModels{k}.AIC;
% end
% 
% [minAIC, numComponents] = min(AIC);
% BestModelFemale = GMModels{numComponents};


    % Fit GMM model to MFCCs
options = statset('MaxIter', 1000);         % limit max itterations without convergence

    % use kNN to initalise and set covariance type to diagonal
cInd = kmeans(FemaleMFCCs, NUM_MIXTURES, 'Options', options, 'EmptyAction', 'singleton');
BestModelFemale = fitgmdist(FemaleMFCCs, NUM_MIXTURES, 'Options', options, 'CovType', 'diagonal', 'Start', cInd);

        

    %% Test Classifier
    
% FileLength = 450;
% FID = fopen('TestData.txt');
FileLength = 300;
FID = fopen('TestData2.txt');           % Read in test Data
filenames = textscan(FID, '%s');
fclose(FID);
files = filenames{1};
FemaleMFCCs = [];

classification = cell(FileLength, 1);   % used to hold classifications

for i = 1:FileLength

    F = files{i};
    [speech, fs] = audioread(F);
    MFCCs = melcepst(speech, fs, 'Mtaz', NUM_MFCCs, 26);    % Get MFCCs of classified data

        % Calculate PDF for male and female GMMs
    ProbsMale = pdf(BestModelMale, MFCCs);          
    ProbsFemale = pdf(BestModelFemale, MFCCs);

        % Calculate average Liklihood of male or female classification
        % based of PDF for each MFCCs section
    averageMale = mean(ProbsMale);
    averageFemale = mean(ProbsFemale);
    
    counterMale = 0;
    counterFemale = 0;
    
    for j = 1:length(ProbsMale)
        if (ProbsMale(j) > ProbsFemale(j))
            counterMale = counterMale + 1;
        else
            counterFemale = counterFemale + 1;
        end
    end

    
        % count number of correcta nd incorrect classifications
        % Classification is male if average PDF of male GMM is greater the
        % female PDF calculated at loacations given by MFCCs for each test
        % utterance
%     if (averageMale > averageFemale)
%         classification{i} = 'M';
%     else
%         classification{i} = 'F';
%     end
    
    if (counterMale > counterFemale)
        classification{i} = 'M';
    else
        classification{i} = 'F';
    end

    if (classification{i} ~= Labels{i})
        IncorrectCount = IncorrectCount + 1;
        if (Labels{i} == 'F')
            IncorrectFemale = IncorrectFemale + 1;
        end
        if (Labels{i} == 'M')
            IncorrectMale = IncorrectMale + 1;
        end
        
    else
        if (Labels{i} == 'F')
            CorrectFemale = CorrectFemale + 1;
        end
        if (Labels{i} == 'M')
            CorrectMale = CorrectMale + 1;
        end
    end
end

Precentage = ((FileLength - IncorrectCount)/FileLength)*100;        % final classification precentage

A1 = [CorrectMale, CorrectFemale, IncorrectMale, IncorrectFemale, Precentage];

    % Print Results to a files
fileID = fopen('Results.txt','w');
fprintf(fileID, 'Number of Correctly Identified Male Speakers %8.3f     \n', A1(1));
fprintf(fileID, 'Number of Correctly Identified Female Speakers %8.3f   \n', A1(2));
fprintf(fileID, 'Number of Incorrectly Identified Male Speakers %8.3f   \n', A1(3));
fprintf(fileID, 'Number of Incorrectly Identified Female Speakers %8.3f \n', A1(4));
fprintf(fileID, 'Total Precentage of Correct Classification %8.3f       \n', A1(5));