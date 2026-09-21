clear;
clc;
close all;

% ==========================================
% PROJECT PATH
% ==========================================

addpath(genpath(pwd));

% ==========================================
% DAY 2 - NLMS ANC TEST
% ==========================================

fprintf('\n');
fprintf('============================================\n');
fprintf('       AI ADAPTIVE AUDIO - ANC TEST\n');
fprintf('============================================\n');

% ==========================================
% GENERATE TEST SIGNAL
% ==========================================

[t, cleanSignal, referenceNoise, noise, noisySignal, Fs] = ...
    generateTestSignal();
% ==========================================
% AUTOMATIC PARAMETER OPTIMIZATION
% ==========================================

bestConfig = optimizeANC( ...
    cleanSignal, ...
    noisySignal, ...
    referenceNoise);

% ==========================================
% RUN NLMS ANC
% ==========================================

fprintf('\nRunning NLMS ANC...\n');

[cleanedSignal, errorSignal, weights] = ...
    nlmsANC_config( ...
    noisySignal, ...
    referenceNoise, ...
    bestConfig.FilterLength, ...
    bestConfig.Mu);
% ==========================================
% ANC PERFORMANCE ANALYSIS
% ==========================================

results = ancPerformance( ...
    cleanSignal, ...
    noisySignal, ...
    cleanedSignal, ...
    Fs);

% ==========================================
% FILTER INFORMATION
% ==========================================

fprintf('\n');
fprintf('============================================\n');
fprintf('       NLMS CONFIGURATION\n');
fprintf('============================================\n');

fprintf('Filter Length : %d taps\n', ...
    bestConfig.FilterLength);

fprintf('Step Size     : %.2f\n', ...
    bestConfig.Mu);
fprintf('============================================\n');

% ==========================================
% TIME DOMAIN
% ==========================================

figure('Name','ANC Time Domain');

subplot(3,1,1);

plot(t,cleanSignal);

title('Clean Signal');
xlabel('Time (s)');
ylabel('Amplitude');

grid on;


subplot(3,1,2);

plot(t,noisySignal);

title('Noisy Signal');
xlabel('Time (s)');
ylabel('Amplitude');

grid on;


subplot(3,1,3);

plot(t,cleanedSignal);

title('NLMS ANC Output');
xlabel('Time (s)');
ylabel('Amplitude');

grid on;

% ==========================================
% FREQUENCY DOMAIN
% ==========================================

Nfft = length(noisySignal);

f = (0:Nfft-1)*(Fs/Nfft);

FFT_before = abs(fft(noisySignal));

FFT_after = abs(fft(cleanedSignal));

figure('Name','ANC Frequency Domain');

plot(f(1:Nfft/2), ...
     FFT_before(1:Nfft/2), ...
     'DisplayName','Before ANC');

hold on;

plot(f(1:Nfft/2), ...
     FFT_after(1:Nfft/2), ...
     'DisplayName','After ANC');

xlabel('Frequency (Hz)');
ylabel('Magnitude');

title('Spectrum Before vs After ANC');

legend;
grid on;

% ==========================================
% NLMS ERROR / CONVERGENCE
% ==========================================

figure('Name','NLMS Convergence');

plot(t,errorSignal);

xlabel('Time (s)');
ylabel('Error');

title('NLMS Error Signal / Convergence');

grid on;

% ==========================================
% FINAL SUMMARY
% ==========================================

fprintf('\n');
fprintf('============================================\n');
fprintf('       FINAL ANC PERFORMANCE\n');
fprintf('============================================\n');

fprintf('SNR Before ANC : %.2f dB\n', ...
    results.SNRBefore);

fprintf('SNR After ANC  : %.2f dB\n', ...
    results.SNRAfter);

fprintf('Improvement    : %.2f dB\n', ...
    results.SNRImprovement);

fprintf('Noise Reduction: %.2f %%\n', ...
    results.NoiseReduction);

fprintf('============================================\n');