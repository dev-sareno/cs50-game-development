PowerUp = Class{}

function PowerUp:init(type, x, y)
    self.type = type
    self.x = x
    self.y = y
    self.dy = POWER_UP_SPEED
    self.toRemove = false
end

function PowerUp:update(dt)
    self.y = self.y + self.dy * dt

    if self.y > VIRTUAL_HEIGHT then
        self.toRemove = true
    end
end

function PowerUp:render()
    local quad = {}
    if self.type == 'extra-ball' then
        quad = gFrames['power-ups'][8]
    elseif self.type == 'key' then
        quad = gFrames['power-ups'][9]
    end
    love.graphics.draw(gTextures['main'], quad, self.x, self.y)
end

function PowerUp:collides(target)
    local sx = self.x
    local sy = self.y
    local sw = 16
    local sh = 16

    local tx = target.x
    local ty = target.y
    local tw = target.width
    local th = target.height

    if (sy + sh) < ty then
        return false
    end

    if sx > (tx + tw) then
        return false
    end

    if (sx + sw) < tx then
        return false
    end

    return true
end