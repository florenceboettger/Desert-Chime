--easeBezier = require "easeBezier"
--parseDialogue = require "parseDialogue"
require "ScriptOwnerBypass"

-- music = "shine_on_you_crazy_diamond" --Either OGG or WAV. Extension is added automatically. Uncomment for custom music.
encountertext = "The sand swirls around you." --Modify as necessary. It will only be read out in the action select screen.
nextwaves = {"bullettest_touhou"}
wavetimerOrig = 4.0
wavetimer = 4.0
wavespeed = 1.0
arenasize = {100, 100}

autolinebreak = true
noscalerotationbug = true
--playerskipdocommand = true

enemies = {
    "desert_chime"
}

enemypositions = {
    {0, 50}
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

-- A custom list with attacks to choose from. Actual selection happens in EnemyDialogueEnding(). Put here in case you want to use it.
possible_attacks = {"bullettest_bouncy", "bullettest_chaserorb", "bullettest_touhou"}

LabelBarDiff = 0
HPBarDiff = 0

function EncounterStarting()
    LabelBarDiff = UI.hpbar.background.absx - (UI.hplabel.absx + UI.hplabel.width)
    HPBarDiff = UI.hptext.absx - (UI.hpbar.background.absx + UI.hpbar.background.xscale)
    require "Animations/desert_chime_anim"
    
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
    Player.sprite.rotation = -90
    UI.background.Set("empty")

    tp = require "tp"
    tp.grazeSpriteColor = {132, 132, 132}

    -- Testing
    --tp.setTP(100)
end

function Update()
    UI.hplabel.absx = 162
    UI.hpbar.background.absx = UI.hplabel.absx + UI.hplabel.width + LabelBarDiff
    UI.hptext.absx = UI.hpbar.background.absx + UI.hpbar.background.xscale + HPBarDiff

    if DesertChimeAnim then
        UpdateKeyframes()
        ApplyKeyframes()
        UpdateSplines()
    end
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