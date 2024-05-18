return function(enemybullet, shot)
    if enemybullet["type"] == "blossom" then
        enemybullet["hit"] = true
        return not shot["bigshot"]
    elseif enemybullet["type"] == "mask" then
        enemybullet["hit"] = true
        return true
    else
        enemybullet.Remove()
        return not shot["bigshot"]
    end
end