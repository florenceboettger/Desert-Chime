easeBezier = require "easeBezier"
require "ScriptOwnerBypass"

-- music = "shine_on_you_crazy_diamond" --Either OGG or WAV. Extension is added automatically. Uncomment for custom music.
encountertext = "The sand swirls around you." --Modify as necessary. It will only be read out in the action select screen.
nextwaves = {"bullettest_touhou"}
wavetimerOrig = 4.0
wavetimer = 4.0
wavespeed = 1.0
arenasize = {155, 130}

noscalerotationbug = true

enemies = {
    "desert_chime"
}

enemypositions = {
    {0, 0}
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

function EncounterStarting()
    require "Animations/desert_chime_anim"

    -- Setup Fight Command
    UI.background.Set("empty")
    UI.fightbtn.Set("FIGHT_inactive")
    UI.fightbtn.color = {0.4, 0.4, 0.4}
    UI.DisableButton("FIGHT")

    -- Setup Player
    Player.maxhp = 5
    Player.hp = Player.maxhp
    Player.name = "CEROBA"
    Player.sprite.Set("monster_soul")
    Player.sprite.color = {1, 1, 1}

    spells = require "spells"
    shield = require "shield"
    tp = require "tp"

    -- Testing
    shield.setShield(10)
    tp.setTP(100)
    spells.activateSpellButton()
end

function Update()
    UpdateKeyframes()
    ApplyKeyframes()
    UpdateSplines()
end

function EnteringState(newstate, oldstate)
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