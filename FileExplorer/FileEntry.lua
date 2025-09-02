local Object=require("libs.classic")
local FileEntry=Object:extend()
local Draws=require("libs.Draws")

function FileEntry:new(path,name,x,y)
    self.path=path
    self.name=name
    self.fullPath=self.path.."/"..self.name
    self.x=x or 0
    self.y=y or 0
    self.width=64
    self.height=64

end
local function truncateName(name, maxLength)
    if #name > maxLength then
        return name:sub(1, maxLength - 3) .. "..."
    else
        return name
    end
end

function FileEntry:draw()
    Draws.file(self.x, self.y, 2)
    love.graphics.setColor(0, 0, 0)
    local name=truncateName(self.name,10)
    love.graphics.print(name, self.x+10, self.y + 60)
end
function FileEntry:setCoord(x,y)
    self.x=x
    self.y=y
end
function FileEntry:isHovered(mx, my)
    return mx >= self.x and mx <= self.x + self.width and
           my >= self.y and my <= self.y + self.height
end

function FileEntry:onClick()
    return self.fullPath
end

return FileEntry