clear all;
close all;

% ----------------------------------------------------------------------- %
% This code plots the histograms and pdf of the pitch data and GMMs
% ----------------------------------------------------------------------- %

addpath('MATRICIES');

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

    % calculatae PDF of GMMs
Range = 0:299;
MalePlot = pdf(MaleGMM, Range');
FemalePlot = pdf(FemaleGMM, Range');

    % Plot male Histogram
figure(1);
[f, x] = hist(MalePitch, 20);          % create histogram from a normal distribution.
bar(x, f/trapz(x, f))
h1 = findobj(gca,'Type','patch');
set(h1,'FaceColor','r','EdgeColor','k','facealpha',0.75)
hold on;

    % plot Female Histogram
[f, x] = hist(FemalePitch, 20);          % create histogram from a normal distribution.
bar(x, f/trapz(x, f))
h2 = findobj(gca,'Type','patch');
set(h2,'facealpha',0.75);
hold on;

    % Plot male and female PDFs
plot(Range, MalePlot, 'b', 'LineWidth', 2);hold on;
plot(Range, FemalePlot, 'r', 'LineWidth', 2);
hold on;


    % this is just a classification test with a single sample
L = 400;                    % we want sampleperiod between 10 ms and 40 ms (with FS = 16000 we get 25 ms sample period)
R = L/4;                    % we have window shift so we have 75 % overlap
FS = 16000;
P = struct('minf0', 80, 'maxf0', 300, 'thresh', 0.1, 'relfag', 1, 'hop', R, 'range', [], 'bufsize', 10000, 'sr', FS, 'wsize', L, 'lpf', 900, 'shift', 0);

Y = audioread('Y:\TIMIT_database\TIMIT\TRAIN\DR1\MDAC0\SI1837.WAV');
R = yin(Y, P);

Best = 440*exp(R.f0*log(2));
Best(find(R.ap0 > R.plotthreshold)) = 0;        % clip fundemental frequencies that are obviously wrong

Best(isnan(Best)) = [];     % Remove NaNs
Best = Best(Best ~= 0);     % Remove zeros

averagePitch = mean(Best);

% figure(1);
% plot([averagePitch, averagePitch], [0, 0.05], 'k', 'LineWidth', 2);
xlabel('Fundemental Frequency (Pitch)');ylabel('PDF');title('Seperation of Male and Female Classes Based On Pitch');
legend('Male PDF', 'Female PDF', 'Male GMM', 'Female GMM');
hold off;

p = [pdf(MaleGMM, averagePitch), pdf(FemaleGMM, averagePitch)];
if (p(1) > p(2))
    classification = 'm';
else
    classification = 'f';
end