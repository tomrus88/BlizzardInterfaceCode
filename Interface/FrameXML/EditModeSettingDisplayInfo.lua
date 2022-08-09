EditModeSettingDisplayInfoManager = {};

local function showAsPercentage(value)
	local roundToNearestInteger = true;
	return FormatPercentage(value / 100, roundToNearestInteger);
end

-- The ordering of the setting display info tables in here affects the order settings show in the system setting dialog
EditModeSettingDisplayInfoManager.systemSettingDisplayInfo = {
	-- Action Bar Settings
	[Enum.EditModeSystem.ActionBar] =
	{
		-- Orientation
		{
			setting = Enum.EditModeActionBarSetting.Orientation,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION,
			type = Enum.EditModeSettingDisplayType.Dropdown,
			options = 
			{
				{value = Enum.ActionBarOrientation.Horizontal, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL},
				{value = Enum.ActionBarOrientation.Vertical, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL},
			},
		},

		-- Num Rows/Columns
		{
			setting = Enum.EditModeActionBarSetting.NumRows,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS,
			altName = HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_COLUMNS,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 1,
			maxValue = 4,
		},

		-- Num Icons
		{
			setting = Enum.EditModeActionBarSetting.NumIcons,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ICONS,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 6,
			maxValue = 12,
		},

		-- Icon Size
		{
			setting = Enum.EditModeActionBarSetting.IconSize,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 50,
			maxValue = 200,
			stepSize = 10,
			ConvertValue = function(self, value, forDisplay)
				if forDisplay then
					return self:ClampValue((value * 10) + 50);
				else
					return (value - 50) / 10;
				end
			end,
			formatter = showAsPercentage,
		},

		-- Icon Padding
		{
			setting = Enum.EditModeActionBarSetting.IconPadding,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_PADDING,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 2,
			maxValue = 10,
			stepSize = 1,
		},

		-- Visible Setting
		{
			setting = Enum.EditModeActionBarSetting.VisibleSetting,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING,
			type = Enum.EditModeSettingDisplayType.Dropdown,
			options = 
			{
				{value = Enum.ActionBarVisibleSetting.Always, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_ALWAYS},
				{value = Enum.ActionBarVisibleSetting.InCombat, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT},
				{value = Enum.ActionBarVisibleSetting.OutOfCombat, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_OUT_OF_COMBAT},
			},
		},

		-- Always Show Buttons
		{
			setting = Enum.EditModeActionBarSetting.AlwaysShowButtons,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_ALWAYS_SHOW_BUTTONS,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		-- Bar Art Visible Setting
		{
			setting = Enum.EditModeActionBarSetting.HideBarArt,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_HIDE_BAR_ART,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		-- Bar Scrolling Visible Setting
		{
			setting = Enum.EditModeActionBarSetting.HideBarScrolling,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_HIDE_BAR_SCROLLING,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		-- Snap To Side
		{
			setting = Enum.EditModeActionBarSetting.SnapToSide,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_SNAP_TO_RIGHT_SIDE,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},
	},

	[Enum.EditModeSystem.Minimap] =
	{
		-- Header Underneath
		{
			setting = Enum.EditModeMinimapSetting.HeaderUnderneath,
			name = HUD_EDIT_MODE_SETTING_MINIMAP_HEADER_UNDERNEATH,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},
	},

	-- Cast Bar Settings
	[Enum.EditModeSystem.CastBar] =
	{
		-- Bar Size
		{
			setting = Enum.EditModeCastBarSetting.BarSize,
			name = HUD_EDIT_MODE_SETTING_CAST_BAR_SIZE,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 100,
			maxValue = 150,
			stepSize = 10,
			ConvertValue = function(self, value, forDisplay)
				if forDisplay then
					return self:ClampValue((value * 10) + 100);
				else
					return (value - 100) / 10;
				end
			end,
			formatter = showAsPercentage,
		},

		-- Lock To Player Frame
		{
			setting = Enum.EditModeCastBarSetting.LockToPlayerFrame,
			name = HUD_EDIT_MODE_SETTING_CAST_BAR_LOCK_TO_PLAYER_FRAME,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},
	},

	-- Unit Frame Settings
	[Enum.EditModeSystem.UnitFrame] =
	{
		-- Hide Portrait
		--[[{
			setting = Enum.EditModeUnitFrameSetting.HidePortrait,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_HIDE_PORTRAIT,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},]]--

		-- Cast Bar Underneath
		{
			setting = Enum.EditModeUnitFrameSetting.CastBarUnderneath,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_CAST_BAR_UNDERNEATH,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		-- Buffs On Top
		{
			setting = Enum.EditModeUnitFrameSetting.BuffsOnTop,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_BUFFS_ON_TOP,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		-- Use Larger Frame
		{
			setting = Enum.EditModeUnitFrameSetting.UseLargerFrame,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_USE_LARGER_FRAME,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},
	},

	[Enum.EditModeSystem.EncounterBar] =
	{

	},
};

local DefaultSettingDisplayInfo = {};

function DefaultSettingDisplayInfo:ConvertValue(value, forDisplay)
	if forDisplay then
		return self:ClampValue(value);
	else
		return value;
	end
end

function DefaultSettingDisplayInfo:ClampValue(value)
	if self.type == Enum.EditModeSettingDisplayType.Dropdown then
		return Clamp(value, 0, #self.options - 1);
	elseif self.type == Enum.EditModeSettingDisplayType.Slider then
		return Clamp(value, self.minValue, self.maxValue);
	else
		return Clamp(value, 0, 1);
	end
end

function DefaultSettingDisplayInfo:ConvertValueForDisplay(value)
	local forDisplay = true;
	return self:ConvertValue(value, forDisplay);
end

-- Metatable used for all setting display info tables
-- This provides ClampValue and ConvertValueForDisplay methods, in addition to a default version of the ConvertValue method
local mt = {__index =  DefaultSettingDisplayInfo};

-- Create a map from system/setting to displayInfo for easy access
EditModeSettingDisplayInfoManager.displayInfoMap = {};
for system, systemDisplayInfo in pairs(EditModeSettingDisplayInfoManager.systemSettingDisplayInfo) do
	EditModeSettingDisplayInfoManager.displayInfoMap[system] = {};
	for _, settingDisplayInfo in ipairs(systemDisplayInfo) do
		-- Set the metatable on each of the display info tables
		setmetatable(settingDisplayInfo, mt);
		-- And then add it to the map
		EditModeSettingDisplayInfoManager.displayInfoMap[system][settingDisplayInfo.setting] = settingDisplayInfo;
	end
end

function EditModeSettingDisplayInfoManager:GetSystemSettingDisplayInfo(system)
	return self.systemSettingDisplayInfo[system];
end

function EditModeSettingDisplayInfoManager:GetSystemSettingDisplayInfoMap(system)
	return self.displayInfoMap[system];
end

local mirroredSettings = {
	-- CastBar-LockToPlayerFrame and PlayerFrame-CastBarUnderneath are mirrored
	{
		{system = Enum.EditModeSystem.CastBar, setting = Enum.EditModeCastBarSetting.LockToPlayerFrame},
		{system = Enum.EditModeSystem.UnitFrame, systemIndex = Enum.EditModeUnitFrameSystemIndices.Player, setting = Enum.EditModeUnitFrameSetting.CastBarUnderneath},
	}
};

-- Create a mirrored settings map for easy access
EditModeSettingDisplayInfoManager.mirroredSettingsMap = {};
for _, mirrors in ipairs(mirroredSettings) do
	for _, mirroredSetting in ipairs(mirrors) do
		if not EditModeSettingDisplayInfoManager.mirroredSettingsMap[mirroredSetting.system] then
			EditModeSettingDisplayInfoManager.mirroredSettingsMap[mirroredSetting.system] = {};
		end

		if mirroredSetting.systemIndex and not EditModeSettingDisplayInfoManager.mirroredSettingsMap[mirroredSetting.system][mirroredSetting.systemIndex] then
			EditModeSettingDisplayInfoManager.mirroredSettingsMap[mirroredSetting.system][mirroredSetting.systemIndex] = {};
		end

		local systemMirrors = mirroredSetting.systemIndex and EditModeSettingDisplayInfoManager.mirroredSettingsMap[mirroredSetting.system][mirroredSetting.systemIndex] or EditModeSettingDisplayInfoManager.mirroredSettingsMap[mirroredSetting.system];

		if not systemMirrors[mirroredSetting.setting] then
			systemMirrors[mirroredSetting.setting] = {};
		end

		for _, otherSetting in ipairs(mirrors) do
			if mirroredSetting ~= otherSetting then
				table.insert(systemMirrors[mirroredSetting.setting], otherSetting);
			end
		end
	end
end

function EditModeSettingDisplayInfoManager:GetMirroredSettings(system, systemIndex, setting)
	local systemMirrors;
	if systemIndex then
		systemMirrors = EditModeSettingDisplayInfoManager.mirroredSettingsMap[system] and EditModeSettingDisplayInfoManager.mirroredSettingsMap[system][systemIndex];
	else
		systemMirrors = EditModeSettingDisplayInfoManager.mirroredSettingsMap[system];
	end
	return systemMirrors and systemMirrors[setting];
end