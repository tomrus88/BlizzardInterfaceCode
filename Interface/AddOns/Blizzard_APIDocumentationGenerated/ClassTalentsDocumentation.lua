local ClassTalents =
{
	Name = "ClassTalents",
	Type = "System",
	Namespace = "C_ClassTalents",

	Functions =
	{
		{
			Name = "CanChangeTalents",
			Type = "Function",

			Returns =
			{
				{ Name = "canChange", Type = "bool", Nilable = false },
				{ Name = "canAdd", Type = "bool", Nilable = false },
				{ Name = "changeError", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CommitConfig",
			Type = "Function",

			Arguments =
			{
				{ Name = "savedConfigID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetActiveConfigID",
			Type = "Function",

			Returns =
			{
				{ Name = "activeConfigID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetConfigIDsBySpecID",
			Type = "Function",

			Arguments =
			{
				{ Name = "specID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "configIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "IsConfigReady",
			Type = "Function",
			Documentation = { "New configs may or may not be ready to load immediately after creation" },

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isReady", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LoadConfig",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
				{ Name = "autoApply", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "LoadConfigResult", Nilable = false },
			},
		},
		{
			Name = "RequestNewConfig",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SaveConfig",
			Type = "Function",

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ActiveCombatConfigChanged",
			Type = "Event",
			LiteralName = "ACTIVE_COMBAT_CONFIG_CHANGED",
			Payload =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "LoadConfigResult",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Error", Type = "LoadConfigResult", EnumValue = 0 },
				{ Name = "NoChangesNecessary", Type = "LoadConfigResult", EnumValue = 1 },
				{ Name = "LoadInProgress", Type = "LoadConfigResult", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ClassTalents);