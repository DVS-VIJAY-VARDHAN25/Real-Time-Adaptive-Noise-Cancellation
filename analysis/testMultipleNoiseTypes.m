function testMultipleNoiseTypes()

% =========================================================
% AI ADAPTIVE AUDIO
% MULTIPLE NOISE TYPE ANC BENCHMARK
% =========================================================

clc;
close all;

fprintf('\n');
fprintf('====================================================\n');
fprintf('       AI ADAPTIVE AUDIO - NOISE BENCHMARK\n');
fprintf('====================================================\n');

% =========================================================
% PROJECT PATH
% =========================================================

projectRoot = fileparts(fileparts(mfilename('fullpath')));

addpath(genpath(projectRoot));

% =========================================================
% LOAD ORIGINAL AUDIO
% =========================================================

audioFile = fullfile( ...
    projectRoot, ...
    'audio', ...
    'original_audio.wav');

% If file is not inside audio folder, try project root
if ~isfile(audioFile)

    audioFile = fullfile( ...
        projectRoot, ...
        'original_audio.wav');

end

if ~isfile(audioFile)

    error(['original_audio.wav not found. ' ...
           'Please check the file location.']);

end

[cleanSignal, Fs] = audioread(audioFile);

% Convert stereo to mono
if size(cleanSignal,2) > 1

    cleanSignal = mean(cleanSignal,2);

end

cleanSignal = cleanSignal(:);

% Normalize
cleanSignal = cleanSignal / ...
    (max(abs(cleanSignal)) + eps);

N = length(cleanSignal);

t = (0:N-1)' / Fs;

fprintf('Sampling Frequency : %d Hz\n', Fs);
fprintf('Samples            : %d\n', N);
fprintf('Duration           : %.2f seconds\n', N/Fs);

% =========================================================
% DEFINE NOISE TYPES
% =========================================================

noiseNames = { ...
    'Single Tone'; ...
    'Multi Tone'; ...
    'White Noise'; ...
    'Changing Amplitude'; ...
    'Changing Frequency'};

numTests = length(noiseNames);

% Storage
results = cell(numTests, 8);

snrImprovementValues = zeros(numTests,1);

noiseReductionValues = zeros(numTests,1);

correlationValues = zeros(numTests,1);

% =========================================================
% CREATE RESULTS FOLDER
% =========================================================

resultsFolder = fullfile( ...
    projectRoot, ...
    'results');

if ~exist(resultsFolder,'dir')

    mkdir(resultsFolder);

end

% =========================================================
% TEST EACH NOISE TYPE
% =========================================================

for k = 1:numTests

    fprintf('\n');
    fprintf('====================================================\n');
    fprintf('TEST %d OF %d\n', k, numTests);
    fprintf('Noise Type : %s\n', noiseNames{k});
    fprintf('====================================================\n');

    % -----------------------------------------------------
    % CREATE NOISE
    % -----------------------------------------------------

    switch k

        % =================================================
        % 1. SINGLE TONE NOISE
        % =================================================

        case 1

            referenceNoise = ...
                0.35 * sin(2*pi*100*t);

            noise = ...
                referenceNoise + ...
                0.02*randn(N,1);


        % =================================================
        % 2. MULTI TONE NOISE
        % =================================================

        case 2

            referenceNoise = ...
                0.25*sin(2*pi*80*t) + ...
                0.20*sin(2*pi*150*t) + ...
                0.15*sin(2*pi*300*t);

            noise = ...
                referenceNoise + ...
                0.02*randn(N,1);


        % =================================================
        % 3. WHITE NOISE
        % =================================================

        case 3

            referenceNoise = ...
                0.30*randn(N,1);

            noise = referenceNoise;


        % =================================================
        % 4. CHANGING AMPLITUDE NOISE
        % =================================================

        case 4

            amplitudeEnvelope = ...
                0.10 + ...
                0.35*(t / max(t));

            referenceNoise = ...
                amplitudeEnvelope .* ...
                sin(2*pi*120*t);

            noise = ...
                referenceNoise + ...
                0.02*randn(N,1);


        % =================================================
        % 5. CHANGING FREQUENCY NOISE
        % =================================================

        case 5

            startFrequency = 50;

            endFrequency = 500;

            duration = max(t);

            instantaneousFrequency = ...
                startFrequency + ...
                (endFrequency - startFrequency) ...
                .* (t / duration);

            phase = ...
                2*pi*cumsum(instantaneousFrequency) / Fs;

            referenceNoise = ...
                0.30*sin(phase);

            noise = ...
                referenceNoise + ...
                0.02*randn(N,1);

    end

    % -----------------------------------------------------
    % CREATE NOISY SIGNAL
    % -----------------------------------------------------

    noisySignal = cleanSignal + noise;

    % -----------------------------------------------------
    % NORMALIZE SIGNALS TO SAME SCALE
    % -----------------------------------------------------

    scaleFactor = max(abs(noisySignal)) + eps;

    noisySignal = ...
        noisySignal / scaleFactor;

    cleanTest = ...
        cleanSignal / scaleFactor;

    referenceNoise = ...
        referenceNoise / scaleFactor;

    % =====================================================
    % OPTIMIZE ANC PARAMETERS
    % =====================================================

    fprintf('\nOptimizing ANC parameters...\n');

    bestConfig = optimizeRealANC( ...
        cleanTest, ...
        noisySignal, ...
        referenceNoise);

    fprintf('\nSelected Configuration:\n');

    fprintf('Filter Length : %d taps\n', ...
        bestConfig.FilterLength);

    fprintf('Step Size     : %.4f\n', ...
        bestConfig.Mu);

    % =====================================================
    % RUN FINAL ANC
    % =====================================================

    fprintf('\nRunning optimized NLMS ANC...\n');

    [cleanedSignal, errorSignal, weights] = ...
        nlmsANC_config( ...
        noisySignal, ...
        referenceNoise, ...
        bestConfig.FilterLength, ...
        bestConfig.Mu);

    % Ensure column vectors
    cleanedSignal = cleanedSignal(:);

    % =====================================================
    % PERFORMANCE CALCULATIONS
    % =====================================================

    noiseBefore = ...
        noisySignal - cleanTest;

    noiseAfter = ...
        cleanedSignal - cleanTest;

    % SNR BEFORE
    SNRBefore = 10*log10( ...
        mean(cleanTest.^2) / ...
        (mean(noiseBefore.^2) + eps));

    % SNR AFTER
    SNRAfter = 10*log10( ...
        mean(cleanTest.^2) / ...
        (mean(noiseAfter.^2) + eps));

    % SNR IMPROVEMENT
    SNRImprovement = ...
        SNRAfter - SNRBefore;

    % NOISE REDUCTION
    noiseReduction = ...
        (1 - ...
        mean(noiseAfter.^2) / ...
        (mean(noiseBefore.^2) + eps)) * 100;

    % SIGNAL CORRELATION
    signalCorrelation = corr( ...
        cleanTest, ...
        cleanedSignal);

    % DISTORTION
    distortion = sqrt( ...
        mean( ...
        (cleanedSignal - cleanTest).^2));

    % =====================================================
    % STORE RESULTS
    % =====================================================

    results{k,1} = noiseNames{k};

    results{k,2} = ...
        bestConfig.FilterLength;

    results{k,3} = ...
        bestConfig.Mu;

    results{k,4} = ...
        SNRBefore;

    results{k,5} = ...
        SNRAfter;

    results{k,6} = ...
        SNRImprovement;

    results{k,7} = ...
        noiseReduction;

    results{k,8} = ...
        signalCorrelation;

    snrImprovementValues(k) = ...
        SNRImprovement;

    noiseReductionValues(k) = ...
        noiseReduction;

    correlationValues(k) = ...
        signalCorrelation;

    % =====================================================
    % DISPLAY RESULT
    % =====================================================

    fprintf('\n');
    fprintf('----------------------------------------------\n');
    fprintf('RESULT: %s\n', noiseNames{k});
    fprintf('----------------------------------------------\n');

    fprintf('SNR Before       : %.2f dB\n', ...
        SNRBefore);

    fprintf('SNR After        : %.2f dB\n', ...
        SNRAfter);

    fprintf('SNR Improvement  : %.2f dB\n', ...
        SNRImprovement);

    fprintf('Noise Reduction  : %.2f %%\n', ...
        noiseReduction);

    fprintf('Correlation      : %.4f\n', ...
        signalCorrelation);

    fprintf('Distortion       : %.5f\n', ...
        distortion);

    fprintf('----------------------------------------------\n');

end

% =========================================================
% CREATE RESULTS TABLE
% =========================================================

ResultsTable = cell2table( ...
    results, ...
    'VariableNames', { ...
    'NoiseType', ...
    'FilterLength', ...
    'StepSize', ...
    'SNRBefore_dB', ...
    'SNRAfter_dB', ...
    'SNRImprovement_dB', ...
    'NoiseReduction_percent', ...
    'SignalCorrelation'});

% =========================================================
% DISPLAY TABLE
% =========================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('              FINAL BENCHMARK RESULTS\n');
fprintf('====================================================\n');

disp(ResultsTable);

% =========================================================
% SAVE RESULTS
% =========================================================

csvFile = fullfile( ...
    resultsFolder, ...
    'ANC_Noise_Benchmark_Results.csv');

writetable( ...
    ResultsTable, ...
    csvFile);

fprintf('\nResults saved to:\n');
fprintf('%s\n', csvFile);

% =========================================================
% FIND BEST SNR RESULT
% =========================================================

[bestSNRImprovement, bestIndex] = ...
    max(snrImprovementValues);

fprintf('\n');
fprintf('====================================================\n');
fprintf('              BEST ANC PERFORMANCE\n');
fprintf('====================================================\n');

fprintf('Best Noise Type : %s\n', ...
    noiseNames{bestIndex});

fprintf('SNR Improvement : %.2f dB\n', ...
    bestSNRImprovement);

fprintf('Noise Reduction : %.2f %%\n', ...
    noiseReductionValues(bestIndex));

fprintf('Correlation     : %.4f\n', ...
    correlationValues(bestIndex));

fprintf('====================================================\n');

% =========================================================
% CHART 1 - SNR IMPROVEMENT
% =========================================================

figure( ...
    'Name', ...
    'ANC Noise Benchmark - SNR Improvement');

bar(snrImprovementValues);

set(gca, ...
    'XTickLabel', noiseNames);

xtickangle(25);

ylabel('SNR Improvement (dB)');

title( ...
    'ANC Performance Across Different Noise Types');

grid on;

% Add values above bars
for i = 1:numTests

    text( ...
        i, ...
        snrImprovementValues(i), ...
        sprintf('%.2f dB', ...
        snrImprovementValues(i)), ...
        'HorizontalAlignment', ...
        'center', ...
        'VerticalAlignment', ...
        'bottom');

end

saveas( ...
    gcf, ...
    fullfile( ...
    resultsFolder, ...
    'ANC_SNR_Benchmark.png'));

% =========================================================
% CHART 2 - NOISE REDUCTION
% =========================================================

figure( ...
    'Name', ...
    'ANC Noise Benchmark - Noise Reduction');

bar(noiseReductionValues);

set(gca, ...
    'XTickLabel', noiseNames);

xtickangle(25);

ylabel('Noise Reduction (%)');

title( ...
    'Noise Reduction Across Different Noise Types');

grid on;

for i = 1:numTests

    text( ...
        i, ...
        noiseReductionValues(i), ...
        sprintf('%.1f%%', ...
        noiseReductionValues(i)), ...
        'HorizontalAlignment', ...
        'center', ...
        'VerticalAlignment', ...
        'bottom');

end

saveas( ...
    gcf, ...
    fullfile( ...
    resultsFolder, ...
    'ANC_Noise_Reduction_Benchmark.png'));

% =========================================================
% CHART 3 - SIGNAL CORRELATION
% =========================================================

figure( ...
    'Name', ...
    'ANC Noise Benchmark - Signal Correlation');

bar(correlationValues);

set(gca, ...
    'XTickLabel', noiseNames);

xtickangle(25);

ylabel('Signal Correlation');

ylim([0 1.1]);

title( ...
    'Signal Preservation Across Different Noise Types');

grid on;

for i = 1:numTests

    text( ...
        i, ...
        correlationValues(i), ...
        sprintf('%.3f', ...
        correlationValues(i)), ...
        'HorizontalAlignment', ...
        'center', ...
        'VerticalAlignment', ...
        'bottom');

end

saveas( ...
    gcf, ...
    fullfile( ...
    resultsFolder, ...
    'ANC_Signal_Correlation_Benchmark.png'));

% =========================================================
% FINAL MESSAGE
% =========================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('       MULTIPLE NOISE TEST COMPLETED SUCCESSFULLY\n');
fprintf('====================================================\n');

fprintf('Generated Files:\n');

fprintf('1. ANC_Noise_Benchmark_Results.csv\n');

fprintf('2. ANC_SNR_Benchmark.png\n');

fprintf('3. ANC_Noise_Reduction_Benchmark.png\n');

fprintf('4. ANC_Signal_Correlation_Benchmark.png\n');

fprintf('====================================================\n');

end