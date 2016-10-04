clear all;
close all;

% ----------------------------------------------------------------------- %
% This code is an alternative method for calculating MFCCs
% ----------------------------------------------------------------------- %

addpath('MFCC')

          % Read speech samples, sampling rate and precision from file
          [speech, fs] = audioread('Y:\TIMIT_database\TIMIT\TRAIN\DR1\MEDR0\SI744.WAV');
          % [speech, fs] = audioread('sp10.wav');

          Tw = 25;           % analysis frame duration (ms)
          Ts = 10;           % analysis frame shift (ms)
          alpha = 0.97;      % preemphasis coefficient
          R = [300 3700];    % frequency range to consider
          M = 20;            % number of filterbank channels 
          C = 12;            % number of cepstral coefficients
          L = 22;            % cepstral sine lifter parameter
          
          % hamming window (see Eq. (5.2) on p.73 of [1])
          % N = round( 1E-3*Tw*fs );    see mfcc function
          hamming = @(N)(0.54-0.46*cos(2*pi*(0:N-1).'/(N-1)));      % here we're creating a handle for this equation, When equation is called it will take N(frame length) as a parameter
      
          % Feature extraction (feature vectors as columns)
          [MFCCs, FBEs, frames] = mfcc(speech, fs, Tw, Ts, alpha, hamming, R, M, C, L);
      
          % Plot cepstrum over time
%           figure('Position', [30 100 800 200], 'PaperPositionMode', 'auto', 'color', 'w', 'PaperOrientation', 'landscape', 'Visible', 'on' ); 
%       
%           imagesc((1:size(MFCCs,2)), (0:C-1), MFCCs); 
%           axis('xy');
%           xlabel('Frame index'); 
%           ylabel('Cepstrum index');
%           title('Mel frequency cepstrum');

            % this just plots the first MFCC for each window 
        for i = 1:12
            figure(1);histfit(MFCCs(i,:));xlabel('Cepstrum index');ylabel('Frequency of occurances');title('1st Mel Cepstrum coefficint');
            
%             mu = mean(MFCCs(i,:));
%             sig = std(MFCCs(i,:));
%             x = round(min(MFCCs(i,:))):0.1:round(max(MFCCs(i,:)));
%             y = 1/sqrt(2*pi)/sig*exp(-(x - mu).^2/2/sig/sig);
%             y = y*max(MFCCs(i,:))/max(y);
%             plot(x, y, 'red');hold off;
           
        end
        
            % calculate GMM of features
        NumModels = 10;
        % GMM = gmdistribution.fit(MFCCs', NumModels, 'CovType', 'diagonal');        % fix this by setting covariance matrix to diagonal (http://uk.mathworks.com/help/stats/gmdistribution.fit.html)
        GMM = gmdistribution.fit(MFCCs', NumModels);
        
        %% plot contours of first two features (MFCC coefficients)
        
        C1 = round(min(MFCCs(1,:))):0.1:round(max(MFCCs(1,:)));
        C2 = round(min(MFCCs(2,:))):0.1:round(max(MFCCs(2,:)));
        if(length(C1) > length(C2))
            C1 = C1(1:length(C2));
        else
            C2 = C2(1:length(C1));
        end
        X = [C1;C2];
        
        mu = GMM.mu(:,[1,2]);
        cov = GMM.Sigma(1:2, 1:2, :);
       
        Z = (2*pi)*((det(cov(:, :, 1))).^(-1/2))*exp((-1/2)*((X - mu(1))')*inv(cov(:,:,1))*(X - mu(1)));
        figure(2);contour(C1, C2, Z);