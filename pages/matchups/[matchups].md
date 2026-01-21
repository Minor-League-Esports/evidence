```sql matchups_info
    SELECT
        m.league,
        home.division AS home_division,
        m.home,
        away.division AS away_division,
        m.away,
        m.game_mode,
        m.home_wins,
        m.away_wins,
        home."Photo URL" AS home_logo,
        away."Photo URL" AS away_logo,
        '/franchise_page/' || home.franchise AS home_franchise_link,
        '/franchise_page/' || away.franchise AS away_franchise_link,
        CASE 
            WHEN m.winning_team LIKE 'Not Played / Data Unavailable'
            THEN 'Pending'
            ELSE m.winning_team
        END AS winner

    FROM matches m
        INNER JOIN teams home
            ON m.home = home.franchise
        INNER JOIN teams away
            ON m.away = away.franchise
    WHERE m.match_id = '${params.matchups}'
```

```sql home_standings
WITH base_matchup AS (
    SELECT * FROM ${matchups_info}
)
SELECT
    CASE
        WHEN (s18.division_name IS NULL AND s18.conference IS NULL) THEN
            CASE
                WHEN s18.ranking % 100 IN (11, 12, 13) THEN CAST(s18.ranking AS INTEGER) || 'th'
                WHEN s18.ranking % 10 = 1 THEN CAST(s18.ranking AS INTEGER) || 'st'
                WHEN s18.ranking % 10 = 2 THEN CAST(s18.ranking AS INTEGER) || 'nd'
                WHEN s18.ranking % 10 = 3 THEN CAST(s18.ranking AS INTEGER) || 'rd'
                ELSE CAST(s18.ranking AS INTEGER) || 'th'
            END
        ELSE NULL
    END AS overall_ranking,
    CASE
        WHEN (s18.division_name IS NULL AND NOT s18.conference IS NULL) THEN
            CASE
                WHEN s18.ranking % 100 IN (11, 12, 13) THEN CAST(s18.ranking AS INTEGER) || 'th'
                WHEN s18.ranking % 10 = 1 THEN CAST(s18.ranking AS INTEGER) || 'st'
                WHEN s18.ranking % 10 = 2 THEN CAST(s18.ranking AS INTEGER) || 'nd'
                WHEN s18.ranking % 10 = 3 THEN CAST(s18.ranking AS INTEGER) || 'rd'
                ELSE CAST(s18.ranking AS INTEGER) || 'th'
            END            
        ELSE NULL
    END AS conference_ranking,
    CASE
        WHEN (s18.division_name IS NOT NULL AND s18.conference IS NOT NULL) THEN
            CASE
                WHEN s18.ranking % 100 IN (11, 12, 13) THEN CAST(s18.ranking AS INTEGER) || 'th'
                WHEN s18.ranking % 10 = 1 THEN CAST(s18.ranking AS INTEGER) || 'st'
                WHEN s18.ranking % 10 = 2 THEN CAST(s18.ranking AS INTEGER) || 'nd'
                WHEN s18.ranking % 10 = 3 THEN CAST(s18.ranking AS INTEGER) || 'rd'
                ELSE CAST(s18.ranking AS INTEGER) || 'th'
            END
        ELSE NULL
    END AS division_ranking,        
    s18.name,
    s18.division_name,
    s18.conference,
    s18.league,
    s18.mode,
    s18.team_wins,
    s18.team_losses
FROM S18_standings s18
INNER JOIN base_matchup
    ON s18.league = base_matchup.league
    AND s18.mode = base_matchup.game_mode
    AND s18.name = base_matchup.home
WHERE NOT (overall_ranking IS NULL AND conference_ranking IS NULL AND division_ranking IS NULL)
ORDER BY overall_ranking, conference_ranking, division_ranking
```

```sql away_standings
WITH base_matchup AS (
    SELECT * 
    FROM ${matchups_info}
)
SELECT
    CASE
        WHEN (s18.division_name IS NULL AND s18.conference IS NULL) THEN
            CASE
                WHEN s18.ranking % 100 IN (11, 12, 13) THEN CAST(s18.ranking AS INTEGER) || 'th'
                WHEN s18.ranking % 10 = 1 THEN CAST(s18.ranking AS INTEGER) || 'st'
                WHEN s18.ranking % 10 = 2 THEN CAST(s18.ranking AS INTEGER) || 'nd'
                WHEN s18.ranking % 10 = 3 THEN CAST(s18.ranking AS INTEGER) || 'rd'
                ELSE CAST(s18.ranking AS INTEGER) || 'th'
            END
        ELSE NULL
    END AS overall_ranking,
    CASE
        WHEN (s18.division_name IS NULL AND NOT s18.conference IS NULL) THEN
            CASE
                WHEN s18.ranking % 100 IN (11, 12, 13) THEN CAST(s18.ranking AS INTEGER) || 'th'
                WHEN s18.ranking % 10 = 1 THEN CAST(s18.ranking AS INTEGER) || 'st'
                WHEN s18.ranking % 10 = 2 THEN CAST(s18.ranking AS INTEGER) || 'nd'
                WHEN s18.ranking % 10 = 3 THEN CAST(s18.ranking AS INTEGER) || 'rd'
                ELSE CAST(s18.ranking AS INTEGER) || 'th'
            END            
        ELSE NULL
    END AS conference_ranking,
    CASE
        WHEN (s18.division_name IS NOT NULL AND s18.conference IS NOT NULL) THEN
            CASE
                WHEN s18.ranking % 100 IN (11, 12, 13) THEN CAST(s18.ranking AS INTEGER) || 'th'
                WHEN s18.ranking % 10 = 1 THEN CAST(s18.ranking AS INTEGER) || 'st'
                WHEN s18.ranking % 10 = 2 THEN CAST(s18.ranking AS INTEGER) || 'nd'
                WHEN s18.ranking % 10 = 3 THEN CAST(s18.ranking AS INTEGER) || 'rd'
                ELSE CAST(s18.ranking AS INTEGER) || 'th'
            END
        ELSE NULL
    END AS division_ranking,        
    s18.name,
    s18.division_name,
    s18.conference,
    s18.league,
    s18.mode,
    s18.team_wins,
    s18.team_losses
FROM S18_standings s18
INNER JOIN base_matchup
    ON s18.league = base_matchup.league
    AND s18.mode = base_matchup.game_mode
    AND s18.name = base_matchup.away
WHERE NOT (overall_ranking IS NULL AND conference_ranking IS NULL AND division_ranking IS NULL)
ORDER BY overall_ranking, conference_ranking, division_ranking
```


<!--
```sql home_standings_original
    SELECT
        CASE
            WHEN (s18.division_name IS NULL AND s18.conference IS NULL) THEN
                CASE
                    WHEN s18.ranking % 100 IN (11, 12, 13) THEN CAST(s18.ranking AS INTEGER) || 'th'
                    WHEN s18.ranking % 10 = 1 THEN CAST(s18.ranking AS INTEGER) || 'st'
                    WHEN s18.ranking % 10 = 2 THEN CAST(s18.ranking AS INTEGER) || 'nd'
                    WHEN s18.ranking % 10 = 3 THEN CAST(s18.ranking AS INTEGER) || 'rd'
                    ELSE CAST(s18.ranking AS INTEGER) || 'th'
                END
            ELSE NULL
        END AS overall_ranking,
        CASE
            WHEN (s18.division_name IS NULL AND NOT s18.conference IS NULL) THEN
                CASE
                    WHEN s18.ranking % 100 IN (11, 12, 13) THEN CAST(s18.ranking AS INTEGER) || 'th'
                    WHEN s18.ranking % 10 = 1 THEN CAST(s18.ranking AS INTEGER) || 'st'
                    WHEN s18.ranking % 10 = 2 THEN CAST(s18.ranking AS INTEGER) || 'nd'
                    WHEN s18.ranking % 10 = 3 THEN CAST(s18.ranking AS INTEGER) || 'rd'
                    ELSE CAST(s18.ranking AS INTEGER) || 'th'
                END            
            ELSE NULL
        END AS conference_ranking,
        CASE
            WHEN (s18.division_name IS NOT NULL AND s18.conference IS NOT NULL) THEN
                CASE
                    WHEN s18.ranking % 100 IN (11, 12, 13) THEN CAST(s18.ranking AS INTEGER) || 'th'
                    WHEN s18.ranking % 10 = 1 THEN CAST(s18.ranking AS INTEGER) || 'st'
                    WHEN s18.ranking % 10 = 2 THEN CAST(s18.ranking AS INTEGER) || 'nd'
                    WHEN s18.ranking % 10 = 3 THEN CAST(s18.ranking AS INTEGER) || 'rd'
                    ELSE CAST(s18.ranking AS INTEGER) || 'th'
                END
            ELSE NULL
        END AS division_ranking,        
        s18.name,
        s18.division_name,
        s18.conference,
        s18.league,
        s18.mode,
        s18.team_wins,
        s18.team_losses
    FROM S18_standings s18
    WHERE s18.league = 'Academy League'
    AND s18.mode LIKE 'Doubles'
    AND s18.name LIKE 'Bulls'
    AND NOT (overall_ranking IS NULL AND conference_ranking IS NULL AND division_ranking IS NULL)
    ORDER BY overall_ranking, conference_ranking, division_ranking
```

```sql away_standings_original
    SELECT
        CASE
            WHEN (s18.division_name IS NULL AND s18.conference IS NULL) THEN
                CASE
                    WHEN s18.ranking % 100 IN (11, 12, 13) THEN CAST(s18.ranking AS INTEGER) || 'th'
                    WHEN s18.ranking % 10 = 1 THEN CAST(s18.ranking AS INTEGER) || 'st'
                    WHEN s18.ranking % 10 = 2 THEN CAST(s18.ranking AS INTEGER) || 'nd'
                    WHEN s18.ranking % 10 = 3 THEN CAST(s18.ranking AS INTEGER) || 'rd'
                    ELSE CAST(s18.ranking AS INTEGER) || 'th'
                END
            ELSE NULL
        END AS overall_ranking,
        CASE
            WHEN (s18.division_name IS NULL AND NOT s18.conference IS NULL) THEN
                CASE
                    WHEN s18.ranking % 100 IN (11, 12, 13) THEN CAST(s18.ranking AS INTEGER) || 'th'
                    WHEN s18.ranking % 10 = 1 THEN CAST(s18.ranking AS INTEGER) || 'st'
                    WHEN s18.ranking % 10 = 2 THEN CAST(s18.ranking AS INTEGER) || 'nd'
                    WHEN s18.ranking % 10 = 3 THEN CAST(s18.ranking AS INTEGER) || 'rd'
                    ELSE CAST(s18.ranking AS INTEGER) || 'th'
                END            
            ELSE NULL
        END AS conference_ranking,
        CASE
            WHEN (s18.division_name IS NOT NULL AND s18.conference IS NOT NULL) THEN
                CASE
                    WHEN s18.ranking % 100 IN (11, 12, 13) THEN CAST(s18.ranking AS INTEGER) || 'th'
                    WHEN s18.ranking % 10 = 1 THEN CAST(s18.ranking AS INTEGER) || 'st'
                    WHEN s18.ranking % 10 = 2 THEN CAST(s18.ranking AS INTEGER) || 'nd'
                    WHEN s18.ranking % 10 = 3 THEN CAST(s18.ranking AS INTEGER) || 'rd'
                    ELSE CAST(s18.ranking AS INTEGER) || 'th'
                END
            ELSE NULL
        END AS division_ranking,        
        s18.name,
        s18.division_name,
        s18.conference,
        s18.league,
        s18.mode,
        s18.team_wins,
        s18.team_losses
    FROM S18_standings s18
    WHERE s18.league = 'Academy League'
    AND s18.mode LIKE 'Doubles'
    AND s18.name LIKE 'Pandas'
    AND NOT (overall_ranking IS NULL AND conference_ranking IS NULL AND division_ranking IS NULL)
    ORDER BY overall_ranking, conference_ranking, division_ranking
```

-->

<div style="display: flex; justify-content: space-between; align-items: center; padding: 20px; border: 1px solid #ddd; border-radius: 8px; gap: 30px;">
  
  <!-- Left Side: Home Team -->
  <div style="display: flex; align-items: center; gap: 15px; flex: 1;">
    <img src={matchups_info[0].home_logo} alt="Home Team Logo" style="width: 80px; height: 80px; object-fit: contain;">
    <div>
      <h3 style="margin: 0; font-size: 20px; font-weight: bold;">{matchups_info[0].home}</h3>
      <p style="margin: 5px 0 0 0; color: #666; font-size: 14px;">Record: {home_standings[0].team_wins} - {home_standings[0].team_losses}</p>
      <p style="margin: 5px 0 0 0; color: #666; font-size: 14px;">Overall: {home_standings[0].overall_ranking}</p>
      <p style="margin: 5px 0 0 0; color: #666; font-size: 14px;">Division: {home_standings[2].division_ranking}</p>
    </div>
  </div>

  <!-- Center: VS or Score -->
  <div style="text-align: center; font-size: 24px; font-weight: bold; color: #333; min-width: 60px;">
    VS
  </div>

  <!-- Right Side: Away Team -->
  <div style="display: flex; align-items: center; gap: 15px; flex: 1; flex-direction: row-reverse;">
    <img src={matchups_info[0].away_logo} alt="Away Team Logo" style="width: 80px; height: 80px; object-fit: contain;">
    <div style="text-align: right;">
      <h3 style="margin: 0; font-size: 20px; font-weight: bold;">{matchups_info[0].away}</h3>
      <p style="margin: 5px 0 0 0; color: #666; font-size: 14px;">Record: {away_standings[0].team_wins} - {away_standings[0].team_losses}</p>
      <p style="margin: 5px 0 0 0; color: #666; font-size: 14px;">Overall: {away_standings[0].overall_ranking}</p>
      <p style="margin: 5px 0 0 0; color: #666; font-size: 14px;">Division: {away_standings[2].division_ranking}</p>
    </div>
  </div>

</div>


```sql franchise_stats
WITH playerstats AS (
    SELECT name,
    salary AS Salary,
    team_name AS Team,
    s18.skill_group AS league,
    "Primary Color" AS primColor,
    CASE WHEN gamemode = 'RL_DOUBLES' THEN 'Doubles' WHEN gamemode = 'RL_STANDARD' THEN 'Standard' ELSE 'Unknown' END AS GameMode,
    count(*) AS games_played,
    avg(dpi) AS Avg_DPI,
    avg(gpi) AS sprocket_rating,
    avg(opi) AS Avg_OPI,
    avg(score) AS Score_Per_Game,
    avg(goals) AS Goals_Per_Game,
    sum(goals) AS total_goals,
    avg(assists) AS Assists_Per_Game,
    sum(assists) AS total_assists,
    avg(saves) AS Saves_Per_Game,
    sum(saves) AS total_saves,
    avg(shots) AS Shots_Per_Game,
    avg(goals_against) AS goals_against_per_game,
    avg(shots_against) AS shots_against_per_game,
    sum(goals)/sum(shots) AS shooting_pct2
 FROM players p
    INNER JOIN S18_stats s18
        ON p.member_id = s18.member_id
    INNER JOIN teams t 
        ON p.franchise = t.franchise

GROUP BY name, salary, team_name, league, primColor, gamemode
)

SELECT
    Team
    ,name
    ,GameMode
    ,league
    ,primColor
    ,${inputs.stats.value} as stat1

FROM playerstats

WHERE league LIKE '${matchups_info[0].league}'
    AND GameMode LIKE '${matchups_info[0].game_mode}'
    AND (Team LIKE '${matchups_info[0].home}' OR Team LIKE '${matchups_info[0].away}')
ORDER BY stat1 DESC

```

<Dropdown name=stats defaultValue=sprocket_rating>
    <DropdownOption value=avg_dpi valueLabel="Avg DPI" />
    <DropdownOption value=sprocket_rating valueLabel="Avg Sprocket Rating" />
    <DropdownOption value=avg_opi valueLabel="Avg OPI" />
    <DropdownOption value=Score_Per_Game valueLabel="Avg Score" />
    <DropdownOption value=goals_per_game valueLabel="Avg Goals" />
    <DropdownOption value=total_goals valueLabel="Total Goals" />
    <DropdownOption value=assists_per_game valueLabel="Avg Assists" />
    <DropdownOption value=total_assists valueLabel="Total Assists" />
    <DropdownOption value=saves_per_game valueLabel="Avg Saves" />
    <DropdownOption value=total_saves valueLabel="Total Saves" />
    <DropdownOption value=shots_per_game valueLabel="Avg Shots" />
    <DropdownOption value=goals_against_per_game valueLabel="Avg Goals Against" />
    <DropdownOption value=shots_against_per_game valueLabel="Avg Shots Against"/>
    <DropdownOption value=shooting_pct2 valueLabel="Avg Shooting %" />
</Dropdown>


<Grid cols=1 >
    <BarChart data={franchise_stats} title="Matchup Data" x=name y=stat1 swapXY=true series=name seriesLabels=false legend=false yAxisTitle='{inputs.stats.value}' pointSize=15/>

</Grid>


<div style="display: flex; justify-content: space-between; align-items: center; padding: 20px; border: 1px solid #ddd; border-radius: 8px; gap: 30px;">
  
  <!-- Left Side: Home Team -->
  <div style="display: flex; align-items: center; gap: 15px; flex: 1;">
    <img src={matchups_info[0].home_logo} alt="Home Team Logo" style="width: 80px; height: 80px; object-fit: contain;">
    <div>
      <h3 style="margin: 0; font-size: 20px; font-weight: bold;">{matchups_info[0].home}</h3>
      <p style="margin: 5px 0 0 0; color: #666; font-size: 14px;">Record: {home_standings[0].team_wins} - {home_standings[0].team_losses}</p>
      <p style="margin: 5px 0 0 0; color: #666; font-size: 14px;">Overall: {home_standings[0].overall_ranking}</p>
      <p style="margin: 5px 0 0 0; color: #666; font-size: 14px;">Division: {home_standings[2].division_ranking}</p>
    </div>
  </div>

  <!-- Center: Score -->
  <div style="text-align: center; font-size: 32px; font-weight: bold; color: #333; min-width: 80px;">
    {matchups_info[0].home_wins} - {matchups_info[0].away_wins}
  </div>

  <!-- Right Side: Away Team -->
  <div style="display: flex; align-items: center; gap: 15px; flex: 1; flex-direction: row-reverse;">
    <img src={matchups_info[0].away_logo} alt="Away Team Logo" style="width: 80px; height: 80px; object-fit: contain;">
    <div style="text-align: right;">
      <h3 style="margin: 0; font-size: 20px; font-weight: bold;">{matchups_info[0].away}</h3>
      <p style="margin: 5px 0 0 0; color: #666; font-size: 14px;">Record: {away_standings[0].team_wins} - {home_standings[0].team_losses}</p>
      <p style="margin: 5px 0 0 0; color: #666; font-size: 14px;">Overall: {away_standings[0].overall_ranking}</p>
      <p style="margin: 5px 0 0 0; color: #666; font-size: 14px;">Division: {away_standings[2].division_ranking}</p>
    </div>
  </div>

</div>


```sql matches_data
    SELECT 
        p.name,
        s18.team_name AS player_team,
        s18.member_id,
        m.match_id,
        AVG(s18.gpi) AS "Sprocket Rating",
        SUM(s18.goals) AS total_goals,
        SUM(s18.assists) AS total_assists,
        SUM(s18.saves) AS total_saves,
        SUM(s18.shots) AS total_shots
    FROM matches m
        INNER JOIN s18_stats s18
            ON m.match_id = s18.match_id
        INNER JOIN teams home
            ON m.home = home.franchise
        INNER JOIN teams away
            ON m.away = away.franchise 
        INNER JOIN players p
            ON s18.member_id = p.member_id
    WHERE m.match_id = '${params.matchups}'
    GROUP BY
        p.name,
        player_team,
        s18.member_id,
        m.match_id,
    ORDER BY player_team ASC, "Sprocket Rating" DESC
```

```sql rounds_data
    SELECT
        p.name,
        s18.member_id,
        s18.round_id,
        s18.match_id,
        s18.team_name AS player_team,
        s18.gpi AS "Sprocket Rating",
        s18.goals AS total_goals,
        s18.assists AS total_assists,
        s18.saves AS total_saves,
        s18.shots AS total_shots,
        DENSE_RANK() OVER (ORDER BY round_id ASC) AS rank_id 
    FROM s18_stats s18
        INNER JOIN players p
            ON s18.member_id = p.member_id
    WHERE s18.match_id = '${params.matchups}' 
    ORDER by s18.round_id, p.name ASC
```

```sql game_ids
    SELECT DISTINCT rank_id
    FROM (
    SELECT
        p.name,
        s18.member_id,
        s18.round_id,
        s18.match_id,
        s18.team_name AS player_team,
        s18.gpi AS "Sprocket Rating",
        s18.goals AS total_goals,
        s18.assists AS total_assists,
        s18.saves AS total_saves,
        s18.shots AS total_shots,
    DENSE_RANK() OVER (
        ORDER BY round_id ASC
    ) AS rank_id, 
    FROM s18_stats s18
        INNER JOIN players p
            ON s18.member_id = p.member_id
    WHERE s18.match_id = '${params.matchups}' 
    ORDER by s18.round_id
    ) CTE
```

```sql grouped_franchise_matches_data
    SELECT 
        -- p.name,
        s18.team_name AS player_team,
        -- s18.member_id,
        m.match_id,
        AVG(s18.gpi) AS "Sprocket Rating",
        SUM(s18.goals) AS total_goals,
        SUM(s18.assists) AS total_assists,
        SUM(s18.saves) AS total_saves,
        SUM(s18.shots) AS total_shots
    FROM matches m
        INNER JOIN s18_stats s18
            ON m.match_id = s18.match_id
        INNER JOIN teams home
            ON m.home = home.franchise
        INNER JOIN teams away
            ON m.away = away.franchise 
        INNER JOIN players p
            ON s18.member_id = p.member_id
    WHERE m.match_id = '${params.matchups}'
    GROUP BY
        -- p.name,
        player_team,
        -- s18.member_id,
        m.match_id,
    ORDER BY player_team ASC, "Sprocket Rating" DESC
```

<Tabs>

    <Tab label="Series Report">

        ## Series Report

        <DataTable data={matches_data} rowShading=true headerColor=#2a4b82 headerFontColor=white wrapTitles=true groupBy=player_team groupType=section>
            <Column id=name align=center title="Name"/>
            <Column id=player_team align=center title="Team"/>
            <Column id="Sprocket Rating" align=center/>
            <Column id=total_goals align=center title="Goals"/>
            <Column id=total_assists align=center title="Assists"/>
            <Column id=total_saves align=center title="Saves"/>
            <Column id=total_shots align=center title="Shots"/>
        </DataTable>
    </Tab>

    <Tab label="Game Reports">

        {#each game_ids as games}    

            ## Game {games.rank_id}

            <DataTable data={rounds_data.where(`rank_id = '${games.rank_id}'`)} rowShading=true headerColor=#2a4b82 headerFontColor=white wrapTitles=true groupBy=player_team groupType=section>
                <Column id=name align=center title="Name"/>
                <Column id=player_team align=center title="Team"/>
                <Column id="Sprocket Rating" align=center/>
                <Column id=total_goals align=center title="Goals"/>
                <Column id=total_assists align=center title="Assists"/>
                <Column id=total_saves align=center title="Saves"/>
                <Column id=total_shots align=center title="Shots"/>

            </DataTable>

        {/each}


    </Tab>

</Tabs>
