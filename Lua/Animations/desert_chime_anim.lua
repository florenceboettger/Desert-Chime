local gas = require 'gas'
local easeBezier = require 'easeBezier'
local moreCurves = require "moreCurves"

DesertChimeAnim = true

local function sign(number)
    if number > 0 then
       return 1
    elseif number < 0 then
       return -1
    else
       return 0
    end
end

local function mix(x, y, a)
    return x * (1 - a) + y * a
end

local function easeDynamic(val, target, threshold, mixTerm)
    threshold = threshold or 20
    mixTerm = mixTerm or 0.2
    if math.abs(val - target) < threshold then
        return target
    end

    return mix(val, target, mixTerm)
end

local function easeDynamicRotation(val, target, threshold, mixTerm)
    val = val % 360
    target = target % 360
    if math.abs(val + 360 - target) < math.abs(val - target) then
        return easeDynamic(val + 360, target)
    elseif math.abs(val - 360 - target) < math.abs(val - target) then
        return easeDynamic(val - 360, target)
    else
        return easeDynamic(val, target, threshold, mixTerm)
    end
end

-- from http://lua-users.org/wiki/CopyTable
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local startTime = Time.time

function ElapsedTime()
    return (Time.time - startTime) * wavespeed
end

InitialKeyframes = {
    body = {
        xscale = 2,
        yscale = 2
    },
    bodyClone = {},
    armR = {
        xscale = 2,
        yscale = 2
    },
    armThingR = {
        xscale = 2,
        yscale = 2
    },
    armThingRClone = {
        xscale = 2,
        yscale = 2
    },
    clawOuterR = {
        xscale = 2,
        yscale = 2
    },
    clawInnerR = {
        xscale = 2,
        yscale = 2
    },
    armL = {
        xscale = -2,
        yscale = 2
    },
    armThingL = {
        xscale = -2,
        yscale = 2
    },
    armThingLClone = {
        xscale = -2,
        yscale = 2
    },
    clawOuterL = {
        xscale = -2,
        yscale = 2
    },
    clawInnerL = {
        xscale = -2,
        yscale = 2
    },
    jar = {
        x = 0,
        y = 0,
        xscale = 2,
        yscale = 2
    },
    tail = {
        x = 0,
        y = 0,
        xscale = 2,
        yscale = 2
    },
    tailL = {
        xscale = 2,
        yscale = 2
    },
    tailR = {
        xscale = 2,
        yscale = 2
    },
    mask = {
        x = 0,
        y = 0,
        xscale = 2,
        yscale = 2
    },
    maskKintsugi = {
        x = 0,
        y = 0,
        xscale = 0,
        yscale = 0
    },
    chimeL = {
        x = -13,
        y = 14,
        xscale = 2,
        yscale = 2
    },
    chimeR = {
        x = 7,
        y = 14,
        xscale = 2,
        yscale = 2,
        rotation = 90
    },
    maskChimeL = {
        x = -12,
        y = -6,
        xscale = 2,
        yscale = 2,
        alpha = 0
    },
    maskChimeR = {
        x = 8,
        y = -6,
        xscale = 2,
        yscale = 2,
        alpha = 0
    },
    snakeHeadL = {
        x = -24,
        y = -10,
        rotation = -60,
        xscale = 2,
        yscale = 2
    },
    snakeHeadR = {
        x = 24,
        y = -10,
        rotation = -60,
        xscale = -2,
        yscale = 2
    },
    snakeTailL = {
        x = -24,
        y = -12,
        xscale = -2,
        yscale = 2,
        rotation = 22
    },
    snakeTailR = {
        x = 27,
        y = -12,
        xscale = 2,
        yscale = 2,
        rotation = 22
    }
}

Keyframes = {}

Sprites = {}

local curves = {}

DesertChimeSprite = CreateSprite("empty")

Sprites.body = CreateSprite("desert_chime_body")
Sprites.body.SetParent(DesertChimeSprite)
Sprites.body.Scale(2, 2)
Sprites.body.SetPivot(26 / 53, 4 / 57)
Sprites.body.alpha = 0
InitialKeyframes.body.x = Sprites.body.x
InitialKeyframes.body.y = Sprites.body.y

Sprites.tail = CreateSprite("desert_chime_tail_4")
Sprites.tail.SetParent(Sprites.body)
Sprites.tail.Scale(2, 2)
Sprites.tail.SetPivot(12 / 24, 17 / 19)
Sprites.tail.SetAnchor(27 / 53, 4 / 57)
Sprites.tail.MoveTo(0, 0)

Sprites.tailL = CreateSprite("desert_chime_tail_l")
Sprites.tailL.SetParent(Sprites.tail)
Sprites.tailL.Scale(2, 2)
Sprites.tailL.SetPivot(1, 6 / 7)
Sprites.tailL.SetAnchor(13 / 26, 2 / 19)
Sprites.tailL.MoveTo(0, 0)

Sprites.tailR = CreateSprite("desert_chime_tail_r")
Sprites.tailR.SetParent(Sprites.tail)
Sprites.tailR.Scale(2, 2)
Sprites.tailR.SetPivot(0, 6 / 7)
Sprites.tailR.SetAnchor(13 / 26, 2 / 19)
Sprites.tailR.MoveTo(0, 0)

local bottomPos = Sprites.tailR.absy - Sprites.tailR.ypivot * Sprites.tailR.height * Sprites.tailR.yscale - DesertChimeSprite.y

Sprites.bodyClone = CreateSprite("desert_chime_body")
Sprites.bodyClone.SetParent(Sprites.body)
Sprites.bodyClone.Scale(2, 2)
Sprites.bodyClone.SetPivot(26 / 53, 4 / 57)
Sprites.bodyClone.SetAnchor(26 / 53, 4 / 57)
Sprites.bodyClone.MoveTo(0, 0)

local floor = CreateSprite("desert_chime_floor")
floor.SetParent(DesertChimeSprite)
floor.Scale(2, 2)
floor.MoveTo(0, bottomPos)

for _, d in ipairs({"L", "R"}) do
    local xscale = 2
    if d == "L" then
        xscale = -2
    end

    Sprites["arm" .. d] = CreateSprite("desert_chime_arm")
    Sprites["arm" .. d].SetParent(Sprites.body)
    Sprites["arm" .. d].Scale(xscale, 2)
    Sprites["arm" .. d].SetPivot(1 / 23, 27 / 31)
    Sprites["arm" .. d].SetAnchor(47 / 53, 31 / 57)
    Sprites["arm" .. d].MoveTo(0, 0)

    Sprites["armThing" .. d] = CreateSprite("desert_chime_arm_thing")
    Sprites["armThing" .. d].SetParent(Sprites["arm" .. d])
    Sprites["armThing" .. d].Scale(xscale, 2)
    Sprites["armThing" .. d].SetPivot(8 / 17, 9 / 19)
    Sprites["armThing" .. d].SetAnchor(17 / 23, 7 / 31)
    Sprites["armThing" .. d].MoveTo(0, 0)

    Sprites["clawOuter" .. d] = CreateSprite("desert_chime_claw_outer")
    Sprites["clawOuter" .. d].SetParent(Sprites["armThing" .. d])
    Sprites["clawOuter" .. d].Scale(xscale, 2)
    Sprites["clawOuter" .. d].SetPivot(1 / 13, 4 / 14)
    Sprites["clawOuter" .. d].SetAnchor(16 / 17, 13 / 19)
    Sprites["clawOuter" .. d].MoveTo(0, 0)

    Sprites["clawInner" .. d] = CreateSprite("desert_chime_claw_inner")
    Sprites["clawInner" .. d].SetParent(Sprites["armThing" .. d])
    Sprites["clawInner" .. d].Scale(xscale, 2)
    Sprites["clawInner" .. d].SetPivot(5 / 14, 2 / 15)
    Sprites["clawInner" .. d].SetAnchor(8 / 17, 18 / 19)
    Sprites["clawInner" .. d].MoveTo(0, 0)

    Sprites["armThing" .. d .. "Clone"] = CreateSprite("desert_chime_arm_thing")
    Sprites["armThing" .. d .. "Clone"].SetParent(Sprites["armThing" .. d])
    Sprites["armThing" .. d .. "Clone"].Scale(xscale, 2)
    Sprites["armThing" .. d .. "Clone"].SetPivot(8 / 17, 10 / 19)
    Sprites["armThing" .. d .. "Clone"].SetAnchor(8 / 17, 10 / 19)
    Sprites["armThing" .. d .. "Clone"].MoveTo(0, 0)
end


Sprites.armL.SetAnchor(9 / 53, 31 / 57)
Sprites.armL.SendToBottom()

Sprites.jar = enemies[1]["monstersprite"]
Sprites.jar.SetPivot(0.5, 0)
Sprites.jar.SetParent(Sprites.body)
Sprites.jar.SetAnchor(27 / 53, 52 / 57)
Sprites.jar.MoveTo(0, 0)

Sprites.mask = CreateSprite("desert_chime_mask")
Sprites.mask.SetParent(Sprites.jar)
Sprites.mask.SetPivot(0.5, 0.5)
Sprites.mask.SetAnchor(17.5 / 36, 28.5 / 37)
Sprites.mask.MoveTo(0, 0)

Sprites.maskKintsugi = CreateSprite("desert_chime_mask_kintsugi_0")
Sprites.maskKintsugi.SetParent(Sprites.mask)
Sprites.maskKintsugi.SetPivot(0.5, 0.5)
Sprites.maskKintsugi.SetAnchor(0.5, 0.5)
Sprites.maskKintsugi.MoveTo(0, 0)
--Sprites.maskKintsugi.alpha = 0

for _, d in ipairs({"L", "R"}) do
    Sprites["chime" .. d] = CreateSprite("desert_chime_chime")
    Sprites["chime" .. d].SetParent(Sprites.jar)
    Sprites["chime" .. d].SendToBottom()

    Sprites["maskChime" .. d] = CreateSprite("desert_chime_chime")
    Sprites["maskChime" .. d].SetParent(Sprites.mask)

    Sprites["snakeHead" .. d] = CreateSprite("snake_head")
    Sprites["snakeHead" .. d].SetParent(Sprites.mask)
    Sprites["snakeHead" .. d].SetPivot(0.5, 1)

    Sprites["snakeTail" .. d] = CreateSprite("snake_tail")
    Sprites["snakeTail" .. d].SetParent(Sprites.jar)
    Sprites["snakeTail" .. d].SetPivot(0.5, 1)

    curves[d] = gas.curve(0, 0, 0, 0, 0, 0, 0, 0)
    curves[d].show(16, {1, 1, 1}, Sprites.jar, 8, "snake_body", true)
end

Sprites.mask.SendToTop()

for name, spr in pairs(Sprites) do
    local kf = InitialKeyframes[name]

    -- have to do it this way bc ["x"] etc do not work for sprites
    if kf.x then
        spr.x = kf.x
    else
        kf.x = spr.x
    end
    if kf.y then
        spr.y = kf.y
    else
        kf.y = spr.y
    end
    if kf.rotation then
        spr.rotation = kf.rotation
    else
        kf.rotation = spr.rotation
    end
    if kf.xscale then
        spr.xscale = kf.xscale
    else
        kf.xscale = spr.xscale
    end
    if kf.yscale then
        spr.yscale = kf.yscale
    else
        kf.yscale = spr.yscale
    end
    if kf.alpha then
        spr.alpha = kf.alpha
    else
        kf.alpha = spr.alpha
    end
    if kf.color then
        spr.color = kf.color
    else
        kf.color = spr.color
    end
end

Keyframes = deepcopy(InitialKeyframes)

local function alternateMoveRest(t, active, rest)
    local modT = t % (2 * (active + rest))
    return (math.max(0, math.min(active, active + 0.5 * rest - math.abs(active + 0.5 * rest - modT)))) / active, modT >= active + rest
end

local function shiver(duration, periods, amplitude, t)
    if t > duration then
        return 0
    end
    local scaled_t = t / duration
    return amplitude * (1 - easeBezier.ease(.25, .66, .59, 1, scaled_t)) * math.sin(2 * math.pi * scaled_t * periods)
end

local function triangleWave(t, period)
    return math.abs(((t/period - 0.5) % 2) - 1) * 2 - 1
end

local function sinEsqueWave(p1, p2, period, t)
    local wave = triangleWave(t, period)
    return sign(wave) * easeBezier.ease(p1, p1, p2, 1, math.abs(wave))
end

local maskMoveCurve = gas.curve(0, 0, 0, 0, 0, 0, 0, 0)
-- possible values: IDLE, ATTACKED, DEFENDING
SetGlobal("AnimState", "IDLE")
local attackIntensity = 0
local prevState = GetGlobal("AnimState")
local defaultState = prevState
local animStart = Time.time

local attackedDuration = 1.5

local function moveMaskIdle(animTime)
    if wavespeed < 1 then
        animTime = animTime * wavespeed
        Keyframes.body.x = Keyframes.body.x + math.random(-1, 1)
        Keyframes.body.y = Keyframes.body.y + math.random(-1, 1)
    end
    local x, desc = alternateMoveRest(animTime, 3, 4)
    if desc then x = 1 - x end
    local maskDistT = easeBezier.ease(.47, .17, .42, 1.22, x)
    if desc then maskDistT = 1 - maskDistT end

    local maskMaxDist = 60
    local maskAngle = math.rad(200)
    local maskDisplacement = {math.sin(maskAngle) * maskMaxDist, math.cos(maskAngle) * maskMaxDist}

    maskMoveCurve.movepoint(1, 0, 0)
    maskMoveCurve.movepoint(2, -15, -10)
    maskMoveCurve.movepoint(3, maskDisplacement[1], maskDisplacement[2])
    maskMoveCurve.movepoint(4, maskDisplacement[1] + 10, maskDisplacement[2] + 15)

    local rotationShiver = shiver(3, 4, 10 * mix(math.max(0, maskDistT), 1, 0.2), animTime % 3)

    Keyframes.mask.x, Keyframes.mask.y = maskMoveCurve.getpos(maskDistT)
    Keyframes.mask.rotation = InitialKeyframes.mask.rotation + rotationShiver

    Keyframes.snakeHeadL.rotation = InitialKeyframes.snakeHeadL.rotation - 60 * maskDistT + 5 * math.sin(animTime)
    Keyframes.snakeHeadR.rotation = InitialKeyframes.snakeHeadR.rotation - 60 * maskDistT + 5 * math.sin(animTime + math.pi/2)
end

local function animateBells(animTime)
    local offsets = {
        chimeL = 0,
        chimeR = math.pi / 2,
        maskChimeL = 0,
        maskChimeR = math.pi / 2
    }
    for _, d in ipairs({"chimeL", "chimeR", "maskChimeL", "maskChimeR"}) do
        Keyframes[d].rotation = InitialKeyframes[d].rotation + math.sin(animTime + offsets[d]) * 30
    end
end

local dustAnim = {
    [-1] = CreateSprite("desert_chime_dust_0", "BelowBullet"),
    [ 1] = CreateSprite("desert_chime_dust_0", "BelowBullet")
}
for _, d in ipairs({-1, 1}) do
    dustAnim[d].alpha = 0
    dustAnim[d].SetPivot(0, 0)
    dustAnim[d].Scale(2 * d, 2)
    dustAnim[d].SetParent(DesertChimeSprite)
end

local function animateBody(animTime)
    Keyframes.body.x = InitialKeyframes.body.x - 4 * sinEsqueWave(.3, .21, 2.5, animTime)
    local yOffset = -2 + 2 * sinEsqueWave(.15, .5, 2.0, animTime)
    Keyframes.body.y = InitialKeyframes.body.y + yOffset
    Keyframes.body.rotation = InitialKeyframes.body.rotation - 0.7 * Keyframes.body.x

    Keyframes.tail.x = InitialKeyframes.tail.x - 3 * sinEsqueWave(.15, .2, 2.0, animTime)
    Keyframes.tail.y = InitialKeyframes.tail.y - yOffset

    local tailRotPeriod = 1.0
    Keyframes.tail.rotation = InitialKeyframes.tail.rotation + 12 * sinEsqueWave(.2, .5, tailRotPeriod, animTime)

    if Keyframes.tail.rotation > 0 then
        Sprites.tailL.Set("desert_chime_tail_l_cut")
        Sprites.tailR.Set("desert_chime_tail_r")
    else
        Sprites.tailL.Set("desert_chime_tail_l")
        Sprites.tailR.Set("desert_chime_tail_r_cut")
    end

    if animTime % tailRotPeriod >= tailRotPeriod/2 * 0.75 and animTime % tailRotPeriod < tailRotPeriod/2 * 0.75 + Time.dt * wavespeed * 1.5 then
        local direction = sign(triangleWave(animTime, tailRotPeriod))
        local dust = dustAnim[sign(direction)]
        dust.alpha = 1
        dust.SetAnimation({
            "desert_chime_dust_0",
            "desert_chime_dust_1",
            "desert_chime_dust_2",
            "desert_chime_dust_3",
            "desert_chime_dust_4",
        }, 0.125)
        dust.loopmode = "ONESHOTEMPTY"

        local tailBottom = Sprites.tail.absx - DesertChimeSprite.absx + math.sin(math.rad(Keyframes.tail.rotation)) * Sprites.tail.width * Keyframes.tail.xscale * Sprites.tail.xpivot
        dust.MoveTo(tailBottom + sign(direction) * 28, bottomPos)
    end
end

local function animateArms(animTime)
    local armRotation = sinEsqueWave(.15, .45, 4, animTime)
    Keyframes.armL.rotation = InitialKeyframes.armL.rotation + 15 * armRotation
    Keyframes.armR.rotation = InitialKeyframes.armR.rotation + 15 * armRotation

    local armYScale = sinEsqueWave(.35, .5, 2, animTime)
    Keyframes.armL.yscale = InitialKeyframes.armL.yscale * (1 + 0.2 * armYScale)
    Keyframes.armR.yscale = InitialKeyframes.armR.yscale * (1 + 0.2 * armYScale)

    local x, desc = alternateMoveRest(animTime, 0.75, 4)
    if desc then x = 1 - x end
    local pinchAngle = easeBezier.ease(.8, .4, .5, 1.75, x)
    if desc then pinchAngle = 1 - pinchAngle end

    pinchAngle = pinchAngle * 16

    local armThingRotation = 10 * sinEsqueWave(.4, .4, 3, animTime)
    for _, d in ipairs({"L", "R"}) do
        Keyframes["armThing" .. d].rotation = InitialKeyframes["armThing" .. d].rotation + armThingRotation
        Keyframes["clawOuter" .. d].rotation = InitialKeyframes["clawOuter" .. d].rotation + armThingRotation + pinchAngle
        Keyframes["clawInner" .. d].rotation = InitialKeyframes["clawInner" .. d].rotation + armThingRotation - pinchAngle
    end
end

local sandSpeed = 40
local sandHeight = 16
local sandEmitData = {
    bodyR = {
        parent = Sprites.body,
        anchor = {x = 40.5 / 53, y = 5 / 57},
        pile = true,
    },
    bodyL = {
        parent = Sprites.body,
        anchor = {x = 12.5 / 53, y = 5 / 57},
        pile = true,
    },
    armR = {
        parent = Sprites.armThingR,
        anchor = {x = 9.5 / 17, y = 3 / 19},
        pile = false,
        vanishHeight = 15,
        vanishDistance = 15,
    },
    armL = {
        parent = Sprites.armThingL,
        anchor = {x = 9.5 / 17, y = 3 / 19},
        pile = false,
        vanishHeight = 15,
        vanishDistance = 15,
    },
    jar = {
        parent = Sprites.jar,
        anchor = {x = 29.5 / 36, y = 10 / 36},
        pile = false,
        vanishHeight = 140,
        vanishDistance = 10,
    }
}

local sandSprites = CreateSprite("empty")
sandSprites.SetParent(DesertChimeSprite)
sandSprites.MoveTo(0, 0)
sandSprites.SendToBottom()

local function generateSand(v)
    local spr = CreateSprite("sand_fg")
    spr.Scale(2, sandHeight)
    spr.SetPivot(0.5, 1)
    spr.SetAnchor(v.anchor.x, v.anchor.y)
    spr.SetParent(v.parent)
    spr.MoveTo(0, sandHeight)
    table.insert(v.sands, spr)

    local coverSprite = CreateSprite("px")
    coverSprite.color = {0, 0, 0}
    coverSprite.Scale(2, 2)
    coverSprite.SetPivot(0.5, 1)
    local anchorY = math.random(1, (sandHeight / 2)) / (sandHeight / 2)
    coverSprite.SetAnchor(0.5, anchorY)
    coverSprite.SetParent(spr)
    coverSprite.MoveTo(0, 0)
    spr["cover"] = coverSprite

    if v.vanishHeight then
        pcall(spr.shader.Set, "fadeout", "FadeOut")
        if spr.shader.isActive then
            spr.shader.SetFloat("height0", spr.y - sandHeight)
            spr.shader.SetFloat("height1", spr.y)
            spr.shader.SetFloat("cutoffHeight", v.vanishHeight + bottomPos)
            spr.shader.SetFloat("cutoffDistance", v.vanishDistance)
        end
    end

    return spr
end

DesertChimeSprite.y = 276

for _, v in pairs(sandEmitData) do
    v.sands = {}
    local spr = generateSand(v)
    spr.SetParent(sandSprites)

    if v.pile then
        local pileSprite = CreateSprite("sand_pile_new_0")
        pileSprite.SetAnimation({
            "sand_pile_new_0",
            "sand_pile_new_1",
            "sand_pile_new_2",
            "sand_pile_new_3",
            "sand_pile_new_4",
            "sand_pile_new_5",
        }, 6 / sandSpeed)
        pileSprite.Scale(2, 2)
        pileSprite.SetPivot(0.5, 0)
        pileSprite.SetAnchor(v.anchor.x, v.anchor.y)
        pileSprite.SetParent(v.parent)
        pileSprite.MoveTo(0, 0)
        pileSprite.SetParent(sandSprites)
        pileSprite.y = bottomPos
        pileSprite.SendToBottom()
        v.pileSprite = pileSprite

        local pileSpriteBG = CreateSprite("sand_pile_bg_new_0")
        pileSpriteBG.SetAnimation({
            "sand_pile_bg_new_0",
            "sand_pile_bg_new_1",
            "sand_pile_bg_new_2",
            "sand_pile_bg_new_3",
            "sand_pile_bg_new_4",
            "sand_pile_bg_new_5",
        }, 6 / sandSpeed)
        pileSpriteBG.Scale(2, 2)
        pileSpriteBG.SetPivot(0.5, 0)
        pileSpriteBG.MoveToAbs(pileSprite.absx, pileSprite.absy)
        pileSpriteBG.SetParent(sandSprites)
        pileSpriteBG.SendToBottom()
        v.pileSpriteBG = pileSpriteBG
    end
end

local function animateSand(animTime)

    for _, v in pairs(sandEmitData) do
        for i = #v.sands, 1, -1 do
            local spr = v.sands[i]
            if spr.isactive then
                if spr.alpha > 0 then
                    spr.Move(0, -sandSpeed * Time.dt * wavespeed)
                    spr.x = 2 * math.floor(spr.x / 2 + 0.5)
                    if spr.shader.isActive then
                        spr.shader.SetFloat("height0", spr.y - sandHeight)
                        spr.shader.SetFloat("height1", spr.y)
                        if spr.y - spr.absy + spr["cover"].absy < v.vanishHeight + bottomPos then
                            spr["cover"].alpha = 0
                        end
                    end
                    if spr.y < bottomPos + 2 then
                        spr.Remove()
                        table.remove(v.sands, i)
                    elseif spr.y < bottomPos + 2 + sandHeight then
                        spr.yscale = spr.y - (bottomPos + 2)
                    end
                end
            else
                table.remove(v.sands, i)
            end
        end

        local createSand = false
        if #v.sands <= 1 then
            createSand = true
        else
            local topSand = v.sands[#v.sands - 1]
            local newSand = v.sands[#v.sands]

            if newSand.absy - topSand.absy > topSand.height * topSand.yscale then
                newSand.SetParent(sandSprites)
                newSand.rotation = 0
                newSand.alpha = 1
                newSand["cover"].alpha = 1
                newSand.absy = topSand.absy + topSand.height * topSand.yscale
                createSand = true
            end
        end
        if createSand then
            local spr = generateSand(v)
            spr.alpha = 0
            spr["cover"].alpha = 0

            if v.pileSprite then v.pileSprite.SendToTop() end
        end
    end
end

function Attacked(intensity)
    SetGlobal("AnimState", "ATTACKED")
    attackIntensity = intensity
    animStart = Time.time
end

function UpdateKeyframes()
    animateBells(ElapsedTime())
    animateBody(ElapsedTime())
    animateArms(ElapsedTime())
    animateSand(ElapsedTime())

    if GetGlobal("AnimState") ~= prevState then
        animStart = Time.time
        prevState = GetGlobal("AnimState")
        defaultState = prevState
    end
    local animTime = Time.time - animStart

    if GetGlobal("AnimState") == "DEFENDING" then
        Keyframes.mask.x = 0
        Keyframes.mask.y = 0
        Keyframes.mask.rotation = InitialKeyframes.mask.rotation

        Keyframes.snakeHeadL.rotation = InitialKeyframes.snakeHeadL.rotation
        Keyframes.snakeHeadR.rotation = InitialKeyframes.snakeHeadR.rotation
    else
        if GetGlobal("AnimState") == "IDLE" then
            moveMaskIdle(animTime)
        elseif GetGlobal("AnimState") == "ATTACKED" then
            local movementShiver = shiver(1, 4, attackIntensity, animTime)
            Keyframes.mask.x = movementShiver
            Keyframes.mask.y = 0

            local rotationShiver = shiver(2, 5, 6, animTime)

            Keyframes.mask.rotation = InitialKeyframes.mask.rotation + rotationShiver

            Keyframes.snakeHeadL.rotation = InitialKeyframes.snakeHeadL.rotation
            Keyframes.snakeHeadR.rotation = InitialKeyframes.snakeHeadR.rotation

            if animTime >= attackedDuration then
                SetGlobal("AnimState", defaultState)
            end
        end
    end
end

function ApplyKeyframes()
    for _, attr in ipairs({"xscale", "yscale", "rotation"}) do
        Keyframes.bodyClone[attr] = Keyframes.body[attr]
        Keyframes.armThingLClone[attr] = Keyframes.armThingL[attr]
        Keyframes.armThingRClone[attr] = Keyframes.armThingR[attr]
    end
    for name, spr in pairs(Sprites) do
        local kf = Keyframes[name]

        if kf.x then
            spr.x = easeDynamic(spr.x, kf.x, 20)
        end
        if kf.y then
            spr.y = easeDynamic(spr.y, kf.y, 20)
        end
        if kf.rotation then
            spr.rotation = easeDynamicRotation(spr.rotation, kf.rotation, 10)
        end
        if kf.xscale then
            spr.xscale = easeDynamic(spr.xscale, kf.xscale, .05)
        end
        if kf.yscale then
            spr.yscale = easeDynamic(spr.yscale, kf.yscale, .05)
        end
        if kf.color then
            for i = 1, 4 do
                if spr.color[i] then
                    spr.color[i] = easeDynamic(spr.color[i], kf.color[i], .2)
                end
            end
        end
        if kf.alpha then
            spr.alpha = easeDynamic(spr.alpha, kf.alpha, .2)
        end
    end

    for _, d in ipairs({"L", "R"}) do
        Sprites["tail" .. d].absy = DesertChimeSprite.y + bottomPos + Sprites.tailR.ypivot * Sprites.tailR.height * Sprites.tailR.yscale
    end

    if enemies[1] ~= nil and enemies[1]["bubblesprite"] ~= nil then
        enemies[1]["bubblesprite"].rotation = 0
    end
end

function UpdateSplines()
    for _, d in ipairs({"L", "R"}) do
        local pos = {}
        local pos1Start = {Sprites["snakeTail" .. d].absx, Sprites["snakeTail" .. d].absy}
        local pos1Rotation = Sprites["snakeTail" .. d].rotation * sign(Sprites["snakeTail" .. d].xscale) * sign(Sprites["snakeTail" .. d].yscale)
        local pos1Offset = Sprites["snakeTail" .. d].height

        pos[1] = {
            pos1Start[1] + math.sin(math.rad(pos1Rotation)) * pos1Offset,
            pos1Start[2] - math.cos(math.rad(pos1Rotation)) * pos1Offset
        }

        local startOffset = 15

        pos[2] = {
            pos[1][1] + math.sin(math.rad(pos1Rotation)) * startOffset,
            pos[1][2] - math.cos(math.rad(pos1Rotation)) * startOffset
        }

        local pos3Start = {Sprites["snakeHead" .. d].absx, Sprites["snakeHead" .. d].absy}
        local pos3Rotation = Sprites["snakeHead" .. d].rotation * sign(Sprites["snakeHead" .. d].xscale) * sign(Sprites["snakeHead" .. d].yscale)
        local pos3Offset = Sprites["snakeHead" .. d].height
        pos[3] = {
            pos3Start[1] + math.sin(math.rad(pos3Rotation)) * pos3Offset,
            pos3Start[2] - math.cos(math.rad(pos3Rotation)) * pos3Offset
        }

        local endOffset = 15

        pos[4] = {
            pos[3][1] + math.sin(math.rad(pos3Rotation)) * endOffset,
            pos[3][2] - math.cos(math.rad(pos3Rotation)) * endOffset
        }

        for j = 1, 4 do
            curves[d].movepoint(j, pos[j][1], pos[j][2])
        end
    end
end

PreChimeUpdate = Update

function Update()
    if PreChimeUpdate then
        PreChimeUpdate()
    end
    if DesertChimeAnim then
        UpdateKeyframes()
        ApplyKeyframes()
        UpdateSplines()
    end
end