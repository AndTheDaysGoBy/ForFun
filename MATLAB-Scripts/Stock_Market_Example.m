%Takes in stock data from AAPL, COP, and FXI.
%rbar represents the expected returns of these stocks based off of a three
%month period.
%Similarly, cov represents the covariance matrix of these stocks where the
%rows are APPL, COP, and FXI, as are the columns.

%USER DEFINED:
%Target return (e.g. 150% return).
rpbar = 1.5;

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
B = [zeros(size(one, 1), 1); rpbar; 1];

%[[w1; ...; wn]; lambda; mu] where lambda/mu are Lagrangian.
%The wi are the Markowitz weights.
x = inv(A)*B
