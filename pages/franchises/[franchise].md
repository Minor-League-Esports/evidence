```sql team_info
SELECT 
    Franchise,
    Conference,
    "Super Division",
    Division,
    Code,
    "Primary Color" AS primary_color,
    "Secondary Color" AS secondary_color,
    "Photo URL" AS logo
FROM teams t
WHERE t.franchise = '${params.franchise}'
```

<LastRefreshed prefix="Data last updated"/>

{#if team_info[0]?.logo}
<center><img class="h-32" alt="Team Logo" style="content: url({team_info[0].logo}); object-fit: contain;" /></center>
{/if}

#  <center><Value data={team_info} column=Franchise /> </center>

```sql leagues
SELECT
    l.league_name
    , l.color
    , l.league_photo_url
    , l.max_salary
    , COUNT(*) AS num_players

FROM players p

INNER JOIN leagues l
    ON p.skill_group = l.league_name

WHERE p.franchise = '${params.franchise}'

GROUP BY
    l.league_name
    , p.skill_group
    , l.skill_group_id
    , l.color
    , l.league_photo_url
    , l.max_salary

HAVING num_players > 1

ORDER BY
    l.skill_group_id DESC
```

```sql staff_members

SELECT
    p.name AS name,
    p.franchise AS franchise,
    p.skill_group AS league,
    p.member_id AS member_id,
        '/players/' || CAST(p.member_id AS INTEGER) AS id_link,
    p."Franchise Staff Position" AS staff_position,
    CASE
        WHEN p."Franchise Staff Position" = 'Captain' THEN 1
        WHEN p."Franchise Staff Position"  = 'Franchise Manager' THEN 2
        WHEN p."Franchise Staff Position" = 'General Manager' THEN 3
        WHEN p."Franchise Staff Position" = 'Assistant General Manager' THEN 4
    END AS franchise_order
FROM players p

WHERE franchise = '${params.franchise}'
    AND p."Franchise Staff Position" IS NOT NULL

ORDER BY
    franchise_order
```

```sql affordance

WITH eligibility AS (
	SELECT 
	    p.name,
        '/players/' || CAST(p.member_id AS INTEGER) AS id_link,
        '/players/' || CAST(p.member_id AS INTEGER) AS id_link,
	    p.salary,
	    p.skill_group,
	    CASE
	        WHEN p.skill_group = 'Foundation League' THEN 1 
	        WHEN p.skill_group = 'Academy League' THEN 2 
	        WHEN p.skill_group = 'Champion League' THEN 3 
	        WHEN p.skill_group = 'Master League' THEN 4 
	        WHEN p.skill_group = 'Premier League' THEN 5 
	    END as league_order, 
	    p.franchise,
	    SUBSTRING(p.slot, 7) AS slot,
	    COALESCE(ru.doubles_uses, 0) AS doubles_uses,
	    COALESCE(ru.standard_uses, 0) AS standard_uses,
	    COALESCE(ru.total_uses, 0) AS total_uses,
	    p.current_scrim_points,
	    CASE WHEN p.current_scrim_points >= 30 THEN 'Yes'
	        ELSE 'No'
	    END AS Eligible,
	    p."Eligible Through"
	
	FROM players p
	
	LEFT JOIN role_usages ru
	    ON p.franchise = ru.team_name
	    AND p.slot = ru.role
	    AND UPPER(p.skill_group) = CONCAT(ru.league, ' LEAGUE')
	    AND ru.season_number = 19
	
	WHERE p.slot LIKE 'PLAYER%'
	
	ORDER BY
	    league_order
	    , p.slot

), top_sals AS (

	SELECT
		franchise
		, skill_group
		, salary
		, ROW_NUMBER() OVER(PARTITION BY franchise, skill_group ORDER BY salary DESC) AS salary_rank
	FROM eligibility
	ORDER BY
		franchise
		, skill_group
		, salary DESC

), can_sign AS (

	SELECT DISTINCT
	    s.franchise
	    , s.skill_group
	    , l.max_salary - SUM(s.salary) OVER(PARTITION BY s.franchise, s.skill_group) AS remaining_salary
        , l.max_salary - remaining_salary AS total_sal
    	, CASE
			WHEN remaining_salary >= 0 THEN TRUE
			ELSE FALSE
		END AS can_sign_player
	
	FROM top_sals AS s
	
	INNER JOIN leagues l
	    ON s.skill_group = l.league_name
	
	WHERE s.salary_rank <= 5
	
)



SELECT DISTINCT
    s.franchise
    , s.skill_group AS league
    , c.remaining_salary
    , l.max_salary - SUM(s.salary) OVER(PARTITION BY s.franchise, s.skill_group) AS remaining_sal
	, CASE
		WHEN c.can_sign_player THEN remaining_sal::STRING
		ELSE 'Over Cap'
	END AS can_afford
    , total_sal || '/' || l.max_salary as total_salary

FROM top_sals AS s

INNER JOIN leagues l
    ON s.skill_group = l.league_name
    
LEFT JOIN can_sign c
	ON s.franchise = c.franchise
	AND s.skill_group = c.skill_group

WHERE s.salary_rank <= 4
    AND s.franchise = '${params.franchise}'

```

<BigValue 
    data={staff_members.where(`staff_position = 'Franchise Manager'`)}
    title="Franchise Manager"
    value=name
/>
<BigValue 
    data={staff_members.where(`staff_position = 'General Manager'`)}
    title="General Manager"
    value=name
    emptySet=warn
    emptyMessage='GM Not Assigned'
/>
<BigValue 
    data={staff_members.where(`staff_position = 'Assistant General Manager'`)}
    title="Assistant General Manager"
    value=name
    emptySet=warn
    emptyMessage='AGM Not Assigned'
/>
<BigValue 
    data={staff_members.where(`staff_position = 'Assistant General Manager' OFFSET 1`)}
    title="Assistant General Manager"
    value=name
    emptySet=warn
    emptyMessage='Second AGM Not Assigned'
/>


<Tabs>
    <Tab label="Players">


```sql eligibility
SELECT 
    p.name,
    '/players/' || CAST(p.member_id AS INTEGER) AS id_link,
        '/players/' || CAST(p.member_id AS INTEGER) AS id_link,
    p.salary,
    p.skill_group,
    CASE
        WHEN p.skill_group = 'Foundation League' THEN 1 
        WHEN p.skill_group = 'Academy League' THEN 2 
        WHEN p.skill_group = 'Champion League' THEN 3 
        WHEN p.skill_group = 'Master League' THEN 4 
        WHEN p.skill_group = 'Premier League' THEN 5 
    END as league_order, 
    p.franchise,
    SUBSTRING(p.slot, 7) AS slot,
    COALESCE(ru.doubles_uses, 0) AS doubles_uses,
    COALESCE(ru.standard_uses, 0) AS standard_uses,
    COALESCE(ru.total_uses, 0) AS total_uses,
    p.current_scrim_points,
    CASE WHEN p.current_scrim_points >= 30 THEN 'Yes'
        ELSE 'No'
    END AS Eligible,
    p."Eligible Through",
    CASE
        WHEN p."Franchise Staff Position"  = 'Franchise Manager' THEN ' - FM'
        WHEN p."Franchise Staff Position" = 'General Manager' THEN ' - GM'
        WHEN p."Franchise Staff Position" = 'Assistant General Manager' THEN ' - AGM'
        ELSE null
    END AS staff_pos_abr,
    CASE
        WHEN p."Franchise Staff Position" = 'Captain' THEN ' - Capt.'
        ELSE null
    END AS captain,
    CASE
        WHEN staff_pos_abr IS NOT NULL AND captain IS NOT NULL THEN p.name || staff_pos_abr || captain
        WHEN staff_pos_abr IS NOT NULL THEN p.name || staff_pos_abr
        WHEN captain IS NOT NULL THEN p.name || captain
        ELSE p.name
    END AS name_with_pos

FROM players p

LEFT JOIN role_usages ru
    ON p.franchise = ru.team_name
    AND p.slot = ru.role
    AND UPPER(p.skill_group) = CONCAT(ru.league, ' LEAGUE')
    AND ru.season_number = 19


WHERE p.franchise = '${params.franchise}'
    AND p.slot LIKE 'PLAYER%'

ORDER BY
    league_order
    , p.slot
```


{#each leagues as league}

<div style="float:left; font-size:21px; display:inline-block;"><b>{league.league_name}</b></div>
<div style="float:right; display:inline-block;"> <b>Total Salary:</b> <Value data={affordance.where(`league = '${league.league_name}'`)} column=total_salary /> </div>
<div style="float:right; padding:0 50px; display:inline-block;"> <b>Can Afford:</b> <Value data={affordance.where(`league = '${league.league_name}'`)} column=can_afford /> </div>

<DataTable data={eligibility.where(`skill_group = '${league.league_name}'`)} rowshading=true headerColor={league.color} headerFontColor=white wrapTitles=true>
    <Column id=slot align=center />
    <Column id=id_link contentType=link linkLabel=name_with_pos align=center title=Player />
    <Column id=salary align=center fmt=##.0/>
    <Column id=doubles_uses align=center contentType=colorscale colorScale={['white', 'white', 'yellow', '#ce5050']} colorBreakpoints={[0, 4, 5, 6]} />
    <Column id=standard_uses align=center contentType=colorscale colorScale={['white', 'white', 'yellow', '#ce5050']} colorBreakpoints={[0, 6, 7, 8]} />
    <Column id=total_uses align=center contentType=colorscale colorScale={['white', 'white', 'yellow', '#ce5050']} colorBreakpoints={[0, 10, 11, 12]} />    
    <Column id=current_scrim_points align=center contentType=colorscale colorScale={['#ce5050','white']} colorBreakpoints={[0, 30]}/>
    <Column id="Eligible Through" align=center />
</DataTable>


{/each}

</Tab>





<Tab label="S19 Records">

```sql team_record
WITH record AS(
SELECT 
home,
away,
CASE
  WHEN home = '${params.franchise}' THEN away
  ELSE home
  END AS opponent,
'/franchises/' || opponent AS franchise_link,
league,
game_mode,
home_wins,
away_wins,
winning_team AS series_winner,
parent_group_title,
game_mode,
match_group_title
FROM matches m
    INNER JOIN match_groups mg
        ON m.match_group_id = mg.match_group_id
    WHERE parent_group_title = 'Season 19'
    AND home = '${params.franchise}'
    AND league = '${inputs.League}'
    AND game_mode = '${inputs.Gamemodes}'
    OR parent_group_title = 'Season 19'
    AND away = '${params.franchise}'
    AND league = '${inputs.League}'
    AND game_mode = '${inputs.Gamemodes}'
ORDER BY m.match_group_id ASC
), goal_diff AS (
SELECT
r.match_id,
SUBSTRING(mg.match_group_title, 7)::INT AS week,
m.league,
m.game_mode,
r.home AS home,
sum("Home Goals") AS home_goals,
r.away AS away,
sum("Away Goals") AS away_goals,
CASE
    WHEN r.home = '${params.franchise}' THEN home_goals - away_goals
    WHEN r.away = '${params.franchise}' THEN away_goals - home_goals
    END AS goal_differential
FROM s19_rounds r
    INNER JOIN matches m
        ON m.match_id = r.match_id
    INNER JOIN match_groups mg
        ON mg.match_group_id = m.match_group_id
WHERE parent_group_title = 'Season 19'
    AND r.home = '${params.franchise}'
    AND m.league = '${inputs.League}'
    AND m.game_mode = '${inputs.Gamemodes}'
    OR parent_group_title = 'Season 19'
    AND r.away = '${params.franchise}'
    AND m.league = '${inputs.League}'
    AND m.game_mode = '${inputs.Gamemodes}'
GROUP BY r.match_id, week, m.league, m.game_mode, r.home, r.away
ORDER BY week ASC
)
SELECT 
SUBSTRING(match_group_title, 7)::INT AS week,
opponent,
franchise_link,
series_winner,
CASE WHEN series_winner = '${params.franchise}' THEN 'Win' 
    WHEN series_winner = 'Not Played / Data Unavailable' THEN 'NA'
        ELSE 'Loss' 
            END AS series_result,
CASE WHEN re.home = '${params.franchise}' THEN concat(cast(home_wins AS integer), ' - ', cast(away_wins AS integer))   
    WHEN re.away = '${params.franchise}' THEN concat(cast(away_wins AS integer), ' - ', cast(home_wins AS integer))
         END AS record,
series_winner,
re.game_mode,
goal_differential
FROM record re
    INNER JOIN goal_diff gd
        ON re.home = gd.home AND re.away = gd.away
```


<ButtonGroup name=League title="League Selection:" >
    <ButtonGroupItem valueLabel="Foundation League" value="Foundation League" />
    <ButtonGroupItem valueLabel="Academy League" value="Academy League" default />
    <ButtonGroupItem valueLabel="Champion League" value="Champion League" />
    <ButtonGroupItem valueLabel="Master League" value="Master League" />
    <ButtonGroupItem valueLabel="Premier League" value="Premier League" />
</ButtonGroup>

>
<ButtonGroup name=Gamemodes title="GameMode Selection:" >
    <ButtonGroupItem valueLabel="Doubles" value="Doubles" default />
    <ButtonGroupItem valueLabel="Standard" value="Standard" />
</ButtonGroup>

<BigValue data={teamStatistics} value=record /> <BigValue data={teamStatistics} value=series_record /> <BigValue data={teamStatistics} value=goal_differential />

>Season 19 Results
<DataTable data={team_record} rowshading=true headerColor='{team_info[0].primary_color}' headerFontColor=white >
    <Column id=week align=center />
    <Column id=franchise_link contentType=link linkLabel=opponent title=Opponent align=center />
    <Column id=series_result align=center />
    <Column id=record align=center />
    <Column id=goal_differential align=center />
</DataTable>

```sql teamStatistics
WITH S19standings AS (
    
    SELECT
        *
        , CASE
            WHEN s19.mode IN ('Doubles', 'Standard') THEN s19.mode
            ELSE 'Overall'
        END AS game_mode
    FROM S19_standings s19
    INNER JOIN teams t
        ON s19.name = t.Franchise

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
	FROM s19_rounds r
	INNER JOIN matches m
	    ON r.match_id = m.match_id
	INNER JOIN match_groups mg
	    ON m.match_group_id = mg.match_group_id
	WHERE mg.parent_group_title = 'Season 19'
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
	FROM s19_rounds r
	INNER JOIN matches m
	    ON r.match_id = m.match_id
	INNER JOIN match_groups mg
	    ON m.match_group_id = mg.match_group_id
	WHERE mg.parent_group_title = 'Season 19'
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
    s19.ranking AS divisional_rank
    , s19.Franchise AS team_name
    , s19."Photo URL" AS team_logo
    , s19.Division AS division
	, s19."Super Division" AS super_division
    , s19.Conference
    , s19.team_wins::INT || ' - ' || s19.team_losses::INT AS record
    , sagd.series_wins || ' - ' || sagd.series_loses AS series_record
    , sagd.goals_for
    , sagd.goals_against
    , sagd.goal_diff AS goal_differential
FROM S19standings s19
INNER JOIN series_and_goal_diff sagd
    ON s19.Franchise = sagd.team_name
    AND s19.league = sagd.league
    AND s19.game_mode = sagd.game_mode
WHERE s19.conference NOT NULL
    AND s19.division_name NOT NULL
    AND s19.league LIKE '${inputs.League}'
    AND s19.game_mode LIKE '${inputs.Gamemodes}'
    AND team_name = '${params.franchise}'
ORDER BY
    s19.team_wins DESC
    , sagd.series_wins DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```

    </Tab>

    <Tab label="All Time Records">

```sql allTimeRecord
SELECT 
name
,division_name
,CASE
    WHEN conference = 'ORANGE' THEN 'Orange'
    WHEN conference = 'BLUE' THEN 'Blue'
    ELSE NULL
    END AS conference2
,team_wins
,team_losses
,league
,mode
,season
,ranking AS divisional_rank
FROM standings
WHERE name = '${params.franchise}'
AND conference2 = '${team_info[0].Conference}'
AND division_name = '${team_info[0].Division}' 
AND mode = '${inputs.Gamemodes}'
AND league = '${inputs.League}'
ORDER BY season ASC
```


<ButtonGroup name=League title="League Selection:" >
    <ButtonGroupItem valueLabel="Foundation League" value="Foundation League" />
    <ButtonGroupItem valueLabel="Academy League" value="Academy League" default />
    <ButtonGroupItem valueLabel="Champion League" value="Champion League" />
    <ButtonGroupItem valueLabel="Master League" value="Master League" />
    <ButtonGroupItem valueLabel="Premier League" value="Premier League" />
</ButtonGroup>


<ButtonGroup name=Gamemodes title="GameMode Selection:" >
    <ButtonGroupItem valueLabel="Doubles" value="Doubles" default />
    <ButtonGroupItem valueLabel="Standard" value="Standard" />
</ButtonGroup>

## <p> <center> <u> Record By Season </u> </center> </p>
<DataTable data={allTimeRecord} rowshading=true headerColor='{team_info[0].primary_color}' headerFontColor=white totalRow=true >
    <Column id=name align=center />
    <Column id=mode align=center totalAgg='Totals:' />
    <Column id=team_wins align=center totalAgg=sum />
    <Column id=team_losses align=center totalAgg=sum />
    <Column id=season align=center totalAgg='AVG Rank:' />
    <Column id=divisional_rank align=center totalAgg=mean />
</DataTable>

    </Tab>
</Tabs>
