import pandas as pd
import numpy as np
from urllib.request import Request, urlopen

# 01. Functions
# ---------------------------------------------------------
def strip_colnames(col_l1, col_l2):
    """Parse column names from multiindex dataframe."""
    cols = []
    for l1, l2 in zip(col_l1, col_l2):
        cols.append("_".join([l1,l2]).replace(" ", "_").lower())
    cols2 = []
    for idx, val in enumerate(cols):
        cols2.append(val.replace(f"unnamed:_{idx}_level_0_","").replace("strength_of_schedule", "sos"))
    return cols2

def pythag(off_rate, def_rate, expon=10.25):
    """Calculate the pythagorean win expectation."""
    return off_rate ** expon / (off_rate ** expon + def_rate ** expon)

def log5(home=100.0, away=100.0):
    """Calculate the log5 win expectation."""
    return home * (1 - away) / (home * (1 - away) + (1 - home) * away)

def expected_tempo(home_tempo, away_tempo, avg_tempo):
    """Calculate the expected tempo."""
    return (home_tempo * away_tempo) / avg_tempo

def expected_score(home=(100, 100), away=(100, 100), ncaa_adjo=100, expected_tempo=67.5):
    """Calculate the expected game score."""
    home_score = round(home[0] * away[1] / ncaa_adjo * (expected_tempo / 100), 3)
    away_score = round(away[0] * home[1] / ncaa_adjo * (expected_tempo / 100), 3)
    return (home_score, away_score)

def pull_comparison(df, str1, str2):
    """Pull the comparison data for two teams."""
    d1 = df[df.team.str.contains(str1)]
    d2 = df[df.team.str.contains(str2)]
    return pd.concat([d1, d2])

def summarize_game(team1, team2, home_adj=0.014, ncaa_tempo=67.5, ncaa_adjo=100, expon=10.25):
    """
    Summarize the game.
    team1: dict(team, adjt, adjoe, adjde)
    team2: dict(team, adjt, adjoe, adjde)
    """
    home = (team1["adjo"], team1["adjd"])
    away = (team2["adjo"], team2["adjd"])
    adj_home = [home[0] * (1 + home_adj), home[1] * (1 - home_adj)]
    adj_away = [away[0] * (1 - home_adj), away[1] * (1 + home_adj)]
    home_py = pythag(adj_home[0], adj_home[1], expon=expon)
    away_py = pythag(adj_away[0], adj_away[1], expon=expon)
    return {
        'home_team': team1['team']
        , 'away_team': team2['team']
        , 'pwin_home': round(log5(home_py, away_py), 4)
        , 'tempo': round(expected_tempo(team1['adjt'], team2['adjt'], ncaa_tempo), 2)
        , 'score': expected_score(adj_home, adj_away, ncaa_adjo=ncaa_adjo, expected_tempo=ncaa_tempo)
    }
        

# 02. Scrape and Mung data
# ---------------------------------------------------------
url = "http://kenpom.com/"
req = Request(
    url=url, headers={'User-Agent': 'Mozilla/5.0'}
)
df = pd.read_html(urlopen(req).read())[0]
df.columns = strip_colnames(df.columns.get_level_values(0), df.columns.get_level_values(1))

# remove the rows which are headers vs data
idx = []
for i, val in enumerate(df["rk"]):
    if val == "Rk" or np.isnan(float(val)):
        idx.append(i)

df.drop(idx, inplace=True)
df.columns = [val + "_drop" if idx in [2,3] + list(range(6,22,2)) else val for idx, val in enumerate(df.columns)]
df.drop(columns=df.columns[[2,3] + list(range(6,22,2))], inplace=True)

# convert to numerics
df['rk'] = df['rk'].astype(int)
for col in df.columns[2:]:
    df[col] = df[col].astype(float)

# 03. Calculation playground
# ---------------------------------------------------------
ncaa_tempo = df.adjt.mean()
ncaa_adjo = df.adjo.mean()

pull_comparison(df, "Duke", "North Carolina") # get row index from this and input to below
summarize_game(
    df.iloc[8,:].to_dict()
    , df.iloc[7,:].to_dict()
    , home_adj=0
    , ncaa_tempo=ncaa_tempo
    , ncaa_adjo=ncaa_adjo
    , expon=10.25
)
