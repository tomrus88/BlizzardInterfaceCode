HOLY_POWER_FULL = 3;
PALADINPOWERBAR_SHOW_LEVEL = 9;

PaladinPowerBarMixin = {}

function PaladinPowerBarMixin:ToggleHolyRune(rune, visible)
	if visible then
		rune.deactivate:Play();
	else
		rune.activate:Play();
	end
end

function PaladinPowerBarMixin:OnUpdate(elapsed)
	self.delayedUpdate = self.delayedUpdate - elapsed;
	if ( self.delayedUpdate <= 0 ) then
		self.delayedUpdate = nil;
		self:SetScript("OnUpdate", nil);
		self:Update();
	end
end

function PaladinPowerBarMixin:Update()
	if ( self.delayedUpdate ) then
		return;
	end
	
	local numHolyPower = UnitPower( PaladinPowerBar:GetParent().unit, Enum.PowerType.HolyPower );
	local maxHolyPower = UnitPowerMax( PaladinPowerBar:GetParent().unit, Enum.PowerType.HolyPower );
	
	-- a little hacky but we want to signify that the bank is being used to replenish holy power
	if ( self.lastPower and self.lastPower > HOLY_POWER_FULL and numHolyPower == self.lastPower - HOLY_POWER_FULL ) then
		for i = 1, HOLY_POWER_FULL do
			self:ToggleHolyRune(self["rune"..i], true);
		end
		self.lastPower = nil;
		self.delayedUpdate = 0.5;
		self:SetScript("OnUpdate", self.OnUpdate);
		return;
	end
	
	for i=1,maxHolyPower do
		local holyRune = self["rune"..i];
		local isShown = holyRune:GetAlpha()> 0 or holyRune.activate:IsPlaying();
		local shouldShow = i <= numHolyPower;
		if isShown ~= shouldShow then 
			self:ToggleHolyRune(holyRune, isShown);
		end
	end

	-- flash the bar if it's full (3 holy power)
	if numHolyPower >= HOLY_POWER_FULL then
		self.glow.pulse.stopPulse = false;
		self.glow.pulse:Play();
	else
		self.glow.pulse.stopPulse = true;
	end
	
	-- check whether to show bank slots
	if ( maxHolyPower ~= self.maxHolyPower ) then
		if ( maxHolyPower > HOLY_POWER_FULL ) then
			self.showBankAnim:Play();
		else
			-- there is no way to lose the bank slots once you have them, but just in case
			self.showBankAnim:Stop();
			self.bankBG:SetAlpha(0);
		end
		self.maxHolyPower = maxHolyPower;
	end
	
	self.lastPower = numHolyPower;
end



function PaladinPowerBarMixin:OnLoad ()
	-- Disable frame if not a paladin
	local _, class = UnitClass("player");	
	if ( class ~= "PALADIN" ) then
		self:Hide();
		return;
	elseif UnitLevel("player") < PALADINPOWERBAR_SHOW_LEVEL then
		self:RegisterEvent("PLAYER_LEVEL_UP");
		self:SetAlpha(0);
	end
	
	self.maxHolyPower = UnitPowerMax("player", Enum.PowerType.HolyPower);
	if ( self.maxHolyPower > HOLY_POWER_FULL ) then
		self.bankBG:SetAlpha(1);
	end

	self:RegisterEvent("UNIT_POWER_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	
	self.glow:SetAlpha(0);
	self.rune1:SetAlpha(0);
	self.rune2:SetAlpha(0);
	self.rune3:SetAlpha(0);
	self.rune4:SetAlpha(0);
	self.rune5:SetAlpha(0);
end



function PaladinPowerBarMixin:OnEvent (event, arg1, arg2)
	if ( (event == "UNIT_POWER_UPDATE") and (arg1 == self:GetParent().unit) ) then
		if ( arg2 == "HOLY_POWER" ) then
			self:Update();
		end
	elseif( event ==  "PLAYER_LEVEL_UP" ) then
		local level = arg1;
		if level >= PALADINPOWERBAR_SHOW_LEVEL then
			self:UnregisterEvent("PLAYER_LEVEL_UP");
			self.showAnim:Play();
			self:Update();
		end
	else
		self:Update();
	end
end