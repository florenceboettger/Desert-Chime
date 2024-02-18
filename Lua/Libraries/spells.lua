local self = {}

local function stunInit(spell)
    spell.initialized = false
    spell.stunValue = 0
    spell.currentStep = 0

    spell.triggerTimes = {
        0.5 + (math.random() - 0.5) * 2 * 0.1,
        2.3 + (math.random() - 0.5) * 2 * 0.1,
        4.1 + (math.random() - 0.5) * 2 * 0.1
    }

    spell.commandOffsets = {}
    spell.offsets = {
        {-10, 5},
        {10, -5},
        {0, 0}
    }

    spell.perfectDelay = 1/15 * 8
    spell.inputRange = 0.2

    spell.commandFinished = false

    SetGlobal("AnimState", "DEFENDING")
end

local function setupStunSprite(spell, x, y)
    spell.initialized = true

    if spell.stunSprite and spell.stunSprite.isactive then
        spell.stunSprite.Remove()
    end

    spell.stunSprite = CreateSprite("spr_battle_enemy_attack_ceroba_diamond_0", "BelowPlayer")
    local frames = {}
    for i = 0, 9 do
        frames[i] = "spr_battle_enemy_attack_ceroba_diamond_" .. i
    end
    spell.stunSprite.SetAnimation(frames, 1/15)
    spell.stunSprite.xscale = 2
    spell.stunSprite.yscale = 2
    spell.stunSprite.loopmode = "ONESHOT"
    spell.target = enemies[Player.lastenemychosen]
    spell.stunSprite.MoveTo(spell.target["monstersprite"].absx + x, spell.target["monstersprite"].absy + spell.target["monstersprite"].height / 2 + y)
    spell.stunSprite["playedSound"] = false

    PlaySoundOnceThisFrame("snd_ceroba_trap_1")
end

local function stunSpell(spell, time)
    if spell.currentStep < 3 and time > spell.triggerTimes[spell.currentStep + 1] then
        spell.currentStep = spell.currentStep + 1
        setupStunSprite(spell, spell.offsets[spell.currentStep][1], spell.offsets[spell.currentStep][2])
    end

    if spell.stunSprite and spell.stunSprite.isactive then
        local relativeTime = time - spell.triggerTimes[spell.currentStep] - spell.perfectDelay
        if Input.Confirm == 1 and not spell.commandOffsets[spell.currentStep] then
            if relativeTime >= -spell.inputRange and relativeTime <= spell.inputRange then
                spell.commandOffsets[spell.currentStep] = relativeTime
                if math.abs(relativeTime) < 0.03 then
                    PlaySoundOnceThisFrame("snd_shotstrong")
                    PlaySoundOnceThisFrame("snd_ceroba_trap_2")
                    Attacked(60)
                elseif math.abs(relativeTime) < 0.1 then
                    PlaySoundOnceThisFrame("snd_shotmid")
                    PlaySoundOnceThisFrame("snd_ceroba_trap_2")
                    Attacked(30)
                else
                    PlaySoundOnceThisFrame("snd_ceroba_trap_2")
                    Attacked(15)
                end
            end
        end
        if relativeTime > spell.inputRange and not spell.commandOffsets[spell.currentStep] then        
            spell.commandOffsets[spell.currentStep] = -1
            PlaySoundOnceThisFrame("snd_mirrorbreak1")
            shield.spawnShards(spell.stunSprite.x, spell.stunSprite.y, {1, 1, 1})
        end
        if spell.stunSprite.animcomplete then
            spell.stunSprite.alpha = spell.stunSprite.alpha - 0.15 * (Time.dt * 30)
            if spell.stunSprite.alpha == 0 then
                spell.stunSprite.Remove()
                if spell.currentStep == 3 then
                    spell.commandFinished = true
                end
            end
        end
    end

    if spell.commandFinished then
        if not spell.stunText or not spell.stunText.isactive then
            local multiplier = 1
            for _, v in ipairs(spell.commandOffsets) do
                local baseMultiplier = Mix(0, 0.85, easeBezier.ease(.42, 0, .34, 1, math.abs(v) / spell.inputRange))
                if v == -1 then
                    baseMultiplier = 1
                end
                local factor = Mix(0.86, 1, baseMultiplier)
                multiplier = multiplier * factor
            end
            spell.multiplier = math.floor(multiplier * 10 + 0.5) / 10
            spell.stunText = CreateText(
                ("[instant][font:uidamagetext]x%1.1f"):format(spell.multiplier),
                {
                    spell.target["monstersprite"].absx - 55,
                    spell.target["monstersprite"].absy
                },
                999,
                "BelowPlayer"
            )
            spell.stunText.HideBubble()
            spell.stunText.progressmode="none"
            spell.stunText.color32 = {117, 143, 221}
            spell.stunText["spd"] = 4
            spell.stunText["grav"] = -0.5
            spell.stunText["createTime"] = Time.time
            spell.stunText["originalY"] = spell.stunText.y

            SetWavespeed(spell.multiplier)
        else
            spell.stunText["spd"] = spell.stunText["spd"] + spell.stunText["grav"] * (Time.dt * 30)
            spell.stunText.Move(0, spell.stunText["spd"])
            if spell.stunText.y < spell.stunText["originalY"] then
                spell.stunText.y = spell.stunText["originalY"]
                spell.stunText["spd"] = 0
                spell.stunText["grav"] = 0
            end
            if Time.time - spell.stunText["createTime"] > 1.5 then
                spell.stunText.Remove()
                SetGlobal("AnimState", "IDLE")
                State("ENEMYDIALOGUE")
            end
        end
    end
end

self.list = {
    {
        name = "SHIELD",
        active = true,
        selectable = true,
        cost = 16,
        description = {
            "Summon shield.",
            "Move at pieces."
        },
        target = "SELF"
    },
    {
        name = "STUN",
        active = true,
        selectable = true,
        cost = 32,
        description = {
            "Slow down enemy.",
            "Press [Z] in time."
        },
        target = "SELECT",
        init = stunInit,
        func = stunSpell
    },
    {
        name = "FLWRSTRM",
        active = true,
        selectable = false,
        cost = 50,
        description = {
            "Barrage of blossoms.",
            "Mash [Z]."
        },
        target = "SELECT"
    },
    {
        name = "VITADRAIN",
        active = false,
        selectable = true,
        cost = 100,
        description = {
            "Drain enemy's will.",
            "Alternate direction."
        },
        target = "SELF"
    }
}

local commandTime = -1
local columnShift = 230
local playerPosSet = true
local mainTextColumnShift = UI.maintext.columnShift

self.selected = 1

self.dividingLine = CreateSprite("px", "BelowPlayer")
self.dividingLine.SetPivot(0, 0)
self.dividingLine.MoveToAbs(UI.maintext.absx + columnShift - 18, Arena.y)
self.dividingLine.xscale = 5
self.dividingLine.yscale = Arena.height + 10
self.dividingLine.alpha = 0

CreateState("SPELLSELECT")
CreateState("ACTIONCOMMAND")

local function updateSpellList()
    local spellsText = "[instant]"
    local spellDescription = self.list[self.selected].description
    spellDescription[3] = ("(%d%%TP)"):format(self.list[self.selected].cost)
    for i, spell in ipairs(self.list) do
        if spell.active then
            local color = "[color:ffffff]"
            if not spell.selectable then
                color = "[color:ff0000]"
            elseif spell.cost > tp.tp then
                color = "[color:666666]"
            end
            spellsText = spellsText .. ("  %s* %s[color:ffffff]\t%s\n"):format(color, spell.name, spellDescription[i])
        end
    end
    UI.maintext.SetText(spellsText)
end

local function hoverSpell(i, rel)
    if rel == nil then
        rel = false
    end
    if rel then
        i = i + self.selected
    end
    self.selected = math.max(1, math.min(3, i))
    Player.sprite.absx = UI.maintext.absx + 12
    Player.sprite.absy = UI.maintext.absy + Player.sprite.height / 2 + 1 - (self.selected - 1) * 30
    updateSpellList()
end

local function hideSpells()
    UI.maintext.columnShift = mainTextColumnShift
    self.dividingLine.alpha = 0
end

local function showSpells()
    UI.maintext.columnShift = columnShift
    self.dividingLine.alpha = 1
end

local function setupActionCommand()
    tp.setTP(-self.list[self.selected].cost, true, true)
    Player.sprite.MoveToAbs(-100, -100)
    UI.maintext.setText("")
    commandTime = Time.time
    self.list[self.selected]:init()
end

PostSpellsUpdate = Update

function Update()
    if GetCurrentState() == "SPELLSELECT" then
        if Input.Up == 1 and Input.Down <= 0 then
            hoverSpell(-1, true)
            Audio.PlaySound("menumove")
        end
        if Input.Down == 1 and Input.Up <= 0 then
            hoverSpell(1, true)
            Audio.PlaySound("menumove")
        end
        if Input.Confirm == 1 then
            if self.list[self.selected].selectable and self.list[self.selected].cost <= tp.tp then
                if self.list[self.selected].target == "SELF" then
                    State("ACTIONCOMMAND")
                else
                    State("ENEMYSELECT")
                    SetAction("FIGHT")
                end
                hideSpells()
            else
                Audio.PlaySound("hurtsound", 0.4)
            end
        elseif Input.Cancel == 1 then
            State("ACTIONSELECT")
            hideSpells()
        end
    elseif GetCurrentState() == "ENEMYSELECT" then
        if not playerPosSet then
            Player.sprite.absx = UI.maintext.absx + 12
            playerPosSet = true
        end
    elseif GetCurrentState() == "ACTIONCOMMAND" then
        local spellTime = Time.time - commandTime
        self.list[self.selected]:func(spellTime)
    end

    if PostSpellsUpdate then
        PostSpellsUpdate()
    end
end

PostSpellsEnteringState = EnteringState

function EnteringState(newstate, oldstate)
    if oldstate == "ACTIONSELECT" and newstate == "ENEMYSELECT" and UI.GetCurrentButton() == "FIGHT" then
        State("SPELLSELECT")
        showSpells()
        hoverSpell(1)
    end

    if oldstate == "ENEMYSELECT" and newstate == "ACTIONSELECT" and UI.GetCurrentButton() == "FIGHT" then
        State("SPELLSELECT")
        showSpells()
        hoverSpell(self.selected)
    end

    if oldstate == "SPELLSELECT" and newstate == "ENEMYSELECT" then
        playerPosSet = false
    end

    if oldstate == "ENEMYSELECT" and newstate == "ATTACKING" then
        setupActionCommand()
        State("ACTIONCOMMAND")
    end

    if newstate == "ACTIONCOMMAND" then
        setupActionCommand()
    end

    if PostSpellsEnteringState then
        PostSpellsEnteringState(newstate, oldstate)
    end
end

return self