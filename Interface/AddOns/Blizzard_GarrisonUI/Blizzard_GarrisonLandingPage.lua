GARRISON_FOLLOWER_LIST_BUTTON_FULL_XP_WIDTH = 205;
GARRISON_FOLLOWER_MAX_LEVEL = 100;

function GarrisonLandingPage_ToggleFrame()
	if (not GarrisonLandingPage:IsShown()) then
		ShowUIPanel(GarrisonLandingPage);
	else
		HideUIPanel(GarrisonLandingPage);
	end
end

function GarrisonLandingPage_OnLoad(self)
	
	self.List.listScroll.update = GarrisonLandingPageList_Update;
	HybridScrollFrame_CreateButtons(self.List.listScroll, "GarrisonLandingPageMissionTemplate", 0, 0);
	GarrisonLandingPageList_Update();
	
	self:RegisterEvent("GARRISON_SHOW_LANDING_PAGE");
	self:RegisterEvent("GARRISON_HIDE_LANDING_PAGE");
end

function GarrisonLandingPage_OnEvent(self, event, ...)
	if (event == "GARRISON_HIDE_LANDING_PAGE") then
		GarrisonLandingPageMinimapButton:Hide();
	elseif (event == "GARRISON_SHOW_LANDING_PAGE") then
		GarrisonLandingPageMinimapButton:Show();
	end
end

---------------------------------------------------------------------------------
--- Mission List                                                              ---
---------------------------------------------------------------------------------

function GarrisonLandingPageList_OnShow(self)
	GarrisonLandingPageList_UpdateItems()
end

function GarrisonLandingPageList_OnHide(self)
	self.missions = nil;
end

function GarrisonLandingPageList_UpdateItems()
	local self = GarrisonLandingPage.List;
	self.items = C_Garrison.GetLandingPageItems();
	GarrisonLandingPageList_Update();
end

function GarrisonLandingPageList_Update()
	local items = GarrisonLandingPage.List.items or {};
	local numItems = #items;
	local scrollFrame = GarrisonLandingPage.List.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index
		if ( index <= numItems ) then
			local item = items[index];
			button.id = index;
			local bgName;
			if (item.isBuilding) then
				bgName = "GarrLanding-Building-";
				button.Status:SetText(GARRISON_LANDING_STATUS_BUILDING);
				button.MissionTypeIcon:Hide();
			else
				bgName = "GarrLanding-Mission-";
				button.MissionTypeIcon:Show();
			end
			if (item.isComplete) then
				bgName = bgName.."Complete";
				button.Status:Hide();
				button.TimeLeft:Hide();
			else
				bgName = bgName.."InProgress";
			end
			button.BG:SetAtlas(bgName, true);
			button.Title:SetText(item.name);
			button.TimeLeft:SetText(item.timeLeft);
			button:Show();
		else
			button:Hide();
		end
	end
	
	local totalHeight = numItems * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

