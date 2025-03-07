clear all
num_trials=2;
fs=1000;         %Sampling frequency
%a1=0.1;
decision_boundary=[0.15,0.10,0.10,0.08]; 
db2 = [0.15,0.1,0.1,0.08]; %Seperation between outputs
a_values = (0.1:0.025:0.5);   %Different evidence quality = ((a_values-0.1)/(a_values+0.1))

cl12 = [0.60,0.20, 0.40, 0.17]; %Excitatory connection from column 1 to 2
cl21 = [0.60,0.40, 0.10, 0.30]; %Excitatory connection from column 2 to 1

for i=1:length(a_values)
for j=1:length(cl12)

[acc(i,j),decision_reaction_times,error_reaction_times,decision_trial_indices,error_trial_indices,non_decision_trial_indices,o1_e1,o1_e2,o1_i1,o2_e1,o2_e2,o2_i1,input_1,input_2,avg_decision_rts(i,j),avg_error_rts(i,j),output1_LFP,output2_LFP]=fsm3(num_trials,fs,decision_boundary(j),a_values(i),db2(j),cl12(j),cl21(j));
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
end


for i=1:length(a_values)
I(i)=(a_values(i)-0.1)/(a_values(i)+0.1);
end

figure,
plot(I,acc(:,2),'o-','LineWidth',2,'MarkerSize',6,'color','k')
hold on
plot(I,acc(:,3),'o-','LineWidth',2,'MarkerSize',6,'color','k')
hold on
plot(I,acc(:,4),'o-','LineWidth',2,'MarkerSize',6,'color','k')
xlabel("(I_1-I_2)/(I_1+I_2) ", 'FontSize', 16)
ylabel("Choice accuracy (%)", 'FontSize', 16)
set(gca, 'FontSize', 16);
axis square

for i=1:length(a_values)
%if (length(error_trial_indices{i})<10)
%avg_error_rts(i)=nan;  
%end
g1=[avg_decision_rts(:,1)' avg_error_rts(:,1)']; 
g2=[avg_decision_rts(:,2)' avg_error_rts(:,2)'];    
g3=[avg_decision_rts(:,3)' avg_error_rts(:,3)'];    
g4=[avg_decision_rts(:,4)' avg_error_rts(:,4)'];    

no_avg_decision_rts1(i)=(avg_decision_rts(i,1)-nanmin(g1))/(nanmax(g1)-nanmin(g1));
no_avg_decision_rts2(i)=(avg_decision_rts(i,2)-nanmin(g2))/(nanmax(g2)-nanmin(g2));
no_avg_decision_rts3(i)=(avg_decision_rts(i,3)-nanmin(g3))/(nanmax(g3)-nanmin(g3));
no_avg_decision_rts4(i)=(avg_decision_rts(i,4)-nanmin(g4))/(nanmax(g4)-nanmin(g4));

no_avg_error_rts1(i)=(avg_error_rts(i,1)-nanmin(g1))/(nanmax(g1)-nanmin(g1));
no_avg_error_rts2(i)=(avg_error_rts(i,2)-nanmin(g2))/(nanmax(g2)-nanmin(g2));
no_avg_error_rts3(i)=(avg_error_rts(i,3)-nanmin(g3))/(nanmax(g3)-nanmin(g3));
no_avg_error_rts4(i)=(avg_error_rts(i,4)-nanmin(g4))/(nanmax(g4)-nanmin(g4));

end
no_avg_error_rts1(1,6:end)=nan;
no_avg_error_rts2(1,6:end)=nan;
no_avg_error_rts3(1,6:end)=nan;
no_avg_error_rts4(1,6:end)=nan;

figure,
plot(I,no_avg_decision_rts2,'o-','LineWidth',2,'MarkerSize',6,'color','b')
hold on
plot(I,no_avg_error_rts2,'o--','LineWidth',2,'MarkerSize',6,'color','b')
hold on
plot(I,no_avg_decision_rts3,'o-','LineWidth',2,'MarkerSize',6,'color','r')
hold on
plot(I,no_avg_error_rts3,'o--','LineWidth',2,'MarkerSize',6,'color','r')
hold on
plot(I,no_avg_decision_rts4,'o-','LineWidth',2,'MarkerSize',6,'color','m')
hold on
plot(I,no_avg_error_rts4,'o--','LineWidth',2,'MarkerSize',6,'color','m')
legend('Condition 1 (correct)','Condition 1 (error)','Condition 2 (correct)','Condition 2 (error)','Condition 3 (correct)','Condition 3 (error)')
xlabel('(I_1-I_2)/(I_1+I_2)', 'FontSize', 16)
ylabel('Normalized decision time', 'FontSize', 16)
set(gca, 'FontSize', 16);
axis square
legend boxoff