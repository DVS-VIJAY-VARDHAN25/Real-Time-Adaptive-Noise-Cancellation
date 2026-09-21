function realTimeANC()

clc;

fprintf('\n');
fprintf('============================================\n');
fprintf('       REAL-TIME AI ADAPTIVE AUDIO\n');
fprintf('============================================\n');

Fs = 8000;
frameLength = 1024;

reader = audioDeviceReader( ...
    'SampleRate', Fs, ...
    'SamplesPerFrame', frameLength, ...
    'NumChannels', 1);

writer = audioDeviceWriter( ...
    'SampleRate', Fs);

fprintf('\n');
fprintf('Sampling Frequency : %d Hz\n', Fs);
fprintf('Frame Length       : %d samples\n', frameLength);
fprintf('\n');
fprintf('MICROPHONE MONITOR STARTED\n');
fprintf('Speak into the microphone.\n');
fprintf('Press Ctrl+C to stop.\n');
fprintf('============================================\n');

frameCount = 0;

while true

    % Read microphone
    inputFrame = reader();

    inputFrame = inputFrame(:);

    % Monitor the microphone directly
    outputFrame = inputFrame;

    % Send to headphones/speaker
    writer(outputFrame);

    frameCount = frameCount + 1;

    % Display status every ~1 second
    if mod(frameCount,8) == 0

        rmsValue = sqrt(mean(inputFrame.^2));

        fprintf('\rInput RMS: %.4f    ', rmsValue);

        drawnow;

    end

end

end