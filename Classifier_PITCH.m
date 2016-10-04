clear all;
close all;

addpath('DATA');
addpath('MATRICIES');
addpath('YIN');

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

    %% PLOTS
    % Calculate PDF for ploting purposes
Range = 0:299;
MalePlot = pdf(MaleGMM, Range');
FemalePlot = pdf(FemaleGMM, Range');

    % Plot Male Histogram
figure(1);
[f, x] = hist(MalePitch, 20);          % create histogram from a normal distribution.
bar(x, f/trapz(x, f))
h1 = findobj(gca,'Type','patch');
set(h1,'FaceColor','r','EdgeColor','k','facealpha',0.75)
hold on;

    % Plot Female Histogram
[f, x] = hist(FemalePitch, 20);          % create histogram from a normal distribution.
bar(x, f/trapz(x, f))
h2 = findobj(gca,'Type','patch');
set(h2,'facealpha',0.75);
hold on;

    % plot male and female GMM PDF
plot(Range, MalePlot, 'b', 'LineWidth', 2);hold on;
plot(Range, FemalePlot, 'r', 'LineWidth', 2);
hold on;

    % declare YIN Parameters to extract pitch from test utterances
L = 300;                    % we want sample period between 10 ms and 40 ms (with FS = 16000 we get 25 ms sample period)
R = L/4;                    % we have window shift so we have 75 % overlap
FS = 16000;
P = struct('minf0', 80, 'maxf0', 300, 'thresh', 0.1, 'relfag', 1, 'hop', R, 'range', [], 'bufsize', 10000, 'sr', FS, 'wsize', L, 'lpf', 900, 'shift', 0);

    %% File I/O parameters (TEST DATA)
% FileLength = 450;
% FID = fopen('PartialDataBase.txt');
FileLength = 300;
FID = fopen('TestData2.txt');
filenames = textscan(FID, '%s');
fclose(FID);
files = filenames{1};

Classification = cell(FileLength, 2);       % used to hold classification data
h3 = [];                                    % used for ploting purposes

    % Calculate Pitch for each file and determine which GMM it most likely
    % belongs to
for FileNO = 1:FileLength
    
    F = files{FileNO};      % read in file
    Y = audioread(F);       % store speech wave form in memory
    R = yin(Y, P);          % get pitch of speech waveform using YIN

    Best = 440*exp(R.f0*log(2));                    % only use the best voiced regions
    Best(find(R.ap0 > R.plotthreshold)) = 0;        % clip fundemental frequencies that are obviously wrong

    Best(isnan(Best)) = [];     % Remove NaNs
    Best = Best(Best ~= 0);     % Remove zeros

    averagePitch = mean(Best);  % Calulate average pitch of all windows (pitch of utterance)

    p = [pdf(MaleGMM, averagePitch), pdf(FemaleGMM, averagePitch)];     % Calculate probability that pitch is that of male or female based on GMM PDFs

        % classify as male if p(1) > p(2)
    if (p(1) > p(2))
        Classification{FileNO} = 'M';
    else
        Classification{FileNO} = 'F';
    end
    
    % count correct numbers of male and female classification
    % plot location of each pitch on the histogram (red for incorrect
    % classification and black for correct classification)
    figure(1);
    delete(h3);
    if (Classification{FileNO} == Labels{FileNO})
        h3 = plot([averagePitch, averagePitch], [0, 0.035], 'k', 'LineWidth', 2);
        
        if (Labels{FileNO} == 'F')
            CorrectFemale = CorrectFemale + 1;
        end
        if (Labels{FileNO} == 'M')
            CorrectMale = CorrectMale + 1;
        end
    else
        h3 = plot([averagePitch, averagePitch], [0, 0.035], 'r', 'LineWidth', 2);
        IncorrectCount = IncorrectCount + 1;

        if (Labels{FileNO} == 'F')
            IncorrectFemale = IncorrectFemale + 1;
        end
        if (Labels{FileNO} == 'M')
            IncorrectMale = IncorrectMale + 1;
        end
    end
    xlabel('Pitch');ylabel('PDF');title('Classification Based on Pitch');
end

Precentage = ((FileLength - IncorrectCount)/FileLength)*100;    % Total overall precentage

A1 = [CorrectMale, CorrectFemale, IncorrectMale, IncorrectFemale, Precentage];

    % Print Results to a files
fileID = fopen('Results.txt','w');
fprintf(fileID, 'Number of Correctly Identified Male Speakers %8.3f     \n', A1(1));
fprintf(fileID, 'Number of Correctly Identified Female Speakers %8.3f   \n', A1(2));
fprintf(fileID, 'Number of Incorrectly Identified Male Speakers %8.3f   \n', A1(3));
fprintf(fileID, 'Number of Incorrectly Identified Female Speakers %8.3f \n', A1(4));
fprintf(fileID, 'Total Precentage of Correct Classification %8.3f       \n', A1(5));