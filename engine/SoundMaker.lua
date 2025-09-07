-- SoundMaker
-- Made by Jojopov
-- Licence : GNU GPL v3 - 2025
-- https://www.gnu.org/licenses/gpl-3.0.html
local Object = require("libs.classic")
local SoundMaker = Object:extend()
local Notes = require("assets.notes")
function SoundMaker:new()
    self.sampleRate = 44100 -- Standard audio
    self.Notes = Notes.global
    self.WhiteNotes = Notes.WhiteNotes
    self.BlackNotes = Notes.BlackNotes
end

function SoundMaker:getNotes()
    return self.Notes
end

local function getFadeOut(time, duration, level)
    return (1 - (time / duration)) ^ level --FadeOut=transition between notes
end
-- Onde sinusoïdale
function SoundMaker:createSineWave(frequency, duration, amplitude)
    amplitude = amplitude or 0.3
    local samples = math.floor(duration * self.sampleRate)
    local soundData = love.sound.newSoundData(samples, self.sampleRate, 16, 1)
    for i = 0, samples - 1 do
        local time = i / self.sampleRate
        local envelope = getFadeOut(time, duration, 0.5) -- courbe exponentielle -- fade-out linéaire
        local value = math.sin(2 * math.pi * frequency * time) * amplitude * envelope
        soundData:setSample(i, value)
    end
    return love.audio.newSource(soundData)
end

-- Génère un son doux avec enveloppe de type flûte
function SoundMaker:generateFluteNote(frequency, duration, amplitude)
    amplitude = amplitude or 0.3
    local soundData = love.sound.newSoundData(self.sampleRate * duration, self.sampleRate, 16, 1)
    for i = 0, soundData:getSampleCount() - 1 do
        local t = i / self.sampleRate
        local env = self:getEnvelope(t, -3, -15) -- Attaque/déclin
        local value = self:getHarmonic(frequency, amplitude, t, env)
        soundData:setSample(i, value)
    end
    local src = love.audio.newSource(soundData)
    src:setLooping(false)
    return src
end

function SoundMaker:getEnvelope(time, attack, decay)
    return math.exp(attack * time) * (1 - math.exp(decay * time))
end

function SoundMaker:getHarmonic(frequency, amplitude, time, envelope)
    local value = math.sin(2 * math.pi * frequency * time)
    local harmonicfactors = { 1 }    --multiples de la fq fondamentale >=1;<=[16;32]
    local harmonicAmplitudes = { 1 } --coeff de volume sur chq harmonique: "poids" [0.0;1.0]
    for i, factor in ipairs(harmonicfactors) do
        local harmonicFreq = frequency * factor
        value = value + harmonicAmplitudes[i] * math.sin(2 * math.pi * harmonicFreq * time)
    end
    value = value * amplitude * envelope
    return value
end

function SoundMaker:getPersonnalizedHarmonic(frequency, amplitude, time,type, attack, decay, harmonicFactors, harmonicAmplitudes)
    local waves = { "sine", "square", "triangle", "saw", "noise" }
    local values = { math.sin(2 * math.pi * frequency * time),
        math.sin(2 * math.pi * frequency * time) >= 0 and amplitude or -amplitude,
        (4 * math.abs((time * frequency) % 1 - 0.5) - 1) * amplitude,
        (2 * ((time * frequency) % 1) - 1) * amplitude,
        (2 * math.random() - 1) * amplitude
    }
    local index=0
    local enveloppe=math.exp(attack * time) * (1 - math.exp(decay * time))
    local value=nil
    for i, wave in ipairs(waves) do
        if wave==type then
            index=i
            value=values[i]*harmonicAmplitudes[1]
            break
        end
    end
    if value then
        for i, factor in ipairs(harmonicFactors) do
        local harmonicFreq = frequency * factor
        local newValues={math.sin(2 * math.pi * harmonicFreq * time),
        math.sin(2 * math.pi * harmonicFreq * time) >= 0 and amplitude or -amplitude,
        (4 * math.abs((time * harmonicFreq) % 1 - 0.5) - 1) * amplitude,
        (2 * ((time * harmonicFreq) % 1) - 1) * amplitude,
        (2 * math.random() - 1) * amplitude
        }
        value = value + harmonicAmplitudes[i] * newValues[index]
        end
        value=value*amplitude*enveloppe
        return value
    elseif not value then error("Unknown wave type: " .. tostring(type)) end

end
-- Génère un son personnalisé
function SoundMaker:generatePersonnalizedNote(frequency,duration, amplitude,type, attack, decay, harmonicFactors, harmonicAmplitudes)
    amplitude = amplitude or 0.3
    local soundData = love.sound.newSoundData(self.sampleRate * duration, self.sampleRate, 16, 1)
    for i = 0, soundData:getSampleCount() - 1 do
        local time = i / self.sampleRate
        local value = self:getPersonnalizedHarmonic(frequency, amplitude, time,type, attack, decay, harmonicFactors, harmonicAmplitudes)
        soundData:setSample(i, value)
    end
    local src = love.audio.newSource(soundData)
    src:setLooping(false)
    return src
end
-- Onde carrée
function SoundMaker:createSquareWave(frequency, duration, amplitude)
    amplitude = amplitude or 0.3
    local samples = math.floor(duration * self.sampleRate)
    local soundData = love.sound.newSoundData(samples, self.sampleRate, 16, 1)
    for i = 0, samples - 1 do
        local time = i / self.sampleRate
        local value = math.sin(2 * math.pi * frequency * time)
        value = (value >= 0) and amplitude or -amplitude
        soundData:setSample(i, value)
    end
    return love.audio.newSource(soundData)
end

-- Onde triangulaire
function SoundMaker:createTriangleWave(frequency, duration, amplitude)
    amplitude = amplitude or 0.3
    local samples = math.floor(duration * self.sampleRate)
    local soundData = love.sound.newSoundData(samples, self.sampleRate, 16, 1)
    for i = 0, samples - 1 do
        local time = i / self.sampleRate
        local value = (4 * math.abs((time * frequency) % 1 - 0.5) - 1) * amplitude
        soundData:setSample(i, value)
    end
    return love.audio.newSource(soundData)
end

-- Onde dent de scie
function SoundMaker:createSawtoothWave(frequency, duration, amplitude)
    amplitude = amplitude or 0.3
    local samples = math.floor(duration * self.sampleRate)
    local soundData = love.sound.newSoundData(samples, self.sampleRate, 16, 1)
    for i = 0, samples - 1 do
        local time = i / self.sampleRate
        local value = (2 * ((time * frequency) % 1) - 1) * amplitude
        soundData:setSample(i, value)
    end
    return love.audio.newSource(soundData)
end

-- Bruit blanc
function SoundMaker:createWhiteNoise(duration, amplitude)
    amplitude = amplitude or 0.3
    local samples = math.floor(duration * self.sampleRate)
    local soundData = love.sound.newSoundData(samples, self.sampleRate, 16, 1)
    for i = 0, samples - 1 do
        local value = (2 * math.random() - 1) * amplitude
        soundData:setSample(i, value)
    end
    return love.audio.newSource(soundData)
end

-- --- Small pre-made sounds for the interface ---

--  Selection beep (menu)
function SoundMaker:menuSelect()
    return self:createSquareWave(self.Notes.A5, 0.1, 0.3)
end

-- Validation (ok)
function SoundMaker:menuConfirm()
    return self:createSineWave(self.Notes.C5, 0.15, 0.4)
end

-- Error
function SoundMaker:menuError()
    return self:createSawtoothWave(self.Notes.G3, 0.2, 0.4)
end

-- Little "menu move" noise
function SoundMaker:menuMove()
    return self:createTriangleWave(self.Notes.E5, 0.05, 0.2)
end

-- Single explosion (white noise)
function SoundMaker:explosion()
    return self:createWhiteNoise(0.3, 0.5)
end

return SoundMaker