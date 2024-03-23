BowllSprites = {}

for _, monster in ipairs(enemies) do
    if monster["filename"] == "bowll" then
        BowllSprites.body = monster["monstersprite"]
        break
    end
end

local blink = {
    normal = {
        "spr_bowll_head_normal_0",
        "spr_bowll_head_normal_0",
        "spr_bowll_head_normal_0",
        "spr_bowll_head_normal_1",
        "spr_bowll_head_normal_2",
        "spr_bowll_head_normal_1",
        "spr_bowll_head_normal_0",
        "spr_bowll_head_normal_0",
    },
    side = {
        "spr_bowll_head_side_0",
        "spr_bowll_head_side_0",
        "spr_bowll_head_side_0",
        "spr_bowll_head_side_1",
        "spr_bowll_head_side_2",
        "spr_bowll_head_side_1",
        "spr_bowll_head_side_0",
        "spr_bowll_head_side_0",
    }
}

local idle = {
    normal = {
        "spr_bowll_head_normal_0"
    },
    side = {
        "spr_bowll_head_side_0"
    },
    judgmental = {
        "spr_bowll_head_judgmental_0",
        "spr_bowll_head_judgmental_0",
        "spr_bowll_head_judgmental_0",
        "spr_bowll_head_judgmental_0",
        "spr_bowll_head_judgmental_0",
        "spr_bowll_head_judgmental_0",
        "spr_bowll_head_judgmental_1",
        "spr_bowll_head_judgmental_1",
        "spr_bowll_head_judgmental_1",
        "spr_bowll_head_judgmental_1",
        "spr_bowll_head_judgmental_0",
        "spr_bowll_head_judgmental_2",
        "spr_bowll_head_judgmental_2",
        "spr_bowll_head_judgmental_2",
        "spr_bowll_head_judgmental_2",
        "spr_bowll_head_judgmental_2",
        "spr_bowll_head_judgmental_2",
        "spr_bowll_head_judgmental_0",
        "spr_bowll_head_judgmental_0",
        "spr_bowll_head_judgmental_0",
        "spr_bowll_head_judgmental_0",
    }
}

local inTransition = {
    normal = {
        "spr_bowll_head_normal_1",
    },
    side = {
        "spr_bowll_head_side_transition_0",
        "spr_bowll_head_side_transition_1",
        "spr_bowll_head_side_transition_1",
        "spr_bowll_head_side_transition_1",
        "spr_bowll_head_side_transition_1",
        "spr_bowll_head_side_transition_1",
        "spr_bowll_head_side_transition_1",
    },
    judgmental = {
        "spr_bowll_head_judgmental_transition_0",
    },
    transition = {
        -- no in transition
    }
}

local outTransition = {
    normal = {
        "spr_bowll_head_normal_1",
    },
    side = {
        -- no out transition
    },
    judgmental = {
        -- no out transition
    },
    transition = {
        -- no out transition
    }
}

local function resetHeadAnimation()
    if blink[BowllSprites.head["expression"]] ~= nil then
        BowllSprites.head.SetAnimation(blink[BowllSprites.head["expression"]], 1/30 * 3)
        BowllSprites.head.loopmode = "ONESHOT"
    end
end

local function activateSmoke(id)
    BowllSprites.nostrils.alpha = 1
    for i = 1, 2 do
        local smoke = BowllSprites.smoke[2 * id + i]
        smoke.Scale(smoke["direction"] * 0.5, 0.5)
        smoke.MoveTo(1 + smoke["direction"] * 11, 0)
        if BowllSprites.head["expression"] == "side" then
            smoke.Move(2, 0)
        end
        smoke.alpha = 1
        smoke["xspeed"] = 2 * smoke["direction"]
        smoke["yspeed"] = 0
        smoke["gravity"] = 1
    end
end

function ChangeBowllExpression(newExpression)
    local oldExpression = BowllSprites.head["expression"]
    if newExpression == oldExpression then
        return
    end
    BowllSprites.head["futureExpression"] = newExpression
    BowllSprites.head["expression"] = "transition"
    BowllSprites.nostrils.alpha = 0
    local transitionSprites = {}
    for _, spr in ipairs(outTransition[oldExpression]) do
        table.insert(transitionSprites, spr)
    end
    table.insert(transitionSprites, "spr_bowll_head_normal_2")
    for _, spr in ipairs(inTransition[newExpression]) do
        table.insert(transitionSprites, spr)
    end
    BowllSprites.head.SetAnimation(transitionSprites, 1/30 * 3)
end

BowllSprites.legBackFront = CreateSprite("spr_bowll_leg_back_front_0")
BowllSprites.legBackFront.SetParent(BowllSprites.body)
BowllSprites.legBackFront.SetPivot(18/38, 42/52)
BowllSprites.legBackFront.SetAnchor(30/164, 14/88)
BowllSprites.legBackFront.MoveTo(0, 0)

BowllSprites.legBackBehind = CreateSprite("spr_bowll_leg_back_behind_0")
BowllSprites.legBackBehind.SetParent(BowllSprites.body)
BowllSprites.legBackBehind.SetPivot(18/32, 34/40)
BowllSprites.legBackBehind.SetAnchor(128/164, 4/88)
BowllSprites.legBackBehind.MoveTo(0, 0)

BowllSprites.tail = CreateSprite("spr_bowll_tail_normal_0")
BowllSprites.tail.SetParent(BowllSprites.body)
BowllSprites.tail.SetPivot(32/80, 4/68)
BowllSprites.tail.SetAnchor(160/164, 60/88)
BowllSprites.tail.MoveTo(0, 0)
BowllSprites.tail.SetAnimation({
    "spr_bowll_tail_normal_0",
    "spr_bowll_tail_normal_1",
    "spr_bowll_tail_normal_2",
    "spr_bowll_tail_normal_3",
    "spr_bowll_tail_normal_4"
}, 1/30 * 5)

BowllSprites.bodyClone = CreateSprite("spr_bowll_body_normal_0")
BowllSprites.bodyClone.SetParent(BowllSprites.body)
BowllSprites.bodyClone.MoveTo(0, 0)

BowllSprites.head = CreateSprite("spr_bowll_head_normal_0")
BowllSprites.head.SetParent(BowllSprites.body)
BowllSprites.head.SetPivot(54/108, 22/106)
BowllSprites.head.SetAnchor(30/164, 42/88)
BowllSprites.head.MoveTo(0, 0)
BowllSprites.head["stageTimer"] = 0
BowllSprites.head["expression"] = "normal"
resetHeadAnimation()

BowllSprites.nostrils = CreateSprite("spr_bowll_nostrils_snort_1")
BowllSprites.nostrils.SetParent(BowllSprites.head)
BowllSprites.nostrils.SetPivot(16/32, 6/10)
BowllSprites.nostrils.SetAnchor(54/108, 22/106)
BowllSprites.nostrils.MoveTo(0, 0)
BowllSprites.nostrils.alpha = 0

BowllSprites.smoke = {}
for i = 1,6 do
    BowllSprites.smoke[i] = CreateSprite("spr_bowll_nostrils_cloud_0")
    BowllSprites.smoke[i].SetParent(BowllSprites.head)
    BowllSprites.smoke[i].SetPivot(20/42, 20/38)
    BowllSprites.smoke[i].SetAnchor(54/108, 22/106)
    if i % 2 == 1 then
        BowllSprites.smoke[i].MoveTo(-12, 0)
        BowllSprites.smoke[i]["direction"] = -1
    else
        BowllSprites.smoke[i].MoveTo(10, 0)
        BowllSprites.smoke[i]["direction"] = 1
    end
    BowllSprites.smoke[i].alpha = 0
end

BowllSprites.legForeFront = CreateSprite("spr_bowll_leg_fore_front_0")
BowllSprites.legForeFront.SetParent(BowllSprites.body)
BowllSprites.legForeFront.SetPivot(18/32, 70/80)
BowllSprites.legForeFront.SetAnchor(70/164, 28/88)
BowllSprites.legForeFront.MoveTo(0, 0)

BowllSprites.legForeBehind = CreateSprite("spr_bowll_leg_fore_behind_0")
BowllSprites.legForeBehind.SetParent(BowllSprites.body)
BowllSprites.legForeBehind.SetPivot(16/44, 68/76)
BowllSprites.legForeBehind.SetAnchor(142/164, 32/88)
BowllSprites.legForeBehind.MoveTo(0, 0)

local normalStages = {40, 50, 70, 80}
local gratefulStages = {1, 10, 30, 40}
local criticalStages = {1, 10, 30, 40}

PreBowllUpdate = Update

function Update()
    if PreBowllUpdate then
        PreBowllUpdate()
    end
    
    if BowllSprites.head["expression"] == "side" then
        BowllSprites.nostrils.MoveTo(2, 0)
    elseif BowllSprites.head["expression"] ~= "transition" then
        BowllSprites.nostrils.MoveTo(0, 0)
    end

    if BowllSprites.head["expression"] == "transition" and BowllSprites.head.animcomplete then
        BowllSprites.head["stageTimer"] = 0
        BowllSprites.head["expression"] = BowllSprites.head["futureExpression"]
        BowllSprites.head["futureExpression"] = nil
        BowllSprites.head.SetAnimation(idle[BowllSprites.head["expression"]], 1/30 * 3)
    end
    if BowllSprites.head["expression"] == "judgmental" and BowllSprites.head.animcomplete then
        ChangeBowllExpression("normal")
    end

    if BowllSprites.head["expression"] ~= "transition" and BowllSprites.head["expression"] ~= "judgmental" then
        BowllSprites.head["stageTimer"] = BowllSprites.head["stageTimer"] + Time.dt

        if BowllSprites.head["stageTimer"] >= 40/30 and BowllSprites.head["stageTimer"] - Time.dt < 40/30 then
            resetHeadAnimation()
        end

        local stages = normalStages

        if BowllSprites.head["stageTimer"] >= stages[1]/30 and BowllSprites.head["stageTimer"] - Time.dt < stages[1]/30 then
            BowllSprites.nostrils.alpha = 0
        elseif BowllSprites.head["stageTimer"] >= stages[2]/30 and BowllSprites.head["stageTimer"] - Time.dt < stages[2]/30 then
            activateSmoke(0)
        elseif BowllSprites.head["stageTimer"] >= stages[2]/30 + 3/30 and BowllSprites.head["stageTimer"] - Time.dt < stages[2]/30 + 3/30 then
            activateSmoke(1)
        elseif BowllSprites.head["stageTimer"] >= stages[2]/30 + 6/30 and BowllSprites.head["stageTimer"] - Time.dt < stages[2]/30 + 6/30 then
            activateSmoke(2)
        elseif BowllSprites.head["stageTimer"] >= stages[3]/30 and BowllSprites.head["stageTimer"] - Time.dt < stages[3]/30 then
            BowllSprites.nostrils.alpha = 0
        elseif BowllSprites.head["stageTimer"] >= stages[4]/30 then
            BowllSprites.head["stageTimer"] = 0
            resetHeadAnimation()
        end
    end

    for _, smoke in ipairs(BowllSprites.smoke) do
        if smoke.alpha > 0 then
            smoke["yspeed"] = smoke["yspeed"] + smoke["gravity"] * Time.dt * 30
            smoke.Move(
                smoke["xspeed"] * Time.dt * 30,
                smoke["yspeed"] * Time.dt * 30)
            smoke.xscale = smoke.xscale + smoke["direction"] * 0.05 * Time.dt * 30
            smoke.yscale = smoke.yscale + 0.05 * Time.dt * 30

            smoke.alpha = smoke.alpha - 0.1 * Time.dt * 30
        end
    end
end