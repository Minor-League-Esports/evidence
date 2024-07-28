```sql team_info
select 
Franchise,
Conference,
"Super Division",
Division,
Code,
"Primary Color" as primary_color,
"Secondary Color" as secondary_color,
"Photo URL" as logo
 from teams t
where t.franchise = '${params.franchise}'
```

<center><img src={team_info[0].logo} class="h-64" /></center>
<br>

# <center> <Value data={team_info} column=Franchise /> </center>

```sql staff_members
  With playerstats as (
    Select
    p.name as name,
    salary as salary,
    p.franchise as franchise,
    s17.skill_group as league,
    p.member_id as member_id,
    '/player_page/' || p.member_id as id_link,
    t."Photo URL" as logo,
    t."Primary Color" as primary_color,
    t."Secondary Color" as secondary_color,
    case
       when p."Franchise Staff Position" = 'NA' then 'Player'
       else p."Franchise Staff Position"
       end as franchise_position,
    case when p."Franchise Staff Position" = 'Franchise Manager' then 1
        when p."Franchise Staff Position" = 'General Manager' then 2
        when p."Franchise Staff Position" = 'Assistant General Manager' then 3
        when p."Franchise Staff Position" = 'Captain' then 4
        when p."Franchise Staff Position" = 'Player' then 5
        end as franchise_order
 from players p
    left join S17_stats s17
        on p.member_id = s17.member_id
    left join teams t
        on p.franchise = t.Franchise
    )
  select distinct(name),
  salary,
  franchise,
  logo,
  league,
  id_link,
  franchise_position,
  primary_color,
  secondary_color
  from playerstats
  where franchise = '${params.franchise}'
  and franchise_position = 'Franchise Manager' or
  franchise = '${params.franchise}'
  and franchise_position = 'General Manager' or
  franchise = '${params.franchise}'
  and franchise_position = 'Assistant General Manager'
  order by franchise_order asc
```

> Franchise Staff Members
<DataTable data={staff_members} rowshading=true headerColor='{team_info[0].primary_color}' headerFontColor=white>
    <Column id=id_link contentType=link linkLabel=name align=center title=Player />
    <Column id=salary align=center />
    <Column id=league align=center />
    <Column id=franchise_position align=center />
</DataTable>

```sql player_info
select 
name,
'/player_page/' || p.member_id as id_link,
salary,
skill_group as league,
franchise,
SUBSTRING(slot, 7) as slot,
doubles_uses,
standard_uses,
total_uses,
current_scrim_points,
case when current_scrim_points >= 30 then 'Yes'
    else 'No'
    end as Eligible
from players p
    inner join role_usages ru
        on p.franchise = ru.team_name
        and p.slot = ru.role
        and upper(p.skill_group) = concat(ru.league, ' LEAGUE')
where franchise = '${params.franchise}'
and slot != 'NONE'
and season_number = 17
order by slot asc
```

```sql players
select 
name,
'/player_page/' || p.member_id as id_link,
salary,
skill_group as league,
franchise,
SUBSTRING(slot, 7) as slot,
doubles_uses,
standard_uses,
total_uses,
current_scrim_points,
case when current_scrim_points >= 30 then 'Yes'
    else 'No'
    end as Eligible
from players p
    inner join role_usages ru
        on p.franchise = ru.team_name
        and p.slot = ru.role
        and upper(p.skill_group) = concat(ru.league, ' LEAGUE')
where franchise = '${params.franchise}'
and skill_group = '${inputs.League.value}'
and slot != 'NONE'
and season_number = 17
order by slot asc
```

> League Selection
<Dropdown data={player_info} name=League value=league />

> Franchise Players
<DataTable data={players} rowshading=true headerColor='{team_info[0].primary_color}' headerFontColor=white wrapTitles=true>
    <Column id=id_link contentType=link linkLabel=name align=center title=Player />
    <Column id=salary align=center />
    <Column id=slot align=center />
    <Column id=doubles_uses align=center contentType=colorscale scaleColor={['#6db678','white','#ce5050']} colorMin=0 colorMid=3 colorMax=6 />
    <Column id=standard_uses align=center contentType=colorscale scaleColor={['#6db678','white','#ce5050']} colorMin=0 colorMid=4 colorMax=8 />
    <Column id=total_uses align=center contentType=colorscale scaleColor={['#6db678','white','#ce5050']} colorMin=0 colorMid=6 colorMax=12 />
    <Column id=current_scrim_points align=center />
</DataTable>

```sql gamemodes
select game_mode
from matches
```

```sql team_record
with record as(
select 
home,
away,
league,
game_mode,
home_wins,
away_wins,
winning_team as series_winner,
parent_group_title,
game_mode,
match_group_title
from matches m
    inner join match_groups mg
        on m.match_group_id = mg.match_group_id
    where parent_group_title = 'Season 17'
    and home = '${params.franchise}'
    and league = '${inputs.League.value}'
    and game_mode = '${inputs.Gamemodes.value}'
    or parent_group_title = 'Season 17'
    and away = '${params.franchise}'
    and league = '${inputs.League.value}'
    and game_mode = '${inputs.Gamemodes.value}'
order by m.match_group_id asc
)
select 
SUBSTRING(match_group_title, 7) as week,
home,
away,
series_winner,
CASE WHEN series_winner = '${params.franchise}' THEN 'Win' 
    WHEN series_winner = 'Not Played / Data Unavailable' THEN 'NA'
        ELSE 'Loss' 
            END AS series_result,
CASE WHEN home = '${params.franchise}' THEN concat(cast(home_wins as integer), ' - ', cast(away_wins as integer))   
    WHEN away = '${params.franchise}' THEN concat(cast(away_wins as integer), ' - ', cast(home_wins as integer))
         END as record,
series_winner,
game_mode
from record
```

>GameMode Selection
<Dropdown data={gamemodes} name=Gamemodes value=game_mode />

>Season 17 Results
<DataTable data={team_record} rowshading=true headerColor='{team_info[0].primary_color}' headerFontColor=white >
    <Column id=week align=center />
    <Column id=home align=center />
    <Column id=away align=center />
    <Column id=series_result align=center />
    <Column id=record align=center />
</DataTable>