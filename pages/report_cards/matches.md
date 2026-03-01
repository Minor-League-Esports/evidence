---
title: Match Report Cards
---

```sql dropdown_players
SELECT DISTINCT
    player_name,
    league,
    game_mode
FROM match_report_cards
WHERE player_name IS NOT NULL
```

```sql dropdown_teams
SELECT DISTINCT home_team AS team
FROM match_report_cards
WHERE home_team IS NOT NULL
UNION
SELECT DISTINCT away_team AS team
FROM match_report_cards
WHERE away_team IS NOT NULL
```

```sql report_cards
SELECT
    report_card_id,
    report_card_url,
    generated_at,
    match_id,
    legacy_series_id,
    league,
    game_mode,
    home_team,
    away_team,
    string_agg(DISTINCT player_name, ', ') AS players
FROM match_report_cards
WHERE player_name IN ${inputs.Player.value}
  AND league IN ${inputs.League.value}
  AND game_mode IN ${inputs.Mode.value}
  AND (home_team IN ${inputs.Team.value} OR away_team IN ${inputs.Team.value})
GROUP BY
    report_card_id,
    report_card_url,
    generated_at,
    match_id,
    legacy_series_id,
    league,
    game_mode,
    home_team,
    away_team
ORDER BY generated_at DESC
```

<LastRefreshed prefix="Data last updated"/>

<Dropdown data={dropdown_players} name=Player value=player_name multiple=true selectAllByDefault=true />
<Dropdown data={dropdown_players} name=League value=league multiple=true selectAllByDefault=true />
<Dropdown data={dropdown_players} name=Mode value=game_mode multiple=true selectAllByDefault=true />
<Dropdown data={dropdown_teams} name=Team value=team multiple=true selectAllByDefault=true />

<div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 1rem;">
{#each report_cards as card}
  <div style="border: 1px solid #e2e8f0; border-radius: 8px; padding: 0.75rem; background: #ffffff;">
    <a href="{card.report_card_url}" target="_blank" rel="noopener">
      <img alt="Match Report Card" style="width:100%; height:auto; border-radius:6px;" src={card.report_card_url} />
    </a>
    <div style="margin-top: 0.5rem; font-size: 0.9rem;">
      <div><strong>League:</strong> {card.league}</div>
      <div><strong>Mode:</strong> {card.game_mode}</div>
      <div><strong>Match:</strong> {card.home_team} vs {card.away_team}</div>
      <div><strong>Match ID:</strong> {card.match_id}</div>
      <div><strong>Players:</strong> {card.players}</div>
      <div><strong>Generated:</strong> {card.generated_at}</div>
    </div>
  </div>
{/each}
</div>
