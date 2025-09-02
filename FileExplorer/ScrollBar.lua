local Object = require("libs.classic")
local ScrollBar = Object:extend()

function ScrollBar:new()
    self.ratio = 0
    self.barHeight = 0
    self.barY=0
    self.barWidth = 8
end

function ScrollBar:setRatio(ratio, barHeight, barY)
    self.ratio = ratio
    self.barHeight = barHeight
    self.barY = barY
end

function ScrollBar:draw(x, y, width, height)
    local posX = x + width - 10
    local posY = self.barY - y + 10
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.rectangle("fill", posX, posY, self.barWidth, self.barHeight,4,4)
end

return ScrollBar
