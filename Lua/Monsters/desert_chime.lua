-- A basic monster script skeleton you can copy and modify for your own creations.
comments = {"..."}
commands = {}
--randomdialogue = {"[effect:rotate,15," .. -math.pi/2 .. "][charspacing:0]Ddd\nuuu\naaa\nlll\n"}
local textPrefix = "[effect:rotate,0.000001][charspacing:-2][alpha:00]I[charspacing:4][linespacing:6][alpha:ff]"
randomdialogue = {textPrefix .. "Ddd\nu\na\nlll\n...\n"}

sprite = "desert_chime_jar" --Always PNG. Extension is added automatically.
name = "Desert Chime"
hp = 100
atk = 1
def = 1
check = "..."
dialogbubble = "rightlong" -- See documentation for what bubbles you have available.
canspare = false
cancheck = true
filename = "desert_chime"

speed = 1
SetBubbleOffset(10, 6)

-- Happens after the slash animation but before 
function HandleAttack(attackstatus)
    if attackstatus == -1 then
        -- player pressed fight but didn't press Z afterwards
    else
        hp = hp + attackstatus
    end
end

-- This handles the commands; all-caps versions of the commands list you have above.
function HandleCustomCommand(command)
    --if command == "ACT 1" then
    --    currentdialogue = {"Selected\nAct 1."}
    --elseif command == "ACT 2" then
    --    currentdialogue = {"Selected\nAct 2."}
    --elseif command == "ACT 3" then
    --    currentdialogue = {"Selected\nAct 3."}
    --end
    --BattleDialog({"You selected " .. command .. "."})
end