```sql basic_info
    SELECT
        p.name,
        salary,
        p.franchise,
        p.skill_group AS league,
        p.member_id,
        p.sprocket_player_id,
        t."Photo URL" AS logo,
        CASE
            WHEN t."Primary Color" IS NULL THEN '#2a4b82'
            ELSE t."Primary Color"
        END AS primColor,
        CASE 
            WHEN t."Secondary Color" IS NULL THEN '#2a4b82'
            ELSE t."Secondary Color"
        END AS secColor,
        t."Primary Color" AS primary_color,
        t."Secondary Color" AS secondary_color,
        CASE
        WHEN p."Franchise Staff Position" = 'NA' THEN 'Player'
        ELSE p."Franchise Staff Position"
        END AS franchise_position,
        current_scrim_points,
        "Eligible Until"
    FROM players p
    LEFT JOIN teams t
        ON p.franchise = t.Franchise
    WHERE p.member_id = '${params.member_id}'
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
    WITH seriesRecord AS (

        SELECT
            p.name,
            p.salary,
            r.Home AS home,
            r.Away AS away,
            m.match_id AS match_id,
            SUBSTRING(mg.match_group_title, 7)::INT AS week,
            CASE
                WHEN r.home = s19.team_name THEN CONCAT(CAST(m.home_wins AS INTEGER), ' - ', CAST(m.away_wins AS INTEGER))   
                WHEN r.away = s19.team_name THEN CONCAT(CAST(m.away_wins AS INTEGER), ' - ', CAST(m.home_wins AS INTEGER))
            END AS record,
            CASE
                WHEN m.winning_team = s19.team_name THEN 'Win' 
                WHEN m.winning_team = 'Not Played / Data Unavailable' THEN 'NA'
                ELSE 'Loss'
            END AS series_result,
            m.game_mode

        FROM players p

        INNER JOIN S19_stats s19
            ON p.member_id = s19.member_id
        INNER JOIN s19_rounds r
            ON s19.match_id = r.match_id

        INNER JOIN matches m
            ON r.match_id = m.match_id

        INNER JOIN match_groups mg
            ON m.match_group_id = mg.match_group_id

        WHERE p.member_id = '${params.member_id}'
            AND mg.parent_group_title = 'Season 19'

        GROUP BY
            p.name
            , p.salary
            , s19.team_name
            , r.home
            , r.away
            , week
            , m.home_wins
            , m.away_wins
            , m.winning_team
            , m.game_mode
            , m.match_id

    ), seriesStats AS (

        SELECT
            p.member_id,
            s19.team_name,
            s19.gamemode,
            s19.match_id,
            count(*) AS games_played,
            avg(s19.dpi) AS Avg_DPI,
            avg(s19.gpi) AS Avg_GPI,
            avg(s19.opi) AS Avg_OPI,
            avg(s19.score) AS Score_Per_Game,
            avg(s19.goals) AS Goals_Per_Game,
            sum(s19.goals) AS total_goals,
            avg(s19.assists) AS Assists_Per_Game,
            sum(s19.assists) AS total_assists,
            avg(s19.saves) AS Saves_Per_Game,
            sum(s19.saves) AS total_saves,
            avg(s19.shots) AS Shots_Per_Game,
            avg(s19.goals_against) AS goals_against_per_game,
            avg(s19.shots_against) AS shots_against_per_game,
            sum(s19.goals)/sum(s19.shots) AS shooting_pct2

        FROM players p

        INNER JOIN S19_stats s19
            ON p.member_id = s19.member_id
        
        WHERE p.member_id = '${params.member_id}'
        
        GROUP BY
            p.member_id
            , s19.team_name
            , s19.gamemode
            , s19.match_id

    )

    SELECT
        sr.week,
        sr.game_mode,
        sr.home,
        sr.away,
        CASE
            WHEN sr.home = ss.team_name THEN sr.away
            ELSE sr.home
        END AS opponent,
        '/franchise_page/' || opponent AS franchise_link,
        ss.games_played,
        sr.record,
        sr.series_result,
        ss.Avg_DPI,
        ss.Avg_GPI,
        ss.Avg_OPI,
        ss.Score_Per_Game,
        ss.Goals_Per_Game,
        ss.total_goals,
        ss.Assists_Per_Game,
        ss.total_assists,
        ss.Saves_Per_Game,
        ss.total_saves,
        ss.Shots_Per_Game,
        ss.goals_against_per_game,
        ss.shots_against_per_game,
        ss.shooting_pct2

    FROM seriesStats ss

    INNER JOIN seriesRecord sr
        ON ss.match_id = sr.match_id

    ORDER BY
        week ASC

```

## Season 19 Stats by Series
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

```sql scrimStats
    SELECT 
        p.name
        , p.member_id
        , p.salary
        , CASE WHEN ass.gamemode = 'RL_DOUBLES' THEN 'Doubles'
            WHEN ass.gamemode = 'RL_STANDARD' THEN 'Standard'
            ELSE 'Unknown' 
            END as game_mode
        , ass.skill_group as league
        , p.franchise
        , ass.scrim_games_played AS games_played
        , ass.win_percentage AS win_pct
        , ass.dpi_per_game as dpi
        , ass.opi_per_game as opi
        , ass.avg_sprocket_rating as sprocket_rating
        , ass.score_per_game as score
        , ass.goals_per_game as goals
        , ass.assists_per_game as assists
        , ass.saves_per_game as saves
        , ass.shots_per_game as shots
        , ass.avg_goals_against as goals_against
        , ass.avg_shots_against as shots_against
        , ass.demos_per_game as demos
        , p.current_scrim_points as scrim_points
        , p."Eligible Until" as eligible_until
    FROM avgScrimStats ass

    LEFT JOIN players p
        ON p.sprocket_player_id = ass.sprocket_player_id
        
    WHERE p.member_id = '${params.member_id}'
```


## Scrim Stats from last 60 Days
<DataTable data={scrimStats} rows=20 rowShading=true headerColor='{basic_info[0].primColor}' headerFontColor=white compact=true wrapTitles=true >
        <Column id=game_mode align=center />
        <Column id=league align=center />
        <Column id=games_played align=center />
        <Column id=win_pct align=center />
        <Column id=sprocket_rating align=center />
        <Column id=opi align=center />
        <Column id=dpi align=center />
        <Column id=score align=ceneter />
        <Column id=goals align=center />
        <Column id=assists align=center />
        <Column id=saves align=center />
        <Column id=shots align=center />
        <Column id=goals_against align=center />
        <Column id=shots_against align=center />
        <Column id=demos align=center />
</DataTable>


## All-Time Stats
```sql LeaderboardStats_career
    SELECT
        name AS Name
        , '/players/' || ps.member_id as playerLink
        , CASE
            WHEN ps.gamemode = 'RL_DOUBLES' THEN 'Doubles'
            WHEN ps.gamemode = 'RL_STANDARD' THEN 'Standard'
            ELSE 'Unknown'
        END AS GameMode
        , SUM(games_played) AS games_played
        , AVG(sprocket_rating) AS 'Sprocket Rating'
        , AVG(opi_per_game) AS OPI
        , AVG(dpi_per_game) AS DPI
        , AVG(avg_score) AS 'Avg Score'
        , SUM(total_goals) AS Goals
        , SUM(total_assists) AS Assists
        , SUM(total_saves) AS Saves
        , SUM(total_shots) AS Shots
        , SUM(total_goals) / SUM(total_shots) AS shooting_pct2
        , SUM(total_demos_inflicted) AS 'Demos'
        , SUM(total_demos_taken) AS 'Demos Taken'
        , AVG(goals_per_game) AS 'Goals/ G'
        , AVG(assists_per_game) AS 'Assists/ G'
        , AVG(saves_per_game) AS 'Saves/ G'
        , AVG(shots_per_game) AS 'Shots/ G'
        , AVG(avg_goals_against) AS 'Goals Against/ G'
        , AVG(avg_shots_against) AS 'Shots Against/ G'
        , AVG(avg_demos_inflicted) AS 'Demos/ G'
        , AVG(avg_demos_taken) AS 'Demos Taken/ G'
    FROM player_stats ps

    WHERE ps.member_id = '${params.member_id}'

    GROUP BY
        Name
        , gamemode
        , playerLink
```



<DataTable data={LeaderboardStats_career} rows=20 rowShading=true headerColor='{basic_info[0].primColor}' headerFontColor=white compact=true wrapTitles=true >
    <Column id=Name align=center />
    <Column id=GameMode align=center />
    <Column id=games_played align=center />
    <Column id='Sprocket Rating' align=center />
    <Column id='OPI' align=center />
    <Column id='DPI' align=center />
    <Column id='Avg Score' align=center />
    <Column id='Goals' align=center />
    <Column id='Assists' align=center />
    <Column id='Saves' align=center />
    <Column id='Shots' align=center />
    <Column id='shooting_pct2' align=center />
    <Column id='Demos' align=center />
    <Column id='Demos Taken' align=center />
    <Column id='Shots/ G' align=center />
    <Column id='Goals/ G' align=center />
    <Column id='Assists/ G' align=center />
    <Column id='Saves/ G' align=center />
    <Column id='Shots/ G' align=center />
    <Column id='Goals Against/ G' align=center />
    <Column id='Shots Against/ G' align=center />
    <Column id='Demos/ G' align=center />
    <Column id='Demos Taken/ G' align=center />
</DataTable>


## Past Season Stats
```sql SeasonStats_career
    SELECT
        name AS Name
        , '/players/' || ps.member_id AS playerLink
        , CASE
            WHEN ps.gamemode = 'RL_DOUBLES' THEN 'Doubles'
            WHEN ps.gamemode = 'RL_STANDARD' THEN 'Standard'
            ELSE 'Unknown'
        END AS GameMode
        , season
        , skill_group AS 'League'
        , team_name AS Franchise
        , SUM(games_played) AS games_played
        , AVG(sprocket_rating) AS 'Sprocket Rating'
        , AVG(opi_per_game) AS 'OPI'
        , AVG(dpi_per_game) AS 'DPI'
        , AVG(avg_score) AS 'Avg Score'
        , SUM(total_goals) AS Goals
        , SUM(total_assists) AS Assists
        , SUM(total_saves) AS Saves
        , SUM(total_shots) AS Shots
        , SUM(total_goals) / SUM(total_shots) AS shooting_pct2
        , SUM(total_demos_inflicted) AS 'Demos'
        , SUM(total_demos_taken) AS 'Demos Taken'
        , AVG(goals_per_game) AS 'Goals/ G'
        , AVG(assists_per_game) AS 'Assists/ G'
        , AVG(saves_per_game) AS 'Saves/ G'
        , AVG(shots_per_game) AS 'Shots/ G'
        , AVG(avg_goals_against) AS 'Goals Against/ G'
        , avg(avg_shots_against) AS 'Shots Against/ G'
        , avg(avg_demos_inflicted) AS 'Demos/ G'
        , avg(avg_demos_taken) AS 'Demos Taken/ G'

    FROM player_stats ps

    WHERE ps.member_id = '${params.member_id}'

    GROUP BY 
        Name
        , gamemode
        , season
        , team_name
        , League
        , playerLink

    ORDER BY
        season
        , Gamemode
```

<DataTable data={SeasonStats_career} rows=20 rowShading=true headerColor='{basic_info[0].primColor}' headerFontColor=white compact=true wrapTitles=true >
    <Column id='Franchise' align=center />
    <Column id='League' align=center />
    <Column id='season' align=center />
    <Column id=GameMode align=center />
    <Column id='games_played' align=center />
    <Column id='Sprocket Rating' align=center />
    <Column id='OPI' align=center />
    <Column id='DPI' align=center />
    <Column id='Avg Score' align=center />
    <Column id='Goals' align=center />
    <Column id='Assists' align=center />
    <Column id='Saves' align=center />
    <Column id='Shots' align=center />
    <Column id='shooting_pct2' align=center />
    <Column id='Demos' align=center />
    <Column id='Demos Taken' align=center />
    <Column id='Goals/ G' align=center />
    <Column id='Assists/ G' align=center />
    <Column id='Saves/ G' align=center />
    <Column id='Shots/ G' align=center />
    <Column id='Goals Against/ G' align=center />
    <Column id='Shots Against/ G' align=center />
    <Column id='Demos/ G' align=center />
    <Column id='Demos Taken/ G' align=center />
</DataTable>
