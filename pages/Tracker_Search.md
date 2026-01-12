---
title: Player Trackers
---

<LastRefreshed prefix="Data last updated"/>

```sql trackers
SELECT
    t.name
    , CASE 
        WHEN POSITION('[' IN t.tracker) > 0 AND POSITION(']' IN t.tracker) > 0 THEN 
            SUBSTRING(t.tracker FROM POSITION('[' IN t.tracker) + 1 FOR POSITION(']' IN t.tracker) - POSITION('[' IN t.tracker) - 1)
        ELSE 
            t.tracker 
    END AS cleaned_tracker
    , t.platform
    , t.platform_id as gamertag

FROM trackers t
ORDER BY
    t.name
```



<DataTable data={trackers} rows=10 rowShading=true headerColor=#2a4b82 headerFontColor=white search=true>
    <Column id=name />
    <Column id=cleaned_tracker contentType=link linkLabel=platform openInNewTab=true />
    <Column id=gamertag />
</DataTable>
