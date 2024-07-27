```sql basic_info
  With playerstats as (
    Select
    p.name as name,
    salary as salary,
    p.franchise,
    s17.skill_group as league,
    p.member_id as member_id,
    t."Photo URL" as logo,
    t."Primary Color" as primary_color,
    t."Secondary Color" as secondary_color,
    case
       when p."Franchise Staff Position" = 'NA' then 'Player'
       else p."Franchise Staff Position"
       end as franchise_position
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
  franchise_position,
  primary_color,
  secondary_color
  from playerstats
  where member_id = '${params.id}'
```

<LastRefreshed/>

# <Value data={basic_info} column=name /> 
<img src={basic_info[0].logo} class="h-16" />

<DataTable data={basic_info} >
    <Column id=salary align=center />
    <Column id=franchise align=center />
    <Column id=league align=center />
    <Column id=franchise_position align=center />
</DataTable>

```sql player_stats
  With playerstats as (
    Select
    name,
    p.member_id,
    s17.skill_group as league,
    case
      when gamemode = 'RL_DOUBLES' then 'Doubles'
      when gamemode = 'RL_STANDARD' then 'Standard'
      else gamemode
    end as game_mode,
    avg(dpi) as avg_dpi,
    avg(gpi) as avg_gpi,
    avg(opi) as avg_opi,
    avg(score) as score_per_game,
    avg(goals) as goals_per_game,
    avg(assists) as assists_per_game,
    avg(saves) as saves_per_game,
    avg(shots) as shots_per_game,
    avg(goals_against) as goals_against_per_game,
    avg(shots_against) as shots_against_per_game,
    sum(goals)/sum(shots) as shooting_pct2
 from players p
    inner join S17_stats s17 
        on p.member_id = s17.member_id
where p.member_id = '${params.id}'
group by name, league, p.member_id, gamemode
),
leaguestats as (
    select
    s17.skill_group || ' Average' as name,
    'league_averages' as member_id,
    s17.skill_group as league,
    case
      when gamemode = 'RL_DOUBLES' then 'Doubles'
      when gamemode = 'RL_STANDARD' then 'Standard'
      else gamemode
    end as game_mode,
    avg(dpi) as avg_dpi,
    avg(gpi) as avg_gpi,
    avg(opi) as avg_opi,
    avg(score) as score_per_game,
    avg(goals) as goals_per_game,
    avg(assists) as assists_per_game,
    avg(saves) as saves_per_game,
    avg(shots) as shots_per_game,
    avg(goals_against) as goals_against_per_game,
    avg(shots_against) as shots_against_per_game,
    sum(goals)/sum(shots) as shooting_pct2
 from players p
    inner join S17_stats s17
        on p.member_id = s17.member_id
group by League, game_mode
)
  select *
    from playerstats

  union

  select leaguestats.*
    from leaguestats
  inner join playerstats 
    on playerstats.league = leaguestats.league and playerstats.game_mode = leaguestats.game_mode
  order by game_mode
```

```sql comparison
select
game_mode,
name,
${inputs.Stats.value} as value
from ${player_stats}
```

<Details title="Player Match Averages">

<p>Below you can use the dropdown to choose the statistic you would like to display. </p>
<p><b>Note:</b> If no information appears then you do not have any statistical data to display. </p>

</Details>

<Dropdown name=Stats defaultValue=score_per_game>
    <DropdownOption value=avg_dpi valueLabel=DPI />
    <DropdownOption value=avg_gpi valueLabel="Sprocket Rating" />
    <DropdownOption value=avg_opi valueLabel=OPI />
    <DropdownOption value=score_per_game valueLabel=Score />
    <DropdownOption value=goals_per_game valueLabel=Goals />
    <DropdownOption value=assists_per_game valueLabel=Assists />
    <DropdownOption value=saves_per_game valueLabel=Saves />
    <DropdownOption value=shots_per_game valueLabel=Shots />
    <DropdownOption value=goals_against_per_game valueLabel="Goals Against" />
    <DropdownOption value=shots_against_per_game valueLabel="Shots Against"/>
    <DropdownOption value=shooting_pct2 valueLabel="Shooting %" />
</Dropdown>

<BarChart 
data={comparison}
x=game_mode
y=value
series=name
type=grouped
colorPalette={[basic_info[0].primary_color, '#A9A9A9']}
sort=false
/>
