import * as PIXI from "pixi.js";
import { Howl } from "howler";

type State = {
  world: {
    id: string;
    x: number;
    y: number;
    width: number;
    height: number;
    shape: "rectangle";
    color: number;
  }[];
  sound: string;
};

type Assets = { sounds: Record<string, string> };

type Hook = {
  el: HTMLDivElement;
  mounted: () => Promise<void>;
  handleEvent: {
    (name: "state", callback: (data: State) => void): void;
    (name: "assets", callback: (data: Assets) => void): void;
  };
};

export const pixi: Hook = {
  async mounted() {
    const app = new PIXI.Application({
      height: 800,
      width: 800,
      background: "#1099bb",
    });

    const sounds: Record<string, Howl> = {};

    this.el.appendChild(app.view as unknown as Element);

    const entities = new Map<string, PIXI.Graphics>();

    this.handleEvent("assets", (assets) => {
      Object.entries(assets.sounds).forEach(([key, path]) => {
        sounds[key] = new Howl({ src: [path] });
      });
    });

    this.handleEvent("state", ({ world, sound }) => {
      const entityIds = new Set(world.map(({ id }) => id));

      sound && sounds[sound].play();

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
