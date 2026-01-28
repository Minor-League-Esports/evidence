```sql basic_info
    Select
   -- distinct keeps us from getting multiples of the same information in the basic_info table 
    p.name,
    salary,
    p.franchise,
    p.skill_group as league,
    p.member_id,
    p.sprocket_player_id,
    t."Photo URL" as logo,
    CASE
        WHEN t."Primary Color" is Null then '#2a4b82'
        ELSE t."Primary Color"
        END as primColor,
    CASE 
        WHEN t."Secondary Color" is Null then '#2a4b82'
        ELSE t."Secondary Color"
        END as secColor,
    t."Primary Color" as primary_color,
    t."Secondary Color" as secondary_color,
    case
       when p."Franchise Staff Position" = 'NA' then 'Player'
       else p."Franchise Staff Position"
       END as franchise_position,
    current_scrim_points,
    "Eligible Until"
 from players p
    left join (select distinct member_id, skill_group from S19_stats) s19
        on p.member_id = s19.member_id
    left join teams t
        on p.franchise = t.Franchise
  where p.member_id = '${params.member_id}'
```

<LastRefreshed prefix="Data last updated"/>

{#if basic_info[0].logo}
<center><img class="h-16" alt="Team Logo" style="content: url({basic_info[0].logo}); object-fit: contain;" /></center>
{/if}

# <center> <Value data={basic_info} column=name /> </center>

<DataTable data={basic_info} >
    <Column id=salary align=center />
    <Column id=franchise align=center />
    <Column id=league align=center />
    <Column id=franchise_position align=center />
    <Column id=current_scrim_points align=center contentType=colorscale colorScale={['#ce5050','white']} colorBreakpoints={[0, 30]} />
    <Column id="Eligible Until" align=center />
</DataTable>

```sql scrim_decay
WITH player_scrims as (
    SELECT
        s.scrim_created_at,
        s.scrim_points_earned,
        s.scrim_created_at + INTERVAL 30 DAY AS "expiry_date"
    FROM total_scrim_stats s
    --The scrim stats does not include the member_id so we must grab the other binding feature from the basic info query
    WHERE s.sprocket_player_id = (
        SELECT sprocket_player_id
        FROM ${basic_info}
    )
),
--Retrieve the current date AND the next 30 days
dates AS (
    SELECT CURRENT_DATE + (i - 1) * INTERVAL '1 day' AS "eval_date"
    FROM RANGE(0, 31) AS t(i)
),
--Iteratre through each day
points_by_day AS (
    SELECT
        d.eval_date,
        COALESCE(SUM(s.scrim_points_earned),0) AS points
    FROM dates d
    LEFT JOIN player_scrims s
        ON s.scrim_created_at <= d.eval_date
        AND s.expiry_date > d.eval_date
    GROUP BY d.eval_date
    ORDER BY d.eval_date
)

SELECT 
    *
FROM points_by_day
```

<Details title="Active Scrim Eligibility">
  <p>The chart below displays your scrim point decay from today and over the next 30 days.  That is, the number of scrim points remaining on each day over this timeframe.  You are not eligible for league play once your number of scrim points drops below 30.</p>
</Details>

<!-- Evidence's default line chart configuration applies date labels to the x-axis with the day of date only. -->
<LineChart 
    data={scrim_decay}
    x="eval_date"
    y="points"
    yMin=0
    yMax={Math.max(100, basic_info[0].current_scrim_points+20)}
    title={`${basic_info[0].name} - Scrim Point Decay (Next 30 Days)`}
    xAxisTitle="Date"
    yAxisTitle="Scrim Points"
    
    echartsOptions={{
      xAxis:{
        type: 'time',
        axisLabel: {
          formatter: '{dd} {MMM}'
        }
      }
    }}
>
    <ReferenceLine y=30 label="Eligibility Line" />
    <ReferenceArea yMin=30 label=Eligible color=positive/>
    <ReferenceArea yMax=30 label=Ineligible color=negative/>
</LineChart>

```sql player_stats
  With playerstats as (
    Select
    name,
    p.member_id,
    s19.skill_group as league,
    case
      when gamemode = 'RL_DOUBLES' then 'Doubles'
      when gamemode = 'RL_STANDARD' then 'Standard'
      else gamemode
    end as game_mode,
    avg(dpi) as avg_dpi,
    avg(gpi) as avg_gpi,
    avg(opi) as avg_opi,
    avg(score) as score_per_game,
    avg(goals) as goals_per_game,
    avg(assists) as assists_per_game,
    avg(saves) as saves_per_game,
    avg(shots) as shots_per_game,
    avg(goals_against) as goals_against_per_game,
    avg(shots_against) as shots_against_per_game,
    sum(goals)/sum(shots) as shooting_pct2
 from players p
    inner join S19_stats s19 
        on p.member_id = s19.member_id
where p.member_id = '${params.member_id}'
group by name, league, p.member_id, gamemode
),
leaguestats as (
    select
    s19.skill_group || ' Average' as name,
    'league_averages' as member_id,
    s19.skill_group as league,
    case
      when gamemode = 'RL_DOUBLES' then 'Doubles'
      when gamemode = 'RL_STANDARD' then 'Standard'
      else gamemode
    end as game_mode,
    avg(dpi) as avg_dpi,
    avg(gpi) as avg_gpi,
    avg(opi) as avg_opi,
    avg(score) as score_per_game,
    avg(goals) as goals_per_game,
    avg(assists) as assists_per_game,
    avg(saves) as saves_per_game,
    avg(shots) as shots_per_game,
    avg(goals_against) as goals_against_per_game,
    avg(shots_against) as shots_against_per_game,
    sum(goals)/sum(shots) as shooting_pct2
 from players p
    inner join S19_stats s19
        on p.member_id = s19.member_id
group by League, game_mode
)
  select *
    from playerstats

  union

  select leaguestats.*
    from leaguestats
  inner join playerstats 
    on playerstats.league = leaguestats.league and playerstats.game_mode = leaguestats.game_mode
  order by game_mode
```

```sql comparison
select
game_mode,
name,
${inputs.Stats.value} as value
from ${player_stats}
```

<Details title="Season 19 Player Match Averages">

<p>Below you can use the dropdown to choose the statistic you would like to display. </p>
<p><b>Note:</b> If no information appears then you do not have any statistical data to display. </p>

</Details>

<Dropdown name=Stats defaultValue=score_per_game>
    <DropdownOption value=avg_dpi valueLabel=DPI />
    <DropdownOption value=avg_gpi valueLabel="Sprocket Rating" />
    <DropdownOption value=avg_opi valueLabel=OPI />
    <DropdownOption value=score_per_game valueLabel=Score />
    <DropdownOption value=goals_per_game valueLabel=Goals />
    <DropdownOption value=assists_per_game valueLabel=Assists />
    <DropdownOption value=saves_per_game valueLabel=Saves />
    <DropdownOption value=shots_per_game valueLabel=Shots />
    <DropdownOption value=goals_against_per_game valueLabel="Goals Against" />
    <DropdownOption value=shots_against_per_game valueLabel="Shots Against"/>
    <DropdownOption value=shooting_pct2 valueLabel="Shooting %" />
</Dropdown>

<BarChart 
data={comparison}
x=game_mode
y=value
series=name
type=grouped
colorPalette={[basic_info[0].primColor, '#A9A9A9']}
sort=false
/>

```sql playerSeries
with seriesRecord as(
select 
name,
salary,
r.Home as home,
r.Away as away,
m.match_id as match_id,
SUBSTRING(match_group_title, 7)::INT as week,
CASE WHEN r.home = '${basic_info[0].franchise}' THEN concat(cast(home_wins as integer), ' - ', cast(away_wins as integer))   
    WHEN r.away = '${basic_info[0].franchise}' THEN concat(cast(away_wins as integer), ' - ', cast(home_wins as integer))
         END as record,
CASE WHEN winning_team = '${basic_info[0].franchise}' THEN 'Win' 
    WHEN winning_team = 'Not Played / Data Unavailable' THEN 'NA'
        ELSE 'Loss' 
            END AS series_result,
game_mode
from players p
  inner join S19_stats s19
    on p.member_id = s19.member_id
  inner join s19_rounds r
    on s19.match_id = r.match_id
  inner join matches m
    on r.match_id = m.match_id
  inner join match_groups mg
    on m.match_group_id = mg.match_group_id
where p.member_id = '${params.member_id}'
and parent_group_title = 'Season 19'
group by name, salary, r.home, r.away, week, home_wins, away_wins, winning_team, game_mode, m.match_id
), seriesStats as (
select 
p.member_id,
team_name,
gamemode,
match_id,
count(*) as games_played,
    avg(dpi) as Avg_DPI,
    avg(gpi) as Avg_GPI,
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
where p.member_id = '${params.member_id}'
group by p.member_id, team_name, gamemode, match_id
)
Select
week,
game_mode,
home,
away,
case
  when home = '${basic_info[0].franchise}' then away
  else home
  end as opponent,
'/franchise_page/' || opponent as franchise_link,
games_played,
record,
series_result,
Avg_DPI,
Avg_GPI,
Avg_OPI,
Score_Per_Game,
Goals_Per_Game,
total_goals,
Assists_Per_Game,
total_assists,
Saves_Per_Game,
total_saves,
Shots_Per_Game,
goals_against_per_game,
shots_against_per_game,
shooting_pct2
from seriesStats ss
  inner join seriesRecord sr
    on ss.match_id = sr.match_id
order by week asc 
```

Season 19 Stats by Series
<DataTable data={playerSeries} rows=20 rowShading=true headerColor='{basic_info[0].primColor}' headerFontColor=white compact=true wrapTitles=true>
    <Column id=week align=center />
    <Column id=game_mode align=center />
    <Column id=franchise_link contentType=link linkLabel=opponent title=Opponent align=center />
    <Column id=games_played align=center />
    <Column id=record align=center />
    <Column id=series_result align=center />
    <Column id=Avg_GPI title="Sprocket Rating" align=center />
    <Column id=Avg_OPI align=center />
    <Column id=Avg_DPI align=center />
    <Column id=Score_Per_Game title="Score/Game" align=center />
    <Column id=Goals_Per_Game title="Goals/Game" align=center />
    <Column id=total_goals align=center />
    <Column id=Assists_Per_Game title="Assists/Game" align=center />
    <Column id=total_assists align=center />
    <Column id=Saves_Per_Game title="Saves/Game" align=center />
    <Column id=total_saves align=center />
    <Column id=Shots_Per_Game title="Shots/Game" align=center />
    <Column id=goals_against_per_game title="Goals Against/Game" align=center />
    <Column id=shots_against_per_game title="Shots Against/Game"align=center />
    <Column id=shooting_pct2 align=center />
</DataTable>
