function realTimeNLMS()

clc;

fprintf('\n');
fprintf('============================================\n');
fprintf('       REAL-TIME NLMS AUDIO TEST\n');
fprintf('============================================\n');

% ==========================================
% AUDIO PARAMETERS
% ==========================================

Fs = 8000;
frameLength = 1024;

filterLength = 64;
mu = 0.1;
epsilon = 1e-8;

% ==========================================
% AUDIO DEVICES
% ==========================================

reader = audioDeviceReader( ...
    'SampleRate', Fs, ...
    'SamplesPerFrame', frameLength, ...
    'NumChannels', 1);

writer = audioDeviceWriter( ...
    'SampleRate', Fs);

% ==========================================
% NLMS INITIALIZATION
% ==========================================

weights = zeros(filterLength,1);

referenceBuffer = zeros(filterLength,1);

frameCount = 0;

fprintf('\n');
fprintf('Sampling Frequency : %d Hz\n', Fs);
fprintf('Frame Length       : %d samples\n', frameLength);
fprintf('Filter Length      : %d taps\n', filterLength);
fprintf('Step Size           : %.2f\n', mu);

fprintf('\n');
fprintf('REAL-TIME NLMS STARTED\n');
fprintf('Speak into the microphone.\n');
fprintf('Press Ctrl+C to stop.\n');

fprintf('============================================\n');

% ==========================================
% REAL-TIME PROCESSING
% ==========================================

while true

    % --------------------------------------
    % Read microphone frame
    % --------------------------------------

    inputFrame = reader();

    inputFrame = inputFrame(:);

    % --------------------------------------
    % Create controlled reference noise
    % --------------------------------------

    sampleIndex = ...
        ((frameCount*frameLength) : ...
        (frameCount*frameLength + frameLength-1))';

    timeFrame = sampleIndex / Fs;

    referenceNoise = ...
        0.3*sin(2*pi*80*timeFrame) + ...
        0.2*sin(2*pi*120*timeFrame);

    referenceNoise = referenceNoise(:);

    % --------------------------------------
    % Add controlled noise to input
    % --------------------------------------

    noisyFrame = ...
        inputFrame + referenceNoise;

    % --------------------------------------
    % NLMS processing
    % --------------------------------------

    outputFrame = zeros(frameLength,1);

    tic;

    for n = 1:frameLength

        % Update reference buffer
        referenceBuffer = ...
            [referenceNoise(n); ...
             referenceBuffer(1:end-1)];

        % Estimate noise
        estimatedNoise = ...
            weights' * referenceBuffer;

        % Error / cleaned signal
        errorSignal = ...
            noisyFrame(n) - estimatedNoise;

        outputFrame(n) = errorSignal;

        % NLMS normalization
        normalization = ...
            referenceBuffer' * referenceBuffer ...
            + epsilon;

        % Update weights
        weights = weights + ...
            (mu / normalization) * ...
            errorSignal * referenceBuffer;

    end

    processingTime = toc;

    % --------------------------------------
    % Output audio
    % --------------------------------------

    writer(outputFrame);

    % --------------------------------------
    % Performance monitoring
    % --------------------------------------

    inputRMS = sqrt(mean(noisyFrame.^2));

    outputRMS = sqrt(mean(outputFrame.^2));

    frameDuration = frameLength / Fs;

    realTimeFactor = ...
        frameDuration / max(processingTime,eps);

    frameCount = frameCount + 1;

    % Display approximately once per second
    if mod(frameCount,8) == 0

        fprintf('\rInput RMS: %.4f | Output RMS: %.4f | Processing: %.2f ms | RT Factor: %.2fx   ', ...
            inputRMS, ...
            outputRMS, ...
            processingTime*1000, ...
            realTimeFactor);

        drawnow;

    end

end

end