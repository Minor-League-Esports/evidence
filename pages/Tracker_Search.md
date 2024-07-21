---
title: Player Trackers
---

<LastRefreshed prefix="Data last updated"/>

<Details title='Instructions'>

<p>Below you will find all trackers for all players in MLE.</p>
<p>-You can use the drop down menu to search for a specific player.</p>
<p>-Once you find the player you would like to view clicking on their name will direct you to their tracker.</p>
</Details>

```sql dropdown
with tracker_search as (
    SELECT * FROM trackers
)
select
name,
tracker,
platform,
platform_id as gamertag
from tracker_search
```

```sql trackers
with tracker_search as (
    SELECT * FROM trackers
)
select
name,
tracker,
platform,
platform_id as gamertag
from tracker_search
where name like '${inputs.Name.value}'
order by name
```

<Dropdown data={dropdown} name=Name value=name>
    <DropdownOption value="%" valueLabel="Filter By Name"/>
</Dropdown>

<DataTable data={trackers} rows=20 rowShading=true headerColor=#7FFFD4 backgroundColor=#A9A9A9>
    <Column id=tracker align=center contentType=link linkLabel=name openInNewTab=true />
    <Column id=platform align=center />
    <Column id=gamertag align=center />
</DataTable>
