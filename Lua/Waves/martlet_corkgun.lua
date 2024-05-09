require "waveBegin"

local yellowShot = Encounter["YellowShot"]

local shotDelay = 0.8
local guns = {}

function OnHit(bullet)
    PlayerHurt(9)
end

local function gunsUpdate()
    for _, g in ipairs(guns) do
        local gun = g["gun"]
        if g.alpha < 1 then
            g.alpha = math.min(1, g.alpha + WaveDeltaTime() / 0.5)
            gun.alpha = g.alpha
        end
    end
end

local function createGun()
    local gunParent = CreateSprite("empty", "Top")
    gunParent.SetPivot(-80, 0)
    gunParent.MoveToAbs(Arena.x, Arena.y + Arena.height/2)
    gunParent.rotation = math.random() * 360
    gunParent.alpha = 0

    local gun = CreateSprite("gun_0", "Top")
    gun.SetPivot(0, 17.5 / 21)
    gun.SetAnchor(0, 0)
    gun.Scale(2, 2)
    gun.SetParent(gunParent)
    gunParent["gun"] = gun
    gun.MoveTo(0, 0)
    gun.alpha = 0
    gun.rotation = gunParent.rotation
    if gunParent.rotation > 90 and gunParent.rotation < 270 then
        gun.yscale = -2
        gun.rotation = -gun.rotation
    end

    table.insert(guns, gunParent)
end

function Update()
    gunsUpdate()
    if WaveTime() >= shotDelay * #guns then
        createGun()
    end
end

function EndingWave()
    for i = #guns, 1, -1 do
        guns[i].Remove()
        table.remove(guns, i)
    end
end

require "waveEnd"