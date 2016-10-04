clear all;
close all;

% classification is done using a mixture of Pitch and MFCC features

addpath('DATA');
addpath('MATRICIES');
addpath('YIN');
addpath('VOICEBOX');
addpath('DATA');

    %% File I/O parameters

FID = fopen('TestData2Labels.txt');     % correct labels of test data (150 male and 150 female utterances)
filenames = textscan(FID, '%s');
fclose(FID);
Labels = filenames{1};

    % variables to keep track of correct and incorrect counts
IncorrectCount = 0;
IncorrectMale = 0;
IncorrectFemale = 0;
CorrectMale = 0;
CorrectFemale = 0;

    % Load the Precomputed GMMs (Pitch)
MaleGMM = load('BestMaleGMM(Full).mat');
FemaleGMM = load('BestFemaleGMM(Full).mat');

    % extract the GMM from the structure (Pitch)
MaleGMM_Pitch = MaleGMM.BestModelMale;
FemaleGMM_Pitch = FemaleGMM.BestModelFemale;

    % Load the Precomputed GMMs (Pitch)
MaleGMM = load('MaleGMM_MFCC.mat');
FemaleGMM = load('FemaleGMM_MFCC.mat');

    % extract the GMM from the structure (Pitch)
MaleGMM_MFCC = MaleGMM.BestModelMale;
FemaleGMM_MFCC = FemaleGMM.BestModelFemale;

FileLength = 300;               % Number of files in test data
NUM_MFCCs = 12;                  % number of MFCC coeffients to use

    % declare YIN Parameters to extract pitch from test utterances
L = 300;                    % we want sample period between 10 ms and 40 ms (with FS = 16000 we get 25 ms sample period)
R = L/4;                    % we have window shift so we have 75 % overlap
FS = 16000;
P = struct('minf0', 80, 'maxf0', 300, 'thresh', 0.1, 'relfag', 1, 'hop', R, 'range', [], 'bufsize', 10000, 'sr', FS, 'wsize', L, 'lpf', 900, 'shift', 0);

FID = fopen('TestData2.txt');
filenames = textscan(FID, '%s');
fclose(FID);
files = filenames{1};

Classification = cell(FileLength, 1);
for FileNO = 1:FileLength
    
    F = files{FileNO};      % read in file
    Y = audioread(F);       % store speech wave form in memory
    R = yin(Y, P);          % get pitch of speech waveform using YIN

    Best = 440*exp(R.f0*log(2));                    % only use the best voiced regions
    Best(find(R.ap0 > R.plotthreshold)) = 0;        % clip fundemental frequencies that are obviously wrong

    Best(isnan(Best)) = [];     % Remove NaNs
    Best = Best(Best ~= 0);     % Remove zeros

    averagePitch = mean(Best);  % Calulate average pitch of all windows (pitch of utterance)   
    p = [pdf(MaleGMM_Pitch, averagePitch), pdf(FemaleGMM_Pitch, averagePitch)];     % Calculate probability that pitch is that of male or female based on GMM PDFs

    % if classification using pitch is obvious then just classify based on
    % pitch as normal
    if (abs(p(1) - p(2)) > 0.005)
            % classify as male if p(1) > p(2)
        if (p(1) > p(2))
            Classification{FileNO} = 'M';
        else
            Classification{FileNO} = 'F';
        end
        
    % if we are unsure of classification based on pitch alone then use
    % MFCCs for classification
    else
        [speech, fs] = audioread(F);
        MFCCs = melcepst(speech, fs, 'Mtaz', NUM_MFCCs, 26);    % Get MFCCs of classified data

            % Calculate PDF for male and female GMMs
        ProbsMale = pdf(MaleGMM_MFCC, MFCCs);          
        ProbsFemale = pdf(FemaleGMM_MFCC, MFCCs);
        
        counterMale = 0;
        counterFemale = 0;
        
        % count number of classified sections
        for j = 1:length(ProbsMale)
            if (ProbsMale(j) > ProbsFemale(j))
                counterMale = counterMale + 1;
            else
                counterFemale = counterFemale + 1;
            end
        end
        
        % classify based on number of classified scetions for each
        % utterance
        if (counterMale > counterFemale)
            Classification{FileNO} = 'M';
        else
            Classification{FileNO} = 'F';
        end
    end
    
        % compare classifications to actual labels and count number of
        % correct and incorrectly classified males and females
    if (Classification{FileNO} ~= Labels{FileNO})
        IncorrectCount = IncorrectCount + 1;
        if (Labels{FileNO} == 'F')
            IncorrectFemale = IncorrectFemale + 1;
        end
        if (Labels{FileNO} == 'M')
            IncorrectMale = IncorrectMale + 1;
        end
        
    else
        if (Labels{FileNO} == 'F')
            CorrectFemale = CorrectFemale + 1;
        end
        if (Labels{FileNO} == 'M')
            CorrectMale = CorrectMale + 1;
        end
    end
end

Precentage = ((FileLength - IncorrectCount)/FileLength)*100;        % final classification precentage
A1 = [CorrectMale, CorrectFemale, IncorrectMale, IncorrectFemale, Precentage];