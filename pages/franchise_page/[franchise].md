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

<Tabs>
    <Tab label="Franchise Info">

<LastRefreshed prefix="Data last updated"/>

<center><img src={team_info[0].logo} class="h-32" /></center>

#  <center><Value data={team_info} column=Franchise /> </center>

```sql staff_members
  WITH playerstats AS (
    SELECT
    p.name AS name,
    salary AS salary,
    p.franchise AS franchise,
    s17.skill_group AS league,
    p.member_id AS member_id,
    '/player_page/' || p.member_id AS id_link,
    t."Photo URL" AS logo,
    t."Primary Color" AS primary_color,
    t."Secondary Color" AS secondary_color,
    CASE
       WHEN p."Franchise Staff Position" = 'NA' THEN 'Player'
       ELSE p."Franchise Staff Position"
       END AS franchise_position,
    CASE WHEN p."Franchise Staff Position" = 'Franchise Manager' THEN 1
        WHEN p."Franchise Staff Position" = 'General Manager' THEN 2
        WHEN p."Franchise Staff Position" = 'Assistant General Manager' THEN 3
        WHEN p."Franchise Staff Position" = 'Captain' THEN 4
        WHEN p."Franchise Staff Position" = 'Player' THEN 5
        END AS franchise_order
 FROM players p
    LEFT JOIN S17_stats s17
        ON p.member_id = s17.member_id
    LEFT JOIN teams t
        ON p.franchise = t.Franchise
    )
  SELECT DISTINCT(name),
  salary,
  franchise,
  logo,
  league,
  id_link,
  franchise_position,
  primary_color,
  secondary_color
  FROM playerstats
  WHERE franchise = '${params.franchise}'
  AND franchise_position = 'Franchise Manager' OR
  franchise = '${params.franchise}'
  AND franchise_position = 'General Manager' OR
  franchise = '${params.franchise}'
  AND franchise_position = 'Assistant General Manager'
  ORDER BY franchise_order ASC
```

> Franchise Leadership
<DataTable data={staff_members} rowshading=true headerColor='{team_info[0].primary_color}' headerFontColor=white >
    <Column id=id_link contentType=link linkLabel=name align=center title=Player />
    <Column id=salary align=center />
    <Column id=league align=center />
    <Column id=franchise_position align=center />
</DataTable>

```sql players
SELECT 
name,
'/player_page/' || p.member_id AS id_link,
salary,
skill_group AS league,
franchise,
SUBSTRING(slot, 7) AS slot,
doubles_uses,
standard_uses,
total_uses,
current_scrim_points,
CASE WHEN current_scrim_points >= 30 THEN 'Yes'
    ELSE 'No'
    END AS Eligible
FROM players p
    INNER JOIN role_usages ru
        ON p.franchise = ru.team_name
        AND p.slot = ru.role
        AND upper(p.skill_group) = concat(ru.league, ' LEAGUE')
WHERE franchise = '${params.franchise}'
AND skill_group = '${inputs.League}'
AND slot != 'NONE'
AND season_number = 17
ORDER BY slot ASC
```

```sql captain
  WITH captain_search AS (
    SELECT
    p.name AS name,
    salary AS salary,
    p.franchise AS franchise,
    p.skill_group AS league,
    p.member_id AS member_id,
    '/player_page/' || p.member_id AS id_link,
    p."Franchise Staff Position" AS staff_position,
    CASE 
        WHEN p."Franchise Staff Position"  = 'Franchise Manager'  AND league = '${inputs.League}' THEN 2
        WHEN p."Franchise Staff Position" = 'General Manager' AND league = '${inputs.League}' THEN 3
        WHEN p."Franchise Staff Position" = 'Assistant General Manager' AND league= '${inputs.League}' THEN 4
        WHEN p."Franchise Staff Position" = 'Captain' THEN 1
        WHEN p."Franchise Staff Position"  = 'Franchise Manager' THEN 5
        WHEN p."Franchise Staff Position"  = 'General Manager' THEN 6
        WHEN p."Franchise Staff Position"  = 'Assistant General Manager' THEN 7
        END AS franchise_order
 FROM players p
    )
  SELECT 
  DISTINCT(name),
  salary,
  franchise_order,
  franchise,
  league,
  id_link,
  staff_position

  FROM captain_search

  WHERE franchise = '${params.franchise}'
  AND league = '${inputs.League}'
  AND staff_position = 'Captain'
  OR
  franchise = '${params.franchise}'
  AND staff_position = 'Franchise Manager'
  OR
  franchise = '${params.franchise}'
  AND staff_position = 'General Manager'
  OR
  franchise = '${params.franchise}'
  AND staff_position = 'Assistant General Manager'

ORDER BY franchise_order ASC
```

<ButtonGroup name=League title="League Selection:" >
    <ButtonGroupItem valueLabel="Foundation League" value="Foundation League" />
    <ButtonGroupItem valueLabel="Academy League" value="Academy League" default />
    <ButtonGroupItem valueLabel="Champion League" value="Champion League" />
    <ButtonGroupItem valueLabel="Master League" value="Master League" />
    <ButtonGroupItem valueLabel="Premier League" value="Premier League" />
</ButtonGroup>

<BigValue data={captain} value=name title=Captain: />

> Franchise Players
<DataTable data={players} rowshading=true headerColor='{team_info[0].primary_color}' headerFontColor=white wrapTitles=true>
    <Column id=slot align=center />
    <Column id=id_link contentType=link linkLabel=name align=center title=Player />
    <Column id=salary align=center />
    <Column id=doubles_uses align=center contentType=colorscale scaleColor={['white', 'white', 'yellow', '#ce5050']} colorBreakpoints={[0, 4, 5, 6]} />
    <Column id=standard_uses align=center contentType=colorscale scaleColor={['white', 'white', 'yellow', '#ce5050']} colorBreakpoints={[0, 6, 7, 8]} />
    <Column id=total_uses align=center contentType=colorscale scaleColor={['white', 'white', 'yellow', '#ce5050']} colorBreakpoints={[0, 10, 11, 12]} />
    <Column id=current_scrim_points align=center contentType=colorscale scaleColor={['#ce5050','white']} colorBreakpoints={[0, 30]}/>
</DataTable>

    </Tab>
    <Tab label="Franchise Records">

```sql team_record
WITH record AS(
SELECT 
home,
away,
CASE
  WHEN home = '${params.franchise}' THEN away
  ELSE home
  END AS opponent,
'/franchise_page/' || opponent AS franchise_link,
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
    WHERE parent_group_title = 'Season 17'
    AND home = '${params.franchise}'
    AND league = '${inputs.League}'
    AND game_mode = '${inputs.Gamemodes}'
    OR parent_group_title = 'Season 17'
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
FROM rounds r
    INNER JOIN matches m
        ON m.match_id = r.match_id
    INNER JOIN match_groups mg
        ON mg.match_group_id = m.match_group_id
WHERE parent_group_title = 'Season 17'
    AND r.home = '${params.franchise}'
    AND m.league = '${inputs.League}'
    AND m.game_mode = '${inputs.Gamemodes}'
    OR parent_group_title = 'Season 17'
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

<LastRefreshed prefix="Data last updated"/>

<center><img src={team_info[0].logo} class="h-32" /></center>

#  <center><Value data={team_info} column=Franchise /> </center>

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

>Season 17 Results
<DataTable data={team_record} rowshading=true headerColor='{team_info[0].primary_color}' headerFontColor=white >
    <Column id=week align=center />
    <Column id=franchise_link contentType=link linkLabel=opponent title=Opponent align=center />
    <Column id=series_result align=center />
    <Column id=record align=center />
    <Column id=goal_differential align=center />
</DataTable>

```sql teamStatistics
WITH S17standings AS (
    
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
	    ON m.match_group_id = mg.match_group_id
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
	    ON m.match_group_id = mg.match_group_id
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
    AND s17.league LIKE '${inputs.League}'
    AND s17.game_mode LIKE '${inputs.Gamemodes}'
    AND team_name = '${params.franchise}'
ORDER BY
    s17.team_wins DESC
    , sagd.series_wins DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```

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