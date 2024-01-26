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

-- from https://easings.net/#easeInOutBack
local function easeInOutBack(x)
    local c1 = 1.70158
    local c2 = c1 * 1.525

    if x < 0.5 then
        return (((2 * x) ^ 2) * ((c2 + 1) * 2 * x - c2)) / 2
    else
        return (((2 * x - 2) ^ 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
    end
end

local function easeInOutCubic(x)
    if x < 0.5 then
        return 4 * x * x * x
    else
        return 1 - ((-2 * x + 2) ^ 3) / 2
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
    return Time.time - startTime
end

InitialKeyframes = {
    jar = {
        x = 320,
        y = 320
    },
    mask = {},
    chimeL = {
        x = -13,
        y = 14,
    },
    chimeR = {
        x = 7,
        y = 14,
        rotation = 90
    },
    maskChimeL = {
        x = -12,
        y = -6,
        color = {1, 1, 1, 0}
    },
    maskChimeR = {
        x = 8,
        y = -6,
        color = {1, 1, 1, 0}
    },
    snakeHeadL = {
        x = -24,
        y = -10,
        rotation = -60
    },
    snakeHeadR = {
        x = 24,
        y = -10,
        rotation = -60,
        xscale = -1
    },
    snakeTailL = {
        x = -24,
        y = -12,
        xscale = -1,
        rotation = 22
    },
    snakeTailR = {
        x = 27,
        y = -12,
        rotation = 22
    }
}

InitialKeyframes.mask.x = InitialKeyframes.jar.x - 1
InitialKeyframes.mask.y = InitialKeyframes.jar.y + 57
local maskGoal = {InitialKeyframes.mask.x, InitialKeyframes.mask.y}

Keyframes = {}

Sprites = {}

local curves = {}

CreateLayer("jar")
CreateLayer("snakes", "jar")
CreateLayer("mask", "snakes")

Sprites.mask = CreateSprite("mask", "mask")

Sprites.jar = CreateSprite("jar", "jar")
Sprites.jar.SetPivot(0.5, 0)

local monsterSprite = enemies[1].GetVar("monstersprite")
monsterSprite.color = {0, 0, 0, 0}
monsterSprite.MoveToAbs(InitialKeyframes.jar.x, InitialKeyframes.jar.y)

for _, d in ipairs({"L", "R"}) do
    Sprites["chime" .. d] = CreateSprite("chime")
    Sprites["chime" .. d].SetParent(Sprites.jar)

    Sprites["maskChime" .. d] = CreateSprite("chime")
    Sprites["maskChime" .. d].SetParent(Sprites.mask)

    Sprites["snakeHead" .. d] = CreateSprite("snake_head")
    Sprites["snakeHead" .. d].SetParent(Sprites.mask)
    Sprites["snakeHead" .. d].SetPivot(0.5, 1)

    Sprites["snakeTail" .. d] = CreateSprite("snake_tail")
    Sprites["snakeTail" .. d].SetParent(Sprites.jar)
    Sprites["snakeTail" .. d].SetPivot(0.5, 1)

    curves[d] = gas.curve(0, 0, 0, 0, 0, 0, 0, 0)
    curves[d].show(16, {1, 1, 1}, "snakes", 8, "snake_body", true)
end

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
        Keyframes.jar.x = InitialKeyframes.jar.x + math.random(-1, 1)
        Keyframes.jar.y = InitialKeyframes.jar.y + math.random(-1, 1)
        --Sprites.jar.MoveToAbs(Keyframes.jar.x, Keyframes.jar.y)
    end
    local x, desc = alternateMoveRest(animTime, 3, 4)
    if desc then x = 1 - x end
    local maskDistT = easeBezier.ease(.47, .17, .42, 1.22, x)
    if desc then maskDistT = 1 - maskDistT end

    maskGoal = {Sprites.jar.absx - 1, Sprites.jar.absy + 57}
    local maskMaxDist = 60
    local maskAngle = math.rad(200)
    local maskDisplacement = {maskGoal[1] + math.sin(maskAngle) * maskMaxDist, maskGoal[2] + math.cos(maskAngle) * maskMaxDist}

    maskMoveCurve.movepoint(1, maskGoal[1], maskGoal[2])
    maskMoveCurve.movepoint(2, maskGoal[1] - 15, maskGoal[2] - 10)
    maskMoveCurve.movepoint(3, maskDisplacement[1], maskDisplacement[2])
    maskMoveCurve.movepoint(4, maskDisplacement[1] + 10, maskDisplacement[2] + 15)

    local rotation_shiver = shiver(3, 6, 10 * mix(math.max(0, maskDistT), 1, 0.2), animTime % 3)

    Keyframes.mask.x, Keyframes.mask.y = maskMoveCurve.getpos(maskDistT)
    Keyframes.mask.rotation = InitialKeyframes.mask.rotation + rotation_shiver

    Keyframes.snakeHeadL.rotation = InitialKeyframes.snakeHeadL.rotation - 60 * maskDistT + 5 * math.sin(animTime)
    Keyframes.snakeHeadR.rotation = InitialKeyframes.snakeHeadR.rotation - 60 * maskDistT + 5 * math.sin(animTime + math.pi/2)
end

local function animateBells(anim_time)
    local offsets = {
        chimeL = 0,
        chimeR = math.pi / 2,
        maskChimeL = 0,
        maskChimeR = math.pi / 2
    }
    for _, d in ipairs({"chimeL", "chimeR", "maskChimeL", "maskChimeR"}) do
        Keyframes[d].rotation = InitialKeyframes[d].rotation + math.sin(anim_time + offsets[d]) * 30
    end
end

function Attacked(intensity)
    SetGlobal("AnimState", "ATTACKED")
    attackIntensity = intensity
    animStart = Time.time
end

function UpdateKeyframes()
    if GetGlobal("AnimState") ~= prevState then
        animStart = Time.time
        prevState = GetGlobal("AnimState")
        defaultState = prevState
    end
    local animTime = Time.time - animStart

    if GetGlobal("AnimState") == "DEFENDING" then
        Keyframes.mask.x = maskGoal[1]
        Keyframes.mask.y = maskGoal[2]
        Keyframes.mask.rotation = InitialKeyframes.mask.rotation

        Keyframes.snakeHeadL.rotation = InitialKeyframes.snakeHeadL.rotation
        Keyframes.snakeHeadR.rotation = InitialKeyframes.snakeHeadR.rotation
    else
        if GetGlobal("AnimState") == "IDLE" then
            moveMaskIdle(animTime)
        elseif GetGlobal("AnimState") == "ATTACKED" then
            local movementShiver = shiver(1, 4, attackIntensity, animTime)
            Keyframes.mask.x = maskGoal[1] + movementShiver
            Keyframes.mask.y = maskGoal[2]

            local rotationShiver = shiver(2, 5, 6, animTime)

            Keyframes.mask.rotation = InitialKeyframes.mask.rotation + rotationShiver

            Keyframes.snakeHeadL.rotation = InitialKeyframes.snakeHeadL.rotation
            Keyframes.snakeHeadR.rotation = InitialKeyframes.snakeHeadR.rotation

            if animTime >= attackedDuration then
                SetGlobal("AnimState", defaultState)
            end
        end
    end

    animateBells(ElapsedTime())
end

function ApplyKeyframes()
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
                    spr.color[i] = easeDynamic(spr.color[i], kf.color[i], .05)
                end
            end
        end
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