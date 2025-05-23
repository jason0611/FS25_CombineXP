
---@class CombineHUD
CombineHUD = {
    TEXT_SIZE = {
        HIGHLIGHT = 22
    },

    SIZE = {
        BOX = { 190, 110 }, -- 4px border correction
        BOX_MARGIN = { 400, -200 },
        BOX_PADDING = { 4, 4 },
        ICON = { 40, 40 },
        ICON_MARGIN = { 16, 0 },
        ICON_SMALL = { 24, 24 },
        ICON_SMALL_MARGIN = { 12, 0 },
        TEXT_MARGIN = { 145, 0 }
    },

	POSITIONS = {
        MASS_PERF = { 46, 300 },
        MASS_YIELD = { 46, 364 },
        SLASH_PERF = { 60, 300 },
        SLASH_YIELD = { 60, 364 },
        OPERATING_TIME = { 86, 364 },
        ENGINE_LOAD = { 46, 332 },
        AREA = { 86, 300 },
        FILL = { 36, 290 },
        MOISTURE = { 64, 364 }
	},

    UV = {
        MASS = { 0, 0, 64, 64 },
        AREA = { 64, 0, 64, 64 },
        SLASH = { 128, 0, 64, 64 },
        ENGINE_LOAD = { 192, 0, 64, 64 },
        FILL = { 0, 64, 64, 64 },
        MOISTURE = { 64, 64, 64, 64 }
    },

    COLOR = {
        TEXT_WHITE = { 1, 1, 1, 0.75 },
        INACTIVE = { 1, 1, 1, 0.75 },
        ORANGE = { 0.718, 0.5, 0, 0.75 },
        RED = { 0.718, 0, 0, 0.75 },
        MEDIUM_GLASS = { 0.018, 0.016, 0.015, 0.5 },
    }
}
CombineHUD.INPUT_CONTEXT_NAME = "COMBINE_HUD"

local xpCombineHUD_mt = Class(CombineHUD, HUDDisplayElement)

---Creates a new instance of the CombineHUD.
---@return CombineHUD
function CombineHUD.new(speedMeter, modDirectory, uiFilename)
    --print("CombineHUD:new")
    local instance = setmetatable({}, xpCombineHUD_mt)

    instance.modDirectory = modDirectory
    instance.speedMeter = speedMeter
    instance.uiFilename = uiFilename
	instance.baseLocation = {
		xOffset = 0,
		yOffset = 0
	}

    instance.tonPerHour = 0.
    instance.engineLoad = 0.
    instance.yield = 0.
    instance.gameplay = 0.

    return instance
end

function CombineHUD:delete()
    --print("CombineHUD:delete")
    if self.main ~= nil then
        self.main:delete()
    end
end

function CombineHUD:load()
    print("CombineHUD:load")
    self.uiScale = g_gameSettings.uiScale

    if g_languageShort == "fr" then
        self.l10nHour = "h"
    else
        self.l10nHour = string.gsub(string.gsub(g_i18n:getText("ui_hours_none"), "--:--", ""), "%s", "")
    end

    if g_seasons then
        CombineHUD.SIZE.BOX = { 190, 146 } -- 4px border correction
    else
        CombineHUD.SIZE.BOX = { 190, 110 } -- 4px border correction
    end

    self:createElements()
    self:setVehicle(nil)
end

function CombineHUD:scalePixelToScreenVector(vector2D)
    --print("CombineHUD:scalePixelToScreenVector")
    return self.speedMeter:scalePixelToScreenVector(vector2D)
end

function CombineHUD:scalePixelToScreenHeight(pixel)
    --print("CombineHUD:scalePixelToScreenHeight")
    return self.speedMeter:scalePixelToScreenHeight(pixel)
end

function CombineHUD:getCorrectTextSize(size)
    -- print("CombineHUD:getCorrectTextSize")
    return size --* self.uiScale
end

function CombineHUD:createElement(position, size, uvDimensions, colors)
	-- local x, y = self:scalePixelValuesToScreenVector(table.unpack(position))
	-- local width, height = self:scalePixelValuesToScreenVector(table.unpack(size))
    print("createElement")
    local x, y = self.speedMeter:scalePixelValuesToScreenVector(table.unpack(position))
    print("x,y"..tostring(x)..","..tostring(y))
	local width, height = self.speedMeter:scalePixelValuesToScreenVector(table.unpack(size))
    print("width,height"..tostring(width)..","..tostring(height))
	local overlay = Overlay.new(self.uiFilename, g_currentMission.hud.speedMeter.speedBg.x, g_currentMission.hud.speedMeter.speedBg.y, width, height)
	overlay.isVisible = true
	local element = HUDElement.new(overlay)
	if uvDimensions then
		element:setUVs(GuiUtils.getUVs(uvDimensions))
	end
	element:setColor(table.unpack(colors))
	return element
end

function CombineHUD:createElements()
    print("CombineHUD:createElements")
    -- local rightX = 1 - g_safeFrameOffsetX -- right of screen.
    -- local bottomY = g_safeFrameOffsetY

    -- local boxWidth, boxHeight = self:scalePixelToScreenVector(CombineHUD.SIZE.BOX)
    -- local marginWidth, marginHeight = self:scalePixelToScreenVector(CombineHUD.SIZE.BOX_MARGIN)
    local paddingWidth, paddingHeight = self:scalePixelToScreenVector(CombineHUD.SIZE.BOX_PADDING)

    -- local iconWidth, iconHeight = self:scalePixelToScreenVector(CombineHUD.SIZE.ICON)
    -- local iconMarginWidth, _ = self:scalePixelToScreenVector(CombineHUD.SIZE.ICON_MARGIN)
    -- local iconSmallWidth, iconSmallHeight = self:scalePixelToScreenVector(CombineHUD.SIZE.ICON_SMALL)
    -- iconSmallWidth = iconSmallWidth * 0.6
    -- iconSmallHeight = iconSmallHeight * 0.6
    -- local iconSmallMarginWidth, _ = self:scalePixelToScreenVector(CombineHUD.SIZE.ICON_SMALL_MARGIN)

    -- local posX, posY = self.speedMeter:getPosition()
    -- posX = posX + paddingWidth
    -- posY = posY + paddingHeight
    local textMarginWidth, _ = self:scalePixelToScreenVector(CombineHUD.SIZE.TEXT_MARGIN)
    
    local posX, posY = g_currentMission.hud.speedMeter.workingHoursTextOffsetX, g_currentMission.hud.speedMeter.y - g_currentMission.hud.speedMeter.workingHoursTextOffsetY
    local textX = posX + textMarginWidth
    local textY = posY + paddingHeight + paddingHeight

    self.IconBox = self:createElement({0, 0}, CombineHUD.SIZE.BOX, CombineHUD.UV.FILL, CombineHUD.COLOR.MEDIUM_GLASS)
    self.Mass = self:createElement({0, 0}, CombineHUD.SIZE.ICON_SMALL, CombineHUD.UV.MASS, CombineHUD.COLOR.INACTIVE)
    self.Mass2 = self:createElement({0, 0}, CombineHUD.SIZE.ICON_SMALL, CombineHUD.UV.MASS, CombineHUD.COLOR.INACTIVE)
    self.Slash = self:createElement({0, 0}, CombineHUD.SIZE.ICON_SMALL, CombineHUD.UV.SLASH, CombineHUD.COLOR.INACTIVE)
    self.Slash2 = self:createElement({0, 0}, CombineHUD.SIZE.ICON_SMALL, CombineHUD.UV.SLASH, CombineHUD.COLOR.INACTIVE)
    self.Area = self:createElement({0, 0}, CombineHUD.SIZE.ICON_SMALL, CombineHUD.UV.AREA, CombineHUD.COLOR.INACTIVE)
    self.EngineLoad = self:createElement({0, 0}, CombineHUD.SIZE.ICON_SMALL, CombineHUD.UV.ENGINE_LOAD, CombineHUD.COLOR.INACTIVE)

    local width, height = self.speedMeter:scalePixelValuesToScreenVector(table.unpack(CombineHUD.SIZE.ICON_SMALL))
    local overlay = g_overlayManager:createOverlay("gui.icon_usage", g_currentMission.hud.speedMeter.speedBg.x, g_currentMission.hud.speedMeter.speedBg.y, width, height) --Overlay.new(g_baseHUDFilename, g_currentMission.hud.speedMeter.speedBg.x, g_currentMission.hud.speedMeter.speedBg.y, width, height)
    overlay.isVisible = true
	local element = HUDElement.new(overlay)
	element:setColor(table.unpack(CombineHUD.COLOR.INACTIVE))
    self.Hour = element

    if g_seasons then
        local seasonsModDirectory = g_seasons.modDirectory
        posX = posX - iconSmallWidth - iconMarginWidth
        posY = posY + iconSmallHeight + iconMarginWidth
        self.iconMoisture = self:createIcon(self.uiFilename, posX, posY, iconSmallWidth, iconSmallHeight, CombineHUD.UV.MOISTURE)
        self.Moisture = HUDElement.new(self.iconMoisture)
    end

end

function CombineHUD:setVehicle(vehicle)
    -- print("CombineHUD:setVehicle")
    self.vehicle = vehicle
end

function CombineHUD:isVehicleActive(vehicle)
    --print("CombineHUD:isVehicleActive")
    return vehicle == self.vehicle
end


---Called on mouse event.
function CombineHUD:update(dt)
    if self.vehicle ~= nil then
        local spec = self.vehicle.spec_xpCombine
        self:setData(spec.mrCombineLimiter)
        -- Refresh the IconBox size if needed
        self:refreshIconBoxSize()
    end
end

function CombineHUD:refreshIconBoxSize()
    local scaledBoxWidth, scaledBoxHeight = self:scalePixelToScreenVector(CombineHUD.SIZE.BOX)
    self.IconBox.overlay:setDimension(scaledBoxWidth, scaledBoxHeight)
end

function CombineHUD:setData(mrCombineLimiter)
    --print("CombineHUD:setData")
    local tonPerHour = mrCombineLimiter.tonPerHour
    if tonPerHour ~= tonPerHour then
        tonPerHour = 0.
    end
    self.tonPerHour = tonPerHour
    local loadMultiplier = mrCombineLimiter.loadMultiplier
    if loadMultiplier ~= loadMultiplier then
        loadMultiplier = 1
    end
    self.engineLoad = 100 * mrCombineLimiter.engineLoad * loadMultiplier
    local yield = mrCombineLimiter.yield
    if yield ~= yield then
        yield = 0.
    end
    self.yield = yield
    self.gameplay = g_combinexp.powerBoost
end

function CombineHUD:getRelativeBaseLocation(speedMeter)
	local xOff, yOff = speedMeter:scalePixelValuesToScreenVector(self.baseLocation.xOffset, self.baseLocation.yOffset)
	return speedMeter.speedBg.x + xOff, speedMeter.speedBg.y + yOff
end

function CombineHUD:setScaledPos(element, relativePixelPos)
	local xRel, yRel = self.speedMeter:scalePixelValuesToScreenVector(table.unpack(relativePixelPos))
	local baseX, baseY = self:getRelativeBaseLocation(self.speedMeter)
	element:setPosition(baseX + xRel, baseY + yRel)
end

function CombineHUD:drawHUD()
    -- print("CombineHUD:drawHUD")
    -- if self.Mass.overlay:getIsVisible() then
        self:setScaledPos(self.IconBox, CombineHUD.POSITIONS.FILL)
        self.IconBox.overlay:render()
        self:setScaledPos(self.Mass, CombineHUD.POSITIONS.MASS_PERF)
        self.Mass.overlay:render()
        self:setScaledPos(self.Mass2, CombineHUD.POSITIONS.MASS_YIELD)
        self.Mass2.overlay:render()
        self:setScaledPos(self.Slash, CombineHUD.POSITIONS.SLASH_PERF)
        -- self.Slash.overlay:render()
        self:setScaledPos(self.Slash2, CombineHUD.POSITIONS.SLASH_YIELD)
        -- self.Slash2.overlay:render()
        self:setScaledPos(self.Area, CombineHUD.POSITIONS.AREA)
        self.Area.overlay:render()
        self:setScaledPos(self.Hour, CombineHUD.POSITIONS.OPERATING_TIME)
        self.Hour.overlay:render()
        self:setScaledPos(self.EngineLoad, CombineHUD.POSITIONS.ENGINE_LOAD)
        self.EngineLoad.overlay:render()
    -- end
end

function CombineHUD:drawText()
    -- print("CombineHUD:drawText")

    local _, paddingHeight = self:scalePixelToScreenVector(CombineHUD.SIZE.BOX_PADDING)
    local iconMarginWidth, _ = self:scalePixelToScreenVector(CombineHUD.SIZE.ICON_MARGIN)
    local iconSmallMarginWidth, _ = self:scalePixelToScreenVector(CombineHUD.SIZE.ICON_SMALL_MARGIN)
    local textMarginWidth, _ = self:scalePixelToScreenVector(CombineHUD.SIZE.TEXT_MARGIN)
    local textSize = self:scalePixelToScreenHeight(self:getCorrectTextSize(CombineHUD.TEXT_SIZE.HIGHLIGHT))
    local _, iconSmallHeight = self:scalePixelToScreenVector(CombineHUD.SIZE.ICON_SMALL)
    -- iconSmallHeight = iconSmallHeight * 0.6

    setTextAlignment(RenderText.ALIGN_RIGHT)
    setTextColor(unpack(CombineHUD.COLOR.TEXT_WHITE))
    setTextBold(true)
    -- print("x:"..tostring(g_currentMission.hud.speedMeter.x))
    -- print("workingHoursTextOffsetX:"..tostring(g_currentMission.hud.speedMeter.workingHoursTextOffsetX))
    local posX, posY = g_currentMission.hud.speedMeter.speedBg.x + 2 * g_currentMission.hud.speedMeter.workingHoursTextOffsetX, g_currentMission.hud.speedMeter.speedBg.y + g_currentMission.hud.speedMeter.speedGaugeCenterOffsetY - 3 * g_currentMission.hud.speedMeter.workingHoursTextOffsetY
    local textX = posX + textMarginWidth
    local textY = posY - paddingHeight
    -- renderText(0.925 * textX, textY, textSize, "/") -- OK only at 100% scale
    renderText(posX + iconSmallMarginWidth, textY, textSize, "/") -- OK only at 100% scale
    renderText(textX, textY, textSize, string.format("%.1f T/"..g_i18n:getAreaUnit(false), self.yield / g_i18n:getArea(1)))
    -- print(string.format("%.1f T/"..g_i18n:getAreaUnit(false), self.yield / g_i18n:getArea(1)))

    -- print("yield " .. tostring(posX) .. "," .. tostring(posY))

    textY = textY + iconSmallHeight + iconMarginWidth
    if self.engineLoad > 100 and self.engineLoad <= 120 then
        setTextColor(unpack(CombineHUD.COLOR.ORANGE))
    elseif self.engineLoad > 120 then
        setTextColor(unpack(CombineHUD.COLOR.RED))
    end
    renderText(textX, textY, textSize, string.format("%.1f %%", self.engineLoad))
    -- print(string.format("%.1f %%", self.engineLoad))
    setTextColor(unpack(CombineHUD.COLOR.TEXT_WHITE))

    local gameplay = string.sub(g_i18n:getText("gameplayNormal"), 1, 1) .. "                                  "
    if self.gameplay >= 100 then
        gameplay = string.sub(g_i18n:getText("gameplayArcade"), 1, 1) .. "                                  "
    elseif self.gameplay >= 20 then
        gameplay = string.sub(g_i18n:getText("gameplayNormal"), 1, 1) .. "                                  "
    elseif self.gameplay >= 0 then
        gameplay = string.sub(g_i18n:getText("gameplayRealistic"), 1, 1) .. "                                  "
    end
    renderText(1.005 * textX, textY, 0.7 * textSize, gameplay)

    textY = textY + iconSmallHeight + iconMarginWidth
    renderText(posX + iconSmallMarginWidth, textY, textSize, "/") -- OK only at 100% scale
    renderText(textX, textY, textSize, string.format("%.1f T/"..self.l10nHour, self.tonPerHour))

    if g_seasons then
        if g_seasons.weather.cropMoistureContent then
            textY = textY + iconSmallHeight + iconMarginWidth
            renderText(textX, textY, textSize, string.format("%.1f %%", g_seasons.weather.cropMoistureContent))
        end
    end
end
