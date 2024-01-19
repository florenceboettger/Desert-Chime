-- taken from CYK
require "ScriptOwnerBypass"

veryBigBulletPool = {}
_CreateProjectile = CreateProjectile
-- Overrides CreateProjectile
function CreateProjectile(spritename, initial_x, initial_y, layer)
    return CreateProjectileForReal(spritename, initial_x, initial_y, layer, false)
end

_CreateProjectileAbs = CreateProjectileAbs
-- Overrides CreateProjectileAbs
function CreateProjectileAbs(spritename, initial_x, initial_y, layer)
    return CreateProjectileForReal(spritename, initial_x, initial_y, layer, true)
end

-- Actually does the thing CreateProjectile and CreateProjectileAbs is supposed to do
function CreateProjectileForReal(spritename, initial_x, initial_y, layer, isAbs)
    -- Starts the right CYF function
    local projectile = (isAbs and _CreateProjectileAbs or _CreateProjectile)(spritename, initial_x, initial_y, layer)
    if not layer then
        projectile.sprite.layer = "Bullet"
    end

    table.insert(veryBigBulletPool, projectile)
    return projectile
end

local startTime = Time.time

function WaveTime()
    local diffTime = Time.time - startTime
    return diffTime * Encounter["wavespeed"]
end

function WaveDeltaTime()
    return Time.dt * Encounter["wavespeed"]
end

function EndingWave()
    Encounter.Call("SetWavespeed", 1)
end