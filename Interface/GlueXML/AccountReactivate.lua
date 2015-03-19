function AccountReactivate_ReactivateNow()
	PlaySound("gsTitleOptionOK");
	
	-- open web page
	LoadURLIndex(2);
end

function AccountReactivate_Cancel()
	SubscriptionRequestDialog:Hide();
	PlaySound("gsTitleOptionExit");
end

function AccountReactivate_CloseDialogs()
	ReactivateAccountDialog:Hide();
	AccountReactivationInProgressDialog:Hide();
	GoldReactivateConfirmationDialog:Hide();
	TokenReactivateConfirmationDialog:Hide();
	SubscriptionRequestDialog:Hide();
end

function ReactivateAccountDialog_OnLoad(self)
	self:SetHeight( 60 + self.Description:GetHeight() + 64 );
	self:RegisterEvent("TOKEN_BUY_CONFIRM_REQUIRED");
	self:RegisterEvent("TOKEN_REDEEM_CONFIRM_REQUIRED");
	self:RegisterEvent("TOKEN_STATUS_CHANGED");
	self:RegisterEvent("TOKEN_REDEEM_RESULT");
	self:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED");
end

function GetTimeLeftMinuteString(minutes)
	local weeks = 7 * 24 * 60; -- 7 days, 24 hours, 60 minutes
	local days = 24 * 60; -- 24 hours, 60 minutes
	local hours = 60; -- 60 minutes

	local str = "";
	if (math.floor(minutes / weeks) > 0) then
		local wks = math.floor(minutes / weeks);

		minutes = minutes - (wks * weeks);
		str = str .. wks .. " " .. WEEKS_ABBR;
	end

	if (math.floor(minutes / days) > 0) then
		local dys = math.floor(minutes / days);

		minutes = minutes - (dys * days);
		str = str .. " " .. dys .. " " .. DAYS_ABBR;
	end

	if (math.floor(minutes / hours) > 0) then
		local hrs = math.floor(minutes / hours);

		minutes = minutes - (hrs * hours);
		str = str .. " " .. hrs .. " " .. HOURS_ABBR;
	end

	if (minutes > 0) then
		str = str .. " " .. minutes .. " " .. MINUTES_ABBR;
	end

	return str;
end

function ReactivateAccountDialog_OnEvent(self, event, ...)
	if (event == "TOKEN_BUY_CONFIRM_REQUIRED") then
		local dialog = GoldReactivateConfirmationDialog;
		local redeemIndex = select(3, C_WowTokenPublic.GetCommerceSystemStatus());
		
		if (redeemIndex == LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_30_DAYS) then
			local now = time();
			local newTime = now + (30 * 24 * 60 * 60); -- 30 days * 24 hours * 60 minutes * 60 seconds

			local newDate = date("*t", newTime);
			dialog.Expires:SetText(ACCOUNT_REACTIVATE_EXPIRATION:format(newDate.month, newDate.day, newDate.year));
		else
			dialog.Expires:SetText(ACCOUNT_REACTIVATE_EXPIRATION_MINUTES:format(GetTimeLeftMinuteString(2700)));
		end
		dialog.Price:SetText(ACCOUNT_REACTIVATE_GOLD_PRICE:format(GetMoneyString(C_WowTokenPublic.GetGuaranteedPrice(), true)));
		dialog.Remaining:SetText(ACCOUNT_REACTIVATE_GOLD_REMAINING:format(GetMoneyString(C_WowTokenGlue.GetAccountRemainingGoldAmount(), true)));
		dialog.remainingDialogTime = C_WowTokenSecure.GetPriceLockDuration();
		dialog.CautionText:Hide();
		dialog.heightSet = false;
		if (not dialog.ticker) then
			dialog.ticker = C_Timer.NewTicker(1, function()
				if (dialog.remainingDialogTime == 0) then
					dialog.ticker:Cancel();
					dialog.ticker = nil;
					dialog:Hide();
					self:Show();
				elseif (dialog.remainingDialogTime <= 20) then
					dialog.CautionText:SetText(TOKEN_PRICE_LOCK_EXPIRE:format(dialog.remainingDialogTime));
					dialog.CautionText:Show();
					if (not dialog.heightSet) then
						dialog:SetHeight(dialog:GetHeight() + dialog.CautionText:GetHeight() + 20);
						dialog.heightSet = true;
					end
				else
					dialog.CautionText:Hide();
				end
				dialog.remainingDialogTime = dialog.remainingDialogTime - 1;
			end);
		end
		dialog:Show();
		ReactivateAccountDialog:Hide();
	elseif (event == "TOKEN_REDEEM_CONFIRM_REQUIRED") then
		local now = time();
		local newTime = now + (30 * 24 * 60 * 60); -- 30 days * 24 hours * 60 minutes * 60 seconds

		local newDate = date("*t", newTime);
		local dialog = TokenReactivateConfirmationDialog;
		dialog.Expires:SetText(ACCOUNT_REACTIVATE_EXPIRATION:format(newDate.month, newDate.day, newDate.year));
		dialog:Show();
		ReactivateAccountDialog:Hide();
	elseif (event == "TOKEN_STATUS_CHANGED") then
		if (self:IsShown()) then
			ReactivateAccountDialog_Open();
		end
	elseif (event == "TOKEN_REDEEM_RESULT") then
		AccountReactivationInProgressDialog:Hide();
	elseif (event == "TOKEN_MARKET_PRICE_UPDATED") then
		if (ReactivateAccountDialog:IsShown()) then
			ReactivateAccountDialog_Open();
		elseif (SubscriptionRequestDialog:IsShown()) then
			SubscriptionRequestDialog_Open();
		end
	end
end

function ReactivateAccountDialog_Open()
	local self = ReactivateAccountDialog;
	if (AccountReactivationInProgressDialog:IsShown() or not select(20,GetCharacterInfo(GetCharacterSelection())) or 
		SubscriptionRequestDialog:IsShown() or 
		TokenReactivateConfirmationDialog:IsShown() or 
		GoldReactivateConfirmationDialog:IsShown()) then
		self:Hide();
		return;
	end
	AccountReactivate_CloseDialogs();
	local redeemIndex = select(3, C_WowTokenPublic.GetCommerceSystemStatus());
	if (C_WowTokenGlue.GetTokenCount() > 0) then
		self.redeem = true;
		self.Title:SetText(ACCOUNT_REACTIVATE_TOKEN_TITLE);
		if (redeemIndex == LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_30_DAYS) then
			self.Description:SetText(ACCOUNT_REACTIVATE_TOKEN_DESC);
		elseif (redeemIndex == LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_2700_MINUTES) then
			self.Description:SetText(ACCOUNT_REACTIVATE_TOKEN_DESC_MINUTES);
		end
		self.Accept:SetText(ACCOUNT_REACTIVATE_TOKEN_ACCEPT);
		self:Show();
	elseif (C_WowTokenGlue.CanVeteranBuy()) then
		self.redeem = false;
		self.Title:SetText(ACCOUNT_REACTIVATE_GOLD_TITLE);
		if (redeemIndex == LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_30_DAYS) then
			self.Description:SetText(ACCOUNT_REACTIVATE_GOLD_DESC);
			self.Accept:SetText(ACCOUNT_REACTIVATE_ACCEPT:format(GetMoneyString(C_WowTokenPublic.GetCurrentMarketPrice(), true)));
		elseif (redeemIndex == LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_2700_MINUTES) then
			self.Description:SetText(ACCOUNT_REACTIVATE_GOLD_DESC_MINUTES);
			self.Accept:SetText(ACCOUNT_REACTIVATE_ACCEPT_MINUTES:format(GetMoneyString(C_WowTokenPublic.GetCurrentMarketPrice(), true)));
		end
		self.Accept:SetEnabled(C_WowTokenPublic.GetCurrentMarketPrice() > 0);
		self:Show();
	else
		self:Hide();
	end
end

function SubscriptionRequestDialog_Open()
	if (AccountReactivationInProgressDialog:IsShown()) then
		return;
	end
	AccountReactivate_CloseDialogs();
	local self = SubscriptionRequestDialog;
	local redeemIndex = select(3, C_WowTokenPublic.GetCommerceSystemStatus());
	if (C_WowTokenGlue.GetTokenCount() > 0) then
		self.redeem = true;
		self.Reactivate:SetText(ACCOUNT_REACTIVATE_TOKEN_ACCEPT);
		self.ButtonDivider:Show();
		self.Reactivate:Show();
		self.Reactivate:Enable();
		self:SetHeight(self.Text:GetHeight() + 16 + self.ButtonDivider:GetHeight() + self.Accept:GetHeight() + 40 + self.Reactivate:GetHeight());
	elseif (C_WowTokenGlue.CanVeteranBuy()) then	
		self.redeem = false;
		if (redeemIndex == LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_30_DAYS) then
			self.Reactivate:SetText(ACCOUNT_REACTIVATE_ACCEPT:format(GetMoneyString(C_WowTokenPublic.GetCurrentMarketPrice(), true)));
		elseif (redeemIndex == LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_2700_MINUTES) then
			self.Reactivate:SetText(ACCOUNT_REACTIVATE_ACCEPT_MINUTES:format(GetMoneyString(C_WowTokenPublic.GetCurrentMarketPrice(), true)));
		end
		self.ButtonDivider:Show();
		self.Reactivate:Show();
		self.Reactivate:SetEnabled(C_WowTokenPublic.GetCurrentMarketPrice() > 0);
		self:SetHeight(self.Text:GetHeight() + 16 + self.ButtonDivider:GetHeight() + self.Accept:GetHeight() + 40 + self.Reactivate:GetHeight());
	elseif (CAN_BUY_RESULT_FOUND == LE_TOKEN_RESULT_SUCCESS_NO) then
		self.Reactivate.tooltip = ERR_NOT_ENOUGH_GOLD;
		if (redeemIndex == LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_30_DAYS) then
			self.Reactivate:SetText(ACCOUNT_REACTIVATE_ACCEPT:format(GetMoneyString(C_WowTokenPublic.GetCurrentMarketPrice(), true)));
		elseif (redeemIndex == LE_CONSUMABLE_TOKEN_REDEEM_FOR_SUB_AMOUNT_2700_MINUTES) then
			self.Reactivate:SetText(ACCOUNT_REACTIVATE_ACCEPT_MINUTES:format(GetMoneyString(C_WowTokenPublic.GetCurrentMarketPrice(), true)));
		end
		self.ButtonDivider:Show();
		self.Reactivate:Show();
		self.Reactivate:Disable();
		self:SetHeight(self.Text:GetHeight() + 16 + self.ButtonDivider:GetHeight() + self.Accept:GetHeight() + 40 + self.Reactivate:GetHeight());
	else
		self.ButtonDivider:Hide();
		self.Reactivate:Hide();
		self:SetHeight(self.Text:GetHeight() + 16 + self.Accept:GetHeight() + 40);
	end
	
	
	self:Show();
	ReactivateAccount_UpdateMarketPrice();
end

function ReactivateAccountDialog_OnReactivate(self)
	PlaySound("gsTitleOptionOK");
	if (self:GetParent().redeem) then
		C_WowTokenSecure.RedeemToken();
	else
		C_WowTokenPublic.BuyToken();
	end
	self:GetParent():Hide();
end

function ReactivateAccount_UpdateMarketPrice()
	C_WowTokenPublic.UpdateMarketPrice();
	local self = ReactivateAccountDialog;
	if (SubscriptionRequestDialog:IsShown() or ReactivateAccountDialog:IsShown()) then
		local _, pollTimeSeconds = C_WowTokenPublic.GetCommerceSystemStatus();
		if (not self.priceUpdateTimer or pollTimeSeconds ~= self.priceUpdateTimer.pollTimeSeconds) then
			if (self.priceUpdateTimer) then
				self.priceUpdateTimer:Cancel();
			end
			self.priceUpdateTimer = C_Timer.NewTicker(pollTimeSeconds, ReactivateAccount_UpdateMarketPrice);
			self.priceUpdateTimer.pollTimeSeconds = pollTimeSeconds;
		end
	else
		if (self.priceUpdateTimer) then
			self.priceUpdateTimer:Cancel();
			self.priceUpdateTimer = nil;
		end
	end
end
