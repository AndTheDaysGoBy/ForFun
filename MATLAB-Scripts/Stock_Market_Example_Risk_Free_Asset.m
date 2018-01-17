%Takes in stock data from AAPL, COP, and FXI.
%rbar represents the expected returns of these stocks based off of a three
%month period.
%Similarly, cov represents the covariance matrix of these stocks where the
%rows are APPL, COP, and FXI, as are the columns.

%USER DEFINED:
%Target return (e.g. 150%).
rpbar = 1.5;
%return on the risk free asset (e.g. 10%).
rf = 0.1;
%delimit by:
del = 0.005;

%CORE PROGRAM:
%Return values.
rbar = [0.62; -1.36; -0.36];
%Covariance matrix.
cov = [0.2239 0.1547 0.1825; 0.1547 0.2684 0.2631; 0.1825 0.2631 0.4035];

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
