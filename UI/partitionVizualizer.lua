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

  self.scrollBar = ScrollBar()
  --self.scrollBar:setColors(255, 0, 0)
  self.name = ""
  self.hidden = true
  self.cursorState = "arrow"
  self.actualLine = 1
  self.viewX = 50
  self.viewY = 450
  self.viewWidth = 1300
  self.viewHeight = 300
  self.maxVisibleLines = 4
  self.partitionLength = 25
end

function PartitionVizualizer:updatePartition(value, duration)
  table.insert(self.partition, { note = value.note, duration = duration })
  local newButton = nil
  local x = #self.partitionButtons[#self.partitionButtons]
  local y = #self.partitionButtons
  y = self.viewY + (50 * (y))

  if x > self.partitionLength - 1 then
    table.insert(self.partitionButtons, {})
    x = 0
    y = y + 50
    newButton = NoteButton(x, y, value.name, duration, value.note, #self.partition)
    table.insert(self.partitionButtons[#self.partitionButtons], newButton)
  elseif x <= self.partitionLength - 1 then
    newButton = NoteButton(x, y, value.name, duration, value.note, #self.partition)
    table.insert(self.partitionButtons[#self.partitionButtons], newButton)
  else
    table.insert(self.partitionButtons, {})
    newButton = NoteButton(x, y, value.name, duration, value.note, #self.partition)
    table.insert(self.partitionButtons[#self.partitionButtons], newButton)
  end
  self:refreshVisibleLines(0)
  --print(self.actualLine)
end

function PartitionVizualizer:refreshVisibleLines(modif)
  if self.partitionButtons[self.actualLine + modif + self.maxVisibleLines] and self.partitionButtons[self.actualLine + modif] then
    self.actualLine = math.max(1, self.actualLine + modif)
  end

  self.visibleLines = {}
  for index, btn in ipairs(self.partitionButtons) do
    if index >= 1 and index >= self.actualLine and index <= self.actualLine + self.maxVisibleLines then
      table.insert(self.visibleLines, { index = index, line = self.partitionButtons[index] })
    end
  end

  for l, line in ipairs(self.visibleLines) do
    for n, noteButton in ipairs(line.line) do
      noteButton:setCoords(n, self.viewY + (50 * l))
    end
  end
  if #self.partitionButtons > self.maxVisibleLines then
    self.hidden = false
    self:setRatio()
  end
end

function PartitionVizualizer:setRatio()
  local totalLines = #self.partitionButtons
  local visibleLinesCount = #self.visibleLines
  if #self.visibleLines > 0 and #self.partitionButtons > #self.visibleLines then
    local firstLineIndex = self.visibleLines[1].index

    local scrollRatio = firstLineIndex / totalLines
    local scrollBarHeight = (visibleLinesCount / totalLines) * self.viewHeight
    local scrollBarY = scrollRatio * self.viewHeight
    self.scrollBar:setRatio(scrollRatio, scrollBarHeight, scrollBarY)
  end
end

function PartitionVizualizer:playPartition(simpleMusicPlayer, instrument)
  local instrumentIndex = instrument.indexChosen
  local waveType, attack, decay, harmonicFactors, harmonicAmplitudes =
      instrument.shapes[instrumentIndex], instrument.attacks[instrumentIndex],
      instrument.decays[instrumentIndex], instrument.factors[instrumentIndex],
      instrument.amplitudes[instrumentIndex]
  simpleMusicPlayer:playMelody(self.partition, function(f, d, a)
    return soundMaker:generatePersonnalizedNote(f, d, a, waveType,
      attack, decay, harmonicFactors, harmonicAmplitudes)
  end)
end

function PartitionVizualizer:getSamples(instrument)
  local instrumentIndex = instrument.indexChosen
  local waveType, attack, decay, harmonicFactors, harmonicAmplitudes =
      instrument.shapes[instrumentIndex], instrument.attacks[instrumentIndex],
      instrument.decays[instrumentIndex], instrument.factors[instrumentIndex],
      instrument.amplitudes[instrumentIndex]
  local samples = {}
  local sr = (soundMaker and soundMaker.sampleRate) or 44100
  for _, note in ipairs(self.partition) do
    local f0 = note.note or 0
    local dur = note.duration or 0
    if f0 == 0 or dur <= 0 then
      -- silence: insère N zéros pour conserver la durée
      local N = math.max(0, math.floor(dur * sr + 0.5))
      for i = 1, N do samples[#samples + 1] = 0 end
    else
      local newSamples = soundMaker:generatePersonnalizedSamples(note.note, note.duration, 0.3,
        waveType,
        attack, decay, harmonicFactors, harmonicAmplitudes)

      for _, sample in ipairs(newSamples) do
        table.insert(samples, sample)
      end
    end
  end
  return samples
end

function PartitionVizualizer:wheelmoved(mx, my)
  if my < 0 then
    self:refreshVisibleLines(1)
    self:setRatio()
  elseif my > 0 then
    self:refreshVisibleLines(-1)
    self:setRatio()
  end
end

function PartitionVizualizer:draw()
  for _, line in ipairs(self.visibleLines) do
    for _, btn in ipairs(line.line) do
      btn:draw()
    end
  end
  if not self.hidden then
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.viewWidth + 40, 500, self.scrollBar.barWidth, 300)
    self.scrollBar:draw(self.viewX, self.viewY, self.viewWidth)
  end
end

function PartitionVizualizer:mousepressed(mx, my, button)
  for _, line in ipairs(self.visibleLines) do
    for _, btn in ipairs(line.line) do
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
