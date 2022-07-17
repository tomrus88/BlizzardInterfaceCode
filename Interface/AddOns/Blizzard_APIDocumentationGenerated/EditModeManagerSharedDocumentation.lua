local EditModeManagerShared =
{
	Tables =
	{
		{
			Name = "ActionBarOrientation",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Horizontal", Type = "ActionBarOrientation", EnumValue = 0 },
				{ Name = "Vertical", Type = "ActionBarOrientation", EnumValue = 1 },
			},
		},
		{
			Name = "ActionBarVisibleSetting",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Always", Type = "ActionBarVisibleSetting", EnumValue = 0 },
				{ Name = "InCombat", Type = "ActionBarVisibleSetting", EnumValue = 1 },
				{ Name = "OutOfCombat", Type = "ActionBarVisibleSetting", EnumValue = 2 },
			},
		},
		{
			Name = "CastBarSize",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Small", Type = "CastBarSize", EnumValue = 0 },
				{ Name = "Medium", Type = "CastBarSize", EnumValue = 1 },
				{ Name = "Large", Type = "CastBarSize", EnumValue = 2 },
			},
		},
		{
			Name = "EditModeActionBarSetting",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "Orientation", Type = "EditModeActionBarSetting", EnumValue = 0 },
				{ Name = "NumRows", Type = "EditModeActionBarSetting", EnumValue = 1 },
				{ Name = "NumIcons", Type = "EditModeActionBarSetting", EnumValue = 2 },
				{ Name = "IconSize", Type = "EditModeActionBarSetting", EnumValue = 3 },
				{ Name = "IconPadding", Type = "EditModeActionBarSetting", EnumValue = 4 },
				{ Name = "VisibleSetting", Type = "EditModeActionBarSetting", EnumValue = 5 },
				{ Name = "HideBarArt", Type = "EditModeActionBarSetting", EnumValue = 6 },
				{ Name = "SnapToSide", Type = "EditModeActionBarSetting", EnumValue = 7 },
				{ Name = "HideBarScrolling", Type = "EditModeActionBarSetting", EnumValue = 8 },
			},
		},
		{
			Name = "EditModeCastBarSetting",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "BarSize", Type = "EditModeCastBarSetting", EnumValue = 0 },
			},
		},
		{
			Name = "EditModeLayoutType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Preset", Type = "EditModeLayoutType", EnumValue = 0 },
				{ Name = "Account", Type = "EditModeLayoutType", EnumValue = 1 },
				{ Name = "Character", Type = "EditModeLayoutType", EnumValue = 2 },
			},
		},
		{
			Name = "EditModeMinimapSetting",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "HeaderUnderneath", Type = "EditModeMinimapSetting", EnumValue = 0 },
			},
		},
		{
			Name = "EditModePresetLayouts",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Modern", Type = "EditModePresetLayouts", EnumValue = 0 },
				{ Name = "Classic", Type = "EditModePresetLayouts", EnumValue = 1 },
			},
		},
		{
			Name = "EditModeSettingDisplayType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Dropdown", Type = "EditModeSettingDisplayType", EnumValue = 0 },
				{ Name = "Checkbox", Type = "EditModeSettingDisplayType", EnumValue = 1 },
				{ Name = "Slider", Type = "EditModeSettingDisplayType", EnumValue = 2 },
			},
		},
		{
			Name = "EditModeSystem",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "ActionBar", Type = "EditModeSystem", EnumValue = 0 },
				{ Name = "CastBar", Type = "EditModeSystem", EnumValue = 1 },
				{ Name = "Minimap", Type = "EditModeSystem", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EditModeManagerShared);