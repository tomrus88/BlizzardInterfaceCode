RUSSIAN_DECLENSION_PATTERNS = 5;

RUSSIAN_DECLENSION_TAB_LIST = {};
RUSSIAN_DECLENSION_TAB_LIST[1] = "DeclensionFrameDeclension1Edit";
RUSSIAN_DECLENSION_TAB_LIST[2] = "DeclensionFrameDeclension2Edit";
RUSSIAN_DECLENSION_TAB_LIST[3] = "DeclensionFrameDeclension3Edit";
RUSSIAN_DECLENSION_TAB_LIST[4] = "DeclensionFrameDeclension4Edit";
RUSSIAN_DECLENSION_TAB_LIST[5] = "DeclensionFrameDeclension5Edit";

function DeclensionFrame_OnLoad(self)
	self:RegisterEvent("FORCE_DECLINE_CHARACTER");
	self:RegisterEvent("CHARACTER_DECLINE_RESULT");
	self:RegisterEvent("CHARACTER_DECLINE_IN_PROGRESS");
	self.set = 1;
end

function DeclensionFrame_OnEvent(self, event, ...)
	if ( event == "FORCE_DECLINE_CHARACTER" ) then
		self:Show();
	elseif ( event == "CHARACTER_DECLINE_RESULT" ) then
		local err = ...;
		if ( err ) then
			GlueDialog_Show("DECLINE_FAILED", _G[err]);
		else
			GlueDialog_Hide();
		end
	elseif ( event == "CHARACTER_DECLINE_IN_PROGRESS" ) then
		GlueDialog_Show("OKAY", CHAR_DECLINE_IN_PROGRESS);
	end
end

function DeclensionFrame_Update()
	local declensionButton, exampleButton, declensionBox;
	local declension, example, declension;
	local backdropColor = DEFAULT_TOOLTIP_COLOR;
	
	local name, race, class, level, zone, fileString, sex = GetCharacterInfo(GetCharIDFromIndex(CharacterSelect.selectedIndex));
	DeclensionFrameNominative:SetText(name);

	local count = GetNumDeclensionSets(name, sex);
	local set = DeclensionFrame.set;

	if ( not set ) then
		set = 1;
	end
	
	-- Save the count value so we know our max pages.
	DeclensionFrame.count = count;

	-- Hide the paging tool if there is only one set
	if ( count > 1 ) then
		DeclensionFrameSetPage:SetText(format(DECLENSION_SET, set, count));
		DeclensionFrame:SetHeight(330);
		DeclensionFrameSet:Show();
		if ( set == 1 and set < count ) then
			DeclensionFrameSetNext:Enable();
			DeclensionFrameSetPrev:Disable();
		elseif ( set == count and set ~= 1 ) then
			DeclensionFrameSetNext:Disable();
			DeclensionFrameSetPrev:Enable();
		elseif ( set == count - 1 and set ~= 1 ) then
			DeclensionFrameSetNext:Enable();
			DeclensionFrameSetPrev:Enable();
		end
	else
		DeclensionFrame:SetHeight(310);
		DeclensionFrameSet:Hide();
	end

	local names;
	if ( DeclensionFrame.names ) then
		names = DeclensionFrame.names;
		DeclensionFrame.names = nil;
	else
		names = { DeclineName(name, sex, set) };
	end

	for i=1, RUSSIAN_DECLENSION_PATTERNS do
		declensionButton = getglobal("DeclensionFrameDeclension"..i.."Type");
		exampleButton = getglobal("DeclensionFrameDeclension"..i.."Example");
		declensionBox = getglobal("DeclensionFrameDeclension"..i.."Edit");
		declensionBox:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3]);
		declensionBox:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);
		declensionBox:SetText(names[i]);
		declensionButton:SetText(getglobal("RUSSIAN_DECLENSION_"..i));
		exampleButton:SetText(format(getglobal("RUSSIAN_DECLENSION_EXAMPLE_"..i), names[i]));
	end
end

function DeclensionFrame_OnOkay()
	local valid;
	local names = {};
	for i=1, RUSSIAN_DECLENSION_PATTERNS do
		names[i] = getglobal("DeclensionFrameDeclension"..i.."Edit"):GetText();
		if ( names[i] ) then
			valid = 1;
		else
			valid = nil;
		end
	end
	if ( valid ) then
		DeclensionFrame:Hide();
		DeclineCharacter(GetCharIDFromIndex(CharacterSelect.selectedIndex), names[1], names[2], names[3], names[4], names[5]);
	end
end

function DeclensionFrame_OnCancel()
	DeclensionFrame.set = 1;
	DeclensionFrame:Hide();
end

function DeclensionFrame_Next()
	local set = DeclensionFrame.set;
	local count = DeclensionFrame.count;
	if ( not set ) then
		set = 1;
	end

	set = set + 1;
	DeclensionFrame.set = set;
	DeclensionFrame_Update();
end

function DeclensionFrame_Prev()
	local set = DeclensionFrame.set;
	local count = DeclensionFrame.count;
	if ( not set ) then
		set = 1;
	end
	
	set = set - 1;
	DeclensionFrame.set = set;
	DeclensionFrame_Update();
end
