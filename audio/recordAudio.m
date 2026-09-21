function [audioData, Fs] = recordAudio(duration)

% ==========================================
% REAL-TIME AUDIO RECORDING
% ==========================================

Fs = 8000;          % Sampling frequency
bits = 16;
channels = 1;

fprintf('\n');
fprintf('============================================\n');
fprintf('       REAL AUDIO RECORDING\n');
fprintf('============================================\n');

fprintf('Sampling Frequency : %d Hz\n', Fs);
fprintf('Duration           : %.2f seconds\n', duration);
fprintf('\n');

fprintf('Recording starts in...\n');

pause(1);
fprintf('3...\n');

pause(1);
fprintf('2...\n');

pause(1);
fprintf('1...\n');

fprintf('\nRECORDING...\n');

% Create recorder
recorder = audiorecorder(Fs, bits, channels);

% Record
recordblocking(recorder, duration);

fprintf('Recording completed.\n');

% Get audio data
audioData = getaudiodata(recorder);

% Convert to column vector
audioData = audioData(:);

% Normalize
audioData = audioData ./ ...
    (max(abs(audioData)) + eps);

fprintf('Samples recorded : %d\n', length(audioData));

fprintf('============================================\n');

end