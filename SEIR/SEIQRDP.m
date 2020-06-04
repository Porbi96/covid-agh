function [S,E,I1,I2,Q,H,R,D] = SEIQRDP(alpha,sigma,beta,delta,eta1,eta2,gamma1,gamma2,lambda1,kappa1,lambda2,kappa2,Npop,E0,I1_0,I2_0,Q0,H0,R0,D0,t)
% [S,E,I,Q,R,D,P] = SEIQRDP(alpha,beta,gamma,delta,lambda,kappa,Npop,E0,I0,R0,D0,t,lambdaFun)
% simulate the time-histories of an epidemic outbreak using a generalized
% SEIR model.
%
% Input
%
%   alpha: scalar [1x1]: fitted protection rate
%   beta: scalar [1x1]: fitted  infection rate
%   gamma: scalar [1x1]: fitted  Inverse of the average latent time
%   delta: scalar [1x1]: fitted  rate at which people enter in quarantine
%   lambda: scalar [1x1]: fitted  cure rate
%   kappa: scalar [1x1]: fitted  mortality rate
%   Npop: scalar: Total population of the sample
%   E0: scalar [1x1]: Initial number of exposed cases
%   I0: scalar [1x1]: Initial number of infectious cases
%   Q0: scalar [1x1]: Initial number of quarantined cases
%   R0: scalar [1x1]: Initial number of recovered cases
%   D0: scalar [1x1]: Initial number of dead cases
%   t: vector [1xN] of time (double; it cannot be a datetime)
%   lambdaFun: anonymous function giving the time-dependant recovery rate
%   kappaFun: anonymous function giving the time-dependant death rate
% 
% Output
%   S: vector [1xN] of the target time-histories of the susceptible cases
%   E: vector [1xN] of the target time-histories of the exposed cases
%   I: vector [1xN] of the target time-histories of the infectious cases
%   Q: vector [1xN] of the target time-histories of the quarantinedcases
%   R: vector [1xN] of the target time-histories of the recovered cases
%   D: vector [1xN] of the target time-histories of the dead cases
%   P: vector [1xN] of the target time-histories of the insusceptible cases
%
% Author: E. Cheynet - UiB - last modified 27-04-2020
%
% see also fit_SEIQRDP.m

%% Initial conditions
N = numel(t);
Y = zeros(8,N);
Y(1,1) = Npop - Q0 - H0 - E0 - R0 - D0 - I1_0 - I2_0;
Y(2,1) = E0;
Y(3,1) = I1_0;
Y(4,1) = I2_0;
Y(5,1) = Q0;
Y(6,1) = H0;
Y(7,1) = R0;
Y(8,1) = D0;

A = zeros(8,8);
F = zeros(8,1);

A(1,1) = -alpha;
A(2,2) = -beta;
A(3,2) = beta;
A(3,3) = (-delta-eta1);
A(4,3) = delta;
A(4,4) = (-eta2-gamma1);
A(5,3) = eta1;
A(5,4) = eta2;
A(5,5) = (-gamma2-lambda1-kappa1);
A(6,4) = gamma1;
A(6,5) = gamma2;
A(6,6) = (-lambda2-kappa2);
A(7,5) = lambda1;
A(7,6) = lambda2;
A(8,5) = kappa1;
A(8,6) = kappa2;

F(1,1) = -sigma/Npop;
F(2,1) = sigma/Npop;

if round(sum(Y(:,1))-Npop)~=0
    error(['the sum must be zero because the total population',...
        ' (including the deads) is assumed constant']);
end
%% Computes the eight states
modelFun = @(Y,A,F) A*Y + F;
dt = median(diff(t));

% ODE resolution

for ii=1:N-1
    SI = Y(1,ii)*(Y(3,ii));
    F = F.*SI;
    Y(:,ii+1) = RK4(modelFun,Y(:,ii),A,F,dt);
end

% Y = round(Y);
%% Write the outputs
S = Y(1,1:N);
E = Y(2,1:N);
I1 = Y(3,1:N);
I2 = Y(4,1:N);
Q = Y(5,1:N);
H = Y(6,1:N);
R = Y(7,1:N);
D = Y(8,1:N);
% P = Y(7,1:N);


%% Nested functions
    function [A] = getA(alpha,gamma,delta,lambda,kappa)
        %  [A] = getA(alpha,gamma,delta,lambda,kappa) computes the matrix A
        %  that is found in: dY/dt = A*Y + F
        %
        %   Inputs:
        %   alpha: scalar [1x1]: protection rate
        %   beta: scalar [1x1]: infection rate
        %   gamma: scalar [1x1]: Inverse of the average latent time
        %   delta: scalar [1x1]: rate of people entering in quarantine
        %   lambda: scalar [1x1]: cure rate
        %   kappa: scalar [1x1]: mortality rate
        %   Output:
        %   A: matrix: [7x7]
        A = zeros(7);
        % S
        A(1,1) = -alpha;
        % E
        A(2,2) = -gamma;
        % I
        A(3,2:3) = [gamma,-delta];
        % Q
        A(4,3:4) = [delta,-kappa-lambda];
        % R
        A(5,4) = lambda;
        % D
        A(6,4) = kappa;
        % P
        A(7,1) = alpha;
    end
    function [Y] = RK4(Fun,Y,A,F,dt)
        % Runge-Kutta of order 4
        k_1 = Fun(Y,A,F);
        k_2 = Fun(Y+0.5*dt*k_1,A,F);
        k_3 = Fun(Y+0.5*dt*k_2,A,F);
        k_4 = Fun(Y+k_3*dt,A,F);
        % output
        Y = Y + (1/6)*(k_1+2*k_2+2*k_3+k_4)*dt;
    end
end


