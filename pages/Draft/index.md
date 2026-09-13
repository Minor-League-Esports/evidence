---
title: Draft
sidebar_position: 6
---

<LastRefreshed prefix="Data last updated"/>

```sql draft_pool
-- GAP: there is no dedicated "draft pool"/eligibility flag anywhere in sources/ (see
-- SCHEMA_NOTES.md "Gaps"), so this lists every player in the `players` registry — which
-- already includes free agents / non-rostered players (franchise IN ('FA','Pend','Waivers','RFA'))
-- alongside currently rostered ones, per the existing pages/players/non_rostered_players.md query.
-- Building the link here (rather than only inside [sprocket_id].md) is what makes Evidence
-- generate a static page for every player at build time — a templated page is only built for
-- IDs linked to from somewhere in the site.
SELECT
    p.name,
    p.member_id AS mleid,
    p.sprocket_player_id AS sprocket_id,
    p.franchise,
    'Undrafted' AS draft_pick, -- TODO: no draft records table exists yet, see SCHEMA_NOTES.md
    -- sprocket_player_id is stored as a float upstream (e.g. 2.0), so it must be cast to an
    -- integer before concatenating or the link/URL ends up as "/Draft/2.0" (same issue the
    -- existing pages/players/non_rostered_players.md already works around with member_id)
    '/Draft/' || CAST(p.sprocket_player_id AS INTEGER) AS player_link
FROM players p
ORDER BY p.name
```

## Draft Eligible Players

<DataTable data={draft_pool} search=true rows=20 rowShading=true link=player_link>
    <Column id=name align=center />
    <Column id=mleid title="MLEID" align=center />
    <Column id=sprocket_id title="Sprocket ID" align=center />
    <Column id=franchise title="Current Franchise" align=center />
    <Column id=draft_pick title="Draft Pick" align=center />
    <Column id=player_link contentType=link title="Profile" align=center />
</DataTable>

## Export Player Links

Full list of Draft profile URLs for pasting into a Google Sheet.

```sql draft_links_csv
-- cast to INTEGER for the same reason as player_link above: sprocket_player_id is a float
-- upstream and would otherwise render as ".../Draft/2.0"
SELECT
    CAST(p.sprocket_player_id AS INTEGER) AS sprocket_id,
    'https://evidence.mlesports.gg/Draft/' || CAST(p.sprocket_player_id AS INTEGER) AS profile_url
FROM players p
ORDER BY p.sprocket_player_id
```

<DataTable data={draft_links_csv} search=true rows=20 downloadable=true>
    <Column id=sprocket_id title="Sprocket ID" align=center />
    <Column id=profile_url title="Profile URL" align=left />
</DataTable>
