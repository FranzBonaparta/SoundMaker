local FrequencySweep = {}

local sampleRate = 44100

function FrequencySweep.generateSweep(freqStart, freqEnd, duration, amplitude)
    amplitude = amplitude or 0.3
    local samples = math.floor(duration * sampleRate)
    local soundData = love.sound.newSoundData(samples, sampleRate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sampleRate
        local freq = freqStart + (freqEnd - freqStart) * (t / duration)
        local phase = 2 * math.pi * freq * t
        local sample = math.sin(phase) * amplitude
        soundData:setSample(i, sample)
    end

    return love.audio.newSource(soundData)
end

return FrequencySweep
