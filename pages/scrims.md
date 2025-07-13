---
title: Scrim Tracker
---

<LastRefreshed prefix="Data last updated"/>

```sql linechart
select * from meta_scrim_stats
```

<LineChart 
    data={linechart}
    x=weekof
    y={['played_matches', '2s_matches', '3s_matches']}
    yAxisTitle="Scrim Played Rounds Test"
    colorPalette={
        [
            '#085411',
            '#09209e',
            '#730821'
        ]
    }
/>

<DataTable data={linechart} totalRow=true>
    <Column id=weekof align=left totalAgg="Total"/>
	<Column id=played_matches align=left />
	<Column id=2s_matches align=left/>
	<Column id=3s_matches align=left />
</DataTable>