local self = {}

self.dialogue = {}
self.currentLine = 0
self.overrideUI = false
self.textboxSprite = nil
self.mainTextX = 0
self.arenaY = 0
self.active = false
self.enemySet = {}

local function parseMainText(mainText, prevText, line)
    local text = mainText.text
    if self.overrideUI then
        text = "[font:uidialognew][linespacing:6]" .. text
    end
    if mainText.character ~= nil then
        text = ("[effect:shake,0][voice:snd_talk_%s]%s"):format(mainText.character, text)
        if mainText.portrait then
            local sprite0 = ("%s/%s_0"):format(mainText.character, mainText.portrait)
            if mainText.anim then
                local sprite1 = ("%s/%s_1"):format(mainText.character, mainText.portrait)
                text = ("[mugshot:{%s,%s}]%s[mugshot:%s]"):format(sprite0, sprite1, text, sprite0)
            else
                text = ("[mugshot:%s]%s"):format(sprite0, text)
            end
        end
    end
    table.insert(prevText, text)

    -- handle multiple maintext dialogs at once - otherwise there is a frame delay
    if self.dialogue[line + 1].main_text ~= nil then
        self.currentLine = line + 1
        prevText = parseMainText(self.dialogue[line + 1].main_text, prevText, line + 1)
    end

    return prevText
end

local function resetUI()
    if self.overrideUI then
        Player.sprite.MoveTo(-100, -100)
        Arena.MoveTo(Arena.x, 21, false, true)
        UI.mugshot.MoveTo(12, -4)
    else
        UI.mugshot.MoveTo(12, 0)
    end
end

function self.parseLine(i)
    self.enemySet = {}
    self.currentLine = i
    for k, v in pairs(self.dialogue[self.currentLine]) do
        if k == "main_text" then
            local dialog = parseMainText(v, {}, i)
            BattleDialog(dialog)
            resetUI()
            return
        else
            for j, enemy in ipairs(enemies) do
                if enemy["filename"] == k then
                    enemies[j]["currentdialogue"] = {v}
                    self.enemySet[enemy["filename"]] = true
                elseif not self.enemySet[enemy["filename"]] then
                    enemies[j]["currentdialogue"] = {""}
                end
            end
        end
    end
    State("ENEMYDIALOGUE")
    resetUI()
end

function self.loadDialogue(dialogue, overrideUI)
    if overrideUI == nil then
        overrideUI = false
    end
    
    if overrideUI then
        UI.Hide(true)
        Arena.Hide(true)

        self.mainTextX = UI.maintext.x
        UI.maintext.x = self.mainTextX + 7
        self.arenaY = Arena.y

        self.textboxSprite = CreateSprite("textbox", "BelowUI")
        self.textboxSprite.SetPivot(0, 0)
        self.textboxSprite.MoveTo(32, 8)
    end
    
    self.overrideUI = overrideUI
    self.dialogue = dialogue
    self.active = true
    self.parseLine(1)
end

function self.enteringState(newstate, oldstate)
    if self.active and ((oldstate == "DIALOGRESULT" and newstate == "ENEMYDIALOGUE") or (oldstate == "ENEMYDIALOGUE" and newstate == "DEFENDING")) then
        if self.currentLine == #(self.dialogue) then
            self.active = false
            UI.mugshot.MoveTo(0, 0)
            if self.overrideUI then
                UI.Hide(false)
                Arena.Show()
                Arena.MoveTo(Arena.x, self.arenaY)
                UI.maintext.x = self.mainTextX
                self.textboxSprite.Remove()
            end
            State("DEFENDING")
            return
        end
        self.parseLine(self.currentLine + 1)
    end
end

return self