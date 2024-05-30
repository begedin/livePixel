export type Config = {
    width: number;
    height: number;
    background: string;
  };
  
export type State = {
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

  
export type Assets = { sounds: Record<string, string> };

export type Hook = {
  el: HTMLDivElement;
  mounted: () => Promise<void>;
  handleEvent: {
    (name: "setup", callback: (data: Config) => void): void;
    (name: "state", callback: (data: State) => void): void;
    (name: "assets", callback: (data: Assets) => void): void;
  };
};
