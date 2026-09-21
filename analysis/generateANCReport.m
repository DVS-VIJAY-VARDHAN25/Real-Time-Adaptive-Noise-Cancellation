function generateANCReport()

% =========================================================
% AI ADAPTIVE AUDIO - FINAL ANC REPORT
% =========================================================

clc;
close all;

fprintf('\n');
fprintf('============================================\n');
fprintf('       AI ADAPTIVE AUDIO - FINAL REPORT\n');
fprintf('============================================\n');

% =========================================================
% LOAD AUDIO FILES
% =========================================================

[originalAudio, Fs1] = audioread('original_audio.wav');

[noisyAudio, Fs2] = audioread('noisy_audio.wav');

[ancAudio, Fs3] = audioread('anc_output.wav');

% Convert stereo to mono if necessary

if size(originalAudio,2) > 1
    originalAudio = mean(originalAudio,2);
end

if size(noisyAudio,2) > 1
    noisyAudio = mean(noisyAudio,2);
end

if size(ancAudio,2) > 1
    ancAudio = mean(ancAudio,2);
end

% Check sampling frequency

if Fs1 ~= Fs2 || Fs1 ~= Fs3
    error('Audio files have different sampling frequencies.');
end

Fs = Fs1;

% =========================================================
% MAKE SIGNAL LENGTHS EQUAL
% =========================================================

N = min([length(originalAudio), ...
         length(noisyAudio), ...
         length(ancAudio)]);

originalAudio = originalAudio(1:N);
noisyAudio = noisyAudio(1:N);
ancAudio = ancAudio(1:N);

t = (0:N-1)' / Fs;

% =========================================================
% PERFORMANCE METRICS
% =========================================================

% Noise before ANC
noiseBefore = noisyAudio - originalAudio;

% Residual noise after ANC
noiseAfter = ancAudio - originalAudio;

% RMS values
originalRMS = sqrt(mean(originalAudio.^2));

noisyRMS = sqrt(mean(noisyAudio.^2));

ancRMS = sqrt(mean(ancAudio.^2));

noiseRMSBefore = sqrt(mean(noiseBefore.^2));

noiseRMSAfter = sqrt(mean(noiseAfter.^2));

% SNR
SNRBefore = 10 * log10( ...
    mean(originalAudio.^2) / ...
    (mean(noiseBefore.^2) + eps));

SNRAfter = 10 * log10( ...
    mean(originalAudio.^2) / ...
    (mean(noiseAfter.^2) + eps));

SNRImprovement = SNRAfter - SNRBefore;

% Noise reduction
noiseReduction = ...
    (1 - mean(noiseAfter.^2) / ...
    (mean(noiseBefore.^2) + eps)) * 100;

% Signal correlation
signalCorrelation = corr( ...
    originalAudio, ancAudio);

% Signal distortion
distortion = sqrt( ...
    mean((ancAudio - originalAudio).^2));

% =========================================================
% DISPLAY FINAL RESULTS
% =========================================================

fprintf('\n');
fprintf('============================================\n');
fprintf('          FINAL ANC PERFORMANCE\n');
fprintf('============================================\n');

fprintf('Sampling Frequency : %d Hz\n', Fs);

fprintf('Samples            : %d\n', N);

fprintf('\n');

fprintf('Original RMS       : %.5f\n', originalRMS);

fprintf('Noisy RMS          : %.5f\n', noisyRMS);

fprintf('ANC Output RMS     : %.5f\n', ancRMS);

fprintf('\n');

fprintf('Noise RMS Before   : %.5f\n', noiseRMSBefore);

fprintf('Noise RMS After    : %.5f\n', noiseRMSAfter);

fprintf('Noise Reduction    : %.2f %%\n', noiseReduction);

fprintf('\n');

fprintf('SNR Before ANC     : %.2f dB\n', SNRBefore);

fprintf('SNR After ANC      : %.2f dB\n', SNRAfter);

fprintf('SNR Improvement    : %.2f dB\n', SNRImprovement);

fprintf('\n');

fprintf('Signal Correlation : %.4f\n', signalCorrelation);

fprintf('Signal Distortion  : %.5f\n', distortion);

fprintf('============================================\n');

% =========================================================
% TIME DOMAIN COMPARISON
% =========================================================

figure('Name','ANC Time Domain Comparison');

subplot(3,1,1);

plot(t, originalAudio);

title('Original Audio');

xlabel('Time (s)');
ylabel('Amplitude');

grid on;


subplot(3,1,2);

plot(t, noisyAudio);

title('Noisy Audio');

xlabel('Time (s)');
ylabel('Amplitude');

grid on;


subplot(3,1,3);

plot(t, ancAudio);

title('NLMS ANC Output');

xlabel('Time (s)');
ylabel('Amplitude');

grid on;

sgtitle('AI Adaptive Audio - Time Domain Comparison');

% =========================================================
% FREQUENCY DOMAIN COMPARISON
% =========================================================

NFFT = N;

f = (0:NFFT/2-1) * Fs / NFFT;

originalFFT = abs(fft(originalAudio));
noisyFFT = abs(fft(noisyAudio));
ancFFT = abs(fft(ancAudio));

maxValue = max([max(originalFFT), ...
                max(noisyFFT), ...
                max(ancFFT)]) + eps;
originalFFT = originalFFT(1:NFFT/2);
noisyFFT = noisyFFT(1:NFFT/2);
ancFFT = ancFFT(1:NFFT/2);

% Normalize

originalFFT = originalFFT / ...
    (max(originalFFT) + eps);

noisyFFT = noisyFFT / ...
    (max(noisyFFT) + eps);

ancFFT = ancFFT / ...
    (max(ancFFT) + eps);

figure('Name','ANC Frequency Comparison');

plot(f, originalFFT, ...
    'DisplayName','Original Audio');

hold on;

plot(f, noisyFFT, ...
    'DisplayName','Noisy Audio');

plot(f, ancFFT, ...
    'DisplayName','ANC Output');

xlabel('Frequency (Hz)');
ylabel('Normalized Magnitude');

title('Frequency Spectrum Comparison');

legend;

grid on;

xlim([0 Fs/2]);

% =========================================================
% SAVE FIGURES
% =========================================================

saveas(figure(1), ...
    'ANC_TimeDomain_Comparison.png');

saveas(figure(2), ...
    'ANC_Frequency_Comparison.png');

fprintf('\n');
fprintf('Figures saved successfully:\n');
fprintf('ANC_TimeDomain_Comparison.png\n');
fprintf('ANC_Frequency_Comparison.png\n');

fprintf('============================================\n');

end