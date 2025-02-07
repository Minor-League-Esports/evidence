```sql teamLogos
SELECT 
franchise,
'/franchise_page/' || franchise as franchiseLink,
"Photo URL" as logo
FROM teams
ORDER BY franchise ASC
```
<div style="width:100%; max-width:700px; margin:auto;">
<div style="display:flex; flex-direction:row; align-items:center; justify-content:center; flex-wrap:wrap; gap:0.25rem;"> 
{#each teamLogos as t}
<a href="{t.franchiseLink}" > <img src={t.logo} class="h-10 w-10" /> </a>
{/each}
</div>
</div>


<p>&nbsp; </p>
<h1 style="font-size: 40px;"><center><b> MLE Homepage </b></center></h1>


Evidence is your gateway into MLE's statistics. Here you will find pages for
many areas of current, and historical stats (performance, standings, etc).
If you don't see something here, or are unsure of how to use this tool, reach out
to the team on [Discord](https://discord.com/channels/172404472637685760/323511951357509642).

<h2 style="font-size: 25px;"><center><b><u> Season 17 Champions </u></b></center></h2>

<h3 style="font-size: 20px;"><center><b> Doubles: </b></center></h3>

<div style="text-align: center;">
    <span style="display: inline-flex; align-items: center;">
        <b>FL:</b> &nbsp;Ducks <img src={teamLogos[7].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>AL:</b> &nbsp;Jets <img src={teamLogos[16].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>CL:</b> &nbsp;Puffins <img src={teamLogos[22].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>ML:</b> &nbsp;Ducks <img src={teamLogos[7].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>PL:</b> &nbsp;Rhinos <img src={teamLogos[23].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />
    </span>
</div>

<h3 style="font-size: 20px;"><center><b> Standard: </b></center></h3>

<div style="text-align: center;">
    <span style="display: inline-flex; align-items: center;">
        <b>FL:</b> &nbsp;Pirates <img src={teamLogos[21].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>AL:</b> &nbsp;Jets <img src={teamLogos[16].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>CL:</b> &nbsp;Jets <img src={teamLogos[16].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>ML:</b> &nbsp;Aviators <img src={teamLogos[0].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />
    </span>
    <span style="display: inline-flex; align-items: center;">
        <b>PL:</b> &nbsp;Bulls <img src={teamLogos[3].logo} class="h-10" style="vertical-align: middle; margin-left: 0.5rem; margin-right: 3rem;" />
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
    </ButtonGroup>
</p>

## Blue Conference Standings

```sql blueconference
with S18standings as (
    
    SELECT 
    *,
    '/franchise_page/' || t.Franchise AS Franchise_Link,
    FROM S18_standings st
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
	FROM rounds r
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

)

SELECT
    s18.ranking AS divisional_rank
    , s18.Franchise AS team_name
    , s18."Photo URL" AS team_logo
    , s18.Division AS division
    , s18."Super Division" AS super_division
	, s18.Conference
    , s18.team_wins::INT || ' - ' || s18.team_losses::INT AS record
    , sagd.series_wins || ' - ' || sagd.series_loses AS series_record
    , sagd.goals_for
    , sagd.goals_against
    , sagd.goal_diff AS goal_differential
    , Franchise_Link
FROM S18standings s18
INNER JOIN series_and_goal_diff sagd
    ON s18.Franchise = sagd.team_name
    AND s18.league = sagd.league
    AND s18.mode = sagd.game_mode
WHERE s18.Conference = 'BLUE'
	AND s18.division_name NOT NULL
    AND s18.league LIKE '${inputs.League_Selection}'
    AND s18.mode LIKE '${inputs.GameMode_Selection}'
ORDER BY
    s18.team_wins DESC
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
with S18standings as (
    
    SELECT 
    *,
    '/franchise_page/' || t.Franchise AS Franchise_Link,
    FROM S18_standings st
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
	FROM rounds r
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

)

SELECT
    s18.ranking AS divisional_rank
    , s18.Franchise AS team_name
    , s18."Photo URL" AS team_logo
    , s18.Division AS division
    , s18."Super Division" AS super_division
	, s18.Conference
    , s18.team_wins::INT || ' - ' || s18.team_losses::INT AS record
    , sagd.series_wins || ' - ' || sagd.series_loses AS series_record
    , sagd.goals_for
    , sagd.goals_against
    , sagd.goal_diff AS goal_differential
    , Franchise_Link
FROM S18standings s18
INNER JOIN series_and_goal_diff sagd
    ON s18.Franchise = sagd.team_name
    AND s18.league = sagd.league
    AND s18.mode = sagd.game_mode
WHERE s18.Conference = 'ORANGE'
    AND s18.division_name NOT NULL
    AND s18.league LIKE '${inputs.League_Selection}'
    AND s18.mode LIKE '${inputs.GameMode_Selection}'
ORDER BY
    s18.team_wins DESC
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

  <Tab label="Player Eligibility">

```sql franchise
SELECT
  franchise
FROM teams
ORDER BY franchise ASC
```

```sql eligibility
SELECT 
name,
'/players/' || p.member_id AS id_link,
salary,
skill_group AS league,
CASE
    WHEN skill_group = 'Foundation League' THEN 1 
    WHEN skill_group = 'Academy League' THEN 2 
    WHEN skill_group = 'Champion League' THEN 3 
    WHEN skill_group = 'Master League' THEN 4 
    WHEN skill_group = 'Premier League' THEN 5 
END as league_order, 
franchise,
SUBSTRING(slot, 7) AS slot,
doubles_uses,
standard_uses,
total_uses,
current_scrim_points,
CASE WHEN current_scrim_points >= 30 THEN 'Yes'
    ELSE 'No'
    END AS Eligible,
"Eligible Until"
FROM players p
    INNER JOIN role_usages ru
        ON p.franchise = ru.team_name
        AND p.slot = ru.role
        AND upper(p.skill_group) = concat(ru.league, ' LEAGUE')
WHERE franchise = '${inputs.Team_Selection.value}'
AND slot != 'NONE'
AND season_number = 18 
ORDER BY league_order ASC, slot ASC
```

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
WHERE t.franchise = '${inputs.Team_Selection.value}'
```

<Dropdown
    data={franchise}
    name=Team_Selection
    value=franchise
    defaultvalue="Aviators"
/>


<DataTable data={eligibility} rowshading=true headerColor='{team_info[0].primary_color}' headerFontColor=white wrapTitles=true rows=25 >
      <Column id=league align=center />
      <Column id=slot align=center />
      <Column id=id_link contentType=link linkLabel=name align=center title=Player />
      <Column id=salary align=center />
      <Column id=doubles_uses align=center contentType=colorscale colorScale={['white', 'white', 'yellow', '#ce5050']} colorBreakpoints={[0, 4, 5, 6]} />
      <Column id=standard_uses align=center contentType=colorscale colorScale={['white', 'white', 'yellow', '#ce5050']} colorBreakpoints={[0, 6, 7, 8]} />
      <Column id=total_uses align=center contentType=colorscale colorScale={['white', 'white', 'yellow', '#ce5050']} colorBreakpoints={[0, 10, 11, 12]} />
      <Column id=current_scrim_points align=center contentType=colorscale colorScale={['#ce5050','white']} colorBreakpoints={[0, 30]}/>
      <Column id="Eligible Until" align=center />  
</DataTable>

  </Tab>

  <Tab label="S18 Matchups">

```sql matches
WITH weeks AS 
(
SELECT 
  m.Home,
  m.Away,
  m.League,
  m.game_mode,
  m.home_wins,
  m.away_wins,
  '/franchise_page/' || m.Home AS home_link,
  '/franchise_page/' || m.Away AS away_link,
  CASE 
  WHEN mg.match_group_title='Match 1' THEN 'Week 01'
  WHEN mg.match_group_title='Match 2' THEN 'Week 02'
  WHEN mg.match_group_title='Match 3' THEN 'Week 03'
  WHEN mg.match_group_title='Match 4' THEN 'Week 04'
  WHEN mg.match_group_title='Match 5' THEN 'Week 05'
  WHEN mg.match_group_title='Match 6' THEN 'Week 06'
  WHEN mg.match_group_title='Match 7' THEN 'Week 07'
  WHEN mg.match_group_title='Match 8' THEN 'Week 08'
  WHEN mg.match_group_title='Match 9' THEN 'Week 09'
  WHEN mg.match_group_title='Match 10' THEN 'Week 10'
  ELSE mg.match_group_title
  END AS Week
FROM matches m
INNER JOIN match_groups mg
ON m.match_group_id = mg.match_group_id
WHERE parent_group_title='Season 18'
AND m.League='${inputs.League_Selection}'
AND m.game_mode='${inputs.GameMode_Selection}'
AND Week='${inputs.Week_Selection}'
)
SELECT
Home,
home_link,
home_wins::INT || ' - ' || away_wins::INT AS series_score,
Away,
away_link,
FROM weeks
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
    <ButtonGroupItem valueLabel="Week 1" value= "Week 01" default />
    <ButtonGroupItem valueLabel="Week 2" value= "Week 02" />
    <ButtonGroupItem valueLabel="Week 3" value= "Week 03" />
    <ButtonGroupItem valueLabel="Week 4" value= "Week 04" />
    <ButtonGroupItem valueLabel="Week 5" value= "Week 05" />
    <ButtonGroupItem valueLabel="Week 6" value= "Week 06" />
    <ButtonGroupItem valueLabel="Week 7" value= "Week 07" />
    <ButtonGroupItem valueLabel="Week 8" value= "Week 08" />
    <ButtonGroupItem valueLabel="Week 9" value= "Week 09" />
    <ButtonGroupItem valueLabel="Week 10" value= "Week 10" />

</ButtonGroup>

</p>

<DataTable data={matches} rows=16 headerColor=#2a4b82 headerFontColor=white>
  <Column id=home_link contentType=link linkLabel=home align=center title="Home Team" />
  <Column id=series_score align=center/>
  <Column id=away_link contentType=link linkLabel=away align=center title="Away Team" />

</DataTable>

  </Tab>

</Tabs>

