function bestConfig = optimizeANC( ...
    cleanSignal, noisySignal, referenceNoise)

% =========================================================
% AUTOMATIC NLMS PARAMETER OPTIMIZATION
% =========================================================

cleanSignal = cleanSignal(:);
noisySignal = noisySignal(:);
referenceNoise = referenceNoise(:);

% ---------------------------------------------------------
% PARAMETERS TO TEST
% ---------------------------------------------------------

filterLengths = [32 64 128 256];

muValues = [0.05 0.1 0.2 0.3 0.5];

% ---------------------------------------------------------
% SNR BEFORE ANC
% ---------------------------------------------------------

noiseBefore = noisySignal - cleanSignal;

SNRBefore = 10*log10( ...
    mean(cleanSignal.^2) / ...
    max(mean(noiseBefore.^2),eps));

% ---------------------------------------------------------
% STORAGE
% ---------------------------------------------------------

numTests = ...
    length(filterLengths) * length(muValues);

results = zeros(numTests,3);

testIndex = 1;

% ---------------------------------------------------------
% DISPLAY
% ---------------------------------------------------------

fprintf('\n');
fprintf('============================================\n');
fprintf('       AUTOMATIC NLMS OPTIMIZATION\n');
fprintf('============================================\n');

fprintf('SNR Before ANC : %.2f dB\n',SNRBefore);

fprintf('\n');

fprintf('%-15s %-12s %-15s\n', ...
    'Filter Length','Mu','SNR Improvement');

fprintf('--------------------------------------------\n');

% ---------------------------------------------------------
% TEST ALL CONFIGURATIONS
% ---------------------------------------------------------

for i = 1:length(filterLengths)

    for j = 1:length(muValues)

        filterLength = filterLengths(i);
        mu = muValues(j);

        % ---------------------------------------------
        % Run NLMS with current configuration
        % ---------------------------------------------

        [cleanedSignal,~,~] = ...
            nlmsANC_config( ...
            noisySignal, ...
            referenceNoise, ...
            filterLength, ...
            mu);

        % ---------------------------------------------
        % Calculate SNR after ANC
        % ---------------------------------------------

        noiseAfter = ...
            cleanedSignal - cleanSignal;

        SNRAfter = 10*log10( ...
            mean(cleanSignal.^2) / ...
            max(mean(noiseAfter.^2),eps));

        improvement = ...
            SNRAfter - SNRBefore;

        % ---------------------------------------------
        % Store result
        % ---------------------------------------------

        results(testIndex,1) = filterLength;
        results(testIndex,2) = mu;
        results(testIndex,3) = improvement;

        fprintf('%-15d %-12.2f %-15.2f dB\n', ...
            filterLength,mu,improvement);

        testIndex = testIndex + 1;

    end

end

% ---------------------------------------------------------
% FIND BEST CONFIGURATION
% ---------------------------------------------------------

[bestImprovement,bestIndex] = ...
    max(results(:,3));

bestFilterLength = ...
    results(bestIndex,1);

bestMu = ...
    results(bestIndex,2);

% ---------------------------------------------------------
% DISPLAY BEST CONFIGURATION
% ---------------------------------------------------------

fprintf('\n');
fprintf('============================================\n');
fprintf('       BEST NLMS CONFIGURATION\n');
fprintf('============================================\n');

fprintf('Filter Length : %d taps\n', ...
    bestFilterLength);

fprintf('Step Size     : %.2f\n', ...
    bestMu);

fprintf('SNR Improvement : %.2f dB\n', ...
    bestImprovement);

fprintf('============================================\n');

% ---------------------------------------------------------
% RETURN STRUCT
% ---------------------------------------------------------

bestConfig.FilterLength = bestFilterLength;
bestConfig.Mu = bestMu;
bestConfig.SNRImprovement = bestImprovement;
bestConfig.SNRBefore = SNRBefore;

bestConfig.AllResults = results;

end