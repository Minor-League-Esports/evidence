---
title: MLE Champions
---

```sql championsTable
SELECT
    'Season ' || c.season::INTEGER AS season,
    COALESCE(fl_t."Photo URL", 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7') AS fl_logo,
    COALESCE(al_t."Photo URL", 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7') AS al_logo,
    COALESCE(cl_t."Photo URL", 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7') AS cl_logo,
    COALESCE(ml_t."Photo URL", 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7') AS ml_logo,
    COALESCE(pl_t."Photo URL", 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7') AS pl_logo
FROM champions c
LEFT JOIN teams fl_t ON fl_t.Franchise = CASE WHEN '${inputs.mode}' = 'Doubles' THEN c.fl_doubles ELSE c.fl_standard END
LEFT JOIN teams al_t ON al_t.Franchise = CASE WHEN '${inputs.mode}' = 'Doubles' THEN c.al_doubles ELSE c.al_standard END
LEFT JOIN teams cl_t ON cl_t.Franchise = CASE WHEN '${inputs.mode}' = 'Doubles' THEN COALESCE(c.cl_doubles, c.solo_doubles) ELSE c.cl_standard END
LEFT JOIN teams ml_t ON ml_t.Franchise = CASE WHEN '${inputs.mode}' = 'Doubles' THEN c.ml_doubles ELSE c.ml_standard END
LEFT JOIN teams pl_t ON pl_t.Franchise = CASE WHEN '${inputs.mode}' = 'Doubles' THEN c.pl_doubles ELSE c.pl_standard END
WHERE '${inputs.mode}' = 'Doubles' OR c.season > 11
ORDER BY c.season DESC
```

```sql earlyChampions
SELECT
    'Season ' || c.season::INTEGER AS season,
    c.solo_doubles AS champion
FROM champions c
WHERE c.season <= 5 AND c.solo_doubles IS NOT NULL
ORDER BY c.season
```

<Alert>
  Multiple leagues were not introduced until Season 6. Seasons 1–5 had a single champion.
</Alert>

<ButtonGroup name="mode">
    <ButtonGroupItem value="Doubles" valueLabel="Doubles" default/>
    <ButtonGroupItem value="Standard" valueLabel="Standard" />
</ButtonGroup>

<DataTable data={championsTable} rowShading=true headerColor=#2a4b82 headerFontColor=white rows=100>
    <Column id=season    title="Season"             align=center />
    <Column id=fl_logo   title="Foundation League"  align=center contentType=image height=2rem />
    <Column id=al_logo   title="Academy League"     align=center contentType=image height=2rem />
    <Column id=cl_logo   title="Champion League"    align=center contentType=image height=2rem />
    <Column id=ml_logo   title="Master League"      align=center contentType=image height=2rem />
    <Column id=pl_logo   title="Premier League"     align=center contentType=image height=2rem />
</DataTable>
