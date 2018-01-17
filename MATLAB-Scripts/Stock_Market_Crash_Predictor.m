%Take the stock data from January 2, 2008 - 100 trading days, all the way
%until December 31, 2012. The stocks considered are AAPL, AMZN, NFLX, MSFT,
%PCLN, IBM, CSCO, INTC, BIDU, and YHOO.
%The purpose of this program is to see if this type of "prediction"
%algorithm properly predicts the crash of '08-'09 (as well as the rest of
%the general stock trends of the period).
%The algorithm varies in two  ways, how many past prices to use in
%constructing the model to be used in a trade (M) and how many trade days 
%between trades.
%The model will work by constructing a mean-covariance model w.r.t. (M, N)
%and then determining how to trade based off of what weights maximize the
%Sharpe ratio.

%USER DEFINED:
%How many days of adjusted daily closing prices to hold for.
N = 3;
%How many of the previous closing prices to use in rebalancing the predicting model.
M = 4; %Assume max of 100.
%Initial amount of money (e.g. $1 billion).
V(1) = 10^9;
%Adjusted daily closing prices matrix.
ADJCP = xlsread("ADJCP.xlsx", "B:K"); %Ignore date
%How many weights to generate for the Monte-Carlo approximation.
ITER = 10^4;

%CORE PROGRAM:
%Compute daily returns. (today - prev)/prev.
daily_returns = dailyReturns(ADJCP);

trading_days = 1; %Starts at 2 due to index-1 of MATLAB
for day=(100 + 1):size(ADJCP, 1)
    k = day - 100;
    
    %Trade
    if (mod((k - 1), N) == 0)
        %No prior investment in the first trade.
        if (k > 1)
            %Get ROI:
            ROIs = (ADJCP(day-1,:)-ADJCP(day-N,:))./ADJCP(day-N,:);
            V(trading_days) = sum(investments + investments.*ROIs');
        end
        
        %Update the model:
        %Past M days of dialy returns (i.e. M-1 items).
        M_days = daily_returns((day-M):(day-2),:);
        %Compute cov matrix using past M trading days.
        stock_cov = cov(M_days);
        %Compute expected returns of each stock.
        expected_returns = mean(M_days)';
        
        %Obtain the best weights (maximize Sharpe ratio).
        allWeights = weights(size(ADJCP,2), ITER);
        max_sharpe = -1;
        for j=1:ITER
            sharpe = mySharpe(allWeights(:,j), expected_returns, stock_cov, 0);
            if (max_sharpe < sharpe)
                max_sharpe = sharpe;
                best_weights = allWeights(:,j);
            end
        end
        
        %Re-invest
        investments = V(trading_days)*best_weights;
        trading_days = trading_days + 1;
    end
end
plot(V)


%Construct the daily returns of a matrix whose columns are stocks and rows
%observed adjusted closing prices. Obviously excludes that of the first day.
%Assume olderest in first row.
function d = dailyReturns(M)
    yesterday = M(1:(end-1),:);
    d = (M(2:end,:)-yesterday)./yesterday;
end
    
    
%Generate Monte-Carlo weights. Each column is a set of weights.
%Satisfies sum(|w_i|) <= 1.
function w = weights(num_weights, iterations)
    abs_sum = zeros([1,iterations]);
    w = zeros([num_weights, iterations]);
    for j=1:num_weights
        for i=1:iterations
            w(j,i) = 2*(1 - abs_sum(i))*rand - (1 - abs_sum(i));
            abs_sum(i) = abs_sum(i) + abs(w(j,i));
        end
    end
end

%calculate sharpe ratio. Assume column vectors.
function s = mySharpe(weights, expectedReturns, cov_matrix, riskFreeAsset)
    adjustedReturn =(weights'*expectedReturns) - riskFreeAsset;
    std = sqrt(weights'*cov_matrix*weights);
    s = adjustedReturn/std;
end
