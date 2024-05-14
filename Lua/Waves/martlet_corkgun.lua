require "waveBegin"
local easeBezier = require "easeBezier"

local yellowShot = Encounter["YellowShot"]

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

local function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

local shotDelay = {0, 1, 2, 2.7, 3.4, 4, 4.5}
local gunAppearTime = 0.3
local shootStart = 0.7
local shootDistance = 150
local travelTime = 0.2
local recallStart = 1.3
local recallTravelTime = 0.5
local deleteStart = 2.1
local deleteTime = 0.3

local recoilDistance = 40
local recoilTimeStart = 0.2
local recoilTimeReturn = 0.4

local guns = {}
local gunSize = #shotDelay

local startAngle = math.random() * 360
local ids = {}
for i = 1, gunSize do
    table.insert(ids, i)
end
local shuffledIds = shuffle(ids)
local gunRotation = -45
local shotOffset = {x = 0, y = 17.5}
local triggerOffset = {x = 23, y = 8.5}

function OnHit(bullet)
    PlayerHurt(12)
end

local function gunsUpdate()
    for i = #guns, 1, -1 do
        g = guns[i]
        local gunProxy = g["gunProxy"]
        local gun = g["gun"]
        local cork = g["cork"]
        local marker = g["marker"]
        local bullet = g["bullet"]
        local stringSprite = g["stringSprite"]
        local effect = g["effect"]

        local activeTime = WaveTime() - gunProxy["initialTime"]

        local elapsed = math.min(1, activeTime / gunAppearTime)
        g.alpha = elapsed
        local factor = easeBezier.ease(.61, 1.18, .73, 1.00, activeTime / gunAppearTime)
        gunProxy.rotation = gunProxy["initialRotation"] - factor * gunRotation
        gun.alpha = g.alpha
        gun.rotation = gunProxy.rotation
        cork.alpha = g.alpha
        cork.rotation = gunProxy.rotation
        marker.alpha = g.alpha * 0.4

        if activeTime > shootStart then
            gun.Set("gun_1")
            factor = easeBezier.ease(.53, 1.24, .79, 1.00, math.min(1, (activeTime - shootStart) / travelTime))
            cork.SetParent(g)
            cork.SendToBottom()
            cork.SetAnchor(-shootDistance * factor, 0)
            marker.alpha = 0

            stringSprite.xscale = shootDistance * factor
            stringSprite.SendToBottom()

            if not effect then
                effect = CreateSprite("gun_shot_0", "Top")
                effect.SetAnimation(
                    {
                        "gun_shot_0",
                        "gun_shot_1",
                        "gun_shot_2",
                        "gun_shot_3",
                        "gun_shot_4",
                        "gun_shot_5",
                    }, 0.05
                )
                effect.loopmode = "ONESHOTEMPTY"
                effect.SetPivot(1, 0.5)
                effect.SetAnchor(0, 0)
                effect.Scale(2, gunProxy.yscale)
                effect.SetParent(g)
                effect.MoveTo(0, 0)
                effect.rotation = gunProxy.rotation
                effect.SendToTop()
                g["effect"] = effect
            end

            local recoilFactor = easeBezier.ease(.35, 1.11, .75, 1.07, math.min(1, (activeTime - shootStart) / recoilTimeStart))
            gun.SetAnchor(0.5 + factor * recoilDistance / (gunProxy.width * gunProxy.xscale), 0.5)
        end

        if activeTime > recallStart then
            factor = easeBezier.ease(.85, .17, .95, .83, math.min(1, (activeTime - recallStart) / recallTravelTime))
            --cork.SetAnchor(shootDistance * (factor - 1), 0)
            cork.SetAnchor(mix(-shootDistance, recoilDistance, factor), 0)
            cork.SendToBottom()

            stringSprite.xscale = shootDistance * (1 - factor)
        end

        if activeTime > deleteStart then
            elapsed = math.min(1, (activeTime - deleteStart) / deleteTime)
            g.alpha = 1 - elapsed
            gun.alpha = g.alpha
            cork.alpha = g.alpha
        end

        bullet.MoveToAbs(cork.absx, cork.absy)
        bullet.sprite.rotation = cork.rotation
    end
end

local function createGun(id)
    local gunParent = CreateSprite("empty", "BelowPlayer")
    gunParent.SetPivot(-80, 0)
    gunParent.MoveToAbs(Arena.x, Arena.y + 5 + Arena.height/2)
    gunParent.rotation = startAngle + (360 / gunSize) * shuffledIds[id + 1]
    gunParent.alpha = 0

    local gunProxy = CreateSprite("gun_0", "Top")
    gunProxy.SetPivot(shotOffset.x / gunProxy.width, shotOffset.y / gunProxy.height)
    gunProxy.SetAnchor(0, 0)
    gunProxy.Scale(2, 2)
    gunProxy.SetParent(gunParent)
    gunProxy.MoveTo(0, 0)
    gunProxy.alpha = 0
    gunProxy.rotation = gunParent.rotation
    if gunParent.rotation > 90 and gunParent.rotation < 270 then
        gunProxy.yscale = -2
        gunProxy.rotation = -gunProxy.rotation
    end
    gunParent["gunProxy"] = gunProxy

    gunProxy.SetPivot(triggerOffset.x / gunProxy.width, triggerOffset.y / gunProxy.height)
    gunProxy.SetAnchor(
        (triggerOffset.x - shotOffset.x) * gunProxy.xscale,
        (triggerOffset.y - shotOffset.y) * gunProxy.yscale
    )
    gunProxy.rotation = gunProxy.rotation + gunRotation
    gunProxy["initialRotation"] = gunProxy.rotation
    gunProxy["initialTime"] = WaveTime()

    local gun = CreateSprite("gun_0", "Top")
    gun.Scale(gunProxy.xscale, gunProxy.yscale)
    gun.SetParent(gunProxy)
    gun.MoveTo(0, 0)
    gun.rotation = gunProxy.rotation
    gun.alpha = 0
    gunParent["gun"] = gun

    local gunMarker = CreateSprite("px", "Top")
    gunMarker.Scale(135, 2)
    gunMarker.SetPivot(1, 0.5)
    gunMarker.SetAnchor(0, 0)
    gunMarker.SetParent(gunParent)
    gunMarker.MoveTo(0, 0)
    gunMarker.alpha = 0
    gunMarker.color = {1, 0, 0}
    gunMarker.rotation = gunParent.rotation
    gunMarker.SendToBottom()
    gunParent["marker"] = gunMarker

    local stringSprite = CreateSprite("px", "Top")
    stringSprite.Scale(0, gunProxy.xscale)
    stringSprite.SetPivot(1, 0.5)
    stringSprite.SetAnchor(0, 0)
    stringSprite.SetParent(gunParent)
    stringSprite.MoveTo(0, 0)
    stringSprite.alpha = 1
    stringSprite.color32 = {70, 70, 70}
    stringSprite.rotation = gunParent.rotation
    stringSprite.SendToBottom()
    gunParent["stringSprite"] = stringSprite

    local cork = CreateSprite("cork", "Top")
    cork.SetPivot(5 / 7, 0.5)
    cork.SetAnchor(shotOffset.x / gunProxy.width, shotOffset.y / gunProxy.height)
    cork.Scale(2, gunProxy.yscale)
    cork.SetParent(gunProxy)
    cork.MoveTo(0, 0)
    cork.alpha = 0
    cork.rotation = gunProxy.rotation
    cork.SendToBottom()
    gunParent["cork"] = cork

    local corkBullet = CreateProjectileAbs("cork", cork.absx, cork.absy)
    corkBullet.sprite.SetPivot(cork.xpivot, cork.ypivot)
    corkBullet.sprite.rotation = cork.rotation
    corkBullet.sprite.Scale(cork.xscale, cork.yscale)
    corkBullet.sprite.alpha = 0
    gunParent["bullet"] = corkBullet

    table.insert(guns, gunParent)
end

function Update()
    gunsUpdate()
    if #guns < gunSize and WaveTime() >= shotDelay[#guns + 1] then
        createGun(#guns)
    end
end

function EndingWave()
    for i = #guns, 1, -1 do
        guns[i].Remove()
        table.remove(guns, i)
    end
end

require "waveEnd"