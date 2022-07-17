local ProfessionSpecConstants =
{
	Tables =
	{
		{
			Name = "ProfTraitPerkNodeFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "UnlocksSubpath", Type = "ProfTraitPerkNodeFlags", EnumValue = 1 },
			},
		},
		{
			Name = "ProfessionsSpecPathState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Locked", Type = "ProfessionsSpecPathState", EnumValue = 0 },
				{ Name = "Progressing", Type = "ProfessionsSpecPathState", EnumValue = 1 },
				{ Name = "Completed", Type = "ProfessionsSpecPathState", EnumValue = 2 },
			},
		},
		{
			Name = "ProfessionsSpecTabState",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Locked", Type = "ProfessionsSpecTabState", EnumValue = 0 },
				{ Name = "Unlocked", Type = "ProfessionsSpecTabState", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ProfessionSpecConstants);