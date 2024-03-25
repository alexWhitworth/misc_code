import pandas as pd
import numpy as np
from scipy.stats import norm 

# example data
np.random.seed(123)
click_control = np.random.randint(0,20,10000)
view_control = np.random.randint(1,60,10000)

click_treatment = np.random.randint(0,21,10000)
view_treatment = np.random.randint(1,60,10000)

control = pd.DataFrame({'click':click_control,'view':view_control})
treatment = pd.DataFrame({'click':click_treatment,'view':view_treatment})


def var_ratio(x, y): 
    """
    Variance for ratio using delta method:
        V(g(X,Y)) = (mean(X)^2 / mean(Y)^2 * N) * (V(X) / mean(X)^2 + V(Y) / mean(Y)^2 - 2*Cov(X,Y)/(mean(X)*mean(Y))
        where G(X,Y) = X/Y and N = len(X) = len(Y)
    Params:
        x: array-like
        y: array-like
    """
    mean_x = np.mean(x)
    mean_y = np.mean(y)
    var_x = np.var(x,ddof=1) # ddof=1 --> sample vs population variance
    var_y = np.var(y,ddof=1)
    cov_xy = np.cov(x,y,ddof=1)[0][1] # ddof=1 --> sample vs population covariance
    return (mean_x*mean_x)/(mean_y*mean_y*len(x)) * (var_x/mean_x**2 + var_y/mean_y**2 - 2*cov_xy/(mean_x*mean_y))


def ttest(mean_c, mean_t, var_c, var_t, alpha=0.05):
    """
    Perform a two-sample t-test using means and variances.

    Parameters:
    mean_c (float): Mean of the control group.
    mean_t (float): Mean of the treatment group.
    var_c (float): Variance of the control group.
    var_t (float): Variance of the treatment group.
    alpha (float, optional): Significance level for the confidence interval. Default is 0.05.

    Returns:
    dict: A dictionary containing the following results:
        - 'delta' (float): Difference between the means (mean_t - mean_c).
        - 'ci' (tuple): Confidence interval for the difference between the means.
        - 'p_value' (float): Two-tailed p-value for the t-test.
        - 'z_stat' (float): Z-statistic for the t-test.
    """
    delta = mean_t - mean_c
    se = np.sqrt(var_c + var_t)
    lower = delta - norm.ppf(1 - alpha / 2) * se 
    upper = delta + norm.ppf(1 - alpha / 2) * se
    z = delta / se
    p_val = norm.sf(abs(z))*2
    # return
    return {'delta': delta
            , 'pct_delta': delta / mean_c if mean_c != 0.0 else np.nan
            , 'ci': (lower, upper)
            , 'p_value': p_val
            , 'z_stat': z
    }


var_control = var_ratio(control['click'],control['view'])
var_treatment = var_ratio(treatment['click'],treatment['view'])
mean_control = control['click'].sum()/control['view'].sum()
mean_treatment = treatment['click'].sum()/treatment['view'].sum()

ttest(mean_control,mean_treatment,var_control,var_treatment)