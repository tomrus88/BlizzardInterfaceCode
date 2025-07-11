
local COMMUNITIES_MEMBER_LIST_EVENTS = {
	"CLUB_MEMBER_ADDED",
	"CLUB_MEMBER_REMOVED",
	"CLUB_MEMBER_UPDATED",
	"CLUB_MEMBERS_UPDATED",
	"CLUB_MEMBER_PRESENCE_UPDATED",
	"CLUB_STREAMS_LOADED",
	"VOICE_CHAT_CHANNEL_ACTIVATED",
	"VOICE_CHAT_CHANNEL_DEACTIVATED",
	"VOICE_CHAT_CHANNEL_JOINED",
	"VOICE_CHAT_CHANNEL_REMOVED",
	"VOICE_CHAT_CHANNEL_MEMBER_ADDED",
	"VOICE_CHAT_CHANNEL_MEMBER_GUID_UPDATED",
	"CLUB_INVITATIONS_RECEIVED_FOR_CLUB",
	"CLUB_MEMBER_ROLE_UPDATED",
	"GUILD_ROSTER_UPDATE",
};

local COMMUNITIES_MEMBER_LIST_ENTRY_EVENTS = {
	"CLUB_MEMBER_ROLE_UPDATED",
	"VOICE_CHAT_CHANNEL_MEMBER_ACTIVE_STATE_CHANGED",
	"GUILD_ROSTER_UPDATE",
};

local clubTypeToUnitPopup = {
	[Enum.ClubType.BattleNet] = "COMMUNITIES_MEMBER",
	[Enum.ClubType.Character] = "COMMUNITIES_WOW_MEMBER",
	[Enum.ClubType.Guild] = "COMMUNITIES_GUILD_MEMBER",
};

COMMUNITY_MEMBER_ROLE_NAMES = {
	[Enum.ClubRoleIdentifier.Owner] = COMMUNITY_MEMBER_ROLE_NAME_OWNER,
	[Enum.ClubRoleIdentifier.Leader] = COMMUNITY_MEMBER_ROLE_NAME_LEADER,
	[Enum.ClubRoleIdentifier.Moderator] = COMMUNITY_MEMBER_ROLE_NAME_MODERATOR,
	[Enum.ClubRoleIdentifier.Member] = COMMUNITY_MEMBER_ROLE_NAME_MEMBER,
};

local BNET_COLUMN_INFO = {
	[1] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NAME,
		width = 145,
		attribute = "name",
	},

	[2] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_RANK,
		width = 85,
		attribute = "role",
	},

	[3] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NOTE,
		width = 0,
		attribute = "memberNote",
	},
};

local CHARACTER_COLUMN_INFO = {
	[1] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_LEVEL,
		width = 40,
		attribute = "level",
	},

	[2] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_CLASS,
		width = 45,
		attribute = "classID",
	},

	[3] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NAME,
		width = 100,
		attribute = "name",
	},

	[4] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_ZONE,
		width = 100,
		attribute = "zone",
	},

	[5] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_RANK,
		width = 85,
		attribute = "role",
	},

	[6] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NOTE,
		width = 0,
		attribute = "memberNote",
	},
};

local GUILD_COLUMN_INFO = {
	[1] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_LEVEL,
		width = 40,
		attribute = "level",
	},

	[2] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_CLASS,
		width = 45,
		attribute = "classID",
	},

	[3] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NAME,
		width = 100,
		attribute = "name",
	},

	[4] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_ZONE,
		width = 100,
		attribute = "zone",
	},

	[5] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_RANK,
		width = 85,
		attribute = "guildRankOrder",
	},

	[6] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NOTE,
		width = 0,
		attribute = "memberNote",
	},
};

local EXTRA_GUILD_COLUMN_ACHIEVEMENT = 1;
local EXTRA_GUILD_COLUMN_PROFESSION = 2;
local EXTRA_GUILD_COLUMN_APPLICANTS = 3;
local EXTRA_GUILD_COLUMN_PENDING = 4;
local EXTRA_GUILD_COLUMN_DUNGEON_SCORE = 5;

local COMMUNITY_APPLICANT_LIST_VALUE = 2; 

local function CanShowFinderDropdownOptions()
	local canGuildInvite = CanGuildInvite() and (C_GuildInfo.IsGuildOfficer() or IsGuildLeader());
	local isClubFinderEnabled = C_ClubFinder.IsEnabled();
	return canGuildInvite and isClubFinderEnabled;
end

local EXTRA_GUILD_COLUMNS = {
	[EXTRA_GUILD_COLUMN_ACHIEVEMENT] = {
		text = GUILD_ROSTER_DROPDOWN_ACHIEVEMENT_POINTS,
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_ACHIEVEMENT,
		attribute = "achievementPoints",
		width = 115,
		CanShow = function()
			return CanShowAchievementUI();
		end,
	};
	[EXTRA_GUILD_COLUMN_PROFESSION] = {
		text = GUILD_ROSTER_DROPDOWN_PROFESSION,
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_PROFESSION,
		attribute = "profession", -- This is a special case since there are 2 separate sets of profession attributes.
		width = 115,
		CanShow = function()
			return C_TradeSkillUI.IsGuildTradeSkillsEnabled();
		end,
	};
	[EXTRA_GUILD_COLUMN_APPLICANTS] = {
		text = CLUB_FINDER_APPLICANTS,
		title = CLUB_FINDER_APPLICANTS,
		attribute = "applicants",
		width = 115,
		CanShow = CanShowFinderDropdownOptions,
	};
	[EXTRA_GUILD_COLUMN_PENDING] = {
		text = CLUB_FINDER_APPLICANT_HISTORY,
		title = CLUB_FINDER_APPLICANT_HISTORY,
		attribute = "pending",
		width = 115,
		CanShow = CanShowFinderDropdownOptions,
	};
	[EXTRA_GUILD_COLUMN_DUNGEON_SCORE] = {
		text = DUNGEON_SCORE,
		title = DUNGEON_SCORE,
		attribute = "dungeonScore",
		width = 115,
		CanShow = function()
			-- TODO: Could use an API of C_MythicPlus once it gets exposed to Classic.
			return ClassicExpansionAtLeast(LE_EXPANSION_LEGION);
		end,
	};

};

CommunitiesMemberListMixin = {};

function CommunitiesMemberListMixin:ResetColumnSort()
	self.activeColumnSortIndex = nil;
	self.reverseActiveColumnSort = nil;
end

function CommunitiesMemberListMixin:SetVoiceChannel(voiceChannel)
	self.linkedVoiceChannel = voiceChannel;
end

function CommunitiesMemberListMixin:GetVoiceChannel(voiceChannel)
	local hideVoiceChannel = self.expandedDisplay;
	return not hideVoiceChannel and self.linkedVoiceChannel or nil;
end

function CommunitiesMemberListMixin:GetVoiceChannelID()
	if self.linkedVoiceChannel then
		return self.linkedVoiceChannel.channelID;
	end

	return nil;
end

function CommunitiesMemberListMixin:UpdateVoiceChannel()
	local clubId = self:GetSelectedClubId();
	local streamId = self:GetSelectedStreamId();
	if clubId and streamId then
		self:SetVoiceChannel(C_VoiceChat.GetChannelForCommunityStream(clubId, streamId));
	else
		self:SetVoiceChannel(nil);
	end
end

function CommunitiesMemberListMixin:UpdateProfessionDisplay()
	if not self.sortedMemberList then
		return;
	end

	-- Clear out the profession lists without removing the additional data.
	local professionLookup = self.professionDisplay;
	for professionId, professionList in pairs(professionLookup) do
		wipe(professionList.memberList);
	end

	for i, member in ipairs(self.sortedMemberList) do
		local firstProfessionID = member.profession1ID
		if firstProfessionID then
			if not professionLookup[firstProfessionID] then
				professionLookup[firstProfessionID] = {};

				local professionList = professionLookup[firstProfessionID];
				professionList.memberList = { member };
				professionList.collapsed = true;
				professionList.professionName = member.profession1Name;
			else
				table.insert(professionLookup[firstProfessionID].memberList, member);
			end
		end

		local secondProfessionID = member.profession2ID
		if secondProfessionID then
			if not professionLookup[secondProfessionID] then
				professionLookup[secondProfessionID] = {};

				local professionList = professionLookup[secondProfessionID];
				professionList.memberList = { member };
				professionList.collapsed = true;
				professionList.professionName = member.profession2Name;
			else
				table.insert(professionLookup[secondProfessionID].memberList, member);
			end
		end
	end

	self:UpdateSortedProfessionList();
end

function CommunitiesMemberListMixin:UpdateSortedProfessionList()
	self.sortedProfessionList = {};
	local sortedProfessionList = self.sortedProfessionList;
	for professionId, professionList in pairs(self.professionDisplay) do
		local professionEntry = {
			professionHeaderId = professionId,
			professionHeaderName = professionList.professionName,
			professionHeaderCollapsed = professionList.collapsed,
		};

		table.insert(sortedProfessionList, professionEntry);

		if not professionList.collapsed then
			for i, member in ipairs(professionList.memberList) do
				table.insert(sortedProfessionList, member);
			end
		end
	end
end

function CommunitiesMemberListMixin:SetProfessionCollapsed(professionId, collapsed)
	self.professionDisplay[professionId].collapsed = collapsed;
	if self:IsDisplayingProfessions() then
		self:UpdateSortedProfessionList();
		self:RefreshListDisplay();
	end
end

function CommunitiesMemberListMixin:IsDisplayingProfessions()
	local clubInfo = self:GetSelectedClubInfo();
	if not clubInfo then
		return false;
	end

	return clubInfo.clubType == Enum.ClubType.Guild and self.expandedDisplay and self.extraGuildColumnIndex == EXTRA_GUILD_COLUMN_PROFESSION;
end

function CommunitiesMemberListMixin:RefreshListDisplay()
	local displayingProfessions = self:IsDisplayingProfessions();
	local dataProvider = CreateDataProvider();

	local memberList = displayingProfessions and self.sortedProfessionList or self.sortedMemberList;
	if memberList and #memberList > 0 then
		local professionId = nil;
		for index, memberInfo in ipairs(memberList) do
			if memberInfo.professionHeaderId then
				professionId = memberInfo.professionHeaderId;
			end
			memberInfo.professionId = professionId;
			dataProvider:Insert({memberInfo=memberInfo});
		end
	end
	
	local invitations = self.invitations;
	local displayInvitations = self.expandedDisplay and not displayingProfessions and #invitations > 0;
	if displayInvitations then
		dataProvider:Insert({invitationHeaderCount=#invitations});

		for index, invitationInfo in ipairs(invitations) do
			dataProvider:Insert({invitationInfo=invitationInfo});
		end
	end

	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
	self.ScrollBox:ForEachFrame(function(button, elementData)
		button:SetExpanded(self.expandedDisplay);
	end);
end

function CommunitiesMemberListMixin:UpdateMemberList()
	local clubId = self:GetSelectedClubId();
	local streamId;

	-- If we are showing the expandedDisplay, leave streamId as nil, so we show the roster of the whole club instead of just the current stream
	if not self.expandedDisplay then
		streamId = self:GetSelectedStreamId();
	end

	self.memberIds = CommunitiesUtil.GetMemberIdsSortedByName(clubId, streamId);
	self.allMemberList = CommunitiesUtil.GetMemberInfo(clubId, self.memberIds);
	self.allMemberInfoLookup = CommunitiesUtil.GetMemberInfoLookup(self.allMemberList);
	self.allMemberList = CommunitiesUtil.SortMemberInfo(clubId, self.allMemberList);
	if not self:ShouldShowOfflinePlayers() then
		self.sortedMemberList = CommunitiesUtil.GetOnlineMembers(self.allMemberList);
		self.sortedMemberLookup = CommunitiesUtil.GetMemberInfoLookup(self.sortedMemberList);
	else
		self.sortedMemberList = self.allMemberList;
		self.sortedMemberLookup = self.allMemberInfoLookup
	end

	if self.activeColumnSortIndex then
		local keepSortDirection = true;
		self:SortByColumnIndex(self.activeColumnSortIndex, keepSortDirection);
	end

	if self:IsDisplayingProfessions() then
		self:UpdateProfessionDisplay();
	end

	self:UpdateMemberCount();
	self:Update();
end

function CommunitiesMemberListMixin:UpdateWatermark()
	local clubInfo = self:GetSelectedClubInfo();
	self.WatermarkFrame:SetShown(clubInfo ~= nil);
	if clubInfo then
		if clubInfo.clubType == Enum.ClubType.Guild then
			SetLargeGuildTabardTextures("player", self.WatermarkFrame.Watermark, nil, nil);
			self.WatermarkFrame.Watermark:SetVertexColor(1.0, 1.0, 1.0);
			self.WatermarkFrame.Watermark:SetAlpha(0.15);
			self.WatermarkFrame.Watermark:SetSize(160, 160);
			self.WatermarkFrame.Watermark:SetPoint("BOTTOMLEFT", self.WatermarkFrame, "BOTTOMRIGHT", -95, -10);
		else
			C_Club.SetAvatarTexture(self.WatermarkFrame.Watermark, clubInfo.avatarId, clubInfo.clubType);
			self.WatermarkFrame.Watermark:SetTexCoord(0, 1, 0, 1);
			self.WatermarkFrame.Watermark:SetAlpha(0.1);
			self.WatermarkFrame.Watermark:SetSize(128, 128);
			self.WatermarkFrame.Watermark:SetPoint("BOTTOMLEFT", self.WatermarkFrame, "BOTTOMRIGHT", -84, 3);
		end
	end
end

function CommunitiesMemberListMixin:UpdateMemberCount()
	local numOnlineMembers = 0;
	for i, memberInfo in ipairs(self.allMemberList) do
		if memberInfo.presence == Enum.ClubMemberPresence.Online or
			memberInfo.presence == Enum.ClubMemberPresence.Away or
			memberInfo.presence == Enum.ClubMemberPresence.Busy then
			numOnlineMembers = numOnlineMembers + 1;
		end
	end

	self.MemberCount:SetText(COMMUNITIES_MEMBER_LIST_MEMBER_COUNT_FORMAT:format(AbbreviateNumbers(numOnlineMembers), AbbreviateNumbers(#self.allMemberList)));
end

function CommunitiesMemberListMixin:Update()
	self:UpdateVoiceChannel();
	self:RefreshLayout();
	self:RefreshListDisplay();
end

function CommunitiesMemberListMixin:MarkSortDirty()
	self.sortDirty = true;
end

function CommunitiesMemberListMixin:MarkMemberListDirty()
	self.memberListDirty = true;
end

function CommunitiesMemberListMixin:IsSortDirty()
	return self.sortDirty;
end

function CommunitiesMemberListMixin:IsMemberListDirty()
	return self.memberListDirty;
end

function CommunitiesMemberListMixin:ClearSortDirty()
	self.sortDirty = nil;
end

function CommunitiesMemberListMixin:ClearMemberListDirty()
	self.memberListDirty = nil;
end

function CommunitiesMemberListMixin:SortList()
	if self.activeColumnSortIndex then
		local keepSortDirection = true;
		self:SortByColumnIndex(self.activeColumnSortIndex, keepSortDirection);
	else
		CommunitiesUtil.SortMemberInfo(self:GetSelectedClubId(), self.sortedMemberList);
	end

	if self:IsDisplayingProfessions() then
		self:UpdateProfessionDisplay();
	end

	self:RefreshListDisplay();
end

function CommunitiesMemberListMixin:OnLoad()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("CommunitiesMemberListEntryTemplate", function(button, elementData)
		button:Init(elementData, self.expandedDisplay);
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.invitations = {};
	self.professionDisplay = {};
	self.showOfflinePlayers = GetCVarBool("communitiesShowOffline");
	self.ShowOfflineButton:SetChecked(self.showOfflinePlayers);

	self:SetExpandedDisplay(false);
	if( CanShowAchievementUI() ) then
		self:SetGuildColumnIndex(EXTRA_GUILD_COLUMN_ACHIEVEMENT);
	else
		self:SetGuildColumnIndex(nil);
	end
end

function CommunitiesMemberListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_MEMBER_LIST_EVENTS);
	local shouldSetExpandedDisplay = self:GetCommunitiesFrame():GetDisplayMode() == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER;
	self:SetExpandedDisplay(shouldSetExpandedDisplay);

	local selectedClubId = self:GetSelectedClubId();

	self:UpdateMemberList();

	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.StreamSelected, self.OnStreamSelected, self);
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self.OnClubSelected, self);
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.DisplayModeChanged, self.OnCommunitiesDisplayModeChanged, self);
	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.SelectedClubInfoUpdated, self.OnSelectedClubInfoChanged, self);

	if selectedClubId ~= nil and selectedClubId == C_Club.GetGuildClubId() then
		C_GuildInfo.GuildRoster();
		QueryGuildRecipes();
	end
end

function CommunitiesMemberListMixin:OnStreamSelected(streamId)
	self:UpdateMemberList();
end

function CommunitiesMemberListMixin:OnClubSelected(clubId)
	self:ResetColumnSort();

	self:UpdateInvitations();
	self:UpdateMemberList();
	self:UpdateWatermark();

	if clubId then
		C_Club.FocusMembers(clubId);
		local ready = C_Club.AreMembersReady(clubId);
		self.ScrollBox:SetShown(ready);
		self.Spinner:SetShown(not ready);
		self:MarkSortDirty();
	end
end

function CommunitiesMemberListMixin:OnCommunitiesDisplayModeChanged(displayMode)
	local expandedDisplay = displayMode == COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER;
	self:SetExpandedDisplay(expandedDisplay);
end

function CommunitiesMemberListMixin:OnSelectedClubInfoChanged(clubId)
	self:UpdateWatermark();
end

function CommunitiesMemberListMixin:OnUpdate()
	if self:IsMemberListDirty() then
		self:UpdateMemberList();
		self:ClearMemberListDirty();
		self:MarkSortDirty();
	end

	if self:IsSortDirty() then
		if not self:ShouldShowOfflinePlayers() then
			self.sortedMemberList = CommunitiesUtil.GetOnlineMembers(self.allMemberList);
			self.sortedMemberLookup = CommunitiesUtil.GetMemberInfoLookup(self.sortedMemberList);
		end
		self:SortList();
		self:ClearSortDirty();
		self:UpdateMemberCount();
	end
end

function CommunitiesMemberListMixin:UpdateInvitations()
	self.invitations = {};

	local clubId = self:GetSelectedClubId();
	if self:GetCommunitiesFrame():GetPrivilegesForClub(clubId).canGetInvitation then
		C_Club.RequestInvitationsForClub(clubId);
	end
end

function CommunitiesMemberListMixin:OnInvitationsUpdated()
	self.invitations = C_Club.GetInvitationsForClub(self:GetSelectedClubId());
	self:RefreshListDisplay();
end

function CommunitiesMemberListMixin:SetExpandedDisplay(expandedDisplay)
	self.expandedDisplay = expandedDisplay;
	self.MemberCount:SetShown(not expandedDisplay);
	self.WatermarkFrame:SetShown(not expandedDisplay);
	self:ResetColumnSort();
	self:UpdateMemberList();

	if expandedDisplay then
		if self:IsDisplayingProfessions() then
			self:UpdateProfessionDisplay();
		else
			self:UpdateInvitations();
		end
	end

	self:RefreshLayout();
	self:RefreshListDisplay();
	self.ShowOfflineButton:SetShown(expandedDisplay);
end

function CommunitiesMemberListMixin:ShouldShowOfflinePlayers()
	return self.showOfflinePlayers or not self.expandedDisplay;
end

function CommunitiesMemberListMixin:SetShowOfflinePlayers(showOfflinePlayers)
	self.showOfflinePlayers = showOfflinePlayers;
	SetCVar("communitiesShowOffline", showOfflinePlayers and "1" or "0");
	self:UpdateMemberList();
end

function CommunitiesMemberListMixin:RefreshLayout()
	if self.expandedDisplay then
		self:SetPoint("TOPLEFT", self:GetCommunitiesFrame().CommunitiesList, "TOPRIGHT", 26, -60);
	else
		self:SetPoint("TOPLEFT", self:GetCommunitiesFrame(), "TOPRIGHT", -165, -63);
	end

	self.ColumnDisplay:Hide();
	local guildColumnIndex = nil;
	if self.expandedDisplay then
		local clubInfo = self:GetSelectedClubInfo();
		if clubInfo then
			if clubInfo.clubType == Enum.ClubType.Guild then
				guildColumnIndex = self:GetGuildColumnIndex();
				self.columnInfo = GUILD_COLUMN_INFO;
				if (guildColumnIndex) then
					self.ColumnDisplay:LayoutColumns(GUILD_COLUMN_INFO, EXTRA_GUILD_COLUMNS[guildColumnIndex]);
				else
					self.ColumnDisplay:LayoutColumns(GUILD_COLUMN_INFO);
				end
			elseif clubInfo.clubType == Enum.ClubType.Character then
				self.columnInfo = CHARACTER_COLUMN_INFO;
				self.ColumnDisplay:LayoutColumns(CHARACTER_COLUMN_INFO);
			else
				self.columnInfo = BNET_COLUMN_INFO;
				self.ColumnDisplay:LayoutColumns(BNET_COLUMN_INFO);
			end

			self.ColumnDisplay:Show();
		end
	end

	self.ScrollBox:ForEachFrame(function(button, elementData)
		button:SetExpanded(self.expandedDisplay);
		button:SetGuildColumnIndex(guildColumnIndex);
	end);
end

function CommunitiesMemberListMixin:OnEvent(event, ...)
	if event == "CLUB_MEMBERS_UPDATED" then
		local clubId = ...;
		if clubId == self:GetSelectedClubId() then
			self:MarkMemberListDirty();
			local ready = C_Club.AreMembersReady(clubId);
			self.ScrollBox:SetShown(ready);
			self.Spinner:SetShown(not ready);
		end
	elseif event == "CLUB_MEMBER_ADDED" or event == "CLUB_MEMBER_REMOVED" or event == "CLUB_MEMBER_UPDATED" or event == "CLUB_MEMBERS_UPDATED" or event == "CLUB_STREAMS_LOADED" then
		local clubId, memberId = ...;
		if clubId == self:GetSelectedClubId() then
			self:MarkMemberListDirty();

			if event == "CLUB_MEMBER_ADDED" then
				self:RemoveInvitation(memberId);
			end
		end
	elseif event == "VOICE_CHAT_CHANNEL_JOINED" then
		local _, _, channelType, clubId, streamId = ...;
		if channelType == Enum.ChatChannelType.Communities and clubId == self:GetSelectedClubId() and streamId == self:GetSelectedStreamId() then
			self:MarkMemberListDirty();
		end
	elseif event == "VOICE_CHAT_CHANNEL_REMOVED" then
		local voiceChannelID = ...;
		if voiceChannelID == self:GetVoiceChannelID() then
			self:MarkMemberListDirty();
		end
	elseif event == "VOICE_CHAT_CHANNEL_ACTIVATED" or event == "VOICE_CHAT_CHANNEL_DEACTIVATED" then
		local voiceChannelID = ...;
		if voiceChannelID == self:GetVoiceChannelID() then
			self:Update();
		end
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_ADDED" or event == "VOICE_CHAT_CHANNEL_MEMBER_GUID_UPDATED" then
		local _, voiceChannelID = ...;
		if voiceChannelID == self:GetVoiceChannelID() then
			self:Update();
		end
	elseif event == "CLUB_INVITATIONS_RECEIVED_FOR_CLUB" then
		local clubId = ...;
		if self.expandedDisplay and clubId == self:GetSelectedClubId() then
			self:OnInvitationsUpdated();
		end
	elseif event == "CLUB_MEMBER_PRESENCE_UPDATED" then
		local clubId, memberId, presence = ...;
		if clubId == self:GetSelectedClubId() and self.allMemberInfoLookup[memberId] ~= nil then
			self.allMemberInfoLookup[memberId].presence = presence;
			self:MarkSortDirty();
		end
	elseif event == "CLUB_MEMBER_ROLE_UPDATED" then
		local clubId, memberId, roleId = ...;
		if clubId == self:GetSelectedClubId() and self.allMemberInfoLookup[memberId] ~= nil then
			self.allMemberInfoLookup[memberId].role = roleId;
			self:MarkSortDirty();
		end
	elseif event == "GUILD_ROSTER_UPDATE" then
		local canRequestGuildRosterUpdate = ...;
		if canRequestGuildRosterUpdate then
			C_GuildInfo.GuildRoster();
		end
		if C_Club.GetGuildClubId() == self:GetSelectedClubId() then
			self:MarkMemberListDirty();
			self:MarkSortDirty();
		end
	end
end

function CommunitiesMemberListMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_MEMBER_LIST_EVENTS);
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.DisplayModeChanged, self);
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.StreamSelected, self);
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self);
	self:GetCommunitiesFrame():UnregisterCallback(CommunitiesFrameMixin.Event.DisplayModeChanged, self);
end

function CommunitiesMemberListMixin:GetCommunitiesFrame()
	return self:GetParent();
end

function CommunitiesMemberListMixin:RemoveInvitation(memberId)
	for i, invitation in ipairs(self.invitations) do
		if invitation.invitee.memberId == memberId then
			table.remove(self.invitations, i);
			break;
		end
	end

	self:RefreshListDisplay();
end

function CommunitiesMemberListMixin:CancelInvitation(memberId)
	C_Club.RevokeInvitation(self:GetSelectedClubId(), memberId);
	self:RemoveInvitation(memberId);
end

function CommunitiesMemberListMixin:OnClubMemberButtonClicked(entry, button)
	if button == "RightButton" then
		if not entry then
			return;
		end

		local clubInfo = self:GetSelectedClubInfo();
		if not clubInfo then
			return;
		end
		
		local memberInfo = entry:GetMemberInfo();
		if memberInfo and memberInfo.name then
			local clubPrivileges = self:GetCommunitiesFrame():GetPrivilegesForClub(clubInfo.clubId);
			local contextData =
			{
				name = memberInfo.name,
				clubMemberInfo = memberInfo,
				clubInfo = clubInfo,
				clubPrivileges = clubPrivileges,
				clubAssignableRoles = C_Club.GetAssignableRoles(clubInfo.clubId, memberInfo.memberId),
				isSelf = memberInfo.isSelf,
				guid = memberInfo.guid,
				isMobile = memberInfo.presence == Enum.ClubMemberPresence.OnlineMobile,
			};
			
			local which = clubTypeToUnitPopup[clubInfo.clubType];
			UnitPopup_OpenMenu(which, contextData);
		end

		return;
	end

	local clubInfo = self:GetSelectedClubInfo();
	if clubInfo and clubInfo.clubType == Enum.ClubType.Guild then
		local professionId = entry:GetProfessionId();
		if professionId then
			local memberInfo = entry:GetMemberInfo();
			if memberInfo then
				C_GuildInfo.QueryGuildMemberRecipes(memberInfo.guid, professionId);
			end
		else
			local memberInfo = entry:GetMemberInfo();
			if memberInfo then
				CommunitiesFrame:OpenGuildMemberDetailFrame(clubInfo.clubId, memberInfo);
			end
		end
	end
end

function CommunitiesMemberListMixin:GetSelectedClubId()
	return self:GetCommunitiesFrame():GetSelectedClubId();
end

function CommunitiesMemberListMixin:GetSelectedClubInfo()
	return self:GetCommunitiesFrame():GetSelectedClubInfo();
end

function CommunitiesMemberListMixin:GetSelectedStreamId()
	return self:GetCommunitiesFrame():GetSelectedStreamId();
end

function CommunitiesMemberListMixin:SetGuildColumnIndex(extraGuildColumnIndex)
	self.extraGuildColumnIndex = extraGuildColumnIndex;
	if self.expandedDisplay then
		if self:IsDisplayingProfessions() then
			self:UpdateProfessionDisplay();
		end

		self:RefreshLayout();
		self:RefreshListDisplay();
	end
end

function CommunitiesMemberListMixin:GetGuildColumnIndex()
	return self.extraGuildColumnIndex;
end

local function CompareMembersByAttribute(lhsMemberInfo, rhsMemberInfo, attribute)
	local lhsAttribute = lhsMemberInfo[attribute];
	local rhsAttribute = rhsMemberInfo[attribute];
	local attributeType = type(lhsAttribute);
	if lhsAttribute == nil and rhsAttribute == nil then
		return nil;
	elseif lhsAttribute == nil then
		return false;
	elseif rhsAttribute == nil then
		return true;
	elseif attributeType == "string" then
		local compareResult = strcmputf8i(lhsAttribute, rhsAttribute);
		if compareResult == 0 then
			return nil;
		else
			return compareResult < 0;
		end
	elseif attributeType == "number" then
		return lhsAttribute > rhsAttribute;
	end

	return nil;
end

function CommunitiesMemberListMixin:SortByColumnIndex(columnIndex, keepSortDirection)
	local sortAttribute = columnIndex <= #self.columnInfo and self.columnInfo[columnIndex].attribute or nil;
	if columnIndex > #self.columnInfo and self.extraGuildColumnIndex then
		sortAttribute = EXTRA_GUILD_COLUMNS[self.extraGuildColumnIndex].attribute;
	end

	if sortAttribute == nil then
		return;
	end

	if not keepSortDirection or self.reverseActiveColumnSort == nil then
		self.reverseActiveColumnSort = columnIndex ~= self.activeColumnSortIndex and false or not self.reverseActiveColumnSort;
	end
	self.activeColumnSortIndex = columnIndex;

	if sortAttribute == "name" then
		self.sortedMemberList = CommunitiesUtil.SortMembersByList(self.sortedMemberLookup, self.memberIds);
		if self.reverseActiveColumnSort then
			-- Reverse the member list.
			local memberListSize = #self.sortedMemberList;
			for i = 1, memberListSize / 2 do
				local reverseIndex = (memberListSize - i) + 1;
				local reverseEntry = self.sortedMemberList[reverseIndex];
				self.sortedMemberList[reverseIndex] = self.sortedMemberList[i];
				self.sortedMemberList[i] = reverseEntry;
			end
		end

		if self:IsDisplayingProfessions() then
			self:UpdateProfessionDisplay();
		end

		return;
	elseif sortAttribute == "profession" then
		for professionId, professionList in pairs(self.professionDisplay) do
			table.sort(professionList.memberList, function(lhsMemberInfo, rhsMemberInfo)
				local lhsSkill = lhsMemberInfo.profession1ID == professionId and lhsMemberInfo.profession1Rank or lhsMemberInfo.profession2Rank;
				local rhsSkill = rhsMemberInfo.profession1ID == professionId and rhsMemberInfo.profession1Rank or rhsMemberInfo.profession2Rank;
				if self.reverseActiveColumnSort then
					return rhsSkill < lhsSkill;
				else
					return lhsSkill < rhsSkill;
				end
			end);
		end

		self:UpdateSortedProfessionList();

		return;
	elseif sortAttribute == "zone" then
		table.sort(self.sortedMemberList, function(lhsMemberInfo, rhsMemberInfo)
			if self.reverseActiveColumnSort then
				lhsMemberInfo, rhsMemberInfo = rhsMemberInfo, lhsMemberInfo;
			end
			if lhsMemberInfo.lastOnlineYear and rhsMemberInfo.lastOnlineYear then
				if lhsMemberInfo.lastOnlineYear ~= rhsMemberInfo.lastOnlineYear then
					return lhsMemberInfo.lastOnlineYear > rhsMemberInfo.lastOnlineYear;
				elseif lhsMemberInfo.lastOnlineMonth ~= rhsMemberInfo.lastOnlineMonth then
					return lhsMemberInfo.lastOnlineMonth > rhsMemberInfo.lastOnlineMonth;
				elseif lhsMemberInfo.lastOnlineDay ~= rhsMemberInfo.lastOnlineDay then
					return lhsMemberInfo.lastOnlineDay > rhsMemberInfo.lastOnlineDay;
				else
					return lhsMemberInfo.lastOnlineHour > rhsMemberInfo.lastOnlineHour;
				end
			elseif lhsMemberInfo.lastOnlineYear then
				return true;
			elseif rhsMemberInfo.lastOnlineYear then
				return false;
			else
				return CompareMembersByAttribute(lhsMemberInfo, rhsMemberInfo, sortAttribute);
			end
		end);
	elseif sortAttribute == "dungeonScore" then 
		table.sort(self.sortedMemberList, function(lhsMemberInfo, rhsMemberInfo)
			if self.reverseActiveColumnSort then
				lhsMemberInfo, rhsMemberInfo = rhsMemberInfo, lhsMemberInfo;
			end
			-- If the score somehow hasn't been populated yet, we want to treat it like a score of 0. 
			local lhsSortScore = lhsMemberInfo.overallDungeonScore or 0;
			local rhsSortScore = rhsMemberInfo.overallDungeonScore or 0; 
			return lhsSortScore < rhsSortScore;
		end);
		return;
	else
		CommunitiesUtil.SortMemberInfoWithOverride(self:GetSelectedClubId(), self.sortedMemberList, function(lhsMemberInfo, rhsMemberInfo)
			if self.reverseActiveColumnSort then
				return CompareMembersByAttribute(lhsMemberInfo, rhsMemberInfo, sortAttribute);
			else
				return CompareMembersByAttribute(rhsMemberInfo, lhsMemberInfo, sortAttribute);
			end
		end);
	end

	if self:IsDisplayingProfessions() then
		self:UpdateProfessionDisplay();
	end
end

function CommunitiesMemberListColumnDisplay_OnClick(self, columnIndex)
	self:GetParent():SortByColumnIndex(columnIndex);
	self:GetParent():RefreshListDisplay();
end

CommunitiesMemberListEntryMixin = {};

function CommunitiesMemberListEntryMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_MEMBER_LIST_ENTRY_EVENTS);
end

function CommunitiesMemberListEntryMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_MEMBER_LIST_ENTRY_EVENTS);
end

function CommunitiesMemberListEntryMixin:OnEvent(event, ...)
	if event == "CLUB_MEMBER_ROLE_UPDATED" then
		local clubId, memberId, roleId = ...;
		local thisClubId = self:GetMemberList():GetSelectedClubId();
		local thisMemberId = self:GetMemberId();
		if clubId == thisClubId and memberId == thisMemberId then
			self.memberInfo.role = roleId;
			self:UpdateRank();
			self:UpdateNameFrame();
		end
	elseif event == "VOICE_CHAT_CHANNEL_MEMBER_ACTIVE_STATE_CHANGED" then
		local voiceMemberId, voiceChannelId, isActive = ...;
		if voiceChannelId == self:GetVoiceChannelID() and voiceMemberId == self:GetVoiceMemberID() then
			self:SetVoiceActive(isActive);
			self:UpdateVoiceButtons();
			self:UpdateNameFrame();
		end
	elseif event == "GUILD_ROSTER_UPDATE" then
		local clubInfo = self:GetMemberList():GetSelectedClubInfo();
		if clubInfo == nil or clubInfo.clubType ~= Enum.ClubType.Guild then
			return;
		end

		if self.memberInfo == nil then
			return;
		end

		self.memberInfo = C_Club.GetMemberInfo(clubInfo.clubId, self.memberInfo.memberId);
		if self.memberInfo == nil then
			return;
		end

		self:RefreshExpandedColumns();
	end
end

function CommunitiesMemberListEntryMixin:GetMemberList()
	return self:GetParent():GetParent():GetParent();
end

function CommunitiesMemberListEntryMixin:UpdateRank()
	if self.isInvitation then
		self.NameFrame.RankIcon:Hide();
		return;
	end

	local memberInfo = self:GetMemberInfo();
	if memberInfo then
		self.NameFrame.RankIcon:Show();

		if memberInfo.role == Enum.ClubRoleIdentifier.Owner or memberInfo.role == Enum.ClubRoleIdentifier.Leader then
			self.NameFrame.RankIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
		elseif memberInfo.role == Enum.ClubRoleIdentifier.Moderator then
			self.NameFrame.RankIcon:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon");
		else
			self.NameFrame.RankIcon:Hide();
		end
	else
		self.NameFrame.RankIcon:Hide();
	end
end

function CommunitiesMemberListEntryMixin:UpdatePresence()
	self.NameFrame.PresenceIcon:Show();

	local memberInfo = self:GetMemberInfo();
	if memberInfo then
		if memberInfo.classID then
			local classInfo = C_CreatureInfo.GetClassInfo(memberInfo.classID);
			local color = (classInfo and RAID_CLASS_COLORS[classInfo.classFile]) or NORMAL_FONT_COLOR;
			self.NameFrame.Name:SetTextColor(color.r, color.g, color.b);
		else
			self.NameFrame.Name:SetTextColor(BATTLENET_FONT_COLOR:GetRGB());
		end

		self.Level:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self.Zone:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self.Rank:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self.Note:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self.GuildInfo:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());

		self.NameFrame.PresenceIcon:SetPoint("LEFT", 0, 0);
		if memberInfo.presence == Enum.ClubMemberPresence.Away then
			self.NameFrame.PresenceIcon:SetTexture(FRIENDS_TEXTURE_AFK);
		elseif memberInfo.presence == Enum.ClubMemberPresence.Busy then
			self.NameFrame.PresenceIcon:SetTexture(FRIENDS_TEXTURE_DND);
		elseif memberInfo.presence == Enum.ClubMemberPresence.OnlineMobile then
			self.NameFrame.PresenceIcon:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ArmoryChat");
			self.NameFrame.PresenceIcon:SetPoint("LEFT", -2, 0);
		else
			self.NameFrame.PresenceIcon:Hide();
			if memberInfo.presence == Enum.ClubMemberPresence.Offline then
				self.NameFrame.Name:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
				self.Level:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
				self.Zone:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
				self.Rank:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
				self.Note:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
				self.GuildInfo:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
			end
		end
	else
		self.NameFrame.PresenceIcon:Hide();
		self.NameFrame.Name:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	end
end

function CommunitiesMemberListEntryMixin:SetHeader(headerText)
	self:SetMember(nil);
	self.NameFrame.Name:SetText(headerText);
end

function CommunitiesMemberListEntryMixin:SetProfessionId(professionId)
	self.professionId = professionId;
end

function CommunitiesMemberListEntryMixin:GetProfessionId()
	return self.professionId;
end

function CommunitiesMemberListEntryMixin:SetProfessionHeader(professionId, professionName, isCollapsed)
	self:SetMember(nil, nil, professionId);

	local professionHeader = self.ProfessionHeader;
	professionHeader.AllRecipes:SetShown(CanViewGuildRecipes(professionId));
	professionHeader.Icon:SetTexture(C_TradeSkillUI.GetTradeSkillTexture(professionId));
	professionHeader.Name:SetText(C_TradeSkillUI.GetTradeSkillDisplayName(professionId));
	self:SetCollapsed(isCollapsed);
	professionHeader:Show();
end

function CommunitiesMemberListEntryMixin:OnProfessionHeaderClicked()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:SetCollapsed(not self.isCollapsed);
	self:GetMemberList():SetProfessionCollapsed(self:GetProfessionId(), self.isCollapsed);
end

function CommunitiesMemberListEntryMixin:SetCollapsed(collapsed)
	self.isCollapsed = collapsed;
	self.ProfessionHeader.CollapsedIcon:SetShown(collapsed);
	self.ProfessionHeader.ExpandedIcon:SetShown(not collapsed);
end

function CommunitiesMemberListEntryMixin:SetMember(memberInfo, isInvitation, professionId)
	self.isInvitation = isInvitation;

	self:SetProfessionId(professionId);
	self.ProfessionHeader:Hide();

	if memberInfo then
		self.memberInfo = memberInfo;
		self:SetMemberPlayerLocationFromGuid(memberInfo.guid);
		local name = memberInfo.name;
		if name and memberInfo.timerunningSeasonID then
			name = TimerunningUtil.AddTinyIcon(name);
		end
		self.NameFrame.Name:SetText(name or "");
	else
		self.memberInfo = nil;
		self:SetMemberPlayerLocationFromGuid(nil);
		self.NameFrame.Name:SetText(nil);
	end

	self:UpdateRank();
	self:UpdatePresence();
	self:RefreshExpandedColumns();

	self.CancelInvitationButton:SetShown(isInvitation);
	self:UpdateVoiceMemberInfo(self:GetMemberList():GetVoiceChannelID());
	self:UpdateVoiceButtons();
	self:UpdateNameFrame();
end

function CommunitiesMemberListEntryMixin:Init(elementData, expanded)
	self:SetExpanded(expanded);
	if elementData.invitationHeaderCount then
		self:SetHeader(COMMUNITIES_MEMBER_LIST_PENDING_INVITE_HEADER:format(elementData.invitationHeaderCount));
	elseif elementData.memberInfo then
		local memberInfo = elementData.memberInfo;
		if memberInfo.professionHeaderId then
			self:SetProfessionHeader(memberInfo.professionHeaderId, memberInfo.professionHeaderName, memberInfo.professionHeaderCollapsed);
		else
			self:SetMember(memberInfo, false, memberInfo.professionId);
		end
	elseif elementData.invitationInfo then
		local invitationInfo = elementData.invitationInfo;
		self:SetMember(invitationInfo.invitee, true);
	end
end

function CommunitiesMemberListEntryMixin:UpdateVoiceMemberInfo(voiceChannelID)
	self.voiceChannelID = voiceChannelID;

	if voiceChannelID and self.memberInfo and self.memberInfo.guid then
		self.voiceMemberID = C_VoiceChat.GetMemberID(voiceChannelID, self.memberInfo.guid);
		self.voiceMemberInfo = self.voiceMemberID and C_VoiceChat.GetMemberInfo(self.voiceMemberID, voiceChannelID);
		if self.voiceMemberInfo then
			self:SetVoiceActive(self.voiceMemberInfo.isActive);
		else
			self:SetVoiceActive(false);
		end
	else
		self.voiceMemberID = nil;
		self.voiceMemberInfo = nil;
		self:SetVoiceActive(false);
	end
end

function CommunitiesMemberListEntryMixin:UpdateVoiceButtons()
	self.SelfDeafenButton:UpdateVisibleState();
	self.SelfMuteButton:UpdateVisibleState();
	self.MemberMuteButton:UpdateVisibleState();

	self:UpdateVoiceActivityNotification();
end

function CommunitiesMemberListEntryMixin:GetMemberInfo()
	return self.memberInfo;
end

function CommunitiesMemberListEntryMixin:GetMemberId()
	return self.memberInfo and self.memberInfo.memberId or nil;
end

function CommunitiesMemberListEntryMixin:GetFaction()
	return  self.memberInfo and self.memberInfo.faction or nil;
end 

function CommunitiesMemberListEntryMixin:OnEnter()
	if self.expanded then
		if not self.NameFrame.Name:IsTruncated() and not self.Rank:IsTruncated() and not self.Note:IsTruncated() and not self.Zone:IsTruncated() then
			return;
		end
	end

	local memberInfo = self:GetMemberInfo();
	if memberInfo then
		GameTooltip:SetOwner(self);

		local name = memberInfo.name;
		if name and memberInfo.timerunningSeasonID then
			name = TimerunningUtil.AddSmallIcon(name);
		end
		GameTooltip:AddLine(name);

		local clubInfo = self:GetMemberList():GetSelectedClubInfo();
		if not clubInfo or clubInfo.clubType == Enum.ClubType.Guild then
			GameTooltip:AddLine(memberInfo.guildRank or "");
		else
			local memberRoleId = memberInfo.role;
			if memberRoleId then
				GameTooltip:AddLine(COMMUNITY_MEMBER_ROLE_NAMES[memberRoleId], HIGHLIGHT_FONT_COLOR:GetRGB());
			end
		end

		if memberInfo.level and memberInfo.race and memberInfo.classID then
			local raceInfo = C_CreatureInfo.GetRaceInfo(memberInfo.race);
			local classInfo = C_CreatureInfo.GetClassInfo(memberInfo.classID);
			if raceInfo and classInfo then
				GameTooltip:AddLine(COMMUNITY_MEMBER_CHARACTER_INFO_FORMAT:format(memberInfo.level, raceInfo.raceName, classInfo.className), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
			end
		end

		if memberInfo.presence == Enum.ClubMemberPresence.OnlineMobile then
			GameTooltip:AddLine(COMMUNITIES_PRESENCE_MOBILE_CHAT, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
		elseif memberInfo.zone then
			GameTooltip:AddLine(memberInfo.zone, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
		end

		if memberInfo.memberNote then
			GameTooltip:AddLine(COMMUNITY_MEMBER_NOTE_FORMAT:format(memberInfo.memberNote), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		end

		if(clubInfo and clubInfo.clubType ~= Enum.ClubType.BattleNet and memberInfo.faction and (UnitFactionGroup("player") ~= PLAYER_FACTION_GROUP[memberInfo.faction])) then 
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip:AddLine(COMMUNITY_MEMBER_LIST_CROSS_FACTION:format(PLAYER_FACTION_BRIGHT_COLORS[memberInfo.faction]:GenerateHexColorMarkup() .. FACTION_LABELS[memberInfo.faction]), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		end

		GameTooltip:Show();
	end
end

function CommunitiesMemberListEntryMixin:OnLeave()
	GameTooltip:Hide();
end

function CommunitiesMemberListEntryMixin:CancelInvitation()
	if self.isInvitation then
		local memberInfo = self:GetMemberInfo();
		if memberInfo then
			self:GetMemberList():CancelInvitation(memberInfo.memberId);
		end
	end
end

function CommunitiesMemberListEntryMixin:OnClick(button)
	if not self.isInvitation then
		self:GetMemberList():OnClubMemberButtonClicked(self, button);
	end
end

function CommunitiesMemberListEntryMixin:RefreshExpandedColumns()
	if not self.expanded then
		self.FactionButton:SetShown(false);
		return;
	end

	local memberInfo = self:GetMemberInfo();
	local hasMemberInfo = memberInfo ~= nil;
	self.Level:SetShown(hasMemberInfo);
	self.Class:SetShown(hasMemberInfo);
	self.Zone:SetShown(hasMemberInfo);
	self.Rank:SetShown(hasMemberInfo);
	self.Note:SetShown(hasMemberInfo);
	self.GuildInfo:SetShown(hasMemberInfo and self.guildColumnIndex ~= nil);
	if not hasMemberInfo then
		return;
	end

	local clubInfo = self:GetMemberList():GetSelectedClubInfo();
	if not clubInfo then
		return;
	end

	local shouldShowFactionIcon = hasMemberInfo and memberInfo.faction and clubInfo.clubType ~= Enum.ClubType.BattleNet and ((UnitFactionGroup("player") ~= PLAYER_FACTION_GROUP[memberInfo.faction]));
	self.FactionButton:SetShown(shouldShowFactionIcon and not self.isInvitation);

	if clubInfo.clubType == Enum.ClubType.BattleNet then
		self.Level:Hide();
		self.Class:Hide();
		self.Zone:Hide();

		self.Rank:SetSize(75, 0);
		self.Rank:ClearAllPoints();
		self.Rank:SetPoint("LEFT", self.NameFrame, "RIGHT", 10, 0);
	else
		if memberInfo.level then
			self.Level:SetText(memberInfo.level);
		else
			self.Level:SetText("");
		end

		self.Class:Hide();
		if memberInfo.classID then
			local classInfo = C_CreatureInfo.GetClassInfo(memberInfo.classID);
			if classInfo then
				self.Class:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classInfo.classFile]));
				self.Class:Show();
			end
		end

		if memberInfo.presence == Enum.ClubMemberPresence.OnlineMobile then
			self.Zone:SetText(COMMUNITIES_PRESENCE_MOBILE_CHAT);
		elseif memberInfo.presence == Enum.ClubMemberPresence.Offline then
			if memberInfo.lastOnlineYear then
				self.Zone:SetText(RecentTimeDate(memberInfo.lastOnlineYear, memberInfo.lastOnlineMonth, memberInfo.lastOnlineDay, memberInfo.lastOnlineHour));
			else
				self.Zone:SetText(COMMUNITIES_PRESENCE_OFFLINE);
			end
		elseif memberInfo.zone then
			self.Zone:SetText(memberInfo.zone);
		else
			self.Zone:SetText("");
		end

		self.Rank:SetSize(75, 0);
		self.Rank:ClearAllPoints();
		self.Rank:SetPoint("LEFT", self.Zone, "RIGHT", 7, 0);
	end

	local memberRoleId = memberInfo.role;
	if clubInfo.clubType == Enum.ClubType.Guild then
		self.Rank:SetText(memberInfo.guildRank or "");
	elseif memberRoleId then
		self.Rank:SetText(COMMUNITY_MEMBER_ROLE_NAMES[memberRoleId]);
	else
		self.Rank:SetText("");
	end

	self.Note:SetText(memberInfo.memberNote or "");

	if self.guildColumnIndex == EXTRA_GUILD_COLUMN_ACHIEVEMENT then
		if ( memberInfo.achievementPoints ) then
			self.GuildInfo:SetText(memberInfo.achievementPoints);
		else
			self.GuildInfo:SetText(NO_ROSTER_ACHIEVEMENT_POINTS);
		end
	elseif self.guildColumnIndex == EXTRA_GUILD_COLUMN_PROFESSION then
		local professionId = self:GetProfessionId();
		self.GuildInfo:SetText(GUILD_VIEW_RECIPES_LINK);
	elseif self.guildColumnIndex == EXTRA_GUILD_COLUMN_DUNGEON_SCORE then
		if(memberInfo.overallDungeonScore) then 
			local color = C_ChallengeMode.GetDungeonScoreRarityColor(memberInfo.overallDungeonScore);
			if(not color) then 
				color = HIGHLIGHT_FONT_COLOR; 
			end 
			self.GuildInfo:SetText(color:WrapTextInColorCode(memberInfo.overallDungeonScore));
		else 
			self.GuildInfo:SetText(NO_ROSTER_ACHIEVEMENT_POINTS); -- Display - if there is no dungeon score. 
		end
	end
end

function CommunitiesMemberListEntryMixin:SetExpanded(expanded)
	self.expanded = expanded;
	self:SetWidth(self:GetMemberList():GetWidth());
	self.Level:SetShown(expanded);
	self.Class:SetShown(expanded);
	self.Zone:SetShown(expanded);
	self.Rank:SetShown(expanded);
	self.Note:SetShown(expanded);
	self:RefreshExpandedColumns();
	self:UpdateNameFrame();
end

function CommunitiesMemberListEntryMixin:SetGuildColumnIndex(guildColumnIndex)
	if self.guildColumnIndex == guildColumnIndex then
		return;
	end

	self.guildColumnIndex = guildColumnIndex;
	self.Note:ClearAllPoints();
	self.Note:SetPoint("LEFT", self.Rank, "RIGHT", 8, 0);
	if self.expanded and guildColumnIndex ~= nil then
		self.GuildInfo:Show();
		self.Note:SetWidth(93);
	else
		self.Note:SetPoint("RIGHT", self, "RIGHT", -4, 0);
		self.GuildInfo:Hide();
	end

	self:RefreshExpandedColumns();
end

function CommunitiesMemberListEntryMixin:UpdateNameFrame()
	local nameFrame = self.NameFrame;

	local frameWidth;
	local iconsWidth = 0;
	local nameOffset = 0;

	if self.expanded then
		-- we are in the roster
		if self.Class:IsShown() then
			frameWidth = 95;
		else
			frameWidth = 140;
		end
	else
		frameWidth = 130;
		if self.SelfMuteButton:IsShown() then
			iconsWidth = 40;
		elseif self.MemberMuteButton:IsShown() then
			iconsWidth = 20;
		end
	end

	local voiceButtonShown = iconsWidth > 0;
	local presenceShown = nameFrame.PresenceIcon:IsShown();

	nameFrame.Name:ClearAllPoints();
	if presenceShown then
		iconsWidth = iconsWidth + 20;

		nameFrame.Name:SetPoint("LEFT", nameFrame.PresenceIcon, "RIGHT");
		nameOffset = nameFrame.PresenceIcon:GetWidth();
	else
		nameFrame.Name:SetPoint("LEFT", nameFrame, "LEFT", 0, 0);
	end

	if nameFrame.RankIcon:IsShown() then
		if voiceButtonShown and presenceShown  then
			iconsWidth = iconsWidth + 15;
		elseif voiceButtonShown or presenceShown then
			iconsWidth = iconsWidth + 20;
		else
			iconsWidth = iconsWidth + 25;
		end
	end

	local nameWidth = frameWidth - iconsWidth;
	nameFrame.Name:SetWidth(nameWidth);

	nameFrame:ClearAllPoints();
	if self.Class:IsShown() then
		nameFrame:SetPoint("LEFT", self.Class, "RIGHT", 18, 0);
	else
		nameFrame:SetPoint("LEFT", 4, 0);
	end
	nameFrame:SetWidth(frameWidth);

	local nameStringWidth = nameFrame.Name:GetStringWidth();
	local rankOffset = (nameFrame.Name:IsTruncated() and nameWidth or nameStringWidth) + nameOffset;
	nameFrame.RankIcon:ClearAllPoints();
	nameFrame.RankIcon:SetPoint("LEFT", nameFrame, "LEFT", rankOffset, 0);
end

function CommunitiesMemberListEntryMixin:IsLocalPlayer()
	return self.memberInfo and self.memberInfo.isSelf or false;
end

function CommunitiesMemberListEntryMixin:GetVoiceMemberID()
	return self.voiceMemberID;
end

function CommunitiesMemberListEntryMixin:GetVoiceChannelID()
	return self.voiceChannelID;
end

function CommunitiesMemberListEntryMixin:GetMemberPlayerLocation()
	return self.playerLocation;
end

function CommunitiesMemberListEntryMixin:SetMemberPlayerLocationFromGuid(memberGuid)
	if memberGuid then
		if not self.playerLocation then
			self.playerLocation = PlayerLocation:CreateFromGUID(memberGuid);
		else
			self.playerLocation:SetGUID(memberGuid);
		end
	else
		self.playerLocation = nil
	end
end

function CommunitiesMemberListEntryMixin:IsChannelActive()
	local voiceChannel = self:GetMemberList():GetVoiceChannel();
	if voiceChannel then
		return voiceChannel.isActive;
	else
		return false;
	end
end

function CommunitiesMemberListEntryMixin:IsChannelPublic()
	return false;	-- community voice channels are never public
end

function CommunitiesMemberListEntryMixin:IsVoiceActive()
	return self.voiceActive;
end

function CommunitiesMemberListEntryMixin:SetVoiceActive(voiceActive)
	self.voiceActive = voiceActive;
end

do
	function CommunitiesMemberListEntry_VoiceActivityNotificationCreatedCallback(self, notification)
		notification:SetParent(self);
		notification:ClearAllPoints();
		notification:SetPoint("RIGHT", self, "RIGHT", -5, 0);
		notification:Show();
	end

	function CommunitiesMemberListEntryMixin:UpdateVoiceActivityNotification()
		if self:IsVoiceActive() and self:IsChannelActive() then
			local guid = self.playerLocation and self.playerLocation:GetGUID();
			if guid ~= self.registeredGuid then
				if self.registeredGuid then
					VoiceActivityManager:UnregisterFrameForVoiceActivityNotifications(self);
				end

				if guid then
					VoiceActivityManager:RegisterFrameForVoiceActivityNotifications(self, guid, self:GetVoiceChannelID(), "VoiceActivityNotificationRosterTemplate", "Button", CommunitiesMemberListEntry_VoiceActivityNotificationCreatedCallback);
				end

				self.registeredGuid = guid;
			end
		else
			if self.registeredGuid then
				VoiceActivityManager:UnregisterFrameForVoiceActivityNotifications(self);
				self.registeredGuid = nil;
			end
		end
	end
end

CommunitiesFrameMemberListDropdownMixin = {};

function CommunitiesFrameMemberListDropdownMixin:OnLoad()
	self:SetSelectionTranslator(function(selection)
		return selection.data.dropdownText;
	end);

	self.listFrameOnShow = function ()
		self:GetCommunitiesFrame():TriggerEvent(CommunitiesFrameMixin.Event.MemberListDropdownShown);
	end
end

function CommunitiesFrameMemberListDropdownMixin:OnHide()
	local communitiesFrame = self:GetCommunitiesFrame();
	communitiesFrame:UnregisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self);
end

function CommunitiesFrameMemberListDropdownMixin:UpdateNotificationFlash(shouldShowFlash)
	self.NotificationOverlay:SetShown(shouldShowFlash);
	self.NotificationOverlay.UnreadNotificationIcon:SetShown(shouldShowFlash);
	self.NotificationOverlay.Flash:SetShown(shouldShowFlash);
end

function CommunitiesFrameMemberListDropdownMixin:GetCommunitiesFrame()
	return self:GetParent();
end

GuildMemberListDropdownMixin = CreateFromMixins(CommunitiesFrameMemberListDropdownMixin);

function GuildMemberListDropdownMixin:OnShow()
	self:ResetGuildColumnIndex();
	self:SetupMenu();

	local communitiesFrame = self:GetCommunitiesFrame();
	if( CanShowAchievementUI() ) then
		communitiesFrame.MemberList:SetGuildColumnIndex(1);
	else
		communitiesFrame.MemberList:SetGuildColumnIndex(nil);
	end

	communitiesFrame:RegisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self.OnCommunitiesClubSelected, self);
end

function GuildMemberListDropdownMixin:ResetGuildColumnIndex()
		local communitiesFrame = self:GetCommunitiesFrame();
	local memberList = communitiesFrame.MemberList;
	memberList:SetGuildColumnIndex(1);

	if(not self.hasApplicants) then 
		self.NotificationOverlay:Hide();
	end 
end 

function GuildMemberListDropdownMixin:SetupMenu()
	DropdownButtonMixin.SetupMenu(self, function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_COMMUNITIES_GUILD_MEMBER_LIST");

		local communitiesFrame = self:GetCommunitiesFrame();
		local memberList = communitiesFrame.MemberList;
		if (self.shouldResetDropdown and (memberList:GetGuildColumnIndex() == EXTRA_GUILD_COLUMN_APPLICANTS) and communitiesFrame:IsShowingApplicantList()) then 
			self:ResetGuildColumnIndex();
		end 

		local function IsChecked(data)
			return data.index == memberList:GetGuildColumnIndex();
		end

		local function SetApplicantListPending(index, isPendingList)
			communitiesFrame.ApplicantList.isPendingList = isPendingList; 
			communitiesFrame.ApplicantList:BuildList();
			communitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_APPLICANT_LIST);
			memberList:SetGuildColumnIndex(index);
		end

		local canGuildInvite = CanGuildInvite() and (C_GuildInfo.IsGuildOfficer() or IsGuildLeader());
		local canModifyApplicants = canGuildInvite and C_ClubFinder.IsEnabled();

		for index, extraColumnInfo in ipairs(EXTRA_GUILD_COLUMNS) do
			if extraColumnInfo:CanShow() then
				local text = extraColumnInfo.text;
				local data = { index = index, dropdownText = text };

				if index == EXTRA_GUILD_COLUMN_APPLICANTS then 
					if canModifyApplicants then
						if self.hasApplicants then 
							text = CreateCommunitiesIconNotificationMarkup(text);
						end
								
						local function SetChecked(data)
							SetApplicantListPending(data.index, false);
						end

						local radio = rootDescription:CreateRadio(text, IsChecked, SetChecked, data);
						radio:SetEnabled(self.hasApplicants);
					end
				elseif index == EXTRA_GUILD_COLUMN_PENDING then
					if canModifyApplicants then
						local function SetChecked(data)
							SetApplicantListPending(data.index, true);
						end

						local radio = rootDescription:CreateRadio(text, IsChecked, SetChecked, data);
						radio:SetEnabled(self.hasPendingApplicants);
					end
				else 
					local function SetChecked(data)
						communitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER);
						memberList:SetGuildColumnIndex(data.index);
					end

					rootDescription:CreateRadio(text, IsChecked, SetChecked, data);
				end
			end
		end

		dropdown:SetShown(rootDescription:HasElements());
	end);
end

function GuildMemberListDropdownMixin:OnCommunitiesClubSelected(clubId)
	if clubId and self:IsVisible() then
		local communitiesFrame = self:GetCommunitiesFrame();
		local clubInfo = communitiesFrame:GetSelectedClubInfo();
		if clubInfo and clubInfo.clubType ~= Enum.ClubType.Guild then
			self:Hide();
		else 
			communitiesFrame.CommunityMemberListDropdown:Hide();
		end
	end
end

function GuildMemberListDropdownMixin:ResetDisplayMode()
	self:ResetGuildColumnIndex();
	self:SetupMenu();
end 

CommunityMemberListDropdownMixin = CreateFromMixins(CommunitiesFrameMemberListDropdownMixin);

function CommunityMemberListDropdownMixin:OnShow()
	self:ResetCurrentIndex();
	self:SetupMenu();

	self:GetCommunitiesFrame():RegisterCallback(CommunitiesFrameMixin.Event.ClubSelected, self.OnCommunitiesClubSelected, self);
end

function CommunityMemberListDropdownMixin:ResetCurrentIndex()
	self.currentIndex = 1;

	if(not self.hasApplicants) then 
		self.NotificationOverlay:Hide();
	end 
end 

function CommunityMemberListDropdownMixin:SetupMenu()
	DropdownButtonMixin.SetupMenu(self, function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_COMMUNITIES_MEMBER_LIST");

	local communitiesFrame = self:GetCommunitiesFrame();
	local memberList = communitiesFrame.MemberList;

		if self.shouldResetDropdown and (self.currentIndex == COMMUNITY_APPLICANT_LIST_VALUE) and communitiesFrame:IsShowingApplicantList() then 
			self:ResetCurrentIndex();
	end 

		local hasFinderPermissions = false; 
	local clubInfo = communitiesFrame:GetSelectedClubInfo();
	if (clubInfo) then 
		local selectedClubId = clubInfo.clubId;
		local myMemberInfo = C_Club.GetMemberInfoForSelf(selectedClubId);
		if (myMemberInfo.role and myMemberInfo.role == Enum.ClubRoleIdentifier.Owner or myMemberInfo.role == Enum.ClubRoleIdentifier.Leader) then 
			hasFinderPermissions = true;
		end 
	end

		local function IsChecked(data)
			return data.index == self.currentIndex;
		end

		do
			local function SetChecked(data)
				self.currentIndex = data.index;
		communitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.ROSTER);
	end
			local text = CLUB_FINDER_COMMUNITY_ROSTER_DROPDOWN;
			local data = {index = 1, dropdownText = text};
			rootDescription:CreateRadio(text, IsChecked, SetChecked, data);
		end

		local function SetApplicantListPending(index, isPendingList)
			self.currentIndex = index;
			communitiesFrame.ApplicantList.isPendingList = isPendingList; 
			communitiesFrame.ApplicantList:BuildList();
			communitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.COMMUNITY_APPLICANT_LIST);
		end

		do
			local text = CLUB_FINDER_APPLICANTS;
			local data = {index = COMMUNITY_APPLICANT_LIST_VALUE, dropdownText = text};

	if (self.hasApplicants and hasFinderPermissions) then 
				text = CreateCommunitiesIconNotificationMarkup(text);
			end

			local function SetChecked(data)
				SetApplicantListPending(data.index, false);
	end

			local radio = rootDescription:CreateRadio(text, IsChecked, SetChecked, data);
			radio:SetEnabled(self.hasApplicants);
	end

		do
			local function SetChecked(data)
				SetApplicantListPending(data.index, true);
			end

			local text = CLUB_FINDER_APPLICANT_HISTORY;
			local data = {index = 3, dropdownText = text};
			local radio = rootDescription:CreateRadio(text, IsChecked, SetChecked, data);
			radio:SetEnabled(self.hasPendingApplicants);
	end

	self:UpdateNotificationFlash(communitiesFrame:HasNewClubApplications(memberList:GetSelectedClubId()) and hasFinderPermissions);
	end);
end

function CommunityMemberListDropdownMixin:OnCommunitiesClubSelected(clubId)
	if clubId and self:IsVisible() then
		local communitiesFrame = self:GetCommunitiesFrame();
		local clubInfo = communitiesFrame:GetSelectedClubInfo();
		if clubInfo and clubInfo.clubType ~= Enum.ClubType.Character then
			self:Hide();
		else 
			communitiesFrame.GuildMemberListDropdown:Hide();
		end
	end
end

function CommunityMemberListDropdownMixin:ResetDisplayMode()
	self:ResetCurrentIndex();
	self:SetupMenu();
end

CommunitiesMemberListFactionButtonMixin = { }; 
function CommunitiesMemberListFactionButtonMixin:OnShow()
	local faction = self:GetParent():GetFaction(); 
	if(not faction) then 
		return; 
	end 

	if(PLAYER_FACTION_GROUP[faction] == "Horde") then 
		self:SetNormalAtlas("communities-icon-faction-horde")
	else 
		self:SetNormalAtlas("communities-icon-faction-alliance");
	end 
end		

function CommunitiesMemberListFactionButtonMixin:OnEnter()
	local faction = self:GetParent():GetFaction(); 
	if(not faction) then 
		return; 
	end 
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, COMMUNITIES_CROSS_FACTION_BUTTON_TOOLTIP_TITLE:format(FACTION_LABELS[faction]));
	GameTooltip_AddNormalLine(GameTooltip, CROSS_FACTION_INVITE_TOOLTIP:format(FACTION_LABELS[faction])); 
	GameTooltip:Show(); 
end