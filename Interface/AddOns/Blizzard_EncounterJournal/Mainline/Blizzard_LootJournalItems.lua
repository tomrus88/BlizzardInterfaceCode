LootJournalItemsMixin = { };

function LootJournalItemsMixin:OnLoad()
	self:SetView(LOOT_JOURNAL_ITEM_SETS);
	self:RegisterEvent("LOOT_JOURNAL_ITEM_UPDATE");
	EventUtil.ContinueOnPlayerLogin(function() self:SetClassAndSpecFiltersFromSpecialization(); end);
end

function LootJournalItemsMixin:SetClassAndSpecFiltersFromSpecialization()
	local _, _, classID = UnitClass("player");
	local specID = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization());
	self:SetClassAndSpecFilters(classID, specID);
end

function LootJournalItemsMixin:SetClassAndSpecFilters(classID, specID)
	self.classFilter = classID;
	self.specFilter = specID;
end

function LootJournalItemsMixin:GetClassAndSpecFilters()
	return self.classFilter or UNSPECIFIED_CLASS_FILTER, self.specFilter or UNSPECIFIED_SPEC_FILTER;
end

function LootJournalItemsMixin:OnEvent(event)
	if ( event == "LOOT_JOURNAL_ITEM_UPDATE" ) then
		self:Refresh();
	end
end

function LootJournalItemsMixin:SetView(view)
	if ( self.view == view ) then
		return;
	end

	self.view = view;
	self.ItemSetsFrame:Show();
end

function LootJournalItemsMixin:GetActiveList()
	return self.ItemSetsFrame;
end

function LootJournalItemsMixin:Refresh()
	self:GetActiveList():Refresh();
end

function LootJournalItemButtonTemplate_OnEnter(self)
	local listFrame = self:GetParent();
	while ( listFrame and not listFrame.ShowItemTooltip ) do
		listFrame = listFrame:GetParent();
	end
	if ( listFrame ) then
		listFrame:ShowItemTooltip(self);
		self:SetScript("OnUpdate", LootJournalItemButton_OnUpdate);
		self.UpdateTooltip = LootJournalItemButtonTemplate_OnEnter;
	end
end

function LootJournalItemButtonTemplate_OnLeave(self)
	self.UpdateTooltip = nil;
	GameTooltip:Hide();
	self:SetScript("OnUpdate", nil);
	ResetCursor();
end

--=================================================================================================================================== 
LootJournalItemSetsMixin = {}

local LJ_ITEMSET_X_OFFSET = 10;
local LJ_ITEMSET_Y_OFFSET = 29;
local LJ_ITEMSET_BUTTON_SPACING = 13;
local LJ_ITEMSET_BOTTOM_BUFFER = 4;

function LootJournalItemSetsMixin:Refresh()
	self.dirty = true;

	self:UpdateList();

	if ( self.ClassDropdown ) then
		self:SetupClassDropdown();
	end
	if ( self.SlotButton ) then
		self:UpdateSlotButtonText();
	end
end

function LootJournalItemSetsMixin:SetupClassDropdown()
	local getClassFilter = GenerateClosure(self.GetClassFilter, self);
	local getSpecFilter = GenerateClosure(self.GetSpecFilter, self);
	local setClassAndSpecFilter = GenerateClosure(self.SetClassAndSpecFilters, self);
	local excludeSpec, excludeAllSpecOption = false, true;
	ClassMenu.InitClassSpecDropdown(self.ClassDropdown, getClassFilter, getSpecFilter, setClassAndSpecFilter, excludeSpec, excludeAllSpecOption);
end

function LootJournalItemSetsMixin:GetClassAndSpecFilters()
	return self:GetParent():GetClassAndSpecFilters();
end

function LootJournalItemSetsMixin:GetPreviewClassAndSpec()
	local classID, specID = self:GetClassAndSpecFilters();
	if specID == 0 then
		local spec = C_SpecializationInfo.GetSpecialization();
		if spec and classID == select(3, UnitClass("player")) then
			specID = C_SpecializationInfo.GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player"));
		else
			specID = -1;
		end
	end
	return classID, specID;
end

function LootJournalItemSetsMixin:ShowItemTooltip(button)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
	-- itemLink may not be available until after a GET_ITEM_INFO_RECEIVED event
	if ( button.itemLink ) then
		local classID, specID = self:GetPreviewClassAndSpec();
		GameTooltip:SetHyperlink(button.itemLink, classID, specID);
	else
		GameTooltip:SetItemByID(button.itemID);
	end
	self.tooltipItemID = button.itemID;
	GameTooltip_ShowCompareItem();
end

function LootJournalItemSetsMixin:CheckItemButtonTooltip(button)
	if ( GameTooltip:GetOwner() == button and self.tooltipItemID ~= button.itemID ) then
		self:ShowItemTooltip(button);
	end
end

function LootJournalItemSetsMixin:GetClassFilter()
	local classFilter, specFilter = self:GetClassAndSpecFilters();
	return classFilter;
end

function LootJournalItemSetsMixin:GetSpecFilter()
	local classFilter, specFilter = self:GetClassAndSpecFilters();
	return specFilter;
end

function LootJournalItemSetsMixin:SetClassAndSpecFilters(newClassFilter, newSpecFilter)
	local classFilter, specFilter = self:GetClassAndSpecFilters();
	if not self.classAndSpecFiltersSet or classFilter ~= newClassFilter or specFilter ~= newSpecFilter then
		-- if choosing just a class without a spec, pick a spec
		if newClassFilter ~= UNSPECIFIED_CLASS_FILTER and newSpecFilter == UNSPECIFIED_SPEC_FILTER then
			local _, _, classID = UnitClass("player");
			-- if player's class, choose active spec
			-- otherwise use 1st spec
			if classID == newClassFilter then
				newSpecFilter = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization());
			else
				local sex = UnitSex("player");
				newSpecFilter = GetSpecializationInfoForClassID(newClassFilter, 1, sex);
			end
		end
		self:GetParent():SetClassAndSpecFilters(newClassFilter, newSpecFilter);

		self.ScrollBar:ScrollToBegin();

		self:Refresh();
	end

	self.classAndSpecFiltersSet = true;
end

	function LootJournalItemButton_OnUpdate(self)
		if GameTooltip:IsOwned(self) then
			if IsModifiedClick("DRESSUP") then
				ShowInspectCursor();
			else
				ResetCursor();
			end
		end	
	end

function LootJournalItemSetsMixin:OnLoad()
	local view = CreateScrollBoxListLinearView(LJ_ITEMSET_Y_OFFSET, 0, LJ_ITEMSET_X_OFFSET, 0, LJ_ITEMSET_BUTTON_SPACING);

	local configureItemButton = GenerateClosure(self.ConfigureItemButton, self);
	local function Initializer(frame, elementData)
		frame:Init(elementData, configureItemButton);
	end
	view:SetElementInitializer("LootJournalItemSetButtonTemplate", Initializer);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.ClassDropdown:SetWidth(175);
end

function LootJournalItemSetsMixin:OnShow()
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	if not self.init then
		self.init = true;
		self:Refresh();
	end

	self:SetupClassDropdown();
end

function LootJournalItemSetsMixin:OnHide()
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
end

function LootJournalItemSetsMixin:OnEvent(event, ...)
	if ( event == "GET_ITEM_INFO_RECEIVED" ) then
		local itemID = ...;

		self.ScrollBox:ForEachFrame(function(frame, elementData)
			local itemButtons = frame.ItemButtons;
			for j = 1, #itemButtons do
				if itemButtons[j].itemID == itemID then
					self:ConfigureItemButton(itemButtons[j]);
					return;
				end
			end
		end);
	end
end

function LootJournalItemSetsMixin:ConfigureItemButton(button)
	local _, itemLink, itemQuality = C_Item.GetItemInfo(button.itemID);
	button.itemLink = itemLink;
	itemQuality = itemQuality or Enum.ItemQuality.Epic;	-- sets are most likely rare
	local atlasData = ColorManager.GetAtlasDataForLootJournalSetItemQuality(itemQuality);
	if atlasData then
		button.Border:SetAtlas(atlasData.atlas, true);

		if atlasData.overrideColor then
			button.Border:SetVertexColor(atlasData.overrideColor.r, atlasData.overrideColor.g, atlasData.overrideColor.b);
		else
			button.Border:SetVertexColor(1, 1, 1);
		end
	end

	local r, g, b = C_Item.GetItemQualityColor(itemQuality);
	button:GetParent().SetName:SetTextColor(r, g, b);

	self:CheckItemButtonTooltip(button);
end

function SortItemSetItems(entry1, entry2)
	local order1 = EJ_GetInvTypeSortOrder(entry1.invType);
	local order2 = EJ_GetInvTypeSortOrder(entry2.invType);
	if ( order1 ~= order2 ) then
		return order1 < order2;
	end
	if ( entry1.itemID and entry2.itemID ) then
		return entry1.itemID < entry2.itemID;
	end
	return true;
end

function LootJournalItemSetsMixin:UpdateList()
	if ( self.dirty ) then
		self.itemSets = C_LootJournal.GetItemSets(self:GetClassAndSpecFilters());
		self.dirty = nil;

		local SortItemSets = function(set1, set2)
			if ( set1.itemLevel ~= set2.itemLevel ) then
				return set1.itemLevel > set2.itemLevel;
			end
			local strCmpResult = strcmputf8i(set1.name, set2.name);
			if ( strCmpResult ~= 0 ) then
				return strCmpResult < 0;
			end
			return set1.setID > set2.setID;
		end
		table.sort(self.itemSets, SortItemSets);
	end

	local dataProvider = CreateDataProvider(self.itemSets);
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

LootJournalItemSetButtonMixin = {};

function LootJournalItemSetButtonMixin:Init(elementData, configureItemButton)
	self.SetName:SetText(elementData.name);
	self.ItemLevel:SetFormattedText(ITEM_LEVEL, elementData.itemLevel);
	local items = C_LootJournal.GetItemSetItems(elementData.setID);
	table.sort(items, SortItemSetItems);
	for j = 1, #items do
		local itemButton = self.ItemButtons[j];
		if ( not itemButton ) then
			itemButton = CreateFrame("BUTTON", nil, self, "LootJournalItemSetItemButtonTemplate");
			itemButton:SetPoint("LEFT", self.ItemButtons[j-1], "RIGHT", 5, 0);
		end
		itemButton.Icon:SetTexture(items[j].icon);
		itemButton.itemID = items[j].itemID;
		itemButton:Show();
		configureItemButton(itemButton);
	end
	for j = #items + 1, #self.ItemButtons do
		self.ItemButtons[j].itemID = nil;
		self.ItemButtons[j]:Hide();
	end
end

			