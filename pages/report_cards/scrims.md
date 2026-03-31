---
title: Scrim Report Cards
---

```sql dropdown_info
SELECT DISTINCT
    player_name,
    league,
    scrim_mode,
    scrim_type
FROM scrim_report_cards
WHERE player_name IS NOT NULL
```

```sql report_cards
SELECT
    report_card_id,
    report_card_url,
    generated_at,
    scrim_id,
    legacy_scrim_id,
    league,
    scrim_mode,
    scrim_type,
    string_agg(DISTINCT player_name, ', ') AS players
FROM scrim_report_cards
WHERE player_name IN ${inputs.Player.value}
  AND league IN ${inputs.League.value}
  AND scrim_mode IN ${inputs.Mode.value}
  AND scrim_type IN ${inputs.Type.value}
GROUP BY
    report_card_id,
    report_card_url,
    generated_at,
    scrim_id,
    legacy_scrim_id,
    league,
    scrim_mode,
    scrim_type
ORDER BY generated_at DESC
```

<LastRefreshed prefix="Data last updated"/>

<Dropdown data={dropdown_info} name=Player value=player_name multiple=true selectAllByDefault=true />
<Dropdown data={dropdown_info} name=League value=league multiple=true selectAllByDefault=true />
<Dropdown data={dropdown_info} name=Mode value=scrim_mode multiple=true selectAllByDefault=true />
<Dropdown data={dropdown_info} name=Type value=scrim_type multiple=true selectAllByDefault=true />

<div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 1rem;">
{#each report_cards as card}
  <div style="border: 1px solid #e2e8f0; border-radius: 8px; padding: 0.75rem; background: #ffffff;">
    <a href="{card.report_card_url}" target="_blank" rel="noopener">
      <img alt="Scrim Report Card" style="width:100%; height:auto; border-radius:6px;" src={card.report_card_url} />
    </a>
    <div style="margin-top: 0.5rem; font-size: 0.9rem;">
      <div><strong>League:</strong> {card.league}</div>
      <div><strong>Mode:</strong> {card.scrim_mode} • {card.scrim_type}</div>
      <div><strong>Scrim ID:</strong> {card.scrim_id}</div>
      <div><strong>Players:</strong> {card.players}</div>
      <div><strong>Generated:</strong> {card.generated_at}</div>
    </div>
  </div>
{/each}
</div>
