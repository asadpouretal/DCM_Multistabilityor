function dy = NET_period_doubling(t, y,t_input1,I_input1,t_input2,I_input2)

I_inputt1 = interp1(t_input1, I_input1,t);
I_inputt2 = interp1(t_input2, I_input2,t);


dy = zeros(6,1);


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%             THALAMOCORTICAL   NETWORK                   %              
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%                   SYNAPTIC STRENGTHS                    %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%                        CORTEX                   %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

J_ex1_ex1=0.375;

J_IN1_ex1=1.4;

J_ex2_ex2=0.375;

J_IN2_ex2=1.4;


J_ex1_ex2=0.05;

J_ex1_IN2=0.09;

J_ex2_ex1=0.05;


J_ex2_IN1=0.09;

J_ex1_IN1=0.475;


J_IN1_IN1=0.5;

J_IN2_IN2=0.5;




J_ex2_IN2=0.475;

J_exx2_ex1=0.01;
J_exx2_exx2=0.01;
J_ex1_exx2=0.01;




%%
% Constant terms derived from the original equations


const_ex1 = 0.8 * 10000 * 0.2 / (1 + exp((2 - 10) / 3));
const_ex2 = 0.8 * 10000 * 0.2 / (1 + exp((2 - 10) / 3));
c6=const_ex1 * J_exx2_exx2;
c1=const_ex1 * J_ex1_exx2;
c7=const_ex1 * J_ex1_ex1;
c3=0.2 * 10000 * 0.2 * J_IN1_ex1;
cee=const_ex1 * J_ex2_ex1;
c2=const_ex1 * J_exx2_ex1;
c4=0.8 * 10000 * 0.2 * J_ex1_IN1; 
c5=0.2 * 10000 * 0.2 * J_IN1_IN1;
cei=0.8 * 10000 * 0.2* J_ex2_IN1;
c6p = const_ex2 * J_exx2_exx2;
c1p=const_ex2 * J_ex1_exx2;
c7p=const_ex2 * J_ex2_ex2;
c3p=0.2 * 10000 * 0.2 * J_IN2_ex2;
c2p=const_ex2 * J_exx2_ex1;
ceep=const_ex2 * J_ex1_ex2;
c4p=0.8 * 10000 * 0.2 * J_ex2_IN2;
c5p=0.2 * 10000 * 0.2 * J_IN2_IN2;
ceip=0.8 * 10000 * 0.2 * J_ex1_IN2;
dy(1) = -y(1) / 0.02 + c6 * (70/ (1 + exp(-(y(1) - 30) / 5)) + 0.1) ...
        + c1 * (70/ (1 + exp(-(y(2) - 30) / 5)) + 0.1);

dy(2) = -y(2) / 0.02 + c7 * (70 / (1 + exp(-(y(2) - 30) / 5)) + 0.1) ...
        - c3 * (70 / (1 + exp(-(y(3) - 30) / 2)) + 0.1) ...
        + cee * (70/ (1 + exp(-(y(5) - 30) / 5)) + 0.1) ...
        + c2 * (70/ (1 + exp(-(y(1) - 30) / 5)) + 0.1) ...
        + I_inputt1;                                                      % Why input is divided by 0.1?

dy(3) = -y(3) / 0.01 + c4* (70 / (1 + exp(-(y(2) - 30) / 5)) + 0.1) ...
        - c5 * (70 / (1 + exp(-(y(3) - 30) / 2)) + 0.1) ...
        + cei  * (70/ (1 + exp(-(y(5) - 30) / 5)) + 0.1) ...
        + I_inputt1;

dy(4) = -y(4) / 0.02 + c6p * (70 / (1 + exp(-(y(4) - 30) / 5)) + 0.1) ...
        + c1p * (70/ (1 + exp(-(y(5) - 30) / 5)) + 0.1);

dy(5) = -y(5) / 0.02 + c7p * (70 / (1 + exp(-(y(5) - 30) / 5)) + 0.1) ...
        - c3p * (70 / (1 + exp(-(y(6) - 30) / 2)) + 0.1) ...                    % We have two gm: 2 and 5. Why gm is changing? 
        + ceep * (70/ (1 + exp(-(y(2) - 30) / 5)) + 0.1) ...
        + c2p * (70/ (1 + exp(-(y(4) - 30) / 5)) + 0.1) ...
        + I_inputt2;

dy(6) = -y(6) / 0.01 + c4p * (70/ (1 + exp(-(y(5) - 30) / 5)) + 0.1) ...
        - c5p * (70 / (1 + exp(-(y(6) - 30) / 2)) + 0.1) ...
        + ceip * (70/ (1 + exp(-(y(2) - 30) / 5)) + 0.1)...
        + I_inputt2;


end


