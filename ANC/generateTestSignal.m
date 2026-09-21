function [t, cleanSignal, referenceNoise, noise, noisySignal, Fs] = generateTestSignal()

% =========================================================
% AI ADAPTIVE AUDIO
% Day 2 - ANC Test Signal Generation
% =========================================================

clc;

% =========================================================
% AUDIO PARAMETERS
% =========================================================

Fs = 8000;
duration = 5;

t = (0:1/Fs:duration-1/Fs)';

% =========================================================
% CLEAN AUDIO-LIKE SIGNAL
% =========================================================

cleanSignal = ...
    0.6*sin(2*pi*500*t) + ...
    0.3*sin(2*pi*1000*t);

% =========================================================
% REFERENCE MICROPHONE NOISE
% =========================================================

referenceNoise = ...
    0.5*sin(2*pi*80*t) + ...
    0.3*sin(2*pi*120*t);

% =========================================================
% PRIMARY MICROPHONE NOISE
% =========================================================

% Simulate acoustic path between noise source
% and primary microphone

acousticPath = [1 0.7 0.3 0.1];

noiseFromPath = filter(acousticPath,1,referenceNoise);

% Small unrelated measurement noise
measurementNoise = ...
    0.02*randn(size(t));

% Actual noise reaching primary microphone
noise = ...
    noiseFromPath + measurementNoise;

% =========================================================
% PRIMARY MICROPHONE SIGNAL
% =========================================================

noisySignal = ...
    cleanSignal + noise;

% =========================================================
% NORMALIZE EVERYTHING CONSISTENTLY
% =========================================================

scale = max(abs(noisySignal));

cleanSignal = cleanSignal / scale;

referenceNoise = referenceNoise / scale;

noise = noise / scale;

noisySignal = noisySignal / scale;

% =========================================================
% INFORMATION
% =========================================================

fprintf('\n');
fprintf('============================================\n');
fprintf(' AI ADAPTIVE AUDIO - ANC TEST\n');
fprintf('============================================\n');

fprintf('Sampling Frequency : %d Hz\n',Fs);
fprintf('Duration           : %.2f seconds\n',duration);
fprintf('Number of Samples  : %d\n',length(t));

fprintf('============================================\n');

end