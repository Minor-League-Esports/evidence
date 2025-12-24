---
title: S18 Standings
---
<LastRefreshed prefix="Data last updated"/>

## Filters 

<ButtonGroup name=League>
      <ButtonGroupItem valueLabel="Foundation League" value= "Foundation League" />
      <ButtonGroupItem valueLabel="Academy League" value= "Academy League" default />
      <ButtonGroupItem valueLabel="Champion League" value="Champion League" />
      <ButtonGroupItem valueLabel="Master League" value="Master League" />
      <ButtonGroupItem valueLabel="Premier League" value="Premier League" />
</ButtonGroup>


<ButtonGroup name=GameMode>
    <ButtonGroupItem valueLabel="Doubles" value="Doubles" default />
    <ButtonGroupItem valueLabel="Standard" value="Standard" />
    <ButtonGroupItem valueLabel="Overall" value="Overall" />
</ButtonGroup>


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

```sql super_divisions
SELECT DISTINCT
	t."Super Division" AS super_division
	, t.Conference
FROM teams t
INNER JOIN S18_standings s18
	ON t.Franchise = s18.name
WHERE s18.league LIKE '${inputs.League}'
ORDER BY
	t.Conference
	, t."Super Division"
```

```sql divisions
SELECT DISTINCT
	t.Division AS div_name
	, t.Conference
FROM teams t
INNER JOIN S18_standings s18
	ON t.Franchise = s18.name
WHERE s18.league LIKE '${inputs.League}'
ORDER BY
	t.Conference
	, t."Super Division"
	, t.Division
```


<Tabs>
<Tab label="Overall Standings">

# Overall Standings

```sql overallStandings
with S18standings as (
    
    SELECT
        *
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
    , s18."Photo URL" AS team_logo
    , s18.Division AS division
	, s18."Super Division" AS super_division
	, '/franchise_page/' || s18.Franchise AS Franchise_Link
    , s18.Conference
    , s18.team_wins::INT || ' - ' || s18.team_losses::INT AS record
	, s18.team_wins::FLOAT / (s18.team_wins + s18.team_losses) AS win_pct2
    , sagd.series_wins || ' - ' || sagd.series_loses AS series_record
	, sagd.series_wins::FLOAT / (sagd.series_wins + sagd.series_loses) AS series_win_pct2
    , sagd.goals_for
    , sagd.goals_against
    , sagd.goal_diff AS goal_differential
FROM S18standings s18
INNER JOIN series_and_goal_diff sagd
    ON s18.Franchise = sagd.team_name
    AND s18.league = sagd.league
    AND s18.game_mode = sagd.game_mode
WHERE s18.conference NOT NULL
    AND s18.division_name NOT NULL
    AND s18.league LIKE '${inputs.League}'
    AND s18.game_mode LIKE '${inputs.GameMode}'
ORDER BY
    win_pct2 DESC
    , series_win_pct2 DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```

<DataTable data={overallStandings} rows=32 rowShading=true wrapTitles=true headerColor=#2a4b82 headerFontColor=white link=Franchise_Link>
    <Column id=team_name align=center />
    <Column id=team_logo contentType=image height=25px align=center />
    <Column id=conference align=center />
	<Column id=super_division align=center />
    <Column id=division align=center />
    <Column id=record align=center />
    <Column id=series_record align=center />
    <Column id=goals_for align=center />
    <Column id=goals_against align=center />
    <Column id=goal_differential align=center />
</DataTable>

</Tab>





<Tab label="S18 Conference Standings">

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
    , s18."Photo URL" AS team_logo
    , s18.Division AS division
    , s18."Super Division" AS super_division
	, '/franchise_page/' || s18.Franchise AS Franchise_Link
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
    AND s18.league LIKE '${inputs.League}'
    AND s18.game_mode LIKE '${inputs.GameMode}'
ORDER BY
    s18.team_wins DESC
    , sagd.series_wins DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```

{#each conference as c}

	# {c.Conference} Conference

	<DataTable data={conference_standings.where(`LOWER(conference) = LOWER('${c.Conference}')`)} rows=16 rowShading=true headerColor={c.conference_color} wrapTitles=true link=Franchise_Link>
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

{/each}

</Tab>





<Tab label="S18 Super Division Standings">

```sql super_division_standings
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

), staging AS (

	SELECT
		s18.ranking AS divisional_rank
		, s18.Franchise AS team_name
		, s18."Photo URL" AS team_logo
		, s18.Division AS division
		, s18."Super Division" AS super_division
		, '/franchise_page/' || s18.Franchise AS Franchise_Link
		, CASE
			WHEN s18.Conference = 'BLUE' THEN 'Blue'
			WHEN s18.Conference = 'ORANGE' THEN 'Orange'
			ELSE 'OH NO, SOMETHING IS WEIRD'
		END AS conference
		, s18.league
		, s18.team_wins
		, s18.team_wins::INT || ' - ' || s18.team_losses::INT AS record
		, s18.team_wins / NULLIF(s18.team_wins + s18.team_losses, 0) AS win_pct
		, sagd.series_wins
		, sagd.series_wins || ' - ' || sagd.series_loses AS series_record
		, sagd.series_wins / NULLIF(sagd.series_wins + sagd.series_loses, 0) AS series_win_pct
		, sagd.goals_for
		, sagd.goals_against
		, sagd.goal_diff AS goal_differential
		, CASE
			WHEN s18.ranking = 1 THEN 1
			ELSE 0
		END AS is_divisional_leader
	FROM S18standings s18
	INNER JOIN series_and_goal_diff sagd
		ON s18.Franchise = sagd.team_name
		AND s18.league = sagd.league
		AND s18.game_mode = sagd.game_mode
	WHERE s18.Conference NOT NULL
		AND s18.division_name NOT NULL
		AND s18.league LIKE '${inputs.League}'
		AND s18.game_mode LIKE '${inputs.GameMode}'
)

SELECT
	*
	, ROW_NUMBER() OVER(PARTITION BY s.super_division ORDER BY s.is_divisional_leader DESC, s.win_pct DESC, s.series_win_pct DESC, s.goal_differential DESC, s.goals_for DESC) AS super_division_rank
FROM staging s
ORDER BY
	super_division_rank
```

{#each conference as c}

	# {c.Conference} Conference

	{#each super_divisions as sd}

		{#if sd.Conference === c.Conference}

			## {sd.super_division} Super Division

			<DataTable data={super_division_standings.where(`super_division = '${sd.super_division}'`)} rows=8 rowShading=true headerColor={c.conference_color} wrapTitles=true link=Franchise_Link>
				<Column id=super_division_rank align=center />
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

		{/if}

	{/each}

{/each}

</Tab>




<Tab label="S18 Divisional Standings">

```sql divisional_standings
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
    , s18."Photo URL" AS team_logo
    , s18.Division AS division
    , s18."Super Division" AS super_division
	, '/franchise_page/' || s18.Franchise AS Franchise_Link
	, CASE
		WHEN s18.Conference = 'BLUE' THEN 'Blue'
		WHEN s18.Conference = 'ORANGE' THEN 'Orange'
		ELSE 'OH NO, SOMETHING IS WEIRD'
	END AS conference
	, s18.league
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
WHERE s18.Conference NOT NULL
	AND s18.division_name NOT NULL
	AND s18.league LIKE '${inputs.League}'
    AND s18.game_mode LIKE '${inputs.GameMode}'
ORDER BY
	s18.ranking
    , s18.team_wins DESC
    , sagd.series_wins DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```


{#each conference as c}

	# {c.Conference} Conference

	{#each divisions as d}

		{#if  d.Conference === c.Conference}

			## {d.div_name} Division

			<DataTable data={divisional_standings.where(`division = '${d.div_name}'`)} rows=4 rowShading=true headerColor={c.conference_color} wrapTitles=true link=Franchise_Link>
				<Column id=divisional_rank align=center />
				<Column id=team_name align=center />
				<Column id=team_logo contentType=image height=25px align=center />
				<Column id=super_division align=center />
				<Column id=record align=center />
				<Column id=series_record align=center />
				<Column id=goals_for align=center />
				<Column id=goals_against align=center />
				<Column id=goal_differential align=center />
			</DataTable>

		{/if}

	{/each}

{/each}

</Tab>
</Tabs>
