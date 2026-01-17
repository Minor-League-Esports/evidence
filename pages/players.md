```sql player_page_link
SELECT
    name,
    salary,
    '/players/' || CAST(p.member_id AS INTEGER) as id_link,
    franchise, 
    p.current_scrim_points,
    "Eligible Until"
FROM players p
LEFT JOIN S18_stats s18
    ON p.member_id = s18.member_id
WHERE salary <= 21.0 --filtering out TestUser1 & TestUser2 which have > 21.0 salaries
AND NOT franchise = 'FP'
GROUP BY name, salary, p.member_id, franchise, current_scrim_points, "Eligible Until"
```

## Active Player Pages


<LastRefreshed prefix="Data last updated"/>


<DataTable data={player_page_link} search=true rows=10 headerColor=#2a4b82 headerFontColor=white link=id_link >
  <Column id="name" />
  <Column id="salary" align=center />
  <Column id="franchise" align=center />
  <Column id=current_scrim_points align=center contentType=colorscale colorScale={['#ce5050','white']} colorBreakpoints={[0, 30]} />
  <Column id="Eligible Until" align=center />
</DataTable>


```sql playerCount
SELECT
    salary
    , skill_group
    , count(*) as totalPlayers
FROM players p
WHERE salary <= 21.0 --filtering out TestUser1 & TestUser2 which have > 21.0 salaries
AND NOT franchise = 'FP'
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


