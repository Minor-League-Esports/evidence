```sql basic_info
  With playerstats as (
    Select
    p.name as name,
    salary as salary,
    franchise,
    ps.skill_group as league,
    p.member_id as member_id,
    t.logo_img_link as logo,
    case
       when p."Franchise Staff Position" = 'NA' then 'Player'
       else p."Franchise Staff Position"
       end as franchise_position
 from read_parquet('https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/players.parquet') p
    left join read_parquet('https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/s17/player_stats_s17.parquet') ps
        on p.member_id = ps.member_id
    left join read_parquet('https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/teams.parquet') t
        on p.franchise = t.name
    )
  select distinct(name),
  salary,
  franchise,
  logo,
  league,
  franchise_position
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
    salary,
    team_name as team,
    ps.skill_group as league,
    p.member_id,
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
    avg(shots_against) as shots_against_per_game
 from read_parquet('https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/players.parquet') p
    inner join read_parquet('https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/s17/player_stats_s17.parquet') ps
        on p.member_id = ps.member_id
where p.member_id = '${params.id}'
group by name, salary, team, league, p.member_id, gamemode
)
  select *
  from playerstats
```

<Details title="Player Match Averages">

<p>Below you can use the dropdown to choose the statistic you would like to display. </p>
<p><b>Note:</b> If no information appears then you do not have any statistical data to display. </p>

</Details>

<Dropdown name=Stats defaultValue=score_per_game>
    <DropdownOption value=avg_dpi valueLabel=DPI />
    <DropdownOption value=avg_gpi valueLabel=GPI />
    <DropdownOption value=avg_opi valueLabel=OPI />
    <DropdownOption value=score_per_game valueLabel=Score />
    <DropdownOption value=goals_per_game valueLabel=Goals />
    <DropdownOption value=assists_per_game valueLabel=Assists />
    <DropdownOption value=saves_per_game valueLabel=Saves />
    <DropdownOption value=shots_per_game valueLabel=Shots />
    <DropdownOption value=goals_against_per_game valueLabel="Goals Against" />
    <DropdownOption value=shots_against_per_game valueLabel="Shots Against"/>
</Dropdown>

<BarChart 
data={player_stats}
x=game_mode
y='{inputs.Stats.value}'
/>

<DimensionGrid data={player_stats} />