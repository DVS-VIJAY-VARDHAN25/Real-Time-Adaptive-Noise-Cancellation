function processRealAudio()

% ==========================================
% REAL AUDIO → NLMS ANC
% ==========================================

clc;
close all;
projectRoot = fileparts(fileparts(mfilename('fullpath')));

addpath(genpath(projectRoot));
fprintf('\n');
fprintf('============================================\n');
fprintf('       REAL AUDIO ANC TEST\n');
fprintf('============================================\n');

% ------------------------------------------
% RECORD AUDIO
% ------------------------------------------

duration = 5;

[audioData, Fs] = recordAudio(duration);

% ------------------------------------------
% CREATE REFERENCE NOISE
% ------------------------------------------
%
% For this first real-audio experiment,
% create a controlled noise reference.
%
% Later we will replace this with a real
% reference microphone.

t = (0:length(audioData)-1)' / Fs;

referenceNoise = ...
    0.3*sin(2*pi*80*t) + ...
    0.2*sin(2*pi*120*t);

% ------------------------------------------
% CREATE TEST NOISY SIGNAL
% ------------------------------------------

noise = referenceNoise + ...
        0.03*randn(size(t));

noisySignal = ...
    audioData + noise;

% Normalize
noisySignal = ...
    noisySignal ./ ...
    (max(abs(noisySignal)) + eps);

% ------------------------------------------
% RUN NLMS ANC
% ------------------------------------------

fprintf('\nRunning NLMS ANC...\n');
% ==========================================
% AUTOMATIC REAL-AUDIO OPTIMIZATION
% ==========================================

fprintf('\n');
fprintf('Optimizing NLMS parameters for real audio...\n');

bestConfig = optimizeRealANC( ...
    audioData, ...
    noisySignal, ...
    referenceNoise);

fprintf('\n');
fprintf('Selected Configuration:\n');

fprintf('Filter Length : %d taps\n', ...
    bestConfig.FilterLength);

fprintf('Step Size     : %.2f\n', ...
    bestConfig.Mu);

fprintf('RMS Reduction : %.2f %%\n', ...
    bestConfig.RMSReduction);
% ==========================================
% RUN OPTIMIZED ANC
% ==========================================

[cleanedSignal,errorSignal,weights] = ...
    nlmsANC_config( ...
    noisySignal, ...
    referenceNoise, ...
    bestConfig.FilterLength, ...
    bestConfig.Mu);

% ==========================================
% ANC QUALITY EVALUATION
% ==========================================

quality = evaluateANCQuality( ...
    audioData, ...
    noisySignal, ...
    cleanedSignal);
% ------------------------------------------
% SNR
% ------------------------------------------

noiseBefore = noisySignal - audioData;

noiseAfter = cleanedSignal - audioData;

SNR_before = ...
    10*log10(mean(audioData.^2) / ...
    (mean(noiseBefore.^2) + eps));

SNR_after = ...
    10*log10(mean(audioData.^2) / ...
    (mean(noiseAfter.^2) + eps));

improvement = ...
    SNR_after - SNR_before;
% ==========================================
% FREQUENCY DOMAIN ANALYSIS
% ==========================================

Nfft = length(noisySignal);

f = (0:Nfft-1)*(Fs/Nfft);

FFT_before = abs(fft(noisySignal));
FFT_after  = abs(fft(cleanedSignal));

% Normalize FFT
FFT_before = FFT_before / max(FFT_before);
FFT_after  = FFT_after / max(FFT_after);

% ==========================================
% PLOT SPECTRUM
% ==========================================

figure('Name','Real Audio ANC Spectrum');

plot(f(1:Nfft/2), ...
     FFT_before(1:Nfft/2), ...
     'DisplayName','Before ANC');

hold on;

plot(f(1:Nfft/2), ...
     FFT_after(1:Nfft/2), ...
     'DisplayName','After ANC');

xlabel('Frequency (Hz)');
ylabel('Normalized Magnitude');

title('Real Audio Spectrum Before vs After ANC');

legend;
grid on;
% ==========================================
% NLMS CONVERGENCE
% ==========================================

figure('Name','Real Audio NLMS Convergence');

plot(t,errorSignal);

xlabel('Time (s)');
ylabel('Error');

title('NLMS Error Signal');

grid on;
% ------------------------------------------
% DISPLAY RESULTS
% ------------------------------------------

fprintf('\n');
fprintf('============================================\n');
fprintf('       REAL AUDIO ANC PERFORMANCE\n');
fprintf('============================================\n');

fprintf('SNR Before ANC : %.2f dB\n',SNR_before);
fprintf('SNR After ANC  : %.2f dB\n',SNR_after);
fprintf('Improvement    : %.2f dB\n',improvement);

fprintf('============================================\n');

% ------------------------------------------
% TIME DOMAIN
% ------------------------------------------

figure('Name','Real Audio ANC');

subplot(3,1,1);

plot(t,audioData);

title('Original Microphone Audio');

xlabel('Time (s)');
ylabel('Amplitude');

grid on;


subplot(3,1,2);

plot(t,noisySignal);

title('Microphone Audio + Added Noise');

xlabel('Time (s)');
ylabel('Amplitude');

grid on;


subplot(3,1,3);

plot(t,cleanedSignal);

title('NLMS ANC Output');

xlabel('Time (s)');
ylabel('Amplitude');

grid on;

% ------------------------------------------
% PLAY ORIGINAL
% ------------------------------------------

fprintf('\nPlaying original recording...\n');

sound(audioData,Fs);

pause(duration + 1);

% ------------------------------------------
% PLAY ANC OUTPUT
% ------------------------------------------

fprintf('Playing ANC output...\n');

sound(cleanedSignal,Fs);
% ==========================================
% SAVE AUDIO RESULTS
% ==========================================

audiowrite('original_audio.wav', audioData, Fs);

audiowrite('noisy_audio.wav', noisySignal, Fs);

audiowrite('anc_output.wav', cleanedSignal, Fs);

fprintf('\n');
fprintf('Audio files saved successfully:\n');
fprintf('1. original_audio.wav\n');
fprintf('2. noisy_audio.wav\n');
fprintf('3. anc_output.wav\n');
end