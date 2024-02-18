require "waveBegin"
local easeBezier = require "easeBezier"

local spawntimer = 0
local bullets = {}
local yOffset = 180
local mult = 0.5
local lastTime = 0.49

local movingArena = true
local moveTime = 1

local startTime = Time.time
local startArena = {x = Arena.x, y = Arena.y}
local endArena = {x = Arena.x - 150, y = Arena.y}

local monsterSprite = Encounter["DesertChimeSprite"]

local startMonster = {x = monsterSprite.x, y = monsterSprite.y}
local endMonster = {x = startMonster.x + 150, y = startMonster.y - 150}

function OnHit(bullet)
    PlayerHurt(9)
end

function Mix(x, y, a)
    return x * (1 - a) + y * a
end

function Update()
    --if movingArena and Time.time - startTime <= moveTime then
    --    Player.SetControlOverride(true)
    --    if Encounter["yellowShot"] then
    --        Encounter["yellowShot"].lock = true
    --    end
    --    local interp = easeBezier.ease(.28, .28, .57, 1, (Time.time - startTime) / moveTime)
    --    Arena.MoveTo(
    --        Mix(startArena.x, endArena.x, interp),
    --        Mix(startArena.y, endArena.y, interp),
    --        true, true)
    --    monsterSprite.MoveTo(
    --        Mix(startMonster.x, endMonster.x, interp),
    --        Mix(startMonster.y, endMonster.y, interp)
    --    )
    --else
    --    Player.SetControlOverride(false)
    --    if Encounter["yellowShot"] then
    --        Encounter["yellowShot"].lock = false
    --    end
    --    movingArena = false
    --    Arena.MoveTo(endArena.x, endArena.y, true, true)
    --    monsterSprite.MoveTo(endMonster.x, endMonster.y)
    --end

    spawntimer = spawntimer + 1
    if(WaveTime() % 0.5 < lastTime % 0.5) then
        local numbullets = 10
        for i=1,numbullets+1 do
            local bullet = CreateProjectile('bullet', 0, yOffset)
            bullet.SetVar('timer', 0)
            bullet.SetVar('offset', math.pi * 2 * i / numbullets)
            bullet.SetVar('negmult', mult)
            bullet.SetVar('lerp', 0)
            table.insert(bullets, bullet)
        end
        mult = mult + 0.05
    end

    for i=1,#bullets do
        local bullet = bullets[i]
        local timer = bullet.GetVar('timer')
        local offset = bullet.GetVar('offset')
        local lerp = bullet.GetVar('lerp')
        local neg = 1
        local posx = (70*lerp)*math.sin(timer*bullet.GetVar('negmult') + offset)
        local posy = (70*lerp)*math.cos(timer + offset) + yOffset - lerp*50
        bullet.MoveTo(posx, posy)
        bullet.SetVar('timer', timer + 1/40 * (60 * WaveDeltaTime()))
        lerp = lerp + 1 / 90 * (60 * WaveDeltaTime())
        if lerp > 4.0 then
            lerp = 4.0
        end
        bullet.SetVar('lerp', lerp)
    end

    lastTime = WaveTime()
end

require "waveEnd"