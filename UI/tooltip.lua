local Object = require("libs.classic")

local Tooltip = Object:extend()

function Tooltip:new(text, target, delay, position)
    self.text = text
    self.target = target
    self.delay = delay or 0.5
    self.position = position or "top"
    self.hoverTime = 0
    self.isVisible = false
end

function Tooltip:draw()
    if self.isVisible then
        local mx, my = love.mouse.getPosition()
        local tooltipX, tooltipY = mx + 10, my + 10

        local font = love.graphics.getFont()
        local boxWidth = 250
        local _, wrappedText = font:getWrap(self.text, boxWidth - 16) --return a table of line
        local lineHeight = font:getHeight()
        --make the heigh flexible
        local lineCount = #wrappedText
        local boxHeight = (lineHeight * lineCount) + 16 --+padding

        love.graphics.rectangle("fill", tooltipX, tooltipY, boxWidth, boxHeight, 6, 6)
        -- bordure claire
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.rectangle("line", tooltipX, tooltipY, boxWidth, boxHeight, 6, 6)

        -- texte
        love.graphics.setColor(0, 0, 0)

        love.graphics.printf(self.text, tooltipX + 8, tooltipY + 8, boxWidth - 16)
        --reset color to white
        love.graphics.setColor(1, 1, 1)
    end
end

function Tooltip:update(dt)
    local mx, my = love.mouse.getPosition()
    if self.target.isHovered and self.target:isHovered(mx, my) then
        self.hoverTime = self.hoverTime + dt
    else
        self.hoverTime = 0
        self.isVisible = false
    end
    if self.hoverTime >= self.delay then
        self.isVisible = true
    end

end

return Tooltip
