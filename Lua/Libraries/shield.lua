local self = {}

self.shieldHP = 0
self.maxShield = 35
self.hpOffset = 0
self.shieldColor = {1, 0.86, 0}
local expandSpr = nil
self.bar = nil

local activationTime = -1
local shieldColorAnim = self.shieldColor
local shieldPieces = {}

function self.totalHP()
    return Player.hp + self.shieldHP
end

function self.setShield(v)
    if self.shieldHP == 0 and v > 0 then
        activationTime = Time.time
    end
    v = math.max(0, math.min(self.maxShield, v))
    self.shieldHP = v

    local color = "[color:ffffff]"
    if self.shieldHP > 0 then
        color = "[color:ffdc00]"
    end
    self.bar.SetInstant(self.shieldHP/self.maxShield)

    UI.hptext.SetText(("[instant]%s%02d[color:ffffff] / %02d"):format(color,self.totalHP(), Player.maxhp))
    UI.hptext.absx = self.bar.background.absx + (self.shieldHP/self.maxShield) * self.bar.background.xscale + self.hpOffset
end

function self.spawnShards(x, y, color)
    for i = 1, 4 do
        if shieldPieces[i] then
            shieldPieces[i].Remove()
        end
        local spr = CreateSprite("spr_heart_white_shard_0", "BelowPlayer")
        spr.SetAnimation({
            "spr_heart_white_shard_0.png",
            "spr_heart_white_shard_1.png",
            "spr_heart_white_shard_2.png",
            "spr_heart_white_shard_3.png"
        })
        spr.MoveToAbs(x, y)
        spr.color = color
        spr["spd"] = {math.random(-10, 10), math.random(-10, 10)}
        spr["grav"] = -0.5

        shieldPieces[i] = spr
    end
end

function self.playerHurt(damage, invulTime, ignoreDef, playSound)
    if playSound == nil then
        playSound = true
    end

    if Player.ishurting then
        return
    end
    if self.shieldHP == 0 then
        Player.Hurt(damage, invulTime, ignoreDef, playSound)
        return
    end
    self.setShield(self.shieldHP - damage)
    Player.Hurt(0, invulTime, ignoreDef, false)

    if playSound then
        PlaySoundOnceThisFrame("snd_mirrorbreak1")
    end

    self.spawnShards(Player.absx, Player.absy, shieldColorAnim)

    if expandSpr then
        expandSpr.Remove()
    end
    expandSpr = CreateSprite("monster_soul", "BelowPlayer")
    expandSpr.SetParent(Player.sprite)
    expandSpr.alpha = 1
    expandSpr.MoveTo(0, 0)
end

-- Setup Shield Bar
UI.hpbar.background.color = {0.4, 0.4, 0.4}
UI.hpbar.fill.color = {1, 1, 1}
self.bar = CreateBar(UI.hpbar.background.absx + UI.hpbar.background.xscale, UI.hpbar.background.absy, self.maxShield, UI.hpbar.background.yscale)
self.bar.background.color = {0, 0, 0, 0}
self.bar.fill.color = self.shieldColor
self.hpOffset = UI.hptext.absx - (UI.hpbar.background.absx + UI.hpbar.background.xscale)

self.setShield(0)

_Update = Update

function Update()
    local shieldElapsedTime = Time.time - activationTime
    local shine = -0.5 * math.cos(shieldElapsedTime * 2 * math.pi / 2) + 0.5
    shine = easeBezier.ease(1, .27, .77, 1, shine)
    local playerShine = shine * 0.7
    shieldColorAnim = {Mix(1, self.shieldColor[1], playerShine), Mix(1, self.shieldColor[2], playerShine), Mix(1, self.shieldColor[3], playerShine)}

    if self.shieldHP > 0 then
        Player.sprite.color = shieldColorAnim
        --ShieldBar.fill.color = ShieldColorAnim
    else
        Player.sprite.color = {1, 1, 1}
    end

    for i = 1, 4 do
        if shieldPieces[i] and shieldPieces[i].isactive then
            shieldPieces[i]["spd"][2] = shieldPieces[i]["spd"][2] + shieldPieces[i]["grav"] * (Time.dt * 30)
            shieldPieces[i].Move(
                shieldPieces[i]["spd"][1] * Time.dt * 30,
                shieldPieces[i]["spd"][2] * Time.dt * 30
            )

            --ShieldPieces[i].color = ShieldColorAnim

            if shieldPieces[i].absy < -10 then
                shieldPieces[i].Remove()
            end
        end
    end

    if expandSpr and expandSpr.isactive then
        expandSpr.xscale = expandSpr.xscale + 0.1 * Time.dt * 30
        expandSpr.yscale = expandSpr.yscale + 0.1 * Time.dt * 30
        expandSpr.alpha = expandSpr.alpha - 0.05 * Time.dt * 30

        if expandSpr.alpha < 0 then
            expandSpr.Remove()
        end
    end

    _Update()
end

_EnteringState = EnteringState

function EnteringState(newstate, oldstate)
    if oldstate == "DEFENDING" and newstate ~= "PAUSE" and newstate ~= "DEFENDING" then
        if expandSpr and expandSpr.isactive then
            expandSpr.Remove()
        end

        for i = 1, 4 do
            if shieldPieces[i] and shieldPieces[i].isactive then
                shieldPieces[i].Remove()
            end
        end
    end
    
    _EnteringState(newstate, oldstate)
end

return self