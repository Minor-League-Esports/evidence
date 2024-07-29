---
title: Franchise Pages
---

<LastRefreshed/>

```sql franchises
select 
Franchise,
'/franchise_page/' || t.Franchise as franchise_link,
"Photo URL" as logo
from teams t
order by franchise asc
```

<DataTable data={franchises} search=true rows=32 headerColor=#2a4b82 headerFontColor=white >
  <Column id="Franchise" align=center/>
  <Column id="logo" contentType=image height=25px align=center />
  <Column id="franchise_link" contentType=link linkLabel="Franchise Page" title="Link to Franchise Page" align=center />
</DataTable>
