// CocoStudio 1.x ExportJson Skeletal Armature Player

class ArmatureDataCache {
  constructor() {
    this.cache = {};
    this.loading = {};
  }

  async load(name) {
    if (this.cache[name]) return this.cache[name];
    if (this.loading[name]) return this.loading[name];

    const p = (async () => {
      const [res] = await Promise.all([
        fetch(`assets/${name}.ExportJson`),
        window.atlasMgr.loadImage(name),
      ]);
      const data = await res.json();
      const arm = data.armature_data[0];
      const anim = data.animation_data[0];

      const boneMap = {};
      for (const b of arm.bone_data) {
        boneMap[b.name] = b;
      }
      const texMap = {};
      for (const t of data.texture_data || []) {
        texMap[t.name] = t;
      }
      const movMap = {};
      for (const m of anim.mov_data || []) {
        const mbMap = {};
        for (const mb of m.mov_bone_data || []) {
          mbMap[mb.name] = mb;
        }
        movMap[m.name] = {
          name: m.name,
          dr: m.dr || 1,
          sc: m.sc || 1,
          lp: m.lp !== false,
          mbMap,
        };
      }

      const parsed = { name, bones: arm.bone_data, boneMap, texMap, movMap };
      this.cache[name] = parsed;
      return parsed;
    })();

    this.loading[name] = p;
    return p;
  }
}

window.armatureCache = new ArmatureDataCache();

const IGNORED_HELPER_BONES = new Set(["sunNode", "sleepNode", "carArrow", "smokeNode"]);

class ArmatureInstance {
  constructor(name) {
    this.name = name;
    this.data = window.armatureCache.cache[name] || null;
    this.currentAnim = "idle";
    this.frame = 0;
    this.loop = true;
    this.finished = false;
    this.speedMul = 1.0;

    if (!this.data) {
      window.armatureCache.load(name).then((d) => {
        this.data = d;
        if (!d.movMap[this.currentAnim]) {
          const first = Object.keys(d.movMap)[0];
          if (first) this.currentAnim = first;
        }
      });
    } else if (!this.data.movMap[this.currentAnim]) {
      const first = Object.keys(this.data.movMap)[0];
      if (first) this.currentAnim = first;
    }
  }

  play(animName, loop = true, forceRestart = false) {
    if (!this.data) {
      this.currentAnim = animName;
      this.loop = loop;
      return;
    }
    let target = animName;
    if (!this.data.movMap[target]) {
      if (target === "dead" && this.data.movMap["death"]) target = "death";
      else if (this.data.movMap["idle"]) target = "idle";
      else target = Object.keys(this.data.movMap)[0];
    }
    if (this.currentAnim !== target || forceRestart) {
      this.currentAnim = target;
      this.frame = 0;
      this.finished = false;
    }
    this.loop = loop;
  }

  update(dtSec) {
    if (!this.data) return;
    const mov = this.data.movMap[this.currentAnim];
    if (!mov) return;
    // CocoStudio base FPS is 60 * mov.sc
    const fps = 60 * (mov.sc || 1) * this.speedMul;
    this.frame += dtSec * fps;
    if (this.frame >= mov.dr) {
      if (this.loop) {
        this.frame = this.frame % Math.max(1, mov.dr);
      } else {
        this.frame = Math.max(0, mov.dr - 0.01);
        this.finished = true;
      }
    }
  }

  _evalBoneTransform(bone, mov) {
    let x = bone.x || 0;
    let y = bone.y || 0;
    let cX = bone.cX !== undefined ? bone.cX : 1;
    let cY = bone.cY !== undefined ? bone.cY : 1;
    let kX = bone.kX || 0;
    let kY = bone.kY || 0;
    let dI = bone.dI !== undefined ? bone.dI : 0;
    let z = bone.z || 0;
    let alpha = 1;
    let additive = false;

    const mb = mov && mov.mbMap[bone.name];
    if (!mb) {
      return { x, y, cX, cY, kX, kY, dI: -1, z, alpha: 0, additive: false };
    }
    if (mb && mb.frame_data && mb.frame_data.length > 0) {
      const frames = mb.frame_data;
      const f = this.frame;

      let f0 = frames[0];
      let f1 = frames[0];
      for (let i = 0; i < frames.length; i++) {
        if (frames[i].fi <= f) {
          f0 = frames[i];
          f1 = frames[Math.min(i + 1, frames.length - 1)];
        } else {
          break;
        }
      }

      let t = 0;
      if (f0 !== f1 && f0.tweenFrame !== false && f1.fi > f0.fi) {
        t = (f - f0.fi) / (f1.fi - f0.fi);
        if (f0.twE && f0.twE !== 0) {
          // Simple ease in/out approximation if tween easing is specified
          t = f0.twE > 0 ? Math.pow(t, 1.3) : 1 - Math.pow(1 - t, 1.3);
        }
      }

      const lerp = (a, b) => a + (b - a) * t;
      x += lerp(f0.x || 0, f1.x || 0);
      y += lerp(f0.y || 0, f1.y || 0);
      cX *= lerp(f0.cX !== undefined ? f0.cX : 1, f1.cX !== undefined ? f1.cX : 1);
      cY *= lerp(f0.cY !== undefined ? f0.cY : 1, f1.cY !== undefined ? f1.cY : 1);
      kX += lerp(f0.kX || 0, f1.kX || 0);
      kY += lerp(f0.kY || 0, f1.kY || 0);
      dI = f0.dI !== undefined ? f0.dI : dI;
      if (f0.z !== undefined) z += f0.z;
      const a0 = f0.color && f0.color.a !== undefined ? f0.color.a : 255;
      const a1 = f1.color && f1.color.a !== undefined ? f1.color.a : 255;
      alpha = lerp(a0, a1) / 255;
      additive = f0.bd_dst === 1;
    }

    return { x, y, cX, cY, kX, kY, dI, z, alpha, additive };
  }

  // Exact TransformHelp::nodeToMatrix from libcocos2dlua.so
  static _nodeToMatrix(n) {
    return [
      n.cX * Math.cos(n.kY),
      n.cX * Math.sin(n.kY),
      n.cY * Math.sin(n.kX),
      n.cY * Math.cos(n.kX),
      n.x,
      n.y,
    ];
  }

  static _mul(m1, m2) {
    return [
      m1[0] * m2[0] + m1[2] * m2[1],
      m1[1] * m2[0] + m1[3] * m2[1],
      m1[0] * m2[2] + m1[2] * m2[3],
      m1[1] * m2[2] + m1[3] * m2[3],
      m1[0] * m2[4] + m1[2] * m2[5] + m1[4],
      m1[1] * m2[4] + m1[3] * m2[5] + m1[5],
    ];
  }

  draw(ctx, worldX, worldY, scaleX = 1, scaleY = 1, tint = null) {
    if (!this.data) return;
    const mov = this.data.movMap[this.currentAnim];
    const evals = {};
    const matrices = {};

    for (const b of this.data.bones) {
      evals[b.name] = this._evalBoneTransform(b, mov);
    }

    const computeMatrix = (name) => {
      if (matrices[name]) return matrices[name];
      const b = this.data.boneMap[name];
      const m = ArmatureInstance._nodeToMatrix(evals[name]);
      if (b && b.parent && this.data.boneMap[b.parent]) {
        const pm = computeMatrix(b.parent);
        matrices[name] = ArmatureInstance._mul(pm, m);
      } else {
        matrices[name] = m;
      }
      return matrices[name];
    };

    const drawList = [];
    for (const b of this.data.bones) {
      if (IGNORED_HELPER_BONES.has(b.name)) continue;
      const ev = evals[b.name];
      if (ev.dI < 0) continue;
      const dd = b.display_data && b.display_data[ev.dI];
      if (!dd || !dd.name) continue;
      // Skip tiny placeholder shadows on non-shadow bones
      if (dd.name === "影子.png" && Math.abs(ev.cX) < 0.25 && Math.abs(ev.cY) < 0.25) continue;

      const worldM = computeMatrix(b.name);
      drawList.push({ bone: b, ev, dd, worldM });
    }

    drawList.sort((a, b) => a.ev.z - b.ev.z);

    ctx.save();
    if (!tint) {
      ctx.translate(worldX, worldY);
      ctx.scale(scaleX, -scaleY);
      this._drawBones(ctx, drawList);
      ctx.restore();
      return;
    }

    // Offscreen scratch canvas prevents source-atop from bleeding onto background lawn
    if (!ArmatureInstance._tintCanvas) {
      ArmatureInstance._tintCanvas = document.createElement("canvas");
      ArmatureInstance._tintCanvas.width = 360;
      ArmatureInstance._tintCanvas.height = 360;
      ArmatureInstance._tintCtx = ArmatureInstance._tintCanvas.getContext("2d");
    }
    const tc = ArmatureInstance._tintCanvas;
    const tctx = ArmatureInstance._tintCtx;
    const ox = 180;
    const oy = 300;
    tctx.save();
    tctx.setTransform(1, 0, 0, 1, 0, 0);
    tctx.clearRect(0, 0, tc.width, tc.height);
    tctx.translate(ox, oy);
    tctx.scale(scaleX, -scaleY);
    this._drawBones(tctx, drawList);
    tctx.setTransform(1, 0, 0, 1, 0, 0);
    tctx.globalCompositeOperation = "source-atop";
    tctx.fillStyle = tint;
    tctx.fillRect(0, 0, tc.width, tc.height);
    tctx.restore();

    ctx.drawImage(tc, worldX - ox, worldY - oy);
    ctx.restore();
  }

  _drawBones(ctx, drawList) {
    for (const item of drawList) {
      const { dd, worldM, ev } = item;
      if (ev.alpha <= 0.01) continue;
      const frameName = dd.name;
      if (!window.atlasMgr.getFrame(this.name, frameName)) continue;

      const skin = dd.skin_data && dd.skin_data[0];
      let m = worldM;
      if (skin) {
        const sm = ArmatureInstance._nodeToMatrix({
          x: skin.x || 0,
          y: skin.y || 0,
          cX: skin.cX !== undefined ? skin.cX : 1,
          cY: skin.cY !== undefined ? skin.cY : 1,
          kX: skin.kX || 0,
          kY: skin.kY || 0,
        });
        m = ArmatureInstance._mul(worldM, sm);
      }

      const texName = frameName.replace(/\.png$/i, "");
      const texInfo = this.data.texMap[texName];
      const pX = texInfo && texInfo.pX !== undefined ? texInfo.pX : 0.5;
      const pY = texInfo && texInfo.pY !== undefined ? texInfo.pY : 0.5;

      ctx.save();
      ctx.globalAlpha *= ev.alpha;
      if (ev.additive) ctx.globalCompositeOperation = "lighter";
      ctx.transform(m[0], m[1], m[2], m[3], m[4], m[5]);
      window.atlasMgr.drawFrame(ctx, this.name, frameName, pX, pY, true);
      ctx.restore();
    }
  }
}

window.ArmatureInstance = ArmatureInstance;
