---
title: Player Trackers
sidebar_position: 3
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
WHERE t.name = '${inputs.Dropdown.value}'
ORDER BY
    t.name
```

```sql dropdown
select name from trackers
```

<Dropdown data={dropdown} name=Dropdown value=name defaultValue="OwnerOfTheWhiteSedan" />

<DataTable data={trackers} rows=20 rowShading=true headerColor=#2a4b82 headerFontColor=white>
    <Column id=name />
    <Column id=cleaned_tracker contentType=link linkLabel=platform openInNewTab=true />
    <Column id=gamertag />
</DataTable>
