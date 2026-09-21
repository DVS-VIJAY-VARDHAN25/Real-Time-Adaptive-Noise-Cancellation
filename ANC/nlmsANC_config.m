function [outputSignal,errorSignal,weights] = ...
    nlmsANC_config(noisySignal,referenceNoise,filterLength,mu)

% =========================================================
% CONFIGURABLE NLMS ANC
% =========================================================

epsilon = 1e-8;

noisySignal = noisySignal(:);
referenceNoise = referenceNoise(:);

N = length(noisySignal);

weights = zeros(filterLength,1);

outputSignal = zeros(N,1);

errorSignal = zeros(N,1);

% =========================================================
% NLMS
% =========================================================

for n = filterLength:N

    x = referenceNoise( ...
        n:-1:n-filterLength+1);

    estimatedNoise = ...
        weights' * x;

    errorSignal(n) = ...
        noisySignal(n) - estimatedNoise;

    outputSignal(n) = ...
        errorSignal(n);

    normalization = ...
        x' * x + epsilon;

    weights = weights + ...
        (mu/normalization) * ...
        errorSignal(n) * x;

end

end