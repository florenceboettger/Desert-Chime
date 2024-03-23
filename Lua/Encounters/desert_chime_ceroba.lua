easeBezier = require "easeBezier"
parseDialogue = require "parseDialogue"
require "ScriptOwnerBypass"

-- music = "shine_on_you_crazy_diamond" --Either OGG or WAV. Extension is added automatically. Uncomment for custom music.
encountertext = "The sand swirls around you." --Modify as necessary. It will only be read out in the action select screen.
nextwaves = {"bullettest_touhou"}
wavetimerOrig = 4.0
wavetimer = 4.0
wavespeed = 1.0
arenasize = {565, 130}

autolinebreak = true

noscalerotationbug = true
--playerskipdocommand = true

enemies = {
    "desert_chime"
    --"sir_slither_esq",
    --"sir_slither_esq_esq",
    --"bowll"
}

enemypositions = {
    {-210, 10},
    {210, 10},
    {0, 50}
}

function PlaySoundOnceThisFrame(sound)
    if not NewAudio.Exists(sound) then
        NewAudio.CreateChannel(sound)
    end
    NewAudio.PlaySound(sound, sound)
end

function Mix(x, y, a)
    return x * (1 - a) + y * a
end

function SetWavetimer(t)
    wavetimerOrig = t
    wavetimer = t / wavespeed
end

function SetWavespeed(s)
    wavespeed = s
    wavetimer = wavetimerOrig / wavespeed
end

-- A custom list with attacks to choose from. Actual selection happens in EnemyDialogueEnding(). Put here in case you want to use it.
possible_attacks = {"bullettest_bouncy", "bullettest_chaserorb", "bullettest_touhou"}

local spellButtonAnimStart = -1
local spellButtonAnimDuration = 0.5
local spellButtonAnim, spellButtonShadow

local textboxSprite

function ActivateSpellButton()
    --UI.EnableButton("FIGHT")
    UI.fightbtn.Set("SPELL")
    UI.fightbtn.color = {1, 1, 1}
    UI.SetButtonActiveSprite("FIGHT", "SPELL_active")
    Audio.PlaySound("snd_undertale_flash")
    spellButtonAnimStart = Time.time

    spellButtonShadow = CreateSprite("SPELL", "BelowUI")
    spellButtonShadow.MoveToAbs(
        UI.fightbtn.absx + UI.fightbtn.width / 2,
        UI.fightbtn.absy + UI.fightbtn.height / 2
    )
    spellButtonShadow.alpha = 0.5

    spellButtonAnim = CreateSprite("SPELL", "BelowArena")
    spellButtonAnim.MoveToAbs(
        UI.fightbtn.absx + UI.fightbtn.width / 2,
        UI.fightbtn.absy + UI.fightbtn.height / 2
    )

    tp.Activate()
end

function EncounterStarting()
    require "Animations/desert_chime_anim"
    Sandstorm = require "Animations/sandstorm_anim"
    --require "Animations/sir_slither_anim"
    --SetupSlitherAnimation("sir_slither_esq", 1)
    --SetupSlitherAnimation("sir_slither_esq_esq", 2)
    --require "Animations/bowll_anim"

    --parseDialogue.loadDialogue(require "Dialogue/testing", true)

    -- Setup Fight Command
    UI.background.Set("empty")
    UI.fightbtn.Set("FIGHT_inactive")
    UI.fightbtn.color = {0.4, 0.4, 0.4}
    UI.DisableButton("FIGHT")
    
    UI.hpbar.background.color = {0.4, 0.4, 0.4}
    UI.hpbar.fill.color = {1, 1, 1}

    -- Setup Player
    Player.maxhp = 5
    Player.hp = Player.maxhp
    Player.name = "CEROBA"
    Player.sprite.Set("monster_soul")
    Player.sprite.color = {1, 1, 1}

    --[[if not pcall(Player.sprite.shader.Set, "shear", "Shear") then
        DEBUG("uh oh")
    end]]

    spells = require "spells"
    shield = require "shield"
    tp = require "tp"

    tp.Deactivate()
    tp.grazeSpriteColor = {132, 132, 132}

    -- Testing
    shield.setShield(10)
    --ActivateSpellButton()
    tp.setTP(100)
end

function Update()
    if (Arena.currentwidth % 2 ~= 0 or Arena.currentheight ~= 0) and not Arena.isResizing then
        Arena.ResizeImmediate(math.floor(Arena.width / 2) * 2, math.floor(Arena.height / 2) * 2)
    end
    --[[if Player.sprite.shader.isactive then
    
        Player.sprite.shader.SetVector("yOffset", {10 * math.sin(Time.time * 2 * math.pi), 0, 0, 0})
    end]]
    if Input.GetKey("Mouse1") == 1 and spellButtonAnimStart < 0 then
        ActivateSpellButton()
    end

    if (spellButtonAnim and spellButtonAnim.isactive) or (spellButtonShadow and spellButtonShadow.isactive) then
        local animTime = Time.time - spellButtonAnimStart
        local scale = 1 + 0.15 * easeBezier.ease(.81, .56, .62, 1, math.sin(animTime / spellButtonAnimDuration * math.pi))
        local angle = 0.7 * math.sin(animTime / spellButtonAnimDuration * math.pi * 2)
        if animTime > spellButtonAnimDuration and spellButtonAnim.isactive then
            spellButtonAnim.Remove()
            UI.EnableButton("FIGHT")
        elseif spellButtonAnim.isactive then
            spellButtonAnim.xscale = scale
            spellButtonAnim.yscale = scale
            spellButtonAnim.rotation = angle
        end

        if spellButtonShadow.isactive then
            local shadeScale = 1 + 0.5 * easeBezier.ease(.31, .67, .61, 1, animTime / (spellButtonAnimDuration * 2))
            spellButtonShadow.xscale = shadeScale
            spellButtonShadow.yscale = shadeScale
            spellButtonShadow.rotation = angle * 0.5
            spellButtonShadow.alpha = 1 - animTime / (spellButtonAnimDuration * 2)
            if spellButtonShadow.alpha < 0 and spellButtonShadow.isactive then
                spellButtonShadow.Remove()
            end
        end
    end
end

function EnteringState(newstate, oldstate)
    parseDialogue.enteringState(newstate, oldstate)
end

function EnemyDialogueStarting()
    -- Good location for setting monster dialogue depending on how the battle is going.
end

function EnemyDialogueEnding()
    -- Good location to fill the 'nextwaves' table with the attacks you want to have simultaneously.
    --nextwaves = { possible_attacks[math.random(#possible_attacks)] }
end

function DefenseEnding() --This built-in function fires after the defense round ends.
    encountertext = RandomEncounterText() --This built-in function gets a random encounter text from a random enemy.
end

function HandleSpare()
    State("ENEMYDIALOGUE")
end

function HandleItem(ItemID)
    BattleDialog({"Selected item " .. ItemID .. "."})
end