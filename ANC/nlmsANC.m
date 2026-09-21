function [outputSignal, errorSignal, weights] = nlmsANC( ...
    noisySignal, referenceNoise)

% =========================================================
% NLMS ADAPTIVE NOISE CANCELLATION
% =========================================================

% Filter parameters
filterLength = 64;

mu = 0.1;

epsilon = 1e-8;

% Number of samples
N = length(noisySignal);

% Make sure signals are column vectors
noisySignal = noisySignal(:);
referenceNoise = referenceNoise(:);

% Initialize adaptive filter
weights = zeros(filterLength,1);

% Initialize output
outputSignal = zeros(N,1);

% Error signal
errorSignal = zeros(N,1);

% =========================================================
% NLMS PROCESSING
% =========================================================

for n = filterLength:N

    % -----------------------------------------
    % Reference noise vector
    % -----------------------------------------

    x = referenceNoise(n:-1:n-filterLength+1);

    % -----------------------------------------
    % Estimate noise
    % -----------------------------------------

    estimatedNoise = weights' * x;

    % -----------------------------------------
    % Error / cleaned signal
    % -----------------------------------------

    errorSignal(n) = ...
        noisySignal(n) - estimatedNoise;

    outputSignal(n) = ...
        errorSignal(n);

    % -----------------------------------------
    % NLMS coefficient update
    % -----------------------------------------

    normalization = ...
        (x' * x) + epsilon;

    weights = weights + ...
        (mu / normalization) * ...
        errorSignal(n) * x;

end

end