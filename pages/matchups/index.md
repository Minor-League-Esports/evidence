# S19 Matchups

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
        '/franchise_page/' || m.Home AS home_link,
        '/franchise_page/' || m.Away AS away_link,
        '/matchups/' || m.match_id AS matchups_link,
        mg.match_group_title AS Week
        , strftime(m.scheduled_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York', '%m/%d %I:%M %p') as game_time

    FROM matches m

    LEFT JOIN match_groups mg
        ON m.match_group_id = mg.match_group_id

    WHERE parent_group_title = 'Season 19'
        AND m.League = '${inputs.League_Selection}'
        AND m.game_mode = '${inputs.GameMode_Selection}'
        AND Week = '${inputs.Week_Selection}'
)

SELECT
    match_id,
    Home,
    home_link,
    home_wins::INT || ' - ' || away_wins::INT AS series_score,
    Away,
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
  <!-- <Column id=match_id align=center title="Match Id" /> -->
  <Column id=game_time contentType=datetime format="MMM d, h:mm A" align=center title="Game Time" />
  <Column id=home_link contentType=link linkLabel=home align=center title="Home Team" />
  <Column id=series_score align=center/>
  <Column id=away_link contentType=link linkLabel=away align=center title="Away Team" />

</DataTable>
