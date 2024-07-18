```sql basic_info
  With playerstats as (
    Select
    p.name as name,
    salary as salary,
    team_name as team,
    ps.skill_group as league,
    p.member_id as member_id,
    t.logo_img_link as logo
 from read_parquet('https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/players.parquet') p
    inner join read_parquet('https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/s17/player_stats_s17.parquet') ps
        on p.member_id = ps.member_id
    inner join read_parquet('https://f004.backblazeb2.com/file/sprocket-artifacts/public/data/teams.parquet') t
        on p.franchise = t.name
    )
  select distinct(name),
  salary,
  team,
  logo,
  league
  from playerstats
  where member_id = '${params.id}'
```

<LastRefreshed/>

# <Value data={basic_info} column=name /> ![Franchise](basic_info(0).logo_img_link)

<DataTable data={basic_info} >
    <Column id=salary align=center />
    <Column id=team align=center />
    <Column id=logo align=center contentType=image height=25px />
    <Column id=league align=center />
</DataTable>

```sql player_stats
  With playerstats as (
    Select
    name,
    salary,
    team_name as team,
    ps.skill_group as league,
    p.member_id,
    gamemode,
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

<Dropdown name=Stats defaultValue=score_per_game>
    <DropdownOption value=avg_dpi />
    <DropdownOption value=avg_gpi />
    <DropdownOption value=avg_opi/>
    <DropdownOption value=score_per_game />
    <DropdownOption value=goals_per_game />
    <DropdownOption value=assists_per_game />
    <DropdownOption value=saves_per_game />
    <DropdownOption value=shots_per_game />
    <DropdownOption value=goals_against_per_game />
    <DropdownOption value=shots_against_per_game />
</Dropdown>

<BarChart 
data={player_stats}
x=gamemode
y='{inputs.Stats.value}'
/>
