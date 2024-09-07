---
title: MLE Homepage
---

Evidence is your gateway into MLE's statistics. Here you will find pages for
many areas of current, and historical stats (performance, standings, etc).
If you don't see something here, or are unsure of how to use this tool, reach out
to the team on [Discord](https://discord.com/channels/172404472637685760/323511951357509642)

```sql franchise
SELECT
  franchise
FROM teams
ORDER BY franchise ASC
```

<Tabs>

  <Tab label=" S17 Conference Standings">

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
    </ButtonGroup>
</p>

## Blue Conference Standings

```sql blueconference
with S17standings as (
    
    SELECT 
    *,
    '/franchise_page/' || t.Franchise AS Franchise_Link,
    FROM S17_standings st
    INNER JOIN teams t
        ON st.name = t.Franchise

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
	FROM rounds r
	INNER JOIN matches m
	    ON r.match_id = m.match_id
	INNER JOIN match_groups mg
	    on m.match_group_id = mg.match_group_id
	WHERE mg.parent_group_title = 'Season 17'
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
	FROM rounds r
	INNER JOIN matches m
	    ON r.match_id = m.match_id
	INNER JOIN match_groups mg
	    on m.match_group_id = mg.match_group_id
	WHERE mg.parent_group_title = 'Season 17'
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

)

SELECT
    s17.ranking AS divisional_rank
    , s17.Franchise AS team_name
    , s17."Photo URL" AS team_logo
    , s17.Division AS division
    , s17."Super Division" AS super_division
	, s17.Conference
    , s17.team_wins::INT || ' - ' || s17.team_losses::INT AS record
    , sagd.series_wins || ' - ' || sagd.series_loses AS series_record
    , sagd.goals_for
    , sagd.goals_against
    , sagd.goal_diff AS goal_differential
    , Franchise_Link
FROM S17standings s17
INNER JOIN series_and_goal_diff sagd
    ON s17.Franchise = sagd.team_name
    AND s17.league = sagd.league
    AND s17.mode = sagd.game_mode
WHERE s17.Conference = 'BLUE'
	AND s17.division_name NOT NULL
    AND s17.league LIKE '${inputs.League_Selection}'
    AND s17.mode LIKE '${inputs.GameMode_Selection}'
ORDER BY
    s17.team_wins DESC
    , sagd.series_wins DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```

<DataTable data={blueconference} rows=16 rowShading=true headerColor=#1E90FF wrapTitles=true link=Franchise_Link>
    <Column id=divisional_rank align=center />
    <Column id=team_name align=center />
    <Column id=team_logo contentType=image height=25px align=center />
	<Column id=super_division align=center />
    <Column id=division align=center />
    <Column id=record align=center />
    <Column id=series_record align=center />
    <Column id=goals_for align=center />
    <Column id=goals_against align=center />
    <Column id=goal_differential align=center />
</DataTable>


## Orange Conference Standings

```sql orangeconference
with S17standings as (
    
    SELECT 
    *,
    '/franchise_page/' || t.Franchise AS Franchise_Link,
    FROM S17_standings st
    INNER JOIN teams t
        ON st.name = t.Franchise

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
	FROM rounds r
	INNER JOIN matches m
	    ON r.match_id = m.match_id
	INNER JOIN match_groups mg
	    on m.match_group_id = mg.match_group_id
	WHERE mg.parent_group_title = 'Season 17'
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
	FROM rounds r
	INNER JOIN matches m
	    ON r.match_id = m.match_id
	INNER JOIN match_groups mg
	    on m.match_group_id = mg.match_group_id
	WHERE mg.parent_group_title = 'Season 17'
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

)

SELECT
    s17.ranking AS divisional_rank
    , s17.Franchise AS team_name
    , s17."Photo URL" AS team_logo
    , s17.Division AS division
    , s17."Super Division" AS super_division
	, s17.Conference
    , s17.team_wins::INT || ' - ' || s17.team_losses::INT AS record
    , sagd.series_wins || ' - ' || sagd.series_loses AS series_record
    , sagd.goals_for
    , sagd.goals_against
    , sagd.goal_diff AS goal_differential
    , Franchise_Link
FROM S17standings s17
INNER JOIN series_and_goal_diff sagd
    ON s17.Franchise = sagd.team_name
    AND s17.league = sagd.league
    AND s17.mode = sagd.game_mode
WHERE s17.Conference = 'ORANGE'
    AND s17.division_name NOT NULL
    AND s17.league LIKE '${inputs.League_Selection}'
    AND s17.mode LIKE '${inputs.GameMode_Selection}'
ORDER BY
    s17.team_wins DESC
    , sagd.series_wins DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```

<DataTable data={orangeconference} rows=16 rowShading=true headerColor=#FFA500 wrapTitles=true link=Franchise_Link>
    <Column id=divisional_rank align=center />
    <Column id=team_name align=center />
    <Column id=team_logo contentType=image height=25px align=center />
    <Column id=division align=center />
    <Column id=record align=center />
    <Column id=series_record align=center />
    <Column id=goals_for align=center />
    <Column id=goals_against align=center />
    <Column id=goal_differential align=center />
</DataTable>  

  </Tab>

</Tabs>
