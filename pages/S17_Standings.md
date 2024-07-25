---
title: S17 Standings
---

<Tabs>
<Tab label="Overall Standings">

## Overall Standings

<Details title='Instructions'>

<p>Below you will find overall standings for MLE in S17.</p>
<p>Please use the dropdown menus below to see the overall standings for your desired league.</p>
</Details>



```sql overallStandings
with S17standings as (
    
    SELECT
        *
        , CASE
            WHEN s17.mode IN ('Doubles', 'Standard') THEN s17.mode
            ELSE 'Overall'
        END AS game_mode
    FROM S17_standings s17
    INNER JOIN teams t
        ON s17.name = t.name

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
    s17.ranking AS divisional_rank
    , s17.name AS team_name
    , s17.logo_img_link AS team_logo
    , s17.division_name AS division
    , s17.conference
    , s17.team_wins::INT || ' - ' || s17.team_losses::INT AS record
    , sagd.series_wins || ' - ' || sagd.series_loses AS series_record
    , sagd.goals_for
    , sagd.goals_against
    , sagd.goal_diff AS goal_differential
FROM S17standings s17
INNER JOIN series_and_goal_diff sagd
    ON s17.name = sagd.team_name
    AND s17.league = sagd.league
    AND s17.game_mode = sagd.game_mode
WHERE s17.conference NOT NULL
    AND s17.division_name NOT NULL
    AND s17.league LIKE '${inputs.League.value}'
    AND s17.game_mode LIKE '${inputs.GameMode.value}'
ORDER BY
    s17.team_wins DESC
    , sagd.series_wins DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```

<Dropdown name=League>
    <DropdownOption valueLabel="Foundation League" value="Foundation League"/>
    <DropdownOption valueLabel="Academy League" value="Academy League"/>
    <DropdownOption valueLabel="Champion League" value="Champion League"/>
    <DropdownOption valueLabel="Master League" value="Master League"/>
    <DropdownOption valueLabel="Premier League" value="Premier League"/>
</Dropdown>

<Dropdown name=GameMode defaultValue="Overall">
    <DropdownOption valueLabel="Overall" value="Overall"/>
    <DropdownOption valueLabel="Doubles" value="Doubles"/>
    <DropdownOption valueLabel="Standard" value="Standard"/>
</Dropdown>

<DataTable data={overallStandings} rows=32 rowShading=true wrapTitles=true headerColor=#2a4b82 headerFontColor=white>
    <Column id=team_name align=center />
    <Column id=team_logo contentType=image height=25px align=center />
    <Column id=conference align=center />
    <Column id=division align=center />
    <Column id=record align=center />
    <Column id=series_record align=center />
    <Column id=goals_for align=center />
    <Column id=goals_against align=center />
    <Column id=goal_differential align=center />
</DataTable>
</Tab>

<Tab label="S17 Conference Standings">

<LastRefreshed prefix="Data last updated"/>

<Details title='Instructions'>

<p>Below you will find conference standings for MLE in S17.</p>
<p>Please use the dropdown menus below to sort the data as you see fit.</p>
<p>You have options to sort by League and Mode.</p>
</Details>


```sql blueconference
with S17standings as (
    
    SELECT *
    FROM S17_standings st
    INNER JOIN teams t
        ON st.name = t.name

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
    , s17.name AS team_name
    , s17.logo_img_link AS team_logo
    , s17.division_name AS division
    , s17.conference
    , s17.team_wins::INT || ' - ' || s17.team_losses::INT AS record
    , sagd.series_wins || ' - ' || sagd.series_loses AS series_record
    , sagd.goals_for
    , sagd.goals_against
    , sagd.goal_diff AS goal_differential
FROM S17standings s17
INNER JOIN series_and_goal_diff sagd
    ON s17.name = sagd.team_name
    AND s17.league = sagd.league
    AND s17.mode = sagd.game_mode
WHERE s17.conference = 'BLUE'
    AND s17.division_name NOT NULL
    AND s17.league LIKE '${inputs.League.value}'
    AND s17.mode LIKE '${inputs.GameMode.value}'
ORDER BY
    s17.team_wins DESC
    , sagd.series_wins DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```

## Blue Conference Standings

<Dropdown name=League>
    <DropdownOption valueLabel="Foundation League" value="Foundation League"/>
    <DropdownOption valueLabel="Academy League" value="Academy League"/>
    <DropdownOption valueLabel="Champion League" value="Champion League"/>
    <DropdownOption valueLabel="Master League" value="Master League"/>
    <DropdownOption valueLabel="Premier League" value="Premier League"/>
</Dropdown>

<Dropdown name=GameMode>
    <DropdownOption valueLabel="Doubles" value="Doubles"/>
    <DropdownOption valueLabel="Standard" value="Standard"/>
</Dropdown>

<DataTable data={blueconference} rows=16 rowShading=true headerColor=#1E90FF wrapTitles=true>
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

```sql orangeconference
with S17standings as (
    
    SELECT *
    FROM S17_standings st
    INNER JOIN teams t
        ON st.name = t.name

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
    , s17.name AS team_name
    , s17.logo_img_link AS team_logo
    , s17.division_name AS division
    , s17.conference
    , s17.team_wins::INT || ' - ' || s17.team_losses::INT AS record
    , sagd.series_wins || ' - ' || sagd.series_loses AS series_record
    , sagd.goals_for
    , sagd.goals_against
    , sagd.goal_diff AS goal_differential
FROM S17standings s17
INNER JOIN series_and_goal_diff sagd
    ON s17.name = sagd.team_name
    AND s17.league = sagd.league
    AND s17.mode = sagd.game_mode
WHERE s17.conference = 'ORANGE'
    AND s17.division_name NOT NULL
    AND s17.league LIKE '${inputs.League1.value}'
    AND s17.mode LIKE '${inputs.GameMode1.value}'
ORDER BY
    s17.team_wins DESC
    , sagd.series_wins DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```

## Orange Conference Standings

<Dropdown name=League1>
    <DropdownOption valueLabel="Foundation League" value="Foundation League"/>
    <DropdownOption valueLabel="Academy League" value="Academy League"/>
    <DropdownOption valueLabel="Champion League" value="Champion League"/>
    <DropdownOption valueLabel="Master League" value="Master League"/>
    <DropdownOption valueLabel="Premier League" value="Premier League"/>
</Dropdown>

<Dropdown name=GameMode1>
    <DropdownOption valueLabel="Doubles" value="Doubles"/>
    <DropdownOption valueLabel="Standard" value="Standard"/>
</Dropdown>

<DataTable data={orangeconference} rows=16 rowShading=true headerColor=#FFA500 wrapTitles=true>
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

<Tab label="S17 Divisional Standings">

<LastRefreshed prefix="Data last updated"/>

<Details title='Instructions'>

<p>Below you will find all divisional standings for MLE in S17.</p>
<p>Please use the dropdown menus below to sort the data as you see fit.</p>
<p>You have options to sort by Division, League, and Mode.</p>
<p><b>Note: Not all divisions exist in FL and PL so if a non existent division is selected no information will be displayed.</b></p>
</Details>

```sql bluestandings
with S17standings as (
    
    SELECT *
    FROM S17_standings st
    INNER JOIN teams t
        ON st.name = t.name

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
    , s17.name AS team_name
    , s17.logo_img_link AS team_logo
    , s17.division_name AS division
    , s17.conference
    , s17.team_wins::INT || ' - ' || s17.team_losses::INT AS record
    , sagd.series_wins || ' - ' || sagd.series_loses AS series_record
    , sagd.goals_for
    , sagd.goals_against
    , sagd.goal_diff AS goal_differential
FROM S17standings s17
INNER JOIN series_and_goal_diff sagd
    ON s17.name = sagd.team_name
    AND s17.league = sagd.league
    AND s17.mode = sagd.game_mode
WHERE s17.conference = 'BLUE'
    AND s17.division_name LIKE '${inputs.division.value}'
    AND s17.league LIKE '${inputs.League.value}'
    AND s17.mode LIKE '${inputs.GameMode.value}'
ORDER BY
    s17.team_wins DESC
    , sagd.series_wins DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```

## Blue Conference Divisional Standings

<Dropdown name=division>
    <DropdownOption valueLabel="Arctic" value="Arctic"/>
    <DropdownOption valueLabel="Mystic" value="Mystic"/>
    <DropdownOption valueLabel="Sky" value="Sky"/>
    <DropdownOption valueLabel="Storm" value="Storm"/>
</Dropdown>

<Dropdown name=League>
    <DropdownOption valueLabel="Foundation League" value="Foundation League"/>
    <DropdownOption valueLabel="Academy League" value="Academy League"/>
    <DropdownOption valueLabel="Champion League" value="Champion League"/>
    <DropdownOption valueLabel="Master League" value="Master League"/>
    <DropdownOption valueLabel="Premier League" value="Premier League"/>
</Dropdown>

<Dropdown name=GameMode>
    <DropdownOption valueLabel="Doubles" value="Doubles"/>
    <DropdownOption valueLabel="Standard" value="Standard"/>
</Dropdown>

<DataTable data={bluestandings} rows=5 rowShading=true headerColor=#1E90FF wrapTitles=true>
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

```sql orangestandings
with S17standings as (
    
    SELECT *
    FROM S17_standings st
    INNER JOIN teams t
        ON st.name = t.name

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
    , s17.name AS team_name
    , s17.logo_img_link AS team_logo
    , s17.division_name AS division
    , s17.conference
    , s17.team_wins::INT || ' - ' || s17.team_losses::INT AS record
    , sagd.series_wins || ' - ' || sagd.series_loses AS series_record
    , sagd.goals_for
    , sagd.goals_against
    , sagd.goal_diff AS goal_differential
FROM S17standings s17
INNER JOIN series_and_goal_diff sagd
    ON s17.name = sagd.team_name
    AND s17.league = sagd.league
    AND s17.mode = sagd.game_mode
WHERE s17.conference = 'ORANGE'
    AND s17.division_name LIKE '${inputs.division1.value}'
    AND s17.league LIKE '${inputs.League1.value}'
    AND s17.mode LIKE '${inputs.GameMode1.value}'
ORDER BY
    s17.team_wins DESC
    , sagd.series_wins DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```

## Orange Conference Divisional Standings

<Dropdown name=division1>
    <DropdownOption valueLabel="Forge" value="Forge"/>
    <DropdownOption valueLabel="Sun" value="Sun"/>
    <DropdownOption valueLabel="Tropic" value="Tropic" />
    <DropdownOption valueLabel="Volcanic" value="Volcanic"/>
</Dropdown>

<Dropdown name=League1>
    <DropdownOption valueLabel="Foundation League" value="Foundation League"/>
    <DropdownOption valueLabel="Academy League" value="Academy League"/>
    <DropdownOption valueLabel="Champion League" value="Champion League"/>
    <DropdownOption valueLabel="Master League" value="Master League"/>
    <DropdownOption valueLabel="Premier League" value="Premier League"/>
</Dropdown>

<Dropdown name=GameMode1>
    <DropdownOption valueLabel="Doubles" value="Doubles"/>
    <DropdownOption valueLabel="Standard" value="Standard"/>
</Dropdown>

<DataTable data={orangestandings} rows=5 rowShading=true headerColor=#FFA500 wrapTitles=true>
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
