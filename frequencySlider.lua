local Object = require("libs.classic")

local FrequencySlider = Object:extend()

function FrequencySlider:new(x, y, width, height, note)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.min = 0
    self.max = 100
    self.value = 50
    self.dragging = false
    self.onChange = nil
    self.cursorState = "arrow"
    self.note = note
    self.modifiedNote = self.note
    self.isModified=false
end

function FrequencySlider:setOnChange(f)
    self.onChange = f
end

function FrequencySlider:setValue(value)
    value = math.max(self.min, math.min(self.max, value))
    value = math.floor(value)

    local oldValue = self.value
    self.value = value
    if self.onChange and oldValue ~= value then
        self.onChange(value)
    end
    self.isModified=true
end

function FrequencySlider:draw()
    local xRatio, yRatio = 1, 1
    local x, y
    if (self.width > self.height) then
        xRatio = self.value / self.max
        x = self.x + self.width * xRatio
        y = self.y + self.height / 2
    else
        yRatio = self.value / self.max
        y = self.y + self.height * yRatio
        x = self.x + self.width / 2
    end
    love.graphics.setColor(1, 1, 1)
    if self:mouseIsHover(love.mouse.getX(), love.mouse.getY()) then
        local freq = math.floor(self.note * (self.value + 50) / 100)
        love.graphics.print(freq .. " Hz", self.x - 10, 225)
    end
    love.graphics.print(self.value, self.x - 5, self.y + self.height + 10)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(0.25, 0.25, 0.25)
    love.graphics.circle("fill", x, y, 5, 30)
    love.graphics.setColor(1, 1, 1)
end

function FrequencySlider:mousepressed(mx, my, button)
    if button ~= 1 and button ~= 2 then return end
    -- reset the note to initial value
    if button == 2 and self:mouseIsHover(mx, my) then
        self.modifiedNote = self.note
        self:setValue((self.modifiedNote * 100 / self.note) - 50)
        return
    end

    local buttonRadius = 3
    --horizontal
    if self.width >= self.height then
        local buttonX = self.x + self.width * (self.value / self.max)
        local buttonY = self.y + self.height / 2
        --drag modif value
        if mx <= buttonX + buttonRadius / 2 and mx > buttonX - buttonRadius / 2 and
            my <= buttonY + buttonRadius / 2 and my > buttonY - buttonRadius / 2 then
            self.dragging = true
            --direct click modif value
        elseif ((mx >= self.x and mx < buttonX - buttonRadius / 2) or
                (mx > buttonX + buttonRadius / 2 and mx <= self.x + self.width)) and
            (my <= buttonY + buttonRadius / 2 and my > buttonY - buttonRadius / 2) then
            self:setValue(self.min + ((mx - self.x) / self.width) * (self.max - self.min))
        end
        --vertical
    else
        local buttonX = self.x + self.width / 2
        local buttonY = self.y + self.height * (self.value / self.max)
        --drag modif value
        if mx <= buttonX + buttonRadius / 2 and mx > buttonX - buttonRadius / 2 and
            my <= buttonY + buttonRadius / 2 and my > buttonY - buttonRadius / 2 then
            self.dragging = true
            --direct click modif value
        elseif (mx <= buttonX + buttonRadius / 2 and mx > buttonX - buttonRadius / 2) and
            ((my >= self.y and my < buttonY - buttonRadius / 2) or
                (my > buttonY + buttonRadius / 2 and my <= self.y + self.height)) then
            self:setValue(self.min + ((my - self.y) / self.height) * (self.max - self.min))
        end
    end
end

function FrequencySlider:mousemoved(mx, my, dx, dy)
    if not self.dragging then return end

    local pos = 0
    if self.width >= self.height then
        -- Horizontal FrequencySlider
        pos = (mx - self.x) / self.width
    else
        -- Vertical FrequencySlider
        pos = (my - self.y) / self.height
    end

    -- Clamp between 0 and 1
    pos = math.max(0, math.min(1, pos))

    self:setValue(self.min + (self.max - self.min) * pos)
    --self.modifiedNote = self.note * (self.value + 50) / 100
end

function FrequencySlider:mousereleased(mx, my, button)
    if button == 1 and self.isModified then
        self.dragging = false
        self.modifiedNote = self.note * (self.value + 50) / 100
        self.isModified=false
    end
end

function FrequencySlider:mouseIsHover(mx, my)
    local isHover = false
    if mx >= self.x and mx <= self.x + self.width and
        my >= self.y and my <= self.y + self.height then
        isHover = true
    end
    return isHover
end

function FrequencySlider:update(dt)
    local mx, my = love.mouse.getPosition()
    local isHovering=self:mouseIsHover(mx, my)

    local newCursor = isHovering and "hand" or "arrow"
    if self.cursorState ~= newCursor then
        love.mouse.setCursor(love.mouse.getSystemCursor(newCursor))
        self.cursorState = newCursor
    end
    if love.mouse.isDown(1) and self.dragging then
        self:mousemoved(mx, my, 2, 2)
    end
end

return FrequencySlider
