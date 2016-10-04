clear all;
close all;

addpath('VOICEBOX')

% ----------------------------------------------------------------------- %
% This code calculates MFCCs using the Voicebox toolkit and fits a GMM to
% the MFCCs
% ----------------------------------------------------------------------- %

    %% File I/O parameters
FileLength = 200;
FID = fopen('LargeFemaleDataBase.txt');
filenames = textscan(FID, '%s');
fclose(FID);
files = filenames{1};

TotalMFCCs = [];

for fileNO = 1:FileLength

    F = files{fileNO};
    [speech, fs] = audioread(F);
    MFCCs = melcepst(speech, fs, 'MtaE0dDz', 10, 20);       % calculate mel coefficinets with deltas and delta-deltas (12 coefficints and 20 filterbanks)
    TotalMFCCs = [TotalMFCCs ; MFCCs];
end
    
NumModels = 10;
options = statset('MaxIter', 200);                          % need grater number of iterations for convergence as number of coefficinets increase
GMM = gmdistribution.fit(TotalMFCCs(:, 1:12), NumModels, 'Options', options);

% figure(1);scatter(MFCCs(:, 3), MFCCs(:, 4));hold on;
% data = [MFCCs(:, 3) , MFCCs(:, 4)];
% GMM = gmdistribution.fit(data, 3);
% 
% h = ezcontour(@(x,y)pdf(GMM,[x y]),[-6 8],[-8 8]);hold off;