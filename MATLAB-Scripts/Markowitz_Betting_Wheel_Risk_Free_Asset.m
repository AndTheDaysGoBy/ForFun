%Have a betting wheel split into three parts,  win A = $3, B = $2, and C = $6.
%A has a 1/2 chance of occurring, B has a 1/3 chance, and C has a 1/6 chance.
%rbar represents the expected values E[A], E[B], and E[C].
%sigma is the covariance matrix rows are (A-C) and columns are (A-C) from upper left.
%Suppose there is a risk free asset to invest in as well. The return is
%given by rf.
%del tells by how much to step in an attempt to find an optimal balance
%between investing in the risk free asset and the betting wheel.

%USER DEFINED:
%Target return (e.g. 25%).
rpbar = 0.25;
%return on the risk free asset (e.g. 10%).
rf = 0.1;
%delimit by:
del = 0.005;

%CORE PROGRAM:
%Return values.
rbar = [0.5 ; -1/3 ; 0];
%Covariance matrix.
cov = [2.25 -1 -1.5; -1 0.889 -2/3; -1.5 -2/3 5];

one = ones(size(rbar));
oneT = one';
rbarT = rbar';
zero = zeros(size([rbarT; oneT], 1), size([rbar one], 2));
temp1 = [cov  rbar one];
temp2 = [rbarT; oneT];
temp3 = [temp2 zero];
A = [temp1; temp3];

risk = inf;
for alpha=0:del:1
    rpbaradjusted = rpbar - alpha*rf*ones(size(rpbar, 1), 1);
    B = [zeros(size(one, 1), 1); rpbaradjusted; 1 - alpha];
    X = inv(A)*B;
    
    %Obtain weights for this alpha: see if it minimizes the risk.
    weights  = X(1 : size(X, 1) - 2);
    std_a = sqrt(weights'*cov*weights);
    if (std_a < risk)
        risk = std_a;
        bestweights = [weights ; alpha]; %column of weights, risk free at end.
    end
end

%[[w1; ...; wn]; alpha] where alpha is the weight of the risk-free asset.
%The wi are the Markowitz weights.
bestweights
