local Object = require("libs.classic")

local Button = Object:extend()
local defaultFont = love.graphics.newFont(14)
local Tooltip=require("UI.tooltip")

function Button:new(x, y, width, height, text, f, angle)
    self.index=nil
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text = text or " "
    self.onClick = f or nil
    self.pressed = false
    self.pressedTime = 0
    self.image = nil
    self.canReleased = true
    self.backgroundColor={0,0,0}
    self.angle=angle or 0
    self.toRemove=false
    self.locked=false
    self.tooltip=nil
end
function Button:setAngle(a)
    self.angle=a
end
function Button:setCoord(x,y)
    self.x=x
    self.y=y
end
function Button:setIndex(index)
    self.index=index
end
function Button:setText(text)
    self.text=text
end
function Button:setToRemove()
    self.toRemove=true
end
function Button:setOnClick(f)
    self.onClick=f
end
function Button:setLocked(state)
    self.locked = state
end

function Button:isLocked()
    return self.locked
end
function Button:adjustButtonSizeToText()
    local offset = 35

    local fontHeight = defaultFont:getHeight()
    local fontWidth = defaultFont:getWidth(self.text)
    self.width = fontWidth + offset + offset
    self.height = fontHeight + offset
end
function Button:setBackgroundColor(r, g, b, a)
    r, g, b = love.math.colorFromBytes(r, g, b)
    self.backgroundColor = { r, g, b, a }
end
function Button:setTooltip(text, delay, position)
    self.tooltip=Tooltip(text,self,delay,position)
end
function Button:draw()
    love.graphics.setFont(defaultFont)

    local offset = self.pressed and 2 or 0
    -- Drawing the background
    love.graphics.setColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4])
    love.graphics.rectangle("fill", self.x + offset, self.y + offset,
        self.width, self.height, self.angle, self.angle)

    if self.image then
        -- Scale calcul
        local scaleX = self.width / self.image:getWidth()
        local scaleY = self.height / self.image:getHeight()
        local imgW = self.image:getWidth() * scaleX
        local imgH = self.image:getHeight() * scaleY
        -- Center
        local imgX = self.x + offset + (self.width - imgW) / 2
        local imgY = self.y + offset + (self.height - imgH) / 2

        -- Draw the centered image
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.image, imgX, imgY, 0, scaleX, scaleY)
    end
    --center text above
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(
        self.text,
        self.x,
        self.y ,
        self.width,
        "center"
    )
    love.graphics.setColor(1, 1, 1)
 
end

function Button:setImmediate()
    self.canReleased = false
end

function Button:isHovered(mx, my)
    return mx >= self.x and mx <= self.x + self.width and
        my >= self.y and my <= self.y + self.height
end

--draw effect when clicked
function Button:mousepressed(mx, my, button)
    if button == 1 and self:isHovered(mx, my) then
        if self.canReleased == true then
            self.pressed = true
            self.pressedTime = 0.1
        else
            self.onClick()
            --print("click on "..mx..","..my)
        end
        --FxManager.play("click")
    end
end

--run onclick when released
function Button:mousereleased(mx, my, button)
    if button == 1 and self:isHovered(mx, my)
        and self.pressed == true and self.canReleased == true then
        self.onClick()
        --print("click", mx, my)
        return true -- tell parent box to stop propagation
    end
    self.pressed = false
end

function Button:update(dt)
    if self.pressed then
        self.pressedTime = self.pressedTime - dt
        if self.pressedTime <= 0 then
            self.pressed = false
        end
    end
    if self.tooltip then
        self.tooltip:update(dt)
    end
end

return Button
