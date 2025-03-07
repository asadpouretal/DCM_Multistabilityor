clear all; %% OK

fs = 1000; % Sampling frequency
n = 400; % Number of trials
FC = [0 0 0 0 0 0]; % Initial condition
ts = 0 : 1/fs : 4; % Time of simulation
tf = ts(end);
t0 = ts(1);

f = 1; %Frequency of input to column 1

f1 = 200; %Frequency of input to column 2

% Generate sinusoidal inputs modulated by random noise
X1 = (0.01 * sin(2 * pi * f * ts) + 0.01 * rand(n, length(ts))) / 0.1; % input to column 1

X2 = (0.05 * sin(2 * pi * f1 * ts) +  0.05 *rand(n, length(ts))) / 0.1; % input to column 2

for i = 1:n
    options = odeset('RelTol', 1e-4, 'AbsTol', ones(1, 6) * 1e-4, 'MaxStep', abs(t0 - tf) / 10);

    % Numerical solution of model differential equations using the Runge-Kutta method.
    [t, yg_temp] = ode45(@(t, yg) NET_chaos(t, yg, ts, X1(i, :), ts, X2(i, :)), ts, FC, options); 

    yg(i, :, :) = yg_temp;
    
    % Extract yg dimensions
    yg_i = squeeze(yg(i, :, :));

    LFP(i, :) = -(yg_i(:, 2)); % LFP definition for column 1 (-e2)
    LFP1(i, :) = -(yg_i(:, 5)); % LFP definition for column 2 (-e2)
end

chaotic_trials = struct('input1', X1, ...
                           'input2', X2, ...
                           'output1_e1', yg(:,:,1), ...
                           'output1_e2', yg(:,:,2), ...
                           'output1_i1', yg(:,:,3), ...
                           'output2_e1', yg(:,:,4), ...
                           'output2_e2', yg(:,:,5), ...
                           'output2_i1', yg(:,:,6), ...
                           'output1_LFP', LFP(:,fs:end), ...
                           'output2_LFP', LFP1(:,fs:end));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure,
ch=squeeze(yg(1,:,1));

ch1=squeeze(yg(1,:,2));

%ch2=squeeze(yg(1,:,3));

plot(ch, ch1, '.')
hold on
plot(ch1)

