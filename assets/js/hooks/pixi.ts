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
  el: HTMLElement;
  mounted: () => void | Promise<void>;
  handleEvent: (
    name: "update",
    callback: (data: { world: World }) => void
  ) => void;
};

export const pixi: Hook = {
  async mounted() {
    const app = new PIXI.Application({
      background: "#1099bb",
      resizeTo: window,
    });
    (this.el as HTMLDivElement).appendChild(app.view as unknown as Element);

    const entities = new Map<string, PIXI.Graphics>();

    this.handleEvent("update", ({ world }) => {
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
