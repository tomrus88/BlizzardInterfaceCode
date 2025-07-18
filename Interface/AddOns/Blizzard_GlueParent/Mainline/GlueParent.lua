GLUE_SCREENS = {
	["login"] = 		{ frame = "AccountLogin", 			playMusic = true,	playAmbience = true },
	["realmlist"] = 	{ frame = "RealmListUI", 			playMusic = true,	playAmbience = false },
	["charselect"] = 	{ frame = "CharacterSelect",		playMusic = true,	playAmbience = false, onAttemptShow = function() InitializeCharacterScreenData() end },
	["plunderstorm"] = 	{ frame = "PlunderstormLobbyFrame",	playMusic = true,	playAmbience = false, onAttemptShow = function() InitializeCharacterScreenData() end, allowChat = true, },
	["charcreate"] =	{ frame = "CharacterCreateFrame",	playMusic = true,	playAmbience = false, onAttemptShow = function() InitializeCharacterScreenData() end },
	["kioskmodesplash"]={ frame = "KioskModeSplash",		playMusic = true,	playAmbience = false },
};

GLUE_SECONDARY_SCREENS = {
	["cinematics"] =		{ frame = "CinematicsMenu", 				playMusic = true,	playAmbience = false,	fullScreen = false,	showSound = SOUNDKIT.GS_TITLE_OPTIONS },
	["credits"] = 			{ frame = "CreditsFrame", 					playMusic = false,	playAmbience = false,	fullScreen = true,	showSound = SOUNDKIT.GS_TITLE_CREDITS },
	-- Bug 477070 We have some rare race condition crash in the sound engine that happens when the MovieFrame's "showSound" sound plays at the same time the movie audio is starting.
	-- Removing the showSound from the MovieFrame in attempt to avoid the crash, until we can actually find and fix the bug in the sound engine.
	["movie"] = 			{ frame = "MovieFrame", 					playMusic = false,	playAmbience = false,	fullScreen = true },
	["photosensitivity"] =	{ frame = "PhotosensitivityWarningFrame",	playMusic = false,	playAmbience = false,	fullScreen = true },
	["options"] = 			{ frame = "SettingsPanel",					playMusic = true,	playAmbience = false,	fullScreen = false,	showSound = SOUNDKIT.GS_TITLE_OPTIONS, checkFit = true, },
};

ACCOUNT_SUSPENDED_ERROR_CODE = 53;
GENERIC_DISCONNECTED_ERROR_CODE = 319;

local function GlueParent_SetSecondaryScreen(secondaryScreen, contextKey)
	GlueParent.currentSecondaryScreen = secondaryScreen;
	GlueParent.currentSecondaryScreenContextKey = contextKey;
end

local function GetNotchHeight()
    if (C_UI.ShouldUIParentAvoidNotch()) then
		local pixelHeight = select(4, C_UI.GetTopLeftNotchSafeRegion());
		local scale = PixelUtil.GetPixelToUIUnitFactor() / GlueParent:GetEffectiveScale();
		return pixelHeight * scale;
    end

	return 0;
end

local function OnDisplaySizeChanged(self)
	local width = GetScreenWidth();
	local notchHeight = GetNotchHeight();
	local height = GetScreenHeight() - notchHeight;

	local MIN_ASPECT = 5 / 4;
	local MAX_ASPECT = 16 / 9;
	local currentAspect = width / height;

	self:ClearAllPoints();

	if ( currentAspect > MAX_ASPECT ) then
		local maxWidth = height * MAX_ASPECT;
		local barWidth = ( width - maxWidth ) / 2;
		self:SetPoint("TOPLEFT", barWidth, -notchHeight);
		self:SetPoint("BOTTOMRIGHT", -barWidth, 0);
	elseif ( currentAspect < MIN_ASPECT ) then
		local maxHeight = width / MIN_ASPECT;
		local scale = currentAspect / MIN_ASPECT;
		local barHeight = ( height - maxHeight ) / (2 * scale);

		-- Note: we're overriding the default scaling behavior, but this is necessary for this edge case
		self:SetScale(maxHeight/height);

		self:SetPoint("TOPLEFT", 0, -barHeight - notchHeight);
		self:SetPoint("BOTTOMRIGHT", 0, barHeight);
	else
		self:SetPoint("TOPLEFT", 0, -notchHeight);
		self:SetPoint("BOTTOMRIGHT");
	end
end

GlueParentMixin = {};

function GlueParentMixin:OnLoad()
	-- alias GlueParent to UIParent
	UIParent = self; -- luacheck: ignore 111 (setting non-standard global variable)

	self:RegisterEvent("FRAMES_LOADED");
	self:RegisterEvent("LOGIN_STATE_CHANGED");
	self:RegisterEvent("OPEN_STATUS_DIALOG");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("SUBSCRIPTION_CHANGED_KICK_IMMINENT");
	self:RegisterEvent("ACTIVE_GAME_MODE_UPDATED");
	self:RegisterEvent("CONNECT_TO_EVENT_REALM_FAILED");
	-- Events for Global Mouse Down
	self:RegisterEvent("GLOBAL_MOUSE_DOWN");
	self:RegisterEvent("GLOBAL_MOUSE_UP");
	self:RegisterEvent("KIOSK_SESSION_SHUTDOWN");
	self:RegisterEvent("KIOSK_SESSION_EXPIRED");
	self:RegisterEvent("KIOSK_SESSION_EXPIRATION_CHANGED");
	self:RegisterEvent("SCRIPTED_ANIMATIONS_UPDATE");

	self:RegisterEvent("NOTCHED_DISPLAY_MODE_CHANGED");

	self:AddStaticEventMethod(EventRegistry, "GlueParent.SecondaryScreenClosed", GlueParentMixin.OnSecondaryScreenClosed);
	self:AddStaticEventMethod(EventRegistry, "AddonList.FrameHidden", GlueParentMixin.OnAddonListClosed);
	self:AddStaticEventMethod(EventRegistry, "Store.FrameHidden", GlueParentMixin.OnStoreFrameClosed);

	OnDisplaySizeChanged(self);
end

function GlueParentMixin:OnSecondaryScreenClosed(unused_secondaryScreen, contextKey, openingNewScreen)
	if not openingNewScreen then
		if contextKey == GlueMenuFrameUtil.GlueMenuContextKey then
			GlueMenuFrameUtil.ShowMenu();
		elseif contextKey == G_CinematicsMenuContextKey then
			GlueParent_ShowCinematicsScreen(GlueMenuFrameUtil.GlueMenuContextKey);
		end
	end
end

function GlueParentMixin:OnAddonListClosed()
	if GlueParent_GetCurrentScreen() == "charselect" then
		GlueMenuFrameUtil.ShowMenu();
	end
end

function GlueParentMixin:OnStoreFrameClosed(contextKey)
	if (GlueParent_GetCurrentScreen() == "charselect") and (contextKey == GlueMenuFrameUtil.GlueMenuContextKey) then
		GlueMenuFrameUtil.ShowMenu();
	end
end

local function IsGlobalMouseEventHandled(buttonName, event)
	local regions = GetMouseFoci();
	for _, region in ipairs(regions) do
		if region and region.HandlesGlobalMouseEvent and region:HandlesGlobalMouseEvent(buttonName, event) then
			return true;
		end
	end
	return false;
end

function GlueParentMixin:OnEvent(event, ...)
	if ( event == "FRAMES_LOADED" ) then
		LocalizeFrames();
		GlueParent_EnsureValidScreen();
		GlueParent_UpdateDialogs();
		if not GlueParent_CheckPhotosensitivity() then
			GlueParent_CheckCinematic();
		end

		if ( AccountLogin:IsVisible() ) then
			SetExpansionLogo(AccountLogin.UI.GameLogo, GetClientDisplayExpansionLevel());
		end
	elseif ( event == "LOGIN_STATE_CHANGED" ) then
		GlueParent_EnsureValidScreen();
		GlueParent_UpdateDialogs();
	elseif ( event == "OPEN_STATUS_DIALOG" ) then
		local dialog, text = ...;
		StaticPopup_Show(dialog, text);
	elseif ( event == "DISPLAY_SIZE_CHANGED" or event == "NOTCHED_DISPLAY_MODE_CHANGED" ) then
		OnDisplaySizeChanged(self);
	elseif ( event == "UI_SCALE_CHANGED" ) then
		local secondaryScreen = GlueParent_GetSecondaryScreen();
		if ( secondaryScreen ) then
			GlueParent_CheckFitSecondaryScreen(secondaryScreen);
		end
		CharacterSelectServerAlertFrame:UpdateHeight();
	elseif ( event == "SUBSCRIPTION_CHANGED_KICK_IMMINENT" ) then
		if not StoreFrame_IsShown() then
			StaticPopup_Show("SUBSCRIPTION_CHANGED_KICK_WARNING");
		end
	elseif ( event == "ACTIVE_GAME_MODE_UPDATED" ) then
		local gameMode = ...;
		local isPlunderstorm = gameMode == Enum.GameMode.Plunderstorm;
		WOW_PROJECT_ID = isPlunderstorm and WOW_PROJECT_WOWLABS or WOW_PROJECT_MAINLINE;
		local screen = isPlunderstorm and "plunderstorm" or "charselect";
		GlueParent_SetScreen(screen);
		C_Log.LogMessage("From ACTIVE_GAME_MODE_UPDATED");
	elseif ( event == "ERROR_CONNECT_TO_EVENT_REALM_FAILED" ) then
		C_RealmList.ClearRealmList();
		StaticPopup_Show("ERROR_CONNECT_TO_EVENT_REALM_FAILED");
	elseif (event == "GLOBAL_MOUSE_DOWN" or event == "GLOBAL_MOUSE_UP") then
		local buttonID = ...;
		if not IsGlobalMouseEventHandled(buttonID, event) then
			UIDropDownMenu_HandleGlobalMouseEvent(buttonID, event);
		end
	elseif (event == "KIOSK_SESSION_SHUTDOWN" or event == "KIOSK_SESSION_EXPIRED") then
		GlueParent_SetScreen("kioskmodesplash");
	elseif (event == "KIOSK_SESSION_EXPIRATION_CHANGED") then
		StaticPopup_Show("OKAY", KIOSK_SESSION_TIMER_CHANGED);
	elseif(event == "SCRIPTED_ANIMATIONS_UPDATE") then
		ScriptedAnimationEffectsUtil.ReloadDB();
	end
end

-- =============================================================
-- State/Screen functions
-- =============================================================

function GlueParent_IsScreenValid(screen)
	local auroraState, connectedToWoW, wowConnectionState, hasRealmList = C_Login.GetState();
	if ( screen == "plunderstorm" or screen == "charselect" or screen == "charcreate" or screen == "kioskmodesplash" ) then
		return auroraState == LE_AURORA_STATE_NONE and (connectedToWoW or wowConnectionState == LE_WOW_CONNECTION_STATE_CONNECTING) and not hasRealmList;
	elseif ( screen == "realmlist" ) then
		return hasRealmList;
	elseif ( screen == "login" ) then
		return not connectedToWoW and not hasRealmList;
	else
		return false;
	end
end

function GlueParent_GetBestScreen()
	local auroraState, connectedToWoW, wowConnectionState, hasRealmList = C_Login.GetState();
	if ( hasRealmList ) then
		return "realmlist";
	elseif ( connectedToWoW ) then
		local screenName = C_GameRules.GetGameModeGlueScreenName() or "charselect";
		return screenName;
	else
		return "login";
	end
end

local function IsHigherPriorityError(errorID, currentErrorID)
	if currentErrorID and errorID == GENERIC_DISCONNECTED_ERROR_CODE then
		return false;
	end
	return true;
end

local function GlueParent_ShowLastErrorDialog(which, text, data)
	local text2 = nil;
	local insertedFrame = nil;
	local customOnHideScript = C_Login.ClearLastError;
	StaticPopup_Show(which, text, text2, data, insertedFrame, customOnHideScript);
end

local currentlyShowingErrorID = nil;
function GlueParent_UpdateDialogs()
	local auroraState, connectedToWoW, wowConnectionState, hasRealmList, waitingForRealmList = C_Login.GetState();
	local errorID;
	if ( auroraState == LE_AURORA_STATE_WAITING_FOR_NETWORK ) then
		StaticPopup_Show("CANCEL", LOGIN_STATE_WAITFORNETWORK)
	elseif ( auroraState == LE_AURORA_STATE_CONNECTING ) then
		local isQueued, queuePosition, estimatedSeconds = C_Login.GetLogonQueueInfo();
		if ( isQueued ) then
			local queueMessage;
			if ( estimatedSeconds < 60 ) then
				queueMessage = string.format(BNET_LOGIN_QUEUE_TIME_LEFT_SECONDS, queuePosition);
			elseif ( estimatedSeconds > 3600 ) then
				queueMessage = string.format(BNET_LOGIN_QUEUE_TIME_LEFT_UNKNOWN, queuePosition);
			else
				queueMessage = string.format(BNET_LOGIN_QUEUE_TIME_LEFT, queuePosition, estimatedSeconds / 60);
			end

			StaticPopup_Show("CANCEL", queueMessage);
		else
			StaticPopup_Show("CANCEL", LOGIN_STATE_CONNECTING);
		end
	elseif ( auroraState == LE_AURORA_STATE_NONE and C_Login.GetLastError() ) then
		local errorCategory, localizedString, debugString, errorCodeString;
		errorCategory, errorID, localizedString, debugString, errorCodeString = C_Login.GetLastError();

		if (ACCOUNT_SAVE_KICK_ERROR_CODE and AccountSaveFrame and errorCategory == "WOW" and errorID == ACCOUNT_SAVE_KICK_ERROR_CODE) then
			-- If client is kicked due to account save success, allow the Account Save Frame to handle messaging if it's loaded
			return;
		end

		if (IsHigherPriorityError(errorID, currentlyShowingErrorID)) then
			local isHTML = false;
			local hasURL = false;
			local useGenericURL = false;

			--If we didn't get a string from C, look one up in GlueStrings as HTML
			if ( not localizedString ) then
				local tag = string.format("%s_ERROR_%d_HTML", errorCategory, errorID);
				localizedString = _G[tag];
				if ( localizedString ) then
					isHTML = true;
				end
			end

			--If we didn't get a string from C, look one up in GlueStrings
			if ( not localizedString ) then
				local tag = string.format("%s_ERROR_%d", errorCategory, errorID);
				localizedString = _G[tag];

				-- some translations may need the HTML formatting even if we are not using the %s_ERROR_%d_HTML basetag
				if localizedString and strfind(strlower(localizedString), "<html><body><p>") then
					isHTML = true;
				end
			end

			--If we still don't have one, just display a generic error with the ID
			if ( not localizedString ) then
				localizedString = _G[errorCategory.."_ERROR_OTHER"];
				useGenericURL = true;
			end

			--If we got a debug message, stick it on the end of the errorCodeString
			if ( debugString ) then
				errorCodeString = errorCodeString.." [[DBG "..debugString.."]]";
			end

			--See if we want a custom URL
			local urlTag = string.format("%s_ERROR_%d_URL", errorCategory, errorID);
			if ( _G[urlTag] ) then
				hasURL = true;
			end

			if ( errorCategory == "BNET" and errorID == ACCOUNT_SUSPENDED_ERROR_CODE ) then
				local remaining = C_Login.GetAccountSuspensionRemainingTime();
				if (remaining) then
					local days = floor(remaining / 86400);
					local hours = floor((remaining / 3600) - (days * 24));
					local minutes = floor((remaining / 60) - (days * 1440) - (hours * 60));
					localizedString = localizedString:format(" "..ACCOUNT_SUSPENSION_EXPIRATION:format(days, hours, minutes));
				else
					localizedString = localizedString:format("");
				end
			end

			--Append the errorCodeString
			if ( isHTML ) then
				--Pretty hacky...
				local endOfHTML = "</p></body></html>";
				localizedString = string.gsub(localizedString, endOfHTML, string.format(" (%s)%s", errorCodeString, endOfHTML));
			else
				localizedString = string.format("%s (%s)", localizedString, errorCodeString);
			end

			if ( isHTML ) then
				GlueParent_ShowLastErrorDialog("OKAY_HTML", localizedString);
			elseif ( hasURL ) then
				GlueParent_ShowLastErrorDialog("OKAY_WITH_URL", localizedString, urlTag);
			elseif ( useGenericURL ) then
				GlueParent_ShowLastErrorDialog("OKAY_WITH_GENERIC_URL", localizedString);
			else
				GlueParent_ShowLastErrorDialog("OKAY", localizedString);
			end
			currentlyShowingErrorID = errorID;

			EventRegistry:TriggerEvent("GlueParent.OnLoginError");
		end
	elseif (  waitingForRealmList ) then
		StaticPopup_Show("REALM_LIST_IN_PROGRESS");
	elseif ( wowConnectionState == LE_WOW_CONNECTION_STATE_CONNECTING ) then
		StaticPopup_Show("CANCEL", GAME_SERVER_LOGIN);
	elseif ( wowConnectionState == LE_WOW_CONNECTION_STATE_IN_QUEUE ) then
		local waitPosition, waitMinutes, hasFCM = C_Login.GetWaitQueueInfo();

		local queueString;
		if ( waitMinutes == 0 ) then
			queueString = string.format(_G["QUEUE_TIME_LEFT_UNKNOWN"], waitPosition);
		elseif ( waitMinutes == 1 ) then
			queueString = string.format(_G["QUEUE_TIME_LEFT_SECONDS"], waitPosition);
		else
			queueString = string.format(_G["QUEUE_TIME_LEFT"], waitPosition, waitMinutes);
		end

		if ( hasFCM ) then
			queueString = queueString .. "\n\n" .. _G["QUEUE_FCM"];
			StaticPopup_Show("QUEUED_WITH_FCM", queueString);
		else
			StaticPopup_Show("QUEUED_NORMAL", queueString);
		end
	else
		-- JS_TODO: make it so this only cancels state dialogs, like "Connecting"
		StaticPopup_HideAllExcept("RETRIEVING_CHARACTER_LIST");
	end

	if not errorID then
		currentlyShowingErrorID = nil;
	end
end

function GlueParent_EnsureValidScreen()
	local currentScreen = GlueParent.currentScreen;
	if ( not GlueParent_IsScreenValid(currentScreen) ) then
		local bestScreen = GlueParent_GetBestScreen();

		C_Log.LogMessage(string.format("Screen invalid. Changing from=\"%s\" to=\"%s\"", currentScreen or "none", bestScreen));

		GlueParent_SetScreen(bestScreen);
		C_Log.LogMessage("From EnsureValidScreen");
	end
end

local function GlueParent_UpdateScreenSound(screenInfo)
	local displayedExpansionLevel = GetClientDisplayExpansionLevel();
	if ( screenInfo.playMusic ) then
		local musicSoundKit = C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm and SOUNDKIT.PLUNDERSTORM_QUEUE_SCREEN_MUSIC or SafeGetExpansionData(EXPANSION_GLUE_MUSIC, displayedExpansionLevel);
		PlayGlueMusic(musicSoundKit);
	end
	if ( screenInfo.playAmbience ) then
		PlayGlueAmbience(SafeGetExpansionData(EXPANSION_GLUE_AMBIENCE, displayedExpansionLevel), 4.0);
	end	
end

local function GlueParent_ChangeScreen(screenInfo, screenTable, oldScreen)
	C_Log.LogMessage(string.format("Switching to screen=\"%s\" (from \"%s\")", screenInfo.frame, oldScreen or 'none'));

	--Hide all other screens
	for key, info in pairs(screenTable) do
		if ( info ~= screenInfo and _G[info.frame] ) then
			_G[info.frame]:Hide();
		end
	end

	--Start music. Have to do this before showing screen in case its OnShow changes screen.
	GlueParent_UpdateScreenSound(screenInfo);

	--Actually show this screen
	_G[screenInfo.frame]:Show();
end

function GlueParent_GetCurrentScreen()
	return GlueParent.currentScreen;
end

function GlueParent_GetSecondaryScreen()
	return GlueParent.currentSecondaryScreen, GlueParent.currentSecondaryScreenContextKey;
end

function GlueParent_IsSecondaryScreenOpen(screen)
	return GlueParent_GetSecondaryScreen() == screen;
end

function GlueParent_SetScreen(screen)
	local oldScreen = GlueParent.currentScreen or 'none'
	local screenInfo = GLUE_SCREENS[screen];
	if ( screenInfo ) then
		GlueParent.currentScreen = screen;

		--Sometimes, we have to do things we would normally do in OnShow even if the screen doesn't actually
		--get shown (due to a secondary screen being shown)
		if ( screenInfo.onAttemptShow ) then
			screenInfo.onAttemptShow();
		end

		local suppressScreen = false;
		if ( GlueParent.currentSecondaryScreen ) then
			local secondaryInfo = GLUE_SECONDARY_SCREENS[GlueParent.currentSecondaryScreen];
			if ( secondaryInfo and secondaryInfo.fullScreen ) then
				suppressScreen = true;
			end
		end

		--If there's a full-screen secondary screen showing right now, we'll wait to show this one.
		--Once the secondary screen hides, we'll be shown.
		if ( not suppressScreen ) then
			GlueParent_ChangeScreen(screenInfo, GLUE_SCREENS, oldScreen);
		end
	end
end

local function GlueParent_CloseSecondaryScreenInternal(openingNewScreen)
	local secondaryScreen = GlueParent.currentSecondaryScreen;
	if (secondaryScreen) then
		local screenInfo = GLUE_SECONDARY_SCREENS[secondaryScreen];
		local contextKey = GlueParent.currentSecondaryScreenContextKey;
		GlueParent_SetSecondaryScreen(nil);

		--The secondary screen may have started music. Start the primary screen's music if so
		local primaryScreen = GlueParent.currentScreen;
		if (primaryScreen and GLUE_SCREENS[primaryScreen]) then
			GlueParent_UpdateScreenSound(GLUE_SCREENS[primaryScreen]);
		end

		_G[screenInfo.frame]:Hide();

		--Show the original screen if we hid it. Have to do this last in case it opens a new secondary screen.
		if (screenInfo.fullScreen) then
			GlueParent.ScreenFrame:Show();
			if (GlueParent.currentScreen) then
				GlueParent_SetScreen(GlueParent.currentScreen);
			end
		end

		EventRegistry:TriggerEvent("GlueParent.SecondaryScreenClosed", secondaryScreen, contextKey, openingNewScreen);
	end
end

function GlueParent_OpenSecondaryScreen(screen, contextKey)
	local oldSecondaryScreen = GlueParent.currentSecondaryScreen or 'none';
	local screenInfo = GLUE_SECONDARY_SCREENS[screen];
	if ( screenInfo ) then
		--Close the last secondary screen
		if ( GlueParent.currentSecondaryScreen ) then
			local openingNewScreen = true;
			GlueParent_CloseSecondaryScreenInternal(openingNewScreen);
		end

		GlueParent_SetSecondaryScreen(screen, contextKey);
		if ( screenInfo.fullScreen ) then
			GlueParent.ScreenFrame:Hide();

			--If it's full-screen, hide the main screen
			if ( GlueParent.currentScreen ) then
				local mainScreenInfo = GLUE_SCREENS[GlueParent.currentScreen];
				if ( mainScreenInfo ) then
					_G[mainScreenInfo.frame]:Hide();
				end
			end
		else
			GlueParent.ScreenFrame:Show();
		end
		if ( screenInfo.showSound ) then
			PlaySound(screenInfo.showSound);
		end
		GlueParent_ChangeScreen(screenInfo, GLUE_SECONDARY_SCREENS, oldSecondaryScreen);
		GlueParent_CheckFitSecondaryScreen(screenInfo);
	end
end

function GlueParent_CheckFitSecondaryScreen(screenInfo)
	if ( screenInfo.checkFit ) then
		local frame = _G[screenInfo.frame];
		local extraSpacing = 10;
		FrameUtil.UpdateScaleForFit(frame, extraSpacing, extraSpacing);
	end
end

function GlueParent_CloseSecondaryScreen()
	local openingNewScreen = false;
	GlueParent_CloseSecondaryScreenInternal(openingNewScreen);
end

local function GetCinematicsIndexRangeForExpansion(expansion)
	local firstEntry, lastEntry;
	for i, movieEntry in ipairs(MOVIE_LIST) do
		if movieEntry.expansion == expansion then
			firstEntry = firstEntry or i;
			lastEntry = i;
			end
		end

	return firstEntry, lastEntry;
end

local function IsCinematicsAutoPlayDisabled(cinematicIndex)
	local movieEntry = MOVIE_LIST[cinematicIndex];
	return movieEntry and movieEntry.disableAutoPlay;
end

function GlueParent_GetCurrentScreenInfo()
	local screen = GlueParent_GetSecondaryScreen();
	local info;
	if screen then
		info = GLUE_SECONDARY_SCREENS[screen];
		if info then
			return info;
		end
	end

	screen = GlueParent_GetCurrentScreen();
	if screen then
		return GLUE_SCREENS[screen];
	end
end

-- playIntroMovie CVar is set to the index of the last cinematic played.
-- So we will play the cinematic at that index + 1 if there is one.
function GlueParent_CheckCinematic()
	if not C_Glue.IsFirstLoadThisSession() then
		return;
	end
	local firstCinematicIndex, lastCinematicIndex = GetCinematicsIndexRangeForExpansion(LE_EXPANSION_LEVEL_CURRENT);
	if not firstCinematicIndex or not lastCinematicIndex then
		return;
	end
	local nextCinematicIndex = (tonumber(GetCVar("playIntroMovie")) or 0) + 1;
	nextCinematicIndex = math.max(nextCinematicIndex, firstCinematicIndex);
	while nextCinematicIndex <= lastCinematicIndex do
		SetCVar("playIntroMovie", nextCinematicIndex);
		if not IsCinematicsAutoPlayDisabled(nextCinematicIndex) then
			MovieFrame.version = C_Login.IsNewPlayer() and 1 or tonumber(GetCVar("playIntroMovie"));
			GlueParent_OpenSecondaryScreen("movie");
			break;
		end
		nextCinematicIndex = nextCinematicIndex + 1;
	end
end

function ToggleFrame(frame)
	frame:SetShown(not frame:IsShown());
end

-- =============================================================
-- Model functions
-- =============================================================

function SetLoginScreenModel(model)
	local expansionLevel = GetClientDisplayExpansionLevel();
	local expansionInfo = GetExpansionDisplayInfo(expansionLevel);

	if expansionInfo then
		local lowResBG = expansionInfo.lowResBackgroundID;
		local highResBG = expansionInfo.highResBackgroundID;

		if lowResBG and highResBG then
			local background = GetLoginScreenBackground(highResBG, lowResBG);
			model:SetModel(background, true);
		end
	end

	model:SetCamera(0);
	model:SetSequence(0);
end

local function ResetLighting(model)
	--model:SetSequence(0);
	model:SetCamera(0);
	model:ClearFog();
	model:SetGlow(0.3);

    model:ResetLights();
end

local function UpdateLighting(model)
	-- TODO: Remove this and CHAR_MODEL_FOG_INFO and bake fog into models as desired.
    local fogData = CHAR_MODEL_FOG_INFO[GetCurrentGlueTag()];
    if fogData then
    	model:SetFogNear(0);
    	model:SetFogFar(fogData.far);
    	model:SetFogColor(fogData.r, fogData.g, fogData.b);
    end
end

local glueScreenTags =
{
	["charselect"] =
	{
		["PANDAREN"] = "PANDARENCHARACTERSELECT",
	},

	["charcreate"] =
	{
		-- Classes
		["DEATHKNIGHT"] = true,
		["DEMONHUNTER"] = true,

		-- Races
		["PANDAREN"] = true,

		-- Factions
		["HORDE"] = true,
		["ALLIANCE"] = true,
		["NEUTRAL"] = true,
	},

	["default"] =
	{
		-- Classes
		["DEATHKNIGHT"] = true,
		["DEMONHUNTER"] = true,

		-- Races
		["HUMAN"] = true,
		["ORC"] = true,
		["TROLL"] = true,
		["DWARF"] = true,
		["GNOME"] = true,
		["TAUREN"] = true,
		["SCOURGE"] = true,
		["NIGHTELF"] = true,
		["DRAENEI"] = true,
		["BLOODELF"] = true,
		["GOBLIN"] = true,
		["WORGEN"] = true,
		["VOIDELF"] = true,
		["LIGHTFORGEDDRAENEI"] = true,
		["NIGHTBORNE"] = true,
		["HIGHMOUNTAINTAUREN"] = true,
		["DARKIRONDWARF"] = true,
		["MAGHARORC"] = true,
		["ZANDALARITROLL"] = true,
		["KULTIRAN"] = true,
		["MECHAGNOME"] = true,
		["VULPERA"] = true,
		["DRACTHYR"] = true,
		["EARTHENDWARF"] = true,
	},
};

local function GetGlueTagFromKey(subTable, key)
	if ( subTable and key ) then
		local value = subTable[key];
		local valueType = type(value);
		if ( valueType == "boolean" ) then
			return key;
		elseif ( valueType == "string" ) then
			return value;
		end
	end
end

local function UpdateGlueTagWithOrdering(subTable, ...)
	for i = 1, select("#", ...) do
		local tag = GetGlueTagFromKey(subTable, select(i, ...));
		if ( tag ) then
			GlueParent.currentTag = tag;
			return true;
		end
	end

	return false;
end

local function UpdateGlueTag()
	local currentScreen = GlueParent_GetCurrentScreen();

	local race, class, faction;

	-- Determine which API to use to get character information
	if currentScreen == "charselect" then
		local characterGuid = GetCharacterGUID(GetCharacterSelection());
		if characterGuid then
			local basicCharacterInfo = GetBasicCharacterInfo(characterGuid);
			class = basicCharacterInfo.classFilename;
			race = select(2, GetCharacterRace(GetCharacterSelection()));
			faction = "";
		end
	elseif currentScreen == "charcreate" then
		local classInfo = C_CharacterCreation.GetSelectedClass();
		if classInfo then
			class = classInfo.fileName;
		end
		local raceID = C_CharacterCreation.GetSelectedRace();
		race = C_CharacterCreation.GetNameForRace(raceID);
		faction = C_CharacterCreation.GetFactionForRace(raceID);
	end

	-- Once valid information is available, determine the current tag
	if race and class and faction then
		race, class, faction = strupper(race), strupper(class), strupper(faction);

		-- Try lookup from current screen (current screen may have fixed bg's)
		if UpdateGlueTagWithOrdering(glueScreenTags[currentScreen], class, race, faction) then
			return;
		end

		-- Try lookup from defaults
		if UpdateGlueTagWithOrdering(glueScreenTags["default"], class, race, faction) then
			return;
		end
	end

	-- Fallback default value for the current glue tag
	GlueParent.currentTag = "CHARACTERSELECT";
end

function GetCurrentGlueTag()
	return GlueParent.currentTag;
end

local function PlayGlueAmbienceFromTag()
	PlayGlueAmbience(GLUE_AMBIENCE_TRACKS[GetCurrentGlueTag()], 4.0);
end

function ResetModel(model)
	UpdateGlueTag();
	PlayGlueAmbienceFromTag();

	ResetLighting(model);
	UpdateLighting(model);
end

-- =============================================================
-- Buttons
-- =============================================================

function GlueParent_ShowOptionsScreen(contextKey)
	GlueParent_OpenSecondaryScreen("options", contextKey);
end

function GlueParent_ShowCinematicsScreen(contextKey)
	local numMovies = GetClientDisplayExpansionLevel() + 1;
	if ( numMovies == 1 ) then
		MovieFrame.version = 1;
		GlueParent_OpenSecondaryScreen("movie", contextKey);
	else
		GlueParent_OpenSecondaryScreen("cinematics", contextKey);
	end
end

function GlueParent_ShowCreditsScreen(contextKey)
	GlueParent_OpenSecondaryScreen("credits", contextKey);
end

-- =============================================================
-- Utils
-- =============================================================

function HideUIPanel(self)
	-- Glue specific implementation of this function, doesn't need to leverage FrameXML data.
	self:Hide();
end

function IsKioskGlueEnabled()
	return Kiosk.IsEnabled() and not Kiosk.IsCompetitiveModeEnabled();
end

function GetDisplayedExpansionLogo(expansionLevel)
	local isTrial = expansionLevel == nil;

	if isTrial then
		return [[Interface\Glues\Common\Glues-WoW-FreeTrial]];
	elseif expansionLevel <= GetMinimumExpansionLevel() then
		local expansionInfo = GetExpansionDisplayInfo(LE_EXPANSION_CLASSIC);
		if expansionInfo then
			return expansionInfo.logo;
		end
	else
		local expansionInfo = GetExpansionDisplayInfo(expansionLevel);
		if expansionInfo then
			return expansionInfo.logo;
		end
	end

	return nil;
end

function SetExpansionLogo(texture, expansionLevel)
	local logo = GetDisplayedExpansionLogo(expansionLevel);
	if logo then
		texture:SetTexture(logo);
		texture:Show();
	else
		texture:Hide();
	end
end

function UpgradeAccount()
	if IsTrialAccount() then
		StoreInterfaceUtil.OpenToSubscriptionProduct();
	else
		if C_StorePublic.DoesGroupHavePurchaseableProducts(WOW_GAMES_CATEGORY_ID) then
			StoreFrame_SetGamesCategory();
			ToggleStoreUI();
		else
			PlaySound(SOUNDKIT.GS_LOGIN_NEW_ACCOUNT);
			LoadURLIndex(2);
		end
	end
end

function MinutesToTime(mins, hideDays)
	local time = "";
	local count = 0;
	local tempTime;
	-- only show days if hideDays is false
	if ( mins > 1440 and not hideDays ) then
		tempTime = floor(mins / 1440);
		time = TIME_UNIT_DELIMITER .. format(DAYS_ABBR, tempTime);
		mins = mod(mins, 1440);
		count = count + 1;
	end
	if ( mins > 60  ) then
		tempTime = floor(mins / 60);
		time = time .. TIME_UNIT_DELIMITER .. format(HOURS_ABBR, tempTime);
		mins = mod(mins, 60);
		count = count + 1;
	end
	if ( count < 2 ) then
		tempTime = mins;
		time = time .. TIME_UNIT_DELIMITER .. format(MINUTES_ABBR, tempTime);
		count = count + 1;
	end
	return time;
end

function CheckSystemRequirements(includeSeenWarnings)
	local configWarnings = C_ConfigurationWarnings.GetConfigurationWarnings(includeSeenWarnings);
	for i, warning in ipairs(configWarnings) do
		local text = C_ConfigurationWarnings.GetConfigurationWarningString(warning);
		if text then
			StaticPopup_Queue("CONFIGURATION_WARNING", text, text2, { configurationWarning = warning });
		end
	end
end

function GetScaledCursorPosition()
	local uiScale = GlueParent:GetEffectiveScale();
	local x, y = GetCursorPosition();
	return x / uiScale, y / uiScale;
end

function GetScaledCursorDelta()
	local uiScale = GlueParent:GetEffectiveScale();
	local x, y = GetCursorDelta();
	return x / uiScale, y / uiScale;
end

function GMError(...)
	if ( IsGMClient() ) then
		error(...);
	end
end

function OnExcessiveErrors()
	-- Glue Implementation, no-op.
end

setprinthandler(function(...)
	C_Log.LogMessage(string.join(" ", tostringall(...)));
end);

SecureMixin = Mixin;
CreateFromSecureMixins = CreateFromMixins;

function AllowChatFramesToShow(chatFrame)
	local info = GlueParent_GetCurrentScreenInfo();
	if chatFrame and info and info.allowChat then
	    return chatFrame.allowAtGlues;
	end
	return false;
end

-- =============================================================
-- Backwards Compatibility
-- =============================================================
function getglobal(var)
	return _G[var];
end

function setglobal(var, val)
	_G[var] = val;
end
