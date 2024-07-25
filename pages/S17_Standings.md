---
title: S17 Standings
---

<Tabs>
<Tab label="Overall Standings">

## Overall Standings

<Details title='Instructions'>

<p>Below you will find overall standings for MLE in S17.</p>
<p>Please use the dropdown menus below to see the overall standings for your desired league.</p>
</Details>

```sql test
with home_goals as (
select 
r.home as team,
sum("Home Goals") as home_goals,
league,
game_mode,
parent_group_title
    from rounds r
        inner join matches m
            on r.match_id = m.match_id
        inner join fixtures f
            on m.fixture_id = f.fixture_id
        inner join match_groups mg
            on m.match_group_id = mg.match_group_id
    where mg.parent_group_title = 'Season 17' 
        and league = '${inputs.League.value}'
    group by r.home, parent_group_title, league, game_mode
),
away_goals as (
select r.away as team,
sum("Away Goals") as away_goals,
league,
game_mode,
parent_group_title
    from rounds r
        inner join matches m
            on r.match_id = m.match_id
        inner join fixtures f
            on m.fixture_id = f.fixture_id
        inner join match_groups mg
            on m.match_group_id = mg.match_group_id
    where mg.parent_group_title = 'Season 17' 
        and league = '${inputs.League.value}' 
    group by r.away, parent_group_title, league, game_mode
),
home_wins as ( 
select m.home as team,
sum(home_wins) as home_wins,
league,
game_mode,
parent_group_title
    from matches m        
        inner join fixtures f
            on m.fixture_id = f.fixture_id
        inner join match_groups mg
            on m.match_group_id = mg.match_group_id
    where mg.parent_group_title = 'Season 17'  
        and league = '${inputs.League.value}'
    group by m.home, parent_group_title, league, game_mode
),
away_wins as (
select m.away as team,
sum(away_wins) as away_wins,
league,
game_mode,
parent_group_title
    from matches m        
        inner join fixtures f
            on m.fixture_id = f.fixture_id
        inner join match_groups mg
            on m.match_group_id = mg.match_group_id
    where mg.parent_group_title = 'Season 17'  
        and league = '${inputs.League.value}'
    group by m.away, parent_group_title, league, game_mode
),
series as (
select
winning_team as team,
count(winning_team) as series_wins,
league,
game_mode,
parent_group_title
    from matches m        
        inner join fixtures f
            on m.fixture_id = f.fixture_id
        inner join match_groups mg
            on m.match_group_id = mg.match_group_id
    where mg.parent_group_title = 'Season 17'  
        and league = '${inputs.League.value}'
    group by winning_team, league, parent_group_title, game_mode
)
select 
home_goals.team as team,
home_goals,
away_goals,
home_wins,
away_wins,
series_wins,
series.league as league,
series.game_mode as game_mode
from home_goals
    inner join away_goals
        on home_goals.team = away_goals.team
    inner join home_wins
        on home_goals.team = home_wins.team
    inner join away_wins
        on home_goals.team = away_wins.team
    inner join series
        on home_goals.team = series.team    
```

```sql overallStandings
with S17standings as (
    SELECT *
    FROM S17_standings st
        inner join teams t
            on st.name = t.name
)
select
name as team_name,
logo_img_link as team_logo,
division_name as division,
conference as conference,
team_wins as team_wins,
team_losses as team_losses,
league,
mode as gamemode
from S17standings
where conference not null
and division not null
and league like '${inputs.League.value}'
and gamemode is null
group by name, logo_img_link, division_name, conference, league, team_wins, team_losses, gamemode
order by team_wins desc
```

<Dropdown name=League>
    <DropdownOption valueLabel="Foundation League" value="Foundation League"/>
    <DropdownOption valueLabel="Academy League" value="Academy League"/>
    <DropdownOption valueLabel="Champion League" value="Champion League"/>
    <DropdownOption valueLabel="Master League" value="Master League"/>
    <DropdownOption valueLabel="Premier League" value="Premier League"/>
</Dropdown>

<DataTable data={overallStandings} rows=32 rowShading=true wrapTitles=true headerColor=#2a4b82 headerFontColor=white>
    <Column id=team_name align=center />
    <Column id=team_logo contentType=image height=25px align=center />
    <Column id=division align=center />
    <Column id=conference align=center />
    <Column id=team_wins align=center />
    <Column id=team_losses align=center />
    <Column id=league align=center />
</DataTable>
</Tab>

<Tab label="S17 Conference Standings">

<LastRefreshed prefix="Data last updated"/>

<Details title='Instructions'>

<p>Below you will find conference standings for MLE in S17.</p>
<p>Please use the dropdown menus below to sort the data as you see fit.</p>
<p>You have options to sort by League and Mode.</p>
</Details>


```sql blueconference
with S17standings as (
    SELECT *
    FROM S17_standings st
        inner join teams t
            on st.name = t.name
)
select
ranking as divisional_rank,
name as team_name,
logo_img_link as team_logo,
division_name as Division,
conference as Conference,
team_wins,
team_losses,
league as League,
mode as GameMode
from S17standings
where Conference = 'BLUE'
and Division not null
and League like '${inputs.League.value}'
and GameMode like '${inputs.GameMode.value}'
order by team_wins desc
```

## Blue Conference Standings

<Dropdown name=League>
    <DropdownOption valueLabel="Foundation League" value="Foundation League"/>
    <DropdownOption valueLabel="Academy League" value="Academy League"/>
    <DropdownOption valueLabel="Champion League" value="Champion League"/>
    <DropdownOption valueLabel="Master League" value="Master League"/>
    <DropdownOption valueLabel="Premier League" value="Premier League"/>
</Dropdown>

<Dropdown name=GameMode>
    <DropdownOption valueLabel="Doubles" value="Doubles"/>
    <DropdownOption valueLabel="Standard" value="Standard"/>
</Dropdown>

<DataTable data={blueconference} rows=16 rowShading=true headerColor=#1E90FF wrapTitles=true>
    <Column id=divisional_rank align=center />
    <Column id=team_name align=center />
    <Column id=team_logo contentType=image height=25px align=center />
    <Column id=Division align=center />
    <Column id=Conference align=center />
    <Column id=team_wins align=center />
    <Column id=team_losses align=center />
    <Column id=League align=center />
    <Column id=GameMode align=center />
</DataTable>

```sql orangeconference
with S17standings as (
    SELECT *
    FROM S17_standings st
        inner join teams t
            on st.name = t.name
)
select
ranking as divisional_rank,
name as team_name,
logo_img_link as team_logo,
division_name as Division,
conference as Conference,
team_wins,
team_losses,
league as League,
mode as GameMode
from S17standings
where Conference = 'ORANGE'
and Division not null
and League like '${inputs.League1.value}'
and GameMode like '${inputs.GameMode1.value}'
order by team_wins desc
```

## Orange Conference Standings

<Dropdown name=League1>
    <DropdownOption valueLabel="Foundation League" value="Foundation League"/>
    <DropdownOption valueLabel="Academy League" value="Academy League"/>
    <DropdownOption valueLabel="Champion League" value="Champion League"/>
    <DropdownOption valueLabel="Master League" value="Master League"/>
    <DropdownOption valueLabel="Premier League" value="Premier League"/>
</Dropdown>

<Dropdown name=GameMode1>
    <DropdownOption valueLabel="Doubles" value="Doubles"/>
    <DropdownOption valueLabel="Standard" value="Standard"/>
</Dropdown>

<DataTable data={orangeconference} rows=16 rowShading=true headerColor=#FFA500 wrapTitles=true>
    <Column id=divisional_rank align=center />
    <Column id=team_name align=center />
    <Column id=team_logo contentType=image height=25px align=center />
    <Column id=Division align=center />
    <Column id=Conference align=center />
    <Column id=team_wins align=center />
    <Column id=team_losses align=center />
    <Column id=League align=center />
    <Column id=GameMode align=center />
</DataTable>

</Tab>

<Tab label="S17 Divisional Standings">

<LastRefreshed prefix="Data last updated"/>

<Details title='Instructions'>

<p>Below you will find all divisional standings for MLE in S17.</p>
<p>Please use the dropdown menus below to sort the data as you see fit.</p>
<p>You have options to sort by Division, League, and Mode.</p>
<p><b>Note: Not all divisions exist in FL and PL so if a non existent division is selected no information will be displayed.</b></p>
</Details>

```sql bluestandings
with S17standings as (
    SELECT *
    FROM S17_standings st
        inner join teams t
            on st.name = t.name
)
select
ranking as divisional_rank,
name as team_name,
logo_img_link as team_logo,
division_name as Division,
conference as Conference,
team_wins,
team_losses,
league as League,
mode as GameMode
from S17standings
where conference = 'BLUE'
and division_name like '${inputs.division_name.value}'
and League like '${inputs.League.value}'
and GameMode like '${inputs.GameMode.value}'
```

## Blue Conference Divisional Standings

<Dropdown name=division_name>
    <DropdownOption valueLabel="Arctic" value="Arctic"/>
    <DropdownOption valueLabel="Mystic" value="Mystic"/>
    <DropdownOption valueLabel="Sky" value="Sky"/>
    <DropdownOption valueLabel="Storm" value="Storm"/>
</Dropdown>

<Dropdown name=League>
    <DropdownOption valueLabel="Foundation League" value="Foundation League"/>
    <DropdownOption valueLabel="Academy League" value="Academy League"/>
    <DropdownOption valueLabel="Champion League" value="Champion League"/>
    <DropdownOption valueLabel="Master League" value="Master League"/>
    <DropdownOption valueLabel="Premier League" value="Premier League"/>
</Dropdown>

<Dropdown name=GameMode>
    <DropdownOption valueLabel="Doubles" value="Doubles"/>
    <DropdownOption valueLabel="Standard" value="Standard"/>
</Dropdown>

<DataTable data={bluestandings} rows=5 rowShading=true headerColor=#1E90FF wrapTitles=true>
    <Column id=divisional_rank align=center />
    <Column id=team_name align=center />
    <Column id=team_logo contentType=image height=25px align=center />
    <Column id=Division align=center />
    <Column id=Conference align=center />
    <Column id=team_wins align=center />
    <Column id=team_losses align=center />
    <Column id=League align=center />
    <Column id=GameMode align=center />
</DataTable>

```sql orangestandings
with S17standings as (
    SELECT *
    FROM S17_standings st
        inner join teams t
            on st.name = t.name
)
select
ranking as divisional_rank,
name as team_name,
logo_img_link as team_logo,
division_name as Division,
conference as Conference,
team_wins,
team_losses,
league as League,
mode as GameMode
from S17standings
where Conference = 'ORANGE'
and division_name like '${inputs.division.value}'
and League like '${inputs.League1.value}'
and GameMode like '${inputs.GameMode1.value}'
```

## Orange Conference Divisional Standings

<Dropdown name=division>
    <DropdownOption valueLabel="Forge" value="Forge"/>
    <DropdownOption valueLabel="Sun" value="Sun"/>
    <DropdownOption valueLabel="Tropic" value="Tropic" />
    <DropdownOption valueLabel="Volcanic" value="Volcanic"/>
</Dropdown>

<Dropdown name=League1>
    <DropdownOption valueLabel="Foundation League" value="Foundation League"/>
    <DropdownOption valueLabel="Academy League" value="Academy League"/>
    <DropdownOption valueLabel="Champion League" value="Champion League"/>
    <DropdownOption valueLabel="Master League" value="Master League"/>
    <DropdownOption valueLabel="Premier League" value="Premier League"/>
</Dropdown>

<Dropdown name=GameMode1>
    <DropdownOption valueLabel="Doubles" value="Doubles"/>
    <DropdownOption valueLabel="Standard" value="Standard"/>
</Dropdown>

<DataTable data={orangestandings} rows=5 rowShading=true headerColor=#FFA500 wrapTitles=true>
    <Column id=divisional_rank align=center />
    <Column id=team_name align=center />
    <Column id=team_logo contentType=image height=25px align=center />
    <Column id=Division align=center />
    <Column id=Conference align=center />
    <Column id=team_wins align=center />
    <Column id=team_losses align=center />
    <Column id=League align=center />
    <Column id=GameMode align=center />
</DataTable>

</Tab>
</Tabs>
