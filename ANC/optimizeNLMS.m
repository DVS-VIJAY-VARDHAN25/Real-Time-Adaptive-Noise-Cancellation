clear;
clc;
close all;

% ==========================================
% GENERATE TEST SIGNAL
% ==========================================

[t, cleanSignal, referenceNoise, noise, noisySignal, Fs] = ...
    generateTestSignal();

% ==========================================
% BASELINE SNR
% ==========================================

SNR_before = 10*log10( ...
    mean(cleanSignal.^2) / mean(noise.^2));

% ==========================================
% PARAMETERS TO TEST
% ==========================================

filterLengths = [32 64 128 256];

muValues = [0.1 0.3 0.5 0.7 0.9];

results = zeros(length(filterLengths), ...
                length(muValues));

% ==========================================
% TEST DIFFERENT PARAMETERS
% ==========================================

for i = 1:length(filterLengths)

    for j = 1:length(muValues)

        filterLength = filterLengths(i);
        mu = muValues(j);

        % ----------------------------------
        % NLMS
        % ----------------------------------

        [cleanedSignal,~,~] = ...
            nlmsANC_custom( ...
            noisySignal, ...
            referenceNoise, ...
            filterLength, ...
            mu);

        % ----------------------------------
        % Calculate SNR
        % ----------------------------------

        noiseAfter = ...
            cleanedSignal - cleanSignal;

        SNR_after = 10*log10( ...
            mean(cleanSignal.^2) / ...
            mean(noiseAfter.^2));

        % ----------------------------------
        % Improvement
        % ----------------------------------

        results(i,j) = ...
            SNR_after - SNR_before;

    end

end

% ==========================================
% DISPLAY RESULTS
% ==========================================

fprintf('\n');
fprintf('============================================\n');
fprintf('       NLMS PARAMETER OPTIMIZATION\n');
fprintf('============================================\n');

fprintf('SNR Before ANC : %.2f dB\n',SNR_before);

fprintf('\nSNR Improvement (dB)\n');
fprintf('Filter Length    ');

for j = 1:length(muValues)
    fprintf('mu=%.1f       ',muValues(j));
end

fprintf('\n');

for i = 1:length(filterLengths)

    fprintf('%-17d',filterLengths(i));

    for j = 1:length(muValues)
        fprintf('%8.2f      ',results(i,j));
    end

    fprintf('\n');

end

fprintf('============================================\n');

% ==========================================
% FIND BEST PARAMETERS
% ==========================================

[bestImprovement,index] = max(results(:));

[bestI,bestJ] = ...
    ind2sub(size(results),index);

bestFilterLength = ...
    filterLengths(bestI);

bestMu = ...
    muValues(bestJ);

fprintf('\nBEST CONFIGURATION\n');
fprintf('Filter Length : %d\n',bestFilterLength);
fprintf('Mu            : %.1f\n',bestMu);
fprintf('Improvement   : %.2f dB\n',bestImprovement);
fprintf('============================================\n');

% ==========================================
% VISUALIZE
% ==========================================

figure;

imagesc(muValues,filterLengths,results);

colorbar;

xlabel('NLMS Step Size (\mu)');
ylabel('Filter Length');

title('NLMS SNR Improvement');

set(gca,'YDir','normal');