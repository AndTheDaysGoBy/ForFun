%Have a betting wheel split into three parts,  win A = $3, B = $2, and C = $6.
%A has a 1/2 chance of occurring, B has a 1/3 chance, and C has a 1/6 chance.
%rbar represents the expected values E[A], E[B], and E[C].
%sigma is the covariance matrix rows are (A-C) and columns are (A-C) from upper left.

%USER DEFINED:
%Target return (e.g. 25%).
rpbar = 0.25;

%CORE PROGRAM:
%Return values.
rbar = [0.5 ; -1/3 ; 0];
%Covariance matrix.
Sigma = [2.25 -1 -1.5; -1 0.889 -2/3; -1.5 -2/3 5];

one = ones(size(rbar));
oneT = one';
rbarT = rbar';
zero = zeros(size([rbarT; oneT], 1), size([rbar one], 2));

temp1 = [Sigma  rbar one];
temp2 = [rbarT; oneT];
temp3 = [temp2 zero];
A = [temp1; temp3];
B = [zeros(size(one, 1), 1); rpbar; 1];

%[[w1; ...; wn]; lambda; mu] where lambda/mu are Lagrangian.
%The w_i are the Markowitz weights.
x = inv(A)*B
