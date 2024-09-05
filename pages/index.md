---
title: MLE Homepage
---

<LastRefreshed prefix="Data last updated"/>


Evidence is your gateway into MLE's statistics. Here you will find pages for
many areas of current, and historical stats (performance, standings, etc).
If you don't see something here, or are unsure of how to use this tool, reach out
to the team on [Discord](https://discord.com/channels/172404472637685760/323511951357509642)

```sql franchise
SELECT
  franchise
FROM teams
ORDER BY franchise ASC
```

```sql players
SELECT 
name,
'/player_page/' || p.member_id AS id_link,
salary,
skill_group AS league,
case
    when skill_group = 'Foundation League' then 1
    when skill_group = 'Academy League' then 2
    when skill_group = 'Champion League' then 3
    when skill_group = 'Master League' then 4
    when skill_group = 'Premier League' then 5
  end as league_order,
franchise,
SUBSTRING(slot, 7) AS slot,
doubles_uses,
standard_uses,
total_uses,
current_scrim_points,
CASE WHEN current_scrim_points >= 30 THEN 'Yes'
    ELSE 'No'
    END AS Eligible
FROM players p
    INNER JOIN role_usages ru
        ON p.franchise = ru.team_name
        AND p.slot = ru.role
        AND upper(p.skill_group) = concat(ru.league, ' LEAGUE')
WHERE franchise = '${inputs.Team_Selection.value}'
AND skill_group LIKE '${inputs.League_Selection}'
AND slot != 'NONE'
AND season_number = 17
ORDER BY league_order DESC, slot ASC
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

```sql basicInfo
SELECT
    ranking
    , Franchise
    , t.Conference
    , "Super Division"
    , Division
    , Code 
    , "Primary Color"
    , "Secondary Color"
    , "Photo URL"
    , mode
    , league
    , season 
    , team_wins
    , team_losses
FROM S17_standings s17
    INNER JOIN teams t 
        on t.franchise = s17.name
```

<Tabs>

  <Tab label="Standings">

    <ButtonGroup name=League_Selection>
      <ButtonGroupItem valueLabel="Foundation League" value= "Foundation League" />
      <ButtonGroupItem valueLabel="Academy League" value= "Academy League" default />
      <ButtonGroupItem valueLabel="Champion League" value="Champion League" />
      <ButtonGroupItem valueLabel="Master League" value="Master League" />
      <ButtonGroupItem valueLabel="Premier League" value="Premier League" />
    </ButtonGroup>  

  </Tab>

  <Tab label="Eligibility">

    <Dropdown
      data={franchise}
      name=Team_Selection
      value=franchise
      defaultvalue="Aviators"
    />

    <ButtonGroup name=League_Selection>
      <ButtonGroupItem valueLabel="Foundation League" value= "Foundation League" />
      <ButtonGroupItem valueLabel="Academy League" value= "Academy League" default />
      <ButtonGroupItem valueLabel="Champion League" value="Champion League" />
      <ButtonGroupItem valueLabel="Master League" value="Master League" />
      <ButtonGroupItem valueLabel="Premier League" value="Premier League" />
    </ButtonGroup> 
    

    <DataTable data={players} rowshading=true headerColor='{team_info[0].primary_color}' headerFontColor=white wrapTitles=true>
      <Column id=slot align=center />
      <Column id=id_link contentType=link linkLabel=name align=center title=Player />
      <Column id=salary align=center />
      <Column id=doubles_uses align=center contentType=colorscale scaleColor={['white', 'white', 'yellow', '#ce5050']} colorBreakpoints={[0, 4, 5, 6]} />
      <Column id=standard_uses align=center contentType=colorscale scaleColor={['white', 'white', 'yellow', '#ce5050']} colorBreakpoints={[0, 6, 7, 8]} />
      <Column id=total_uses align=center contentType=colorscale scaleColor={['white', 'white', 'yellow', '#ce5050']} colorBreakpoints={[0, 10, 11, 12]} />
      <Column id=current_scrim_points align=center contentType=colorscale scaleColor={['#ce5050','white']} colorBreakpoints={[0, 30]}/>
    </DataTable>

  </Tab>

</Tabs>  
