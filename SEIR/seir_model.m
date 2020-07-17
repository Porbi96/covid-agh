clear all;
Npop = 6*10^7; % Total population N = S + I + R
I1_0 = 10; % initial number of infected
T = 300; % period of 300 days
dt = 1/4; % time interval of 6 hours (1/4 of a day)

isSelfProtection = 0;
isPublicProtection = 0;
ventilators = 25000;

if (isSelfProtection && isPublicProtection)
    sigma = 0.35;
    delta = 0.02;
    eta1 = 0.2;
    eta2 = 0.8;
    gamma1 = 0.2;
    gamma2 = 0.05;
    lambda1 = 0.6;
    lambda2 = 0.8;
    kappa1 = 0.02;
    kappa2 = 0.2;
elseif (~isSelfProtection && isPublicProtection)
    sigma = 0.7;
    delta = 0.02;
    eta1 = 0.2;
    eta2 = 0.8;
    gamma1 = 0.2;
    gamma2 = 0.05;
    lambda1 = 0.6;
    lambda2 = 0.8;
    kappa1 = 0.02;
    kappa2 = 0.2;
elseif (isSelfProtection && ~isPublicProtection)
    sigma = 0.4;
    delta = 0.02;
    eta1 = 0.1;
    eta2 = 0.3;
    gamma1 = 0.2;
    gamma2 = 0.05;
    lambda1 = 0.6;
    lambda2 = 0.8;
    kappa1 = 0.02;
    kappa2 = 0.2;
else
    sigma = 0.9;
    delta = 0.02;
    eta1 = 0.01;
    eta2 = 0.2;
    gamma1 = 0.2;
    gamma2 = 0.05;
    lambda1 = 0.6;
    lambda2 = 0.8;
    kappa1 = 0.02;
    kappa2 = 0.2;
end

beta = 0.1;

% Calculate the model
[S,E,I1,I2,Q,H,R,D] = sir_model(sigma,beta,delta,eta1,eta2,gamma1,gamma2,lambda1,lambda2,kappa1,kappa2,Npop,I1_0,ventilators,T,dt);

% Plots that display the epidemic outbreak
tt = 0:dt:T-dt;

plot(tt,S,tt,I1+I2,tt,Q,tt,H,tt,R,tt,D,'LineWidth',1); grid on;
xlabel('Days'); ylabel('Number of individuals');
legend('S','I','Q', 'H', 'R', 'D');

function [S,E,I1,I2,Q,H,R,D] = sir_model(sigma,beta,delta,eta1,eta2,gamma1,gamma2,lambda1,lambda2,kappa1,kappa2,Npop,I1_0,vents,T,dt)
    S = zeros(1,T/dt);
    E = zeros(1,T/dt);
    I1 = zeros(1,T/dt);
    I2 = zeros(1,T/dt);
    Q = zeros(1,T/dt);
    H = zeros(1,T/dt);
    R = zeros(1,T/dt);
    D = zeros(1,T/dt);
    
    S(1) = Npop;
    I1(1) = I1_0;
    
    for tt = 1:(T/dt)-1
        % Equations of the model
        dS = (-sigma*(I1(tt)+I2(tt))*S(tt)/(Npop)) * dt;
        dE = (sigma*(I1(tt)+I2(tt))*S(tt)/(Npop) - beta*E(tt)) * dt;
        dI1 = (beta*E(tt) - delta*I1(tt) - eta1*I1(tt)) * dt;
        dI2 = (delta*I1(tt) - eta2*I2(tt) - gamma1*I2(tt)) * dt;
        dQ = (eta1*I1(tt) + eta2*I2(tt) - gamma2*Q(tt) - lambda1*Q(tt) - kappa1*Q(tt)) * dt;
        dH = (gamma1*I2(tt) + gamma2*Q(tt) - lambda2*H(tt) - kappa2*H(tt)) * dt;
        dR = (lambda1*Q(tt) + lambda2*H(tt)) * dt;
        dD = (kappa1*Q(tt) + (2*(vents<H(tt)+1))*kappa2*H(tt)) * dt;
        S(tt+1) = S(tt) + dS;
        E(tt+1) = E(tt) + dE;
        I1(tt+1) = I1(tt) + dI1;
        I2(tt+1) = I2(tt) + dI2;
        Q(tt+1) = Q(tt) + dQ;
        H(tt+1) = H(tt) + dH;
        R(tt+1) = R(tt) + dR;
        D(tt+1) = D(tt) + dD;
    end
end