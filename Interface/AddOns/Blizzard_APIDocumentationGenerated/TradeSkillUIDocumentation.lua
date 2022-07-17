local TradeSkillUI =
{
	Name = "TradeSkillUI",
	Type = "System",
	Namespace = "C_TradeSkillUI",

	Functions =
	{
		{
			Name = "CloseCraftingOrders",
			Type = "Function",
		},
		{
			Name = "CloseCustomerOrders",
			Type = "Function",
		},
		{
			Name = "CloseTradeSkill",
			Type = "Function",
		},
		{
			Name = "ContinueRecast",
			Type = "Function",
		},
		{
			Name = "CraftRecipe",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "numCasts", Type = "number", Nilable = false, Default = 1 },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = true },
				{ Name = "recipeLevel", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CraftSalvage",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "numCasts", Type = "number", Nilable = false, Default = 1 },
				{ Name = "itemLocation", Type = "table", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
		{
			Name = "GetAllProfessionTradeSkillLines",
			Type = "Function",

			Returns =
			{
				{ Name = "skillLineID", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetBaseProfessionInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "ProfessionInfo", Nilable = false },
			},
		},
		{
			Name = "GetChildProfessionInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "ProfessionInfo", Nilable = false },
			},
		},
		{
			Name = "GetChildProfessionInfos",
			Type = "Function",

			Returns =
			{
				{ Name = "infos", Type = "table", InnerType = "ProfessionInfo", Nilable = false },
			},
		},
		{
			Name = "GetCraftingOperationInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "CraftingOperationInfo", Nilable = true },
			},
		},
		{
			Name = "GetCraftingReagentBonusText",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "craftingReagentIndex", Type = "number", Nilable = false },
				{ Name = "craftingReagents", Type = "table", InnerType = "CraftingReagentInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "bonusText", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "GetFactionSpecificOutputItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetItemReagentQualityByItemInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "quality", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetProfessionChildSkillLineID",
			Type = "Function",

			Returns =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetProfessionGearShown",
			Type = "Function",

			Returns =
			{
				{ Name = "shown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetProfessionInfoBySkillLineID",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "ProfessionInfo", Nilable = false },
			},
		},
		{
			Name = "GetProfessionSkillLineID",
			Type = "Function",

			Arguments =
			{
				{ Name = "profession", Type = "Profession", Nilable = false },
			},

			Returns =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetProfessionSlots",
			Type = "Function",

			Arguments =
			{
				{ Name = "profession", Type = "Profession", Nilable = false },
			},

			Returns =
			{
				{ Name = "slots", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetProfessionSpells",
			Type = "Function",

			Arguments =
			{
				{ Name = "professionID", Type = "number", Nilable = false },
				{ Name = "skillLineID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "knownSpells", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetReagentSlotStatus",
			Type = "Function",

			Arguments =
			{
				{ Name = "mcrSlotID", Type = "number", Nilable = false },
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "locked", Type = "bool", Nilable = false },
				{ Name = "lockedReason", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetRecipeFixedReagentItemLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "reagentSlotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetRecipeInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "recipeLevel", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "recipeInfo", Type = "TradeSkillRecipeInfo", Nilable = true },
			},
		},
		{
			Name = "GetRecipeOutputItemData",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "outputInfo", Type = "CraftingRecipeOutputInfo", Nilable = false },
			},
		},
		{
			Name = "GetRecipeQualityReagentItemLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "mcrSlotIndex", Type = "number", Nilable = false },
				{ Name = "qualityIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetRecipeRepeatCount",
			Type = "Function",

			Returns =
			{
				{ Name = "recastTimes", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRecipeSchematic",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "recipeLevel", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "schematic", Type = "CraftingRecipeSchematic", Nilable = false },
			},
		},
		{
			Name = "GetRecipesTracked",
			Type = "Function",

			Returns =
			{
				{ Name = "recipeIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetSalvagableItemIDs",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetTradeSkillDisplayName",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "professionDisplayName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "HasRecipesTracked",
			Type = "Function",

			Returns =
			{
				{ Name = "hasRecipesTracked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsNPCCrafting",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRecipeInSkillLine",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRecipeProfessionLearned",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "recipeProfessionLearned", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRecipeTracked",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "tracked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRuneforging",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "OpenRecipe",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "OpenTradeSkill",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "opened", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetProfessionChildSkillLineID",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetProfessionGearShown",
			Type = "Function",

			Arguments =
			{
				{ Name = "shown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetRecipeTracked",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "tracked", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "NewRecipeLearned",
			Type = "Event",
			LiteralName = "NEW_RECIPE_LEARNED",
			Payload =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "recipeLevel", Type = "number", Nilable = true },
				{ Name = "baseRecipeID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ObliterumForgeClose",
			Type = "Event",
			LiteralName = "OBLITERUM_FORGE_CLOSE",
		},
		{
			Name = "ObliterumForgePendingItemChanged",
			Type = "Event",
			LiteralName = "OBLITERUM_FORGE_PENDING_ITEM_CHANGED",
		},
		{
			Name = "ObliterumForgeShow",
			Type = "Event",
			LiteralName = "OBLITERUM_FORGE_SHOW",
		},
		{
			Name = "OpenRecipeResponse",
			Type = "Event",
			LiteralName = "OPEN_RECIPE_RESPONSE",
			Payload =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "skillLineID", Type = "number", Nilable = false },
				{ Name = "expansionSkillLineID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TrackedRecipeUpdate",
			Type = "Event",
			LiteralName = "TRACKED_RECIPE_UPDATE",
			Payload =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "tracked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TradeSkillClose",
			Type = "Event",
			LiteralName = "TRADE_SKILL_CLOSE",
		},
		{
			Name = "TradeSkillCraftingReagentBonusTextUpdated",
			Type = "Event",
			LiteralName = "TRADE_SKILL_CRAFTING_REAGENT_BONUS_TEXT_UPDATED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TradeSkillDataSourceChanged",
			Type = "Event",
			LiteralName = "TRADE_SKILL_DATA_SOURCE_CHANGED",
		},
		{
			Name = "TradeSkillDataSourceChanging",
			Type = "Event",
			LiteralName = "TRADE_SKILL_DATA_SOURCE_CHANGING",
		},
		{
			Name = "TradeSkillDetailsUpdate",
			Type = "Event",
			LiteralName = "TRADE_SKILL_DETAILS_UPDATE",
		},
		{
			Name = "TradeSkillItemCraftedResult",
			Type = "Event",
			LiteralName = "TRADE_SKILL_ITEM_CRAFTED_RESULT",
			Payload =
			{
				{ Name = "data", Type = "CraftingItemResultData", Nilable = false },
			},
		},
		{
			Name = "TradeSkillListUpdate",
			Type = "Event",
			LiteralName = "TRADE_SKILL_LIST_UPDATE",
		},
		{
			Name = "TradeSkillNameUpdate",
			Type = "Event",
			LiteralName = "TRADE_SKILL_NAME_UPDATE",
		},
		{
			Name = "TradeSkillShow",
			Type = "Event",
			LiteralName = "TRADE_SKILL_SHOW",
		},
		{
			Name = "UpdateTradeskillRecast",
			Type = "Event",
			LiteralName = "UPDATE_TRADESKILL_RECAST",
		},
		{
			Name = "UpdateTradeskillRecastReady",
			Type = "Event",
			LiteralName = "UPDATE_TRADESKILL_RECAST_READY",
		},
	},

	Tables =
	{
		{
			Name = "CraftingReagentItemFlag",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "TooltipShowsAsStatModifications", Type = "CraftingReagentItemFlag", EnumValue = 0 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TradeSkillUI);