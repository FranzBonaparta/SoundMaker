local WavWriter = {}

local function le16(n)
  local lo = n % 256
  local hi = math.floor(n / 256) % 256
  return string.char(lo, hi)
end

local function le32(n)
  local b1 = n % 256
  local b2 = math.floor(n/256) % 256
  local b3 = math.floor(n/65536) % 256
  local b4 = math.floor(n/16777216) % 256
  return string.char(b1, b2, b3, b4)
end

-- samples: tableau de floats [-1..1], mono
function WavWriter.writePCM16Mono(filename, samples, sampleRate)
  sampleRate = sampleRate or 44100
  local numChannels   = 1
  local bitsPerSample = 16
  local byteRate      = sampleRate * numChannels * (bitsPerSample/8)
  local blockAlign    = numChannels * (bitsPerSample/8)
  local dataBytes     = #samples * 2 -- 2 octets par échantillon int16

  local header = table.concat{
    "RIFF", le32(36 + dataBytes), "WAVE",
    "fmt ", le32(16), le16(1),            -- PCM
    le16(numChannels),
    le32(sampleRate),
    le32(byteRate),
    le16(blockAlign),
    le16(bitsPerSample),
    "data", le32(dataBytes)
  }

  local out = {header}
  for i = 1, #samples do
    local s = samples[i]
    if s ~= s then s = 0 end                     -- NaN guard
    s = math.max(-1, math.min(1, s))             -- clamp
    local v = math.floor(s * 32767 + 0.5)        -- float -> int16
    if v < 0 then v = v + 65536 end              -- two's complement
    local lo = v % 256
    local hi = math.floor(v / 256) % 256
    out[#out+1] = string.char(lo, hi)
  end
local path="musics/"..filename
 love.filesystem.createDirectory("musics")
  love.filesystem.write(path, table.concat(out))
  return filename
end


return WavWriter
