<script>
  // PlayoffBracket.svelte — Renders a dynamic playoff bracket for MLE Season 19.
  //
  // Supports two layouts based on league size:
  //   - 16-team (Foundation League, Premier League): 3 columns (SF → CF → Championship)
  //     Seeds are partitioned by conference (Orange/Blue), 4 per conference.
  //   - 32-team (Academy, Champion, Master League): 4 columns (QF → SF → CF → GF)
  //     Seeds are partitioned by super_division (West/East for Orange, North/South for Blue).
  //
  // Seeding uses calculated standings from playoff_seeds with full tiebreaker resolution,
  // and switches to official playoff_games data when the "Season 19 Playoffs" match group has results.
  //
  // Props:
  //   playoff_seeds    — SQL result: teams with win_pct, series_win_pct, goal_differential, etc.
  //   playoff_games    — SQL result: official playoff matchups (empty until playoffs begin)
  //   h2h_records      — SQL result: pairwise head-to-head game win totals between teams
  //   division_records — SQL result: each team's game win % in division-only matchups
  //   league           — string: the selected league name, used to determine bracket layout

  export let playoff_seeds = [];
  export let playoff_games = [];
  export let h2h_records = [];
  export let division_records = [];
  export let league = '';

  // 16-team leagues use conference-based seeding; 32-team leagues use super_division-based seeding
  $: is16 = league === 'Foundation League' || league === 'Premier League';

  // ===== Tiebreaker Engine (MLE Rules 1.9.1–1.9.6) =====
  // Order: Win% → H2H → Series% → Division% (same div only) → Goal Diff → Goals For
  // Division leaders are guaranteed seeds 1–2; wildcards get seeds 3–4.
  // Within each group, teams are sorted by win% first, then tiebreakers resolve only
  // among teams with identical win%.

  // Returns teamA's game win percentage against teamB (0–1), or null if they never played.
  function getH2HWinPct(teamA, teamB) {
    let aWins = 0, bWins = 0;
    const direct = h2h_records.find(r => r.team_a === teamA && r.team_b === teamB);
    if (direct) { aWins += direct.a_game_wins; bWins += direct.b_game_wins; }
    const reverse = h2h_records.find(r => r.team_a === teamB && r.team_b === teamA);
    if (reverse) { aWins += reverse.b_game_wins; bWins += reverse.a_game_wins; }
    if (aWins + bWins === 0) return null;
    return aWins / (aWins + bWins);
  }

  function beatsAll(team, opponents) {
    return opponents.every(opp => {
      const pct = getH2HWinPct(team.team_name, opp.team_name);
      return pct !== null && pct > 0.5;
    });
  }

  function losesToAll(team, opponents) {
    return opponents.every(opp => {
      const pct = getH2HWinPct(team.team_name, opp.team_name);
      return pct !== null && pct < 0.5;
    });
  }

  // Multi-team H2H elimination (rules 1.9.2.1–1.9.2.3):
  // Iteratively removes teams that beat ALL or lose to ALL others, then restarts.
  function multiTeamH2H(teams) {
    let remaining = [...teams];
    let top = [], bottom = [];
    let changed = true;
    while (changed && remaining.length > 1) {
      changed = false;
      let newTop = [], newBottom = [];
      // Rules 1.9.2.1 + 1.9.2.2 observed simultaneously (1.9.2.3)
      for (const team of remaining) {
        const others = remaining.filter(t => t !== team);
        if (beatsAll(team, others)) newTop.push(team);
        else if (losesToAll(team, others)) newBottom.push(team);
      }
      if (newTop.length > 0 || newBottom.length > 0) {
        top.push(...newTop);
        bottom.unshift(...newBottom);
        remaining = remaining.filter(t => !newTop.includes(t) && !newBottom.includes(t));
        changed = true;
      }
    }
    return { top, bottom, remaining };
  }

  // Groups teams by a stat value (descending), returns array of arrays with equal values.
  function groupByValue(teams, stat) {
    if (teams.length === 0) return [];
    const sorted = [...teams].sort((a, b) => (b[stat] ?? 0) - (a[stat] ?? 0));
    const groups = [[sorted[0]]];
    for (let i = 1; i < sorted.length; i++) {
      if ((sorted[i][stat] ?? 0) === (groups[groups.length - 1][0][stat] ?? 0)) {
        groups[groups.length - 1].push(sorted[i]);
      } else {
        groups.push([sorted[i]]);
      }
    }
    return groups;
  }

  function allShareDivision(teams) {
    const divs = new Set(teams.map(t => t.division).filter(Boolean));
    return divs.size === 1;
  }

  function getDivWinPct(teamName) {
    return division_records.find(r => r.team_name === teamName)?.div_win_pct ?? 0;
  }

  // Recursive tiebreaker resolution per rules 1.9.1-1.9.6.
  // On any elimination the procedure restarts from the top (via recursion).
  function resolveCluster(tiedTeams) {
    if (tiedTeams.length <= 1) return tiedTeams;

    // Step 2: H2H
    if (tiedTeams.length === 2) {
      const pct = getH2HWinPct(tiedTeams[0].team_name, tiedTeams[1].team_name);
      if (pct !== null && pct !== 0.5) {
        return pct > 0.5 ? [tiedTeams[0], tiedTeams[1]] : [tiedTeams[1], tiedTeams[0]];
      }
    } else {
      const { top, bottom, remaining } = multiTeamH2H(tiedTeams);
      if (top.length > 0 || bottom.length > 0) {
        return [...top, ...resolveCluster(remaining), ...bottom];
      }
    }

    // Step 3: Series win %
    const bySeries = groupByValue(tiedTeams, 'series_win_pct');
    if (bySeries.length > 1) return bySeries.flatMap(g => resolveCluster(g));

    // Step 4: Division game win % (only if all tied teams share a division)
    if (allShareDivision(tiedTeams)) {
      const withDiv = tiedTeams.map(t => ({ ...t, _dwp: getDivWinPct(t.team_name) }));
      const byDiv = groupByValue(withDiv, '_dwp');
      if (byDiv.length > 1) return byDiv.flatMap(g => resolveCluster(g));
    }

    // Step 5: Goal differential
    const byGD = groupByValue(tiedTeams, 'goal_differential');
    if (byGD.length > 1) return byGD.flatMap(g => resolveCluster(g));

    // Step 6: Goals for
    const byGF = groupByValue(tiedTeams, 'goals_for');
    if (byGF.length > 1) return byGF.flatMap(g => resolveCluster(g));

    return tiedTeams;
  }

  // Main entry point: partitions seeds by conference or super_division, then resolves
  // seeding within each partition. Leaders (div winners) are ranked first, then wildcards.
  function resolveTiebreakers(seeds, is16Team) {
    if (!seeds || seeds.length === 0) return [];
    const partKey = is16Team ? 'conference' : 'super_division';
    const groups = {};
    for (const t of seeds) {
      const k = t[partKey] ?? 'unknown';
      if (!groups[k]) groups[k] = [];
      groups[k].push(t);
    }
    // Sort by win_pct first, then only apply tiebreakers within same win_pct
    function resolveGroup(teams) {
      if (teams.length <= 1) return teams;
      const byWinPct = groupByValue(teams, 'win_pct');
      return byWinPct.flatMap(g => g.length === 1 ? g : resolveCluster(g));
    }

    const result = [];
    for (const teams of Object.values(groups)) {
      const leaders = teams.filter(t => t.is_divisional_leader == 1);
      const others = teams.filter(t => t.is_divisional_leader != 1);
      const resolved = [...resolveGroup(leaders), ...resolveGroup(others)];
      result.push(...resolved.map((t, i) => ({ ...t, resolved_rank: i + 1 })));
    }
    return result;
  }

  // ===== Resolved Seeds =====
  // Pass is16 explicitly so Svelte tracks the dependency on both playoff_seeds and is16
  $: resolvedSeeds = resolveTiebreakers(playoff_seeds, is16);

  // ===== Shared Helpers =====
  // Note: seed lookups below reference resolvedSeeds directly in the $: expression
  // so Svelte properly re-runs them when resolvedSeeds changes.

  function getLogo(name, seeds) {
    return (seeds || []).find(t => t.team_name === name)?.team_logo ?? '';
  }

  function findGame(a, b) {
    if (!a || !b) return null;
    return playoff_games.find(g =>
      (g.home === a && g.away === b) || (g.home === b && g.away === a)
    ) ?? null;
  }

  function seriesScore(game, name) {
    if (!game || game.winner === null) return null;
    return game.home === name ? game.home_wins : game.away_wins;
  }

  function roundGames(kw, conf, seeds) {
    return playoff_games.filter(g => {
      const r = g.round?.toLowerCase() ?? '';
      if (!r.includes(kw)) return false;
      if (!conf) return true;
      const hc = (seeds || []).find(t => t.team_name === g.home)?.conference;
      const ac = (seeds || []).find(t => t.team_name === g.away)?.conference;
      return hc === conf || ac === conf;
    });
  }

  const TBD = { topName:'TBD', topLogo:'', topScore:null, botName:'TBD', botLogo:'', botScore:null, winner:null };

  function bd(game, seeds) {
    return {
      topName: game.home,
      topLogo: getLogo(game.home, seeds),
      topScore: game.winner !== null ? game.home_wins : null,
      botName: game.away,
      botLogo: getLogo(game.away, seeds),
      botScore: game.winner !== null ? game.away_wins : null,
      winner: game.winner
    };
  }

  function qfCls(m, isBot) {
    const seed = isBot ? m.botSeed : m.topSeed;
    const w = m.game?.winner;
    if (!w) return seed ? '' : 'tbd';
    return w === seed?.team_name ? 'winner' : 'loser';
  }

  function slotCls(m, isBot) {
    const name = isBot ? m.botName : m.topName;
    const w = m.winner;
    if (!w) return name === 'TBD' ? 'tbd' : '';
    return w === name ? 'winner' : 'loser';
  }

  // ===== 32-Team Seeds & Matchups =====
  // _sd: look up a seed by conference, super_division keyword, and resolved rank.
  // Svelte reactive expressions ($:) reference `resolvedSeeds &&` before calling these
  // helpers so the compiler tracks the dependency correctly.
  function _sd(conf, kw, rank) { return (resolvedSeeds || []).find(t => t.conference === conf && t.super_division?.toLowerCase().includes(kw) && t.resolved_rank === rank); }
  $: oW1 = resolvedSeeds && _sd('Orange','west',1); $: oW2 = resolvedSeeds && _sd('Orange','west',2);
  $: oW3 = resolvedSeeds && _sd('Orange','west',3); $: oW4 = resolvedSeeds && _sd('Orange','west',4);
  $: oE1 = resolvedSeeds && _sd('Orange','east',1); $: oE2 = resolvedSeeds && _sd('Orange','east',2);
  $: oE3 = resolvedSeeds && _sd('Orange','east',3); $: oE4 = resolvedSeeds && _sd('Orange','east',4);
  $: bN1 = resolvedSeeds && _sd('Blue','north',1);  $: bN2 = resolvedSeeds && _sd('Blue','north',2);
  $: bN3 = resolvedSeeds && _sd('Blue','north',3);  $: bN4 = resolvedSeeds && _sd('Blue','north',4);
  $: bS1 = resolvedSeeds && _sd('Blue','south',1);  $: bS2 = resolvedSeeds && _sd('Blue','south',2);
  $: bS3 = resolvedSeeds && _sd('Blue','south',3);  $: bS4 = resolvedSeeds && _sd('Blue','south',4);

  // QF ordering matches official 32-team bracket:
  // Pair 1 (Games 1+2): W#1 vs E#4, E#2 vs W#3 -> SF
  // Pair 2 (Games 3+4): E#1 vs W#4, W#2 vs E#3 -> SF
  $: oQF = [
    { topSeed:oW1, botSeed:oE4, topLabel:'W#1', botLabel:'E#4', game:findGame(oW1?.team_name, oE4?.team_name) },
    { topSeed:oE2, botSeed:oW3, topLabel:'E#2', botLabel:'W#3', game:findGame(oE2?.team_name, oW3?.team_name) },
    { topSeed:oE1, botSeed:oW4, topLabel:'E#1', botLabel:'W#4', game:findGame(oE1?.team_name, oW4?.team_name) },
    { topSeed:oW2, botSeed:oE3, topLabel:'W#2', botLabel:'E#3', game:findGame(oW2?.team_name, oE3?.team_name) },
  ];
  $: bQF = [
    { topSeed:bN1, botSeed:bS4, topLabel:'N#1', botLabel:'S#4', game:findGame(bN1?.team_name, bS4?.team_name) },
    { topSeed:bS2, botSeed:bN3, topLabel:'S#2', botLabel:'N#3', game:findGame(bS2?.team_name, bN3?.team_name) },
    { topSeed:bS1, botSeed:bN4, topLabel:'S#1', botLabel:'N#4', game:findGame(bS1?.team_name, bN4?.team_name) },
    { topSeed:bN2, botSeed:bS3, topLabel:'N#2', botLabel:'S#3', game:findGame(bN2?.team_name, bS3?.team_name) },
  ];

  $: oSFRaw = roundGames('semi','Orange', resolvedSeeds).map(g => bd(g, resolvedSeeds));
  $: bSFRaw = roundGames('semi','Blue', resolvedSeeds).map(g => bd(g, resolvedSeeds));
  $: oSF = [oSFRaw[0] ?? TBD, oSFRaw[1] ?? TBD];
  $: bSF = [bSFRaw[0] ?? TBD, bSFRaw[1] ?? TBD];

  $: oCF = roundGames('final','Orange', resolvedSeeds).filter(g => {
    const r = g.round?.toLowerCase() ?? '';
    return !r.includes('grand') && !r.includes('championship');
  }).map(g => bd(g, resolvedSeeds))[0] ?? TBD;
  $: bCF = roundGames('final','Blue', resolvedSeeds).filter(g => {
    const r = g.round?.toLowerCase() ?? '';
    return !r.includes('grand') && !r.includes('championship');
  }).map(g => bd(g, resolvedSeeds))[0] ?? TBD;
  $: gf = playoff_games.filter(g => {
    const r = g.round?.toLowerCase() ?? '';
    return r.includes('grand') || r.includes('championship');
  }).map(g => bd(g, resolvedSeeds))[0] ?? TBD;

  // ===== 16-Team Seeds & Matchups =====
  // _cs: look up a seed by conference and resolved rank (no super_division for 16-team leagues).
  function _cs(conf, rank) { return (resolvedSeeds || []).find(t => t.conference === conf && t.resolved_rank === rank); }
  $: o1 = resolvedSeeds && _cs('Orange', 1); $: o2 = resolvedSeeds && _cs('Orange', 2);
  $: o3 = resolvedSeeds && _cs('Orange', 3); $: o4 = resolvedSeeds && _cs('Orange', 4);
  $: b1 = resolvedSeeds && _cs('Blue', 1);   $: b2 = resolvedSeeds && _cs('Blue', 2);
  $: b3 = resolvedSeeds && _cs('Blue', 3);   $: b4 = resolvedSeeds && _cs('Blue', 4);

  // SF matchups: Seed 4 @ Seed 1, Seed 3 @ Seed 2
  $: oSF16 = [
    { topSeed:o1, botSeed:o4, topLabel:'#1', botLabel:'#4', game:findGame(o1?.team_name, o4?.team_name) },
    { topSeed:o2, botSeed:o3, topLabel:'#2', botLabel:'#3', game:findGame(o2?.team_name, o3?.team_name) },
  ];
  $: bSF16 = [
    { topSeed:b1, botSeed:b4, topLabel:'#1', botLabel:'#4', game:findGame(b1?.team_name, b4?.team_name) },
    { topSeed:b2, botSeed:b3, topLabel:'#2', botLabel:'#3', game:findGame(b2?.team_name, b3?.team_name) },
  ];
</script>

<div class="bk-wrap">

{#if is16}
  <!-- ===== 16-Team Bracket: 3 columns ===== -->
  <div class="bk-headers">
    <div class="bk-h">CONF. SEMI-FINALS</div>
    <div class="bk-h">CONF. FINALS</div>
    <div class="bk-h">LEAGUE CHAMPIONSHIP</div>
  </div>

  <div class="bk-body">
    <div class="bk-conf-col">
      <div class="bk-conf bk-orange"><span class="bk-conf-lbl">ORANGE</span></div>
      <div class="bk-conf-rule"></div>
      <div class="bk-conf bk-blue"><span class="bk-conf-lbl">BLUE</span></div>
    </div>

    <!-- SF column (seed-based first round) -->
    <div class="bk-col">
      <div class="bk-pair">
        {#each oSF16 as m}
        <div class="bk-slot">
          <div class="pp-card">
            <div class="pp-row {qfCls(m,false)} pp-sep">
              {#if m.topSeed?.team_logo}<img src={m.topSeed.team_logo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.topSeed?.team_name ?? 'TBD'}</span>
              {#if m.topSeed?.record}<span class="pp-rec">{m.topSeed.record}</span>{/if}
              {#if seriesScore(m.game, m.topSeed?.team_name) !== null}<span class="pp-score">{seriesScore(m.game, m.topSeed?.team_name)}</span>{/if}
              <span class="pp-seed">{m.topLabel}</span>
            </div>
            <div class="pp-row {qfCls(m,true)}">
              {#if m.botSeed?.team_logo}<img src={m.botSeed.team_logo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.botSeed?.team_name ?? 'TBD'}</span>
              {#if m.botSeed?.record}<span class="pp-rec">{m.botSeed.record}</span>{/if}
              {#if seriesScore(m.game, m.botSeed?.team_name) !== null}<span class="pp-score">{seriesScore(m.game, m.botSeed?.team_name)}</span>{/if}
              <span class="pp-seed">{m.botLabel}</span>
            </div>
          </div>
        </div>
        {/each}
      </div>

      <div class="bk-col-rule"></div>

      <div class="bk-pair">
        {#each bSF16 as m}
        <div class="bk-slot">
          <div class="pp-card">
            <div class="pp-row {qfCls(m,false)} pp-sep">
              {#if m.topSeed?.team_logo}<img src={m.topSeed.team_logo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.topSeed?.team_name ?? 'TBD'}</span>
              {#if m.topSeed?.record}<span class="pp-rec">{m.topSeed.record}</span>{/if}
              {#if seriesScore(m.game, m.topSeed?.team_name) !== null}<span class="pp-score">{seriesScore(m.game, m.topSeed?.team_name)}</span>{/if}
              <span class="pp-seed">{m.topLabel}</span>
            </div>
            <div class="pp-row {qfCls(m,true)}">
              {#if m.botSeed?.team_logo}<img src={m.botSeed.team_logo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.botSeed?.team_name ?? 'TBD'}</span>
              {#if m.botSeed?.record}<span class="pp-rec">{m.botSeed.record}</span>{/if}
              {#if seriesScore(m.game, m.botSeed?.team_name) !== null}<span class="pp-score">{seriesScore(m.game, m.botSeed?.team_name)}</span>{/if}
              <span class="pp-seed">{m.botLabel}</span>
            </div>
          </div>
        </div>
        {/each}
      </div>
    </div>

    <!-- CF column -->
    <div class="bk-col bk-next">
      <div class="bk-pair">
        <div class="bk-slot">
          <div class="pp-card pp-orange">
            <div class="pp-row {slotCls(oCF,false)} pp-sep">
              {#if oCF.topLogo}<img src={oCF.topLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{oCF.topName}</span>
              {#if oCF.topScore !== null}<span class="pp-score">{oCF.topScore}</span>{/if}
            </div>
            <div class="pp-row {slotCls(oCF,true)}">
              {#if oCF.botLogo}<img src={oCF.botLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{oCF.botName}</span>
              {#if oCF.botScore !== null}<span class="pp-score">{oCF.botScore}</span>{/if}
            </div>
          </div>
        </div>
        <div class="bk-slot">
          <div class="pp-card pp-blue">
            <div class="pp-row {slotCls(bCF,false)} pp-sep">
              {#if bCF.topLogo}<img src={bCF.topLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{bCF.topName}</span>
              {#if bCF.topScore !== null}<span class="pp-score">{bCF.topScore}</span>{/if}
            </div>
            <div class="pp-row {slotCls(bCF,true)}">
              {#if bCF.botLogo}<img src={bCF.botLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{bCF.botName}</span>
              {#if bCF.botScore !== null}<span class="pp-score">{bCF.botScore}</span>{/if}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Championship column -->
    <div class="bk-col bk-gf">
      <div class="bk-slot">
        <div class="pp-card pp-gold">
          <div class="pp-row {slotCls(gf,false)} pp-sep">
            {#if gf.topLogo}<img src={gf.topLogo} alt="" class="pp-logo" />{/if}
            <span class="pp-name">{gf.topName}</span>
            {#if gf.topScore !== null}<span class="pp-score">{gf.topScore}</span>{/if}
            <span class="pp-tag pp-tag-orange">Orange</span>
          </div>
          <div class="pp-row {slotCls(gf,true)}">
            {#if gf.botLogo}<img src={gf.botLogo} alt="" class="pp-logo" />{/if}
            <span class="pp-name">{gf.botName}</span>
            {#if gf.botScore !== null}<span class="pp-score">{gf.botScore}</span>{/if}
            <span class="pp-tag pp-tag-blue">Blue</span>
          </div>
        </div>
      </div>
    </div>
  </div>

{:else}
  <!-- ===== 32-Team Bracket: 4 columns ===== -->
  <div class="bk-headers">
    <div class="bk-h">CONF. QUARTERFINALS</div>
    <div class="bk-h">CONF. SEMIFINALS</div>
    <div class="bk-h">CONF. FINALS</div>
    <div class="bk-h">GRAND FINAL</div>
  </div>

  <div class="bk-body">
    <div class="bk-conf-col">
      <div class="bk-conf bk-orange"><span class="bk-conf-lbl">ORANGE</span></div>
      <div class="bk-conf-rule"></div>
      <div class="bk-conf bk-blue"><span class="bk-conf-lbl">BLUE</span></div>
    </div>

    <!-- QF column -->
    <div class="bk-col">
      {#each [[oQF[0], oQF[1]], [oQF[2], oQF[3]]] as pair}
      <div class="bk-pair">
        {#each pair as m}
        <div class="bk-slot">
          <div class="pp-card">
            <div class="pp-row {qfCls(m,false)} pp-sep">
              {#if m.topSeed?.team_logo}<img src={m.topSeed.team_logo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.topSeed?.team_name ?? 'TBD'}</span>
              {#if m.topSeed?.record}<span class="pp-rec">{m.topSeed.record}</span>{/if}
              {#if seriesScore(m.game, m.topSeed?.team_name) !== null}<span class="pp-score">{seriesScore(m.game, m.topSeed?.team_name)}</span>{/if}
              <span class="pp-seed">{m.topLabel}</span>
            </div>
            <div class="pp-row {qfCls(m,true)}">
              {#if m.botSeed?.team_logo}<img src={m.botSeed.team_logo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.botSeed?.team_name ?? 'TBD'}</span>
              {#if m.botSeed?.record}<span class="pp-rec">{m.botSeed.record}</span>{/if}
              {#if seriesScore(m.game, m.botSeed?.team_name) !== null}<span class="pp-score">{seriesScore(m.game, m.botSeed?.team_name)}</span>{/if}
              <span class="pp-seed">{m.botLabel}</span>
            </div>
          </div>
        </div>
        {/each}
      </div>
      {/each}

      <div class="bk-col-rule"></div>

      {#each [[bQF[0], bQF[1]], [bQF[2], bQF[3]]] as pair}
      <div class="bk-pair">
        {#each pair as m}
        <div class="bk-slot">
          <div class="pp-card">
            <div class="pp-row {qfCls(m,false)} pp-sep">
              {#if m.topSeed?.team_logo}<img src={m.topSeed.team_logo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.topSeed?.team_name ?? 'TBD'}</span>
              {#if m.topSeed?.record}<span class="pp-rec">{m.topSeed.record}</span>{/if}
              {#if seriesScore(m.game, m.topSeed?.team_name) !== null}<span class="pp-score">{seriesScore(m.game, m.topSeed?.team_name)}</span>{/if}
              <span class="pp-seed">{m.topLabel}</span>
            </div>
            <div class="pp-row {qfCls(m,true)}">
              {#if m.botSeed?.team_logo}<img src={m.botSeed.team_logo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.botSeed?.team_name ?? 'TBD'}</span>
              {#if m.botSeed?.record}<span class="pp-rec">{m.botSeed.record}</span>{/if}
              {#if seriesScore(m.game, m.botSeed?.team_name) !== null}<span class="pp-score">{seriesScore(m.game, m.botSeed?.team_name)}</span>{/if}
              <span class="pp-seed">{m.botLabel}</span>
            </div>
          </div>
        </div>
        {/each}
      </div>
      {/each}
    </div>

    <!-- SF column -->
    <div class="bk-col bk-next">
      <div class="bk-pair">
        {#each oSF as m}
        <div class="bk-slot">
          <div class="pp-card">
            <div class="pp-row {slotCls(m,false)} pp-sep">
              {#if m.topLogo}<img src={m.topLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.topName}</span>
              {#if m.topScore !== null}<span class="pp-score">{m.topScore}</span>{/if}
            </div>
            <div class="pp-row {slotCls(m,true)}">
              {#if m.botLogo}<img src={m.botLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.botName}</span>
              {#if m.botScore !== null}<span class="pp-score">{m.botScore}</span>{/if}
            </div>
          </div>
        </div>
        {/each}
      </div>

      <div class="bk-col-rule"></div>

      <div class="bk-pair">
        {#each bSF as m}
        <div class="bk-slot">
          <div class="pp-card">
            <div class="pp-row {slotCls(m,false)} pp-sep">
              {#if m.topLogo}<img src={m.topLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.topName}</span>
              {#if m.topScore !== null}<span class="pp-score">{m.topScore}</span>{/if}
            </div>
            <div class="pp-row {slotCls(m,true)}">
              {#if m.botLogo}<img src={m.botLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.botName}</span>
              {#if m.botScore !== null}<span class="pp-score">{m.botScore}</span>{/if}
            </div>
          </div>
        </div>
        {/each}
      </div>
    </div>

    <!-- CF column -->
    <div class="bk-col bk-next">
      <div class="bk-pair">
        <div class="bk-slot">
          <div class="pp-card pp-orange">
            <div class="pp-row {slotCls(oCF,false)} pp-sep">
              {#if oCF.topLogo}<img src={oCF.topLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{oCF.topName}</span>
              {#if oCF.topScore !== null}<span class="pp-score">{oCF.topScore}</span>{/if}
            </div>
            <div class="pp-row {slotCls(oCF,true)}">
              {#if oCF.botLogo}<img src={oCF.botLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{oCF.botName}</span>
              {#if oCF.botScore !== null}<span class="pp-score">{oCF.botScore}</span>{/if}
            </div>
          </div>
        </div>
        <div class="bk-slot">
          <div class="pp-card pp-blue">
            <div class="pp-row {slotCls(bCF,false)} pp-sep">
              {#if bCF.topLogo}<img src={bCF.topLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{bCF.topName}</span>
              {#if bCF.topScore !== null}<span class="pp-score">{bCF.topScore}</span>{/if}
            </div>
            <div class="pp-row {slotCls(bCF,true)}">
              {#if bCF.botLogo}<img src={bCF.botLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{bCF.botName}</span>
              {#if bCF.botScore !== null}<span class="pp-score">{bCF.botScore}</span>{/if}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- GF column -->
    <div class="bk-col bk-gf">
      <div class="bk-slot">
        <div class="pp-card pp-gold">
          <div class="pp-row {slotCls(gf,false)} pp-sep">
            {#if gf.topLogo}<img src={gf.topLogo} alt="" class="pp-logo" />{/if}
            <span class="pp-name">{gf.topName}</span>
            {#if gf.topScore !== null}<span class="pp-score">{gf.topScore}</span>{/if}
            <span class="pp-tag pp-tag-orange">Orange</span>
          </div>
          <div class="pp-row {slotCls(gf,true)}">
            {#if gf.botLogo}<img src={gf.botLogo} alt="" class="pp-logo" />{/if}
            <span class="pp-name">{gf.botName}</span>
            {#if gf.botScore !== null}<span class="pp-score">{gf.botScore}</span>{/if}
            <span class="pp-tag pp-tag-blue">Blue</span>
          </div>
        </div>
      </div>
    </div>
  </div>
{/if}

</div>

<style>
  /* ===== Theme tokens =====
     Light mode defaults; dark mode overrides via Evidence's [data-theme='dark'] attribute.
     Uses Evidence's --grey-* CSS custom properties for consistency with the app theme. */
  .bk-wrap {
    --bk-border: var(--grey-200);
    --bk-arm: var(--grey-300);
    --bk-card-bg: var(--grey-50);
    --bk-card-border: var(--grey-200);
    --bk-sep: var(--grey-200);
    --bk-header: var(--grey-500);
    --bk-muted: var(--grey-400);
    --bk-seed: var(--grey-400);
    --bk-tbd: var(--grey-400);
    --bk-winner-bg: rgba(74,222,128,0.12);
    overflow-x: auto;
    padding-bottom: 1.5rem;
  }
  :global([data-theme='dark']) .bk-wrap {
    --bk-border: var(--grey-800);
    --bk-arm: var(--grey-700);
    --bk-card-bg: var(--grey-900);
    --bk-card-border: var(--grey-800);
    --bk-sep: var(--grey-800);
    --bk-header: var(--grey-500);
    --bk-muted: var(--grey-500);
    --bk-seed: var(--grey-600);
    --bk-tbd: var(--grey-600);
    --bk-winner-bg: rgba(74,222,128,0.1);
  }

  .bk-headers {
    display: flex;
    margin-left: 40px;
    margin-bottom: 6px;
  }
  .bk-h {
    flex: 1;
    min-width: 200px;
    text-align: center;
    font-size: 0.62rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 2px;
    color: var(--bk-header);
  }

  .bk-body {
    display: flex;
    min-height: 680px;
  }

  /* Conference label column */
  .bk-conf-col {
    width: 40px;
    flex-shrink: 0;
    display: flex;
    flex-direction: column;
  }
  .bk-conf {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .bk-orange { color: #fb923c; border-right: 2px solid rgba(249,115,22,0.3); }
  .bk-blue   { color: #60a5fa; border-right: 2px solid rgba(96,165,250,0.3); }
  .bk-conf-lbl {
    writing-mode: vertical-rl;
    transform: rotate(180deg);
    font-size: 0.6rem;
    font-weight: 700;
    letter-spacing: 3px;
    text-transform: uppercase;
  }
  .bk-conf-rule {
    height: 2px;
    background: var(--bk-border);
    flex-shrink: 0;
  }

  /* Bracket columns */
  .bk-col {
    flex: 1;
    min-width: 210px;
    display: flex;
    flex-direction: column;
  }

  /* Divider between orange/blue within a column */
  .bk-col-rule {
    height: 2px;
    background: var(--bk-border);
    flex-shrink: 0;
    margin: 0 8px;
  }

  /* Pair: groups 2 slots and draws the right bracket arm */
  .bk-pair {
    flex: 1;
    display: flex;
    flex-direction: column;
    position: relative;
    padding-right: 24px;
  }
  .bk-pair::after {
    content: '';
    position: absolute;
    right: 0;
    top: 25%;
    height: 50%;
    width: 24px;
    border-top: 2px solid var(--bk-arm);
    border-right: 2px solid var(--bk-arm);
    border-bottom: 2px solid var(--bk-arm);
    border-radius: 0 4px 4px 0;
    box-sizing: border-box;
  }

  /* Slot: holds one matchup card */
  .bk-slot {
    flex: 1;
    display: flex;
    align-items: center;
    padding: 4px 0;
  }

  /* Left incoming connector for SF + CF + GF */
  .bk-next .bk-slot,
  .bk-gf .bk-slot {
    padding-left: 24px;
    position: relative;
  }
  .bk-next .bk-slot::before,
  .bk-gf .bk-slot::before {
    content: '';
    position: absolute;
    left: 0;
    top: 50%;
    width: 24px;
    height: 2px;
    background: var(--bk-arm);
    transform: translateY(-50%);
  }

  /* GF column: no pair/arm, just the slot */
  .bk-gf { justify-content: center; }

  /* Matchup card */
  .pp-card {
    border-radius: 6px;
    overflow: hidden;
    border: 1px solid var(--bk-card-border);
    background: var(--bk-card-bg);
    width: 100%;
  }
  .pp-orange { border-color: rgba(249,115,22,0.4); }
  .pp-blue   { border-color: rgba(96,165,250,0.4); }
  .pp-gold   { border-color: rgba(251,191,36,0.5); }

  .pp-row {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 6px 9px;
    font-size: 0.8rem;
    min-height: 34px;
  }
  .pp-sep { border-bottom: 1px solid var(--bk-sep); }
  .pp-row.winner { background: var(--bk-winner-bg); }
  .pp-row.loser  { opacity: 0.38; }
  .pp-row.tbd    { color: var(--bk-tbd); font-style: italic; }

  .pp-logo { width: 20px; height: 20px; object-fit: contain; flex-shrink: 0; }
  .pp-name { flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .pp-rec  { font-size: 0.68rem; color: var(--bk-muted); white-space: nowrap; }
  .pp-score { font-weight: 700; font-size: 0.9rem; min-width: 16px; text-align: center; }
  .pp-seed  { font-size: 0.65rem; color: var(--bk-seed); white-space: nowrap; }
  .pp-tag   { font-size: 0.65rem; white-space: nowrap; }
  .pp-tag-orange { color: #fb923c; }
  .pp-tag-blue   { color: #60a5fa; }
</style>
