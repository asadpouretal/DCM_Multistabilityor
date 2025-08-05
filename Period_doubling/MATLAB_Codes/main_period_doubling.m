clear all; %% OK
fs=1000; %Sampling frequency
n=400; %Number of trials
FC=[0 0 0 0 0 0];

ts=0 : 1/fs : 5;
tf=ts(end);
t0=ts(1);
X1=0.018*rand(n,length(ts)) / 0.1; %input 1
X2=0.012*rand(n,length(ts)) / 0.1; %input 2


for i = 1:n
    options = odeset('RelTol', 1e-4, 'AbsTol', ones(1, 6) * 1e-4, 'MaxStep', abs(t0 - tf) / 10);
    [t, yg_temp] = ode45(@(t, yg) NET_period_doubling(t, yg, ts, X1(i, :), ts, X2(i, :)), ts, FC, options);
    yg(i, :, :) = yg_temp;
    
    % Extract yg dimensions
    yg_i = squeeze(yg(i, :, :));

    LFP(i, :) = -(yg_i(:, 2)); % LFP definition for column 1
    
    LFP1(i, :) = -(yg_i(:, 5));% LFP definition for column 2
end


period_doubling_trials = struct('input1', X1, ...
                           'input2', X2, ...
                           'output1_e1', yg(:,:,1), ...
                           'output1_e2', yg(:,:,2), ...
                           'output1_i1', yg(:,:,3), ...
                           'output2_e1', yg(:,:,4), ...
                           'output2_e2', yg(:,:,5), ...
                           'output2_i1', yg(:,:,6), ...
                           'output1_LFP', LFP(:,:), ...
                           'output2_LFP', LFP1(:,:));



figure,
ch=squeeze(yg(1,:,2));
ch1=squeeze(yg(1,:,3));
plot(ch)


plot(ch,ch1,'.')
%hold on
plot(ts,ch1)

%plot(ch,ch1)

%plot(LFP)

