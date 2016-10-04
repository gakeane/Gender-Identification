clear all;
close all;

% same as Classifier_MFCC.m except GMM are read in rather than calculated
% from the start

addpath('VOICEBOX');
addpath('DATA');
FileLength = 300;                % Number of files in test data
NUM_MFCCs = 12;                  % number of MFCC coeffients to use

FID = fopen('TestData2Labels.txt');       % Read in correct labels for test data
filenames = textscan(FID, '%s');
fclose(FID);
Labels = filenames{1};

    % Load the Precomputed GMMs (Pitch)
MaleGMM = load('MaleGMM_MFCC.mat');
FemaleGMM = load('FemaleGMM_MFCC.mat');

    % extract the GMM from the structure (Pitch)
BestModelMale = MaleGMM.BestModelMale;
BestModelFemale = FemaleGMM.BestModelFemale;

Results = zeros(3, 13);

for SNR = 5:5:65
        % Keeps track of correct and incorrect classifications
    IncorrectCount = 0;
    IncorrectMale = 0;
    IncorrectFemale = 0;
    CorrectMale = 0;
    CorrectFemale = 0;

        %% Test Classifier

    FID = fopen('TestData2.txt');           % Read in test Data
    filenames = textscan(FID, '%s');
    fclose(FID);
    files = filenames{1};
    FemaleMFCCs = [];

    classification = cell(FileLength, 1);   % used to hold classifications

    for i = 1:FileLength

        F = files{i};
        [speech, fs] = audioread(F);
        speech = awgn(speech, SNR);
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
    A2 = [Precentage; IncorrectMale; IncorrectFemale];
    Results(:,SNR/5) = A2;
end
