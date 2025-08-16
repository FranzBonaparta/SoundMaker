local Object = require("libs.classic")
local PianoViewer = Object:extend()
local PianoKey = require("pianoKey")
local SoundMaker = require("SoundMaker")
local soundMaker = SoundMaker()
local width, whiteHeight, blackHeight = 25, 100, 50
local Notes=require("notes")
local whiteNotes = Notes.whiteNotesName
local blackNotes = Notes.blackNotesName
function PianoViewer:new(x, y)
  self.x = x
  self.y = y
  self.whiteTouches = {}
  self.blackTouches = {}
  self.partition = {}
  self.partitionText = "Partition jouée:\n"

  for w = 1, 52 do
    local whiteKey = PianoKey("white", x, y, width, whiteHeight)
    whiteKey:setName(whiteNotes[w])
    table.insert(self.whiteTouches, whiteKey)
  end
  -- Ex : motif C-D-E F-G-A-B → 7 touches blanches par octave
  local pattern = { true, true, false, true, true, true, false } -- positions avec noire
  -- Ajout manuel de la touche noire isolée (As0)
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
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(self.partitionText, self.x, 500, 1200)
end

function PianoViewer:updatePartition(value, duration)
  table.insert(self.partition, { note = value.note, duration = duration })
  self.partitionText = self.partitionText .. value.name .. ", "
end

function PianoViewer:playPartition(simpleMusicPlayer)
  simpleMusicPlayer:playMelody(self.partition, function(f, d, a) return soundMaker:createSineWave(f, d, a) end)
end

function PianoViewer:mousepressed(mx, my, button)
  local duration = 0
  if button == 1 then duration = 0.2 elseif button == 2 then duration = 0.1 elseif button == 3 then duration = 0.4 end
  if button == 1 or button == 2 or button == 3 then
    for _, value in ipairs(self.blackTouches) do
      if value:mouseIsHover(mx, my) then
        self:updatePartition(value, duration)
        value:play(duration)
        print(value.note)
        return
      end
      value:mousepressed(mx,my,button)
    end
    for _, value in ipairs(self.whiteTouches) do
      if value:mouseIsHover(mx, my) then
        self:updatePartition(value, duration)
        value:play(duration)
                print(value.note)

        return
      end
      value:mousepressed(mx,my,button)
    end
  end
end
function PianoViewer:mousereleased(mx,my,button)
    for _, value in ipairs(self.blackTouches) do
    value:mousereleased(mx,my,button)
  end
  for _, value in ipairs(self.whiteTouches) do
    value:mousereleased(mx,my,button)
  end
end
function PianoViewer:update(dt)
  for _, value in ipairs(self.blackTouches) do
    value:update(dt)
  end
  for _, value in ipairs(self.whiteTouches) do
    value:update(dt)
  end
end

return PianoViewer
