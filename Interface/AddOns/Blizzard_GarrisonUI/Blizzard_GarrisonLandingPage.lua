GARRISON_FOLLOWER_LIST_BUTTON_FULL_XP_WIDTH = 205;
GARRISON_FOLLOWER_MAX_LEVEL = 100;

function GarrisonLandingPage_OnLoad(self)
	
	self.List.listScroll.update = GarrisonLandingPageList_Update;
	HybridScrollFrame_CreateButtons(self.List.listScroll, "GarrisonLandingPageMissionTemplate", 0, 0);
	GarrisonLandingPageList_Update();
end

---------------------------------------------------------------------------------
--- Mission List                                                              ---
---------------------------------------------------------------------------------

function GarrisonLandingPageList_OnShow(self)
	GarrisonLandingPageMinimapButton.MinimapLoopPulseAnim:Stop();
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
			else
				bgName = "GarrLanding-Mission-";
			end
			if (item.isComplete) then
				bgName = bgName.."Complete";
				button.MissionType:SetText(GARRISON_LANDING_BUILDING_COMPLEATE);
				button.MissionType:SetTextColor(YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
			else
				bgName = bgName.."InProgress";
				button.MissionType:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				if (item.isBuilding) then
					button.MissionType:SetText(GARRISON_BUILDING_IN_PROGRESS);
				else
					button.MissionType:SetText(item.type);
				end
			end

			button.MissionTypeIcon:SetShown(not item.isBuilding);
			button.Status:SetShown(not item.isComplete);
			button.TimeLeft:SetShown(not item.isComplete);

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

