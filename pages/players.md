```sql player_page_link
SELECT
  name,
  sprocket_player_id,
  salary,
  '/players/' || p.member_id as id_link,
  franchise, 
  p.current_scrim_points,
  "Eligible Until"  
  from players p
  left join S17_stats s17
      on p.member_id = s17.member_id
group by name, sprocket_player_id, salary, p.member_id, franchise, current_scrim_points, "Eligible Until"
```

## Player Pages


<LastRefreshed prefix="Data last updated"/>


<DataTable data={player_page_link} search=true rows=10 headerColor=#2a4b82 headerFontColor=white link=id_link >
  <Column id="name" />
  <Column id="salary" align=center />
  <Column id="franchise" align=center />
  <Column id=current_scrim_points align=center contentType=colorscale scaleColor={['#ce5050','white']} colorBreakpoints={[0, 30]} />
  <Column id="Eligible Until" align=center />
</DataTable>


```sql playerCount
SELECT
    salary
    , skill_group
    , count(*) as totalPlayers
FROM players p
GROUP BY
    salary
    , skill_group
ORDER BY salary
```

<BarChart
    data={playerCount}
    x=salary
    y=totalPlayers
    xAxisTitle="Salaries"
    title="Number of Players per Salary"
    series=skill_group
    stackTotalLabel=true
    colorPalette={[
        '#4ebeec',
        '#0085fa',
        '#7e55ce',
        '#d10057',
        '#e2b22d'
        ]}
/>


