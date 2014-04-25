GARRISON_FOLLOWER_LIST_BUTTON_FULL_XP_WIDTH = 205;
GARRISON_FOLLOWER_MAX_LEVEL = 100;

function GarrisonLandingPage_ToggleFrame()
	if (not GarrisonLandingPage:IsShown()) then
		ShowUIPanel(GarrisonLandingPage);
	else
		HideUIPanel(GarrisonLandingPage);
	end
end

function GarrisonMissionFrame_OnLoad(self)
	
	self.MissionList.listScroll.update = GarrisonLandingPageMissionList_Update;
	HybridScrollFrame_CreateButtons(self.MissionList.listScroll, "GarrisonLandingPageMissionTemplate", 10, -10, nil, nil, nil, -6);
	GarrisonLandingPageMissionList_Update();

end

---------------------------------------------------------------------------------
--- Mission List                                                              ---
---------------------------------------------------------------------------------

function GarrisonLandingPageMissionList_OnShow(self)
	GarrisonLandingPageMissionList_UpdateMissions()
end

function GarrisonLandingPageMissionList_OnHide(self)
	self.missions = nil;
end

function GarrisonLandingPageMissionList_UpdateMissions()
	local self = GarrisonLandingPage.MissionList;
	self.missions = C_Garrison.GetLandingPageMissions();
	GarrisonLandingPageMissionList_Update();
end

function GarrisonLandingPageMissionList_Update()
	local missions = GarrisonLandingPage.MissionList.missions or {};
	local numMissions = #missions;
	local scrollFrame = GarrisonLandingPage.MissionList.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index
		if ( index <= numMissions ) then
			local mission = missions[index];
			button.id = index;
			button.Title:SetText(mission.name);
			button.TimeLeft:SetText(mission.timeLeft);
			button:Show();
		else
			button:Hide();
		end
	end
	
	local totalHeight = numMissions * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

