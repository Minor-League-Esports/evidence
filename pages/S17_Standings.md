---
title: S17 Standings
---

<Tabs>
<Tab label="Overall Standings">
	
<LastRefreshed prefix="Data last updated"/>

## Filters

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


## Overall Standings

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
        ON s17.name = t.Franchise

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
FROM S17standings s17
INNER JOIN series_and_goal_diff sagd
    ON s17.Franchise = sagd.team_name
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

<DataTable data={overallStandings} rows=32 rowShading=true wrapTitles=true headerColor=#2a4b82 headerFontColor=white>
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

<Tab label="S17 Conference Standings">

<LastRefreshed prefix="Data last updated"/>

## Filters

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


## Blue Conference Standings

```sql blueconference
with S17standings as (
    
    SELECT *
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
FROM S17standings s17
INNER JOIN series_and_goal_diff sagd
    ON s17.Franchise = sagd.team_name
    AND s17.league = sagd.league
    AND s17.mode = sagd.game_mode
WHERE s17.Conference = 'BLUE'
	AND s17.division_name NOT NULL
    AND s17.league LIKE '${inputs.League.value}'
    AND s17.mode LIKE '${inputs.GameMode.value}'
ORDER BY
    s17.team_wins DESC
    , sagd.series_wins DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```

<DataTable data={blueconference} rows=16 rowShading=true headerColor=#1E90FF wrapTitles=true>
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
    
    SELECT *
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
FROM S17standings s17
INNER JOIN series_and_goal_diff sagd
    ON s17.Franchise = sagd.team_name
    AND s17.league = sagd.league
    AND s17.mode = sagd.game_mode
WHERE s17.Conference = 'ORANGE'
    AND s17.division_name NOT NULL
    AND s17.league LIKE '${inputs.League.value}'
    AND s17.mode LIKE '${inputs.GameMode.value}'
ORDER BY
    s17.team_wins DESC
    , sagd.series_wins DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```

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

<Tab label="S17 Super Division Standings">

<LastRefreshed prefix="Data last updated"/>

## Filters

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


```sql super_division_standings
with S17standings as (
    
    SELECT *
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

), staging AS (

	SELECT
		s17.ranking AS divisional_rank
		, s17.Franchise AS team_name
		, s17."Photo URL" AS team_logo
		, s17.Division AS division
		, s17."Super Division" AS super_division
		, CASE
			WHEN s17.Conference = 'BLUE' THEN 'Blue'
			WHEN s17.Conference = 'ORANGE' THEN 'Orange'
			ELSE 'OH NO, SOMETHING IS WEIRD'
		END AS conference
		, s17.league
		, s17.team_wins
		, s17.team_wins::INT || ' - ' || s17.team_losses::INT AS record
		, s17.team_wins / NULLIF(s17.team_wins + s17.team_losses, 0) AS win_pct
		, sagd.series_wins
		, sagd.series_wins || ' - ' || sagd.series_loses AS series_record
		, sagd.series_wins / NULLIF(sagd.series_wins + sagd.series_loses, 0) AS series_win_pct
		, sagd.goals_for
		, sagd.goals_against
		, sagd.goal_diff AS goal_differential
		, CASE
			WHEN s17.ranking = 1 THEN 1
			ELSE 0
		END AS is_divisional_leader
	FROM S17standings s17
	INNER JOIN series_and_goal_diff sagd
		ON s17.Franchise = sagd.team_name
		AND s17.league = sagd.league
		AND s17.mode = sagd.game_mode
	WHERE s17.Conference NOT NULL
		AND s17.division_name NOT NULL
		AND s17.league LIKE '${inputs.League.value}'
		AND s17.mode LIKE '${inputs.GameMode.value}'
)

SELECT
	*
	, ROW_NUMBER() OVER(PARTITION BY s.super_division ORDER BY s.is_divisional_leader DESC, s.win_pct DESC, s.series_win_pct DESC, s.goal_differential DESC, s.goals_for DESC) AS super_division_rank
FROM staging s
ORDER BY
	super_division_rank
```

```sql conference
SELECT
	DISTINCT t.Conference
FROM teams t
```

```sql super_divisions
SELECT
	DISTINCT t."Super Division" AS super_division
	, t.Conference
	, CASE
		WHEN t.Conference = 'Orange' THEN '#FFA500'
		WHEN t.Conference = 'Blue' THEN '#1E90FF'
		ELSE 'OH NO, SOMETHING IS WEIRD'
	END AS conference_color
FROM teams t
INNER JOIN S17_standings s17
	ON t.Franchise = s17.name
WHERE s17.league LIKE '${inputs.League.value}'
ORDER BY
	t.Conference
	, t."Super Division"
```

{#each conference as c}

	# {c.Conference} Conference Divisional Standings

	{#each super_divisions as sd}

		{#if  sd.Conference === c.Conference}

			## {sd.super_division} Super Division
			<div class="styled-table-wrapper">
				<table class="styled-table">
					<thead>
						<tr  style="background-color: {sd.conference_color} !important; color: #000000;"> 
							<th> Super Division Rank </th>
							<th> Divisional Rank </th>
							<th> Team Name </th>
							<th> Logo </th>
							<th> Division </th>
							<th> Record </th>
							<th> Series Record </th>
							<th> Goals For </th>
							<th> Goals Against </th>
							<th> Goal Differential </th>
						</tr>
					</thead>

					<tbody>
					
						{#each super_division_standings as s}
							{#if  s.conference === c.Conference && sd.super_division === s.super_division && s.league === inputs.League.value}
								<tr> 
									<td> {s.super_division_rank} </td>
									<td> {s.divisional_rank} </td>
									<td> {s.team_name} </td>
									<td> <img src="{s.team_logo}" /> </td>
									<td> {s.division} </td>
									<td> {s.record} </td>
									<td> {s.series_record} </td>
									<td> {s.goals_for} </td>
									<td> {s.goals_against} </td>
									<td> {s.goal_differential} </td>
								</tr>

							{/if}

						{/each}

					</tbody>

				</table>
			</div>

		{/if}

	{/each}

{/each}

</Tab>




<Tab label="S17 Divisional Standings">

<LastRefreshed prefix="Data last updated"/>


## Filters

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


```sql divisional_standings
with S17standings as (
    
    SELECT *
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
	, CASE
		WHEN s17.Conference = 'BLUE' THEN 'Blue'
		WHEN s17.Conference = 'ORANGE' THEN 'Orange'
		ELSE 'OH NO, SOMETHING IS WEIRD'
	END AS conference
	, s17.league
    , s17.team_wins::INT || ' - ' || s17.team_losses::INT AS record
    , sagd.series_wins || ' - ' || sagd.series_loses AS series_record
    , sagd.goals_for
    , sagd.goals_against
    , sagd.goal_diff AS goal_differential
FROM S17standings s17
INNER JOIN series_and_goal_diff sagd
    ON s17.Franchise = sagd.team_name
    AND s17.league = sagd.league
    AND s17.mode = sagd.game_mode
WHERE s17.Conference NOT NULL
	AND s17.division_name NOT NULL
	AND s17.league LIKE '${inputs.League.value}'
    AND s17.mode LIKE '${inputs.GameMode.value}'
ORDER BY
	s17.ranking
    , s17.team_wins DESC
    , sagd.series_wins DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```

```sql conference
SELECT
	DISTINCT t.Conference
FROM teams t
```

```sql divisions
SELECT
	DISTINCT t.Division AS div_name
	, t.Conference
	, CASE
		WHEN t.Conference = 'Orange' THEN '#FFA500'
		WHEN t.Conference = 'Blue' THEN '#1E90FF'
		ELSE 'OH NO, SOMETHING IS WEIRD'
	END AS conference_color
FROM teams t
INNER JOIN S17_standings s17
	ON t.Franchise = s17.name
WHERE s17.league LIKE '${inputs.League.value}'
ORDER BY
	t.Conference
	, t."Super Division"
	, t.Division
```

{#each conference as c}

	# {c.Conference} Conference Divisional Standings

	{#each divisions as d}

		{#if  d.Conference === c.Conference}

			## {d.div_name} Division
			<div class="styled-table-wrapper">
				<table class="styled-table">
					<thead>
						<tr  style="background-color: {d.conference_color} !important; color: #000000;"> 
							<th> Divisional Rank </th>
							<th> Team Name </th>
							<th> Logo </th>
							<th> Super Division </th>
							<th> Record </th>
							<th> Series Record </th>
							<th> Goals For </th>
							<th> Goals Against </th>
							<th> Goal Differential </th>
						</tr>
					</thead>

					<tbody>
					
						{#each divisional_standings as s}
							{#if  s.conference === c.Conference && s.division === d.div_name && s.league === inputs.League.value}
								<tr> 
									<td> {s.divisional_rank} </td>
									<td> {s.team_name} </td>
									<td> <img src="{s.team_logo}" /> </td>
									<td> {s.super_division} </td>
									<td> {s.record} </td>
									<td> {s.series_record} </td>
									<td> {s.goals_for} </td>
									<td> {s.goals_against} </td>
									<td> {s.goal_differential} </td>
								</tr>

							{/if}

						{/each}

					</tbody>

				</table>
			</div>

		{/if}

	{/each}

{/each}

</Tab>
</Tabs>
