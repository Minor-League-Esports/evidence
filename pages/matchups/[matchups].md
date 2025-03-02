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
    SELECT *
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
    WHERE rank_id = '${inputs.games_group}'
    ORDER BY CTE.name ASC
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

        <ButtonGroup name=games_group>
            <ButtonGroupItem valueLabel="Game 1" value="1" default />
            <ButtonGroupItem valueLabel="Game 2" value="2" />
            <ButtonGroupItem valueLabel="Game 3" value="3" />
            <ButtonGroupItem valueLabel="Game 4" value="4" />
            <ButtonGroupItem valueLabel="Game 5" value ="5" />

        </ButtonGroup>

        ## Game Reports

        <DataTable data={rounds_data} rowShading=true headerColor=#2a4b82 headerFontColor=white wrapTitles=true groupBy=player_team groupType=section >
            <Column id=name align=center title="Name"/>
            <Column id=player_team align=center title="Team"/>
            <Column id="Sprocket Rating" align=center/>
            <Column id=total_goals align=center title="Goals"/>
            <Column id=total_assists align=center title="Assists"/>
            <Column id=total_saves align=center title="Saves"/>
            <Column id=total_shots align=center title="Shots"/>    
        </DataTable>

    </Tab>

</Tabs>