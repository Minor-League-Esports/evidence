```sql teamLogos
SELECT 
franchise,
'franchise_page/' || franchise as franchiseLink,
-- "Photo URL" as logo
FROM teams
ORDER BY franchise ASC
```
<div style="width:100%; max-width:700px; margin:auto;">
<div style="display:flex; flex-direction:row; align-items:center; justify-content:center; flex-wrap:wrap; gap:0.25rem;"> 
{#each teamLogos as t}
<a href="{t.franchiseLink}" > <!-- <img src={t.logo} class="h-10 w-10" /> --> </a>
{/each}
</div>
</div>


<p>&nbsp; </p>
<h1 style="font-size: 40px;"><center><b> MLE Homepage </b></center></h1>


Evidence is your gateway into MLE's statistics. Here you will find pages for
many areas of current, and historical stats (performance, standings, etc).
If you don't see something here, or are unsure of how to use this tool, reach out
to the team on [Discord](https://discord.com/channels/172404472637685760/323511951357509642).

<h2 style="font-size: 25px;"><center><b><u> Season 18 Champions </u></b></center></h2>

<h3 style="font-size: 20px;"><center><b> Doubles: </b></center></h3>

<div style="text-align: center;">
    <span style="display: inline-flex; align-items: center;">
        <b>FL:</b> &nbsp;Flames <!-- <img src={teamLogos[11].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" /> -->
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>AL:</b> &nbsp;Hurricanes <!-- <img src={teamLogos[15].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" /> -->
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>CL:</b> &nbsp;Tyrants <!-- <img src={teamLogos[29].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" /> -->
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>ML:</b> &nbsp;Ducks <!-- <img src={teamLogos[7].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" /> -->
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>PL:</b> &nbsp;Bulls <!-- <img src={teamLogos[3].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" /> -->
    </span>
</div>

<h3 style="font-size: 20px;"><center><b> Standard: </b></center></h3>

<div style="text-align: center;">
    <span style="display: inline-flex; align-items: center;">
        <b>FL:</b> &nbsp;Flames <!-- <img src={teamLogos[11].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" /> -->
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>AL:</b> &nbsp;Bulls <!-- <img src={teamLogos[3].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" /> -->
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>CL:</b> &nbsp;Flames <!-- <img src={teamLogos[11].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" /> -->
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>ML:</b> &nbsp;Ducks <!-- <img src={teamLogos[7].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" /> -->
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>PL:</b> &nbsp;Shadow <!-- <img src={teamLogos[25].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" /> -->
    </span>
</div>

<Tabs>

<Tab label=" S18 Conference Standings">

  <LastRefreshed prefix="Data last updated"/>

<p> 
<ButtonGroup name=League_Selection>
      <ButtonGroupItem valueLabel="Foundation League" value= "Foundation League" />
      <ButtonGroupItem valueLabel="Academy League" value= "Academy League" default />
      <ButtonGroupItem valueLabel="Champion League" value="Champion League" />
      <ButtonGroupItem valueLabel="Master League" value="Master League" />
      <ButtonGroupItem valueLabel="Premier League" value="Premier League" />
    </ButtonGroup>
</p>

<p>
<ButtonGroup name=GameMode_Selection>
      <ButtonGroupItem valueLabel="Doubles" value= "Doubles" default/>
      <ButtonGroupItem valueLabel="Standard" value= "Standard" />
      <ButtonGroupItem valueLabel="Overall" value= "Overall" />
    </ButtonGroup>
</p>

```sql conference
SELECT DISTINCT
	t.Conference
	, CASE
		WHEN t.Conference = 'Orange' THEN '#FFA500'
		WHEN t.Conference = 'Blue' THEN '#1E90FF'
		ELSE 'OH NO, SOMETHING IS WEIRD'
	END AS conference_color
FROM teams t
```

```sql conference_standings
with S18standings as (
    
    SELECT *
        , CASE
            WHEN s18.mode IN ('Doubles', 'Standard') THEN s18.mode
            ELSE 'Overall'
        END AS game_mode
    FROM S18_standings s18
    INNER JOIN teams t
        ON s18.name = t.Franchise

), results AS (

	SELECT
		r.match_id
		, m.league
		, m.game_mode
		, r.Home AS team_name
		, m.home_wins AS wins
		, m.away_wins AS loses
		, CASE WHEN r.Home = m.winning_team THEN 1 ELSE 0 END AS series_wins
		, CASE WHEN r.Home != m.winning_team THEN 1 ELSE 0 END AS series_loses
		, SUM(r."Home Goals") AS goals_for
		, SUM(r."Away Goals") AS goals_against
		, goals_for - goals_against AS goal_diff
	FROM s18_rounds r
	INNER JOIN matches m
	    ON r.match_id = m.match_id
	INNER JOIN match_groups mg
	    on m.match_group_id = mg.match_group_id
	WHERE mg.parent_group_title = 'Season 18'
	GROUP BY
		1, 2, 3, 4, 5, 6, 7, 8
		
	UNION ALL
	
	SELECT
		r.match_id
		, m.league
		, m.game_mode
		, r.Away AS team_name
		, m.away_wins AS wins
		, m.home_wins AS loses
		, CASE WHEN r.Away = m.winning_team THEN 1 ELSE 0 END AS series_wins
		, CASE WHEN r.Away != m.winning_team THEN 1 ELSE 0 END AS series_loses
		, SUM(r."Away Goals") AS goals_for
		, SUM(r."Home Goals") AS goals_against
		, goals_for - goals_against AS goal_diff
	FROM s18_rounds r
	INNER JOIN matches m
	    ON r.match_id = m.match_id
	INNER JOIN match_groups mg
	    on m.match_group_id = mg.match_group_id
	WHERE mg.parent_group_title = 'Season 18'
	GROUP BY
		1, 2, 3, 4, 5, 6, 7, 8

), series_and_goal_diff AS (

    SELECT
        league
        , game_mode
        , team_name
        , SUM(wins) AS wins
        , SUM(loses) AS loses
        , SUM(series_wins) AS series_wins
        , SUM(series_loses) AS series_loses
        , SUM(goals_for) AS goals_for
        , SUM(goals_against) AS goals_against
        , SUM(goal_diff) AS goal_diff
    FROM results
    GROUP BY 1, 2, 3

    UNION ALL

    SELECT
        league
        , 'Overall' AS game_mode
        , team_name
        , SUM(wins) AS wins
        , SUM(loses) AS loses
        , SUM(series_wins) AS series_wins
        , SUM(series_loses) AS series_loses
        , SUM(goals_for) AS goals_for
        , SUM(goals_against) AS goals_against
        , SUM(goal_diff) AS goal_diff
    FROM results
    GROUP BY 1, 2, 3


)

SELECT
    s18.ranking AS divisional_rank
    , s18.Franchise AS team_name
    -- , s18."Photo URL" AS team_logo
    , s18.Division AS division
    , s18."Super Division" AS super_division
        -- 'Photo URL' as logo
	, s18.Conference
    , s18.team_wins::INT || ' - ' || s18.team_losses::INT AS record
    , sagd.series_wins || ' - ' || sagd.series_loses AS series_record
    , sagd.goals_for
    , sagd.goals_against
    , sagd.goal_diff AS goal_differential
FROM S18standings s18
INNER JOIN series_and_goal_diff sagd
    ON s18.Franchise = sagd.team_name
    AND s18.league = sagd.league
    AND s18.game_mode = sagd.game_mode
WHERE s18.division_name NOT NULL
    AND s18.league LIKE '${inputs.League_Selection}'
    AND s18.game_mode LIKE '${inputs.GameMode_Selection}'
ORDER BY
    s18.team_wins DESC
    , sagd.series_wins DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```

{#each conference as c}

	## {c.Conference} Conference

	<DataTable data={conference_standings.where(`LOWER(conference) = LOWER('${c.Conference}')`)} rows=16 rowShading=true headerColor={c.conference_color} wrapTitles=true link=Franchise_Link>
		<Column id=divisional_rank align=center />
        <Column id=team_name align=center />
        <!-- <Column id=team_logo contentType=image height=25px align=center /> -->
		<Column id=super_division align=center />
		<Column id=division align=center />
		<Column id=record align=center />
		<Column id=series_record align=center />
		<Column id=goals_for align=center />
		<Column id=goals_against align=center />
		<Column id=goal_differential align=center />
	</DataTable>

{/each}

  </Tab>





  <Tab label="S18 Matchups">

```sql matches
WITH weeks AS (
    SELECT 
        m.match_id,
        m.Home,
        m.Away,
        m.League,
        m.game_mode,
        m.home_wins,
        m.away_wins,
        'franchise_page/' || m.Home AS home_link,
        'franchise_page/' || m.Away AS away_link,
        mg.match_group_title AS Week

    FROM matches m

    LEFT JOIN match_groups mg
        ON m.match_group_id = mg.match_group_id

    WHERE parent_group_title = 'Season 18'
        AND m.League = '${inputs.League_Selection}'
        AND m.game_mode = '${inputs.GameMode_Selection}'
        AND Week = '${inputs.Week_Selection}'
)

SELECT
    match_id,
    Home,
    home_link,
    home_wins::INT || ' - ' || away_wins::INT AS series_score,
    Away,
    away_link,

FROM weeks

ORDER BY
    home_wins DESC
    , away_wins DESC
    , Home
```

<p> 

<ButtonGroup name=League_Selection>
    <ButtonGroupItem valueLabel="Foundation League" value= "Foundation League" />
    <ButtonGroupItem valueLabel="Academy League" value= "Academy League" default />
    <ButtonGroupItem valueLabel="Champion League" value="Champion League" />
    <ButtonGroupItem valueLabel="Master League" value="Master League" />
    <ButtonGroupItem valueLabel="Premier League" value="Premier League" />
</ButtonGroup>

</p>

<p>

<ButtonGroup name=GameMode_Selection>
      <ButtonGroupItem valueLabel="Doubles" value= "Doubles" default/>
      <ButtonGroupItem valueLabel="Standard" value= "Standard" />
    </ButtonGroup>

</p>

<p>

<ButtonGroup name=Week_Selection>
    <ButtonGroupItem valueLabel="Week 1" value="Match 1" default />
    <ButtonGroupItem valueLabel="Week 2" value="Match 2" />
    <ButtonGroupItem valueLabel="Week 3" value="Match 3" />
    <ButtonGroupItem valueLabel="Week 4" value="Match 4" />
    <ButtonGroupItem valueLabel="Week 5" value="Match 5" />
    <ButtonGroupItem valueLabel="Week 6" value="Match 6" />
    <ButtonGroupItem valueLabel="Week 7" value="Match 7" />
    <ButtonGroupItem valueLabel="Week 8" value="Match 8" />
    <ButtonGroupItem valueLabel="Week 9" value="Match 9" />
    <ButtonGroupItem valueLabel="Week 10" value="Match 10" />

</ButtonGroup>

</p>

<DataTable data={matches} rows=16 headerColor=#2a4b82 headerFontColor=white>
  <!-- <Column id=match_id align=center title="Match Id" /> -->
  <Column id=home_link contentType=link linkLabel=home align=center title="Home Team" />
  <Column id=series_score align=center/>
  <Column id=away_link contentType=link linkLabel=away align=center title="Away Team" />

</DataTable>

  </Tab>

<Tab label="S18 Leaderboard">


```sql S18leaderboard2s
With playerstats as (
    Select name,
    salary as Salary,
    team_name as Team,
    s18.skill_group as league,
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
    inner join S18_stats s18
        on p.member_id = s18.member_id
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


```sql S18leaderboard3s
With playerstats as (
    Select name,
    salary as Salary,
    team_name as Team,
    s18.skill_group as league,
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
    inner join S18_stats s18
        on p.member_id = s18.member_id
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

    FROM S18_stats s18

    WHERE skill_group='${inputs.leagueSelect}'

    GROUP BY
        member_id
        , skill_group
        , GameMode

    ORDER BY
        games_played DESC
```


<ButtonGroup name=leagueSelect>
      <ButtonGroupItem valueLabel="Foundation League" value= "Foundation League" />
      <ButtonGroupItem valueLabel="Academy League" value= "Academy League" default />
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

<Grid cols=2 >
    <BarChart data={S18leaderboard2s} title="Top 10 for 2s" x=name y=stat1 swapXY=true series=name seriesLabels=false legend=false yAxisTitle='{inputs.stats.value}' pointSize=15 colorPalette={[S18leaderboard2s[0].primColor, S18leaderboard2s[1].primColor, S18leaderboard2s[2].primColor, S18leaderboard2s[3].primColor, S18leaderboard2s[4].primColor, S18leaderboard2s[5].primColor, S18leaderboard2s[6].primColor, S18leaderboard2s[7].primColor, S18leaderboard2s[8].primColor, S18leaderboard2s[9].primColor]} />
    <BarChart data={S18leaderboard3s} title="Top 10 for 3s" x=name y=stat1 swapXY=true series=name seriesLabels=false legend=false yAxisTitle='{inputs.stats.value}' pointSize=15 colorPalette={[S18leaderboard3s[0].primColor, S18leaderboard3s[1].primColor, S18leaderboard3s[2].primColor, S18leaderboard3s[3].primColor, S18leaderboard3s[4].primColor, S18leaderboard3s[5].primColor, S18leaderboard3s[6].primColor, S18leaderboard3s[7].primColor, S18leaderboard3s[8].primColor, S18leaderboard3s[9].primColor]} />
</Grid>

</Tab>

</Tabs>

