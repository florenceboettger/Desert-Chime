local self = {}

self.active = true

self.stencil = CreateSprite("sandstorm_stencil", "BelowUI")
self.stencil.Scale(2, 2)
self.stencil.x = 0
self.stencil.Mask("stencil")

self.stencilFG = CreateSprite("sandstorm_stencil", "BelowArena")
self.stencilFG.Scale(2, 2)
self.stencilFG.Mask("stencil")

self.sandstormBG = CreateSprite("sandstorm_bg")
self.sandstormBG.Scale(2, 2)
self.sandstormBG.SetPivot(0.5, 0.5)
self.sandstormBG.SetParent(self.stencil)
self.sandstormBG.alpha = 0.5

self.sandstormFG = CreateSprite("sandstorm_fg")
self.sandstormFG.Scale(2, 2)
self.sandstormFG.SetPivot(0.5, 0.5)
self.sandstormFG.SetParent(self.stencilFG)
self.sandstormFG.alpha = 0.5

function self.update()
    self.stencil.Move(10 * Time.dt, 0)
    self.stencil.x = self.stencil.x % 640
    self.stencilFG.x = self.stencil.x

    self.sandstormBG.absx = (self.sandstormBG.absx + 300 * Time.dt) % 640
    self.sandstormBG.absy = 240 + 30 * math.sin(Time.time / 5 * 2 * math.pi)

    self.sandstormFG.absx = (self.sandstormFG.absx + 320 * Time.dt) % 640
    self.sandstormFG.absy = 240 + 25 * math.sin(Time.time / 5 * 2 * math.pi)
end

return self