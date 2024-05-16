math.randomseed(os.time())

easeBezier = require "easeBezier"
gas = require "gas"
--parseDialogue = require "parseDialogue"
require "ScriptOwnerBypass"

-- music = "shine_on_you_crazy_diamond" --Either OGG or WAV. Extension is added automatically. Uncomment for custom music.
encountertext = "The sand swirls around you." --Modify as necessary. It will only be read out in the action select screen.
local waves = {"martlet_corkgun", "martlet_blossoms"}
local wavetimers = {6.7, 8.0}
local nextWave = waves[1]
nextwaves = {nextWave}
wavetimer = 8.0
wavetimerOrig = wavetimer
wavespeed = 1.0
arenasize = {100, 100}

local waveCounter = 0

autolinebreak = true
noscalerotationbug = true
--playerskipdocommand = true

enemies = {
    "desert_chime"
}

enemypositions = {
    {0, 0}
}

function SetWavetimer(t)
    wavetimerOrig = t
    wavetimer = t / wavespeed
end

function SetWavespeed(s)
    wavespeed = s
    wavetimer = wavetimerOrig / wavespeed
end

function PlaySoundOnceThisFrame(sound)
    if not NewAudio.Exists(sound) then
        NewAudio.CreateChannel(sound)
    end
    NewAudio.PlaySound(sound, sound)
end

function Mix(x, y, a)
    return x * (1 - a) + y * a
end

LabelBarDiff = 0
HPBarDiff = 0

function EncounterStarting()

    LabelBarDiff = UI.hpbar.background.absx - (UI.hplabel.absx + UI.hplabel.width)
    HPBarDiff = UI.hptext.absx - (UI.hpbar.background.absx + UI.hpbar.background.xscale)
    DesertChimeAnimation = require "Animations/desert_chime_anim"
    Sandstorm = require "Animations/sandstorm_anim"

    UI.hpbar.background.color = {0.4, 0.4, 0.4}
    UI.hpbar.fill.color = {1, 1, 1}
    UI.fightbtn.Set("SPELL_martlet")
    UI.fightbtn.color = {1, 1, 1}
    UI.SetButtonActiveSprite("FIGHT", "SPELL_active")

    -- Setup Player
    Player.maxhp = 100
    Player.hp = Player.maxhp
    Player.name = "MARTLET"
    UI.namelv.SetText("[color:ffff00][instant]MARTLET")
    --Player.sprite.Set("monster_soul")
    Player.sprite.SetAnimation(
        {
            "martlet_soul_0",
            "martlet_soul_1",
            "martlet_soul_2",
            "martlet_soul_3",
            "martlet_soul_4",
            "martlet_soul_5",
            "martlet_soul_6",
            "martlet_soul_7",
            "martlet_soul_8",
            "martlet_soul_9",
        },
        0.2
    )
    Player.sprite.color = {1, 1, 1}
    Player.sprite.rotation = 180
    UI.background.Set("empty")

    tp = require "tp"
    tp.grazeSpriteColor = {132, 132, 132}

    YellowShot = require "yellowShot"
    RoundArena = require "roundArena"
    RoundArena.monsterSprite = DesertChimeAnimation.desertChimeSprite
    RoundArena.arenaOffset = {x = 0, y = 30}
    RoundArena.monsterOffset = {x = 0, y = 0}

    -- Testing
    --tp.setTP(100)
    --Sandstorm.Hide()
end

function Update()
    UI.hplabel.absx = 162
    UI.hpbar.background.absx = UI.hplabel.absx + UI.hplabel.width + LabelBarDiff
    UI.hptext.absx = UI.hpbar.background.absx + UI.hpbar.background.xscale + HPBarDiff

    if GetCurrentState() == "PREWAVEMOVE" then
        if nextWave == "martlet_blossoms" then
            Player.sprite.rotation = math.max(90, Player.sprite.rotation - Time.dt * 270)
        end
    elseif GetCurrentState() == "POSTWAVEMOVE" then
        if nextWave == "martlet_blossoms" then
            Player.sprite.rotation = math.min(180, Player.sprite.rotation + Time.dt * 270)
        end
    end
end

function EnteringState(newstate, oldstate)
    if newstate == "DEFENDING" and oldstate ~= "PREWAVEMOVE" then
        waveCounter = waveCounter + 1
        nextWave = waves[math.min(#waves, waveCounter)]
        wavetimer = wavetimers[math.min(#waves, waveCounter)]
        if nextWave == "martlet_blossoms" then
            
        elseif nextWave == "martlet_corkgun" then

        end

        nextwaves = {nextWave}
    end
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

function OnTextDisplay(text)
    if text == enemies[1]["textobject"] then
        local letters = text.GetLetters()
        for _, l in ipairs(letters) do
            l.rotation = -45
        end
    end
end