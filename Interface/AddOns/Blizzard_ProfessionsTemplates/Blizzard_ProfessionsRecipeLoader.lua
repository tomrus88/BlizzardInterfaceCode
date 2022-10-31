local ProfessionsRecipeLoaderMixin = {};

local function Load(item, func)
	local continuableContainer = ContinuableContainer:Create();
	continuableContainer:AddContinuable(item);
	continuableContainer:ContinueOnLoad(func);
	return continuableContainer;
end

function ProfessionsRecipeLoaderMixin:Load(recipeSchematic, callback)
	self.callback = callback;

	local recipeID = recipeSchematic.recipeID;
	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID);
	local outputItemID = recipeSchematic.outputItemID;
	local counter;
	if recipeInfo.qualityItemIDs then
		counter = 1 + #recipeInfo.qualityItemIDs;
	elseif outputItemID then
		counter = 2;
	else
		counter = 1;
	end

	self.qualityItemIDLoads = {};

	local function Decrement()
		counter = counter - 1;
		if counter == 0 then
			callback();
		end
	end

	local spell = Spell:CreateFromSpellID(recipeID);
	self.spellCancelFunc = spell:ContinueWithCancelOnSpellLoad(function()
		Decrement();
	end);

	if recipeInfo.qualityItemIDs then
		for _, itemID in ipairs(recipeInfo.qualityItemIDs) do
			local cc = Load(Item:CreateFromItemID(itemID), function()
				Decrement();
			end);
			table.insert(self.qualityItemIDLoads, cc);
		end
	elseif outputItemID then
		self.cc1 = Load(Item:CreateFromItemID(outputItemID), function()
			local itemID2 = C_TradeSkillUI.GetFactionSpecificOutputItem(recipeID);
			if itemID2 then
				self.cc2 = Load(Item:CreateFromItemID(itemID2), function()
					Decrement();
				end);
			else
				Decrement();
			end
		end);
	end
end

function ProfessionsRecipeLoaderMixin:Cancel()
	if self.spellCancelFunc then
		self.spellCancelFunc();
		self.spellCancelFunc = nil;
	end

	if self.cc1 then
		self.cc1:Cancel();
		self.cc1 = nil;
	end

	if self.cc2 then
		self.cc2:Cancel();
		self.cc2 = nil;
	end

	for _, cc in ipairs(self.qualityItemIDLoads) do
		cc:Cancel();
	end
	self.qualityItemIDLoads = {};
end

function CreateProfessionsRecipeLoader(recipeSchematic, callback)
	local loader = CreateFromMixins(ProfessionsRecipeLoaderMixin);
	loader:Load(recipeSchematic, callback)
	return loader;
end