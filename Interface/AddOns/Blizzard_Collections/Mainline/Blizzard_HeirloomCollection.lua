local VIEW_MODE_FULL = 1; -- Shows everything and isn't filtered by class/spec
local VIEW_MODE_CLASS = 2; -- Only shows items valid for the selected class/spec

HeirloomsMixin = {}

function HeirloomsJournal_OnEvent(self, event, ...)
	if event == "HEIRLOOMS_UPDATED" then
		self:OnHeirloomsUpdated(...);
	elseif event == "HEIRLOOM_UPGRADE_TARGETING_CHANGED" then
		local isPendingHeirloomUpgrade = ...;
		self:SetFindClosestUpgradeablePage(isPendingHeirloomUpgrade);
		self:RefreshViewIfVisible();
	end
end

function HeirloomsJournal_OnShow(self)
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HEIRLOOM_JOURNAL, true);

	CollectionsJournal:SetPortraitToAsset("Interface\\Icons\\inv_misc_enggizmos_19");
	local classFilter, specFilter = C_Heirloom.GetClassAndSpecFilters();
	if self.filtersSet == nil then
		if UnitLevel("player") >= GetMaxPlayerLevel() then
			-- Default to full view for max level players
			C_Heirloom.SetClassAndSpecFilters(UNSPECIFIED_CLASS_FILTER, UNSPECIFIED_SPEC_FILTER);
		else
			-- Default to current class/spec view otherwise
			local classDisplayName, classTag, classID = UnitClass("player");
			local specID = nil;
			local specIndex = C_SpecializationInfo.GetSpecialization();
			if specIndex then
				specID = C_SpecializationInfo.GetSpecializationInfo(specIndex);
			else
				specID = UNSPECIFIED_SPEC_FILTER;
			end

			C_Heirloom.SetClassAndSpecFilters(classID, specID);
		end

		self.ClassDropdown:GenerateMenu();
	end

	if self.needsRefresh then
		self:RefreshView();
	end
end

function HeirloomsJournal_OnMouseWheel(self, delta)
	self.PagingFrame:OnMouseWheel(delta);
end

function HeirloomsJournal_UpdateButton(self)
	self:GetParent():GetParent():UpdateButton(self);
end

function HeirloomsJournalSpellButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetHeirloomByItemID(self.itemID);

	self.UpdateTooltip = HeirloomsJournalSpellButton_OnEnter;

	if self:GetParent():GetParent():ClearNewStatus(self.itemID) then
		HeirloomsJournal_UpdateButton(self);
	end

	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function HeirloomsJournalSpellButton_OnClick(self, button)
	if IsModifiedClick() then
		local itemLink = C_Heirloom.GetHeirloomLink(self.itemID);
		HandleModifiedItemClick(itemLink);
	else
		if SpellCanTargetItemID() then
			if C_Heirloom.IsPendingHeirloomUpgrade() then
				C_Heirloom.UpgradeHeirloom(self.itemID);
			end
		else
			C_Heirloom.CreateHeirloom(self.itemID);
		end
	end
end

function HeirloomsMixin:OnLoad()
	self.newHeirlooms = UIParent.newHeirlooms or {};
	self.upgradedHeirlooms = {};

	self.heirloomEntryFrames = {};
	self.heirloomHeaderFrames = {};

	self.heirloomLayoutData = {};
	self.itemIDsInCurrentLayout = {};

	self.numKnownHeirlooms = 0;
	self.numPossibleHeirlooms = 0;

	self.ClassDropdown:SetWidth(150);

	self:InitFilterDropdown();
	self:InitClassDropdown();
	self:FullRefreshIfVisible();

	self:RegisterEvent("HEIRLOOMS_UPDATED");
	self:RegisterEvent("HEIRLOOM_UPGRADE_TARGETING_CHANGED");
end

function HeirloomsMixin:InitFilterDropdown()
	self.FilterDropdown:SetWidth(90);

	self.FilterDropdown:SetUpdateCallback(function()
		self:FullRefreshIfVisible();
	end);

	self.FilterDropdown:SetIsDefaultCallback(function()
		return C_HeirloomInfo.IsUsingDefaultFilters();
	end);
	
	self.FilterDropdown:SetDefaultCallback(function()
		C_HeirloomInfo.SetDefaultFilters();
		self:FullRefreshIfVisible();
	end);

	self.FilterDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_HEIRLOOMS_FILTER");

		rootDescription:CreateCheckbox(COLLECTED, C_Heirloom.GetCollectedHeirloomFilter, function()
			HeirloomsJournal:SetCollectedHeirloomFilter(not C_Heirloom.GetCollectedHeirloomFilter());
		end);

		rootDescription:CreateCheckbox(NOT_COLLECTED, C_Heirloom.GetUncollectedHeirloomFilter, function()
			HeirloomsJournal:SetUncollectedHeirloomFilter(not C_Heirloom.GetUncollectedHeirloomFilter());
		end);
		
		local function IsChecked(filterIndex) 
			return self:IsSourceChecked(filterIndex)
		end

		local function SetChecked(filterIndex) 
			self:SetSourceChecked(filterIndex, not IsChecked(filterIndex));
		end

		local submenu = rootDescription:CreateButton(SOURCES);
		submenu:CreateButton(CHECK_ALL, function()
			self:SetAllSourcesChecked(true);
			return MenuResponse.Refresh;
		end);

		submenu:CreateButton(UNCHECK_ALL, function()
			self:SetAllSourcesChecked(false);
			return MenuResponse.Refresh;
		end);

		for filterIndex = 1, C_PetJournal.GetNumPetSources() do
			if C_HeirloomInfo.IsHeirloomSourceValid(filterIndex) then
				submenu:CreateCheckbox(_G["BATTLE_PET_SOURCE_"..filterIndex], IsChecked, SetChecked, filterIndex);
			end
		end
	end);
end

function HeirloomsMixin:InitClassDropdown()
	local getClassFilter = GenerateClosure(self.GetClassFilter, self);
	local getSpecFilter = GenerateClosure(self.GetSpecFilter, self);
	local setClassAndSpecFilter = GenerateClosure(self.SetClassAndSpecFilters, self);
	ClassMenu.InitClassSpecDropdown(self.ClassDropdown, getClassFilter, getSpecFilter, setClassAndSpecFilter);
end

function HeirloomsMixin:OnHeirloomsUpdated(itemID, updateReason, ...)
	if itemID then
		-- Single item update
		local requiresFullUpdate = false;
		if updateReason == "NEW" then
			local wasHidden = ...;

			self.newHeirlooms[itemID] = true;
			if self.itemIDsInCurrentLayout[itemID] then
				self.numKnownHeirlooms = self.numKnownHeirlooms + 1;
				self:UpdateProgressBar();
			end

			requiresFullUpdate = wasHidden;
		elseif updateReason == "UPGRADE" then
			self.upgradedHeirlooms[itemID] = true;
		end

		if requiresFullUpdate then
			self:FullRefreshIfVisible();
		else
			self:RefreshViewIfVisible();
		end
	else
		-- Full update
		self:FullRefreshIfVisible();
	end
end

function HeirloomsMixin:ClearNewStatus(itemID)
	if self.newHeirlooms[itemID] then
		self.newHeirlooms[itemID] = nil;
		return true;
	end
	return false;
end

function HeirloomsMixin:SetFindClosestUpgradeablePage(findClosestUpgradeablePage)
	self.findClosestUpgradeablePage = findClosestUpgradeablePage;
end

function HeirloomsMixin:FullRefreshIfVisible()
	self.needsDataRebuilt = true;
	self:RefreshViewIfVisible();
end

function HeirloomsMixin:RefreshViewIfVisible()
	if self:IsVisible() then
		self:RefreshView();
	else
		self.needsRefresh = true;
	end
end

function HeirloomsMixin:RebuildLayoutData()
	if not self.needsDataRebuilt then
		return;
	end
	self.needsDataRebuilt = false;

	self.heirloomLayoutData = {};
	self.itemIDsInCurrentLayout = {};

	self.numKnownHeirlooms = 0;
	self.numPossibleHeirlooms = 0;

	local equipBuckets = self:SortHeirloomsIntoEquipmentBuckets();
	self:SortEquipBucketsIntoPages(equipBuckets);
	self.PagingFrame:SetMaxPages(math.max(#self.heirloomLayoutData, 1));
end

local function GetHeirloomCategoryFromInvType(invType)
	if invType == "INVTYPE_HEAD" then
		return HEIRLOOMS_CATEGORY_HEAD;
	elseif invType == "INVTYPE_SHOULDER" then
		return HEIRLOOMS_CATEGORY_SHOULDER;
	elseif invType == "INVTYPE_CHEST" or invType == "INVTYPE_ROBE" then
		return HEIRLOOMS_CATEGORY_CHEST;
	elseif invType == "INVTYPE_LEGS" then
		return HEIRLOOMS_CATEGORY_LEGS;
	elseif invType == "INVTYPE_CLOAK" then
		return HEIRLOOMS_CATEGORY_BACK;
	elseif invType == "INVTYPE_WEAPON" or invType == "INVTYPE_SHIELD" or invType == "INVTYPE_RANGED" or invType == "INVTYPE_RANGED" or invType == "INVTYPE_2HWEAPON" or invType == "INVTYPE_RELIC"
		or invType == "INVTYPE_WEAPONMAINHAND" or invType == "INVTYPE_WEAPONOFFHAND" or invType == "INVTYPE_HOLDABLE" or invType == "INVTYPE_THROWN" or invType == "INVTYPE_RANGEDRIGHT" then
		return HEIRLOOMS_CATEGORY_WEAPON;
	elseif invType == "INVTYPE_FINGER" or invType == "INVTYPE_TRINKET" or invType == "INVTYPE_NECK" then
		return HEIRLOOMS_CATEGORY_TRINKETS_RINGS_AND_NECKLACES;
	end

	return nil;
end

function HeirloomsMixin:DetermineViewMode()
	local classFilter, specFilter = C_Heirloom.GetClassAndSpecFilters();
	if classFilter == UNSPECIFIED_CLASS_FILTER and specFilter == UNSPECIFIED_SPEC_FILTER then
		return VIEW_MODE_FULL;
	end

	return VIEW_MODE_CLASS;
end

function HeirloomsMixin:SortHeirloomsIntoEquipmentBuckets()
	-- Sort them into equipment buckets
	local equipBuckets = {};
	for i = 1, C_Heirloom.GetNumDisplayedHeirlooms() do
		local itemID = C_Heirloom.GetHeirloomItemIDFromDisplayedIndex(i);

		local name, itemEquipLoc, isPvP, itemTexture, upgradeLevel, source, _, effectiveLevel, minLevel, maxLevel = C_Heirloom.GetHeirloomInfo(itemID);
		local category = GetHeirloomCategoryFromInvType(itemEquipLoc);
		if category then
			if not equipBuckets[category] then
				equipBuckets[category] = {};
			end

			table.insert(equipBuckets[category], itemID);

			-- Count this heirloom as long as it has a category and matches the class/spec filter, other filters should not affect the count
			if C_Heirloom.PlayerHasHeirloom(itemID) then
				self.numKnownHeirlooms = self.numKnownHeirlooms + 1;
			end
			self.numPossibleHeirlooms = self.numPossibleHeirlooms + 1;

			self.itemIDsInCurrentLayout[itemID] = true;
		end
	end

	return equipBuckets;
end

-- Each heirloom button entry dimension
local BUTTON_WIDTH = 208;
local BUTTON_HEIGHT = 50;

-- Padding around each heirloom button
local BUTTON_PADDING_X = 0;
local BUTTON_PADDING_Y = 16;

-- The total height of a heirloom header
local HEADER_HEIGHT = 24 + 13;

-- Y padding before the first header of a page
local FIRST_HEADER_Y_PADDING = 0;
-- Y padding before additional headers after the first header of a page
local ADDITIONAL_HEADER_Y_PADDING = 16;

-- Max height of a page before starting a new page, when the view mode is in "all classes"
local VIEW_MODE_FULL_PAGE_HEIGHT = 370;
-- Max height of a page before starting a new page, when the view mode is in "specific class"
local VIEW_MODE_CLASS_PAGE_HEIGHT = 380;
-- Max width of a page before starting a new row
local PAGE_WIDTH = 625;

-- The starting X offset of a page
local START_OFFSET_X = 40;
-- The starting Y offset of a page
local START_OFFSET_Y = -25;

-- Additional Y offset of a page when the view mode is in "all classes"
local VIEW_MODE_FULL_ADDITIONAL_Y_OFFSET = 0;
-- Additional Y offset of a page when the view mode is in "specific class"
local VIEW_MODE_CLASS_ADDITIONAL_Y_OFFSET = 9;

local ITEM_EQUIP_SLOT_SORT_ORDER = {
	HEIRLOOMS_CATEGORY_HEAD,
	HEIRLOOMS_CATEGORY_SHOULDER,
	HEIRLOOMS_CATEGORY_BACK,
	HEIRLOOMS_CATEGORY_CHEST,
	HEIRLOOMS_CATEGORY_LEGS,
	HEIRLOOMS_CATEGORY_WEAPON,
	HEIRLOOMS_CATEGORY_TRINKETS_RINGS_AND_NECKLACES,
}

local NEW_ROW_OPCODE = -1; -- Used to indicate that the layout should move to the next row

function HeirloomsMixin:SortEquipBucketsIntoPages(equipBuckets)
	if not next(equipBuckets) then
		return;
	end

	local viewMode = self:DetermineViewMode();

	local currentPage = {};
	local pageHeight = viewMode == VIEW_MODE_FULL and VIEW_MODE_FULL_PAGE_HEIGHT or VIEW_MODE_CLASS_PAGE_HEIGHT
	local heightLeft = pageHeight;
	local widthLeft = PAGE_WIDTH;

	for _, itemEquipLoc in ipairs(ITEM_EQUIP_SLOT_SORT_ORDER) do
		local equipBucket = equipBuckets[itemEquipLoc];

		if equipBucket then
			if viewMode == VIEW_MODE_FULL then -- Only headers in full mode
				if heightLeft < HEADER_HEIGHT + BUTTON_PADDING_Y + BUTTON_HEIGHT then
					-- Not enough room to add the upcoming header for this bucket, move to next page
					table.insert(self.heirloomLayoutData, currentPage);
					heightLeft = pageHeight;
					currentPage = {};
				end

				-- Add header
				table.insert(currentPage, itemEquipLoc);
				if #currentPage > 1 then
					heightLeft = heightLeft - ADDITIONAL_HEADER_Y_PADDING - BUTTON_HEIGHT - BUTTON_PADDING_Y;
				else
					heightLeft = heightLeft - FIRST_HEADER_Y_PADDING;
				end

				widthLeft = PAGE_WIDTH;
				heightLeft = heightLeft - HEADER_HEIGHT;
			end

			-- Add buttons
			for i, itemID in ipairs(equipBucket) do
				if widthLeft < BUTTON_WIDTH + BUTTON_PADDING_X then
					-- Not enough room for another entry, try going to a new row
					widthLeft = PAGE_WIDTH;

					if heightLeft < BUTTON_HEIGHT + BUTTON_PADDING_Y then
						-- Not enough room for another row of entries, move to next page
						table.insert(self.heirloomLayoutData, currentPage);

						heightLeft = pageHeight - HEADER_HEIGHT;
						currentPage = {};
					else
						-- Room for another row
						table.insert(currentPage, NEW_ROW_OPCODE);
						heightLeft = heightLeft - BUTTON_HEIGHT - BUTTON_PADDING_Y;
					end
				end

				widthLeft = widthLeft - BUTTON_WIDTH - BUTTON_PADDING_X;
				table.insert(currentPage, itemID);
			end
		end
	end

	table.insert(self.heirloomLayoutData, currentPage);
end

function HeirloomsMixin:AcquireFrame(framePool, numInUse, frameType, template)
	if not framePool[numInUse] then
		framePool[numInUse] = CreateFrame(frameType, nil, self.iconsFrame, template);
	end
	return framePool[numInUse];
end

local function ActivatePooledFrames(framePool, numEntriesInUse)
	for i = 1, numEntriesInUse do
		framePool[i]:Show();
	end

	for i = numEntriesInUse + 1, #framePool do
		framePool[i]:Hide();
	end
end

function HeirloomsMixin:LayoutCurrentPage()
	HelpTip:Hide(self, HEIRLOOMS_JOURNAL_TUTORIAL_UPGRADE);

	local pageLayoutData = self.heirloomLayoutData[self.PagingFrame:GetCurrentPage()];

	local numEntriesInUse = 0;
	local numHeadersInUse = 0;

	if pageLayoutData then
		local offsetX = START_OFFSET_X;
		local offsetY = START_OFFSET_Y;
		if self:DetermineViewMode() == VIEW_MODE_FULL then
			offsetY = offsetY + VIEW_MODE_FULL_ADDITIONAL_Y_OFFSET;
		else
			offsetY = offsetY + VIEW_MODE_CLASS_ADDITIONAL_Y_OFFSET;
		end

		for i, layoutData in ipairs(pageLayoutData) do
			if layoutData == NEW_ROW_OPCODE then
				assert(i ~= 1); -- Never want to start a new row first thing on a page, something is wrong with the page creator
				offsetX = START_OFFSET_X;
				offsetY = offsetY - BUTTON_HEIGHT - BUTTON_PADDING_Y;
			elseif type(layoutData) == "string" then
				-- Header
				numHeadersInUse = numHeadersInUse + 1;
				local header = self:AcquireFrame(self.heirloomHeaderFrames, numHeadersInUse, "FRAME", "HeirloomHeaderTemplate");
				header.text:SetText(layoutData);

				if i > 1 then
					-- Additional headers on the same page should have additional spacing between the sections
					offsetY = offsetY - ADDITIONAL_HEADER_Y_PADDING - BUTTON_HEIGHT - BUTTON_PADDING_Y;
				else
					offsetY = offsetY - FIRST_HEADER_Y_PADDING;
				end
				header:SetPoint("TOP", self.iconsFrame, "TOP", 0, offsetY);

				offsetX = START_OFFSET_X;
				offsetY = offsetY - HEADER_HEIGHT;
			else
				-- Entry
				numEntriesInUse = numEntriesInUse + 1;
				local entry = self:AcquireFrame(self.heirloomEntryFrames, numEntriesInUse, "CHECKBUTTON", "HeirloomSpellButtonTemplate");
				entry.itemID = layoutData;

				if entry:IsVisible() then
					-- If the button was already visible (going to a new page and being reused) we have to update the button immediately instead of deferring the update through the OnShown
					self:UpdateButton(entry);
				end

				if i == 1 then
					-- Continuation of a section from a previous page
					-- Move everything down as if there was a header
					offsetY = offsetY - HEADER_HEIGHT;
				end

				entry:SetPoint("TOPLEFT", self.iconsFrame, "TOPLEFT", offsetX, offsetY);

				offsetX = offsetX + BUTTON_WIDTH + BUTTON_PADDING_X;
			end
		end
	end

	ActivatePooledFrames(self.heirloomEntryFrames, numEntriesInUse);
	ActivatePooledFrames(self.heirloomHeaderFrames, numHeadersInUse);
end


function HeirloomsMixin:FindClosestUpgradeablePage()
	for i = 1, #self.heirloomLayoutData do
		local pageToCheck = ((self.PagingFrame:GetCurrentPage() - 1) + (i - 1)) % #self.heirloomLayoutData + 1;

		local pageLayoutData = self.heirloomLayoutData[pageToCheck];
		if pageLayoutData then
			for _, layoutData in ipairs(pageLayoutData) do
				if layoutData ~= NEW_ROW_OPCODE and type(layoutData) ~= "string" then
					if C_Heirloom.CanHeirloomUpgradeFromPending(layoutData) then
						return pageToCheck;
					end
				end
			end
		end
	end

	return nil;
end

function HeirloomsMixin:RefreshView()
	self.needsRefresh = false;

	self:RebuildLayoutData();

	if self.findClosestUpgradeablePage then
		self.findClosestUpgradeablePage = false;

		-- Try to find an upgradeable heirloom and switch to that page
		local closestUpgradeablePage = self:FindClosestUpgradeablePage();
		if closestUpgradeablePage then
			self.PagingFrame:SetCurrentPage(closestUpgradeablePage);
		else
			--Unable to locate an upgradeable item
			local classFilter, specFilter = C_Heirloom.GetClassAndSpecFilters();
			if classFilter ~= UNSPECIFIED_CLASS_FILTER or specFilter ~= UNSPECIFIED_SPEC_FILTER then
				-- A filter is set, would we be able to find one if we removed filters?
				local oldClassFilter = classFilter;
				local oldSpecFilter = specFilter;

				C_Heirloom.SetClassAndSpecFilters(UNSPECIFIED_CLASS_FILTER, UNSPECIFIED_SPEC_FILTER);

				self.needsDataRebuilt = true;
				self:RebuildLayoutData();

				closestUpgradeablePage = self:FindClosestUpgradeablePage();
				if closestUpgradeablePage then
					-- Found one without filtering, apply this new filter
					self.PagingFrame:SetCurrentPage(closestUpgradeablePage);
					self.ClassDropdown:GenerateMenu();
				else
					-- Still nothing, reset the filter and just stick to the current page
					C_Heirloom.SetClassAndSpecFilters(oldClassFilter, oldSpecFilter);

					self.needsDataRebuilt = true;
					self:RebuildLayoutData();
				end
			end
		end
	end

	self:LayoutCurrentPage();

	self:UpdateProgressBar();
end

function HeirloomsMixin:UpdateButton(button)
	local name, itemEquipLoc, isPvP, itemTexture, upgradeLevel, source, searchFiltered, effectiveLevel, minLevel, maxLevel = C_Heirloom.GetHeirloomInfo(button.itemID);

	button.iconTexture:SetTexture(itemTexture);
	button.iconTextureUncollected:SetTexture(itemTexture);
	button.iconTextureUncollected:SetDesaturated(true);

	button.name:SetText(name);

	local isNew = self.newHeirlooms[button.itemID];
	button.new:SetShown(isNew);
	button.newGlow:SetShown(isNew);

	if self.upgradedHeirlooms[button.itemID] then
		button.upgradeGlowAnim:Play();
		self.upgradedHeirlooms[button.itemID] = nil;
	end

	button.name:ClearAllPoints();
	local nameExtraYOffset = 0;
	if isPvP then
		button.special:SetText(HEIRLOOMS_PVP);
		button.special:Show();

		-- Center the name and special text along the edge of the icon
		nameExtraYOffset = button.special:GetHeight() / 2;
	else
		button.special:Hide();
	end

	button.name:SetPoint("LEFT", button, "RIGHT", 9, 3 + nameExtraYOffset);

	if C_Heirloom.PlayerHasHeirloom(button.itemID) then
		button.iconTexture:Show();
		button.iconTextureUncollected:Hide();
		button.name:SetTextColor(1, 0.82, 0, 1);
		button.name:SetShadowColor(0, 0, 0, 1);
		button.special:SetTextColor(.427, .352, 0, 1);
		button.special:SetShadowColor(0, 0, 0, 1);

		button.slotFrameCollected:Show();
		button.slotFrameUncollected:Hide();
		button.slotFrameUncollectedInnerGlow:Hide();


		if upgradeLevel == C_Heirloom.GetHeirloomMaxUpgradeLevel(button.itemID) then
			button.levelBackground:SetAtlas("collections-levelplate-gold", true);
			button.level:SetFontObject("GameFontBlackSmall");

			button.pendingUpgradeGlow:Hide();
		else
			button.levelBackground:SetAtlas("collections-levelplate-black", true);
			button.level:SetFontObject("GameFontWhiteSmall");

			button.pendingUpgradeGlow:SetShown(C_Heirloom.CanHeirloomUpgradeFromPending(button.itemID));

			self:ConsiderShowingUpgradeTutorial(button);
		end

		button.level:SetText(maxLevel);

		button.levelBackground:Show();
		button.level:Show();
	else
		button.iconTexture:Hide();
		button.iconTextureUncollected:Show();
		button.name:SetTextColor(0.33, 0.27, 0.20, 1);
		button.name:SetShadowColor(0, 0, 0, 0.33);
		button.special:SetTextColor(0.33, 0.27, 0.20, 1);
		button.special:SetShadowColor(0, 0, 0, 0.33);

		button.slotFrameCollected:Hide();
		button.slotFrameUncollected:Show();
		button.slotFrameUncollectedInnerGlow:Show();

		button.levelBackground:Hide();
		button.level:Hide();
		button.pendingUpgradeGlow:Hide();
	end

	CollectionsSpellButton_UpdateCooldown(button);
end

function HeirloomsMixin:ConsiderShowingUpgradeTutorial(button)
	if not GetCVarBitfield("closedInfoFramesAccountWide", LE_FRAME_TUTORIAL_ACCOUNT_HEIRLOOM_JOURNAL_LEVEL) then
		local helpTipInfo = {
			text = HEIRLOOMS_JOURNAL_TUTORIAL_UPGRADE,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFramesAccountWide",
			bitfieldFlag = LE_FRAME_TUTORIAL_ACCOUNT_HEIRLOOM_JOURNAL_LEVEL,
			targetPoint = HelpTip.Point.BottomEdgeRight,
			alignment = HelpTip.Alignment.Left,
			offsetX = -16,
			offsetY = 5,
		};
		HelpTip:Show(self, helpTipInfo, button.levelBackground);
	end
end

function HeirloomsMixin:UpdateProgressBar()
	local maxProgress, currentProgress = self.numPossibleHeirlooms, self.numKnownHeirlooms;
	self.progressBar:SetMinMaxValues(0, maxProgress);
	self.progressBar:SetValue(currentProgress);

	self.progressBar.text:SetFormattedText(HEIRLOOMS_PROGRESS_FORMAT, currentProgress, maxProgress);
end

function HeirloomsMixin:OnPageChanged(userAction)
	PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
	if userAction then
		self:RefreshViewIfVisible();
	end
end

function HeirloomsMixin:SetCollectedHeirloomFilter(checked)
	C_Heirloom.SetCollectedHeirloomFilter(checked);
end

function HeirloomsMixin:SetUncollectedHeirloomFilter(checked)
	C_Heirloom.SetUncollectedHeirloomFilter(checked);
end

function HeirloomsMixin:SetSourceChecked(source, checked)
		C_Heirloom.SetHeirloomSourceFilter(source, checked);
end

function HeirloomsMixin:IsSourceChecked(source)
	return C_Heirloom.GetHeirloomSourceFilter(source);
end

function HeirloomsMixin:SetAllSourcesChecked(checked)
	C_HeirloomInfo.SetAllSourceFilters(checked);
end

function HeirloomsMixin:GetClassFilter()
	local classFilter, specFilter = C_Heirloom.GetClassAndSpecFilters();
	return classFilter;
end

function HeirloomsMixin:GetSpecFilter()
	local classFilter, specFilter = C_Heirloom.GetClassAndSpecFilters();
	return specFilter;
end

function HeirloomsMixin:SetClassAndSpecFilters(newClassFilter, newSpecFilter)
	local classFilter, specFilter = C_Heirloom.GetClassAndSpecFilters();
	if not self.filtersSet or classFilter ~= newClassFilter or specFilter ~= newSpecFilter then
		C_Heirloom.SetClassAndSpecFilters(newClassFilter, newSpecFilter);

		self.PagingFrame:SetCurrentPage(1);
		self.ClassDropdown:GenerateMenu();

		self:FullRefreshIfVisible();
	end

	self.filtersSet = true;
end

function HeirloomsJournalSearchBox_OnTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);
	C_Heirloom.SetSearch(self:GetText());
	HeirloomsJournal:FullRefreshIfVisible();
end