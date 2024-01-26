local self = {}

self.dialogue = {}
self.currentLine = 0
self.hidePlayer = false
self.arenaY = -1
self.active = false

function self.parseLine(i)
    self.currentLine = i
    for k, v in pairs(self.dialogue[self.currentLine]) do
        if k == "main_text" then
            BattleDialog({v})
            State("DIALOGRESULT")
            if self.hidePlayer then
                Player.sprite.MoveTo(-100, -100)
            end
            Arena.MoveTo(Arena.x, self.arenaY, false, true)
            return
        else
            for j, enemy in ipairs(enemies) do
                if enemy["name"] == k then
                    enemies[j]["currentdialogue"] = {v}
                end
            end
        end
    end
    State("ENEMYDIALOGUE")
    if self.hidePlayer then
        Player.sprite.MoveTo(-100, -100)
    end
    Arena.MoveTo(Arena.x, self.arenaY, false, true)
end

function self.loadDialogue(dialogue, hidePlayer, arenaY)
    if hidePlayer == nil then
        hidePlayer = false
    end
    if arenaY == nil then
        arenaY = Arena.y
    end
    
    self.hidePlayer = hidePlayer
    self.arenaY = arenaY
    self.dialogue = dialogue
    self.active = true
    self.parseLine(1)
end

function self.enteringState(newstate, oldstate)
    if self.active and ((oldstate == "DIALOGRESULT" and newstate == "ENEMYDIALOGUE") or (oldstate == "ENEMYDIALOGUE" and newstate == "DEFENDING")) then
        if self.currentLine == #(self.dialogue) then
            self.active = false
            State("DEFENDING")
            return
        end
        self.parseLine(self.currentLine + 1)
    end
end

return self