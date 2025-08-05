clear all
num_trials=1000;
fs=1000;
%a=0.3;
decision_boundary=0.03;
a_values = (0.10:0.05:0.7);
for i=1:length(a_values)

[acc,decision_reaction_times,error_reaction_times,decision_trial_indices,error_trial_indices,non_decision_trial_indices,o1_e1,o1_i1,o2_e1,o2_i1,input_1,input_2,avg_decision_rts,avg_error_rts]=fsm2(num_trials,fs,decision_boundary,a_values(i));

correct_trials{i} = struct('input1', input_1(decision_trial_indices,:), ...
                           'input2', input_2(decision_trial_indices,:), ...
                           'output1_e1', o1_e1(decision_trial_indices,:), ...
                           'output1_i1', o1_i1(decision_trial_indices,:), ...
                           'output2_e1', o2_e1(decision_trial_indices,:), ...
                           'output2_i1', o2_i1(decision_trial_indices,:), ...
                           'reaction_times', decision_reaction_times);

error_trials{i} = struct('input1', input_1(error_trial_indices,:), ...
                           'input2', input_2(error_trial_indices,:), ...
                           'output1_e1', o1_e1(error_trial_indices,:), ...
                           'output1_i1', o1_i1(error_trial_indices,:), ...
                           'output2_e1', o2_e1(error_trial_indices,:), ...
                           'output2_i1', o2_i1(error_trial_indices,:), ...
                           'reaction_times', error_reaction_times);

non_decision_trials{i} = struct('input1', input_1(non_decision_trial_indices,:), ...
                           'input2', input_2(non_decision_trial_indices,:), ...
                           'output1_e1', o1_e1(non_decision_trial_indices,:), ...
                           'output1_i1', o1_i1(non_decision_trial_indices,:), ...
                           'output2_e1', o2_e1(non_decision_trial_indices,:), ...
                           'output2_i1', o2_i1(non_decision_trial_indices,:));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



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
if (length(error_trial_indices{i})<10)
avg_error_rts(i)=nan;  
end
g=[avg_decision_rts avg_error_rts];    
no_avg_decision_rts(i)=(avg_decision_rts(i)-min(g))/(max(g)-min(g));
no_avg_error_rts(i)=(avg_error_rts(i)-min(g))/(max(g)-min(g));
end

figure,
plot(I,no_avg_decision_rts,'o-','LineWidth',2,'MarkerSize',6,'color','b')
hold on
plot(I,no_avg_error_rts,'o-','LineWidth',2,'MarkerSize',6,'color','r')
legend('Correct','Error')
xlabel('(I_1-I_2)/(I_1+I_2)', 'FontSize', 16)
ylabel('Normalized reaction time', 'FontSize', 16)
set(gca, 'FontSize', 16);
axis square