require "waveBegin"

local yellowShot = Encounter["YellowShot"]

function OnHit(bullet)
    PlayerHurt(9)
end

local mask = Encounter["DesertChimeAnimation"].sprites.mask
local maskClone = CreateProjectileAbs("desert_chime_mask", mask.absx, mask.absy)
maskClone.sprite.SetPivot(mask.xpivot, mask.ypivot)
maskClone.sprite.alpha = 0
maskClone.sprite.Scale(mask.xscale, mask.yscale)
maskClone.sprite.rotation = mask.rotation
maskClone.MoveToAbs(mask.absx, mask.absy)
maskClone["type"] = "mask"

table.insert(yellowShot.targetProjectiles, maskClone)

local hitTime = -1

function Update()
    if hitTime > 0 then
        if WaveTime() - hitTime >= 2 then
            Encounter["DesertChimeAnimation"].activateKintsugi = true
        end
        if WaveTime() - hitTime >= 4 then
            State("ENEMYDIALOGUE")
        end
    end

    if maskClone.isactive then
        maskClone.sprite.rotation = mask.rotation
        maskClone.MoveToAbs(mask.absx, mask.absy)

        if maskClone["hit"] and hitTime < 0 then
            hitTime = WaveTime()
            maskClone.Remove()
        end
    end
end

require "waveEnd"