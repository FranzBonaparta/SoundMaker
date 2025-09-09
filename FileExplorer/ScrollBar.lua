local Object = require("libs.classic")
local ScrollBar = Object:extend()

function ScrollBar:new()
    self.ratio = 0
    self.barHeight = 0
    self.barY=0
    self.barWidth = 8
    self.color={178,178,178}
end

function ScrollBar:setRatio(ratio, barHeight, barY)
    self.ratio = ratio
    self.barHeight = barHeight
    self.barY = barY
end
function ScrollBar:setColors(r,g,b)
    self.color={r,g,b}
end
function ScrollBar:draw(x, y, width, height)
    local posX = x + width - 10
    local posY = self.barY-y/2
    --local posY = math.max(60,math.min(550,self.barY))-2*y
    love.graphics.setColor(self.color[1]/255,self.color[2]/255,self.color[3]/255)
    love.graphics.rectangle("fill", posX, posY, self.barWidth, self.barHeight,4,4)
end

return ScrollBar
