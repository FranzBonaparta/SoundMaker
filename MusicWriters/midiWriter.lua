-- ==========
-- MIDI utils
-- ==========
local MidiWriter = {}
--big-endian
--convert an integer to a big-endian
-- byte sequence (most significant byte first) for the MIDI header.
-- be16 = 2bytes, be32 = 4bytes
function MidiWriter.be16(n)
  local b1 = math.floor(n / 256) % 256
  local b2 = n % 256
  return string.char(b1, b2)
end

function MidiWriter.be32(n)
  local b1 = math.floor(n / 16777216) % 256
  local b2 = math.floor(n / 65536) % 256
  local b3 = math.floor(n / 256) % 256
  local b4 = n % 256
  return string.char(b1, b2, b3, b4)
end

-- VLQ (Variable-Length Quantity) for delta times
-- encode an integer (delta-time, lengths) on 1..4 bytes,
-- 7 useful bits per byte, bit 7 = 1 for all bytes except the last.
function MidiWriter.vlq(n)
  n = math.max(0, math.floor(n + 0.5))
  local bytes = { n % 128 }
  n = math.floor(n / 128)
  while n > 0 do
    table.insert(bytes, 1, (n % 128) + 0x80)
    n = math.floor(n / 128)
  end
  return string.char(unpack(bytes))
end

-- Frequency -> note MIDI (round, clamp 0..127)
-- convert a frequency (Hz) to a MIDI note number (0..127),
-- reference A4 = 440 Hz.
function MidiWriter.freq_to_midi(f)
  if not f or f <= 0 then return nil end
  local n = 69 + 12 * (math.log(f / 440) / math.log(2))
  n = math.floor(n + 0.5)
  if n < 0 then n = 0 end
  if n > 127 then n = 127 end
  return n
end

-- Duration in seconds -> ticks (PPQN * BPM / 60)
-- convert a duration in seconds to “MIDI ticks”
-- according to the PPQN resolution and the tempo.
function MidiWriter.sec_to_ticks(sec, ppqn, bpm)
  local ticks = sec * (ppqn * bpm / 60)
  ticks = math.max(1, math.floor(ticks + 0.5)) -- au moins 1 tick si > 0
  return ticks
end

--handy utility — adds a substring of bytes
--to the track table (list of event fragments).
function MidiWriter.push(track, str) table.insert(track, str) end

--Write the meta tempo event to the start of the track.
--MIDI uses "microseconds per quarter note" (MPQN).
function MidiWriter.meta_tempo(track, bpm)
  local mpqn = math.floor(60000000 / bpm + 0.5)   -- microseconds per quarter note
  local t1 = math.floor(mpqn / 65536) % 256
  local t2 = math.floor(mpqn / 256) % 256
  local t3 = mpqn % 256
  -- delta=0, meta tempo
  MidiWriter.push(track, MidiWriter.vlq(0) .. string.char(0xFF, 0x51, 0x03, t1, t2, t3))
end

-- ============================
-- Export a melody in .mid
-- ============================
-- build a complete .mid file (format 0, one track) from a list {note=Hz|0, duration=sec}.
-- melody : { {note=<freq or 0>, duration=<seconds>}, ... }
-- opts   : { bpm=120, ppqn=480, program=0, velocity=100, filename="melody.mid" }
function MidiWriter.export_midi_from_melody(melody, opts)
  opts           = opts or {}
  local bpm      = opts.bpm or 120
  local ppqn     = opts.ppqn or 480
  local program  = opts.program or 0 -- 0 = Acoustic Grand Piano
  local velocity = math.max(1, math.min(127, opts.velocity or 100))
  local filename = opts.filename or "melody.mid"

  -- 1) Header chunk (MThd)
  local header   =
      "MThd" ..
      MidiWriter.be32(6) .. -- header length
      MidiWriter.be16(0) .. -- format 0
      MidiWriter.be16(1) .. -- 1 track
      MidiWriter.be16(ppqn) -- division (ticks per quarter note)

  -- 2) Build the track data (without the length for now)
  local track    = {}



  -- Track start: tempo + (optional) program change channel 0
  MidiWriter.meta_tempo(track, bpm)
  -- Program Change (delta=0)
  MidiWriter.push(track, MidiWriter.vlq(0) .. string.char(0xC0, program))

  -- 3) Note Events
  -- Strategy: For each audible note -> Note On (accumulated delta), Note Off (delta = note ticks)
  -- For a rest (note = 0) -> accumulate delta for the next Note On.
  local accumulated_delta = 0

  for _, ev in ipairs(melody) do
    local freq     = ev.note or 0
    local duration = ev.duration or 0
    local ticks    = MidiWriter.sec_to_ticks(duration, ppqn, bpm)

    if freq == 0 or duration <= 0 then
      -- REST: we just inject time before the next event
      accumulated_delta = accumulated_delta + ticks
    else
      local midi_note = MidiWriter.freq_to_midi(freq)
      if midi_note then
        -- Note On (delta = accumulated delta)
        MidiWriter.push(track, MidiWriter.vlq(accumulated_delta) .. string.char(0x90, midi_note, velocity))
        -- Note Off (delta = note ticks)
        MidiWriter.push(track, MidiWriter.vlq(ticks) .. string.char(0x80, midi_note, 64))
        accumulated_delta = 0
      else
        -- Invalid frequency: treat as silence
        accumulated_delta = accumulated_delta + ticks
      end
    end
  end

  -- 4) End of Track, delta = 0
  MidiWriter.push(track, MidiWriter.vlq(0) .. string.char(0xFF, 0x2F, 0x00))

  -- Concat track data + MTrk prefix + length
  local track_data = table.concat(track)
  local track_chunk = "MTrk" .. MidiWriter.be32(#track_data) .. track_data

  -- 5) Write the file
  local bytes = header .. track_chunk
  local path="musics/"..filename
  love.filesystem.createDirectory("musics") -- Create folder if necessary

  love.filesystem.write(path, bytes)
  return filename
end

return MidiWriter
