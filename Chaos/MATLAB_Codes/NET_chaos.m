function dy = NET_chaos(t, y,t_input1,I_input1,t_input2,I_input2)

I_inputt1 = interp1(t_input1, I_input1,t); % Input to column 1

I_inputt2 = interp1(t_input2, I_input2,t); % Input to column 2


dy = zeros(6,1); % Initial condition

% Constants used for tuning the network. Please do not pay attention to these constants.

J_ex1_ex1=0.375;  

J_IN1_ex1=1.4;

J_ex2_ex2=0.375;

J_IN2_ex2=1.4;


J_ex1_ex2=0.05;

J_ex1_IN2=0.02;

J_ex2_ex1=0.05;


J_ex2_IN1=0.09;

J_ex1_IN1=0.475;


J_IN1_IN1=0.5;

J_IN2_IN2=0.5;


J_ex2_IN2=0.475;

J_exx2_ex1=0.01;

J_exx2_exx2=0.01;

J_ex1_exx2=0.01;


const_ex1 = 0.8 * 10000 * 0.2 / (1 + exp((2 - 10) / 3));

const_ex2 = 0.8 * 10000 * 0.2 / (1 + exp((4 - 10) / 3));


%%
% Constant terms derived from the original equations 


% Column 1


c1=const_ex1 * J_ex1_exx2; %Excitatory connection from e2 to e1

c2=const_ex1 * J_exx2_ex1; %Excitatory connection from e1 to e2

c3=0.2 * 10000 * 0.2 * J_IN1_ex1; %Inhibitory connection from i to e2

c4=0.8 * 10000 * 0.2 * J_ex1_IN1; %Excitatory connection from e2 to i

c5=0.2 * 10000 * 0.2 * J_IN1_IN1; %Self-feedback connection of i

c6=const_ex1 * J_exx2_exx2;  %Self-feedback connection of e1

c7=const_ex1 * J_ex1_ex1;    %Self-feedback connection of e2


%Between columns

cee=const_ex1 * J_ex2_ex1;   %Extrinisic connections from e2 in column 2 to e2 in column1 

ceep=const_ex1 * J_ex1_ex2;  %Extrinisic connections from e2 in column 1 to e2 in column2 

cei=0.8 * 10000 * 0.2* J_ex2_IN1; %Extrinisic connections from e2 in column 2 to i in column1 

ceip=0.8 * 10000 * 0.2 * J_ex1_IN2; %Extrinisic connections from e2 in column 1 to i in column2 


% Column 2


c1p=const_ex1 * J_ex1_exx2; %Excitatory connection from e2 to e1

c2p=const_ex1 * J_exx2_ex1; %Excitatory connection from e1 to e2

c3p=0.2 * 10000 * 0.2 * J_IN2_ex2; %Inhibitory connection from i to e2

c4p=0.8 * 10000 * 0.2 * J_ex2_IN2; %Excitatory connection from e2 to i

c5p=0.2 * 10000 * 0.2 * J_IN2_IN2; %Self-feedback connection of i

c6p = const_ex1 * J_exx2_exx2; %Self-feedback connection of e1

c7p=const_ex1 * J_ex2_ex2; %Self-feedback connection of e2


% Equations

%Column 1

dy(1) = -y(1) / 0.02 + c6 * (70/ (1 + exp(-(y(1) - 30) / 5)) + 0.1) ...         %Membrane potential of e1 
        + c1 * (70/ (1 + exp(-(y(2) - 30) / 5)) + 0.1) + I_inputt1;     

dy(2) = -y(2) / 0.02 + c7 * (70 / (1 + exp(-(y(2) - 30) / 5)) + 0.1) ...        %Membrane potential of e2
        - c3 * (70 / (1 + exp(-(y(3) - 30) / 2)) + 0.1) ...
        + cee * (70/ (1 + exp(-(y(5) - 30) / 5)) + 0.1) ...
        + c2 * (70/ (1 + exp(-(y(1) - 30) / 5)) + 0.1);

dy(3) = -y(3) / 0.01 + c4* (70 / (1 + exp(-(y(2) - 30) / 5)) + 0.1) ...         %Membrane potential of i
        - c5 * (70 / (1 + exp(-(y(3) - 30) / 2)) + 0.1) ...
        + cei  * (70/ (1 + exp(-(y(5) - 30) / 5)) + 0.1) ...
        + I_inputt1;

%Column 2

dy(4) = -y(4) / 0.02 + c6p * (70 / (1 + exp(-(y(4) - 30) / 5)) + 0.1) ...       %Membrane potential of e1
        + c1p * (70/ (1 + exp(-(y(5) - 30) / 5)) + 0.1) + I_inputt2;

dy(5) = -y(5) / 0.02 + c7p * (70 / (1 + exp(-(y(5) - 30) / 5)) + 0.1) ...       %Membrane potential of e2
        - c3p * (70 / (1 + exp(-(y(6) - 30) / 2)) + 0.1) ...
        + ceep * (70/ (1 + exp(-(y(2) - 30) / 5)) + 0.1) ...
        + c2p * (70/ (1 + exp(-(y(4) - 30) / 5)) + 0.1);

dy(6) = -y(6) / 0.01 + c4p * (70/ (1 + exp(-(y(5) - 30) / 5)) + 0.1) ...        %Membrane potential of i
        - c5p * (70 / (1 + exp(-(y(6) - 30) / 2)) + 0.1) ...
        + ceip * (70/ (1 + exp(-(y(2) - 30) / 5)) + 0.1)...
        + I_inputt2;


end


