import * as PIXI from "pixi.js";
import { Hook } from "./types";




export const pixi: Hook = {
  async mounted() {
    let app: PIXI.Application;

    this.handleEvent("setup", ({ width, height, background }) => {
      app = app || new PIXI.Application({ height, width, background });
      const canvas = app.view as HTMLCanvasElement;
      canvas.style.maxHeight = "100%";
      canvas.style.maxWidth = "100%";
      this.el.contains(canvas) || this.el.appendChild(canvas);
    });



    const entities = new Map<string, PIXI.Graphics>();

    this.handleEvent("state", ({ world, sound }) => {
      if (!app) {
        return;
      }
      const entityIds = new Set(world.map(({ id }) => id));

      entities.forEach((graphic, id) => {
        if (!entityIds.has(id)) {
          app.stage.removeChild(graphic);
          entities.delete(id);
        }
      });

      world.forEach(({ id, x, y, width, height, shape, color }) => {
        const entity = entities.get(id) || new PIXI.Graphics();
        if (!entities.has(id)) {
          entities.set(id, entity);
          app.stage.addChild(entity);
        }

        entity.clear();
        entity.beginFill(color);
        if (shape === "rectangle") {
          entity.drawRect(x * width, y * height, width, height);
        }
        entity.endFill();
      });
    });
  },
} as Hook;
