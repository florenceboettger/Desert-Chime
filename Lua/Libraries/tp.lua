local self = {}

self.tp = 0
self.maxTP = 100
self.tpBar = nil
self.tpLabel = nil
self.tpText = nil

self.grazeSprite = nil
self.grazeSpriteColor = {164, 118, 118}
self.grazeHitbox = nil

function self.setTP(v, rel, lerp)
    if rel == nil then
        rel = false
    end
    if lerp == nil then
        lerp = false
    end
    if rel then
        v = v + self.tp
    end
    self.tp = math.max(0, math.min(self.maxTP, v))

    if self.tp < 100 then
        self.tpText.SetText(("[font:uibattlesmall][instant]%02d%%"):format(self.tp))
    else
        self.tpText.SetText("[font:uibattlesmall][instant][color:ffff00]MAX")
    end
    if lerp then
        self.tpBar.SetLerp(self.tp/self.maxTP, 8)
    else
        self.tpBar.SetInstant(self.tp/self.maxTP)
    end
end

function self.Activate()
    self.active = true
end

function self.Deactivate()
    self.active = false
    self.tpBar.background.alpha = 0
    self.tpBar.fill.alpha = 0
    self.tpText.alpha = 0
    self.tpLabel.alpha = 0
    self.tp = 0
end

local labelBarDiff = UI.hpbar.background.absx - (UI.hplabel.absx + UI.hplabel.width)

self.active = true

-- Setup TP Bar
self.tpLabel = CreateSprite("TP", "BelowUI")
self.tpLabel.SetPivot(0, 0)
-- Hardcoded from right side of screen
self.tpLabel.MoveToAbs(472, UI.hplabel.absy)

self.tpBar = CreateBar(self.tpLabel.absx + self.tpLabel.width + labelBarDiff, UI.hpbar.background.absy, self.maxTP / 2, UI.hpbar.background.yscale)
self.tpBar.background.color = {0.5, 0, 0}
self.tpBar.fill.color = {1, 0.5, 0.15}

self.tpText = CreateText("[font:uibattlesmall][instant]00%", {self.tpBar.background.absx + self.tpBar.background.xscale + shield.hpOffset, UI.hptext.absy}, 999, "BelowUI")
self.tpText.HideBubble()
self.tpText.color = {1, 1, 1}
self.tpText.progressmode = "none"

self.grazeSprite = CreateSprite("playerGraze")
self.grazeSprite.SetParent(Player.sprite)
self.grazeSprite.alpha = 0
self.grazeSprite.x = 0
self.grazeSprite.y = 0

self.grazeHitbox = CreateSprite("px")
self.grazeHitbox.SetParent(Player.sprite)
self.grazeHitbox.Scale(40, 40)
self.grazeHitbox.alpha = 0
self.grazeHitbox.x = 0
self.grazeHitbox.y = 0
self.grazeHitbox = { sprite = self.grazeHitbox }

self.setTP(0)

__Update = Update

function Update()
    if self.active and self.tpLabel.alpha < 1 then
        local alpha = math.min(1, self.tpLabel.alpha + 4 * Time.dt)
        self.tpBar.background.alpha = alpha
        self.tpBar.fill.alpha = alpha
        self.tpText.alpha = alpha
        self.tpLabel.alpha = alpha
        -- necessary to reset the color for MAX
        self.setTP(self.tp)
    end
    if __Update then
        __Update()
    end
end

__EnteringState = EnteringState

function EnteringState(newstate, oldstate)
    if oldstate == "DEFENDING" and newstate ~= "PAUSE" and newstate ~= "DEFENDING" then
        self.grazeSprite.alpha = 0
    end

    if __EnteringState then
        __EnteringState(newstate, oldstate)
    end
end

return self