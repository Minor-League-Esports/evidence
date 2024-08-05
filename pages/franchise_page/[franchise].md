```sql team_info
select 
Franchise,
Conference,
"Super Division",
Division,
Code,
"Primary Color" as primary_color,
"Secondary Color" as secondary_color,
"Photo URL" as logo
 from teams t
where t.franchise = '${params.franchise}'
```
<LastRefreshed prefix="Data last updated"/>

<center><img src={team_info[0].logo} class="h-32" /></center>

#  <center><Value data={team_info} column=Franchise /> </center>

```sql staff_members
  With playerstats as (
    Select
    p.name as name,
    salary as salary,
    p.franchise as franchise,
    s17.skill_group as league,
    p.member_id as member_id,
    '/player_page/' || p.member_id as id_link,
    t."Photo URL" as logo,
    t."Primary Color" as primary_color,
    t."Secondary Color" as secondary_color,
    case
       when p."Franchise Staff Position" = 'NA' then 'Player'
       else p."Franchise Staff Position"
       end as franchise_position,
    case when p."Franchise Staff Position" = 'Franchise Manager' then 1
        when p."Franchise Staff Position" = 'General Manager' then 2
        when p."Franchise Staff Position" = 'Assistant General Manager' then 3
        when p."Franchise Staff Position" = 'Captain' then 4
        when p."Franchise Staff Position" = 'Player' then 5
        end as franchise_order
 from players p
    left join S17_stats s17
        on p.member_id = s17.member_id
    left join teams t
        on p.franchise = t.Franchise
    )
  select distinct(name),
  salary,
  franchise,
  logo,
  league,
  id_link,
  franchise_position,
  primary_color,
  secondary_color
  from playerstats
  where franchise = '${params.franchise}'
  and franchise_position = 'Franchise Manager' or
  franchise = '${params.franchise}'
  and franchise_position = 'General Manager' or
  franchise = '${params.franchise}'
  and franchise_position = 'Assistant General Manager'
  order by franchise_order asc
```

> Franchise Staff Members
<DataTable data={staff_members} rowshading=true headerColor='{team_info[0].primary_color}' headerFontColor=white>
    <Column id=id_link contentType=link linkLabel=name align=center title=Player />
    <Column id=salary align=center />
    <Column id=league align=center />
    <Column id=franchise_position align=center />
</DataTable>

```sql player_info
select 
name,
'/player_page/' || p.member_id as id_link,
salary,
skill_group as league,
franchise,
SUBSTRING(slot, 7) as slot,
doubles_uses,
standard_uses,
total_uses,
current_scrim_points,
case when current_scrim_points >= 30 then 'Yes'
    else 'No'
    end as Eligible
from players p
    inner join role_usages ru
        on p.franchise = ru.team_name
        and p.slot = ru.role
        and upper(p.skill_group) = concat(ru.league, ' LEAGUE')
where franchise = '${params.franchise}'
and slot != 'NONE'
and season_number = 17
order by slot asc
```

```sql players
select 
name,
'/player_page/' || p.member_id as id_link,
salary,
skill_group as league,
franchise,
SUBSTRING(slot, 7) as slot,
doubles_uses,
standard_uses,
total_uses,
current_scrim_points,
case when current_scrim_points >= 30 then 'Yes'
    else 'No'
    end as Eligible
from players p
    inner join role_usages ru
        on p.franchise = ru.team_name
        and p.slot = ru.role
        and upper(p.skill_group) = concat(ru.league, ' LEAGUE')
where franchise = '${params.franchise}'
and skill_group = '${inputs.League.value}'
and slot != 'NONE'
and season_number = 17
order by slot asc
```

> League Selection
<Dropdown data={player_info} name=League value=league />

```sql captain
  With captain_search as (
    Select
    p.name as name,
    salary as salary,
    p.franchise as franchise,
    p.skill_group as league,
    p.member_id as member_id,
    '/player_page/' || p.member_id as id_link,
    p."Franchise Staff Position" as staff_position,
    case 
        when p."Franchise Staff Position"  = 'Franchise Manager'  and league = '${inputs.League.value}' then 2
        when p."Franchise Staff Position" = 'General Manager' and league = '${inputs.League.value}' then 3
        when p."Franchise Staff Position" = 'Assistant General Manager' and league= '${inputs.League.value}' then 4
        when p."Franchise Staff Position" = 'Captain' then 1
        when p."Franchise Staff Position"  = 'Franchise Manager' then 5
        when p."Franchise Staff Position"  = 'General Manager' then 6
        when p."Franchise Staff Position"  = 'Assistant General Manager' then 7
        end as franchise_order
 from players p
    )
  select 
  distinct(name),
  salary,
  franchise_order,
  franchise,
  league,
  id_link,
  staff_position

  from captain_search

  where franchise = '${params.franchise}'
  and league = '${inputs.League.value}'
  and staff_position = 'Captain'
  or
  franchise = '${params.franchise}'
  and staff_position = 'Franchise Manager'
  or
  franchise = '${params.franchise}'
  and staff_position = 'General Manager'
  or
  franchise = '${params.franchise}'
  and staff_position = 'Assistant General Manager'

order by franchise_order asc
```

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

```sql gamemodeDropdown
select game_mode
from matches
```

```sql team_record
with record as(
select 
home,
away,
case
  when home = '${params.franchise}' then away
  else home
  end as opponent,
'/franchise_page/' || opponent as franchise_link,
league,
game_mode,
home_wins,
away_wins,
winning_team as series_winner,
parent_group_title,
game_mode,
match_group_title
from matches m
    inner join match_groups mg
        on m.match_group_id = mg.match_group_id
    where parent_group_title = 'Season 17'
    and home = '${params.franchise}'
    and league = '${inputs.League.value}'
    and game_mode = '${inputs.Gamemodes.value}'
    or parent_group_title = 'Season 17'
    and away = '${params.franchise}'
    and league = '${inputs.League.value}'
    and game_mode = '${inputs.Gamemodes.value}'
order by m.match_group_id asc
), goal_diff as (
select
r.match_id,
SUBSTRING(mg.match_group_title, 7)::INT as week,
m.league,
m.game_mode,
r.home as home,
sum("Home Goals") as home_goals,
r.away as away,
sum("Away Goals") as away_goals,
case
    when r.home = '${params.franchise}' then home_goals - away_goals
    when r.away = '${params.franchise}' then away_goals - home_goals
    end as goal_differential
from rounds r
    inner join matches m
        on m.match_id = r.match_id
    inner join match_groups mg
        on mg.match_group_id = m.match_group_id
where parent_group_title = 'Season 17'
    and r.home = '${params.franchise}'
    and m.league = '${inputs.League.value}'
    and m.game_mode = '${inputs.Gamemodes.value}'
    or parent_group_title = 'Season 17'
    and r.away = '${params.franchise}'
    and m.league = '${inputs.League.value}'
    and m.game_mode = '${inputs.Gamemodes.value}'
group by r.match_id, week, m.league, m.game_mode, r.home, r.away
order by week asc
)
select 
SUBSTRING(match_group_title, 7)::INT as week,
opponent,
franchise_link,
series_winner,
CASE WHEN series_winner = '${params.franchise}' THEN 'Win' 
    WHEN series_winner = 'Not Played / Data Unavailable' THEN 'NA'
        ELSE 'Loss' 
            END AS series_result,
CASE WHEN re.home = '${params.franchise}' THEN concat(cast(home_wins as integer), ' - ', cast(away_wins as integer))   
    WHEN re.away = '${params.franchise}' THEN concat(cast(away_wins as integer), ' - ', cast(home_wins as integer))
         END as record,
series_winner,
re.game_mode,
goal_differential
from record re
    inner join goal_diff gd
        on re.home = gd.home and re.away = gd.away
```

>GameMode Selection
<Dropdown data={gamemodeDropdown} name=Gamemodes value=game_mode />

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
    AND s17.game_mode LIKE '${inputs.Gamemodes.value}'
    AND team_name = '${params.franchise}'
ORDER BY
    s17.team_wins DESC
    , sagd.series_wins DESC
    , sagd.goal_diff DESC
    , sagd.goals_for DESC
```