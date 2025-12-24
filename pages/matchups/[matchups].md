```sql team_info
    SELECT
        m.league,
        m.home,
        m.away,
        m.game_mode,
        m.home_wins,
        m.away_wins,
        home."Photo URL" AS home_logo,
        away."Photo URL" AS away_logo,
        '/franchise_page/' || home.franchise AS franchiseLink

    FROM matches m
        INNER JOIN teams home
            ON m.home = home.franchise
        INNER JOIN teams away
            ON m.away = away.franchise
    WHERE m.match_id = '${params.matchups}'
```

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

```sql matches_test
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

<center><img src={team_info[0].home_logo} class="h-32" /><img src={team_info[0].away_logo} class="h-32" /></center>

#  <center><Value data={team_info} column=home /> <Value data={team_info} column=home_wins /> - <Value data={team_info} column=away_wins /> <Value data={team_info} column=away /></center>

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