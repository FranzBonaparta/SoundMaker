local Object = require("libs.classic")
local SoundMaker = Object:extend()
local Notes=require("assets.notes")
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
        local env = self:getEnvelope(t, -3,-15) -- Attaque/déclin
        local value =self:getHarmonic(frequency,amplitude,t,env)
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
    local harmonicfactors = { 1 } --multiples de la fq fondamentale >=1;<=[16;32]
    local harmonicAmplitudes = { 1 } --coeff de volume sur chq harmonique: "poids" [0.0;1.0]
    for i, factor in ipairs(harmonicfactors) do
        local harmonicFreq = frequency * factor
        value = value + harmonicAmplitudes[i] * math.sin(2 * math.pi * harmonicFreq * time)
    end
    value = value * amplitude * envelope
    return value
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

-- --- Petits sons préfaits pour ton interface ---

-- Bip de sélection (menu)
function SoundMaker:menuSelect()
    return self:createSquareWave(self.Notes.A5, 0.1, 0.3)
end

-- Validation (ok)
function SoundMaker:menuConfirm()
    return self:createSineWave(self.Notes.C5, 0.15, 0.4)
end

-- Erreur
function SoundMaker:menuError()
    return self:createSawtoothWave(self.Notes.G3, 0.2, 0.4)
end

-- Petit bruit de "menu move"
function SoundMaker:menuMove()
    return self:createTriangleWave(self.Notes.E5, 0.05, 0.2)
end

-- Explosion simple (bruit blanc)
function SoundMaker:explosion()
    return self:createWhiteNoise(0.3, 0.5)
end

return SoundMaker
