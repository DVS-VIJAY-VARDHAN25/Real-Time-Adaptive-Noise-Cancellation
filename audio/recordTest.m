clc;
clear;
close all;

% ==========================================
% REAL AUDIO TEST
% ==========================================

duration = 5;

[audioData, Fs] = recordAudio(duration);

% Time vector
t = (0:length(audioData)-1)' / Fs;

% Plot
figure('Name','Real Microphone Audio');

plot(t,audioData);

xlabel('Time (s)');
ylabel('Amplitude');

title('Recorded Microphone Signal');

grid on;

% Play recording
fprintf('\nPlaying recorded audio...\n');

sound(audioData,Fs);

fprintf('Playback started.\n');