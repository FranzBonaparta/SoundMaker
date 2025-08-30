local Object = require("libs.classic")
local SoundMaker = require("engine.SoundMaker")
local soundMaker = SoundMaker()
local SimpleMusicPlayer = Object:extend()
local fluteSources = {}

local notes = {
    C4 = 261.63,
    D4 = 293.66,
    E4 = 329.63,
    F4 = 349.23,
    G4 = 392.00
}
for name, freq in pairs(notes) do
    fluteSources[name] = soundMaker:generateFluteNote(freq, 1.2)
end
function SimpleMusicPlayer:new()
    self.currentMelody = nil
    self.currentIndex = 1
    self.timer = 0
    self.isPlaying = false
    self.Notes = soundMaker:getNotes()

    self.defaultInstrument = function(freq, dur, amp) return soundMaker:createSquareWave(freq, dur, amp) end
    self.instrument = self.defaultInstrument
end

function SimpleMusicPlayer:playIntro()
    local melody = {
        { note = self.Notes.C4, duration = 0.2 },
        { note = self.Notes.E4, duration = 0.2 },
        { note = self.Notes.G4, duration = 0.2 },
        { note = self.Notes.C5, duration = 0.4 },
    }
    self:playMelody(melody, function(f, d, a) return soundMaker:createSineWave(f, d, a) end)
end

function SimpleMusicPlayer:playMelody(melody, instrument)
    self.currentMelody = melody
    self.currentIndex = 1
    self.timer = 0
    self.isPlaying = true
    self.instrument = instrument or self.defaultInstrument
end

function SimpleMusicPlayer:update(dt, onNotePlayed)
    if not self.isPlaying or not self.currentMelody then return end

    self.timer = self.timer - dt

    if self.timer <= 0 then
        local noteData = self.currentMelody[self.currentIndex]
        if noteData then
            --check if the note is silence
            if noteData.note ~= 0 then
                local sound = self.instrument(noteData.note, noteData.duration, 0.3)
                sound:play()
                if onNotePlayed then
                    onNotePlayed(noteData.note, noteData.duration)
                end
            end

            self.timer = noteData.duration
            self.currentIndex = self.currentIndex + 1
        else
            self.isPlaying = false -- End of the melody
        end
    end
end

function SimpleMusicPlayer:isFinished()
    return not self.isPlaying
end

function SimpleMusicPlayer:keypressed(key)
    local inputs = { "space", "kp0", "kp1", "kp2", "kp3",
        "a", "z", "e", "r", "t", "y" }
    local outputs = { soundMaker:createSquareWave(440, 0.2), soundMaker:createSineWave(440, 0.2),
        soundMaker:createTriangleWave(440, 0.2), soundMaker:createSawtoothWave(440, 0.2),
        soundMaker:createWhiteNoise(0.3, 0.2), fluteSources.C4, fluteSources.D4, fluteSources.E4,
        fluteSources.F4, fluteSources.G4, soundMaker:generateFluteNote(notes.E4, 0.5) }
    for i = 1, #inputs do
        if key == inputs[i] then
            outputs[i]:play()
            break
        end
    end
    --[[    elseif key=="a" then
        soundMaker:menuSelect():play()
    elseif key=="z" then
        soundMaker:menuConfirm():play()
    elseif key=="e" then
        soundMaker:menuError():play()
    elseif key=="r" then
        soundMaker:menuMove():play()
    elseif key=="t" then
        soundMaker:explosion():play()]]
end

return SimpleMusicPlayer
