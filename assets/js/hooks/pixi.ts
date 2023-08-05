import * as PIXI from 'pixi.js'

type World = { id: string, x: number, y: number, shape: 'rectangle', color: number }[]

type Hook = {
  el: HTMLElement,
  mounted: () => void | Promise<void>,
  handleEvent: (name: 'update', callback: (data: { world: World }) => void) => void
}

export const pixi: Hook = {
  async mounted() {
    const app = new PIXI.Application({ background: '#1099bb', resizeTo: window });
    (this.el as HTMLDivElement).appendChild(app.view as unknown as Element);

    const entities = new Map<string, PIXI.Graphics>()


    this.handleEvent('update', ({ world }) => {
      world.forEach(({ id, x, y, shape, color }) => {
        const entity = entities.get(id) || new PIXI.Graphics()
        if (!entities.has(id)) {
          entities.set(id, entity)
          app.stage.addChild(entity)
        }

        entity.clear()
        entity.beginFill(color)
        entity.drawRect(x * 20, y * 20, 20, 20)
        entity.endFill()
      })
    })
  }
} as Hook