Slithers = {}

function SetupSlitherAnimation(name, hats)
    local monster
    for _, scr in ipairs(enemies) do
        if scr["filename"] == name then
            monster = scr
        end
    end
    if not monster then
        return false
    end

    local xscale = 1
    if name == "sir_slither_esq" then
        xscale = -1
    end

    local sprites = {}

    sprites.xscale = xscale

    sprites.body = monster["monstersprite"]
    sprites.body.Scale(2, 2)

    sprites.neck = CreateSprite("spr_sir_slither_neck_0")
    sprites.neck.SetParent(sprites.body)
    sprites.neck.SetPivot(7/27, 3/31)
    sprites.neck.SetAnchor(20/40, 36/37)
    sprites.neck.Scale(2 * xscale, 2)
    sprites.neck.MoveTo(0, 0)

    sprites.neckThing = CreateSprite("spr_sir_slither_neck_thing_0")
    sprites.neckThing.SetParent(sprites.neck)
    sprites.neckThing.SetPivot(11/22, 14/21)
    sprites.neckThing.SetAnchor(18/27, 30/31)
    sprites.neckThing.Scale(2 * xscale, 2)
    sprites.neckThing.MoveTo(0, 0)

    sprites.head = CreateSprite("spr_sir_slither_head_0")
    sprites.head.SetParent(sprites.neckThing)
    sprites.head.SetPivot(13/21, 8/15)
    sprites.head.SetAnchor(-1/22, 11/21)
    sprites.head.Scale(2 * xscale, 2)
    sprites.head.MoveTo(0, 0)

    sprites.bodyClone = CreateSprite("spr_sir_slither_body_0")
    sprites.bodyClone.SetParent(sprites.body)
    sprites.bodyClone.Scale(2, 2)
    sprites.bodyClone.MoveTo(0, 0)

    sprites.hats = {}

    for i = 1, hats do
        local hat = CreateSprite("spr_sir_slither_hat_0")
        hat.SetPivot(10/19, 5/16)
        if i == 1 then
            hat.SetParent(sprites.head)
            hat.SetAnchor(11/21, 13/15)
        else
            hat.SetParent(sprites.hats[i - 1])
            hat.SetAnchor(8/19, 15/16)
        end
        hat.Scale(2, 2)
        hat.MoveTo(0, 0)
        sprites.hats[i] = hat
    end

    Slithers[name] = sprites
end

PreSlitherUpdate = Update

function Update()
    if PreSlitherUpdate then
        PreSlitherUpdate()
    end

    local modTime = (Time.time / 2) % 1
    local c = 0

    local maxHats = 0
    for _, slither in pairs(Slithers) do
        maxHats = math.max(maxHats, #slither.hats)
    end

    local hatAnims = {}
    for i = 1, maxHats do
        local modTimeOffset = (modTime + i * 0.5) % 1
        hatAnims[i] = {}
        hatAnims[i].rotation = 8 * ((1 - modTimeOffset) ^ 0.5) * math.sin((modTimeOffset ^ 1.7) * 2 * math.pi)
    end

    for _, slither in pairs(Slithers) do
        local modTimeOffset = (modTime + c * 0.5) % 1
    
        local xNeck = -2.2 * (modTimeOffset ^ 0.65) * math.sin((modTimeOffset ^ 0.5) * 2 * math.pi)
        local yNeck = -2.4 * (modTimeOffset ^ 1.4) * math.sin(modTimeOffset * 3 * math.pi)
        local rotNeck = 6.5 * (modTimeOffset ^ 0.1) * math.sin((modTimeOffset ^ 0.8) * 2 * math.pi)
        local scaleModTime = math.min(modTimeOffset / (56/60), 1)
        local xScaleNeck = 2 - 0.2 * math.sin((scaleModTime ^ 2.4) * math.pi)
        local yScaleNeck = 2 - 0.8 * (0.4 - (math.abs(scaleModTime - 0.6) ^ 1.2)) * math.sin((scaleModTime ^ 1.3) * 3 * math.pi)
    
        local xNeckThing = -2.3 * (modTimeOffset ^ 0.7) * math.sin((modTimeOffset ^ 0.8) * 2 * math.pi)
        local yNeckThing = 2.5 * (modTimeOffset ^ 0.5) * math.sin((modTimeOffset ^ 1.05) * 3 * math.pi)
        local rotNeckThing = 5 * (modTimeOffset ^ 0.7) * math.sin(modTimeOffset * 3 * math.pi)
        local xScaleNeckThing = 2 + 0.2 * math.sin((modTimeOffset ^ 2) * math.pi)
        local yScaleNeckThing = 1.85 + 0.15 * math.cos(modTimeOffset * 4 * math.pi)
    
        local rotHead = -12 * ((1 - modTimeOffset) ^ 1.2) * math.sin((modTimeOffset ^ 1.1) * math.pi)
        local yScaleHead = 2
        if modTimeOffset > 10/60 and modTimeOffset < 18/60 then
            yScaleHead = 2 - 0.26 * math.sin((((modTimeOffset - 10/60)/(18/60 - 10/60)) ^ 0.70) * math.pi)
        elseif modTimeOffset > 24/60 and modTimeOffset < 34/60 then
            yScaleHead = 2 + 0.21 * math.sin((((modTimeOffset - 24/60)/(34/60 - 24/60)) ^ 0.76) * math.pi)
        elseif modTimeOffset > 41/60 and modTimeOffset < 46/60 then
            yScaleHead = 2 - 0.16 * math.sin((((modTimeOffset - 41/60)/(46/60 - 41/60)) ^ 1.34) * math.pi)
        end

        slither.neck.MoveTo(xNeck, yNeck)
        slither.neck.localRotation = rotNeck
        slither.neck.Scale(xScaleNeck * slither.xscale, yScaleNeck)

        slither.neckThing.MoveTo(xNeckThing, yNeckThing)
        slither.neckThing.localRotation = rotNeckThing
        slither.neckThing.Scale(xScaleNeckThing * slither.xscale, yScaleNeckThing)

        slither.head.localRotation = rotHead
        slither.head.yscale = yScaleHead

        for i, hat in ipairs(slither.hats) do
            hat.rotation = hatAnims[i].rotation
        end

        c = c + 1
    end
end