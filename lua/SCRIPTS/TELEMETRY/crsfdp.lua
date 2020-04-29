cmsMenuOpen = false
lastMenuEventTime = 0
radio = {}

screenBuffer = {
    rows = 8,
    cols = 32,
    buffer = {},
    data = {},
    batchId = 0,
    sequence = 0,
    reset = function()
        screenBuffer.buffer = {}
        screenBuffer.data = {}
        screenBuffer.batchId = 0
        screenBuffer.sequence = 0
    end,
    draw = function()
        if (#screenBuffer.buffer ~= nil and #screenBuffer.buffer > 0) then
            lcd.clear()
            for char=1,#screenBuffer.buffer do
                if (screenBuffer.buffer[char] ~= 32) then -- skip spaces (CPU no likey)
                    c = string.char(screenBuffer.buffer[char])
                    row = math.ceil(char/screenBuffer.cols)
                    col = char-((row-1)*screenBuffer.cols)
                    xPos = ((col-1)*radio.lcd.pixelsPerChar)+1
                    yPos = ((row-1)*radio.lcd.pixelsPerRow)+1
                    lcd.drawText(xPos, yPos, c, SMLSIZE)
                end
            end
        end
    end
}

local _ = {
    frame = {
        destination = 1,
        source = 2,
        subCommand = 3,
        meta = 4,
        sequence = 5,
        data = 6
    },
    address = {
        transmitter = 0xEA,
        betaflight = 0xC8
    },
    frameType = {
        displayPort = 0x7D 
    },
    subCommand = {
        update = 0x01,
        clear = 0x02,
        open = 0x03,
        close = 0x04,
        poll = 0x05
    },
    bitmask = {
        firstChunk = 0x80,
        lastChunk = 0x40,
        batchId = 0x3F,
        rleDictValueMask = 0x7F,
        rleCharRepeatedMask = 0x80
    }
}

local supportedPlatforms = {
    x7 =
    {
        refresh = {
            event = EVT_ENTER_BREAK,
            text = "Refresh: [ENT]",
            top = 1,
            left = 64,
        },
        lcd = {
            width = 128,
            height = 64,
            rows = 8,
            cols = 26,
            pixelsPerRow = 8,
            pixelsPerChar = 5,
        }
    },
    x9 =
    {
        refresh = {
            event = EVT_PLUS_BREAK,
            text = "Refresh: [+]",
            top = 1,
            left = 156,
        },
        lcd = {
            width = 212,
            height = 64,
            rows = 8,
            cols = 32,
            topPadding = 2,
            pixelsPerRow = 8,
            pixelsPerChar = 6,
        }
    },
}

local supportedRadios =
{
    ["x7"] = supportedPlatforms.x7,
    ["x7s"] = supportedPlatforms.x7,
    ["x9d"] = supportedPlatforms.x9,
    ["x9d+"] = supportedPlatforms.x9,
}

local function cRleDecode(buf)
    local dest = {}
    local rpt = false
    local c = nil
    for i=1, #buf do
        if (rpt == false) then
            c = bit32.band(buf[i], _.bitmask.rleDictValueMask)
            if (bit32.band(buf[i], _.bitmask.rleCharRepeatedMask) > 0) then
                rpt = true
            else
                dest[#dest + 1] = c
            end
        else
            for j=1, buf[i] do
                dest[#dest + 1] = c
            end
            rpt = false
        end
    end
    return dest
end

local function subrange(t, first, last)
    local sub = {}
    local sublen = 0
    for i=first,last do
        sublen = sublen + 1
        sub[sublen] = t[i]
    end
    return sub
end

local function arrayAppend(dst, src)
    local dstLen = #dst
    for i=1, #src do
        dst[dstLen+i] = src[i]
    end
end

local function displayPortCmd(cmd, data)
    local payloadOut = { _.address.betaflight, _.address.transmitter, cmd }
    if data ~= nil then
        for i=1,#(data) do
            payloadOut[3+i] = data[i]
        end
    end
    crossfireTelemetryPush(_.frameType.displayPort, payloadOut) 
end

local function init()
    local ver, rad, maj, min, rev = getVersion()
    radio = supportedRadios[rad]
    if not radio then
        error("Radio not supported: "..rad)
    end
    screenBuffer.rows = radio.lcd.rows
    screenBuffer.cols = radio.lcd.cols
    screenBuffer.reset()
end

local function run(event)
    lastMenuEventTime = getTime()
    local frameType, data = crossfireTelemetryPop()
    if (data ~= nil) and (#data > 2) then
        if (frameType == _.frameType.displayPort) and (data[_.frame.destination] == _.address.transmitter) and (data[_.frame.source] == _.address.betaflight) then
            local subCommand = data[_.frame.subCommand]
            if (subCommand == _.subCommand.update) then
                local firstChunk = bit32.band(data[_.frame.meta], _.bitmask.firstChunk)
                local lastChunk = bit32.band(data[_.frame.meta], _.bitmask.lastChunk)
                local batchId = bit32.band(data[_.frame.meta], _.bitmask.batchId)
                local sequence = data[_.frame.sequence]
                local frameData = subrange(data, _.frame.data, #data)
                if (firstChunk ~= 0) then
                    screenBuffer.reset()
                    screenBuffer.batchId = batchId
                    screenBuffer.sequence = 0
                end
                if(screenBuffer.batchId == batchId and screenBuffer.sequence == sequence) then
                    screenBuffer.sequence = sequence + 1
                    arrayAppend(screenBuffer.data, frameData)
                    if (lastChunk ~= 0) then
                        screenBuffer.buffer = cRleDecode(screenBuffer.data)
                        screenBuffer.draw()
                        screenBuffer.reset()
                    end
                else
                    displayPortCmd(_.subCommand.poll, nil)
                end                
                cmsMenuOpen = true
            elseif (subCommand == _.subCommand.clear) then
                screenBuffer.reset()
            end
        end
    end
    if (cmsMenuOpen == true) then 
        lcd.drawText(radio.refresh.left, radio.refresh.top, radio.refresh.text, SMLSIZE) 
    elseif (cmsMenuOpen == false) then
        displayPortCmd(_.subCommand.open, { screenBuffer.rows, screenBuffer.cols })
    elseif (event == radio.refresh.event) then
        displayPortCmd(_.subCommand.poll, nil)
    end
end

local function background()
    if cmsMenuOpen == true and lastMenuEventTime + 100 < getTime() then
        displayPortCmd(_.subCommand.close, nil)
        cmsMenuOpen = false
    end
end

return { init=init, run=run, background=background }