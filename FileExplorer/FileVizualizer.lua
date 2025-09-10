local Object = require("libs.classic")
local FileVizualizer = Object:extend()
local ScrollBar = require("FileExplorer.ScrollBar")
local FileExplorer = require("FileExplorer.FileExplorer")
local FileEntry = require("FileExplorer.FileEntry")
local FolderEntry = require("FileExplorer.FolderEntry")

function FileVizualizer:new(identity, path)
    self.files = {}
    self.folders = {}
    self.lines = {}
    self.visibleLines = {}
    self.index = 1
    self.path = path
    self.identity = identity
    self.x = 0
    self.y = 20
    self.width = 600
    self.height = 600
    self.offset = 20
    self.scrollBar = ScrollBar()
    self.hidden = false
    self.cursorState = "arrow"
end

function FileVizualizer:init()
    love.filesystem.setIdentity(self.identity)
    local exist = FileExplorer.didExist(self.path)
    if not exist then
        love.filesystem.createDirectory(self.path)
    end
    local files = FileExplorer.getFiles(self.path)
    local folders = FileExplorer.getFolders(self.path)
    for _, file in ipairs(files) do
        local newEntry = FileEntry(self.path, file)
        table.insert(self.files, newEntry)
    end
    for _, folder in ipairs(folders) do
        local newEntry = FolderEntry(self.path, folder)
        table.insert(self.folders, newEntry)
    end
    self:dispatchToLines()
end

function FileVizualizer:reset()
    self.files = {}
    self.folders = {}
    self.lines = {}
    self.visibleLines = {}
    self:init()
end

--set lines to make flex
function FileVizualizer:dispatchToLines()
    self.lines = {}

    local filesPerRow = math.floor(self.width / (self.offset + 64)) -- 64 = largeur de ton Draws.file + marge
    --[[for _, folder in ipairs(self.folders) do
        self:insertItem(folder)
    end]]
    for i, file in ipairs(self.files) do
        self:insertItem(file)
    end

    --set visible lines
    self:setVisibleLines(1, filesPerRow)
    self:setRatio()
end

function FileVizualizer:insertItem(item)
    local filesPerRow = math.floor(self.width / (self.offset + 64)) -- 64 = largeur de ton Draws.file + marge
    local lastLine = #self.lines
    if lastLine >= 1 then
        if #self.lines[lastLine] and #self.lines[lastLine] >= filesPerRow then
            table.insert(self.lines, { item })
        else
            table.insert(self.lines[lastLine], item)
        end
    else
        table.insert(self.lines, { item })
    end
end

function FileVizualizer:setVisibleLines(min, max)
    self.visibleLines = {}
    --insert files
    for l, line in ipairs(self.lines) do
        if l >= min and l <= max then
            table.insert(self.visibleLines, { index = l, line = self.lines[l] })
        end
    end
    --modify coord of each files
    for l, line in ipairs(self.visibleLines) do
        for f, file in ipairs(line.line) do
            file:setCoord(self.x + (f - 1) * (self.offset + 64), self.y + (l - 1) * (self.offset + 64))
        end
    end
end

function FileVizualizer:draw()
    self:drawBorders()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    for _, line in ipairs(self.visibleLines) do
        for _, file in ipairs(line.line) do
            file:draw()
        end
    end
    if #self.lines > #self.visibleLines then
        --self.scrollBar:setCoords(self.x, self.y, self.width)
        self.scrollBar:draw(self.x, self.y-75, self.width)
    end
end

function FileVizualizer:drawBorders()
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.rectangle("fill", self.x, self.y - self.offset, self.width, self.offset)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", self.width + self.x - self.offset, self.y - self.offset, self.offset, self.offset)
    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local height = font:getHeight()
    local width = font:getWidth(self.path)
    love.graphics.print(self.path, self.x + (self.width - width) / 2, self.y - (self.offset + height) / 2)
    width = font:getWidth("X")
    love.graphics.print("X", self.x + self.width - (self.offset + width) / 2, self.y - (self.offset + height) / 2)
end

function FileVizualizer:mouseHoverBorders(mx, my)
    return mx <= self.width + self.x and mx >= self.width + self.x - self.offset
        and my <= self.y and my >= self.y - self.offset
end

function FileVizualizer:mousepressed(mx, my, button)
    if self:mouseHoverBorders(mx, my) then
        self.hidden = true
    end
    for _, line in ipairs(self.lines) do
        for _, item in ipairs(line) do
            if item:isHovered(mx, my) then
                if button == 1 then
                    return item:onClick()
                    --erase a file
                elseif button == 3 then
                    local filePath = self.path .. "/" .. item.name
                    if love.filesystem.getInfo(filePath) then
                        love.filesystem.remove(self.path .. "/" .. item.name)
                        --reset in order to refresh the print of files
                        return self:reset()
                    end
                end
            end
        end
    end
end

function FileVizualizer:setRatio()
    local totalLines = #self.lines
    local visibleLinesCount = #self.visibleLines
    if #self.visibleLines > 0 and #self.lines > #self.visibleLines then
        local firstLineIndex = self.visibleLines[1].index

        local scrollRatio = firstLineIndex / totalLines
        local scrollBarHeight = (visibleLinesCount / totalLines) * self.height
        local scrollBarY = scrollRatio * self.height
        self.scrollBar:setRatio(scrollRatio, scrollBarHeight, scrollBarY)
    end
end

function FileVizualizer:wheelmoved(mx, my)
    if my < 0 then
        if self.visibleLines[#self.visibleLines].index < #self.lines then
            local firstLine, lastLine = self.visibleLines[1].index, self.visibleLines[#self.visibleLines].index
            self:setVisibleLines(firstLine + 1, lastLine + 1)
            self:setRatio()
        end
    end
    if my > 0 then
        if self.visibleLines[1].index > 1 then
            local firstLine, lastLine = self.visibleLines[1].index, self.visibleLines[#self.visibleLines].index
            self:setVisibleLines(firstLine - 1, lastLine - 1)
            self:setRatio()
        end
    end
end

function FileVizualizer:updateCursor()
    if self.hidden and self.cursorState ~= "arrow" then
        self.cursorState = "arrow"
        love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
    elseif not self.hidden then
        local canAct = false
        local mx, my = love.mouse.getPosition()
        for _, line in ipairs(self.lines) do
            for _, item in ipairs(line) do
                if item.isHovered and item:isHovered(mx, my) then
                    canAct = true
                    break
                end
            end
        end
        local wantQuit = self:mouseHoverBorders(mx, my)
        local newCursor = (canAct or wantQuit) and "hand" or "arrow"
        if self.cursorState ~= newCursor then
            love.mouse.setCursor(love.mouse.getSystemCursor(newCursor))
            self.cursorState = newCursor
        end
    end
end

function FileVizualizer:update()
    self:updateCursor()
end

function FileVizualizer:isVisible()
    return not self.hidden
end

return FileVizualizer
