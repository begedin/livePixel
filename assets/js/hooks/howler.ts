import { Howl } from "howler";
import { Hook } from "./types";

export const howler: Hook = {
  mounted() {
    const sounds: Record<string, Howl> = {};

    this.handleEvent("assets", (assets) => {
      Object.entries(assets.sounds).forEach(([key, path]) => {
        sounds[key] = new Howl({ src: [path] });
      });
    });

    this.handleEvent("state", ({ sound }) => sound && sounds[sound].play());
  },
} as Hook;
