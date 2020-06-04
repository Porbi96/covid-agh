close all, clear all;

alpha = 0;
sigma = 0.9;
beta = 0.2;
delta = 0.2;
eta1 = 0.05;
eta2 = 0.4;
gamma1 = 0.2;
gamma2 = 0.05;
lambda1 = 0.6;
lambda2 = 0.8;
kappa1 = 0.02;
kappa2 = 0.3;

Npop = 80e6;
E0 = 100;
I1_0 = 10;
I2_0 = 1;
Q0 = 0;
H0 = 0;
R0 = 0;
D0 = 0;

dt = 0.1; % time step
time1 = datetime(2010,01,01,0,0,0):dt:datetime(2010,03,01,0,0,0);
N = numel(time1);
t = [0:N-1].*dt;

[S,E,I1,I2,Q,H,R,D] = SEIQRDP(alpha,sigma,beta,delta,eta1,eta2,gamma1,gamma2,lambda1,kappa1,lambda2,kappa2,Npop,E0,I1_0,I2_0,Q0,H0,R0,D0,t);

plot(t,E);