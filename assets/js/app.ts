import { Socket } from 'phoenix';
import { LiveSocket } from 'phoenix_live_view';
import { pixi } from './hooks/pixi';

let csrfToken = document
  .querySelector("meta[name='csrf-token']")!
  .getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { pixi },
  params: { _csrf_token: csrfToken },
});

liveSocket.connect();

Object.defineProperty(window, "liveSocket", {
  get() {
    return liveSocket;
  },
});