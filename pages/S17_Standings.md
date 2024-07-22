---
title: S17 Standings
---

<Tabs>
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

<DataTable data={bluestandings} rows=5 rowShading=true headerColor=#1E90FF backgroundColor=#A9A9A9 wrapTitles=true>
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

<DataTable data={orangestandings} rows=5 rowShading=true headerColor=#FFA500 backgroundColor=#A9A9A9 wrapTitles=true>
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
