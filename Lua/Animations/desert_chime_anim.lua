local gas = require 'gas'
local easeBezier = require 'easeBezier'
local moreCurves = require "moreCurves"

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
    chime_l = {
        x = -13,
        y = 14,
    },
    chime_r = {
        x = 7,
        y = 14,
        rotation = 90
    },
    chime_mask_l = {
        x = -12,
        y = -6,
        color = {1, 1, 1, 0}
    },
    chime_mask_r = {
        x = 8,
        y = -6,
        color = {1, 1, 1, 0}
    },
    snake_head_l = {
        x = -24,
        y = -10,
        rotation = -60
    },
    snake_head_r = {
        x = 24,
        y = -10,
        rotation = -60,
        xscale = -1
    },
    snake_tail_l = {
        x = -24,
        y = -12,
        xscale = -1,
        rotation = 22
    },
    snake_tail_r = {
        x = 27,
        y = -12,
        rotation = 22
    }
}

InitialKeyframes.mask.x = InitialKeyframes.jar.x - 1
InitialKeyframes.mask.y = InitialKeyframes.jar.y + 57
local mask_goal = {InitialKeyframes.mask.x, InitialKeyframes.mask.y}

Keyframes = {}

Sprites = {}

local curves = {}

CreateLayer("jar")
CreateLayer("snakes", "jar")
CreateLayer("mask", "snakes")

Sprites.mask = CreateSprite("mask", "mask")

Sprites.jar = CreateSprite("jar", "jar")
Sprites.jar.SetPivot(0.5, 0)

local sprite_monster = enemies[1].GetVar("monstersprite")
sprite_monster.color = {0, 0, 0, 0}
sprite_monster.MoveToAbs(InitialKeyframes.jar.x, InitialKeyframes.jar.y)

for _, d in ipairs({"l", "r"}) do
    Sprites["chime_" .. d] = CreateSprite("chime")
    Sprites["chime_" .. d].SetParent(Sprites.jar)

    Sprites["chime_mask_" .. d] = CreateSprite("chime")
    Sprites["chime_mask_" .. d].SetParent(Sprites.mask)

    Sprites["snake_head_" .. d] = CreateSprite("snake_head")
    Sprites["snake_head_" .. d].SetParent(Sprites.mask)
    Sprites["snake_head_" .. d].SetPivot(0.5, 1)

    Sprites["snake_tail_" .. d] = CreateSprite("snake_tail")
    Sprites["snake_tail_" .. d].SetParent(Sprites.jar)
    Sprites["snake_tail_" .. d].SetPivot(0.5, 1)

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
    local mod_t = t % (2 * (active + rest))
    return (math.max(0, math.min(active, active + 0.5 * rest - math.abs(active + 0.5 * rest - mod_t)))) / active, mod_t >= active + rest
end

local function shiver(duration, periods, amplitude, t)
    if t > duration then
        return 0
    end
    local scaled_t = t / duration
    return amplitude * (1 - easeBezier.ease(.25, .66, .59, 1, scaled_t)) * math.sin(2 * math.pi * scaled_t * periods)
end

local mask_move_curve = gas.curve(0, 0, 0, 0, 0, 0, 0, 0)
-- possible values: IDLE, ATTACKED, DEFENDING
SetGlobal("AnimState", "IDLE")
local attackIntensity = 0
local prev_state = GetGlobal("AnimState")
local default_state = prev_state
local anim_start = Time.time

local attacked_duration = 1.5

local function moveMaskIdle(anim_time)
    if wavespeed < 1 then
        anim_time = anim_time * wavespeed
        Keyframes.jar.x = InitialKeyframes.jar.x + math.random(-1, 1)
        Keyframes.jar.y = InitialKeyframes.jar.y + math.random(-1, 1)
        --Sprites.jar.MoveToAbs(Keyframes.jar.x, Keyframes.jar.y)
    end
    local x, desc = alternateMoveRest(anim_time, 3, 4)
    if desc then x = 1 - x end
    local mask_dist_t = easeBezier.ease(.47, .17, .42, 1.22, x)
    if desc then mask_dist_t = 1 - mask_dist_t end

    mask_goal = {Sprites.jar.absx - 1, Sprites.jar.absy + 57}
    local mask_max_dist = 60
    local mask_angle = math.rad(200)
    local mask_displacement = {mask_goal[1] + math.sin(mask_angle) * mask_max_dist, mask_goal[2] + math.cos(mask_angle) * mask_max_dist}

    mask_move_curve.movepoint(1, mask_goal[1], mask_goal[2])
    mask_move_curve.movepoint(2, mask_goal[1] - 15, mask_goal[2] - 10)
    mask_move_curve.movepoint(3, mask_displacement[1], mask_displacement[2])
    mask_move_curve.movepoint(4, mask_displacement[1] + 10, mask_displacement[2] + 15)

    local rotation_shiver = shiver(3, 6, 10 * mix(math.max(0, mask_dist_t), 1, 0.2), anim_time % 3)

    Keyframes.mask.x, Keyframes.mask.y = mask_move_curve.getpos(mask_dist_t)
    Keyframes.mask.rotation = InitialKeyframes.mask.rotation + rotation_shiver

    Keyframes.snake_head_l.rotation = InitialKeyframes.snake_head_l.rotation - 60 * mask_dist_t + 5 * math.sin(anim_time)
    Keyframes.snake_head_r.rotation = InitialKeyframes.snake_head_r.rotation - 60 * mask_dist_t + 5 * math.sin(anim_time + math.pi/2)
end

local function animateBells(anim_time)
    local offsets = {
        l = 0,
        r = math.pi / 2,
        mask_l = 0,
        mask_r = math.pi / 2
    }
    for _, d in ipairs({"l", "r", "mask_l", "mask_r"}) do
        Keyframes["chime_" .. d].rotation = InitialKeyframes["chime_" .. d].rotation + math.sin(anim_time + offsets[d]) * 30
    end
end

function Attacked(intensity)
    SetGlobal("AnimState", "ATTACKED")
    attackIntensity = intensity
    anim_start = Time.time
end

function UpdateKeyframes()
    if GetGlobal("AnimState") ~= prev_state then
        anim_start = Time.time
        prev_state = GetGlobal("AnimState")
        default_state = prev_state
    end
    local anim_time = Time.time - anim_start

    if GetGlobal("AnimState") == "DEFENDING" then
        Keyframes.mask.x = mask_goal[1]
        Keyframes.mask.y = mask_goal[2]
        Keyframes.mask.rotation = InitialKeyframes.mask.rotation

        Keyframes.snake_head_l.rotation = InitialKeyframes.snake_head_l.rotation
        Keyframes.snake_head_r.rotation = InitialKeyframes.snake_head_r.rotation
    else
        if GetGlobal("AnimState") == "IDLE" then
            moveMaskIdle(anim_time)
        elseif GetGlobal("AnimState") == "ATTACKED" then
            local movement_shiver = shiver(1, 4, attackIntensity, anim_time)
            Keyframes.mask.x = mask_goal[1] + movement_shiver
            Keyframes.mask.y = mask_goal[2]

            local rotation_shiver = shiver(2, 5, 6, anim_time)

            Keyframes.mask.rotation = InitialKeyframes.mask.rotation + rotation_shiver

            Keyframes.snake_head_l.rotation = InitialKeyframes.snake_head_l.rotation
            Keyframes.snake_head_r.rotation = InitialKeyframes.snake_head_r.rotation

            if anim_time >= attacked_duration then
                SetGlobal("AnimState", default_state)
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
    for _, d in ipairs({"l", "r"}) do
        local pos = {}
        local pos1_start = {Sprites["snake_tail_" .. d].absx, Sprites["snake_tail_" .. d].absy}
        local pos1_rotation = Sprites["snake_tail_" .. d].rotation * sign(Sprites["snake_tail_" .. d].xscale) * sign(Sprites["snake_tail_" .. d].yscale)
        local pos1_offset = Sprites["snake_tail_" .. d].height

        pos[1] = {
            pos1_start[1] + math.sin(math.rad(pos1_rotation)) * pos1_offset,
            pos1_start[2] - math.cos(math.rad(pos1_rotation)) * pos1_offset
        }

        local start_offset = 15

        pos[2] = {
            pos[1][1] + math.sin(math.rad(pos1_rotation)) * start_offset,
            pos[1][2] - math.cos(math.rad(pos1_rotation)) * start_offset
        }

        local pos3_start = {Sprites["snake_head_" .. d].absx, Sprites["snake_head_" .. d].absy}
        local pos3_rotation = Sprites["snake_head_" .. d].rotation * sign(Sprites["snake_head_" .. d].xscale) * sign(Sprites["snake_head_" .. d].yscale)
        local pos3_offset = Sprites["snake_head_" .. d].height
        pos[3] = {
            pos3_start[1] + math.sin(math.rad(pos3_rotation)) * pos3_offset,
            pos3_start[2] - math.cos(math.rad(pos3_rotation)) * pos3_offset
        }

        local end_offset = 15

        pos[4] = {
            pos[3][1] + math.sin(math.rad(pos3_rotation)) * end_offset,
            pos[3][2] - math.cos(math.rad(pos3_rotation)) * end_offset
        }

        for j = 1, 4 do
            curves[d].movepoint(j, pos[j][1], pos[j][2])
        end
    end
end