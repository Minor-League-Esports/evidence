---
title: Matchups
sidebar_position: 1
---

<LastRefreshed prefix="Data last updated"/>

```sql matches
WITH weeks AS (
    SELECT 
        m.match_id,
        m.Home,
        m.Away,
        m.League,
        m.game_mode,
        m.home_wins,
        m.away_wins,
        '/franchises/' || m.Home AS home_link,
        '/franchises/' || m.Away AS away_link,
        '/matchups/' || m.match_id AS matchups_link,
        mg.match_group_title AS Week,
        strftime(m.scheduled_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York', '%m/%d %I:%M %p') AS game_time,
        t_home."Photo URL" AS home_logo,
        t_away."Photo URL" AS away_logo

    FROM matches m

    LEFT JOIN match_groups mg
        ON m.match_group_id = mg.match_group_id
    LEFT JOIN teams t_home
        ON m.Home = t_home.Franchise
    LEFT JOIN teams t_away
        ON m.Away = t_away.Franchise

    WHERE parent_group_title = 'Season 19'
        AND m.League = '${inputs.League_Selection}'
        AND m.game_mode = '${inputs.GameMode_Selection}'
        AND Week = '${inputs.Week_Selection}'
)

SELECT
    match_id,
    Home,
    home_logo,
    home_link,
    home_wins::INT || ' - ' || away_wins::INT AS series_score,
    Away,
    away_logo,
    away_link,
    matchups_link,
    game_time

FROM weeks

ORDER BY
    game_time
    , home_wins DESC
    , away_wins DESC
    , Home
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
    <ButtonGroupItem valueLabel="Week 1" value="Match 1" default />
    <ButtonGroupItem valueLabel="Week 2" value="Match 2" />
    <ButtonGroupItem valueLabel="Week 3" value="Match 3" />
    <ButtonGroupItem valueLabel="Week 4" value="Match 4" />
    <ButtonGroupItem valueLabel="Week 5" value="Match 5" />
    <ButtonGroupItem valueLabel="Week 6" value="Match 6" />
    <ButtonGroupItem valueLabel="Week 7" value="Match 7" />
    <ButtonGroupItem valueLabel="Week 8" value="Match 8" />
    <ButtonGroupItem valueLabel="Week 9" value="Match 9" />
    <ButtonGroupItem valueLabel="Week 10" value="Match 10" />

</ButtonGroup>

</p>

<DataTable data={matches} rows=16 headerColor=#2a4b82 headerFontColor=white link=matchups_link>
  <Column id=game_time contentType=datetime format="MMM d, h:mm A" align=center title="Game Time" />
  <Column id=home_logo contentType=image height=25px align=center title="" />
  <Column id=home_link contentType=link linkLabel=home align=left title="Home" />
  <Column id=series_score align=center title="Score" />
  <Column id=away_link contentType=link linkLabel=away align=right title="Away" />
  <Column id=away_logo contentType=image height=25px align=center title="" />
</DataTable>

---

## Franchise Schedule Lookup

```sql franchise_list
SELECT DISTINCT Franchise AS franchise
FROM teams
ORDER BY franchise
```

```sql franchise_schedule
SELECT
    strftime(m.scheduled_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York', '%m/%d %I:%M %p') AS game_time,
    m.League AS league,
    m.game_mode AS mode
FROM matches m
INNER JOIN match_groups mg ON m.match_group_id = mg.match_group_id
WHERE mg.parent_group_title = 'Season 19'
    AND mg.match_group_title IN ${inputs.FranchiseWeek.value}
    AND (m.Home IN ${inputs.Franchise_Selection.value} OR m.Away IN ${inputs.Franchise_Selection.value})
ORDER BY game_time
```

<Dropdown data={franchise_list} name=Franchise_Selection value=franchise label=franchise multiple=true selectAllByDefault=false />

<ButtonGroup name=FranchiseWeek>
    <ButtonGroupItem valueLabel="Week 1" value="Match 1" default />
    <ButtonGroupItem valueLabel="Week 2" value="Match 2" />
    <ButtonGroupItem valueLabel="Week 3" value="Match 3" />
    <ButtonGroupItem valueLabel="Week 4" value="Match 4" />
    <ButtonGroupItem valueLabel="Week 5" value="Match 5" />
    <ButtonGroupItem valueLabel="Week 6" value="Match 6" />
    <ButtonGroupItem valueLabel="Week 7" value="Match 7" />
    <ButtonGroupItem valueLabel="Week 8" value="Match 8" />
    <ButtonGroupItem valueLabel="Week 9" value="Match 9" />
    <ButtonGroupItem valueLabel="Week 10" value="Match 10" />
</ButtonGroup>

<DataTable data={franchise_schedule} headerColor=#2a4b82 headerFontColor=white>
  <Column id=game_time align=center title="Game Time" />
  <Column id=league align=center title="League" />
  <Column id=mode align=center title="Mode" />
</DataTable>
