local rc = require "RotationalCollision"
local onHit = require "yellowShotOnHit"
-- enemy bullet interaction from yellowSoul.lua by Litenek

local self = {}

self.shots = {}
self.hitSprites = {}
self.targetProjectiles = {}

self.shootSprite = CreateSprite("spr_heart_yellow_shoot_0")
self.shootSprite.SetParent(Player.sprite)
self.shootSprite.SetPivot(0.5, 8/14)
self.shootSprite.SetAnchor(0.5, 0)
self.shootSprite.MoveTo(0, 0)
self.shootSprite.localRotation = 0
self.shootSprite.alpha = 0

self.readySprite = CreateSprite("spr_heart_yellow_ready_0")
self.readySprite.SetParent(Player.sprite)
self.readySprite.MoveTo(0, 0)
self.readySprite.localRotation = 0
self.readySprite.alpha = 0

self.chargeOrbs = {}

for i = 1, 4 do
    local spr = CreateSprite("charge_circle")
    spr.SetParent(Player.sprite)
    spr.alpha = 0
    self.chargeOrbs[i] = spr
end

self.chargeTime = 1
self.chargeProgress = 0

self.isCharging = false
self.isCharged = false
self.lock = false

self.lastShot = -1
self.chargeCooldown = nil
self.startedCharging = -1

function self.createShot()
    Audio.PlaySound("snd_yellow_soul_shoot")
    Player.hp = Player.hp - 1
    local spr = CreateSprite("spr_heart_yellow_shot_0")
    spr.SetAnimation({
        "spr_heart_yellow_shot_0",
        "spr_heart_yellow_shot_1",
        "spr_heart_yellow_shot_2",
        "spr_heart_yellow_shot_3",
        "spr_heart_yellow_shot_4",
    }, 1/30)
    spr.loopmode = "ONESHOT"
    spr.Scale(2, 2)
    spr.SetPivot(0.5, 1)
    spr.SetAnchor(0.5, 8/14)
    spr.SetParent(self.shootSprite)
    spr.localRotation = 0
    spr.MoveTo(0, 0)
    spr["xspeed"] = math.sin(spr.rotation / 180 * math.pi) * 300
    spr["yspeed"] = -math.cos(spr.rotation / 180 * math.pi) * 300
    spr["xacc"] = 10
    spr["yacc"] = -200
    spr["bigshot"] = false

    spr.layer = "Top"

    table.insert(self.shots, spr)
end

function self.createBigShot()
    Audio.PlaySound("snd_shot_big_fire")
    Player.hp = Player.hp - 5
    local spr = CreateSprite("spr_heart_yellow_shot_big_0")
    spr.SetAnimation({
        "spr_yheart_bigshot_0",
        "spr_yheart_bigshot_1",
        "spr_yheart_bigshot_2",
        "spr_yheart_bigshot_3",
    }, 0.12)
    spr.Scale(2, 0.1)
    spr.SetPivot(0.5, 1)
    spr.SetAnchor(0.5, 8/14)
    spr.SetParent(self.shootSprite)
    spr.localRotation = 0
    spr.alpha = 0.5
    spr.MoveTo(0, 0)
    spr["xspeed"] = math.sin(spr.rotation / 180 * math.pi) * 360
    spr["yspeed"] = -math.cos(spr.rotation / 180 * math.pi) * 360
    spr["xacc"] = 20
    spr["yacc"] = -100
    spr["bigshot"] = true

    spr.layer = "Top"

    table.insert(self.shots, spr)
end

function self.onCollision(enemybullet, shot)
    if shot["bigshot"] then
        
    else
        local hitSprite = CreateSprite("spr_yheart_shot_hit_0")
        hitSprite.SetAnimation({
            "spr_yheart_shot_hit_0",
            "spr_yheart_shot_hit_1",
            "spr_yheart_shot_hit_2",
            "spr_yheart_shot_hit_3"
        }, 1/30)
        hitSprite.loopmode = "ONESHOTEMPTY"
        hitSprite.Scale(2, 2)
        hitSprite.SetPivot(0.5, 25 / 17)
        hitSprite.SetAnchor(0.5, 1)
        hitSprite.SetParent(shot)
        hitSprite.localRotation = 0
        hitSprite.MoveTo(0, 0)
        hitSprite.layer = "Top"

        table.insert(self.hitSprites, hitSprite)

        shot.Remove()
        onHit(enemybullet)
    end
end

PostYellowShotUpdate = Update

function Update()
    self.shootSprite.localRotation = 0
    self.readySprite.localRotation = 0
    if GetCurrentState() == "DEFENDING" then
        if not self.lock then
            if Input.Confirm == 1 and Time.time - self.lastShot >= 5/30 then
                self.shootSprite.alpha = 1
                self.shootSprite.SetAnimation({
                    "spr_heart_yellow_shoot_0",
                    "spr_heart_yellow_shoot_1",
                    "spr_heart_yellow_shoot_2",
                }, 1/30)
                self.shootSprite.loopmode = "ONESHOTEMPTY"
                self.lastShot = Time.time
                self.createShot()
            end
            if not self.isCharging and not self.isCharged then
                if Input.Confirm > 0 then
                    if not self.chargeCooldown then
                        self.chargeCooldown = Time.time
                    elseif Time.time - self.chargeCooldown >= 7/30 then
                        self.isCharging = true
                        self.chargeCooldown = nil
                        self.startedCharging = Time.time
                    end
                else
                    self.chargeCooldown = nil
                end
            elseif self.isCharging and not self.isCharged then
                self.chargeProgress = (Time.time - self.startedCharging) / self.chargeTime

                if Input.Confirm <= 0 then
                    self.isCharging = false
                elseif self.chargeProgress >= 1 then
                    self.isCharging = false
                    self.isCharged = true

                    Audio.PlaySound("snd_undertale_flash")

                    self.readySprite.alpha = 1
                    self.readySprite.SetAnimation({
                        "spr_heart_yellow_ready_0",
                        "spr_heart_yellow_ready_1",
                        "spr_heart_yellow_ready_2",
                        "spr_heart_yellow_ready_3",
                        "spr_heart_yellow_ready_4",
                        "spr_heart_yellow_ready_5",
                    }, 1/30)
                    self.readySprite.loopmode = "ONESHOTEMPTY"
                end

                for i, spr in ipairs(self.chargeOrbs) do
                    if self.isCharging then
                        spr.alpha = math.max(0, -0.2 + self.chargeProgress)
                        self.color = {1, 1, self.chargeProgress}
                        local angle = (1 - self.chargeProgress + 0.5 * i) * math.pi
                        spr.MoveTo(
                            math.sin(angle) * 25 * (1 - self.chargeProgress),
                            math.cos(angle) * 25 * (1 - self.chargeProgress)
                        )
                    else
                        spr.alpha = 0
                    end
                end
            else
                if Input.Confirm <= 0 then
                    self.isCharged = false
                    self.readySprite.alpha = 0

                    self.shootSprite.alpha = 1
                    self.shootSprite.SetAnimation({
                        "spr_heart_yellow_shoot_0",
                        "spr_heart_yellow_shoot_1",
                        "spr_heart_yellow_shoot_2",
                    }, 1/30)
                    self.shootSprite.loopmode = "ONESHOTEMPTY"
                    self.lastShot = Time.time
                    self.createBigShot()
                end
            end
            if self.readySprite.animcomplete then
                self.readySprite.SetAnimation({
                    "spr_heart_yellow_hold_0",
                    "spr_heart_yellow_hold_1",
                    "spr_heart_yellow_hold_2",
                    "spr_heart_yellow_hold_3",
                }, 1/30)
            end
            if self.shootSprite.animcomplete then
                self.shootSprite.alpha = 0
            end
        end
    end
    for i = #self.shots, 1, -1 do
        local spr = self.shots[i]

        if not spr.isactive then
            table.remove(self.shots, i)
            break
        end
        if GetCurrentState() ~= "DEFENDING" then
            spr.alpha = spr.alpha - 3 * Time.dt
        end
        spr["xspeed"] = spr["xspeed"] + Time.dt * spr["xacc"]
        spr["yspeed"] = spr["yspeed"] + Time.dt * spr["yacc"]
        spr.Move(spr["xspeed"] * Time.dt, spr["yspeed"] * Time.dt)
        if spr.x < -30 or spr.x > 640 + 30 or spr.y < -30 or spr.y > 480 + 30 or spr.alpha <= 0 then
            spr.Remove()
            table.remove(self.shots, i)
        else
            spr.rotation = math.atan2(spr["xspeed"], -spr["yspeed"]) * 180 / math.pi

            if not spr["bigshot"] and spr.animcomplete and spr.yscale < 4 then
                --spr.yscale = math.min(4, spr.yscale + 6 * Time.dt)
            end
            if spr["bigshot"] then
                spr.alpha = spr.alpha + 3 * Time.dt
                spr.yscale = math.min(1, spr.yscale + 3 * Time.dt)
                spr.xscale = math.max(1, spr.xscale - 3 * Time.dt)
            end

            for j = #self.targetProjectiles, 1, -1 do
                local target = self.targetProjectiles[j]
                if target.isactive and rc.collide(target, {sprite = spr}) then
                    self.onCollision(target, spr)
                end
            end
        end
    end
    if PostYellowShotUpdate then
        PostYellowShotUpdate()
    end
end

PostYellowShotEnteringState = EnteringState

function EnteringState(newstate, oldstate)
    if oldstate == "DEFENDING" and newstate ~= "PAUSE" and newstate ~= "DEFENDING" then
        self.readySprite.alpha = 0
        self.shootSprite.alpha = 0

        for _, spr in ipairs(self.chargeOrbs) do
            spr.alpha = 0
        end
    end

    if PostYellowShotEnteringState then
        PostYellowShotEnteringState(newstate, oldstate)
    end
end

return self