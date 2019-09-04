
-- This is a symbol available for people who need to know the locale (separate from GetLocale())
LOCALE_ruRU = true;
EXTEND_TALENT_FRAME_TALENT_DISPLAY = true;
TRADESKILL_FRAME_EXTEND_REAGENT_NAME_FIELD = true;

function Localize()
	-- Put all locale specific string adjustments here
end

function LocalizeFrames()
	-- Put all locale specific UI adjustments here
	SetEuropeanNumbers(true);

	-- Adjust hit/damage anchor point
	PlayerHitIndicator:ClearAllPoints();
	PlayerHitIndicator:SetPoint("LEFT", "PlayerFrame", "TOPLEFT", 62, -42);

	-- Hide billing help option.  If the number of help options changes this will need to change also.
	CATEGORY_TO_NOT_DISPLAY = 9;
	
	AddonListOkayButton:SetWidth(100);
end
