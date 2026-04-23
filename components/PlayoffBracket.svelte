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
  export let team_logos = [];
  export let league = '';

  // 16-team leagues use conference-based seeding; 32-team leagues use super_division-based seeding
  $: is16 = league === 'Foundation League' || league === 'Premier League';

  // ===== Tiebreaker Engine (MLE Rules 1.9.1–1.9.6) =====
  // Order: Win% → H2H → Series% → Division% (same div only) → Goal Diff → Goals For
  // Division leaders are guaranteed seeds 1–2; wildcards get seeds 3–4.
  // Within each group, teams are sorted by win% first, then tiebreakers resolve only
  // among teams with identical win%.
  //
  // h2h_records and division_records are passed explicitly into resolveTiebreakers so
  // Svelte's static reactive-dep tracking re-runs the computation when those arrays
  // arrive asynchronously — reading them via closure would miss the initial arrival
  // and silently drop the H2H/division% steps. (Same pattern as roundGames below.)

  function resolveTiebreakers(seeds, is16Team, h2h, divRecords) {
    if (!seeds || seeds.length === 0) return [];

    // Returns teamA's game win percentage against teamB (0–1), or null if they never played.
    function getH2HWinPct(teamA, teamB) {
      let aWins = 0, bWins = 0;
      const direct = (h2h || []).find(r => r.team_a === teamA && r.team_b === teamB);
      if (direct) { aWins += direct.a_game_wins; bWins += direct.b_game_wins; }
      const reverse = (h2h || []).find(r => r.team_a === teamB && r.team_b === teamA);
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
      return (divRecords || []).find(r => r.team_name === teamName)?.div_win_pct ?? 0;
    }

    // Recursive tiebreaker resolution per rules 1.9.1-1.9.6.
    // On any elimination the procedure restarts from the top (via recursion).
    function resolveCluster(tiedTeams) {
      if (tiedTeams.length <= 1) return tiedTeams;

      // Rule 1.9 cross-division clause: "If multiple teams from the same division
      // are involved in a tie ... with the other division, the highest ranked team
      // from each division in the tie will be compared first. The team that loses
      // the tie will then compare against the next highest team in the tie from
      // the other division."
      // Trigger: tied cluster spans 2+ divisions AND at least one division contains
      // 2+ tied teams. Procedure: rank each division's tied teams internally, then
      // iteratively pair the current top-of-each-division, seed the winner, and let
      // the loser face the next candidate from the opposite division.
      const divGroups = {};
      for (const t of tiedTeams) {
        const d = t.division ?? '_unknown';
        if (!divGroups[d]) divGroups[d] = [];
        divGroups[d].push(t);
      }
      const divNames = Object.keys(divGroups);
      if (divNames.length > 1 && divNames.some(d => divGroups[d].length > 1)) {
        const queues = {};
        for (const d of divNames) queues[d] = resolveCluster(divGroups[d]);
        const out = [];
        while (true) {
          const active = divNames.filter(d => queues[d].length > 0);
          if (active.length === 0) break;
          if (active.length === 1) { out.push(...queues[active[0]]); break; }
          const candidates = active.map(d => queues[d][0]);
          const ranked = resolveCluster(candidates);
          const winner = ranked[0];
          out.push(winner);
          queues[winner.division ?? '_unknown'].shift();
        }
        return out;
      }

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

    function resolveGroup(teams) {
      if (teams.length <= 1) return teams;
      const byWinPct = groupByValue(teams, 'win_pct');
      return byWinPct.flatMap(g => g.length === 1 ? g : resolveCluster(g));
    }

    // Partition seeds by conference or super_division. Within each partition, the
    // rules require division standings to be decided FIRST: run the full tiebreaker
    // procedure inside each division to pick its winner (guaranteed a top seed),
    // then rank the division winners among themselves and the non-winners among
    // themselves using the same procedure. The SQL `is_divisional_leader` flag is
    // ignored here because it comes from an external standings table that doesn't
    // apply the H2H step — e.g. when two teams in one division tie on wins, SQL
    // may crown the wrong team as leader.
    const partKey = is16Team ? 'conference' : 'super_division';
    const groups = {};
    for (const t of seeds) {
      const k = t[partKey] ?? 'unknown';
      if (!groups[k]) groups[k] = [];
      groups[k].push(t);
    }

    const result = [];
    for (const teams of Object.values(groups)) {
      const divisions = {};
      for (const t of teams) {
        const d = t.division ?? 'unknown';
        if (!divisions[d]) divisions[d] = [];
        divisions[d].push(t);
      }
      const leaders = [];
      const nonLeaders = [];
      for (const divTeams of Object.values(divisions)) {
        const ranked = resolveGroup(divTeams);
        leaders.push(ranked[0]);
        nonLeaders.push(...ranked.slice(1));
      }
      const resolved = [...resolveGroup(leaders), ...resolveGroup(nonLeaders)];
      result.push(...resolved.map((t, i) => ({ ...t, resolved_rank: i + 1 })));
    }
    return result;
  }

  // ===== Resolved Seeds =====
  // h2h_records and division_records are passed explicitly so Svelte re-runs this
  // when either arrives after playoff_seeds (see comment on resolveTiebreakers).
  $: resolvedSeeds = resolveTiebreakers(playoff_seeds, is16, h2h_records, division_records);

  // ===== Shared Helpers =====
  // Note: seed lookups below reference resolvedSeeds directly in the $: expression
  // so Svelte properly re-runs them when resolvedSeeds changes.

  // Logo lookup: seeds first (has per-mode record), then the full team_logos
  // list so teams outside the top 4 still render a logo.
  function getLogo(name, seeds, logos) {
    const fromSeeds = (seeds || []).find(t => t.team_name === name)?.team_logo;
    if (fromSeeds) return fromSeeds;
    return (logos || []).find(t => t.team_name === name)?.team_logo ?? '';
  }

  // Takes `games` explicitly (rather than reading the prop via closure) so Svelte's
  // static reactive-dep tracking sees `playoff_games` in every $: callsite —
  // otherwise these reactives miss the initial async arrival of playoff_games.
  function roundGames(games, kw, conf, seeds) {
    return (games || []).filter(g => {
      const r = g.round?.toLowerCase() ?? '';
      if (!r.includes(kw)) return false;
      if (!conf) return true;
      const hc = (seeds || []).find(t => t.team_name === g.home)?.conference;
      const ac = (seeds || []).find(t => t.team_name === g.away)?.conference;
      return hc === conf || ac === conf;
    });
  }

  const TBD = { topName:'TBD', topLogo:'', topScore:null, botName:'TBD', botLogo:'', botScore:null, winner:null };

  function bd(game, seeds, logos) {
    return {
      topName: game.home,
      topLogo: getLogo(game.home, seeds, logos),
      topScore: game.winner !== null ? game.home_wins : null,
      botName: game.away,
      botLogo: getLogo(game.away, seeds, logos),
      botScore: game.winner !== null ? game.away_wins : null,
      winner: game.winner
    };
  }

  function slotCls(m, isBot) {
    const name = isBot ? m.botName : m.topName;
    const w = m.winner;
    if (!w) return name === 'TBD' ? 'tbd' : '';
    return w === name ? 'winner' : 'loser';
  }

  // ===== First-round match override =====
  // For each seeded pair (e.g., W#1 vs E#4), check first-round playoff_games:
  //   1. exact seeded pair played -> use that game as-is
  //   2. one seeded team played someone else -> replace the other slot with the
  //      actual opponent (handles cases where tiebreaker logic picked a wildcard
  //      that League Ops' bracket doesn't agree with)
  //   3. no game found -> fall back to pure seed projection
  $: firstRoundKw = is16 ? 'semi' : 'quarter';
  $: firstRoundGames = playoff_games.filter(g =>
    (g.round?.toLowerCase() ?? '').includes(firstRoundKw)
  );

  function findFirstRoundMatch(topSeed, botSeed, rGames) {
    const gs = rGames || [];
    if (topSeed && botSeed) {
      const exact = gs.find(g =>
        (g.home === topSeed.team_name && g.away === botSeed.team_name) ||
        (g.home === botSeed.team_name && g.away === topSeed.team_name)
      );
      if (exact) return { game: exact, actualTop: topSeed.team_name, actualBot: botSeed.team_name };
    }
    if (topSeed) {
      const g = gs.find(x => x.home === topSeed.team_name || x.away === topSeed.team_name);
      if (g) {
        const other = g.home === topSeed.team_name ? g.away : g.home;
        return { game: g, actualTop: topSeed.team_name, actualBot: other };
      }
    }
    if (botSeed) {
      const g = gs.find(x => x.home === botSeed.team_name || x.away === botSeed.team_name);
      if (g) {
        const other = g.home === botSeed.team_name ? g.away : g.home;
        return { game: g, actualTop: other, actualBot: botSeed.team_name };
      }
    }
    return null;
  }

  function buildFirstRoundSlot(topSeed, botSeed, topLabel, botLabel, rGames, seeds, logos) {
    const match = findFirstRoundMatch(topSeed, botSeed, rGames);
    if (!match) {
      return {
        topName: topSeed?.team_name ?? 'TBD',
        topLogo: topSeed?.team_logo ?? '',
        topRec:  topSeed?.record ?? '',
        topSeedLabel: topSeed ? topLabel : '',
        topScore: null,
        topCls: topSeed ? '' : 'tbd',
        botName: botSeed?.team_name ?? 'TBD',
        botLogo: botSeed?.team_logo ?? '',
        botRec:  botSeed?.record ?? '',
        botSeedLabel: botSeed ? botLabel : '',
        botScore: null,
        botCls: botSeed ? '' : 'tbd',
      };
    }
    const { game, actualTop, actualBot } = match;
    const hasWinner = game.winner !== null && game.winner !== undefined;
    function info(actualName, seedTeam, seedLabel) {
      const isSeedMatch = seedTeam?.team_name === actualName;
      return {
        name: actualName,
        logo: getLogo(actualName, seeds, logos),
        rec: hasWinner ? '' : (isSeedMatch ? (seedTeam.record ?? '') : ''),
        seedLabel: hasWinner ? '' : (isSeedMatch ? seedLabel : ''),
        score: hasWinner ? (game.home === actualName ? game.home_wins : game.away_wins) : null,
        cls: hasWinner ? (game.winner === actualName ? 'winner' : 'loser') : '',
      };
    }
    const top = info(actualTop, topSeed, topLabel);
    const bot = info(actualBot, botSeed, botLabel);
    return {
      topName: top.name, topLogo: top.logo, topRec: top.rec,
      topSeedLabel: top.seedLabel, topScore: top.score, topCls: top.cls,
      botName: bot.name, botLogo: bot.logo, botRec: bot.rec,
      botSeedLabel: bot.seedLabel, botScore: bot.score, botCls: bot.cls,
    };
  }

  // ===== SF pair ordering (32-team) =====
  // Each SF slot is fed by a specific QF pair. Classify by checking whether
  // either team's (super_division, resolved_rank) lands in pair 1 or pair 2's set.
  // Division leaders (seeds 1-2) are the stable anchors; wildcards rarely reach SF
  // without a leader also present, so one lookup usually suffices.
  function classifySFTeam(seed) {
    if (!seed?.super_division || !seed.resolved_rank) return null;
    const sd = seed.super_division.toLowerCase();
    const r = seed.resolved_rank;
    if (seed.conference === 'Orange') {
      const w = sd.includes('west'), e = sd.includes('east');
      if ((w && r === 1) || (e && r === 4) || (e && r === 2) || (w && r === 3)) return 'top';
      if ((e && r === 1) || (w && r === 4) || (w && r === 2) || (e && r === 3)) return 'bot';
    } else if (seed.conference === 'Blue') {
      const n = sd.includes('north'), s = sd.includes('south');
      if ((n && r === 1) || (s && r === 4) || (s && r === 2) || (n && r === 3)) return 'top';
      if ((s && r === 1) || (n && r === 4) || (n && r === 2) || (s && r === 3)) return 'bot';
    }
    return null;
  }

  function orderSFGames(games, seeds) {
    const out = [null, null];
    const pending = [];
    for (const g of games) {
      let cls = null;
      for (const name of [g.home, g.away]) {
        const s = (seeds || []).find(t => t.team_name === name);
        if (s) { const c = classifySFTeam(s); if (c) { cls = c; break; } }
      }
      if (cls === 'top' && !out[0]) out[0] = g;
      else if (cls === 'bot' && !out[1]) out[1] = g;
      else pending.push(g);
    }
    for (const g of pending) {
      const i = out.indexOf(null);
      if (i >= 0) out[i] = g;
    }
    return out;
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
  // Pair 1 (Games 1+2): W#1 vs E#4, E#2 vs W#3 -> SF top
  // Pair 2 (Games 3+4): E#1 vs W#4, W#2 vs E#3 -> SF bottom
  $: oQF = [
    buildFirstRoundSlot(oW1, oE4, 'W#1', 'E#4', firstRoundGames, resolvedSeeds, team_logos),
    buildFirstRoundSlot(oE2, oW3, 'E#2', 'W#3', firstRoundGames, resolvedSeeds, team_logos),
    buildFirstRoundSlot(oE1, oW4, 'E#1', 'W#4', firstRoundGames, resolvedSeeds, team_logos),
    buildFirstRoundSlot(oW2, oE3, 'W#2', 'E#3', firstRoundGames, resolvedSeeds, team_logos),
  ];
  $: bQF = [
    buildFirstRoundSlot(bN1, bS4, 'N#1', 'S#4', firstRoundGames, resolvedSeeds, team_logos),
    buildFirstRoundSlot(bS2, bN3, 'S#2', 'N#3', firstRoundGames, resolvedSeeds, team_logos),
    buildFirstRoundSlot(bS1, bN4, 'S#1', 'N#4', firstRoundGames, resolvedSeeds, team_logos),
    buildFirstRoundSlot(bN2, bS3, 'N#2', 'S#3', firstRoundGames, resolvedSeeds, team_logos),
  ];

  $: oSF = orderSFGames(roundGames(playoff_games, 'semi','Orange', resolvedSeeds), resolvedSeeds).map(g => g ? bd(g, resolvedSeeds, team_logos) : TBD);
  $: bSF = orderSFGames(roundGames(playoff_games, 'semi','Blue',  resolvedSeeds), resolvedSeeds).map(g => g ? bd(g, resolvedSeeds, team_logos) : TBD);

  // CF round filter: "Conference Finals" only — exclude rounds whose names also
  // contain 'final' ("semifinals", "quarterfinals", "grand finals").
  $: oCF = roundGames(playoff_games, 'final','Orange', resolvedSeeds).filter(g => {
    const r = g.round?.toLowerCase() ?? '';
    return !r.includes('grand') && !r.includes('championship')
        && !r.includes('semi') && !r.includes('quarter');
  }).map(g => bd(g, resolvedSeeds, team_logos))[0] ?? TBD;
  $: bCF = roundGames(playoff_games, 'final','Blue', resolvedSeeds).filter(g => {
    const r = g.round?.toLowerCase() ?? '';
    return !r.includes('grand') && !r.includes('championship')
        && !r.includes('semi') && !r.includes('quarter');
  }).map(g => bd(g, resolvedSeeds, team_logos))[0] ?? TBD;

  // Grand Final: place the Orange-conference team on top, Blue on bottom,
  // regardless of which side of the game.home/game.away split they fall on.
  function buildGF(game, seeds, logos) {
    if (!game) return TBD;
    const homeConf = (seeds || []).find(t => t.team_name === game.home)?.conference;
    const awayConf = (seeds || []).find(t => t.team_name === game.away)?.conference;
    const homeIsOrange = homeConf === 'Orange' || awayConf === 'Blue';
    const orangeName  = homeIsOrange ? game.home : game.away;
    const orangeScore = homeIsOrange ? game.home_wins : game.away_wins;
    const blueName    = homeIsOrange ? game.away : game.home;
    const blueScore   = homeIsOrange ? game.away_wins : game.home_wins;
    return {
      topName: orangeName,
      topLogo: getLogo(orangeName, seeds, logos),
      topScore: game.winner !== null ? orangeScore : null,
      botName: blueName,
      botLogo: getLogo(blueName, seeds, logos),
      botScore: game.winner !== null ? blueScore : null,
      winner: game.winner
    };
  }
  $: gf = buildGF(
    playoff_games.find(g => {
      const r = g.round?.toLowerCase() ?? '';
      return r.includes('grand') || r.includes('championship');
    }),
    resolvedSeeds, team_logos
  );

  // ===== 16-Team Seeds & Matchups =====
  // _cs: look up a seed by conference and resolved rank (no super_division for 16-team leagues).
  function _cs(conf, rank) { return (resolvedSeeds || []).find(t => t.conference === conf && t.resolved_rank === rank); }
  $: o1 = resolvedSeeds && _cs('Orange', 1); $: o2 = resolvedSeeds && _cs('Orange', 2);
  $: o3 = resolvedSeeds && _cs('Orange', 3); $: o4 = resolvedSeeds && _cs('Orange', 4);
  $: b1 = resolvedSeeds && _cs('Blue', 1);   $: b2 = resolvedSeeds && _cs('Blue', 2);
  $: b3 = resolvedSeeds && _cs('Blue', 3);   $: b4 = resolvedSeeds && _cs('Blue', 4);

  // SF matchups: Seed 4 @ Seed 1, Seed 3 @ Seed 2
  $: oSF16 = [
    buildFirstRoundSlot(o1, o4, '#1', '#4', firstRoundGames, resolvedSeeds, team_logos),
    buildFirstRoundSlot(o2, o3, '#2', '#3', firstRoundGames, resolvedSeeds, team_logos),
  ];
  $: bSF16 = [
    buildFirstRoundSlot(b1, b4, '#1', '#4', firstRoundGames, resolvedSeeds, team_logos),
    buildFirstRoundSlot(b2, b3, '#2', '#3', firstRoundGames, resolvedSeeds, team_logos),
  ];
</script>

<div class="bk-wrap">

{#if is16}
  <!-- ===== 16-Team Bracket: 3 columns ===== -->
  <div class="bk-headers">
    <div class="bk-h">CONF. SEMI-FINALS</div>
    <div class="bk-h">CONF. FINALS</div>
    <div class="bk-h">GRAND FINAL</div>
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
            <div class="pp-row {m.topCls} pp-sep">
              {#if m.topLogo}<img src={m.topLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.topName}</span>
              {#if m.topRec}<span class="pp-rec">{m.topRec}</span>{/if}
              {#if m.topScore !== null}<span class="pp-score">{m.topScore}</span>{/if}
              {#if m.topSeedLabel}<span class="pp-seed">{m.topSeedLabel}</span>{/if}
            </div>
            <div class="pp-row {m.botCls}">
              {#if m.botLogo}<img src={m.botLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.botName}</span>
              {#if m.botRec}<span class="pp-rec">{m.botRec}</span>{/if}
              {#if m.botScore !== null}<span class="pp-score">{m.botScore}</span>{/if}
              {#if m.botSeedLabel}<span class="pp-seed">{m.botSeedLabel}</span>{/if}
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
            <div class="pp-row {m.topCls} pp-sep">
              {#if m.topLogo}<img src={m.topLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.topName}</span>
              {#if m.topRec}<span class="pp-rec">{m.topRec}</span>{/if}
              {#if m.topScore !== null}<span class="pp-score">{m.topScore}</span>{/if}
              {#if m.topSeedLabel}<span class="pp-seed">{m.topSeedLabel}</span>{/if}
            </div>
            <div class="pp-row {m.botCls}">
              {#if m.botLogo}<img src={m.botLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.botName}</span>
              {#if m.botRec}<span class="pp-rec">{m.botRec}</span>{/if}
              {#if m.botScore !== null}<span class="pp-score">{m.botScore}</span>{/if}
              {#if m.botSeedLabel}<span class="pp-seed">{m.botSeedLabel}</span>{/if}
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
            <div class="pp-row {m.topCls} pp-sep">
              {#if m.topLogo}<img src={m.topLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.topName}</span>
              {#if m.topRec}<span class="pp-rec">{m.topRec}</span>{/if}
              {#if m.topScore !== null}<span class="pp-score">{m.topScore}</span>{/if}
              {#if m.topSeedLabel}<span class="pp-seed">{m.topSeedLabel}</span>{/if}
            </div>
            <div class="pp-row {m.botCls}">
              {#if m.botLogo}<img src={m.botLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.botName}</span>
              {#if m.botRec}<span class="pp-rec">{m.botRec}</span>{/if}
              {#if m.botScore !== null}<span class="pp-score">{m.botScore}</span>{/if}
              {#if m.botSeedLabel}<span class="pp-seed">{m.botSeedLabel}</span>{/if}
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
            <div class="pp-row {m.topCls} pp-sep">
              {#if m.topLogo}<img src={m.topLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.topName}</span>
              {#if m.topRec}<span class="pp-rec">{m.topRec}</span>{/if}
              {#if m.topScore !== null}<span class="pp-score">{m.topScore}</span>{/if}
              {#if m.topSeedLabel}<span class="pp-seed">{m.topSeedLabel}</span>{/if}
            </div>
            <div class="pp-row {m.botCls}">
              {#if m.botLogo}<img src={m.botLogo} alt="" class="pp-logo" />{/if}
              <span class="pp-name">{m.botName}</span>
              {#if m.botRec}<span class="pp-rec">{m.botRec}</span>{/if}
              {#if m.botScore !== null}<span class="pp-score">{m.botScore}</span>{/if}
              {#if m.botSeedLabel}<span class="pp-seed">{m.botSeedLabel}</span>{/if}
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
