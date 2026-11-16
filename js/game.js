// 僵尸农场 · 植物僵尸大乱斗 - 完整多界面 Web 还原版

(() => {
  const GRID_LEFT = 176;
  const GRID_TOP = 64;
  const CELL_W = 64;
  const CELL_H = 73;
  const ROWS = 5;
  const COLS = 7;
  const SPAWN_X = 702;
  const GOAL_X = 146;

  // 默认可用基础植物与僵尸家族（对应1星基础ID，升星后自动替换成高星ID）
  const PLANT_FAMILIES = [
    "10010", "11010", "12010", "13010", "14010",
    "10020", "11020", "12020", "13020", "14020",
    "20010", "21010", "22010", "23010", "24010",
    "20020", "21020", "22020", "23020", "24020",
    "20030", "21030", "22030", "23030", "24030",
    "20040", "21040", "22040", "23040", "24040",
    "20050", "21050", "22050", "23050", "24050",
    "20060", "21060", "22060", "23060", "24060",
  ];

  const MONSTER_FAMILIES = [
    "30080", "31080", "32080", "33080", "34080",
    "30010", "31010", "32010", "33010", "34010",
    "30020", "31020", "32020", "33020", "34020",
    "30030", "31030", "32030", "33030", "34030",
    "30040", "31040", "32040", "33040", "34040",
    "30050", "31050", "32050", "33050", "34050",
    "30070", "31070", "32070", "33070", "34070",
  ];

  const DEFAULT_OWNED_PLANTS = ["10010", "20010", "22010", "21010", "20020", "20050", "20040", "20060", "20030"];
  const DEFAULT_OWNED_MONSTERS = ["30080", "30010", "31010", "30020", "30030", "30040", "30050", "30070"];

  const SAVE_KEY = "zombierush2_web_save_v1";

  function loadSave() {
    try {
      const raw = localStorage.getItem(SAVE_KEY);
      if (raw) {
        const s = JSON.parse(raw);
        if (s && s.plantMap && s.monsterMap) return s;
      }
    } catch (_) {}
    const plantMap = {};
    DEFAULT_OWNED_PLANTS.forEach((id) => (plantMap[id] = id));
    const monsterMap = {};
    DEFAULT_OWNED_MONSTERS.forEach((id) => (monsterMap[id] = id));
    return {
      level: 1,
      sun: 600,
      gold: 1500,
      gem: 120,
      stars: {}, // campaignId -> 1..3
      plantMap, // baseId -> currentId
      monsterMap, // baseId -> currentId
      plantDeck: ["10010", "20010", "22010", "21010", "20020", "20050", "20040", "20060"],
      monsterDeck: ["30080", "30010", "31010", "30020", "30030", "30040", "30050", "30070"],
      farmPlots: [
        { row: 2, col: 2, baseId: "10010" },
        { row: 2, col: 4, baseId: "20010" },
        { row: 3, col: 3, baseId: "20040" },
        { row: 4, col: 5, baseId: "20060" },
      ],
    };
  }

  function writeSave() {
    try {
      localStorage.setItem(SAVE_KEY, JSON.stringify(appState.save));
    } catch (_) {}
  }

  // ==================== 音频系统 (BGM + 原版音效) ====================
  class AudioMgr {
    constructor() {
      this.muted = false;
      this.currentTrack = "";
      this.bgmEl = null;
      this.lastSfx = {};
      this.unlocked = false;
    }

    unlock() {
      if (this.unlocked) return;
      this.unlocked = true;
      if (this.currentTrack && !this.muted) {
        this._startBgm(this.currentTrack);
      }
    }

    playBgm(trackName) {
      if (this.currentTrack === trackName && this.bgmEl && !this.bgmEl.paused) return;
      this.currentTrack = trackName;
      if (this.muted) return;
      this._startBgm(trackName);
    }

    _startBgm(trackName) {
      if (this.bgmEl) {
        this.bgmEl.pause();
        this.bgmEl = null;
      }
      const el = new Audio(`assets/${trackName}.mp3`);
      el.loop = true;
      el.volume = 0.42;
      this.bgmEl = el;
      el.play().catch(() => {});
    }

    toggleMute() {
      this.muted = !this.muted;
      if (this.muted) {
        if (this.bgmEl) this.bgmEl.pause();
      } else if (this.currentTrack) {
        this._startBgm(this.currentTrack);
      }
      return this.muted;
    }

    sfx(name, volume = 0.45) {
      if (this.muted) return;
      const now = performance.now();
      if (this.lastSfx[name] && now - this.lastSfx[name] < 90) return;
      this.lastSfx[name] = now;
      const a = new Audio(`assets/${name}.mp3`);
      a.volume = volume;
      a.play().catch(() => {});
    }
  }

  const audio = new AudioMgr();

  // ==================== 全局应用状态 ====================
  const appState = {
    screen: "login", // "login" | "farm" | "battle"
    data: null,
    save: loadSave(),
    bgs: {},
    loginArms: [],
    farmBuildings: [],
    farmPlotUnits: [],
    farmSuns: [],
    previewArm: null,
    previewCfg: null,
    previewKind: "plant",
    atlasTab: "plant",
    selectedChapter: 1,
    levelFilter: "all",
    deckSide: "defense",
    lotteryArm: null,
  };

  // ==================== 战斗引擎状态 ====================
  const battle = {
    campaign: null,
    isEndless: false,
    mode: "defense",
    speedMul: 1,
    sun: 100,
    elapsedMs: 0,
    endlessWave: 1,
    over: false,
    paused: false,
    selectedDeckIndex: 0,
    shovelSelected: false,
    hoverCell: null,
    hoverLane: -1,
    cooldowns: {},
    units: [],
    bullets: [],
    beams: [],
    suns: [],
    effects: [],
    floatTexts: [],
    cars: [],
    spawns: [],
    nextSpawnIdx: 0,
    skySunTimer: 4.0,
    attackSunTimer: 0,
    deadPlantsCount: 0,
    waveBannerShown: false,
    daveArm: null,
  };

  let uidSeq = 1;
  const nextUid = () => uidSeq++;

  function toggleFullscreen() {
    const el = document.documentElement;
    if (!document.fullscreenElement && !document.webkitFullscreenElement) {
      if (el.requestFullscreen) el.requestFullscreen().catch(() => {});
      else if (el.webkitRequestFullscreen) el.webkitRequestFullscreen();
    } else {
      if (document.exitFullscreen) document.exitFullscreen().catch(() => {});
      else if (document.webkitExitFullscreen) document.webkitExitFullscreen();
    }
  }

  function showScreen(name) {
    appState.screen = name;
    document.getElementById("screenLogin").classList.toggle("hidden", name !== "login");
    document.getElementById("screenFarm").classList.toggle("hidden", name !== "farm");
    document.getElementById("screenBattle").classList.toggle("hidden", name !== "battle");

    if (name === "login") {
      audio.playBgm("beginGame");
      updateSaveSummary();
    } else if (name === "farm") {
      audio.playBgm("enterGame");
      refreshFarmUI();
    } else if (name === "battle") {
      audio.playBgm("battle_start");
    }
  }

  function updateSaveSummary() {
    const totalStars = Object.values(appState.save.stars).reduce((a, b) => a + b, 0);
    const cleared = Object.keys(appState.save.stars).length;
    document.getElementById("saveSummary").textContent =
      `指挥官 LV.${appState.save.level} · 已通关 ${cleared} 关 · 总星数 ★${totalStars} · 阳光 ${appState.save.sun} · 金币 ${appState.save.gold}`;
  }

  function getActiveUnitCfg(kind, baseId) {
    if (kind === "plant") {
      const curId = appState.save.plantMap[baseId] || baseId;
      return appState.data.plants[curId] || appState.data.plants[baseId];
    } else {
      const curId = appState.save.monsterMap[baseId] || baseId;
      return appState.data.monsters[curId] || appState.data.monsters[baseId];
    }
  }

  // ==================== 1. 登录标题页逻辑 ====================
  async function initLoginScene() {
    await window.armatureCache.load("loginArmature").catch(() => {});
    const la = new window.ArmatureInstance("loginArmature");
    la.play("idle", true);
    appState.loginArms = [{ arm: la, x: 480, y: 270, sx: 0.94, sy: 0.94 }];
  }

  function drawLoginScene(dt) {
    const c = document.getElementById("loginCanvas");
    const ctx = c.getContext("2d");
    ctx.clearRect(0, 0, c.width, c.height);
    if (appState.bgs.login) {
      ctx.drawImage(appState.bgs.login, 0, 0, c.width, c.height);
    }
    for (const item of appState.loginArms) {
      item.arm.update(dt);
      item.arm.draw(ctx, item.x, item.y, item.sx, item.sy);
    }
  }

  // ==================== 2. 农场家园主城逻辑 ====================
  async function initFarmScene() {
    await Promise.all([
      window.armatureCache.load("houseBuilding"),
      window.armatureCache.load("laboratoryBuilding"),
      window.armatureCache.load("altarBuilding"),
    ].map((p) => p.catch(() => {})));

    const h = new window.ArmatureInstance("houseBuilding");
    h.play("Action0", true);
    const l = new window.ArmatureInstance("laboratoryBuilding");
    l.play("Action0", true);
    const a = new window.ArmatureInstance("altarBuilding");
    a.play("Action0", true);

    appState.farmBuildings = [
      { name: "出战编队基地", x: 345, y: 192, labelX: 345, labelY: 200, scale: 0.54, arm: h, action: () => openDeckModal(battle.mode) },
      { name: "基因图鉴实验室", x: 455, y: 176, labelX: 545, labelY: 200, scale: 0.54, arm: l, action: () => openAtlasModal("plant") },
      { name: "神秘召唤祭坛", x: 745, y: 188, labelX: 745, labelY: 200, scale: 0.54, arm: a, action: () => openLotteryModal() },
    ];

    await syncFarmPlots();
  }

  async function syncFarmPlots() {
    const plots = appState.save.farmPlots || [];
    await Promise.all(
      plots.map((p) => {
        const cfg = getActiveUnitCfg("plant", p.baseId);
        return cfg ? window.armatureCache.load(cfg.image).catch(() => {}) : Promise.resolve();
      })
    );
    appState.farmPlotUnits = plots.map((p) => {
      const cfg = getActiveUnitCfg("plant", p.baseId);
      const arm = new window.ArmatureInstance(cfg.image);
      arm.play("idle", true);
      return { ...p, cfg, arm, sunTimer: 2 + Math.random() * 4 };
    });
  }

  function refreshFarmUI() {
    const totalStars = Object.values(appState.save.stars).reduce((a, b) => a + b, 0);
    document.getElementById("farmLv").textContent = "LV." + appState.save.level;
    document.getElementById("farmStars").textContent = totalStars;
    document.getElementById("farmSun").textContent = appState.save.sun;
    document.getElementById("farmGold").textContent = appState.save.gold;
    document.getElementById("farmGem").textContent = appState.save.gem;
  }

  function drawFarmScene(dt) {
    const c = document.getElementById("farmCanvas");
    const ctx = c.getContext("2d");
    ctx.clearRect(0, 0, c.width, c.height);

    if (appState.bgs.farm) {
      ctx.drawImage(appState.bgs.farm, 0, 0, c.width, c.height);
    }

    // 建筑骨骼与标签
    for (const b of appState.farmBuildings) {
      b.arm.update(dt);
      b.arm.draw(ctx, b.x, b.y, b.scale, b.scale);
      const lx = b.labelX || b.x;
      const ly = b.labelY || b.y;
      ctx.save();
      ctx.font = "bold 12px sans-serif";
      ctx.textAlign = "center";
      ctx.fillStyle = "rgba(18, 25, 13, 0.85)";
      ctx.fillRect(lx - 56, ly + 4, 112, 20);
      ctx.strokeStyle = "#d9a441";
      ctx.strokeRect(lx - 56, ly + 4, 112, 20);
      ctx.fillStyle = "#ffe57f";
      ctx.fillText(b.name, lx, ly + 18);
      ctx.restore();
    }

    // 农田 5x7 网格 (对应 farmBg1.jpg 下方泥地区域 x: 342..790, y: 318..480)
    const fx0 = 344;
    const fy0 = 315;
    const fw = 63;
    const fh = 32;
    for (let r = 1; r <= 5; r++) {
      for (let col = 1; col <= 7; col++) {
        ctx.strokeStyle = "rgba(255, 255, 255, 0.12)";
        ctx.strokeRect(fx0 + (col - 1) * fw, fy0 + (r - 1) * fh, fw, fh);
      }
    }

    for (const u of appState.farmPlotUnits) {
      u.arm.update(dt);
      const px = fx0 + (u.col - 0.5) * fw;
      const py = fy0 + (u.row - 0.15) * fh;
      u.arm.draw(ctx, px, py, (u.cfg.scale || 0.6) * 0.65, (u.cfg.scale || 0.6) * 0.65);

      u.sunTimer -= dt;
      if (u.sunTimer <= 0) {
        u.sunTimer = 5.5 + Math.random() * 3;
        if (appState.farmSuns.length < 10) {
          appState.farmSuns.push({ id: nextUid(), x: px, y: py - 35, life: 12 });
        }
      }
    }

    appState.farmSuns = appState.farmSuns.filter((s) => {
      s.life -= dt;
      ctx.save();
      ctx.translate(s.x, s.y + Math.sin(performance.now() * 0.004 + s.id) * 4);
      ctx.shadowColor = "#ffd94a";
      ctx.shadowBlur = 12;
      ctx.scale(1.0, 1.0);
      window.atlasMgr.drawFrame(ctx, "BattleViewResImg", "battleSun.png", 0.5, 0.5, false);
      ctx.restore();
      return s.life > 0;
    });
  }

  function handleFarmClick(e) {
    const c = document.getElementById("farmCanvas");
    const rect = c.getBoundingClientRect();
    const x = ((e.clientX - rect.left) / rect.width) * c.width;
    const y = ((e.clientY - rect.top) / rect.height) * c.height;

    // 1. 收获农场阳光
    for (let i = appState.farmSuns.length - 1; i >= 0; i--) {
      const s = appState.farmSuns[i];
      if (Math.hypot(s.x - x, s.y - y) <= 28) {
        appState.farmSuns.splice(i, 1);
        appState.save.sun += 50;
        appState.save.gold += 30;
        writeSave();
        refreshFarmUI();
        audio.sfx("sys_get_sun", 0.5);
        return;
      }
    }

    // 2. 点击建筑
    for (const b of appState.farmBuildings) {
      const lx = b.labelX || b.x;
      if (Math.abs(x - lx) < 75 && y >= 85 && y <= 235) {
        audio.sfx("sys_plant_select", 0.4);
        b.action();
        return;
      }
    }

    // 3. 点击农田空地种植随机已拥有植物
    const fx0 = 344, fy0 = 315, fw = 63, fh = 32;
    const col = Math.floor((x - fx0) / fw) + 1;
    const row = Math.floor((y - fy0) / fh) + 1;
    if (col >= 1 && col <= 7 && row >= 1 && row <= 5) {
      const existing = appState.save.farmPlots.find((p) => p.row === row && p.col === col);
      if (existing) {
        appState.save.sun += 25;
        appState.save.farmPlots = appState.save.farmPlots.filter((p) => p !== existing);
        audio.sfx("sys_plant_select", 0.4);
      } else {
        const owned = Object.keys(appState.save.plantMap);
        const pick = owned[Math.floor(Math.random() * owned.length)] || "10010";
        appState.save.farmPlots.push({ row, col, baseId: pick });
        audio.sfx("sys_plant_farm", 0.5);
      }
      writeSave();
      refreshFarmUI();
      syncFarmPlots();
    }
  }

  // ==================== 3. 战斗核心引擎 ====================
  function cellCenterX(col) {
    return GRID_LEFT + (col - 0.5) * CELL_W;
  }
  function laneFootY(row) {
    return GRID_TOP + (row - 0.14) * CELL_H;
  }
  function laneCenterY(row) {
    return GRID_TOP + (row - 0.5) * CELL_H;
  }

  function showBanner(text, ms = 2000) {
    const el = document.getElementById("bannerMsg");
    el.textContent = text;
    el.classList.remove("hidden");
    clearTimeout(showBanner._t);
    showBanner._t = setTimeout(() => el.classList.add("hidden"), ms);
  }

  function showDaveTip(text, ms = 3200) {
    const box = document.getElementById("daveBubble");
    document.getElementById("daveText").textContent = text;
    box.classList.remove("hidden");
    if (!battle.daveArm) {
      battle.daveArm = new window.ArmatureInstance("DaveArmature");
    }
    battle.daveArm.play("say", true);
    clearTimeout(showDaveTip._t);
    showDaveTip._t = setTimeout(() => box.classList.add("hidden"), ms);
  }

  function addFloatText(x, y, text, color = "#ffe868") {
    battle.floatTexts.push({ x, y, text, color, life: 0.9, maxLife: 0.9 });
  }

  function createBattleUnit(cfg, side, row, x, col = 0) {
    const isPlant = side === "plant";
    const arm = new window.ArmatureInstance(cfg.image);
    const scale = (cfg.scale || 0.6) * 0.92;
    const hp = cfg.hp > 0 ? cfg.hp : 280;
    const moveSpeedPx = isPlant
      ? 0
      : (CELL_W / ((cfg.moveMsPerCell || 3333) / 1000)) *
        (cfg.speedScale ? Math.min(1.35, cfg.speedScale * 0.48) : 0.9);

    return {
      uid: nextUid(),
      side,
      cfg,
      row,
      col,
      x,
      y: laneFootY(row),
      hp,
      maxHp: hp,
      atk: cfg.atk || 0,
      atkInterval: Math.max(420, cfg.atkInterval || 1500),
      atkTimer: Math.random() * 0.3,
      sunTimer: ((cfg.sunInterval || 7000) / 1000) * 0.5,
      rangePx: (cfg.range || 1) * (CELL_W * 0.85),
      moveSpeedPx,
      scale,
      arm,
      slowTimer: 0,
      stunTimer: 0,
      poisonTimer: 0,
      poisonTick: 0,
      hitFlash: 0,
      dead: false,
      deadTimer: 0,
      hasSummoned: false,
      hasBoomed: false,
    };
  }

  function spawnSun(x, y, targetY, value = 50, fromSky = false) {
    battle.suns.push({
      id: nextUid(),
      x,
      y,
      targetY,
      vy: fromSky ? 52 : -70,
      value,
      life: 14,
      collected: false,
      flyT: 0,
      fromSky,
    });
  }

  function resolveBulletInfo(bulletId) {
    const b = appState.data.bullets[String(bulletId)];
    if (!b) return { sprite: "GreenPeaBullet.png", kind: 0, buff: 0, animType: 0 };
    let sp = b.sprite ? b.sprite + ".png" : "GreenPeaBullet.png";
    if (!window.atlasMgr.getFrame("BattleViewResImg", sp)) {
      if (window.atlasMgr.getFrame("BattleViewResImg", b.sprite + "1.png")) {
        sp = b.sprite + "1.png";
      } else {
        sp = "GreenPeaBullet.png";
      }
    }
    return { sprite: sp, kind: b.kind, buff: b.buff, animType: b.animType };
  }

  function spawnExplosionEffect(name, x, y, scale = 0.65) {
    const armName = window.atlasMgr.atlases[name] ? name : "MelonExplode";
    const arm = new window.ArmatureInstance(armName);
    arm.play("explode", false, true);
    battle.effects.push({ x, y, scale, arm, life: 0.7 });
  }

  async function preloadLevelArmatures(campaign) {
    const names = new Set([
      "battleCar", "spoilBoxArmature", "DaveArmature",
      "MelonExplode", "BombExplode", "WinterMelonExplode", "BombPitcherExplode", "FireMelonExplode",
    ]);
    for (const baseId of appState.save.plantDeck) {
      const cfg = getActiveUnitCfg("plant", baseId);
      if (cfg) names.add(cfg.image);
    }
    for (const baseId of appState.save.monsterDeck) {
      const cfg = getActiveUnitCfg("monster", baseId);
      if (cfg) names.add(cfg.image);
    }
    for (const p of campaign.plants || []) {
      const cfg = appState.data.plants[p.plantId];
      if (cfg) names.add(cfg.image);
    }
    for (const m of campaign.monsters || []) {
      const cfg = appState.data.monsters[m.monsterId];
      if (cfg) names.add(cfg.image);
    }
    await Promise.all([...names].map((n) => window.armatureCache.load(n).catch(() => {})));
  }

  async function startBattle(campaign, isEndless = false) {
    battle.campaign = campaign;
    battle.isEndless = isEndless;
    battle.mode = isEndless ? "defense" : campaign.mode;
    battle.sun = isEndless ? 150 : Math.max(campaign.initSun, battle.mode === "attack" ? 140 : 100);
    battle.elapsedMs = 0;
    battle.endlessWave = 1;
    battle.over = false;
    battle.paused = false;
    battle.selectedDeckIndex = 0;
    battle.shovelSelected = false;
    battle.cooldowns = {};
    battle.units = [];
    battle.bullets = [];
    battle.beams = [];
    battle.suns = [];
    battle.effects = [];
    battle.floatTexts = [];
    battle.cars = [];
    battle.deadPlantsCount = 0;
    battle.waveBannerShown = false;
    battle.skySunTimer = 4.0;
    battle.attackSunTimer = 0;

    showScreen("battle");
    await preloadLevelArmatures(campaign);

    for (let r = 1; r <= ROWS; r++) {
      if (battle.mode === "defense") {
        const arm = new window.ArmatureInstance("battleCar");
        arm.play("idle", true);
        battle.cars.push({ row: r, x: GOAL_X, y: laneFootY(r), active: false, used: false, arm, scale: 0.5 });
      } else {
        const arm = new window.ArmatureInstance("spoilBoxArmature");
        arm.play("close", true);
        battle.cars.push({ row: r, x: GOAL_X, y: laneFootY(r), opened: false, arm, scale: 0.52 });
      }
    }

    if (battle.mode === "defense") {
      if (isEndless) {
        battle.spawns = buildEndlessWave(1);
      } else {
        battle.spawns = optimizeDefenseSpawns(campaign.monsters || [], campaign.id);
      }
      battle.nextSpawnIdx = 0;
      battle.sun = Math.max(battle.sun, 150);
      showBanner(`防守准备：${isEndless ? "无尽生存 第1波" : campaign.name}`, 1800);
      showDaveTip("点击上方植物卡牌，在草坪种植防线阻挡僵尸！记得点击收集阳光哦～", 3400);
    } else {
      battle.spawns = [];
      battle.nextSpawnIdx = 0;
      for (const p of campaign.plants || []) {
        const cfg = appState.data.plants[p.plantId];
        if (!cfg) continue;
        const unit = createBattleUnit(cfg, "plant", p.row, cellCenterX(p.col), p.col);
        unit.arm.play("idle", true);
        battle.units.push(unit);
      }
      showBanner(`僵尸进攻：${campaign.name}`, 1800);
      showDaveTip("进攻模式！选择僵尸卡牌，点击右侧出兵点派遣僵尸攻破植物防线与宝箱！", 3600);
    }

    updateBattleHUD();
    renderBattleCardBar(true);
  }

  function optimizeDefenseSpawns(rawMonsters, campaignId) {
    if (!rawMonsters || rawMonsters.length === 0) return [];
    const sorted = [...rawMonsters].sort((a, b) => a.time - b.time);

    // 控制单关僵尸总数上限，避免早期关卡或原版堆怪过多过于逆天
    const maxCount = campaignId === "10101" ? 3 : Math.min(24, Math.max(6, Math.round(sorted.length * 0.45)));
    let picked = [];
    if (sorted.length <= maxCount) {
      picked = sorted.map((m) => ({ ...m }));
    } else {
      // 均匀抽样，保留首尾及关键高阶僵尸
      for (let i = 0; i < maxCount; i++) {
        const idx = Math.min(sorted.length - 1, Math.floor((i * sorted.length) / maxCount));
        picked.push({ ...sorted[idx] });
      }
    }

    // 1-1 教学关原版只有1只，补2只间隔良好的普通僵尸方便体验完整战斗
    if (campaignId === "10101" && picked.length === 1) {
      picked.push({ time: 11000, row: 2, monsterId: picked[0].monsterId });
      picked.push({ time: 18500, row: 4, monsterId: picked[0].monsterId });
    }

    // 平滑生成间隔，避免同一秒扎堆涌出（至少间隔 1.6s ~ 2.6s）
    let t = 3500;
    for (let i = 0; i < picked.length; i++) {
      const gap = i === 0 ? 0 : Math.max(1500, 2700 - Math.min(1100, picked.length * 35));
      t += gap;
      picked[i].time = i === 0 ? 3500 : t;
    }
    return picked;
  }

  function buildEndlessWave(waveNum) {
    const pool = ["30010", "31010", "30020", "30030", "30040", "33010", "30050", "30070"];
    const maxTier = Math.min(pool.length, 1 + Math.ceil(waveNum / 2));
    const count = Math.min(24, 4 + waveNum * 2);
    const list = [];
    for (let i = 0; i < count; i++) {
      const mId = pool[Math.floor(Math.random() * maxTier)];
      const row = 1 + Math.floor(Math.random() * ROWS);
      list.push({ time: 3000 + i * Math.max(1350, 2600 - waveNum * 110), row, monsterId: mId });
    }
    return list;
  }

  function getBattleDeckConfigs() {
    const isDef = battle.mode === "defense";
    const deck = isDef ? appState.save.plantDeck : appState.save.monsterDeck;
    return deck.map((baseId) => ({
      baseId,
      cfg: getActiveUnitCfg(isDef ? "plant" : "monster", baseId),
    })).filter((x) => x.cfg);
  }

  function renderBattleCardBar(force = false) {
    const bar = document.getElementById("cardBar");
    const items = getBattleDeckConfigs();
    const atlasName = battle.mode === "defense" ? "PlantIconImg" : "MonsterIconImg";
    const sig = `${battle.mode}:${items.map((x) => x.cfg.id).join(",")}`;

    if (force || bar.dataset.sig !== sig) {
      bar.dataset.sig = sig;
      bar.innerHTML = "";
      items.forEach(({ baseId, cfg }, idx) => {
        const card = document.createElement("div");
        card.className = "unit-card";
        card.dataset.idx = idx;
        card.dataset.id = cfg.id;
        card.dataset.cost = cfg.cost;

        // 使用原版 battleCard1..5.png 作为卡片品质底框
        const qBg = window.atlasMgr.getFrameDataURL("BattleViewResImg", `battleCard${Math.min(5, Math.max(1, cfg.quality || 1))}.png`);
        if (qBg) card.style.backgroundImage = `url(${qBg})`;

        const iconCanvas = document.createElement("canvas");
        iconCanvas.width = 44;
        iconCanvas.height = 36;
        const ictx = iconCanvas.getContext("2d");
        const frameName = window.atlasMgr.getFrame(atlasName, cfg.image + "S.png")
          ? cfg.image + "S.png"
          : cfg.image + "Card.png";
        const f = window.atlasMgr.getFrame(atlasName, frameName);
        if (f) {
          const s = Math.min(40 / f.ow, 34 / f.oh);
          ictx.translate(22, 18);
          ictx.scale(s, s);
          window.atlasMgr.drawFrame(ictx, atlasName, frameName, 0.5, 0.5, false);
        }

        const nameEl = document.createElement("span");
        nameEl.className = "card-name";
        nameEl.textContent = cfg.name;

        const costEl = document.createElement("span");
        costEl.className = "card-cost";
        costEl.textContent = cfg.cost;

        const cdEl = document.createElement("div");
        cdEl.className = "card-cd";

        card.appendChild(iconCanvas);
        card.appendChild(nameEl);
        card.appendChild(costEl);
        card.appendChild(cdEl);
        card.title = `${cfg.name} (阳光:${cfg.cost} HP:${cfg.hp} 攻:${cfg.atk})`;

        card.addEventListener("click", () => {
          audio.sfx("sys_plant_select", 0.35);
          battle.shovelSelected = false;
          battle.selectedDeckIndex = battle.selectedDeckIndex === idx ? -1 : idx;
          updateBattleCardBarState();
          updateShovelUI();
        });
        bar.appendChild(card);
      });
    }
    updateBattleCardBarState();
  }

  function updateBattleCardBarState() {
    const cards = document.querySelectorAll("#cardBar .unit-card");
    cards.forEach((card) => {
      const idx = Number(card.dataset.idx);
      const id = card.dataset.id;
      const cost = Number(card.dataset.cost);
      const cd = battle.cooldowns[id] || 0;
      card.classList.toggle("selected", battle.selectedDeckIndex === idx && !battle.shovelSelected);
      card.classList.toggle("disabled", battle.sun < cost || cd > 0);
      const cdEl = card.querySelector(".card-cd");
      if (cdEl) cdEl.style.height = `${Math.min(100, (cd / 3.2) * 100)}%`;
    });
  }

  function updateShovelUI() {
    const btn = document.getElementById("btnShovel");
    btn.classList.toggle("hidden", battle.mode !== "defense");
    btn.classList.toggle("selected", battle.shovelSelected);
  }

  function updateBattleHUD() {
    document.getElementById("sunAmount").textContent = Math.floor(battle.sun);
    const badge = document.getElementById("modeBadge");
    if (battle.isEndless) {
      badge.textContent = "无尽";
      badge.className = "hud-badge";
    } else if (battle.mode === "defense") {
      badge.textContent = "防守";
      badge.className = "hud-badge";
    } else {
      badge.textContent = "进攻";
      badge.className = "hud-badge attack";
    }

    document.getElementById("levelName").textContent = battle.isEndless
      ? `无尽 第${battle.endlessWave}波`
      : battle.campaign.name;

    if (battle.mode === "defense") {
      const total = Math.max(1, battle.spawns.length);
      const pct = Math.min(100, Math.round((battle.nextSpawnIdx / total) * 100));
      document.getElementById("waveBarFill").style.width = pct + "%";
      document.getElementById("waveText").textContent = `${battle.nextSpawnIdx}/${total}`;
    } else {
      const opened = battle.cars.filter((c) => c.opened).length;
      const activeLanes = new Set(battle.units.filter((u) => u.side === "plant").map((u) => u.row));
      const target = Math.max(1, activeLanes.size || 1);
      document.getElementById("waveBarFill").style.width = Math.min(100, Math.round((opened / target) * 100)) + "%";
      document.getElementById("waveText").textContent = `${opened}/${target}`;
    }

    updateShovelUI();
  }

  function triggerCombatAction(u, target) {
    if (u.side === "monster" && /BoomZombie|FiremenZombie|SuicideZombie|CrazyScientist/.test(u.cfg.image) && !u.hasBoomed) {
      u.hasBoomed = true;
      u.arm.play("boom", false, true);
      audio.sfx("battle_BoomZombie_Boom", 0.55);
      spawnExplosionEffect("BombExplode", u.x, u.y - 35, 0.72);
      for (const p of battle.units) {
        if (p.side === "plant" && !p.dead && Math.abs(p.row - u.row) <= (u.cfg.image === "SuicideZombie" ? 1 : 0) && Math.abs(p.x - u.x) < CELL_W * 1.3) {
          const dmg = /Nut|Spike|Thorns/.test(p.cfg.image) ? u.atk * 5 : u.atk * 2;
          damageUnit(p, dmg);
        }
      }
      u.hp = 0;
      u.dead = true;
      u.deadTimer = 0.5;
      return;
    }

    if (u.side === "monster" && /DancingZombie|HipHopZombie|SuitDancingZombie|ElvisZombie|JacksonZombie/.test(u.cfg.image) && !u.hasSummoned) {
      u.hasSummoned = true;
      u.arm.play("summon", false, true);
      audio.sfx("battle_DancingZombie_skill", 0.45);
      const basicCfg = appState.data.monsters["30010"];
      if (basicCfg) {
        for (const dr of [-1, 1]) {
          const r = u.row + dr;
          if (r >= 1 && r <= ROWS) {
            const ally = createBattleUnit({ ...basicCfg, hp: Math.round(basicCfg.hp * 0.45), atk: Math.round(basicCfg.atk * 0.6) }, "monster", r, u.x + 14);
            ally.arm.play("walk", true);
            battle.units.push(ally);
          }
        }
      }
      return;
    }

    u.arm.play("attack", false, true);

    if (u.cfg.bullet && u.cfg.bullet > 0) {
      const bInfo = resolveBulletInfo(u.cfg.bullet);
      const isPlant = u.side === "plant";
      const rows = u.cfg.image === "Threepeater" ? [u.row - 1, u.row, u.row + 1].filter((r) => r >= 1 && r <= ROWS) : [u.row];

      if (isPlant) {
        audio.sfx("battle_bullet_shoot_" + (1 + Math.floor(Math.random() * 3)), 0.35);
      }

      for (const r of rows) {
        const rowTarget = r === u.row ? target : findTargetForRow(u, r);
        const startX = u.x + (isPlant ? 22 : -22);
        const startY = laneFootY(r) - 42;

        // 闪电魔法攻击 (animType === 2)：绘制施法者到目标之间的连续闪电光束！
        if (bInfo.animType === 2 && rowTarget) {
          battle.beams.push({
            x1: startX,
            y1: startY,
            x2: rowTarget.x,
            y2: rowTarget.y - 34,
            color: /DarkMagic/.test(u.cfg.image) ? "#d975ff" : /Thor/.test(u.cfg.image) ? "#7be7ff" : "#96ffaa",
            life: 0.24,
            maxLife: 0.24,
          });
          damageUnit(rowTarget, u.atk);
          continue;
        }

        if (bInfo.kind === 1 && rowTarget) {
          battle.bullets.push({
            side: u.side,
            row: r,
            x: startX,
            y: startY,
            startX,
            startY,
            targetX: rowTarget.x,
            targetY: rowTarget.y - 30,
            t: 0,
            duration: 0.76,
            parabolic: true,
            dmg: u.atk,
            sprite: bInfo.sprite,
            buff: bInfo.buff,
            aoe: /Melon|BombPitcher/i.test(u.cfg.image),
            image: u.cfg.image,
          });
        } else {
          battle.bullets.push({
            side: u.side,
            row: r,
            x: startX,
            y: startY,
            vx: isPlant ? 340 : -280,
            parabolic: false,
            dmg: u.atk,
            sprite: bInfo.sprite,
            buff: bInfo.buff,
            aoe: false,
            image: u.cfg.image,
          });
        }
      }
    } else {
      if (u.side === "monster") {
        if (u.cfg.image === "Gargantuar") audio.sfx("battle_Gargantuar_attack_plant", 0.5);
        else audio.sfx("battle_zombie_attack_plant_" + (1 + Math.floor(Math.random() * 3)), 0.28);
      } else {
        if (/Cabbage|BonkChoy/.test(u.cfg.image)) audio.sfx("battle_BonkChoy_attack", 0.4);
        else if (/Spike|Thorns/.test(u.cfg.image)) audio.sfx("battle_Spikeweed_attack", 0.35);
      }

      if (/Spikeweed|Spikerock|ThornsTrap/.test(u.cfg.image)) {
        for (const m of battle.units) {
          if (m.side === "monster" && !m.dead && m.row === u.row && Math.abs(m.x - u.x) <= CELL_W * 0.65) {
            damageUnit(m, u.atk);
          }
        }
      } else {
        damageUnit(target, u.atk);
      }
    }
  }

  function damageUnit(u, dmg) {
    if (u.dead) return;
    u.hp -= dmg;
    u.hitFlash = 0.12;
    if (u.hp <= 0) {
      u.hp = 0;
      u.dead = true;
      u.deadTimer = 0.72;
      if (u.side === "plant") {
        battle.deadPlantsCount++;
        audio.sfx("battle_plant_die", 0.4);
      } else {
        u.arm.play("dead", false, true);
        if (u.cfg.image === "Gargantuar") audio.sfx("battle_Gargantuar_die", 0.5);
        else audio.sfx("battle_zombie_die_" + (1 + Math.floor(Math.random() * 2)), 0.3);
        if (battle.mode === "defense" && Math.random() < 0.32) {
          spawnSun(u.x, u.y - 30, u.y - 6, 25, false);
        }
      }
    }
  }

  function findTargetForRow(u, row) {
    const enemySide = u.side === "plant" ? "monster" : "plant";
    let best = null;
    let bestDist = Infinity;

    for (const o of battle.units) {
      if (o.dead || o.side !== enemySide || o.row !== row) continue;
      if (u.side === "monster" && /Spikeweed|Spikerock|ThornsTrap/.test(o.cfg.image)) {
        if (!/Gargantuar|BoomZombie|Gangster/.test(u.cfg.image)) continue;
      }
      const dx = u.side === "plant" ? o.x - u.x : u.x - o.x;
      if (dx >= -26 && dx <= u.rangePx && dx < bestDist) {
        bestDist = dx;
        best = o;
      }
    }
    return best;
  }

  function updateBattle(dt) {
    if (battle.daveArm) battle.daveArm.update(dt);
    if (battle.over || battle.paused) return;

    const scaledDt = dt * battle.speedMul;
    battle.elapsedMs += scaledDt * 1000;

    let cdChanged = false;
    for (const k of Object.keys(battle.cooldowns)) {
      if (battle.cooldowns[k] > 0) {
        battle.cooldowns[k] = Math.max(0, battle.cooldowns[k] - scaledDt);
        cdChanged = true;
      }
    }

    if (battle.mode === "defense") {
      battle.skySunTimer -= scaledDt;
      if (battle.skySunTimer <= 0) {
        battle.skySunTimer = 5.5;
        const sx = GRID_LEFT + 30 + Math.random() * (CELL_W * COLS - 60);
        const ty = GRID_TOP + 60 + Math.random() * (CELL_H * ROWS - 90);
        spawnSun(sx, -20, ty, 50, true);
      }

      while (battle.nextSpawnIdx < battle.spawns.length && battle.elapsedMs >= battle.spawns[battle.nextSpawnIdx].time) {
        const sp = battle.spawns[battle.nextSpawnIdx++];
        const cfg = appState.data.monsters[sp.monsterId] || appState.data.monsters["30010"];
        if (cfg) {
          const z = createBattleUnit(cfg, "monster", sp.row, SPAWN_X + Math.random() * 14);
          z.arm.play("walk", true);
          battle.units.push(z);
        }
        if (!battle.waveBannerShown && battle.nextSpawnIdx >= Math.floor(battle.spawns.length * 0.65) && battle.spawns.length >= 6) {
          battle.waveBannerShown = true;
          showBanner("一大波僵尸正在接近！", 2200);
          audio.sfx("battle_wave_zombie", 0.5);
          audio.sfx("battle_FlgZombie_ShakingFlag", 0.45);
        }
      }
    } else {
      battle.attackSunTimer += scaledDt;
      if (battle.attackSunTimer >= 1.1) {
        battle.attackSunTimer = 0;
        battle.sun += 14;
      }
    }

    for (const u of battle.units) {
      if (u.dead) {
        u.deadTimer -= scaledDt;
        u.arm.update(scaledDt);
        continue;
      }
      if (u.hitFlash > 0) u.hitFlash -= scaledDt;
      if (u.slowTimer > 0) u.slowTimer -= scaledDt;
      if (u.stunTimer > 0) {
        u.stunTimer -= scaledDt;
        continue;
      }
      if (u.poisonTimer > 0) {
        u.poisonTimer -= scaledDt;
        u.poisonTick += scaledDt;
        if (u.poisonTick >= 1.0) {
          u.poisonTick -= 1.0;
          damageUnit(u, 15);
          if (u.dead) continue;
        }
      }

      const slowFactor = u.slowTimer > 0 ? 0.5 : 1.0;
      u.arm.speedMul = slowFactor;
      u.arm.update(scaledDt);

      if (u.side === "plant" && u.cfg.sunValue > 0) {
        u.sunTimer -= scaledDt;
        if (u.sunTimer <= 0) {
          u.sunTimer = Math.max(5.5, (u.cfg.sunInterval || 7000) / 1000);
          spawnSun(u.x, u.y - 45, u.y - 8, Math.min(75, Math.max(25, Math.round(u.cfg.sunValue / 2) * 5 || 25)), false);
        }
      }

      const target = u.atk > 0 ? findTargetForRow(u, u.row) : null;
      if (target) {
        u.atkTimer -= scaledDt * slowFactor;
        if (u.atkTimer <= 0) {
          u.atkTimer = u.atkInterval / 1000;
          triggerCombatAction(u, target);
        } else if (u.arm.finished) {
          u.arm.play("idle", true);
        }
      } else if (u.side === "monster") {
        u.x -= u.moveSpeedPx * slowFactor * scaledDt;
        if (u.arm.currentAnim !== "walk") u.arm.play("walk", true);
      } else if (u.arm.currentAnim !== "idle" && u.arm.finished) {
        u.arm.play("idle", true);
      }
    }

    battle.units = battle.units.filter((u) => !u.dead || u.deadTimer > 0);

    // 子弹更新
    const aliveBullets = [];
    for (const b of battle.bullets) {
      if (b.parabolic) {
        b.t += scaledDt / b.duration;
        const p = Math.min(1, b.t);
        b.x = b.startX + (b.targetX - b.startX) * p;
        b.y = b.startY + (b.targetY - b.startY) * p - 4 * 58 * p * (1 - p);

        if (b.t >= 1) {
          const enemySide = b.side === "plant" ? "monster" : "plant";
          if (b.aoe) {
            const expName = /WinterMelon/i.test(b.image)
              ? "WinterMelonExplode"
              : /FireMelon/i.test(b.image)
              ? "FireMelonExplode"
              : /BombPitcher/i.test(b.image)
              ? "BombPitcherExplode"
              : "MelonExplode";
            spawnExplosionEffect(expName, b.x, b.y + 10, 0.58);
            audio.sfx("battle_melonBullet_hit_" + (1 + Math.floor(Math.random() * 2)), 0.45);
          } else {
            audio.sfx("battle_cornBullet_hit_" + (1 + Math.floor(Math.random() * 2)), 0.38);
          }
          for (const o of battle.units) {
            if (o.dead || o.side !== enemySide) continue;
            const hitRadius = b.aoe ? CELL_W * 0.95 : 32;
            if (Math.abs(o.row - b.row) <= (b.aoe ? 1 : 0) && Math.abs(o.x - b.x) <= hitRadius) {
              damageUnit(o, b.dmg);
              if (/WinterMelon/i.test(b.image) || b.buff === 146) o.slowTimer = 3.0;
              if (/KernelPult/i.test(b.image) && Math.random() < 0.25) o.stunTimer = 2.0;
            }
          }
          continue;
        }
        aliveBullets.push(b);
      } else {
        b.x += b.vx * scaledDt;
        if (b.x < 40 || b.x > 820) continue;
        const enemySide = b.side === "plant" ? "monster" : "plant";
        let hit = false;
        for (const o of battle.units) {
          if (o.dead || o.side !== enemySide || o.row !== b.row) continue;
          if (Math.abs(o.x - b.x) <= 22) {
            damageUnit(o, b.dmg);
            if (b.buff === 106 || /SnowPea/i.test(b.image)) o.slowTimer = 2.5;
            if ((b.buff >= 141 && b.buff <= 179) || /PoisonPea/i.test(b.image)) o.poisonTimer = 3.2;
            audio.sfx("battle_peaBullet_hit_" + (1 + Math.floor(Math.random() * 3)), 0.3);
            hit = true;
            break;
          }
        }
        if (!hit) aliveBullets.push(b);
      }
    }
    battle.bullets = aliveBullets;

    battle.beams = battle.beams.filter((bm) => {
      bm.life -= scaledDt;
      return bm.life > 0;
    });

    // 阳光更新
    const nextSuns = [];
    for (const s of battle.suns) {
      if (s.collected) {
        s.flyT += scaledDt * 3.5;
        s.x += (40 - s.x) * Math.min(1, scaledDt * 9);
        s.y += (24 - s.y) * Math.min(1, scaledDt * 9);
        if (s.flyT < 1) nextSuns.push(s);
        continue;
      }
      if (s.fromSky) {
        if (s.y < s.targetY) s.y += s.vy * scaledDt;
      } else if (s.y < s.targetY) {
        s.vy += 260 * scaledDt;
        s.y += s.vy * scaledDt;
        if (s.y > s.targetY) s.y = s.targetY;
      }
      s.life -= scaledDt;
      if (s.life > 0) nextSuns.push(s);
    }
    battle.suns = nextSuns;

    battle.effects = battle.effects.filter((ef) => {
      ef.life -= scaledDt;
      ef.arm.update(scaledDt);
      return ef.life > 0;
    });
    battle.floatTexts = battle.floatTexts.filter((ft) => {
      ft.life -= scaledDt;
      ft.y -= 28 * scaledDt;
      return ft.life > 0;
    });

    // 小推车与胜负判定
    if (battle.mode === "defense") {
      for (const car of battle.cars) {
        car.arm.update(scaledDt);
        if (car.used) continue;
        if (!car.active) {
          for (const m of battle.units) {
            if (m.side === "monster" && !m.dead && m.row === car.row && m.x <= GOAL_X + 28) {
              car.active = true;
              car.arm.play("open", true);
              showBanner("小推车出动清场！", 1400);
              break;
            }
          }
        } else {
          car.x += 430 * scaledDt;
          for (const m of battle.units) {
            if (m.side === "monster" && !m.dead && m.row === car.row && Math.abs(m.x - car.x) < 40) {
              damageUnit(m, 99999);
            }
          }
          if (car.x > 820) car.used = true;
        }
      }

      for (const m of battle.units) {
        if (m.side === "monster" && !m.dead && m.x <= GOAL_X - 18) {
          const car = battle.cars.find((c) => c.row === m.row);
          if (!car || car.used) {
            finishBattle(false, "僵尸突破了防线！");
            return;
          }
        }
      }

      const anyMonsterAlive = battle.units.some((u) => u.side === "monster" && !u.dead);
      if (battle.nextSpawnIdx >= battle.spawns.length && !anyMonsterAlive) {
        if (battle.isEndless) {
          battle.endlessWave++;
          battle.spawns = buildEndlessWave(battle.endlessWave);
          battle.nextSpawnIdx = 0;
          battle.elapsedMs = 0;
          battle.sun += 120;
          showBanner(`无尽第 ${battle.endlessWave} 波来袭！(+120 阳光)`, 2000);
        } else {
          const stars = battle.deadPlantsCount === 0 ? 3 : battle.deadPlantsCount <= 4 ? 2 : 1;
          finishBattle(true, "成功守住所有防线，消灭了全部僵尸！", stars);
        }
      }
    } else {
      for (const box of battle.cars) {
        box.arm.update(scaledDt);
        if (box.opened) continue;
        for (const m of battle.units) {
          if (m.side === "monster" && !m.dead && m.row === box.row && m.x <= GOAL_X + 28) {
            box.opened = true;
            box.arm.play("showSpoil", false, true);
            addFloatText(box.x, box.y - 50, "攻破宝箱！", "#ffe258");
            battle.sun += 100;
            break;
          }
        }
      }
      const activePlantLanes = new Set(battle.units.filter((u) => u.side === "plant").map((u) => u.row));
      const openedBoxes = battle.cars.filter((c) => c.opened).length;
      if (openedBoxes >= Math.max(1, activePlantLanes.size || 1)) {
        finishBattle(true, "僵尸大军成功突破防线，夺取全部宝箱！", 3);
      }
    }

    if (cdChanged || Math.floor(battle.elapsedMs / 180) !== Math.floor((battle.elapsedMs - scaledDt * 1000) / 180)) {
      updateBattleHUD();
      updateBattleCardBarState();
    }
  }

  function finishBattle(win, desc, stars = 3) {
    battle.over = true;
    audio.sfx(win ? "battle_Result_Win_1" : "battle_Result_Lost_1", 0.55);
    document.getElementById("resultTitle").textContent = win ? "战斗胜利！" : "战斗失败";
    document.getElementById("resultStars").textContent = win ? "★".repeat(stars) + "☆".repeat(3 - stars) : "☆☆☆";
    document.getElementById("resultDesc").textContent = desc;

    let rewardText = "";
    if (win) {
      const rewardSun = battle.isEndless ? battle.endlessWave * 100 : 120 + stars * 40;
      const rewardGold = battle.isEndless ? battle.endlessWave * 150 : 200 + stars * 80;
      appState.save.sun += rewardSun;
      appState.save.gold += rewardGold;
      if (!battle.isEndless && battle.campaign) {
        const prev = appState.save.stars[battle.campaign.id] || 0;
        if (stars > prev) appState.save.stars[battle.campaign.id] = stars;
        appState.save.level = Math.max(appState.save.level, 1 + Math.floor(Object.keys(appState.save.stars).length / 2));
      }
      writeSave();
      rewardText = `战利品：☀️ +${rewardSun} 阳光   🪙 +${rewardGold} 金币`;
    }
    document.getElementById("resultReward").textContent = rewardText;
    document.getElementById("btnResultNext").style.display = win && !battle.isEndless ? "inline-block" : "none";
    document.getElementById("resultModal").classList.remove("hidden");
  }

  function drawBattleScene() {
    const c = document.getElementById("gameCanvas");
    const ctx = c.getContext("2d");
    ctx.clearRect(0, 0, c.width, c.height);

    if (appState.bgs.battle) {
      ctx.drawImage(appState.bgs.battle, 0, 0, 800, 480);
    }

    // 5x7 草坪地块
    for (let r = 1; r <= ROWS; r++) {
      for (let col = 1; col <= COLS; col++) {
        const cx = cellCenterX(col);
        const cy = laneCenterY(r);
        const tileName = col <= 2 ? `battleGround${Math.min(5, r)}.png` : (r + col) % 2 === 0 ? "battleGround6.png" : "battleGround7.png";
        ctx.save();
        ctx.globalAlpha = 0.72;
        ctx.translate(cx, cy);
        ctx.scale(0.84, 0.84);
        window.atlasMgr.drawFrame(ctx, "farmMainImg", tileName, 0.5, 0.5, false);
        ctx.restore();
      }
    }

    // 悬停格子 / 进攻出兵点
    if (battle.mode === "defense" && battle.hoverCell) {
      const { row, col } = battle.hoverCell;
      const gx = GRID_LEFT + (col - 1) * CELL_W;
      const gy = GRID_TOP + (row - 1) * CELL_H;
      ctx.save();
      ctx.fillStyle = battle.shovelSelected ? "rgba(255, 80, 60, 0.35)" : "rgba(130, 255, 110, 0.25)";
      ctx.strokeStyle = battle.shovelSelected ? "#ff6b57" : "#8cff75";
      ctx.lineWidth = 2;
      ctx.fillRect(gx + 2, gy + 2, CELL_W - 4, CELL_H - 4);
      ctx.strokeRect(gx + 2, gy + 2, CELL_W - 4, CELL_H - 4);
      ctx.restore();
    } else if (battle.mode === "attack") {
      for (let r = 1; r <= ROWS; r++) {
        const cy = laneCenterY(r);
        const isHover = battle.hoverLane === r;
        ctx.save();
        ctx.translate(SPAWN_X, cy);
        ctx.scale(isHover ? 1.15 : 0.9, isHover ? 1.15 : 0.9);
        ctx.globalAlpha = isHover ? 1.0 : 0.78;
        window.atlasMgr.drawFrame(ctx, "BattleViewResImg", "battleTouchTips.png", 0.5, 0.5, false);
        ctx.restore();
      }
    }

    // 小推车 / 宝箱
    for (const car of battle.cars) {
      if (car.used) continue;
      const dir = battle.mode === "defense" ? -1 : 1;
      car.arm.draw(ctx, car.x, car.y, car.scale * dir, car.scale);
    }

    // 战斗单位（离屏染色，彻底避免方块问题！）
    const sortedUnits = [...battle.units].sort((a, b) => a.row - b.row || a.x - b.x);
    for (const u of sortedUnits) {
      let tint = null;
      if (u.hitFlash > 0) tint = "rgba(255,255,255,0.42)";
      else if (u.slowTimer > 0) tint = "rgba(80,180,255,0.34)";
      else if (u.poisonTimer > 0) tint = "rgba(85,235,85,0.32)";

      u.arm.draw(ctx, u.x, u.y, u.scale, u.scale, tint);

      if (!u.dead && u.hp < u.maxHp) {
        const bw = 40;
        const bh = 5;
        const bx = u.x - bw / 2;
        const by = u.y - 68;
        ctx.fillStyle = "rgba(0,0,0,0.7)";
        ctx.fillRect(bx - 1, by - 1, bw + 2, bh + 2);
        ctx.fillStyle = u.side === "plant" ? "#5be349" : "#ff4d3b";
        ctx.fillRect(bx, by, Math.max(0, (u.hp / u.maxHp) * bw), bh);
      }
    }

    // 闪电光束特效（替代水平长图当子弹）
    for (const bm of battle.beams) {
      ctx.save();
      ctx.globalAlpha = Math.max(0.15, bm.life / bm.maxLife);
      ctx.strokeStyle = bm.color;
      ctx.shadowColor = bm.color;
      ctx.shadowBlur = 12;
      ctx.lineWidth = 3.5;
      ctx.beginPath();
      ctx.moveTo(bm.x1, bm.y1);
      const segs = 6;
      for (let i = 1; i < segs; i++) {
        const t = i / segs;
        const jx = bm.x1 + (bm.x2 - bm.x1) * t;
        const jy = bm.y1 + (bm.y2 - bm.y1) * t + (Math.random() - 0.5) * 18;
        ctx.lineTo(jx, jy);
      }
      ctx.lineTo(bm.x2, bm.y2);
      ctx.stroke();
      ctx.strokeStyle = "#ffffff";
      ctx.lineWidth = 1.4;
      ctx.stroke();
      ctx.restore();
    }

    // 普通与抛物线子弹
    for (const b of battle.bullets) {
      ctx.save();
      ctx.translate(b.x, b.y);
      ctx.scale(0.65, 0.65);
      window.atlasMgr.drawFrame(ctx, "BattleViewResImg", b.sprite, 0.5, 0.5, false);
      ctx.restore();
    }

    // 爆炸特效
    for (const ef of battle.effects) {
      ef.arm.draw(ctx, ef.x, ef.y, ef.scale, ef.scale);
    }

    // 阳光球（使用原版 BattleViewResImg/battleSun.png 发光大太阳）
    for (const s of battle.suns) {
      ctx.save();
      ctx.translate(s.x, s.y);
      const pulse = 1.12 + Math.sin(performance.now() * 0.007 + s.id) * 0.09;
      ctx.shadowColor = "#ffe04d";
      ctx.shadowBlur = 14;
      ctx.scale(pulse, pulse);
      window.atlasMgr.drawFrame(ctx, "BattleViewResImg", "battleSun.png", 0.5, 0.5, false);
      ctx.restore();
    }

    // 飘字
    for (const ft of battle.floatTexts) {
      ctx.save();
      ctx.globalAlpha = Math.max(0, ft.life / ft.maxLife);
      ctx.font = "bold 15px sans-serif";
      ctx.textAlign = "center";
      ctx.strokeStyle = "#000";
      ctx.lineWidth = 3;
      ctx.strokeText(ft.text, ft.x, ft.y);
      ctx.fillStyle = ft.color;
      ctx.fillText(ft.text, ft.x, ft.y);
      ctx.restore();
    }

    // 戴夫头像预览（如气泡显示）
    const daveEl = document.getElementById("daveBubble");
    if (!daveEl.classList.contains("hidden") && battle.daveArm) {
      const dc = document.getElementById("daveCanvas");
      const dctx = dc.getContext("2d");
      dctx.clearRect(0, 0, dc.width, dc.height);
      battle.daveArm.draw(dctx, 42, 80, 0.42, 0.42);
    }
  }

  function battleCoords(e) {
    const c = document.getElementById("gameCanvas");
    const rect = c.getBoundingClientRect();
    return {
      x: ((e.clientX - rect.left) / rect.width) * 800,
      y: ((e.clientY - rect.top) / rect.height) * 480,
    };
  }

  function handleBattleMove(e) {
    const { x, y } = battleCoords(e);
    const col = Math.floor((x - GRID_LEFT) / CELL_W) + 1;
    const row = Math.floor((y - GRID_TOP) / CELL_H) + 1;
    battle.hoverCell = col >= 1 && col <= COLS && row >= 1 && row <= ROWS ? { row, col } : null;
    battle.hoverLane = x >= SPAWN_X - 50 && x <= SPAWN_X + 50 && row >= 1 && row <= ROWS ? row : -1;
  }

  function handleBattleClick(e) {
    if (battle.over) return;
    const { x, y } = battleCoords(e);

    // 收集阳光
    for (const s of battle.suns) {
      if (!s.collected && Math.hypot(s.x - x, s.y - y) <= 34) {
        s.collected = true;
        battle.sun += s.value;
        audio.sfx("sys_get_sun", 0.5);
        addFloatText(s.x, s.y - 14, `+${s.value}`, "#ffe258");
        updateBattleHUD();
        updateBattleCardBarState();
        return;
      }
    }

    const col = Math.floor((x - GRID_LEFT) / CELL_W) + 1;
    const row = Math.floor((y - GRID_TOP) / CELL_H) + 1;

    if (battle.mode === "defense") {
      if (col < 1 || col > COLS || row < 1 || row > ROWS) return;

      if (battle.shovelSelected) {
        const idx = battle.units.findIndex((u) => u.side === "plant" && !u.dead && u.row === row && u.col === col);
        if (idx >= 0) {
          battle.units.splice(idx, 1);
          battle.shovelSelected = false;
          audio.sfx("sys_plant_select", 0.45);
          updateShovelUI();
          addFloatText(cellCenterX(col), laneFootY(row) - 40, "已铲除", "#ff9e85");
        }
        return;
      }

      const deckItems = getBattleDeckConfigs();
      const sel = deckItems[battle.selectedDeckIndex];
      if (!sel) return;
      const cfg = sel.cfg;

      if (battle.sun < cfg.cost) {
        showBanner("阳光不足！", 900);
        return;
      }
      if ((battle.cooldowns[cfg.id] || 0) > 0) return;

      if (battle.units.some((u) => u.side === "plant" && !u.dead && u.row === row && u.col === col)) {
        showBanner("该格子已有植物", 900);
        return;
      }

      battle.sun -= cfg.cost;
      battle.cooldowns[cfg.id] = 2.8;
      audio.sfx("sys_plant_farm", 0.48);
      const unit = createBattleUnit(cfg, "plant", row, cellCenterX(col), col);
      unit.arm.play("idle", true);
      battle.units.push(unit);
      updateBattleHUD();
      updateBattleCardBarState();
    } else {
      if (row < 1 || row > ROWS || x < GRID_LEFT) return;
      const deckItems = getBattleDeckConfigs();
      const sel = deckItems[battle.selectedDeckIndex];
      if (!sel) return;
      const cfg = sel.cfg;

      if (battle.sun < cfg.cost) {
        showBanner("阳光不足！", 900);
        return;
      }
      if ((battle.cooldowns[cfg.id] || 0) > 0) return;

      battle.sun -= cfg.cost;
      battle.cooldowns[cfg.id] = 1.4;
      audio.sfx("sys_attack", 0.45);
      const z = createBattleUnit(cfg, "monster", row, SPAWN_X);
      z.arm.play("walk", true);
      battle.units.push(z);
      updateBattleHUD();
      updateBattleCardBarState();
    }
  }

  // ==================== 4. 章节关卡、图鉴、编队与祭坛抽奖弹窗 ====================
  function openLevelModal() {
    const chTabs = document.getElementById("chapterTabs");
    chTabs.innerHTML = "";
    for (const ch of appState.data.chapters) {
      const btn = document.createElement("button");
      btn.className = "ch-pill" + (appState.selectedChapter === ch.id ? " active" : "");
      btn.textContent = ch.name;
      btn.onclick = () => {
        appState.selectedChapter = ch.id;
        openLevelModal();
      };
      chTabs.appendChild(btn);
    }

    const grid = document.getElementById("levelGrid");
    grid.innerHTML = "";
    const list = appState.data.campaigns.filter(
      (c) => c.chapter === appState.selectedChapter && (appState.levelFilter === "all" || c.mode === appState.levelFilter)
    );

    for (const c of list) {
      const st = appState.save.stars[c.id] || 0;
      const item = document.createElement("div");
      item.className = "level-item" + (battle.campaign?.id === c.id ? " active" : "");
      const modeTag = c.mode === "defense" ? `<span class="tag-def">防守篇</span>` : `<span class="tag-atk">进攻篇</span>`;
      const starStr = st > 0 ? "★".repeat(st) + "☆".repeat(3 - st) : "未通关";
      item.innerHTML = `
        <div class="l-title">${c.name}</div>
        <div class="l-meta">${modeTag}<span>${starStr}</span></div>
        <div class="l-meta"><span>初始阳光 ${c.initSun}</span><span>${c.mode === "defense" ? "敌军 " + c.monsters.length : "守军 " + c.plants.length}</span></div>
      `;
      item.onclick = () => {
        document.getElementById("levelModal").classList.add("hidden");
        startBattle(c, false);
      };
      grid.appendChild(item);
    }

    document.getElementById("levelModal").classList.remove("hidden");
  }

  async function openAtlasModal(tab = appState.atlasTab) {
    appState.atlasTab = tab;
    document.querySelectorAll("[data-atlas-tab]").forEach((b) => b.classList.toggle("active", b.dataset.atlasTab === tab));

    const listEl = document.getElementById("atlasList");
    listEl.innerHTML = "";
    const families = tab === "plant" ? PLANT_FAMILIES : MONSTER_FAMILIES;
    const atlasName = tab === "plant" ? "PlantIconImg" : "MonsterIconImg";

    let firstSelect = null;
    for (const baseId of families) {
      const cfg = getActiveUnitCfg(tab, baseId);
      if (!cfg) continue;
      if (!firstSelect) firstSelect = baseId;
      const owned = tab === "plant" ? !!appState.save.plantMap[baseId] : !!appState.save.monsterMap[baseId];
      const iconName = window.atlasMgr.getFrame(atlasName, cfg.image + "S.png") ? cfg.image + "S.png" : cfg.image + "Card.png";
      const url = window.atlasMgr.getFrameDataURL(atlasName, iconName);

      const card = document.createElement("div");
      card.className = "atlas-card" + (appState.previewCfg?.baseId === baseId ? " selected" : "");
      card.innerHTML = `
        <img src="${url}" alt="${cfg.name}" style="${owned ? "" : "filter:grayscale(0.85) opacity(0.65)"}" />
        <div class="ac-name">${cfg.name}</div>
        <div class="ac-star">${owned ? `★${cfg.star}级` : "未解锁"}</div>
      `;
      card.onclick = () => selectAtlasUnit(tab, baseId);
      listEl.appendChild(card);
    }

    document.getElementById("atlasModal").classList.remove("hidden");
    if (!appState.previewCfg || appState.previewKind !== tab) {
      if (firstSelect) await selectAtlasUnit(tab, firstSelect);
    }
  }

  async function selectAtlasUnit(kind, baseId) {
    appState.previewKind = kind;
    const cfg = getActiveUnitCfg(kind, baseId);
    if (!cfg) return;
    appState.previewCfg = cfg;
    await window.armatureCache.load(cfg.image).catch(() => {});
    appState.previewArm = new window.ArmatureInstance(cfg.image);
    appState.previewArm.play(kind === "monster" ? "walk" : "idle", true);

    const owned = kind === "plant" ? !!appState.save.plantMap[baseId] : !!appState.save.monsterMap[baseId];
    document.getElementById("atlasTitle").textContent = `${cfg.name} (${cfg.star}星)`;
    document.getElementById("atlasMeta").textContent =
      `生命: ${cfg.hp} | 攻击: ${cfg.atk} | 消耗阳光: ${cfg.cost} | 射程: ${cfg.range || 1}`;
    document.getElementById("atlasDesc").textContent = cfg.desc || "经典战斗单位";

    const btnUp = document.getElementById("btnUpgradeUnit");
    if (!owned) {
      btnUp.textContent = "🔓 消耗 200 金币解锁";
      btnUp.disabled = false;
    } else if (cfg.nextId && cfg.nextId !== "0") {
      const costGold = 120 + cfg.star * 60;
      btnUp.textContent = `✨ 升至 ${cfg.star + 1} 星 (🪙 ${costGold})`;
      btnUp.disabled = false;
    } else {
      btnUp.textContent = "👑 已达最高星级";
      btnUp.disabled = true;
    }

    document.querySelectorAll("#atlasList .atlas-card").forEach((el) => {
      el.classList.toggle("selected", el.querySelector(".ac-name")?.textContent === cfg.name);
    });
  }

  function handleUpgradeUnit() {
    const cfg = appState.previewCfg;
    if (!cfg) return;
    const kind = appState.previewKind;
    const map = kind === "plant" ? appState.save.plantMap : appState.save.monsterMap;
    const owned = !!map[cfg.baseId];

    if (!owned) {
      if (appState.save.gold < 200) {
        alert("金币不足 200！可以通过通关或点击农田阳光赚取金币。");
        return;
      }
      appState.save.gold -= 200;
      map[cfg.baseId] = cfg.baseId;
      audio.sfx("sys_plant_levelup", 0.55);
    } else if (cfg.nextId && cfg.nextId !== "0") {
      const costGold = 120 + cfg.star * 60;
      if (appState.save.gold < costGold) {
        alert(`金币不足 ${costGold}！`);
        return;
      }
      appState.save.gold -= costGold;
      map[cfg.baseId] = cfg.nextId;
      audio.sfx("sys_plant_levelup", 0.55);
    }
    writeSave();
    refreshFarmUI();
    selectAtlasUnit(kind, cfg.baseId);
    openAtlasModal(kind);
    if (appState.screen === "battle") renderBattleCardBar(true);
  }

  function openDeckModal(side = appState.deckSide) {
    appState.deckSide = side;
    const isDef = side === "defense";
    document.querySelectorAll("[data-deck-side]").forEach((b) => b.classList.toggle("active", b.dataset.deckSide === side));
    document.getElementById("deckModalTitle").textContent = isDef ? "防守植物出战编队（最多 8 张）" : "进攻僵尸出战编队（最多 8 张）";

    const pool = document.getElementById("deckPool");
    pool.innerHTML = "";
    const families = isDef ? PLANT_FAMILIES : MONSTER_FAMILIES;
    const deck = isDef ? appState.save.plantDeck : appState.save.monsterDeck;
    const atlasName = isDef ? "PlantIconImg" : "MonsterIconImg";

    for (const baseId of families) {
      const owned = isDef ? !!appState.save.plantMap[baseId] : !!appState.save.monsterMap[baseId];
      if (!owned) continue;
      const cfg = getActiveUnitCfg(isDef ? "plant" : "monster", baseId);
      if (!cfg) continue;
      const inDeck = deck.includes(baseId);
      const iconName = window.atlasMgr.getFrame(atlasName, cfg.image + "S.png") ? cfg.image + "S.png" : cfg.image + "Card.png";
      const iconUrl = window.atlasMgr.getFrameDataURL(atlasName, iconName);

      const item = document.createElement("div");
      item.className = "deck-item" + (inDeck ? " in-deck" : "");
      item.innerHTML = `
        <img src="${iconUrl}" alt="${cfg.name}" />
        <div>
          <div class="d-name">${cfg.name} ★${cfg.star} ${inDeck ? "✓" : ""}</div>
          <div class="d-stats">阳光 ${cfg.cost} · HP ${cfg.hp} · 攻 ${cfg.atk}</div>
        </div>
      `;
      item.onclick = () => {
        const idx = deck.indexOf(baseId);
        if (idx >= 0) {
          if (deck.length > 1) deck.splice(idx, 1);
        } else if (deck.length < 8) {
          deck.push(baseId);
        }
        writeSave();
        openDeckModal(side);
        if (appState.screen === "battle") renderBattleCardBar(true);
      };
      pool.appendChild(item);
    }
    document.getElementById("deckModal").classList.remove("hidden");
  }

  function openLotteryModal() {
    document.getElementById("lotteryResultText").textContent = "花费 100 阳光或 150 金币召唤强力伙伴！（重复抽取自动升星）";
    appState.lotteryArm = null;
    document.getElementById("lotteryModal").classList.remove("hidden");
  }

  async function doLottery(currency) {
    if (currency === "sun") {
      if (appState.save.sun < 100) return alert("阳光不足 100！");
      appState.save.sun -= 100;
    } else {
      if (appState.save.gold < 150) return alert("金币不足 150！");
      appState.save.gold -= 150;
    }
    audio.sfx("sys_use_chests", 0.55);

    const isPlant = Math.random() < 0.6;
    const pool = isPlant ? PLANT_FAMILIES : MONSTER_FAMILIES;
    const baseId = pool[Math.floor(Math.random() * pool.length)];
    const map = isPlant ? appState.save.plantMap : appState.save.monsterMap;

    let msg = "";
    if (!map[baseId]) {
      map[baseId] = baseId;
      const cfg = getActiveUnitCfg(isPlant ? "plant" : "monster", baseId);
      msg = `🎉 恭喜解锁新伙伴：【${cfg.name}】(${isPlant ? "植物" : "僵尸"})！`;
    } else {
      const cur = getActiveUnitCfg(isPlant ? "plant" : "monster", baseId);
      if (cur.nextId && cur.nextId !== "0") {
        map[baseId] = cur.nextId;
        const nextCfg = getActiveUnitCfg(isPlant ? "plant" : "monster", baseId);
        msg = `🌟 抽中【${cur.name}】，自动升星至 ★${nextCfg.star}！`;
      } else {
        appState.save.gold += 100;
        msg = `✨ 抽中满星【${cur.name}】，转化为 🪙 +100 金币！`;
      }
    }

    writeSave();
    refreshFarmUI();
    const finalCfg = getActiveUnitCfg(isPlant ? "plant" : "monster", baseId);
    await window.armatureCache.load(finalCfg.image).catch(() => {});
    appState.lotteryArm = new window.ArmatureInstance(finalCfg.image);
    appState.lotteryArm.play(isPlant ? "idle" : "walk", true);
    document.getElementById("lotteryResultText").textContent = msg;
  }

  // ==================== 5. 主循环与事件绑定 ====================
  function drawStaticBattleIcons() {
    const sunCanvas = document.getElementById("sunIconCanvas");
    const sctx = sunCanvas.getContext("2d");
    sctx.translate(16, 16);
    sctx.scale(0.9, 0.9);
    window.atlasMgr.drawFrame(sctx, "BattleViewResImg", "battleSun.png", 0.5, 0.5, false);

    const shCanvas = document.getElementById("shovelCanvas");
    const shctx = shCanvas.getContext("2d");
    shctx.translate(17, 17);
    shctx.scale(0.62, 0.62);
    window.atlasMgr.drawFrame(shctx, "BattleViewResImg", "shovelButton.png", 0.5, 0.5, false);
  }

  function syncAudioButtons() {
    const label = audio.muted ? "🔇 音乐: 关" : "🎵 音乐: 开";
    document.getElementById("btnLoginAudio").textContent = label;
    document.getElementById("btnFarmBgm").textContent = audio.muted ? "🔇 静音" : "🎵 音乐";
    document.getElementById("btnMute").textContent = audio.muted ? "🔇" : "🔊";
  }

  async function init() {
    const loadImg = (src) =>
      new Promise((res) => {
        const i = new Image();
        i.onload = () => res(i);
        i.onerror = () => res(null);
        i.src = src;
      });

    const [gdRes, battleBg, loginBg, farmBg] = await Promise.all([
      fetch("data/game_data.json").then((r) => r.json()),
      loadImg("assets/battleImage.jpg"),
      loadImg("assets/loginBg.jpg"),
      loadImg("assets/farmBg1.jpg"),
      window.atlasMgr.loadAtlasData().then(() =>
        Promise.all([
          window.atlasMgr.loadImage("BattleViewResImg"),
          window.atlasMgr.loadImage("PlantIconImg"),
          window.atlasMgr.loadImage("MonsterIconImg"),
          window.atlasMgr.loadImage("farmMainImg"),
          window.atlasMgr.loadImage("myinfo"),
        ])
      ),
    ]);

    appState.data = gdRes;
    appState.bgs = { battle: battleBg, login: loginBg, farm: farmBg };

    drawStaticBattleIcons();
    await Promise.all([initLoginScene(), initFarmScene()]);

    // 解锁浏览器音频策略
    const unlockHandler = () => audio.unlock();
    window.addEventListener("pointerdown", unlockHandler, { once: true });
    window.addEventListener("keydown", unlockHandler, { once: true });

    // 登录页按钮
    document.getElementById("btnEnterFarm").onclick = () => {
      audio.unlock();
      audio.sfx("sys_plant_select", 0.45);
      showScreen("farm");
    };
    document.getElementById("btnQuickBattle").onclick = () => {
      audio.unlock();
      audio.sfx("sys_attack", 0.45);
      const camp = appState.data.campaigns.find((c) => c.id === "10201") || appState.data.campaigns[0];
      startBattle(camp, false);
    };
    document.getElementById("btnLoginAudio").onclick = () => {
      audio.unlock();
      audio.toggleMute();
      syncAudioButtons();
    };
    document.getElementById("btnLoginFs").onclick = toggleFullscreen;

    // 农场主城按钮
    document.getElementById("farmCanvas").addEventListener("click", handleFarmClick);
    document.getElementById("btnFarmBgm").onclick = () => {
      audio.toggleMute();
      syncAudioButtons();
    };
    document.getElementById("btnFarmFs").onclick = toggleFullscreen;
    document.getElementById("btnBackLogin").onclick = () => showScreen("login");
    document.getElementById("btnDockBattle").onclick = () => openLevelModal();
    document.getElementById("btnDockEndless").onclick = () => startBattle(appState.data.campaigns[0], true);
    document.getElementById("btnDockAtlas").onclick = () => openAtlasModal("plant");
    document.getElementById("btnDockLottery").onclick = () => openLotteryModal();
    document.getElementById("btnDockDeck").onclick = () => openDeckModal("defense");

    // 战斗界面交互
    const gameCanvas = document.getElementById("gameCanvas");
    gameCanvas.addEventListener("mousemove", handleBattleMove);
    gameCanvas.addEventListener("click", handleBattleClick);

    document.getElementById("btnShovel").onclick = () => {
      battle.shovelSelected = !battle.shovelSelected;
      if (battle.shovelSelected) battle.selectedDeckIndex = -1;
      updateShovelUI();
      updateBattleCardBarState();
    };
    document.getElementById("btnSpeed").onclick = (e) => {
      battle.speedMul = battle.speedMul === 1 ? 2 : 1;
      e.target.textContent = `${battle.speedMul}x`;
    };
    document.getElementById("btnMute").onclick = () => {
      audio.toggleMute();
      syncAudioButtons();
    };
    document.getElementById("btnBattleFs").onclick = toggleFullscreen;
    document.getElementById("btnBattleDeck").onclick = () => openDeckModal(battle.mode);
    document.getElementById("btnBattleLevels").onclick = () => openLevelModal();
    document.getElementById("btnRestart").onclick = () => startBattle(battle.campaign, battle.isEndless);
    document.getElementById("btnRetreat").onclick = () => showScreen("farm");

    // 弹窗按钮
    document.querySelectorAll("[data-close]").forEach((btn) => {
      btn.onclick = () => document.getElementById(btn.dataset.close).classList.add("hidden");
    });
    document.querySelectorAll("[data-filter]").forEach((btn) => {
      btn.onclick = () => {
        document.querySelectorAll("[data-filter]").forEach((b) => b.classList.remove("active"));
        btn.classList.add("active");
        appState.levelFilter = btn.dataset.filter;
        openLevelModal();
      };
    });
    document.querySelectorAll("[data-atlas-tab]").forEach((btn) => {
      btn.onclick = () => openAtlasModal(btn.dataset.atlasTab);
    });
    document.querySelectorAll("[data-anim]").forEach((btn) => {
      btn.onclick = () => {
        if (appState.previewArm) appState.previewArm.play(btn.dataset.anim, true, true);
      };
    });
    document.getElementById("btnUpgradeUnit").onclick = handleUpgradeUnit;
    document.querySelectorAll("[data-deck-side]").forEach((btn) => {
      btn.onclick = () => openDeckModal(btn.dataset.deckSide);
    });
    document.getElementById("btnDeckDone").onclick = () => {
      document.getElementById("deckModal").classList.add("hidden");
      if (appState.screen === "battle" && battle.campaign) {
        preloadLevelArmatures(battle.campaign);
        renderBattleCardBar(true);
      }
    };
    document.getElementById("btnDrawSun").onclick = () => doLottery("sun");
    document.getElementById("btnDrawGold").onclick = () => doLottery("gold");

    document.getElementById("btnResultFarm").onclick = () => {
      document.getElementById("resultModal").classList.add("hidden");
      showScreen("farm");
    };
    document.getElementById("btnResultReplay").onclick = () => {
      document.getElementById("resultModal").classList.add("hidden");
      startBattle(battle.campaign, battle.isEndless);
    };
    document.getElementById("btnResultNext").onclick = () => {
      document.getElementById("resultModal").classList.add("hidden");
      const idx = appState.data.campaigns.findIndex((c) => c.id === battle.campaign.id);
      const next = appState.data.campaigns[(idx + 1) % appState.data.campaigns.length];
      startBattle(next, false);
    };

    // 支持 URL 参数直达指定界面/关卡
    const params = new URLSearchParams(window.location.search);
    const reqLevel = params.get("level");
    const reqScreen = params.get("screen");
    if (reqLevel) {
      const c = appState.data.campaigns.find((x) => x.id === reqLevel) || appState.data.campaigns[0];
      await startBattle(c, false);
    } else if (reqScreen === "farm") {
      showScreen("farm");
    } else {
      showScreen("login");
    }

    let last = performance.now();
    function loop(now) {
      const dt = Math.min(0.05, (now - last) / 1000);
      last = now;

      if (appState.screen === "login") {
        drawLoginScene(dt);
      } else if (appState.screen === "farm") {
        drawFarmScene(dt);
      } else if (appState.screen === "battle") {
        updateBattle(dt);
        drawBattleScene();
      }

      if (appState.previewArm && !document.getElementById("atlasModal").classList.contains("hidden")) {
        const pc = document.getElementById("previewCanvas");
        const pctx = pc.getContext("2d");
        pctx.clearRect(0, 0, pc.width, pc.height);
        appState.previewArm.update(dt);
        appState.previewArm.draw(pctx, 120, 175, 1.0, 1.0);
      }
      if (appState.lotteryArm && !document.getElementById("lotteryModal").classList.contains("hidden")) {
        const lc = document.getElementById("lotteryPreview");
        const lctx = lc.getContext("2d");
        lctx.clearRect(0, 0, lc.width, lc.height);
        appState.lotteryArm.update(dt);
        appState.lotteryArm.draw(lctx, 100, 145, 0.9, 0.9);
      }

      requestAnimationFrame(loop);
    }
    requestAnimationFrame(loop);
  }

  init();
})();
