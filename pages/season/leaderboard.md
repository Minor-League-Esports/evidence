---
title: S19 Leaderboard
sidebar_position: 7
---

<LastRefreshed prefix="Data last updated"/>

```sql S19leaderboard2s
With playerstats as (
    Select name,
    salary as Salary,
    team_name as Team,
    s19.skill_group as league,
    "Primary Color" as primColor,
    CASE WHEN gamemode = 'RL_DOUBLES' THEN 'Doubles' WHEN gamemode = 'RL_STANDARD' THEN 'Standard' ELSE 'Unknown' END as GameMode,
    count(*) as games_played,
    avg(dpi) as Avg_DPI,
    avg(gpi) as sprocket_rating,
    avg(opi) as Avg_OPI,
    avg(score) as Score_Per_Game,
    avg(goals) as Goals_Per_Game,
    sum(goals) as total_goals,
    avg(assists) as Assists_Per_Game,
    sum(assists) as total_assists,
    avg(saves) as Saves_Per_Game,
    sum(saves) as total_saves,
    avg(shots) as Shots_Per_Game,
    avg(goals_against) as goals_against_per_game,
    avg(shots_against) as shots_against_per_game,
    sum(goals)/sum(shots) as shooting_pct2
 from players p
    inner join S19_stats s19
        on p.member_id = s19.member_id
    inner join teams t 
        on p.franchise = t.franchise

group by name, salary, team_name, league, primColor, gamemode)

SELECT
    name
    ,GameMode
    ,league
    ,games_played
    ,primColor
    ,${inputs.stats.value} as stat1

FROM playerstats

WHERE league='${inputs.leagueSelect}'
    AND GameMode='Doubles'
    AND games_played>='${inputs.gamesSlider}'

ORDER BY stat1 DESC

LIMIT 10
```

```sql S19leaderboard3s
With playerstats as (
    Select name,
    salary as Salary,
    team_name as Team,
    s19.skill_group as league,
    "Primary Color" as primColor,
    CASE WHEN gamemode = 'RL_DOUBLES' THEN 'Doubles' WHEN gamemode = 'RL_STANDARD' THEN 'Standard' ELSE 'Unknown' END as GameMode,
    count(*) as games_played,
    avg(dpi) as Avg_DPI,
    avg(gpi) as sprocket_rating,
    avg(opi) as Avg_OPI,
    avg(score) as Score_Per_Game,
    avg(goals) as Goals_Per_Game,
    sum(goals) as total_goals,
    avg(assists) as Assists_Per_Game,
    sum(assists) as total_assists,
    avg(saves) as Saves_Per_Game,
    sum(saves) as total_saves,
    avg(shots) as Shots_Per_Game,
    avg(goals_against) as goals_against_per_game,
    avg(shots_against) as shots_against_per_game,
    sum(goals)/sum(shots) as shooting_pct2
 from players p
    inner join S19_stats s19
        on p.member_id = s19.member_id
    inner join teams t 
        on p.franchise = t.franchise
group by name, salary, team_name, league, primColor, gamemode)

SELECT
    name
    ,GameMode
    ,league
    ,games_played
    ,primColor
    ,${inputs.stats.value} as stat1

FROM playerstats

WHERE league='${inputs.leagueSelect}'
    AND GameMode='Standard'
    AND games_played>='${inputs.gamesSlider}'

ORDER BY stat1 DESC

LIMIT 10
```

```sql slider
    SELECT
        member_id
        , skill_group
        , CASE WHEN gamemode = 'RL_DOUBLES' THEN 'Doubles' WHEN gamemode = 'RL_STANDARD' THEN 'Standard' ELSE 'Unknown' END as GameMode
        , COUNT(*) as games_played

    FROM S19_stats s19

    WHERE skill_group='${inputs.leagueSelect}'

    GROUP BY
        member_id
        , skill_group
        , GameMode

    ORDER BY
        games_played DESC
```

<ButtonGroup name=leagueSelect>
    <ButtonGroupItem valueLabel="Foundation League" value="Foundation League" />
    <ButtonGroupItem valueLabel="Academy League" value="Academy League" default />
    <ButtonGroupItem valueLabel="Champion League" value="Champion League" />
    <ButtonGroupItem valueLabel="Master League" value="Master League" />
    <ButtonGroupItem valueLabel="Premier League" value="Premier League" />
</ButtonGroup>

<Dropdown name=stats defaultValue=sprocket_rating>
    <DropdownOption value=avg_dpi valueLabel="Avg DPI" />
    <DropdownOption value=sprocket_rating valueLabel="Avg Sprocket Rating" />
    <DropdownOption value=avg_opi valueLabel="Avg OPI" />
    <DropdownOption value=Score_Per_Game valueLabel="Avg Score" />
    <DropdownOption value=goals_per_game valueLabel="Avg Goals" />
    <DropdownOption value=total_goals valueLabel="Total Goals" />
    <DropdownOption value=assists_per_game valueLabel="Avg Assists" />
    <DropdownOption value=total_assists valueLabel="Total Assists" />
    <DropdownOption value=saves_per_game valueLabel="Avg Saves" />
    <DropdownOption value=total_saves valueLabel="Total Saves" />
    <DropdownOption value=shots_per_game valueLabel="Avg Shots" />
    <DropdownOption value=goals_against_per_game valueLabel="Avg Goals Against" />
    <DropdownOption value=shots_against_per_game valueLabel="Avg Shots Against"/>
    <DropdownOption value=shooting_pct2 valueLabel="Avg Shooting %" />
</Dropdown>

<Slider title='Minimum Games Played' name=gamesSlider size=large data={slider} min=1 maxColumn=games_played />

<Grid cols=2>
    <BarChart data={S19leaderboard2s} title="Top 10 for 2s" x=name y=stat1 swapXY=true series=name seriesLabels=false legend=false yAxisTitle='{inputs.stats.value}' pointSize=15 colorPalette={[S19leaderboard2s[0].primColor, S19leaderboard2s[1].primColor, S19leaderboard2s[2].primColor, S19leaderboard2s[3].primColor, S19leaderboard2s[4].primColor, S19leaderboard2s[5].primColor, S19leaderboard2s[6].primColor, S19leaderboard2s[7].primColor, S19leaderboard2s[8].primColor, S19leaderboard2s[9].primColor]} />
    <BarChart data={S19leaderboard3s} title="Top 10 for 3s" x=name y=stat1 swapXY=true series=name seriesLabels=false legend=false yAxisTitle='{inputs.stats.value}' pointSize=15 colorPalette={[S19leaderboard3s[0].primColor, S19leaderboard3s[1].primColor, S19leaderboard3s[2].primColor, S19leaderboard3s[3].primColor, S19leaderboard3s[4].primColor, S19leaderboard3s[5].primColor, S19leaderboard3s[6].primColor, S19leaderboard3s[7].primColor, S19leaderboard3s[8].primColor, S19leaderboard3s[9].primColor]} />
</Grid>
