math.randomseed(os.time())

easeBezier = require "easeBezier"
gas = require "gas"
--parseDialogue = require "parseDialogue"
require "ScriptOwnerBypass"

-- music = "shine_on_you_crazy_diamond" --Either OGG or WAV. Extension is added automatically. Uncomment for custom music.
encountertext = "The sand swirls around you." --Modify as necessary. It will only be read out in the action select screen.
local waves = {"martlet_blossoms", "martlet_corkgun", "martlet_kintsugi"}
local wavetimers = {
    martlet_blossoms = 8.0,
    martlet_corkgun = 6.7,
    martlet_kintsugi = 100000}
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

local letterPositions = {}
local letterRadius = 15

function OnTextDisplay(text)
    if text == enemies[1]["textobject"] then
        local bubbleSprite = enemies[1]["bubblesprite"]
        local textObject = enemies[1]["textobject"]
        bubbleSprite.SetPivot(0, 1 + 58 / bubbleSprite.height)
        local letters = text.GetLetters()
        local lastPos = {x = nil, y = nil, originalY = nil}
        for i, l in ipairs(letters) do
            if i > 1 then
                l.rotation = -45
                l.Scale(1.2, 1.2)
                --l.y = l.y + 10
                local originalY = l.y
                local originalX = l.x
                if lastPos.originalY and math.abs(l.y - lastPos.originalY) < 0.1 then
                    local letterDist = (l.x - lastPos.x) * 0.2
                    l.MoveTo(
                        lastPos.x + letterDist * math.sin(math.pi/4),
                        lastPos.y - letterDist * math.cos(math.pi/4)
                    )
                    l.Scale(0.8, 0.8)
                else
                    l.Move(0, -58)
                end
                letterPositions[i] = {x = l.x + 10, y = l.y, start = originalY / 200 - originalX / 100}
                lastPos = {x = l.x, y = l.y, originalY = originalY}
            end
        end
    end
end

function Update()
    UI.hplabel.absx = 162
    UI.hpbar.background.absx = UI.hplabel.absx + UI.hplabel.width + LabelBarDiff
    UI.hptext.absx = UI.hpbar.background.absx + UI.hpbar.background.xscale + HPBarDiff

    if GetCurrentState() == "PREWAVEMOVE" then
        if nextWave == "martlet_blossoms" or nextWave == "martlet_kintsugi" then
            Player.sprite.rotation = math.max(90, Player.sprite.rotation - Time.dt * 270)
        end
    elseif GetCurrentState() == "POSTWAVEMOVE" then
        if nextWave == "martlet_blossoms" or nextWave == "martlet_kintsugi" then
            Player.sprite.rotation = math.min(180, Player.sprite.rotation + Time.dt * 270)
        end
    end

    if enemies[1]["textobject"] then
        local text = enemies[1]["textobject"]
        local bubbleSprite = enemies[1]["bubblesprite"]
        bubbleSprite.Set("SpeechBubbles/rightlongoffset")
        local letters = text.GetLetters()
        for i, l in ipairs(letters) do
            if i > 1 then
                local rotateProgress = (letterPositions[i].start + Time.time / 1.5) % 1
                local easeValue = {x = .52, y = .34}
                rotateProgress = easeBezier.ease(easeValue.x, easeValue.y, 1 - easeValue.x, 1 - easeValue.y, rotateProgress)
                l.MoveTo(
                    letterPositions[i].x + letterRadius * math.sin(2 * math.pi * rotateProgress),
                    letterPositions[i].y - letterRadius * math.cos(2 * math.pi * rotateProgress)
                )
                math.randomseed(i + math.floor(Time.time * 5))
                local randomJitter = math.random()
                randomJitter = easeBezier.ease(.41, .71, .77, .89, randomJitter) * 10
                local randomAngle = 2 * math.pi * math.random()
                l.Move(
                    randomJitter * math.sin(randomAngle),
                    randomJitter * math.cos(randomAngle)
                )
            end
        end
    end
end

local lastState
local textPrefix = "[effect:rotate,0.000001][charspacing:-2][alpha:00]I[charspacing:4][linespacing:6][alpha:ff]"

function EnteringState(newstate, oldstate)
    if newstate == "ENEMYDIALOGUE" and oldstate ~= "ENEMYDIALOGUE" then
        encountertext = "..."
        lastState = oldstate
        if oldstate == "DEFENDING" then
            enemies[1]["currentdialogue"] = {textPrefix .. "Fff\nrrr\ni\ne\nnnn\nddd\nssssss\n..!"}
            encountertext = "A connection reveals itself."
        else
            waveCounter = waveCounter + 1
            nextWave = waves[math.min(#waves, waveCounter)]
            wavetimer = wavetimers[nextWave]
            if nextWave == "martlet_blossoms" then
                enemies[1]["currentdialogue"] = {textPrefix .. "A\nlll\no\nnnn\ne\n..."}
            elseif nextWave == "martlet_corkgun" then
                enemies[1]["currentdialogue"] = {textPrefix .. "Ddd\nu\na\nlll\n..."}
            elseif nextWave == "martlet_kintsugi" then
                enemies[1]["currentdialogue"] = {textPrefix .. "...\n...\n...\n...\n...\n..?"}           
                RoundArena.arenaOffset = {x = -200, y = 100}
                RoundArena.monsterOffset = {x = 140, y = -120}
            end

            nextwaves = {nextWave}
        end
    end
    if newstate == "DEFENDING" and lastState == "DEFENDING" then
        lastState = nil
        State("DIALOGUETOACTIONSELECT")
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
end

function HandleSpare()
    State("ENEMYDIALOGUE")
end

function HandleItem(ItemID)
    BattleDialog({"Selected item " .. ItemID .. "."})
end