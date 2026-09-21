function [outputSignal, errorSignal, weights] = ...
    nlmsANC_custom(noisySignal, referenceNoise, filterLength, mu)

% =========================================================
% CUSTOM NLMS ADAPTIVE NOISE CANCELLATION
% =========================================================

epsilon = 1e-8;

% Make column vectors
noisySignal = noisySignal(:);
referenceNoise = referenceNoise(:);

% Number of samples
N = length(noisySignal);

% Initialize filter
weights = zeros(filterLength,1);

% Initialize outputs
outputSignal = zeros(N,1);
errorSignal = zeros(N,1);

% =========================================================
% NLMS PROCESSING
% =========================================================

for n = filterLength:N

    % Reference noise vector
    x = referenceNoise(n:-1:n-filterLength+1);

    % Estimated noise
    estimatedNoise = weights' * x;

    % Error signal
    errorSignal(n) = ...
        noisySignal(n) - estimatedNoise;

    % ANC output
    outputSignal(n) = errorSignal(n);

    % Normalization
    normalization = ...
        (x' * x) + epsilon;

    % Update adaptive filter
    weights = weights + ...
        (mu / normalization) * ...
        errorSignal(n) * x;

end

end