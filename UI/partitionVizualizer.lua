local Object = require("libs.classic")
local ScrollBar = require("FileExplorer.ScrollBar")
local PartitionVizualizer = Object:extend()
local NoteButton = require("UI.noteButton")
local SoundMaker = require("engine.SoundMaker")
local soundMaker = SoundMaker()
function PartitionVizualizer:new()
  self.visibleLines = {}
  self.partition = {}
  self.partitionButtons = { {} }
  self.x = 0
  self.y = 20
  self.width = 600
  self.height = 600
  self.offset = 20
  self.scrollBar = ScrollBar()
  self.scrollBar:setColors(255, 0, 0)
  self.hidden = true
  self.cursorState = "arrow"
  self.actualLine = 1
end

function PartitionVizualizer:updatePartition(value, duration)
  --mainly, we reorganize partitionsButtons table before adding a new element
  --each children table's size must be <=25
  table.insert(self.partition, { note = value.note, duration = duration })
  local x, y = #self.partitionButtons >= 1 and #self.partitionButtons[#self.partitionButtons] or 0,
      #self.partitionButtons
  y = 500 + (50 * (y - 1))
  local newButton = nil
  if x < 25 and x >= 1 then
    newButton = NoteButton(x + 1, y, value.name, duration, value.note, #self.partition)
    table.insert(self.partitionButtons[#self.partitionButtons], newButton)
  elseif x >= 25 then
    y = y + 50
    table.insert(self.partitionButtons, {})
    x = #self.partitionButtons[#self.partitionButtons]
    newButton = NoteButton(x + 1, y, value.name, duration, value.note, #self.partition)
    table.insert(self.partitionButtons[#self.partitionButtons], newButton)
    --here is the print limit for partition viewer!
    if #self.partitionButtons % 4 >= 1 then
      self.actualLine = self.actualLine + 1
    end
  else
    table.insert(self.partitionButtons, {})
    newButton = NoteButton(x + 1, y, value.name, duration, value.note, #self.partition)
    table.insert(self.partitionButtons[#self.partitionButtons], newButton)
  end
  local max = self.actualLine + 2
  local min = math.max(1, self.actualLine - 2)
  self:setVisibleLines(min, max)
  if #self.partitionButtons > 4 then
    self.hidden = false
  end
  print(#self.partitionButtons, #self.visibleLines, self.hidden)
end

function PartitionVizualizer:setVisibleLines(min, max)
  self.visibleLines = {}
  --insert noteButton
  for l, line in ipairs(self.partitionButtons) do
    if l >= min and l <= max then
      table.insert(self.visibleLines, { index = l, line = self.partitionButtons[l] })
    end
  end
  --modify coord of each noteButton
  for l, line in ipairs(self.visibleLines) do
    for n, noteButton in ipairs(line.line) do
      noteButton:setCoords(n + 1, 500 + (50 * (l - 1)))
    end
  end
  self:setRatio()
end

function PartitionVizualizer:setRatio()
  local totalLines = #self.partitionButtons
  local visibleLinesCount = #self.visibleLines
  if #self.visibleLines > 0 and #self.partitionButtons > #self.visibleLines then
    local firstLineIndex = self.visibleLines[1].index

    local scrollRatio = firstLineIndex / totalLines
    local scrollBarHeight = (visibleLinesCount / totalLines) * 200
    local scrollBarY = scrollRatio * 200
    self.scrollBar:setRatio(scrollRatio, scrollBarHeight, scrollBarY)
  end
end

function PartitionVizualizer:highlightNoteButton(currentIndex)
  for _, line in ipairs(self.visibleLines) do
    for _, btn in ipairs(line.line) do
      if btn.index == currentIndex then
        btn:highlight(currentIndex)
        return
      end
    end
  end
end

function PartitionVizualizer:playPartition(simpleMusicPlayer, instrument)
  local instrumentIndex = instrument.indexChosen
  local type, attack, decay, harmonicFactors, harmonicAmplitudes =
      instrument.shapes[instrumentIndex], instrument.attacks[instrumentIndex],
      instrument.decays[instrumentIndex], instrument.factors[instrumentIndex],
      instrument.amplitudes[instrumentIndex]
  simpleMusicPlayer:playMelody(self.partition, function(f, d, a)
    return soundMaker:generatePersonnalizedNote(f, d, a, type,
      attack, decay, harmonicFactors, harmonicAmplitudes)
  end)
end

function PartitionVizualizer:draw()
  love.graphics.setColor(1, 1, 1)

  for _, line in ipairs(self.visibleLines) do
    for _, btn in ipairs(line.line) do
      btn:draw()
    end
  end
  --love.graphics.setColor(1, 1, 1)
  if not self.hidden then
    self.scrollBar:draw(800, 600, 20, 500)
  end
end

function PartitionVizualizer:mousepressed(mx, my, button)
  for _, table in ipairs(self.partitionButtons) do
    for _, btn in ipairs(table) do
      btn:mousepressed(mx, my, button)
    end
  end
end

function PartitionVizualizer:update(dt)
  for _, table in ipairs(self.partitionButtons) do
    for _, btn in ipairs(table) do
      --update noteButton color
      btn:update(dt)
      --if noteButton had changed, change also our note's duration
      if self.partition[btn.index] and self.partition[btn.index].duration ~= btn.duration then
        self.partition[btn.index].duration = btn.duration
      end
    end
  end
end

return PartitionVizualizer
