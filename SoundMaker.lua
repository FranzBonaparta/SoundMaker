local Object = require("libs.classic")
local SoundMaker = Object:extend()

function SoundMaker:new()
    self.sampleRate=44100 -- Standard audio
    self.Notes={
    --[[C0 = 16.35, Cs0 = 17.32, D0 = 18.35, Ds0 = 19.45, E0 = 20.60, F0 = 21.83, Fs0 = 23.12, G0 = 24.50, Gs0 = 25.96, ]]A0 = 27.50, As0 = 29.14, B0 = 30.87,
    C1 = 32.70, Cs1 = 34.65, D1 = 36.71, Ds1 = 38.89, E1 = 41.20, F1 = 43.65, Fs1 = 46.25, G1 = 49.00, Gs1 = 51.91, A1 = 55.00, As1 = 58.27, B1 = 61.74,
    C2 = 65.41, Cs2 = 69.30, D2 = 73.42, Ds2 = 77.78, E2 = 82.41, F2 = 87.31, Fs2 = 92.50, G2 = 98.00, Gs2 = 103.83, A2 = 110.00, As2 = 116.54, B2 = 123.47,
    C3 = 130.81, Cs3 = 138.59, D3 = 146.83, Ds3 = 155.56, E3 = 164.81, F3 = 174.61, Fs3 = 185.00, G3 = 196.00, Gs3 = 207.65, A3 = 220.00, As3 = 233.08, B3 = 246.94,
    C4 = 261.63, Cs4 = 277.18, D4 = 293.66, Ds4 = 311.13, E4 = 329.63, F4 = 349.23, Fs4 = 369.99, G4 = 392.00, Gs4 = 415.30, A4 = 440.00, As4 = 466.16, B4 = 493.88,
    C5 = 523.25, Cs5 = 554.37, D5 = 587.33, Ds5 = 622.25, E5 = 659.26, F5 = 698.46, Fs5 = 739.99, G5 = 783.99, Gs5 = 830.61, A5 = 880.00, As5 = 932.33, B5 = 987.77,
    C6 = 1046.50, Cs6 = 1108.73, D6 = 1174.66, Ds6 = 1244.51, E6 = 1318.51, F6 = 1396.91, Fs6 = 1479.98, G6 = 1567.98, Gs6 = 1661.22, A6 = 1760.00, As6 = 1864.66, B6 = 1975.53,
    C7 = 2093.00, Cs7 = 2217.46, D7 = 2349.32, Ds7 = 2489.02, E7 = 2637.02, F7 = 2793.83, Fs7 = 2959.96, G7 = 3135.96, Gs7 = 3322.44, A7 = 3520.00, As7 = 3729.31, B7 = 3951.07,
    C8 = 4186.01
}
self.WhiteNotes = {
    A0 = 27.50,  B0 = 30.87,
    C1 = 32.70,  D1 = 36.71,  E1 = 41.20,  F1 = 43.65,  G1 = 49.00,  A1 = 55.00,  B1 = 61.74,
    C2 = 65.41,  D2 = 73.42,  E2 = 82.41,  F2 = 87.31,  G2 = 98.00,  A2 = 110.00, B2 = 123.47,
    C3 = 130.81, D3 = 146.83, E3 = 164.81, F3 = 174.61, G3 = 196.00, A3 = 220.00, B3 = 246.94,
    C4 = 261.63, D4 = 293.66, E4 = 329.63, F4 = 349.23, G4 = 392.00, A4 = 440.00, B4 = 493.88,
    C5 = 523.25, D5 = 587.33, E5 = 659.26, F5 = 698.46, G5 = 783.99, A5 = 880.00, B5 = 987.77,
    C6 = 1046.50, D6 = 1174.66, E6 = 1318.51, F6 = 1396.91, G6 = 1567.98, A6 = 1760.00, B6 = 1975.53,
    C7 = 2093.00, D7 = 2349.32, E7 = 2637.02, F7 = 2793.83, G7 = 3135.96, A7 = 3520.00, B7 = 3951.07,
    C8 = 4186.01
}

self.BlackNotes = {
    As0 = 29.14,
    Cs1 = 34.65,  Ds1 = 38.89,  Fs1 = 46.25,  Gs1 = 51.91,  As1 = 58.27,
    Cs2 = 69.30,  Ds2 = 77.78,  Fs2 = 92.50,  Gs2 = 103.83, As2 = 116.54,
    Cs3 = 138.59, Ds3 = 155.56, Fs3 = 185.00, Gs3 = 207.65, As3 = 233.08,
    Cs4 = 277.18, Ds4 = 311.13, Fs4 = 369.99, Gs4 = 415.30, As4 = 466.16,
    Cs5 = 554.37, Ds5 = 622.25, Fs5 = 739.99, Gs5 = 830.61, As5 = 932.33,
    Cs6 = 1108.73, Ds6 = 1244.51, Fs6 = 1479.98, Gs6 = 1661.22, As6 = 1864.66,
    Cs7 = 2217.46, Ds7 = 2489.02, Fs7 = 2959.96, Gs7 = 3322.44, As7 = 3729.31
}
end
function SoundMaker:getNotes()
    return self.Notes
end

-- Onde sinusoïdale
function SoundMaker:createSineWave(frequency, duration, amplitude)
    amplitude = amplitude or 0.3
    local samples = math.floor(duration * self.sampleRate)
    local soundData = love.sound.newSoundData(samples, self.sampleRate, 16, 1)
    for i = 0, samples - 1 do
        local time = i / self.sampleRate
        local value = math.sin(2 * math.pi * frequency * time) * amplitude
        soundData:setSample(i, value)
    end
    return love.audio.newSource(soundData)
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