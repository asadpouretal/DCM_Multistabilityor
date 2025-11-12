function [f,J,Q] = spm_fx_erp(x,u,P,M)
% state equations for a neural mass model of erps for period-doubling
% FORMAT [f,J,D] = spm_fx_erp(x,u,P,M)
% FORMAT [f,J]   = spm_fx_erp(x,u,P,M)
% FORMAT [f]     = spm_fx_erp(x,u,P,M)
% x      - state vector
%   x(:,1) - voltage (spiny stellate cells):    e1
%   x(:,2) - voltage (pyramidal cells):         e2
%   x(:,3) - voltage (inhibitory interneurons): i

%
% f        - dx(t)/dt  = f(x(t))
% J        - df(t)/dx(t)
% D        - delay operator dx(t)/dt = f(x(t - d))
%                                    = D(d)*f(x(t))
%
% Prior fixed parameter scaling [Defaults]
%
%  M.pF.E = [32 16 4];           % extrinsic rates (forward, backward, lateral)
%  M.pF.H = [1 4/5 1/4 1/4]*128; % intrinsic rates (g1, g2 g3, g4)
%  M.pF.D = [2 16];              % propogation delays (intrinsic, extrinsic)
%  M.pF.G = [4 32];              % receptor densities (excitatory, inhibitory)
%  M.pF.T = [8 16];              % synaptic constants (excitatory, inhibitory)
%  M.pF.R = [1 1/2];             % parameter of static nonlinearity
%
%__________________________________________________________________________
% David O, Friston KJ (2003) A neural mass model for MEG/EEG: coupling and
% neuronal dynamics. NeuroImage 20: 1743-1755
%___________________________________________________________________________
% Copyright (C) 2005 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_fx_erp.m 5369 2013-03-28 20:09:27Z karl $


% get dimensions and configure state variables
%--------------------------------------------------------------------------
n = length(P.A{1});         % number of sources

x = spm_unvec(x,M.x);       % neuronal states

% [default] fixed parameters
%--------------------------------------------------------------------------
E = [1 1 1]*32;         % extrinsic rates (forward, backward, lateral) %% OK
% G = [1 4/5 1/4 1/4]*128;    % intrinsic rates (g1 g2 g3 g4)

% best model of sFSM
% G = [1 4/5 1/8 1/8 1/1000 1/1000 1/1000]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)


 % model 2 tFSM
%  G = [1 4/5 1/8 1/8 1e-4 1e-4 1e-4]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

% model 3 tFSM Vahab
% G = [1 4/5 1/8 1/8 1/1000 1/1000 1/1000]*132;     % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

J_ex1_ex1=0.375;
J_IN1_ex1=1.4;
J_ex1_IN1=0.475;
J_IN1_IN1=3;
J_exx2_ex1=0.01;
J_exx2_exx2=0.01;
J_ex1_exx2=0.01;

const_ex1 = 0.8 * 10000 * 0.2 / (1 + exp((2 - 10) / 3));
c6=const_ex1 * J_exx2_exx2;
c1=const_ex1 * J_ex1_exx2;
c7=const_ex1 * J_ex1_ex1;
c3=0.2 * 10000 * 0.2 * J_IN1_ex1;
c2=const_ex1 * J_exx2_ex1;
c4=0.8 * 10000 * 0.2 * J_ex1_IN1; 
c5=0.2 * 10000 * 0.2 * J_IN1_IN1;


% model 3 tFSM Abdoreza and Amin
G = [c1 c2 c3 c4 c5 c6 c7];        % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)
% inhibitory_to_excitatory_ratio = [144/74.8025; 144/74.8025];   % inhibitory to excitatory extrinsic connection ratio to each region


D = [0 0];                 % propogation delays (intrinsic, extrinsic) %% Delay is zero for the simulated data
H = [3.25 22];                 % receptor densities (excitatory, inhibitory)    
T = [0.02 0.01];                 % synaptic constants (excitatory, inhibitory)  % OK     
R = [1/5 30 1/2];                % parameters of static nonlinearity  (excitatory gm^-1, V*, inhibitory g^-1)               

% [specified] fixed parameters
%--------------------------------------------------------------------------
if isfield(M,'pF')
    try, E = M.pF.E; end
    try, G = M.pF.H; end
    try, D = M.pF.D; end
    try, H = M.pF.G; end
    try, T = M.pF.T; end
    try, R = M.pF.R; end
end


% test for free parameters on intrinsic connections
%--------------------------------------------------------------------------
try
    G = G.*exp(P.H);
end
G     = ones(n,1)*G;

% exponential transform to ensure positivity constraints
%--------------------------------------------------------------------------
A{1}  = exp(P.A{1})*E(1);
A{2}  = exp(P.A{2})*E(2);
A{3}  = exp(P.A{3})*E(3);
C     = exp(P.C);

% intrinsic connectivity and parameters
%--------------------------------------------------------------------------
Te    = T(1)*exp(P.T(:,1));         % excitatory time constants         %OK
Ti    = T(2)*exp(P.T(:,2));         % inhibitory time constants         %OK
He    = H(1)*exp(P.G(:,1));              % excitatory receptor density
Hi    = H(2)*exp(P.G(:,2));              % inhibitory receptor density

% pre-synaptic inputs: s(V)
%--------------------------------------------------------------------------
R     = R.*exp([P.S P.S(1)]);
S(:, 1:2)     = 70./(1 + exp(-R(1)*(x(:, 1:2) - R(2)))) + 0.1;          %OK
S(:, 3)     = 70./(1 + exp(-R(3)*(x(:, 3) - R(2)))) + 0.1;              %OK

% input
%==========================================================================
if isfield(M,'u')
    
    % endogenous input
    %----------------------------------------------------------------------
    U = u(:)*64;
    
else
    % exogenous input
    %----------------------------------------------------------------------
    U = C*u(:)*2;
end


% State: f(x)
%==========================================================================

% Supragranular layer (inhibitory interneurons): Voltage & depolarizing current
% %--------------------------------------------------------------------------
% f(:,7) = x(:,8);
% f(:,8) = (He.*((A{2} + A{3})*S(:,9) + G(:,3).*S(:,9)) - 2*x(:,8) - x(:,7)./Te)./Te;
% 
% % Granular layer (spiny stellate cells): Voltage & depolarizing current
% %--------------------------------------------------------------------------
% f(:,1) = x(:,4);
% f(:,4) = (He.*((A{1} + A{3})*S(:,9) + G(:,1).*S(:,9) + U) - 2*x(:,4) - x(:,1)./Te)./Te;
% 
% % Infra-granular layer (pyramidal cells): depolarizing current
% %--------------------------------------------------------------------------
% f(:,2) = x(:,5);
% f(:,5) = (He.*((A{2} + A{3})*S(:,9) + G(:,2).*S(:,1)) - 2*x(:,5) - x(:,2)./Te)./Te;
% 
% % Infra-granular layer (pyramidal cells): hyperpolarizing current
% %--------------------------------------------------------------------------
% f(:,3) = x(:,6);
% f(:,6) = (Hi.*G(:,4).*S(:,7) - 2*x(:,6) - x(:,3)./Ti)./Ti;
% 
% % Infra-granular layer (pyramidal cells): Voltage
% %--------------------------------------------------------------------------
% f(:,9) = x(:,5) - x(:,6);



% (spiny stellate cells): membrane potential
%--------------------------------------------------------------------------
f(:,1) = -x(:, 1)./Te + G(:, 6).* S(:, 1) + G(:, 1).* S(:, 2) + A{2} * S(:, 2) + A{1} * S(:, 1) + U; %(He.*((A{1} + A{3})*S(:,17) + G(:,1).*(S(:,17)) + U)    - 2*x(:,8)  - x(:,1)./Te)./Te;    %OK

% (pyramidal cells): membrane potential
%--------------------------------------------------------------------------
f(:,2) = -x(:, 2)./Te + G(:, 7).* S(:, 2) + A{3} * S(:, 2) + G(:, 2).* S(:, 1) - G(:, 3).* S(:, 3); %(He.*((A{2})*S(:,17) + G(:,2).*(S(:,15)))        - 2*x(:,9)  - x(:,2)./Te)./Te;            %OK

% (inhibitory interneurons): membrane potential
%--------------------------------------------------------------------------
f(:,3) = -x(:, 3)./Ti + G(:, 4).* S(:, 2) + A{3} * S(:, 2) - G(:, 5).* S(:, 3) + A{2} * S(:, 1) + U; %(Hi.*G(:,3).*(S(:,16))         - 2*x(:,10) - x(:,3)./Ti)./Ti;                             %OK


f      = spm_vec(f);

if nargout < 2; return, end

% Jacobian
%==========================================================================
J  = spm_diff(M.f,x,u,P,M,1);

% delays
%==========================================================================
% Delay differential equations can be integrated efficiently (but
% approximately) by absorbing the delay operator into the Jacobian
%
%    dx(t)/dt     = f(x(t - d))
%                 = Q(d)f(x(t))
%
%    J(d)         = Q(d)df/dx
%--------------------------------------------------------------------------
neural_state_number = size(x, 2);
De = D(2).*exp(P.D)/1000;
Di = D(1)/1000;
De = (1 - speye(n,n)).*De;
Di = (1 - speye(neural_state_number, neural_state_number)).*Di;
De = kron(ones(neural_state_number, neural_state_number),De);
Di = kron(Di,speye(n,n));
D  = Di + De;

% Implement: dx(t)/dt = f(x(t - d)) = inv(1 + D.*dfdx)*f(x(t))
%                     = Q*f = Q*J*x(t)
%--------------------------------------------------------------------------
Q  = inv(speye(length(J)) + D.*J);




% G = [3/5 3/5 1/8 1/8 1/500 1/1000 1/1000]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)


% model 8
% G = [4/5 4/5 1/8 1/8 1/100 1/100 1/100]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

% model 9
% G = [1 4/5 1/8 1/8 1/1000 1/1000 1/1000]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7

% model 10
% G = [1.5 1.5 1/2 1/2 1/1000 1/1000 1/1000]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

% model 11
% G = [1.2 1.2 1/8 1/8 1/500 1/1000 1/1000]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

% model 12
% G = [2 2 1/2 1/2 1/500 1/1000 1/1000]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

% model 13
%G = [1.2 1.2 1/8 1/8 1/100 1/100 1/100]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

% model 14
% G = [2 2 1/2 1/2 1/10 1/10 1/10]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

% model 15
%G = [1.5 1.5 1/2 1/2 1/1000 1/1000 1/1000]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

% model 16
%G = [1.5 1.2 1/2 1/2 1/1000 1/1000 1/1000]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

% model 17
%G = [1.2 1.2 1/2 1/2 1/1000 1/1000 1/1000]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

% model 18
%G = [1.2 1.2 1/2 1/2 1/500 1/1000 1/1000]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

% model 19
%G = [1.5 1.2 1/2 1/2 1/500 1/1000 1/1000]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

% model 20
% G = [1.2 1.2 1/8 1/8 1/1000 1/1000 1/1000]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

% model 21
%G = [1.2 1.2 1/8 1/8 1/500 1/1000 1/1000]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

% model 22
% G = [1.5 1.2 1/8 1/8 1/500 1/1000 1/1000]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

% model 23
% G = [1.2 1.2 1/8 1/8 1/500 1/500 1/500]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)

% model 25
% G = [1 4/5 1/4 1/4 1/1000 1/1000 1/1000]*128;    % intrinsic rates (g1 g2 g3 g4 g5 g6 g7)
