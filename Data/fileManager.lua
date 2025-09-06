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
    local partition = pianoViewer.partition
    local partitionButtons = pianoViewer.partitionButtons
    fileData = fileData .. "partition = {\n"

    for i, prt in ipairs(partition) do
        local row = math.floor((i - 1) / 25) + 1
        local col = ((i - 1) % 25) + 1
        local btn = partitionButtons[row] and partitionButtons[row][col]
        fileData = fileData .. "{ note = " .. prt.note .. ",\n"
        if btn then
            fileData = fileData .. string.format("name = %q,\n", btn.text)
        else
            fileData = fileData .. "name = \"?\",\n" -- fallback
        end
        fileData = fileData .. "duration = " .. prt.duration .. "}"
        if i < #partition then
            fileData = fileData .. ","
        end
        fileData = fileData .. "\n"
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
