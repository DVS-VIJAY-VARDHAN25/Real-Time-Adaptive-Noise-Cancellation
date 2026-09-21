function results = ancPerformance(cleanSignal, noisySignal, cleanedSignal, Fs)

% =========================================================
% ANC PERFORMANCE ANALYSIS
% =========================================================

cleanSignal   = cleanSignal(:);
noisySignal   = noisySignal(:);
cleanedSignal = cleanedSignal(:);

% Make all signals the same length
N = min([length(cleanSignal), ...
         length(noisySignal), ...
         length(cleanedSignal)]);

cleanSignal   = cleanSignal(1:N);
noisySignal   = noisySignal(1:N);
cleanedSignal = cleanedSignal(1:N);

% =========================================================
% NOISE SIGNALS
% =========================================================

noiseBefore = noisySignal - cleanSignal;
noiseAfter  = cleanedSignal - cleanSignal;

% =========================================================
% SNR CALCULATION
% =========================================================

signalPower = mean(cleanSignal.^2);

noisePowerBefore = mean(noiseBefore.^2);
noisePowerAfter  = mean(noiseAfter.^2);

SNRBefore = 10*log10( ...
    signalPower / max(noisePowerBefore,eps));

SNRAfter = 10*log10( ...
    signalPower / max(noisePowerAfter,eps));

SNRImprovement = SNRAfter - SNRBefore;

% =========================================================
% RMS
% =========================================================

inputRMS = sqrt(mean(noisySignal.^2));

outputRMS = sqrt(mean(cleanedSignal.^2));

noiseRMSBefore = sqrt(mean(noiseBefore.^2));

noiseRMSAfter = sqrt(mean(noiseAfter.^2));

% =========================================================
% NOISE REDUCTION
% =========================================================

noiseReduction = ...
    100 * (1 - ...
    noiseRMSAfter / max(noiseRMSBefore,eps));

% Limit display range
noiseReduction = max(0,min(100,noiseReduction));

% =========================================================
% TIME VECTOR
% =========================================================

t = (0:N-1)' / Fs;

% =========================================================
% DISPLAY RESULTS
% =========================================================

fprintf('\n');
fprintf('============================================\n');
fprintf('       ANC PERFORMANCE ANALYSIS\n');
fprintf('============================================\n');

fprintf('Sampling Frequency : %d Hz\n',Fs);
fprintf('Samples             : %d\n',N);

fprintf('\n');

fprintf('SNR Before ANC      : %.2f dB\n',SNRBefore);
fprintf('SNR After ANC       : %.2f dB\n',SNRAfter);
fprintf('SNR Improvement     : %.2f dB\n',SNRImprovement);

fprintf('\n');

fprintf('Input RMS           : %.4f\n',inputRMS);
fprintf('Output RMS          : %.4f\n',outputRMS);

fprintf('\n');

fprintf('Noise RMS Before    : %.4f\n',noiseRMSBefore);
fprintf('Noise RMS After     : %.4f\n',noiseRMSAfter);

fprintf('Noise Reduction     : %.2f %%\n',noiseReduction);

fprintf('============================================\n');

% =========================================================
% PLOT 1 - CLEAN VS NOISY
% =========================================================

figure('Name','ANC Performance - Input');

plot(t,cleanSignal,'LineWidth',1);
hold on;
plot(t,noisySignal,'LineWidth',1);

grid on;

xlabel('Time (seconds)');
ylabel('Amplitude');

title('Clean Signal vs Noisy Signal');

legend('Clean Signal','Noisy Signal');

% =========================================================
% PLOT 2 - NOISY VS CLEANED
% =========================================================

figure('Name','ANC Performance - Output');

plot(t,noisySignal,'LineWidth',1);
hold on;
plot(t,cleanedSignal,'LineWidth',1);

grid on;

xlabel('Time (seconds)');
ylabel('Amplitude');

title('Noisy Signal vs ANC Output');

legend('Noisy Signal','ANC Output');

% =========================================================
% PLOT 3 - NOISE BEFORE AND AFTER
% =========================================================

figure('Name','ANC Noise Reduction');

plot(t,noiseBefore,'LineWidth',1);
hold on;
plot(t,noiseAfter,'LineWidth',1);

grid on;

xlabel('Time (seconds)');
ylabel('Amplitude');

title('Noise Before and After ANC');

legend('Noise Before ANC','Noise After ANC');

% =========================================================
% RETURN RESULTS
% =========================================================

results.SNRBefore = SNRBefore;
results.SNRAfter = SNRAfter;
results.SNRImprovement = SNRImprovement;

results.InputRMS = inputRMS;
results.OutputRMS = outputRMS;

results.NoiseRMSBefore = noiseRMSBefore;
results.NoiseRMSAfter = noiseRMSAfter;

results.NoiseReduction = noiseReduction;

end