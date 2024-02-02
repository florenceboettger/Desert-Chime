-- A basic monster script skeleton you can copy and modify for your own creations.
comments = {"Smells like the work\rof an enemy stand.", "Poseur is posing like his\rlife depends on it.", "Poseur's limbs shouldn't be\rmoving in this way."}
commands = {"Act 1", "Act 2", "Act 3"}
randomdialogue = {"Random\nDialogue\n1.", "Random\nDialogue\n2.", "Random\nDialogue\n3."}

sprite = "spr_sir_slither_body_0" --Always PNG. Extension is added automatically.
name = "Sir Slither, Esq."
hp = 100
atk = 1
def = 1
check = "..."
dialogbubble = "right" -- See documentation for what bubbles you have available.
canspare = false
cancheck = true
filename = "sir_slither_esq"

dialogbubble = "top"
SetBubbleOffset(-10, 110)

speed = 1

-- Happens after the slash animation but before 
--[[function HandleAttack(attackstatus)
    if attackstatus == -1 then
        -- player pressed fight but didn't press Z afterwards
    else
        hp = hp + attackstatus
    end
end

-- This handles the commands; all-caps versions of the commands list you have above.
function HandleCustomCommand(command)
    if command == "ACT 1" then
        currentdialogue = {"Selected\nAct 1."}
    elseif command == "ACT 2" then
        currentdialogue = {"Selected\nAct 2."}
    elseif command == "ACT 3" then
        currentdialogue = {"Selected\nAct 3."}
    end
    BattleDialog({"You selected " .. command .. "."})
end]]