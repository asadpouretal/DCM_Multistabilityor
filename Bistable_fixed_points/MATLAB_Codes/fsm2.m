
function [acc,decision_reaction_times,error_reaction_times,decision_trial_indicesa,error_trial_indicesa,non_decision_trial_indicesa,o_e1,o_i1,o_e2,o_i2,input_1,input_2,avg_decision_rts,avg_error_rts]=fsm2(num_trials,fs,decision_boundary,a1)
    % Parameters
    Ae = 3.25;
    Ai = 22;
    a1e = 100;
    a1i = 5;
    r1 = 2;
    r2 = 1;
    cL21 = 1;
    cL12 = 1;
    cLi21 = 20;
    cLi12 = 20;
    c3 = 20;
    c4 = 3;
    c5 = 3;
    c7 = 78;
    I0E1 = 0.3255;
    I0E2 = 0.3255;
    noise_amp = 10;
    tampa = 5;
    f = 4;

    % Time vector
    t = linspace(0, 5, 5*fs);

    % Noise and bumps

    b = 1; % Center of Gaussian bumps
    c = 0.005; % Width of Gaussian bumps


        X0 = zeros(1, 22);

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
        X0 = zeros(1, 22);
    % Initialize lists to store trial indices and reaction times for the current 'a' value
    decision_trial_indices = [];
    error_trial_indices = [];
    non_decision_trial_indices = [];
    decision_reaction_times = [];
    error_reaction_times = [];

    % Run trials for the current value of 'a'
    for trial = 1:num_trials
        rng(trial); % Ensure variability in each trial
        input_1(trial,:)= bump1+X(:, 21)';
        input_2(trial,:)= bump2+X(:, 22)';
        % Simulate the trial with Euler's method for the current 'a'
        % Ensure euler_method, model, X0, and t are defined similarly in MATLAB
        X = zeros(length(t), length(X0));
        X(1, :) = X0;
        for i = 1:length(t)-1
            X(i+1, :) = X(i, :) + dt * model2(X(i, :), i, bump1, bump2, noise_amp, tampa, Ae, Ai, a1e, a1i, cL21, cL12, cLi21, cLi12, c3, c4, c5, c7);
        end
        o_e1(trial,:)=X(:, 1)';
        o_i1(trial,:)=X(:, 2)';
        o_e2(trial,:)=X(:, 6)';
        o_i2(trial,:)=X(:, 7)';
        %output1_LFP(trial,:)=abs(X(:, 1)')-abs(X(:, 3)')+X(:, 5)')-abs(X(:, 2)'+X(:, 4)');
        %output2_LFP(trial,:)=abs(X(:, 6)'+X(:, 8)'+X(:, 10)')-abs(X(:, 7)'+X(:, 9)');

        % Analyze segments of x2 and x17 within the specified time window
        start_idx = find(t >= 1, 1, 'first');
        end_idx = find(t <= 4, 1, 'last');
        x2 = X(start_idx:end_idx + 1, 1);
        x17 = X(start_idx:end_idx + 1, 6);

        % Determine trends and classify the trial
        x2_trend = sign(x2(end) - x2(1));
        x17_trend = sign(x17(end) - x17(1));

        % Classification logic as per Python code
        if x2_trend == 1 && x17_trend == 1
            % Both increasing
            if max(x2) >= decision_boundary && max(x2) - max(x17) >= 0.02
                decision_trial_indices = [decision_trial_indices, trial];
            elseif max(x17) >= decision_boundary && max(x17) - max(x2) >= 0.02
                error_trial_indices = [error_trial_indices, trial];
            else
                non_decision_trial_indices = [non_decision_trial_indices, trial];
            end
        elseif x2_trend == -1 && x17_trend == -1
            % Both decreasing
            non_decision_trial_indices = [non_decision_trial_indices, trial];
        elseif x2_trend == 1 && x17_trend == -1
            % x2 increasing, x17 decreasing
            if max(x2) >= decision_boundary && max(x2) - max(x17) >= 0.02
                decision_trial_indices = [decision_trial_indices, trial];
            else
                non_decision_trial_indices = [non_decision_trial_indices, trial];
            end
        elseif x2_trend == -1 && x17_trend == 1
            % x2 decreasing, x17 increasing
            if max(x17) >= decision_boundary && max(x17) - max(x2) >= 0.02
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
            X(i+1, :) = X(i, :) + dt * model2(X(i, :), i, bump1, bump2, noise_amp, tampa, Ae, Ai, a1e, a1i, cL21, cL12, cLi21, cLi12, c3, c4, c5, c7);
        end
        x2 = X(:, 1);

        % Find the first time point where x2 exceeds a threshold
        rt_indices = find(x2 > decision_boundary, 1, 'first');
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
            X(i+1, :) = X(i, :) + dt * model2(X(i, :), i, bump1, bump2, noise_amp, tampa, Ae, Ai, a1e, a1i, cL21, cL12, cLi21, cLi12, c3, c4, c5, c7);
        end
        x17 = X(:, 6);

        % Find the first time point where x17 exceeds a threshold
        rt_indices = find(x17 > decision_boundary, 1, 'first');
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

    avg_decision_rts = [avg_decision_rts, avg_decision_rt];
    avg_error_rts = [avg_error_rts, avg_error_rt];
    acc=(length(decision_trial_indices))/(length(decision_trial_indices)+length(error_trial_indices))*100;

end
end


%disp(['Average decision reaction time: ', num2str(avg_decision_rts)]);
%disp(['Average error reaction time: ', num2str(avg_error_rts)]);
