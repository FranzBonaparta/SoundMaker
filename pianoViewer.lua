local Object = require("libs.classic")
local PianoViewer = Object:extend()
local PianoKey = require("pianoKey")
local SoundMaker = require("SoundMaker")
local soundMaker = SoundMaker()
local width, whiteHeight, blackHeight = 25, 100, 50
local whiteNotes = {
  "A0", "B0",
  "C1", "D1", "E1", "F1", "G1", "A1", "B1",
  "C2", "D2", "E2", "F2", "G2", "A2", "B2",
  "C3", "D3", "E3", "F3", "G3", "A3", "B3",
  "C4", "D4", "E4", "F4", "G4", "A4", "B4",
  "C5", "D5", "E5", "F5", "G5", "A5", "B5",
  "C6", "D6", "E6", "F6", "G6", "A6", "B6",
  "C7", "D7", "E7", "F7", "G7", "A7", "B7",
  "C8"
}
local blackNotes = {
  "As0",
  "Cs1", "Ds1", "Fs1", "Gs1", "As1",
  "Cs2", "Ds2", "Fs2", "Gs2", "As2",
  "Cs3", "Ds3", "Fs3", "Gs3", "As3",
  "Cs4", "Ds4", "Fs4", "Gs4", "As4",
  "Cs5", "Ds5", "Fs5", "Gs5", "As5",
  "Cs6", "Ds6", "Fs6", "Gs6", "As6",
  "Cs7", "Ds7", "Fs7", "Gs7", "As7"
}
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
