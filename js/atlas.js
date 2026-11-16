// Sprite atlas loader and TexturePacker / CocoStudio frame renderer

class AtlasManager {
  constructor() {
    this.atlases = {};
    this.images = {};
    this.loadingPromises = {};
    this.iconUrlCache = {};
  }

  async loadAtlasData() {
    const res = await fetch("data/atlases.json");
    this.atlases = await res.json();
  }

  loadImage(atlasName) {
    if (this.images[atlasName]) {
      return Promise.resolve(this.images[atlasName]);
    }
    if (this.loadingPromises[atlasName]) {
      return this.loadingPromises[atlasName];
    }
    const p = new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => {
        this.images[atlasName] = img;
        resolve(img);
      };
      img.onerror = (e) => reject(e);
      img.src = `assets/${atlasName}.png`;
    });
    this.loadingPromises[atlasName] = p;
    return p;
  }

  getFrame(atlasName, frameName) {
    const atlas = this.atlases[atlasName];
    if (!atlas) return null;
    return atlas[frameName] || null;
  }

  // Draw a sprite frame in standard Y-down canvas coordinates centered at (cx, cy), or with Cocos anchor (pX, pY) in Y-up
  drawFrame(ctx, atlasName, frameName, pX = 0.5, pY = 0.5, yUpParent = false) {
    const img = this.images[atlasName];
    const f = this.getFrame(atlasName, frameName);
    if (!img || !f) return;

    ctx.save();
    if (yUpParent) {
      // Parent space has Y-up; flip locally to Y-down before drawing pixels
      // Anchor offset from untrimmed center:
      // Untrimmed center is at ((0.5 - pX) * ow, (0.5 - pY) * oh) in Y-up
      const cx = (0.5 - pX) * f.ow + f.ox;
      const cy = (0.5 - pY) * f.oh + f.oy;
      ctx.translate(cx, cy);
      ctx.scale(1, -1);
    } else {
      const cx = (0.5 - pX) * f.ow + f.ox;
      const cy = (pY - 0.5) * f.oh - f.oy;
      ctx.translate(cx, cy);
    }

    if (f.rot) {
      ctx.rotate(-Math.PI / 2);
      ctx.drawImage(img, f.x, f.y, f.h, f.w, -f.h / 2, -f.w / 2, f.h, f.w);
    } else {
      ctx.drawImage(img, f.x, f.y, f.w, f.h, -f.w / 2, -f.h / 2, f.w, f.h);
    }
    ctx.restore();
  }

  // Extract a sprite frame as a cropped dataURL for HTML <img> cards / UI icons
  getFrameDataURL(atlasName, frameName) {
    const key = `${atlasName}:${frameName}`;
    if (this.iconUrlCache[key]) return this.iconUrlCache[key];

    const img = this.images[atlasName];
    const f = this.getFrame(atlasName, frameName);
    if (!img || !f) return "";

    const canvas = document.createElement("canvas");
    canvas.width = Math.max(1, f.ow);
    canvas.height = Math.max(1, f.oh);
    const ctx = canvas.getContext("2d");
    ctx.translate(canvas.width / 2, canvas.height / 2);
    if (f.rot) {
      ctx.translate(f.ox, -f.oy);
      ctx.rotate(-Math.PI / 2);
      ctx.drawImage(img, f.x, f.y, f.h, f.w, -f.h / 2, -f.w / 2, f.h, f.w);
    } else {
      ctx.translate(f.ox, -f.oy);
      ctx.drawImage(img, f.x, f.y, f.w, f.h, -f.w / 2, -f.h / 2, f.w, f.h);
    }
    const url = canvas.toDataURL();
    this.iconUrlCache[key] = url;
    return url;
  }
}

window.atlasMgr = new AtlasManager();
