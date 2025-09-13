local Object = require("libs.classic")
local InputName = Object:extend()
local InputField = require("libs.inputField")
local Button = require("UI.button")

function InputName:new(x, y, width, height, canEdit)
    self.inputField = InputField()
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.name = ""
    self.text=""
    self.visible = false
    self.canEdit=canEdit or 1
    self.inputField:setCoords(self.x + 64, self.y + 64,200)
    self.inputField:setColor({0,0,0})
    self.cancel = Button(self.x + 50, self.y + self.height - 100, 100, 50, "cancel")
    self.validate = Button(self.width + self.x - 200, self.y + self.height - 100, 100, 50, "validate")
    self.validated = false
    self:initButtons()
end

function InputName:initButtons()
    if self.canEdit==1 then
           self.cancel:setBackgroundColor(255, 0, 0)
    self.cancel:setAngle(20)
    self.cancel:setOnClick(function() self.visible = false end)
    self.cancel:setImmediate() 
    end

    self.validate:setBackgroundColor(0, 255, 0)
    self.validate:setAngle(20)
    self.validate:setImmediate()
    self.validate:setOnClick(function()
        if self.inputField.text then
            self.name = self.inputField.text
            
        end
        self.visible = false
            self.validated = true
    end)
end
function InputName:setText(text)
    self.text=text
end
function InputName:consumeValidation()
    if self.validated then
        self.validated = false
        return true
    end
    return false
end

function InputName:draw()
    if self:isVisible() then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        
        self.validate:draw()
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(self.text, self.x + 64, self.y + 32)
        love.graphics.setColor(1, 1, 1)
        if self.canEdit==1 then
            self.inputField:draw()
            self.cancel:draw()
        end
                

    end
end

function InputName:mousepressed(mx, my, button)
    if self:isVisible() then
        if self.canEdit==1 then
            self.inputField:mousepressed(mx, my, button)
            self.cancel:mousepressed(mx, my, button)
        end
        
        self.validate:mousepressed(mx, my, button)
        
    end
end

function InputName:keypressed(key)
    if self:isVisible() and  self.canEdit==1 then
        self.inputField:keypressed(key)
    end
end

function InputName:textinput(t)
    if self:isVisible() and self.inputField.focused and  self.canEdit==1 then
        self.inputField:textinput(t)
        self.name = self.inputField.text
        --print(self.name)
    end
end

function InputName:update(dt)
    if self:isVisible() and  self.canEdit==1 then
        self.inputField:update(dt)
    end
end

function InputName:show()
    self.visible = true
end

function InputName:hide()
    self.visible = false
end

function InputName:isVisible()
    return self.visible
end

return InputName
