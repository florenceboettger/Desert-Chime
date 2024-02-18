easeBezier = require "easeBezier"
--parseDialogue = require "parseDialogue"
require "ScriptOwnerBypass"

-- music = "shine_on_you_crazy_diamond" --Either OGG or WAV. Extension is added automatically. Uncomment for custom music.
encountertext = "The sand swirls around you." --Modify as necessary. It will only be read out in the action select screen.
nextwaves = {"martlet_wave"}
wavetimerOrig = 4.0
wavetimer = 5.0
wavespeed = 1.0
arenasize = {100, 100}

local moveMonster = {150, -150}
local moveArena = {-150, 0}

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
    CreateState("PREWAVEMOVE")
    CreateState("POSTWAVEMOVE")

    LabelBarDiff = UI.hpbar.background.absx - (UI.hplabel.absx + UI.hplabel.width)
    HPBarDiff = UI.hptext.absx - (UI.hpbar.background.absx + UI.hpbar.background.xscale)
    require "Animations/desert_chime_anim"
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
    Player.sprite.rotation = -90
    UI.background.Set("empty")

    tp = require "tp"
    tp.grazeSpriteColor = {132, 132, 132}

    YellowShot = require "yellowShot"

    -- Testing
    --tp.setTP(100)
end

local startMoveTime = -1
local totalMoveTime = 0.5

local startArenaPos = {x = 0, y = 0}
local endArenaPos = {x = 0, y = 0}
local startArenaSize = {x = 0, y = 0}
local endArenaSize = {x = 0, y = 0}
local startMonster = {x = 0, y = 0}
local endMonster = {x = 0, y = 0}

function Update()
    if (Arena.currentwidth % 2 ~= 0 or Arena.currentheight ~= 0) and not Arena.isResizing then
        Arena.ResizeImmediate(math.floor(Arena.width / 2) * 2, math.floor(Arena.height / 2) * 2)
    end

    if GetCurrentState() == "PREWAVEMOVE" then
        if (Time.time - startMoveTime) <= totalMoveTime then            
            local interp = easeBezier.ease(.28, .28, .57, 1, (Time.time - startMoveTime) / totalMoveTime)
            Arena.MoveTo(
                Mix(startArenaPos.x, endArenaPos.x, interp),
                Mix(startArenaPos.y, endArenaPos.y, interp),
                true, true)
            Arena.ResizeImmediate(
                Mix(startArenaSize.x, endArenaSize.x, interp),
                Mix(startArenaSize.y, endArenaSize.y, interp)
            )
            DesertChimeSprite.MoveTo(
                Mix(startMonster.x, endMonster.x, interp),
                Mix(startMonster.y, endMonster.y, interp)
            )
        else
            Arena.MoveTo(endArenaPos.x, endArenaPos.y, true, true)
            Arena.ResizeImmediate(endArenaSize.x, endArenaSize.y)
            DesertChimeSprite.MoveTo(endMonster.x, endMonster.y)
            State("DEFENDING")
        end
    elseif GetCurrentState() == "POSTWAVEMOVE" then
        if (Time.time - startMoveTime) <= totalMoveTime then            
            local interp = easeBezier.ease(.28, .28, .57, 1, (Time.time - startMoveTime) / totalMoveTime)
            DesertChimeSprite.MoveTo(
                Mix(endMonster.x, startMonster.x, interp),
                Mix(endMonster.y, startMonster.y, interp)
            )
        else
            DesertChimeSprite.MoveTo(startMonster.x, startMonster.y)
            State("ACTIONSELECT")
        end
    end

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
    if oldstate ~= "PREWAVEMOVE" and newstate == "DEFENDING" then
        startMoveTime = Time.time
        startArenaPos = {x = Arena.x, y = Arena.y}
        endArenaPos = {x = Arena.x - 140, y = Arena.y + 50}
        startArenaSize = {x = Arena.width, y = Arena.height}
        endArenaSize = {x = arenasize[1], y = arenasize[2]}
        startMonster = {x = DesertChimeSprite.x, y = DesertChimeSprite.y}
        endMonster = {x = DesertChimeSprite.x + 140, y = DesertChimeSprite.y - 140}
        State("PREWAVEMOVE")
    end
    if oldstate == "DEFENDING" then
        startMoveTime = Time.time
        Player.sprite.MoveTo(-100, -100)
        State("POSTWAVEMOVE")
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