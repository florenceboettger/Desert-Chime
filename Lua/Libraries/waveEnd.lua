if Encounter["tp"] then
-- taken from CYK
    RotationalCollision = require "RotationalCollision"
    local lastGrazeFrame = 0
    local halfPlayerSize = Encounter["tp"].grazeHitbox.sprite.xscale / 2

    local function mix(x, y, a)
        return x * (1 - a) + y * a
    end

    _Update = Update

    function Update()
        if _Update then _Update() end
        if Encounter["tp"].active then
            GrazeUpdate()
        end
    end

    function GrazeUpdate()
        local bulletsGrazing = 0
        -- Only works if the Player is not hurting
        if not Player.ishurting then
            for i = #veryBigBulletPool, 1, -1 do
                local bullet = veryBigBulletPool[i]
                if not bullet.isactive then
                    table.remove(veryBigBulletPool, i)
                elseif not bullet["noGraze"] then
                    -- Checks if the current bullet is detected by the normal collision check
                    local grazed = false
                    local radRot = math.rad(bullet.sprite.rotation)
                    local bulletWidth = bullet.ppcollision and math.ceil(bullet.sprite.width * math.abs(math.cos(radRot)) + bullet.sprite.height * math.abs(math.sin(radRot))) or bullet.sprite.width
                    local bulletHeight = bullet.ppcollision and math.ceil(bullet.sprite.height * math.abs(math.cos(radRot)) + bullet.sprite.width * math.abs(math.sin(radRot))) or bullet.sprite.height
                    if math.abs(bullet.sprite.absx - Player.sprite.absx) < bulletWidth * bullet.sprite.xscale / 2 + halfPlayerSize and
                    math.abs(bullet.sprite.absy - Player.sprite.absy) < bulletHeight * bullet.sprite.yscale / 2 + halfPlayerSize then
                    -- Check new RotationalCollision
                        if not bullet.ppcollision or RotationalCollision.CheckCollision(bullet, Encounter["CYK"].grazeHitbox) then
                            grazed = true
                        end
                    end

                    -- Grazing!
                    if grazed then
                        bulletsGrazing = bulletsGrazing + 1
                        bullet["grazeTime"] = Time.time
                        if not bullet["TPGain"] or bullet["TPGain"] > 0 then
                            if bullet["grazed"] then
                                SuperCall(Encounter, "tp.setTP", bullet["TPGain"] and bullet["TPGain"] * 0.025 * Encounter["wavespeed"] or 0.05 * Encounter["wavespeed"], true)
                            else
                                Encounter["tp"].grazeSprite.color = {1, 1, 1}
                                Encounter["tp"].grazeSprite.alpha = 1
                                lastGrazeFrame = Time.frameCount
                                Encounter.Call("PlaySoundOnceThisFrame", "graze")
                                bullet["grazed"] = true
                                SuperCall(Encounter, "tp.setTP", bullet["TPGain"] and bullet["TPGain"] * Encounter["wavespeed"] or 2 * Encounter["wavespeed"], true)
                            end
                        end
                    -- Grazed last a second ago: reset the graze
                    elseif bullet["grazed"] and Time.time - bullet["grazeTime"] >= 1 then
                        bullet["grazed"] = false
                    end
                end
            end
        end

        -- Update the grazing sprite
        local frame = Time.frameCount - lastGrazeFrame
        if frame >= 6 and frame < 12 then
            local coeff = (frame - 5) / 6
            local target = Encounter["tp"].grazeSpriteColor
            Encounter["tp"].grazeSprite.color32 = {
                math.ceil(mix(255, target[1], coeff)),
                math.ceil(mix(255, target[2], coeff)),
                math.ceil(mix(255, target[3], coeff))
            }
        elseif frame >= 12 and frame < 18 and bulletsGrazing == 0 then
            Encounter["tp"].grazeSprite.alpha = 1 - ((frame - 11) / 12)
        elseif frame >= 12 and bulletsGrazing > 0 then
            Encounter["tp"].grazeSprite.alpha = 1
            lastGrazeFrame = Time.frameCount - 11
        elseif frame == 18 then
            Encounter["tp"].grazeSprite.alpha = 0
        end
    end
end

_EndingWave = EndingWave

function EndingWave()
    Encounter.Call("SetWavespeed", 1)
    if _EndingWave then
        _EndingWave()
    end
end