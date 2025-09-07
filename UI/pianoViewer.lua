local Object = require("libs.classic")
local PianoViewer = Object:extend()
local PianoKey = require("UI.pianoKey")
local SoundMaker = require("engine.SoundMaker")
local soundMaker = SoundMaker()
local width, whiteHeight, blackHeight = 25, 100, 50
local Notes = require("assets.notes")
local whiteNotes = Notes.whiteNotesName
local blackNotes = Notes.blackNotesName
local NoteButton = require("UI.noteButton")
function PianoViewer:new(x, y)
  self.x = x
  self.y = y
  self.whiteTouches = {}
  self.blackTouches = {}
  self.partition = {}
  self.partitionText = { "Partition jouée:\n" }
  self.partitionButtons = { {} }
  self.restTouche = {}
  for w = 1, 52 do
    local whiteKey = PianoKey("white", x, y, width, whiteHeight)
    whiteKey:setName(whiteNotes[w])
    table.insert(self.whiteTouches, whiteKey)
  end
  -- Ex: pattern C-D-E F-G-A-B → 7 white keys per octave
  local pattern = { true, true, false, true, true, true, false } -- positions with quarter note
  -- Manual addition of the isolated black key (As0)
  local firstBlackKey = PianoKey("black", x, y, width, blackHeight, true)
  table.insert(self.blackTouches, firstBlackKey)

  for i = 3, #self.whiteTouches - 1 do
    local pos = ((i - 3) % 7) + 1
    if pattern[pos] then
      local blackKey = PianoKey("black", x, y, width, blackHeight)
      blackKey:setWhiteIndex(i)
      table.insert(self.blackTouches, blackKey)
    end
  end
  for n, note in ipairs(self.blackTouches) do
    note:setName(blackNotes[n])
  end
  local restKey = PianoKey("white", x, y, width, whiteHeight)
  restKey:setName("_ _")
  restKey.note = 0
  restKey.frequencySlider = nil
  self.restTouche = restKey
end

--draw white touches
local function drawWhiteTouches(self)
  for _, touch in ipairs(self.whiteTouches) do
    touch:draw()
  end
end
--draw black touches
local function drawBlackTouches(self)
  for _, b in ipairs(self.blackTouches) do
    b:draw()
  end
end

function PianoViewer:draw()
  drawWhiteTouches(self)
  drawBlackTouches(self)
  self.restTouche:draw()
  love.graphics.setColor(1, 1, 1)
  --love.graphics.printf(self.text, self.x, 500, 1200)
  for _, table in ipairs(self.partitionButtons) do
    for _, btn in ipairs(table) do
      btn:draw()
    end
  end
end

function PianoViewer:updatePartition(value, duration)
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

function PianoViewer:highlightNoteButton(currentIndex)
for _, row in ipairs(self.partitionButtons) do
    for _, btn in ipairs(row) do
        if btn.index == currentIndex then
        btn:highlight(currentIndex)
        return
      end
    end
  end
end

function PianoViewer:highlightNote(note, duration)
  if note == 0 then
    self.restTouche:highlight(duration)
    return
  end
  for _, key in ipairs(self.whiteTouches) do
    if key.note == note then
      key:highlight(duration)
      return
    end
  end
  for _, key in ipairs(self.blackTouches) do
    if key.note == note then
      key:highlight(duration)
      return
    end
  end
end

function PianoViewer:playPartition(simpleMusicPlayer, instrument)
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

function PianoViewer:mousepressed(mx, my, button, instrument)
  local duration = 0
  if button == 1 then duration = 0.2 elseif button == 2 then duration = 0.1 elseif button == 3 then duration = 0.4 end
  if button == 1 or button == 2 or button == 3 then
    for _, value in ipairs(self.blackTouches) do
      if value:mouseIsHover(mx, my) then
        self:updatePartition(value, duration)
        value:play(duration, instrument)
        --print(value.note)
        return
      end
      value:mousepressed(mx, my, button)
    end
    for _, value in ipairs(self.whiteTouches) do
      if value:mouseIsHover(mx, my) then
        self:updatePartition(value, duration)
        value:play(duration, instrument)
        --print(value.note)

        return
      end
      value:mousepressed(mx, my, button)
    end
    if self.restTouche:mouseIsHover(mx, my) then
      self:updatePartition(self.restTouche, duration)
      self.restTouche:play(duration, instrument)
      return
    end
  end
    for _, table in ipairs(self.partitionButtons) do
    for _, btn in ipairs(table) do
      btn:mousepressed(mx, my, button)
    end
  end
end

function PianoViewer:mousereleased(mx, my, button)
  for _, value in ipairs(self.blackTouches) do
    value:mousereleased(mx, my, button)
  end
  for _, value in ipairs(self.whiteTouches) do
    value:mousereleased(mx, my, button)
  end
end

function PianoViewer:update(dt)
  for _, value in ipairs(self.blackTouches) do
    value:update(dt)
  end
  for _, value in ipairs(self.whiteTouches) do
    value:update(dt)
  end
  self.restTouche:update(dt)

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

return PianoViewer
