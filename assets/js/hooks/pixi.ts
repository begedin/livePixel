import * as PIXI from "pixi.js";

type World = {
  id: string;
  x: number;
  y: number;
  width: number;
  height: number;
  shape: "rectangle";
  color: number;
}[];

type Hook = {
  el: HTMLDivElement;
  mounted: () => void | Promise<void>;
  handleEvent: (
    name: "world",
    callback: (data: { world: World }) => void
  ) => void;
};

export const pixi: Hook = {
  async mounted() {
    const app = new PIXI.Application({
      height: 800,
      width: 800,
      background: "#1099bb",
    });

    if (app.view.style) {
      app.view.style.width = "min(100%, 100vh)";
    }

    this.el.appendChild(app.view as unknown as Element);

    const entities = new Map<string, PIXI.Graphics>();

    this.handleEvent("world", (payload) => {
      const { world } = payload;
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
