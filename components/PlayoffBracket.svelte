<script>
  export let playoff_seeds = [];
  export let playoff_games = [];

  function getSeed(conf, kw, rank) {
    return playoff_seeds.find(t =>
      t.conference === conf &&
      t.super_division?.toLowerCase().includes(kw) &&
      t.super_division_rank === rank
    );
  }

  function getLogo(name) {
    return playoff_seeds.find(t => t.team_name === name)?.team_logo ?? '';
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

  function roundGames(kw, conf) {
    return playoff_games.filter(g => {
      const r = g.round?.toLowerCase() ?? '';
      if (!r.includes(kw)) return false;
      if (!conf) return true;
      const hc = playoff_seeds.find(t => t.team_name === g.home)?.conference;
      const ac = playoff_seeds.find(t => t.team_name === g.away)?.conference;
      return hc === conf || ac === conf;
    });
  }

  const TBD = { topName:'TBD', topLogo:'', topScore:null, botName:'TBD', botLogo:'', botScore:null, winner:null };

  function bd(game) {
    return {
      topName: game.home,
      topLogo: getLogo(game.home),
      topScore: game.winner !== null ? game.home_wins : null,
      botName: game.away,
      botLogo: getLogo(game.away),
      botScore: game.winner !== null ? game.away_wins : null,
      winner: game.winner
    };
  }

  $: oW1 = getSeed('Orange','west',1); $: oW2 = getSeed('Orange','west',2);
  $: oW3 = getSeed('Orange','west',3); $: oW4 = getSeed('Orange','west',4);
  $: oE1 = getSeed('Orange','east',1); $: oE2 = getSeed('Orange','east',2);
  $: oE3 = getSeed('Orange','east',3); $: oE4 = getSeed('Orange','east',4);
  $: bN1 = getSeed('Blue','north',1);  $: bN2 = getSeed('Blue','north',2);
  $: bN3 = getSeed('Blue','north',3);  $: bN4 = getSeed('Blue','north',4);
  $: bS1 = getSeed('Blue','south',1);  $: bS2 = getSeed('Blue','south',2);
  $: bS3 = getSeed('Blue','south',3);  $: bS4 = getSeed('Blue','south',4);

  $: oQF = [
    { topSeed:oW1, botSeed:oE4, topLabel:'W#1', botLabel:'E#4', game:findGame(oW1?.team_name, oE4?.team_name) },
    { topSeed:oW2, botSeed:oE3, topLabel:'W#2', botLabel:'E#3', game:findGame(oW2?.team_name, oE3?.team_name) },
    { topSeed:oW3, botSeed:oE2, topLabel:'W#3', botLabel:'E#2', game:findGame(oW3?.team_name, oE2?.team_name) },
    { topSeed:oW4, botSeed:oE1, topLabel:'W#4', botLabel:'E#1', game:findGame(oW4?.team_name, oE1?.team_name) },
  ];
  $: bQF = [
    { topSeed:bN1, botSeed:bS4, topLabel:'N#1', botLabel:'S#4', game:findGame(bN1?.team_name, bS4?.team_name) },
    { topSeed:bN2, botSeed:bS3, topLabel:'N#2', botLabel:'S#3', game:findGame(bN2?.team_name, bS3?.team_name) },
    { topSeed:bN3, botSeed:bS2, topLabel:'N#3', botLabel:'S#2', game:findGame(bN3?.team_name, bS2?.team_name) },
    { topSeed:bN4, botSeed:bS1, topLabel:'N#4', botLabel:'S#1', game:findGame(bN4?.team_name, bS1?.team_name) },
  ];

  $: oSFRaw = roundGames('semi','Orange').map(bd);
  $: bSFRaw = roundGames('semi','Blue').map(bd);
  $: oSF = [oSFRaw[0] ?? TBD, oSFRaw[1] ?? TBD];
  $: bSF = [bSFRaw[0] ?? TBD, bSFRaw[1] ?? TBD];

  $: oCF = roundGames('final','Orange').filter(g => !g.round?.toLowerCase().includes('grand')).map(bd)[0] ?? TBD;
  $: bCF = roundGames('final','Blue').filter(g => !g.round?.toLowerCase().includes('grand')).map(bd)[0] ?? TBD;
  $: gf  = playoff_games.filter(g => g.round?.toLowerCase().includes('grand')).map(bd)[0] ?? TBD;

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
</script>

<div class="bk-wrap">

  <!-- Column headers -->
  <div class="bk-headers">
    <div class="bk-h">CONF. QUARTERFINALS</div>
    <div class="bk-h">CONF. SEMIFINALS</div>
    <div class="bk-h">CONF. FINALS</div>
    <div class="bk-h">GRAND FINAL</div>
  </div>

  <!-- Main bracket -->
  <div class="bk-body">

    <!-- Conference labels -->
    <div class="bk-conf-col">
      <div class="bk-conf bk-orange">
        <span class="bk-conf-lbl">ORANGE</span>
      </div>
      <div class="bk-conf-rule"></div>
      <div class="bk-conf bk-blue">
        <span class="bk-conf-lbl">BLUE</span>
      </div>
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

    <!-- CF column — both in one pair so the arm spans to GF -->
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
</div>

<style>
  .bk-wrap { overflow-x: auto; padding-bottom: 1.5rem; }

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
    color: #6b7280;
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
    background: #1f2937;
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
    background: #1f2937;
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
    border-top: 2px solid #374151;
    border-right: 2px solid #374151;
    border-bottom: 2px solid #374151;
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
    background: #374151;
    transform: translateY(-50%);
  }

  /* GF column: no pair/arm, just the slot */
  .bk-gf { justify-content: center; }

  /* Matchup card */
  .pp-card {
    border-radius: 6px;
    overflow: hidden;
    border: 1px solid #1f2937;
    background: #111827;
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
  .pp-sep { border-bottom: 1px solid #1f2937; }
  .pp-row.winner { background: rgba(74,222,128,0.1); }
  .pp-row.loser  { opacity: 0.38; }
  .pp-row.tbd    { color: #4b5563; font-style: italic; }

  .pp-logo { width: 20px; height: 20px; object-fit: contain; flex-shrink: 0; }
  .pp-name { flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .pp-rec  { font-size: 0.68rem; color: #6b7280; white-space: nowrap; }
  .pp-score { font-weight: 700; font-size: 0.9rem; min-width: 16px; text-align: center; }
  .pp-seed  { font-size: 0.65rem; color: #4b5563; white-space: nowrap; }
  .pp-tag   { font-size: 0.65rem; white-space: nowrap; }
  .pp-tag-orange { color: #fb923c; }
  .pp-tag-blue   { color: #60a5fa; }
</style>
