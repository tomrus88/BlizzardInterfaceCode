local EditModeManager =
{
	Name = "EditModeManager",
	Type = "System",
	Namespace = "C_EditMode",

	Functions =
	{
		{
			Name = "ConvertLayoutInfoToHyperlink",
			Type = "Function",

			Arguments =
			{
				{ Name = "layoutInfo", Type = "EditModeLayoutInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "hyperlink", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ConvertLayoutInfoToString",
			Type = "Function",

			Arguments =
			{
				{ Name = "layoutInfo", Type = "EditModeLayoutInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "layoutInfoAsString", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ConvertStringToLayoutInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "layoutInfoAsString", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "layoutInfo", Type = "EditModeLayoutInfo", Nilable = false },
			},
		},
		{
			Name = "GetEditModeInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "layoutInfo", Type = "EditModeInfo", Nilable = false },
			},
		},
		{
			Name = "OnLayoutAdded",
			Type = "Function",

			Arguments =
			{
				{ Name = "addedLayoutIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "OnLayoutDeleted",
			Type = "Function",

			Arguments =
			{
				{ Name = "deletedLayoutIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SaveEditModeInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "saveInfo", Type = "EditModeInfo", Nilable = false },
			},
		},
		{
			Name = "SetActiveLayout",
			Type = "Function",

			Arguments =
			{
				{ Name = "activeLayout", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "EditModeDataUpdated",
			Type = "Event",
			LiteralName = "EDIT_MODE_DATA_UPDATED",
			Payload =
			{
				{ Name = "layoutInfo", Type = "EditModeInfo", Nilable = false },
				{ Name = "fromServer", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "EditModeAnchorInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "point", Type = "FramePoint", Nilable = false },
				{ Name = "relativeTo", Type = "string", Nilable = false },
				{ Name = "relativePoint", Type = "FramePoint", Nilable = false },
				{ Name = "offsetX", Type = "number", Nilable = false },
				{ Name = "offsetY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EditModeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "layouts", Type = "table", InnerType = "EditModeLayoutInfo", Nilable = false },
				{ Name = "activeLayout", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EditModeLayoutInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "layoutName", Type = "string", Nilable = false },
				{ Name = "layoutType", Type = "EditModeLayoutType", Nilable = false },
				{ Name = "systems", Type = "table", InnerType = "EditModeSystemInfo", Nilable = false },
			},
		},
		{
			Name = "EditModeSettingInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "setting", Type = "number", Nilable = false },
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EditModeSystemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "system", Type = "EditModeSystem", Nilable = false },
				{ Name = "systemIndex", Type = "number", Nilable = true },
				{ Name = "anchorInfo", Type = "EditModeAnchorInfo", Nilable = false },
				{ Name = "settings", Type = "table", InnerType = "EditModeSettingInfo", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EditModeManager);