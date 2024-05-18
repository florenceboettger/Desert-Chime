require "waveBegin"

local yellowShot = Encounter["YellowShot"]

local barrages = {{}}
local destroyAnims = {}

local shotDelay = 0.8
local spawnDelay = 0.07

local bulletsPerShot = 7
local spawnDist = 100
local bulletSpeed = 140

local playerPositions = {}
local playerSpeedOffset = 0.2
local estimatedPlayerSpeed = 40

function OnHit(bullet)
    PlayerHurt(9)
end

local function getNearestBullet()
    local minDist = 999999999
    local minBullet
    for i = 1, #barrages do
        for _, b in ipairs(barrages[i]) do
            if b.isactive then
                local dist = (Player.x - b.x) * (Player.x - b.x) + (Player.y - b.y) * (Player.y - b.y)
                if dist > 0 and dist < minDist then
                    minBullet = b
                    minDist = dist
                end
            end
        end
    end

    if minDist < 999999999 then
        return minBullet
    end
    return nil
end

local function length(v)
    return math.sqrt(v.x * v.x + v.y * v.y)
end

local function direction(p1, p2)
    local dir = {
        x = p2.x - p1.x,
        y = p2.y - p1.y
    }
    local l = length(dir)
    if l == 0 then
        return {x = 0, y = 0}
    end
    dir.x = dir.x / l
    dir.y = dir.y / l

    return dir
end

local function getPlayerMovementDir(time)
    local prevTime = WaveTime() - time
    local prevPos = playerPositions[1].pos
    for i = #playerPositions, 1, -1 do
        if playerPositions[i].time < prevTime then
            prevPos = playerPositions[i].pos
            break
        end
    end
    return direction(prevPos, Player)
end

local function updateBullets()
    for i, barrage in ipairs(barrages) do
        for j, bullet in ipairs(barrage) do
            if bullet.isactive then
                if bullet["hit"] then
                    local destroyAnim = CreateSprite("desert_chime_blossom_destroy_0")
                    local frames = {}
                    for k = 0, 8 do
                        table.insert(frames, "desert_chime_blossom_destroy_" .. k)
                    end
                    destroyAnim.loopmode = "ONESHOTEMPTY"
                    destroyAnim.SetAnimation(frames, 0.05)
                    destroyAnim.MoveToAbs(bullet.absx, bullet.absy)
                    table.insert(destroyAnims, destroyAnim)
                    bullet.Remove()
                else
                    bullet.Move(bullet["xspeed"] * WaveDeltaTime(), bullet["yspeed"] * WaveDeltaTime())
                end
            end
        end
    end

    for _, destroyAnim in ipairs(destroyAnims) do
        if destroyAnim.isactive then
            if destroyAnim.currentframe > 3 then
                destroyAnim.alpha = destroyAnim.alpha - WaveDeltaTime() / 0.4
                if destroyAnim.alpha < 0 then
                    destroyAnim.Remove()
                end
            end
        end
    end
end

function Update()
    table.insert(playerPositions, {time = WaveTime(), pos = {x = Player.x, y = Player.y}})
    if #playerPositions > 50 then
        table.remove(playerPositions, 1)
    end

    updateBullets()

    if WaveTime() % shotDelay >= spawnDelay * #(barrages[#barrages]) and WaveTime() % shotDelay <= spawnDelay * (#(barrages[#barrages]) + 1) and #(barrages[#barrages]) < bulletsPerShot then
        local bulletPos = {
            x = Player.x / math.sqrt(Player.x * Player.x + Player.y * Player.y) * spawnDist,
            y = Player.y / math.sqrt(Player.x * Player.x + Player.y * Player.y) * spawnDist
        }
        if #barrages > 1 then
            local nearestBullet = getNearestBullet()
            if nearestBullet then
                local dir = {
                    x = Player.x - nearestBullet.x,
                    y = Player.y - nearestBullet.y
                }
                local a = dir.x * dir.x + dir.y * dir.y
                local b = 2 * (nearestBullet.x * dir.x + nearestBullet.y * dir.y)
                local c = nearestBullet.x * nearestBullet.x + nearestBullet.y * nearestBullet.y - spawnDist * spawnDist
                local determinant = b * b - 4 * a * c

                if determinant >= 0 then
                    local t = (-b + math.sqrt(determinant)) / (2 * a)
                    bulletPos = {
                        x = nearestBullet.x + t * dir.x,
                        y = nearestBullet.y + t * dir.y
                    }
                end
            end
        end
        local bullet = CreateProjectile("desert_chime_blossom_0", bulletPos.x + (math.random() - 0.5) * 50, bulletPos.y + (math.random() - 0.5) * 50)
        bullet.sprite.SetAnimation({
            "desert_chime_blossom_0",
            "desert_chime_blossom_1",
            "desert_chime_blossom_2"
        }, 0.25)

        bullet["xspeed"] = 0
        bullet["yspeed"] = 0
        bullet["type"] = "blossom"

        table.insert(yellowShot.targetProjectiles, bullet)
        table.insert(barrages[#barrages], bullet)
    end
    if WaveTime() % shotDelay >= spawnDelay * bulletsPerShot and #(barrages[#barrages]) > 0 then
        for _, bullet in ipairs(barrages[#barrages]) do
            local playerDir = getPlayerMovementDir(playerSpeedOffset)
            local target = {
                x = Player.x + playerDir.x * estimatedPlayerSpeed,
                y = Player.y + playerDir.y * estimatedPlayerSpeed
            }
            local targetDist = length(target)
            if targetDist >= Arena.currentwidth / 2 then
                local targetDir = direction({x = 0, y = 0}, target)
                target = {
                    x = targetDir.x * Arena.currentwidth / 2,
                    y = targetDir.y * Arena.currentwidth / 2
                }
            end

            --local b = CreateProjectile("bullet", target.x, target.y)

            local targetOffset = {
                x = target.x + (math.random() - 0.5) * 50,
                y = target.y + (math.random() - 0.5) * 50
            }
            local dir = direction(bullet, targetOffset)

            bullet["xspeed"] = dir.x * bulletSpeed
            bullet["yspeed"] = dir.y * bulletSpeed
        end

        table.insert(barrages, {})
    end
end

function EndingWave()
    for _, destroyAnim in ipairs(destroyAnims) do
        destroyAnim.Remove()
    end
end

require "waveEnd"