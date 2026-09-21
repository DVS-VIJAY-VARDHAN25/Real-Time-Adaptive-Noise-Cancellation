function bestConfig = optimizeRealANC( ...
    cleanSignal, noisySignal, referenceNoise)

% =========================================================
% REAL AUDIO QUALITY-BASED NLMS OPTIMIZATION
% =========================================================

% Convert to column vectors
cleanSignal = cleanSignal(:);
noisySignal = noisySignal(:);
referenceNoise = referenceNoise(:);

% =========================================================
% PARAMETERS TO TEST
% =========================================================

filterLengths = [32 64 128 256];

muValues = [0.01 0.02 0.05 0.08 0.10 0.20];

% =========================================================
% INITIALIZE BEST CONFIGURATION
% =========================================================

bestScore = -inf;

bestConfig.FilterLength = 64;
bestConfig.Mu = 0.05;

bestConfig.SNRImprovement = -inf;
bestConfig.Correlation = 0;
bestConfig.Distortion = inf;

bestConfig.RMSReduction = 0;

bestConfig.Score = -inf;

% =========================================================
% DISPLAY HEADER
% =========================================================

fprintf('\n');

fprintf('============================================\n');
fprintf(' REAL AUDIO QUALITY-BASED NLMS OPTIMIZATION\n');
fprintf('============================================\n\n');

fprintf(['Filter   Mu      SNR Gain    Correlation   ' ...
         'Distortion   RMS Red.     Score\n']);

fprintf('--------------------------------------------------------------------------\n');

% =========================================================
% TEST ALL CONFIGURATIONS
% =========================================================

for i = 1:length(filterLengths)

    filterLength = filterLengths(i);

    for j = 1:length(muValues)

        mu = muValues(j);

        % =================================================
        % RUN NLMS ANC
        % =================================================

        [cleanedSignal, ~, ~] = ...
            nlmsANC_config( ...
            noisySignal, ...
            referenceNoise, ...
            filterLength, ...
            mu);

        cleanedSignal = cleanedSignal(:);

        % =================================================
        % NOISE BEFORE ANC
        % =================================================

        noiseBefore = ...
            noisySignal - cleanSignal;

        % =================================================
        % NOISE AFTER ANC
        % =================================================

        noiseAfter = ...
            cleanedSignal - cleanSignal;

        % =================================================
        % SNR CALCULATION
        % =================================================

        SNR_before = 10 * log10( ...
            mean(cleanSignal.^2) / ...
            (mean(noiseBefore.^2) + eps));

        SNR_after = 10 * log10( ...
            mean(cleanSignal.^2) / ...
            (mean(noiseAfter.^2) + eps));

        SNR_improvement = ...
            SNR_after - SNR_before;

        % =================================================
        % SIGNAL CORRELATION
        % =================================================

        signalCorrelation = corr( ...
            cleanSignal, ...
            cleanedSignal);

        % Protect against NaN
        if isnan(signalCorrelation)
            signalCorrelation = 0;
        end

        % =================================================
        % SIGNAL DISTORTION
        % =================================================

        distortion = sqrt( ...
            mean( ...
            (cleanedSignal - cleanSignal).^2));

        % =================================================
        % RMS REDUCTION
        % =================================================

        inputRMS = sqrt( ...
            mean(noisySignal.^2));

        outputRMS = sqrt( ...
            mean(cleanedSignal.^2));

        RMSReduction = ...
            (1 - outputRMS / ...
            (inputRMS + eps)) * 100;

        % =================================================
        % QUALITY SCORE
        %
        % Goal:
        % High SNR improvement
        % High signal correlation
        % Low distortion
        % =================================================

        score = ...
            SNR_improvement + ...
            10 * signalCorrelation - ...
            10 * distortion;

        % =================================================
        % DISPLAY CURRENT RESULT
        % =================================================

        fprintf( ...
            '%-8d %-7.2f %-11.2f %-13.4f %-12.5f %-12.2f %.2f\n', ...
            filterLength, ...
            mu, ...
            SNR_improvement, ...
            signalCorrelation, ...
            distortion, ...
            RMSReduction, ...
            score);

        % =================================================
        % CHECK FOR BEST CONFIGURATION
        % =================================================

        if score > bestScore

            bestScore = score;

            bestConfig.FilterLength = ...
                filterLength;

            bestConfig.Mu = ...
                mu;

            bestConfig.SNRImprovement = ...
                SNR_improvement;

            bestConfig.Correlation = ...
                signalCorrelation;

            bestConfig.Distortion = ...
                distortion;

            bestConfig.RMSReduction = ...
                RMSReduction;

            bestConfig.InputRMS = ...
                inputRMS;

            bestConfig.OutputRMS = ...
                outputRMS;

            bestConfig.Score = ...
                score;

        end

    end

end

% =========================================================
% DISPLAY BEST CONFIGURATION
% =========================================================

fprintf('\n');

fprintf('============================================\n');
fprintf(' BEST QUALITY-BASED CONFIGURATION\n');
fprintf('============================================\n');

fprintf('Filter Length   : %d taps\n', ...
    bestConfig.FilterLength);

fprintf('Step Size       : %.2f\n', ...
    bestConfig.Mu);

fprintf('SNR Improvement : %.2f dB\n', ...
    bestConfig.SNRImprovement);

fprintf('Correlation     : %.4f\n', ...
    bestConfig.Correlation);

fprintf('Distortion      : %.5f\n', ...
    bestConfig.Distortion);

fprintf('Input RMS       : %.5f\n', ...
    bestConfig.InputRMS);

fprintf('Output RMS      : %.5f\n', ...
    bestConfig.OutputRMS);

fprintf('RMS Reduction   : %.2f %%\n', ...
    bestConfig.RMSReduction);

fprintf('Quality Score   : %.2f\n', ...
    bestConfig.Score);

fprintf('============================================\n');

end

