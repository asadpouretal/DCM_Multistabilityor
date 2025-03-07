clear all
num_trials=200;
fs=1000;         %Sampling frequency
%a1=0.1;
decision_boundary=0.15; 
a_values = (0.1:0.025:0.2);   %Different evidence quality = ((a_values-0.1)/(a_values+0.1))

for i=1:length(a_values)

[acc(i),decision_reaction_times,error_reaction_times,decision_trial_indices,error_trial_indices,non_decision_trial_indices,o1_e1,o1_e2,o1_i1,o2_e1,o2_e2,o2_i1,input_1,input_2,avg_decision_rts(i),avg_error_rts(i),output1_LFP,output2_LFP]=fsm3(num_trials,fs,decision_boundary,a_values(i));
non_decision_trial_indices1{i}=non_decision_trial_indices;
correct_trials{i} = struct('input1', input_1(decision_trial_indices,:), ...     %Input to column1
                           'input2', input_2(decision_trial_indices,:), ...     %Input to column2
                           'output1_e1', (o1_e1(decision_trial_indices,:)), ... %Output of neuron e1 in column1
                           'output1_e2', (o1_e2(decision_trial_indices,:)), ... %Output of neuron e2 in column1
                           'output1_i1', o1_i1(decision_trial_indices,:), ...   %Output of neuron i1 in column1
                           'output2_e1', (o2_e1(decision_trial_indices,:)), ... %Output of neuron e1 in column2
                           'output2_e2', (o2_e2(decision_trial_indices,:)), ... %Output of neuron e2 in column2
                           'output2_i1', o2_i1(decision_trial_indices,:), ...   %Output of neuron i1 in column2
                           'output1_LFP', output1_LFP(decision_trial_indices,:), ... %Output of LFP in column1
                           'output2_LFP', output2_LFP(decision_trial_indices,:), ... %Output of LFP in column2
                           'reaction_times', decision_reaction_times);               %Decision time

error_trials{i} = struct('input1', input_1(error_trial_indices,:), ...  %Similar to correct trial
                           'input2', input_2(error_trial_indices,:), ...
                           'output1_e1', o1_e1(error_trial_indices,:), ...
                           'output1_e2', o1_e2(error_trial_indices,:), ...
                           'output1_i1', o1_i1(error_trial_indices,:), ...
                           'output2_e1', o2_e1(error_trial_indices,:), ...
                           'output2_e2', o2_e2(error_trial_indices,:), ...
                           'output2_i1', o2_i1(error_trial_indices,:), ...
                           'output1_LFP', output1_LFP(error_trial_indices,:), ...
                           'output2_LFP', output2_LFP(error_trial_indices,:), ...
                           'reaction_times', error_reaction_times);

non_decision_trials{i} = struct('input1', input_1(non_decision_trial_indices,:), ...  %Similar to correct trial
                           'input2', input_2(non_decision_trial_indices,:), ...
                           'output1_e1', o1_e1(non_decision_trial_indices,:), ...
                           'output1_e2', o1_e2(non_decision_trial_indices,:), ...
                           'output1_i1', o1_i1(non_decision_trial_indices,:), ...
                           'output2_e1', o2_e1(non_decision_trial_indices,:), ...
                           'output2_e2', o2_e2(non_decision_trial_indices,:), ...
                           'output2_i1', o2_i1(non_decision_trial_indices,:), ...
                           'output1_LFP', output1_LFP(non_decision_trial_indices,:), ...
                           'output2_LFP', output2_LFP(non_decision_trial_indices,:));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%It is not necessery to use this part of code 

g = [correct_trials{1, 1}.output1_e1 correct_trials{1, 2}.output1_e1 correct_trials{1, 3}.output1_e1 correct_trials{1, 4}.output1_e1 correct_trials{1, 5}.output1_e1 correct_trials{1, 1}.output2_e1 correct_trials{1, 2}.output2_e1 correct_trials{1, 3}.output2_e1 correct_trials{1, 4}.output2_e1 correct_trials{1, 5}.output2_e1];  % Concatenate along the first dimension

h1_o1 = correct_trials{1, 1}.output1_e1;
h2_o1 = correct_trials{1, 2}.output1_e1;
h3_o1 = correct_trials{1, 3}.output1_e1;
h4_o1 = correct_trials{1, 4}.output1_e1;
h5_o1 = correct_trials{1, 5}.output1_e1;

h1_o2 = correct_trials{1, 1}.output2_e1;
h2_o2 = correct_trials{1, 2}.output2_e1;
h3_o2 = correct_trials{1, 3}.output2_e1;
h4_o2 = correct_trials{1, 4}.output2_e1;
h5_o2 = correct_trials{1, 5}.output2_e1;


no1_o1 = zeros(1, size(h1_o1, 2));
no2_o1 = zeros(1, size(h1_o1, 2));
no3_o1 = zeros(1, size(h1_o1, 2));
no4_o1 = zeros(1, size(h1_o1, 2));
no5_o1 = zeros(1, size(h1_o1, 2));

no1_o2 = zeros(1, size(h1_o1, 2));
no2_o2 = zeros(1, size(h1_o1, 2));
no3_o2 = zeros(1, size(h1_o1, 2));
no4_o2 = zeros(1, size(h1_o1, 2));
no5_o2 = zeros(1, size(h1_o1, 2));



for i = 1:size(h1_o1, 2)
    min_g = min(g);
    max_g = max(g);

    no1_o1(i) = (h1_o1(1,i) - min_g) / (max_g - min_g);
    no2_o1(i) = (h2_o1(1,i) - min_g) / (max_g - min_g);
    no3_o1(i) = (h3_o1(1,i) - min_g) / (max_g - min_g);
    no4_o1(i) = (h4_o1(1,i) - min_g) / (max_g - min_g);
    no5_o1(i) = (h5_o1(1,i) - min_g) / (max_g - min_g);

    no1_o2(i) = (h1_o2(1,i) - min_g) / (max_g - min_g);
    no2_o2(i) = (h2_o2(1,i) - min_g) / (max_g - min_g);
    no3_o2(i) = (h3_o2(1,i) - min_g) / (max_g - min_g);
    no4_o2(i) = (h4_o2(1,i) - min_g) / (max_g - min_g);
    no5_o2(i) = (h5_o2(1,i) - min_g) / (max_g - min_g);
end

t = linspace(0, 4, 4*fs);

figure,
plot(t,no1_o1,'LineWidth',2,'color','k')
hold on
plot(t,no2_o1,'LineWidth',2,'color','b')
hold on
plot(t,no3_o1,'LineWidth',2,'color','r')
hold on
plot(t,no4_o1,'LineWidth',2,'color','g')
hold on
plot(t,no5_o1,'LineWidth',2,'color','y')
hold on
plot(t,no1_o2,'LineWidth',2,'color','k')
hold on
plot(t,no2_o2,'LineWidth',2,'color','b')
hold on
plot(t,no3_o2,'LineWidth',2,'color','r')
hold on
plot(t,no4_o2,'LineWidth',2,'color','g')
hold on
plot(t,no5_o2,'LineWidth',2,'color','y')


n=45;
%figure,
%plot(output1_EEG(n,:))
%hold on
%plot(output2_EEG(n,:))

figure,
plot(o1_e1(n,:))
hold on
plot(o2_e1(n,:))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





for i=1:length(a_values)
I(i)=(a_values(i)-0.1)/(a_values(i)+0.1);
end

figure,
plot(I,acc,'o-','LineWidth',2,'MarkerSize',6,'color','k')
xlabel("(I_1-I_2)/(I_1+I_2) ", 'FontSize', 16)
ylabel("Choice accuracy (%)", 'FontSize', 16)
set(gca, 'FontSize', 16);
axis square

for i=1:length(a_values)
%if (length(error_trial_indices{i})<10)
%avg_error_rts(i)=nan;  
%end
g=[avg_decision_rts avg_error_rts];    
no_avg_decision_rts(i)=(avg_decision_rts(i)-nanmin(g))/(nanmax(g)-nanmin(g));
no_avg_error_rts(i)=(avg_error_rts(i)-nanmin(g))/(nanmax(g)-nanmin(g));
end
no_avg_error_rts(1,6)=nan;
figure,
plot(I,no_avg_decision_rts,'o-','LineWidth',2,'MarkerSize',6,'color','b')
hold on
plot(I,no_avg_error_rts,'o-','LineWidth',2,'MarkerSize',6,'color','r')
legend('Correct','Error')
xlabel('(I_1-I_2)/(I_1+I_2)', 'FontSize', 16)
ylabel('Normalized reaction time', 'FontSize', 16)
set(gca, 'FontSize', 16);
axis square

plot(output1_EEG(37,:))
hold on
plot(output2_EEG(37,:))