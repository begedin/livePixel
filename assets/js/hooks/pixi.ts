import * as PIXI from "pixi.js";
import { Howl } from "howler";

type Config = {
  width: number;
  height: number;
  background: string;
};

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
    (name: "setup", callback: (data: Config) => void): void;
    (name: "state", callback: (data: State) => void): void;
    (name: "assets", callback: (data: Assets) => void): void;
  };
};

export const pixi: Hook = {
  async mounted() {
    let app: PIXI.Application;

    this.handleEvent("setup", ({ width, height, background }) => {
      app = new PIXI.Application({ height, width, background });
      this.el.appendChild(app.view as HTMLCanvasElement);
    });

    const sounds: Record<string, Howl> = {};

    this.handleEvent("assets", (assets) => {
      Object.entries(assets.sounds).forEach(([key, path]) => {
        sounds[key] = new Howl({ src: [path] });
      });
    });

    const entities = new Map<string, PIXI.Graphics>();

    this.handleEvent("state", ({ world, sound }) => {
      if (!app) {
        return;
      }
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
