```sql scrim_info
WITH games AS (
    SELECT DISTINCT
        scrim_id,
        scrim_created_at,
        league,
        game_mode,
        game_number,
        blue_won
    FROM scrim_results
    WHERE scrim_id = TRY_CAST('${params.scrim}' AS INTEGER)
)
SELECT
    scrim_id,
    strftime(scrim_created_at AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York', '%b %d, %Y at %I:%M %p ET') AS played_at,
    MAX(league) AS league,
    MAX(game_mode) AS game_mode,
    COUNT(*) AS games,
    COUNT(*) FILTER (WHERE blue_won) AS blue_wins,
    COUNT(*) FILTER (WHERE NOT blue_won) AS orange_wins
FROM games
GROUP BY scrim_id, scrim_created_at
```

```sql player_summary
SELECT
    COALESCE(p.name, sr.player_name) AS name,
    CASE
        WHEN p.member_id IS NOT NULL THEN '/players/' || CAST(p.member_id AS INTEGER)
        ELSE NULL
    END AS player_link,
    COUNT(*) FILTER (WHERE sr.did_win_game) || ' - ' || COUNT(*) FILTER (WHERE NOT sr.did_win_game) AS record,
    ROUND(AVG(sr.gpi), 2) AS "Sprocket Rating",
    ROUND(AVG(sr.opi), 2) AS "OPI",
    ROUND(AVG(sr.dpi), 2) AS "DPI",
    SUM(sr.goals) AS goals,
    SUM(sr.assists) AS assists,
    SUM(sr.saves) AS saves,
    SUM(sr.shots) AS shots
FROM scrim_results sr
LEFT JOIN players p
    ON p.sprocket_player_id = sr.sprocket_player_id
WHERE sr.scrim_id = TRY_CAST('${params.scrim}' AS INTEGER)
GROUP BY sr.sprocket_player_id, sr.player_name, p.name, p.member_id
ORDER BY "Sprocket Rating" DESC, name
```

```sql game_ids
SELECT DISTINCT game_number
FROM scrim_results
WHERE scrim_id = TRY_CAST('${params.scrim}' AS INTEGER)
ORDER BY game_number
```

```sql game_reports
SELECT
    sr.game_number,
    COALESCE(p.name, sr.player_name) AS name,
    CASE
        WHEN p.member_id IS NOT NULL THEN '/players/' || CAST(p.member_id AS INTEGER)
        ELSE NULL
    END AS player_link,
    '<span style="font-weight:600;color:' ||
        CASE WHEN sr.side = 'Blue' THEN '#2563eb' ELSE '#c2410c' END ||
        ';">' || sr.side || '</span>' AS side_html,
    ROUND(sr.gpi, 2) AS "Sprocket Rating",
    ROUND(sr.opi, 2) AS "OPI",
    ROUND(sr.dpi, 2) AS "DPI",
    sr.score,
    sr.goals,
    sr.assists,
    sr.saves,
    sr.shots
FROM scrim_results sr
LEFT JOIN players p
    ON p.sprocket_player_id = sr.sprocket_player_id
WHERE sr.scrim_id = TRY_CAST('${params.scrim}' AS INTEGER)
ORDER BY sr.game_number, sr.is_blue DESC, "Sprocket Rating" DESC, name
```

{#if scrim_info.length === 0}

## Scrim not found

No data found for scrim `${params.scrim}` in the rolling 13-month history window.

{/if}

{#if scrim_info.length > 0}

# Scrim Results

<div style="display:flex; justify-content:space-between; align-items:center; padding:20px; border:1px solid #ddd; border-radius:8px; gap:30px; margin-bottom:20px;">
    <div style="flex:1;">
        <h3 style="margin:0; font-size:20px; font-weight:bold;">{scrim_info[0].league} {scrim_info[0].game_mode}</h3>
        <p style="margin:5px 0 0 0; color:#666; font-size:14px;">{scrim_info[0].played_at}</p>
        <p style="margin:5px 0 0 0; color:#666; font-size:14px;">{scrim_info[0].games} games played</p>
    </div>
    <div style="text-align:center; min-width:170px;">
        <div style="font-size:13px; color:#666; margin-bottom:4px;">Games Won</div>
        <div style="font-size:32px; font-weight:bold;">
            <span style="color:#2563eb;">{scrim_info[0].blue_wins}</span>
            <span style="color:#666;"> - </span>
            <span style="color:#c2410c;">{scrim_info[0].orange_wins}</span>
        </div>
        <div style="font-size:13px; color:#666;">
            <span style="color:#2563eb;">Blue</span>
            <span> / </span>
            <span style="color:#c2410c;">Orange</span>
        </div>
    </div>
</div>

<Tabs>
    <Tab label="Scrim Report">

        ## Player Summary

        <DataTable data={player_summary} rowShading=true headerColor=#2a4b82 headerFontColor=white wrapTitles=true link=player_link>
            <Column id=player_link contentType=link linkLabel=name align=center title="Name"/>
            <Column id=record align=center title="Game Record"/>
            <Column id="Sprocket Rating" align=center/>
            <Column id="OPI" align=center/>
            <Column id="DPI" align=center/>
            <Column id=goals align=center title="Goals"/>
            <Column id=assists align=center title="Assists"/>
            <Column id=saves align=center title="Saves"/>
            <Column id=shots align=center title="Shots"/>
        </DataTable>
    </Tab>

    <Tab label="Game Reports">

        {#each game_ids as game}

            ## Game {game.game_number}

            <DataTable data={game_reports.where(`game_number = '${game.game_number}'`)} rowShading=true headerColor=#2a4b82 headerFontColor=white wrapTitles=true groupBy=side_html groupType=section>
                <Column id=player_link contentType=link linkLabel=name align=center title="Name"/>
                <Column id=side_html contentType=html align=center title="Side"/>
                <Column id="Sprocket Rating" align=center/>
                <Column id="OPI" align=center/>
                <Column id="DPI" align=center/>
                <Column id=score align=center title="Score"/>
                <Column id=goals align=center title="Goals"/>
                <Column id=assists align=center title="Assists"/>
                <Column id=saves align=center title="Saves"/>
                <Column id=shots align=center title="Shots"/>
            </DataTable>

        {/each}
    </Tab>
</Tabs>

{/if}
