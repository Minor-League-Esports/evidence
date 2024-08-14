---
title: Player Trackers
---

<LastRefreshed prefix="Data last updated"/>

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
order by name
```


<DataTable data={trackers} rows=20 rowShading=true search=true headerColor=#2a4b82 headerFontColor=white>
    <Column id=name />
    <Column id=tracker contentType=link linkLabel=platform openInNewTab=true />
    <Column id=gamertag />
</DataTable>
