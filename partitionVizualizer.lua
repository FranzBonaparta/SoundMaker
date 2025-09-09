local Object = require("libs.classic")
local ScrollBar = require("FileExplorer.ScrollBar")
local PartitionVizualizer=Object:extend()
local NoteButton = require("UI.noteButton")
local SoundMaker = require("engine.SoundMaker")
local soundMaker = SoundMaker()
function PartitionVizualizer:new()
      self.lines = {}
    self.visibleLines = {}
    self.partition = {}
    self.partitionButtons = { {} }
      self.x = 0
    self.y = 20
    self.width = 600
    self.height = 600
    self.offset = 20
    self.scrollBar = ScrollBar()
    self.hidden = false
    self.cursorState = "arrow"
end
function PartitionVizualizer:updatePartition(value, duration)
  --mainly, we reorganize partitionsButtons table before adding a new element
  --each children table's size must be <=25
  table.insert(self.partition, { note = value.note, duration = duration })
  local x, y = #self.partitionButtons[#self.partitionButtons],
      #self.partitionButtons
  y = 500 + (50 * (y - 1))
  local newButton = nil
  if x < 25 then
    newButton = NoteButton(x + 1, y, value.name, duration, value.note, #self.partition)
    table.insert(self.partitionButtons[#self.partitionButtons], newButton)
  elseif x >= 25 then
    y = y + 50
    table.insert(self.partitionButtons, {})
    x = #self.partitionButtons[#self.partitionButtons]
    newButton = NoteButton(x + 1, y, value.name, duration, value.note, #self.partition)
    table.insert(self.partitionButtons[#self.partitionButtons], newButton)
  end
end

function PartitionVizualizer:highlightNoteButton(currentIndex)
for _, row in ipairs(self.partitionButtons) do
    for _, btn in ipairs(row) do
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

    for _, table in ipairs(self.partitionButtons) do
    for _, btn in ipairs(table) do
      btn:draw()
    end
  end
end

function PartitionVizualizer:mousepressed(mx,my,button)
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