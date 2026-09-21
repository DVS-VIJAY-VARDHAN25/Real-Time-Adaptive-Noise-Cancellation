function quality = evaluateANCQuality( ...
    cleanSignal, noisySignal, cleanedSignal)

% =========================================================
% ANC QUALITY EVALUATION
% =========================================================

% Make column vectors
cleanSignal   = cleanSignal(:);
noisySignal   = noisySignal(:);
cleanedSignal = cleanedSignal(:);

% Make same length
N = min([length(cleanSignal), ...
         length(noisySignal), ...
         length(cleanedSignal)]);

cleanSignal   = cleanSignal(1:N);
noisySignal   = noisySignal(1:N);
cleanedSignal = cleanedSignal(1:N);

% =========================================================
% NOISE COMPONENTS
% =========================================================

noiseBefore = noisySignal - cleanSignal;

noiseAfter = cleanedSignal - cleanSignal;

% =========================================================
% NOISE POWER
% =========================================================

noisePowerBefore = mean(noiseBefore.^2);

noisePowerAfter = mean(noiseAfter.^2);

% Noise reduction percentage
noiseReduction = ...
    (1 - noisePowerAfter / ...
    max(noisePowerBefore, eps)) * 100;

% =========================================================
% SIGNAL PRESERVATION
% =========================================================

signalCorrelation = corr( ...
    cleanSignal, cleanedSignal);

% =========================================================
% SIGNAL DISTORTION
% =========================================================

distortion = sqrt( ...
    mean((cleanedSignal - cleanSignal).^2));

% =========================================================
% SNR
% =========================================================

SNRBefore = 10*log10( ...
    mean(cleanSignal.^2) / ...
    max(noisePowerBefore, eps));

SNRAfter = 10*log10( ...
    mean(cleanSignal.^2) / ...
    max(noisePowerAfter, eps));

SNRImprovement = ...
    SNRAfter - SNRBefore;

% =========================================================
% COMBINED QUALITY SCORE
% =========================================================

% Normalize SNR contribution
snrScore = max(0, SNRImprovement);

% Correlation contribution
correlationScore = ...
    max(0, signalCorrelation) * 20;

% Distortion penalty
distortionPenalty = ...
    distortion * 10;

% Final quality score
qualityScore = ...
    snrScore + ...
    correlationScore - ...
    distortionPenalty;

% =========================================================
% STORE RESULTS
% =========================================================

quality.NoiseReduction = noiseReduction;

quality.SignalCorrelation = signalCorrelation;

quality.Distortion = distortion;

quality.SNRBefore = SNRBefore;

quality.SNRAfter = SNRAfter;

quality.SNRImprovement = SNRImprovement;

quality.QualityScore = qualityScore;

% =========================================================
% DISPLAY RESULTS
% =========================================================

fprintf('\n');

fprintf('============================================\n');
fprintf('          ANC QUALITY EVALUATION\n');
fprintf('============================================\n');

fprintf('Noise Reduction      : %.2f %%\n', ...
    quality.NoiseReduction);

fprintf('Signal Correlation   : %.4f\n', ...
    quality.SignalCorrelation);

fprintf('Signal Distortion    : %.5f\n', ...
    quality.Distortion);

fprintf('SNR Improvement      : %.2f dB\n', ...
    quality.SNRImprovement);

fprintf('Overall Quality Score: %.2f\n', ...
    quality.QualityScore);

fprintf('============================================\n');

end