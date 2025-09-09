-- SoundMaker
-- Made by Jojopov
-- Licence : GNU GPL v3 - 2025
-- https://www.gnu.org/licenses/gpl-3.0.html
-- FileManager allowed you to load and save datas
local FileManager = {}
function FileManager.saveInstrument(name, harmonicEditor, index)
    local path = "instruments/" .. name .. ".lua"
    local fileData = "return {\n"
    local attack, decay, factors, amplitudes, shape =
        harmonicEditor.attacks[index], harmonicEditor.decays[index],
        harmonicEditor.factors[index], harmonicEditor.amplitudes[index],
        harmonicEditor.shapes[index]

    -- Saving the instrument
    fileData = fileData .. string.format("shape = %q,\nattack = %d,\ndecay = %d,\nfactors = { ",
        shape, attack, decay)
    for i, factor in ipairs(factors) do
        fileData = fileData .. string.format("%.3f", factor)
        if #factors > 1 and i < #factors then
            fileData = fileData .. ", "
        end
    end
    fileData = fileData .. "  },\namplitudes = { "
    for i, amplitude in ipairs(amplitudes) do
        fileData = fileData .. string.format("%.3f", amplitude)
        if #amplitudes > 1 and i < #amplitudes then
            fileData = fileData .. ", "
        end
    end
    fileData = fileData .. "}\n"
    --closing instrument
    fileData = fileData .. "}\n"

    love.filesystem.createDirectory("instruments") -- Create folder if necessary
    love.filesystem.write(path, fileData)
    --print("Sprite sauvé dans : " .. path)
end

function FileManager.savePartition(name, pianoViewer)
    local path = "partitions/" .. name .. ".lua"
    local fileData = "return {\n"
    local partition = pianoViewer.partitionVizualizer.partition
    local partitionButtons = pianoViewer.partitionVizualizer.partitionButtons
    fileData = fileData .. "partition = {\n"
    local i = 1
    for _, line in ipairs(partitionButtons) do
        for _, noteButton in ipairs(line) do
            fileData = fileData .. "{ note = " .. noteButton.note .. ",\n"
            fileData = fileData .. string.format("name = %q,\n", noteButton.text)
            fileData = fileData .. "duration = " .. noteButton.duration .. "}"
            i = i + 1
            if i <= #partition then
                fileData = fileData .. ","
            end
            fileData = fileData .. "\n"
        end
    end

    fileData = fileData .. "}\n"
    fileData = fileData .. "}"
    love.filesystem.createDirectory("partitions") -- Create folder if necessary
    love.filesystem.write(path, fileData)
end

function FileManager.loadInstrument(name)
    local chunk = love.filesystem.load(name)
    local data = chunk()
    return data.shape, data.attack, data.decay, data.factors, data.amplitudes
end

function FileManager.loadPartition(name)
    local chunk = love.filesystem.load(name)
    local data = chunk()
    return data.partition
end

function FileManager.fileTree(folder, fileTree)
    local filesTable = love.filesystem.getDirectoryItems(folder)
    for i, v in ipairs(filesTable) do
        local file = folder .. "/" .. v
        local info = love.filesystem.getInfo(file)
        if info then
            if info.type == "file" then
                fileTree = fileTree .. "\n" .. file
            elseif info.type == "directory" then
                fileTree = fileTree .. "\n" .. file .. " (DIR)"
                fileTree = FileManager.fileTree(file, fileTree)
            end
        end
    end
    return folder .. " contain " .. #filesTable .. " elements\n" .. fileTree
end

return FileManager
