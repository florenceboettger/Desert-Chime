local self = {}

CreateState("PREWAVEMOVE")
CreateState("POSTWAVEMOVE")

self.active = true
self.circleArena = true

self.totalMoveTime = 0.5
self.borderWidth = 5

self.monsterSprite = nil;

self.arenaOffset = {x = 0, y = 0}
self.monsterOffset = {x = 0, y = 0}

local outerArenaCircleSprite = CreateSprite("circle", "BelowArena")
outerArenaCircleSprite.alpha = 0

local innerArenaCircleSprite = CreateSprite("circle")
innerArenaCircleSprite.SetParent(outerArenaCircleSprite)
innerArenaCircleSprite.color = {0, 0, 0}
innerArenaCircleSprite.alpha = 0

local startMoveTime = -1

local startArenaPos = {x = 0, y = 0}
local endArenaPos = {x = 0, y = 0}
local startArenaSize = {x = 0, y = 0}
local endArenaSize = {x = 0, y = 0}
local startMonster = {x = 0, y = 0}
local endMonster = {x = 0, y = 0}

local arenaCurves = {}
local innerCurves = {}
local circleBezierConstant = 0.265216 -- 4/3 * tan(pi/16)
local sqrtPointFive = math.sqrt(2)/2

local function arenaCenter()
    return {
        x = Arena.currentx,
        y = Arena.currenty + Arena.currentheight/2
    }
end

local function arenaWidth()
    return Arena.currentwidth + self.borderWidth
end

local function arenaHeight()
    return Arena.currentheight + self.borderWidth
end

local function updateArenaCurves(curves, interp)
    for i = 1, 4 do
        local horizontalDir = (i % 2 == 0) and 1 or -1
        local verticalDir = (math.floor((i - 1) / 2) == 0) and 1 or -1
        local outerPoint = {
            x = arenaCenter().x,
            y = arenaCenter().y - verticalDir * arenaHeight()/2}
        local innerPoint = {
            x = arenaCenter().x + horizontalDir * arenaWidth()/2 * sqrtPointFive,
            y = arenaCenter().y - verticalDir * arenaHeight()/2 * sqrtPointFive}
        curves[i].movepoint(1,
            outerPoint.x,
            outerPoint.y)
        curves[i].movepoint(2,
            outerPoint.x + horizontalDir * arenaWidth()/2 * circleBezierConstant,
            outerPoint.y)
        curves[i].movepoint(3,
            Mix(outerPoint.x + horizontalDir * arenaWidth()/2 + self.borderWidth/2, innerPoint.x, interp),
            Mix(outerPoint.y, innerPoint.y, interp))
        curves[i].movepoint(4,
            Mix(outerPoint.x + horizontalDir * arenaWidth()/2 * (1 - circleBezierConstant), innerPoint.x - horizontalDir * arenaWidth()/2 * sqrtPointFive * circleBezierConstant, interp),
            Mix(outerPoint.y, innerPoint.y - verticalDir * arenaHeight()/2 * sqrtPointFive * circleBezierConstant, interp))
    end
    for i = 5, 8 do
        local horizontalDir = (i % 2 == 0) and 1 or -1
        local verticalDir = (math.floor((i - 5) / 2) == 0) and 1 or -1
        local outerPoint = {
            x = arenaCenter().x - horizontalDir * arenaWidth()/2,
            y = arenaCenter().y}
        local innerPoint = {
            x = arenaCenter().x - horizontalDir * arenaWidth()/2 * sqrtPointFive,
            y = arenaCenter().y + verticalDir * arenaHeight()/2 * sqrtPointFive}
        curves[i].movepoint(1,
            outerPoint.x,
            outerPoint.y)
        curves[i].movepoint(2,
            outerPoint.x,
            outerPoint.y + verticalDir * arenaHeight()/2 * circleBezierConstant)
        curves[i].movepoint(3,
            Mix(outerPoint.x, innerPoint.x, interp),
            Mix(outerPoint.y + verticalDir * arenaHeight()/2 + self.borderWidth/2, innerPoint.y, interp))
        curves[i].movepoint(4,
            Mix(outerPoint.x, innerPoint.x - horizontalDir * arenaWidth()/2 * sqrtPointFive * circleBezierConstant, interp),
            Mix(outerPoint.y + verticalDir * arenaHeight()/2 * (1 - circleBezierConstant), innerPoint.y - verticalDir * arenaHeight()/2 * sqrtPointFive * circleBezierConstant, interp))
    end
end

PostRoundArenaUpdate = Update

function Update()
    if (Arena.currentwidth % 2 ~= 0 or Arena.currentheight ~= 0) and not Arena.isResizing then
        Arena.ResizeImmediate(math.floor(Arena.width / 2) * 2, math.floor(Arena.height / 2) * 2)
    end

    if GetCurrentState() == "PREWAVEMOVE" then
        if (Time.time - startMoveTime) <= self.totalMoveTime then
            local interp = easeBezier.ease(.28, .28, .57, 1, (Time.time - startMoveTime) / self.totalMoveTime)
            Arena.MoveTo(
                Mix(startArenaPos.x, endArenaPos.x, interp),
                Mix(startArenaPos.y, endArenaPos.y, interp),
                true, true)
            Arena.ResizeImmediate(
                Mix(startArenaSize.x, endArenaSize.x, interp),
                Mix(startArenaSize.y, endArenaSize.y, interp)
            )
            self.monsterSprite.MoveTo(
                Mix(startMonster.x, endMonster.x, interp),
                Mix(startMonster.y, endMonster.y, interp)
            )
            if self.circleArena then
                Arena.Hide(false)
                for i = 1, 8 do
                    innerCurves[i].updatewidth(self.borderWidth/2 + math.min(Arena.currentwidth, Arena.currentheight)/2)
                end
                updateArenaCurves(arenaCurves, interp)
                updateArenaCurves(innerCurves, interp)
            end
        else
            Arena.MoveTo(endArenaPos.x, endArenaPos.y, true, true)
            Arena.ResizeImmediate(endArenaSize.x, endArenaSize.y)
            self.monsterSprite.MoveTo(endMonster.x, endMonster.y)
            if self.circleArena then
                for i = 1, 8 do
                    arenaCurves[i].cleardraw()
                    innerCurves[i].cleardraw()
                end
                outerArenaCircleSprite.alpha = 1
                outerArenaCircleSprite.MoveTo(arenaCenter().x, arenaCenter().y)
                outerArenaCircleSprite.Scale((Arena.currentwidth + 2 * self.borderWidth) / innerArenaCircleSprite.width, (Arena.currentheight + 2 * self.borderWidth) / innerArenaCircleSprite.height)

                innerArenaCircleSprite.alpha = 1
                innerArenaCircleSprite.Scale((Arena.currentwidth) / outerArenaCircleSprite.width, (Arena.currentheight) / outerArenaCircleSprite.height)
            end
            State("DEFENDING")
        end
    elseif GetCurrentState() == "DEFENDING" then
        local playerDist = math.sqrt(Player.x * Player.x + Player.y * Player.y)
        local width = Arena.currentwidth/2 - Player.sprite.width/2
        if playerDist > width then
            Player.MoveTo(
                Player.x / playerDist * width,
                Player.y / playerDist * width
            )
        end
    elseif GetCurrentState() == "POSTWAVEMOVE" then
        if (Time.time - startMoveTime) <= self.totalMoveTime then
            local interp = easeBezier.ease(.28, .28, .57, 1, (Time.time - startMoveTime) / self.totalMoveTime)
            self.monsterSprite.MoveTo(
                Mix(endMonster.x, startMonster.x, interp),
                Mix(endMonster.y, startMonster.y, interp)
            )
        else
            self.monsterSprite.MoveTo(startMonster.x, startMonster.y)
            State("ACTIONSELECT")
        end
    end

    if PostRoundArenaUpdate then
        PostRoundArenaUpdate()
    end
end

PostRoundArenaEnteringState = EnteringState

function EnteringState(newstate, oldstate)
    if oldstate ~= "PREWAVEMOVE" and newstate == "DEFENDING" and self.active then
        startMoveTime = Time.time
        startArenaPos = {x = Arena.x, y = Arena.y}
        endArenaPos = {x = Arena.x - 140, y = Arena.y + 50}
        endArenaPos = {x = Arena.x + self.arenaOffset.x, y = Arena.y + self.arenaOffset.y}
        startArenaSize = {x = Arena.width, y = Arena.height}
        endArenaSize = {x = arenasize[1], y = arenasize[2]}
        startMonster = {x = self.monsterSprite.x, y = self.monsterSprite.y}
        endMonster = {x = self.monsterSprite.x + 140, y = self.monsterSprite.y - 140}
        endMonster = {x = self.monsterSprite.x + self.monsterOffset.x, y = self.monsterSprite.y + self.monsterOffset.y}

        if self.circleArena then
            -- certain sections need to be inverted for correct orientation
            local invert = {false, true, true, false, true, false, false, true}
            for i = 1, 8 do
                innerCurves[i] = gas.curve(0, 0, 0, 0, 0, 0, 0, 0)
                innerCurves[i].show(12, {0, 0, 0}, "BelowArena", self.borderWidth / 2 + math.max(arenasize[1], arenasize[2])/2, nil, nil, invert[i] and 0 or 1)
                arenaCurves[i] = gas.curve(0, 0, 0, 0, 0, 0, 0, 0)
                arenaCurves[i].show(12, {1, 1, 1}, "BelowArena", self.borderWidth)
            end
        end

        State("PREWAVEMOVE")
    end
    if oldstate == "DEFENDING" and self.active then
        startMoveTime = Time.time
        Player.sprite.MoveTo(-100, -100)
        if self.circleArena then
            innerArenaCircleSprite.alpha = 0
            outerArenaCircleSprite.alpha = 0
            Arena.Show()
        end
        State("POSTWAVEMOVE")
    end

    if PostRoundArenaEnteringState then
        PostRoundArenaEnteringState(newstate, oldstate)
    end
end

return self