function [acc,decision_reaction_times,error_reaction_times,decision_trial_indicesa,error_trial_indicesa,non_decision_trial_indicesa,o1_e1,o1_e2,o1_i1,o2_e1,o2_e2,o2_i1,input_1,input_2,avg_decision_rts,avg_error_rts,output1_LFP,output2_LFP]=fsm3(num_trials,fs,decision_boundaries,a1,db2,cL12,cL21)
    % Parameters
    Ae = 3.25; %H_e
    Ai = 22;   %H_i
    a1e = 10;  %K_e
    a1i = 200; %K_I
    r1 = 2;    %Sigmoidal parameter
    r2 = 1;    %Sigmoidal parameter
    %cL21 = 0.6;  %excitatory-excitatory lateral connection
    %cL12 = 0.6;  %excitatory-excitatory lateral connection
    cLi12 = 19/0.6.*cL12;  %excitatory-inhibitory lateral connection
    cLi21 = 19/0.6.*cL21;  %excitatory-inhibitory lateral connection
    c1=0.1;    %Intrinsic coupling parameter
    c2=0.1;    %Intrinsic coupling parameter
    c3 = 15;   %Intrinsic coupling parameter
    c4 = 3;    %Intrinsic coupling parameter
    c5 = 3;    %Intrinsic coupling parameter
    c6=0.1;    %Intrinsic coupling parameter
    c7 = 30;   %Intrinsic coupling parameter
    I0E1 = 0.3255;
    I0E2 = 0.3255;
    noise_amp =10;  
    tampa = 5/1000; %time constant of the noise
    f = 3;       %ending time of stimulus


    % Time vector
    t = linspace(0, 4, 4*fs);

    % Noise and bumps

    b = 1; % Center of Gaussian bumps
    c = 0.005; % Width of Gaussian bumps
   % a = 0.1; % Amplitude factor

        X0 = zeros(1, 30);

    % Euler's method for solving the system of differential equations
    dt = t(2) - t(1);
    X = zeros(length(t), length(X0));
    X(1, :) = X0;
% Number of trials
%num_trials = 300;

% Range of 'a' values to simulate
a_values = (a1);

% Lists to store average reaction times for each 'a' value
avg_decision_rts = [];
avg_error_rts = [];

% Loop over different 'a' values
for a_idx = 1:length(a_values)
    a = a_values(a_idx);
% Guassian bump as input

    rise1 = a * exp(-((t - b) .^ 2) / (2 * c ^ 2));
    rise1(t > b) = 0;
    sustain1 = zeros(size(t));
    sustain1((t >= b) & (t <= f)) = a;
    decay1 = a * exp(-((t - f) .^ 2) / (2 * c ^ 2));
    decay1(t < f) = 0;
    bump1 = 1 * max([rise1; sustain1; decay1]);

    amplitude_bump2 = 0.1;
    rise2 = amplitude_bump2 * exp(-((t - b) .^ 2) / (2 * c ^ 2));
    rise2(t > b) = 0;
    sustain2 = zeros(size(t));
    sustain2((t >= b) & (t <= f)) = amplitude_bump2;
    decay2 = amplitude_bump2 * exp(-((t - f) .^ 2) / (2 * c ^ 2));
    decay2(t < f) = 0;
    bump2 = 1 * max([rise2; sustain2; decay2]);
    % Initialize lists to store trial indices and reaction times for the current 'a' value
    decision_trial_indices = [];
    error_trial_indices = [];
    non_decision_trial_indices = [];
    decision_reaction_times = [];
    error_reaction_times = [];

    % Run trials for the current value of 'a'
    for trial = 1:num_trials
        rng(trial); % Ensure variability in each trial
        input_1(trial,:)= bump1+X(:, 29)';
        input_2(trial,:)= bump2+X(:, 30)';
        % Simulate the trial with Euler's method for the current 'a'
        % Ensure euler_method, model, X0, and t are defined similarly in MATLAB
        X = zeros(length(t), length(X0));
        X(1, :) = X0;
        for i = 1:length(t)-1
            X(i+1, :) = X(i, :) + dt * model3(X(i, :), i, bump1, bump2, noise_amp, tampa, Ae, Ai, a1e, a1i, cL12, cL21, cLi12, cLi21,c1,c2,c3,c4,c5,c6,c7); %Simulation of the model
        end
        o1_e1(trial,:)=X(:, 1)'; %Output of neuron e1 in column1
        o1_e2(trial,:)=X(:, 2)'; %Output of neuron e2 in column1
        o1_i1(trial,:)=X(:, 3)'; %Output of neuron i1 in column1
        o2_e1(trial,:)=X(:, 15)';%Output of neuron e1 in column2
        o2_e2(trial,:)=X(:, 16)';%Output of neuron e2 in column2
        o2_i1(trial,:)=X(:, 17)';%Output of neuron i1 in column2
        output1_LFP(trial,:)=((X(:, 1)'+X(:, 6)'))+((X(:, 2)'+X(:, 7)')-(X(:, 3)'))+(X(:, 4)'-X(:, 5)'); %Output of LFP in column1
        output2_LFP(trial,:)=((X(:, 15)'+X(:, 20)'))+((X(:, 16)'+X(:, 21)')-X(:, 17)')+(X(:, 18)'-X(:, 19)'); %Output of LFP in column2
        %output1_EEG(trial,:)=X(:, 2)'-X(:, 3)'+X(:, 7)';
        %output2_EEG(trial,:)=X(:, 17)'-X(:, 18)'+X(:, 22)';
        output1_EEG(trial,:)=-(X(:, 2)'-X(:, 3)'+X(:, 7)');
        output2_EEG(trial,:)=-(X(:, 16)'-X(:, 17)'+X(:, 21)');
        %X1=abs((X(:, 1)'+X(:, 6)'))+abs((X(:, 2)'+X(:, 7)')-(X(:, 3)'))+abs(X(:, 4)'-X(:, 5)');
        
        %X2=abs((X(:, 16)'+X(:, 21)'))+abs((X(:, 17)'+X(:, 22)')-X(:, 18)')+abs(X(:, 19)'-X(:, 20)');
        %X1=-(X(:, 2)'-X(:, 3)'+X(:, 7)');
        %X2=-(X(:, 16)'-X(:, 17)'+X(:, 21)');
        X1=X(:, 1)';
        X2=X(:, 15)';

        X1=X1';
        X2=X2';


        % Analyze segments of x2 and x17 within the specified time window
        start_idx = find(t >= 1, 1, 'first');
        end_idx = find(t <= f, 1, 'last');
        x2 = X1(start_idx:end_idx + 1,1);
        x17 = X2(start_idx:end_idx + 1,1);

        % Determine trends and classify the trial

            if(cL12==cL21)
        % Classification of trials
            if max(x2) >= max(x17) && abs(max(abs(x2)) - max(abs(x17))) >= db2
                decision_trial_indices = [decision_trial_indices, trial];
            elseif max(x17) >= max(x2) && abs(max(abs(x17)) - max(abs(x2))) >= db2
                error_trial_indices = [error_trial_indices, trial];
            else
                non_decision_trial_indices = [non_decision_trial_indices, trial];
            end
            end
            if(cL12~=cL21)
            % Both increasing
            if max(x2) >= max(x17) && abs(max(abs(x2)) - min(abs(x17))) >= db2
                decision_trial_indices = [decision_trial_indices, trial];
            elseif max(x17) >= max(x2) && abs(max(abs(x17)) - min(abs(x2))) >= db2
                error_trial_indices = [error_trial_indices, trial];
            else
                non_decision_trial_indices = [non_decision_trial_indices, trial];
            end
        end
    end
decision_trial_indicesa=decision_trial_indices;
error_trial_indicesa=error_trial_indices;
non_decision_trial_indicesa=non_decision_trial_indices;
    % Calculate reaction times for decision trials
    for trial_idx = 1:length(decision_trial_indices)
        trial = decision_trial_indices(trial_idx);
        rng(trial);
        X = zeros(length(t), length(X0));
        X(1, :) = X0;
        for i = 1:length(t)-1
            X(i+1, :) = X(i, :) + dt * model3(X(i, :), i, bump1, bump2, noise_amp, tampa, Ae, Ai, a1e, a1i, cL12, cL21, cLi12, cLi21, c1,c2,c3, c4, c5,c6, c7);
        end
        %x2 = X(:, 1);
        %X1=-(X(:, 2)'-X(:, 3)'+X(:, 7)');
        %X2=-(X(:, 16)'-X(:, 17)'+X(:, 21)');

        X1=X(:, 1)';
        X2=X(:, 15)';

        X1=X1';
        X2=X2';
        % Find the first time point where x2 exceeds a threshold
        rt_indices = find((X1) > decision_boundaries, 1, 'first');
        if ~isempty(rt_indices)
            first_rt = t(rt_indices);
            decision_reaction_times = [decision_reaction_times, first_rt];
          

        end
    end

    % Calculate reaction times for error trials
    for trial_idx = 1:length(error_trial_indices)
        trial = error_trial_indices(trial_idx);
        rng(trial);
        X = zeros(length(t), length(X0));
        X(1, :) = X0;
        for i = 1:length(t)-1
            X(i+1, :) = X(i, :) + dt * model3(X(i, :), i, bump1, bump2, noise_amp, tampa, Ae, Ai, a1e, a1i, cL12, cL21, cLi12, cLi21,c1,c2,c3,c4,c5,c6,c7);
        end
        %x17 = X(:, 15);
        %X1=-(X(:, 2)'-X(:, 3)'+X(:, 7)');
        %X2=-(X(:, 16)'-X(:, 17)'+X(:, 21)');
         X1=X(:, 1)';
         X2=X(:, 15)';

        X1=X1';
        X2=X2';
        % Find the first time point where x17 exceeds a threshold
        rt_indices = find(X2 > decision_boundaries, 1, 'first');
        if ~isempty(rt_indices)
            first_rt = t(rt_indices);
            error_reaction_times = [error_reaction_times, first_rt];
        end
    end

    % Calculate and store average reaction times for the current 'a'
    if ~isempty(decision_reaction_times)
        avg_decision_rt = nanmean(decision_reaction_times);
    else
        avg_decision_rt = NaN;
    end

    if ~isempty(error_reaction_times)
        avg_error_rt = nanmean(error_reaction_times);
    else
        avg_error_rt = NaN;
    end
    avg_decision_rts(a_idx)=avg_decision_rt;  %Decision time (correct)
    avg_error_rts(a_idx)=avg_error_rt;%Decision time (error)
    %avg_decision_rtsa(a_idx)= avg_decision_rts;
    %avg_error_rtsa(a_idx)= avg_error_rts;
acc(a_idx)=(length(decision_trial_indices))/(length(decision_trial_indices)+length(error_trial_indices))*100; %Accuracy
end
end

%disp(['Average decision reaction time: ', num2str(avg_decision_rts)]);
%disp(['Average error reaction time: ', num2str(avg_error_rts)]);
