local tooltip = GetAppropriateTooltip()
---------------------------------------------------------------------------------------------------
function PTR_IssueReporter.AttachEmptyFunctionComponent(frame, func)
    local emptyComponent = {
        FrameType = "Empty",
    }
    
    function emptyComponent:GetReportString()
        return func()
    end
    
    table.insert(frame.FrameComponents, emptyComponent) 
end
---------------------------------------------------------------------------------------------------
function PTR_IssueReporter.RegisterUIPanelTabEvent(eventString, index, offsetButton)
    
    if not (PTR_IssueReporter.RegisteredUIPanelButtons) then
        PTR_IssueReporter.RegisteredUIPanelButtons = {}
    end
    
    if not (PTR_IssueReporter.RegisteredUIPanelButtons) then
        PTR_IssueReporter.RegisteredUIPanelRegisteredIndexes = {}
    end
    
    if not (PTR_IssueReporter.RegisteredUIPanelButtons[eventString]) then
        PTR_IssueReporter.RegisteredUIPanelButtons[eventString] = {}
    end
    
    if (index) and not (PTR_IssueReporter.RegisteredUIPanelButtons[eventString][index]) then
        PTR_IssueReporter.RegisteredUIPanelButtons[eventString][index] = true
    end
    
    local registerFunction = function(sender, frame, tabIndex, tabText)
        if not (frame) then
            return
        end
        
        local registeredTabFound = false
        
        if not (PTR_IssueReporter.RegisteredUIPanelButtons[frame]) then
            PTR_IssueReporter.RegisteredUIPanelButtons[frame] = CreateFrame("Button", eventString.."BugButton", frame, "UIPanelBugButton")
        end
        
        if ((index) and (index == tabIndex)) or (index == nil) then
            local offset = 40
            if (offsetButton) then
                offset = 70
            end
            
            PTR_IssueReporter.RegisteredUIPanelButtons[frame]:SetScript("OnClick", function()
                PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.UIPanelButtonClicked, PTR_IssueReporter.GetUIPanelEventString(eventString, index))
            end)            
            PTR_IssueReporter.RegisteredUIPanelButtons[frame]:SetPoint("TOPLEFT", frame, "TOPLEFT", offset, 20)
            PTR_IssueReporter.RegisteredUIPanelButtons[frame]:Show()
        else
            if (index) and not (PTR_IssueReporter.RegisteredUIPanelButtons[eventString][tabIndex]) then
                -- Hide only if the index given is not a registered index, and the event is expecting one
                PTR_IssueReporter.RegisteredUIPanelButtons[frame]:Hide()
            end
        end
    end
    
    if not (index) then
        index = 0
    end

    EventRegistry:RegisterCallback(eventString, registerFunction, "PTR_IssueReporter" .. index)
end
---------------------------------------------------------------------------------------------------
function PTR_IssueReporter.GetUIPanelEventString(eventString, index)
    local eventName = eventString
    if (index) then
        eventName = eventName .. index
    end
    
    return eventName
end
---------------------------------------------------------------------------------------------------
function PTR_IssueReporter.AttachStandaloneQuestion(frame, question, characterLimit)

    local questionFrame
    characterLimit = characterLimit or 255

    local editboxHeight = (characterLimit / 25 * 14) + 15 -- 25 min number of characters on a line, 14 is line height, 15 is extra pad to allow for the character counter
    local headerHeight = 20

    if not (PTR_IssueReporter.Data.UnusedFrameComponents.StandaloneQuestion) then
        PTR_IssueReporter.Data.UnusedFrameComponents.StandaloneQuestion = {}
    end

    local numberOfUnusedFrames = #PTR_IssueReporter.Data.UnusedFrameComponents.StandaloneQuestion

    if  numberOfUnusedFrames > 0 then -- Check if there is a frame we should reuse
        questionFrame = PTR_IssueReporter.Data.UnusedFrameComponents.StandaloneQuestion[numberOfUnusedFrames]
        PTR_IssueReporter.Data.UnusedFrameComponents.StandaloneQuestion[numberOfUnusedFrames] = nil
        numberOfUnusedFrames = #PTR_IssueReporter.Data.UnusedFrameComponents.StandaloneQuestion
    else -- Create one
        questionFrame = CreateFrame("Frame", nil, frame)
        questionFrame:SetHeight(headerHeight)
        questionFrame.FrameType = "StandaloneQuestion"
        questionFrame.text = questionFrame:CreateFontString("CheckListText", "OVERLAY", PTR_IssueReporter.Assets.FontString)
        --questionFrame.text:SetWidth(questionFrame:GetWidth())
        --questionFrame.text:SetHeight(questionFrame:GetHeight())
        questionFrame.text:SetPoint("TOP", questionFrame, "TOP", 0, 0)        
        questionFrame.text:SetSize(questionFrame:GetWidth(), questionFrame:GetHeight())
        questionFrame.text:SetJustifyV("MIDDLE")
        questionFrame.text:SetJustifyH("CENTER")

        PTR_IssueReporter.AddBorder(questionFrame)
        PTR_IssueReporter.AddBackground(questionFrame, PTR_IssueReporter.Assets.BackgroundTexture)
        
        questionFrame.EditBoxBackground = CreateFrame("Frame", nil, questionFrame)  
        questionFrame.EditBoxBackground:SetPoint("TOP", questionFrame, "BOTTOM", 0, -PTR_IssueReporter.Data.FrameComponentMargin)        
        questionFrame.EditBoxBackground:SetWidth(frame:GetWidth())
        questionFrame.EditBoxBackground:SetHeight(editboxHeight)
        
        questionFrame.EditBox = CreateFrame("EditBox", nil, questionFrame.EditBoxBackground)
        questionFrame.EditBox:SetAllPoints(questionFrame.EditBoxBackground)
        questionFrame.EditBox:SetTextInsets(5, 5, 5, -5)        
        questionFrame.EditBox:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE, THICK")
        questionFrame.EditBox:SetAutoFocus(false)        
        questionFrame.EditBox:SetJustifyV("TOP")
        questionFrame.EditBox:SetJustifyH("LEFT")
        questionFrame.EditBox:SetMultiLine(true)
        
        questionFrame.EditBox.Preface = questionFrame.EditBox:CreateFontString(nil, "OVERLAY")
        questionFrame.EditBox.Preface:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE, THICK")
        questionFrame.EditBox.Preface:SetPoint("TOPLEFT", questionFrame.EditBox, "TOPLEFT", 5, -5)
        questionFrame.EditBox.Preface:SetText("Comment...")
        questionFrame.EditBox.Preface:SetTextColor(1, 1, 1, 0.5)
        
        questionFrame.EditBox.Counter = questionFrame.EditBox:CreateFontString(nil, "OVERLAY")
        questionFrame.EditBox.Counter:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE, THICK")
        questionFrame.EditBox.Counter:SetPoint("BOTTOMRIGHT", questionFrame.EditBox, "BOTTOMRIGHT")
        
        questionFrame.EditBox:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
        end)
        questionFrame.EditBox:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
        end)
        questionFrame.EditBox:SetScript("OnTextChanged", function(self)
            local body = self:GetText()
            if (#body > 0) then
                questionFrame.EditBox.Preface:Hide()
            else
                questionFrame.EditBox.Preface:Show()
            end
            local count = string.format("%s / %s", #body, questionFrame.EditBox.MaxLetters)
            questionFrame.EditBox.Counter:SetText(count)
        end)
        
        function questionFrame:GetReportString()
            local reportString = questionFrame.EditBox:GetText():gsub(",", " ")
            return reportString
        end
    end
    
    questionFrame:SetParent(frame)
    questionFrame:SetPoint("TOP", frame, "TOP", 0, -frame.FrameHeight)
    questionFrame:SetWidth(frame:GetWidth())
    
    if (question) and (string.len(question) > 0) then
        headerHeight = PTR_IssueReporter.SetupQuestionFrame(questionFrame, question)
    else
        questionFrame.text:SetText("")
        headerHeight = 0.1
    end
    
    questionFrame:SetHeight(headerHeight)
    
    questionFrame.EditBox:SetText("")
    questionFrame.EditBox.MaxLetters = characterLimit
    questionFrame.EditBox:SetMaxLetters(questionFrame.EditBox.MaxLetters)
    frame.FrameHeight = frame.FrameHeight + (editboxHeight + headerHeight + (PTR_IssueReporter.Data.FrameComponentMargin*2))
    
    questionFrame:Show()    
    table.insert(frame.FrameComponents, questionFrame) 
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.AttachMultipleChoiceNoQuestion(frame, answers, canSelectMultiple, displayVertically, forceSelection)
    local questionFrame    
    local editboxHeight = 50 -- 25 min number of characters on a line, 14 is line height, 15 is extra pad to allow for the character counter 
    local headerHeight = 20
    local verticalCheckboxHeight = 30
    
    if not (PTR_IssueReporter.Data.UnusedFrameComponents.MultipleChoice) then
        PTR_IssueReporter.Data.UnusedFrameComponents.MultipleChoice = {}
    end
    
    local numberOfUnusedFrames = #PTR_IssueReporter.Data.UnusedFrameComponents.MultipleChoice
    
    if  numberOfUnusedFrames > 0 then -- Check if there is a frame we should reuse
        questionFrame = PTR_IssueReporter.Data.UnusedFrameComponents.MultipleChoice[numberOfUnusedFrames]
        PTR_IssueReporter.Data.UnusedFrameComponents.MultipleChoice[numberOfUnusedFrames] = nil
        numberOfUnusedFrames = #PTR_IssueReporter.Data.UnusedFrameComponents.MultipleChoice
    else
        questionFrame = CreateFrame("Frame", nil, frame)
        questionFrame:SetHeight(headerHeight)
        questionFrame.FrameType = "MultipleChoice"
        questionFrame.text = questionFrame:CreateFontString("CheckListText", "OVERLAY", PTR_IssueReporter.Assets.FontString)
        questionFrame.text:SetPoint("TOP", questionFrame, "TOP", 0, 0) 
        questionFrame.text:SetSize(questionFrame:GetWidth(), questionFrame:GetHeight())
        questionFrame.text:SetJustifyV("MIDDLE")
        questionFrame.text:SetJustifyH("CENTER")

        PTR_IssueReporter.AddBorder(questionFrame)
        PTR_IssueReporter.AddBackground(questionFrame, PTR_IssueReporter.Assets.BackgroundTexture)
        
        questionFrame.QuestionBackground = CreateFrame("Frame", nil, questionFrame)  
        questionFrame.QuestionBackground:SetPoint("TOP", questionFrame, "BOTTOM", 0, -PTR_IssueReporter.Data.FrameComponentMargin)        
        questionFrame.QuestionBackground:SetWidth(frame:GetWidth())        
        PTR_IssueReporter.AddBackground(questionFrame, PTR_IssueReporter.Assets.BackgroundTexture)
    end
    
    questionFrame.GetReportString = nil
    
    questionFrame.Checkboxes = {}
    questionFrame:SetParent(frame)
    questionFrame:SetPoint("TOP", frame, "TOP", 0, -frame.FrameHeight)
    questionFrame:SetWidth(frame:GetWidth())    
    
    headerHeight = 30--PTR_IssueReporter.SetupQuestionFrame(questionFrame, question)
    questionFrame:SetHeight(30)
    questionFrame:Show()
    
    local numberOfCurrentCheckboxes = #answers
    local questionFrameWidth = questionFrame.QuestionBackground:GetWidth()
    local checkBoxMargin = (questionFrameWidth/numberOfCurrentCheckboxes)-10
    
    if (PTR_IssueReporter.StandaloneSurvey) and (PTR_IssueReporter.StandaloneSurvey.submitButton) then
        PTR_IssueReporter.SetSubmitButtonEnabled(false)
    end
    
    for key, choiceInfo in pairs (answers) do
        local height = PTR_IssueReporter.AttachCheckboxToQuestion(questionFrame, choiceInfo.Choice, canSelectMultiple, true, checkBoxMargin, choiceInfo.Key, true)
        if (height > verticalCheckboxHeight) then
            verticalCheckboxHeight = height
        end
    end
    
    for key, checkbox in pairs (questionFrame.Checkboxes) do
        if (displayVertically) then
            checkbox:SetPoint("TOP", questionFrame, "TOPLEFT", 20, -((key-1) * verticalCheckboxHeight))
        else
            
            checkbox:SetPoint("TOP", questionFrame, "TOPLEFT", (key * checkBoxMargin)-(checkBoxMargin * 0.5), 0)
        end
        
        checkbox:Show()
    end
    
    if (displayVertically) then
        editboxHeight = 0--#questionFrame.Checkboxes * verticalCheckboxHeight
    else
        editboxHeight = 0--verticalCheckboxHeight + 2
    end
    questionFrame.QuestionBackground:SetHeight(editboxHeight)
    
    frame.FrameHeight = frame.FrameHeight + headerHeight + editboxHeight + (PTR_IssueReporter.Data.FrameComponentMargin*2)
    table.insert(frame.FrameComponents, questionFrame)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.AttachMultipleChoiceQuestion(frame, question, answers, canSelectMultiple, displayVertically)
    
    local questionFrame    
    local editboxHeight = 50 -- 25 min number of characters on a line, 14 is line height, 15 is extra pad to allow for the character counter 
    local headerHeight = 20
    local verticalCheckboxHeight = 30
    
    if not (PTR_IssueReporter.Data.UnusedFrameComponents.MultipleChoice) then
        PTR_IssueReporter.Data.UnusedFrameComponents.MultipleChoice = {}
    end
    
    local numberOfUnusedFrames = #PTR_IssueReporter.Data.UnusedFrameComponents.MultipleChoice
    
    if  numberOfUnusedFrames > 0 then -- Check if there is a frame we should reuse
        questionFrame = PTR_IssueReporter.Data.UnusedFrameComponents.MultipleChoice[numberOfUnusedFrames]
        PTR_IssueReporter.Data.UnusedFrameComponents.MultipleChoice[numberOfUnusedFrames] = nil
        numberOfUnusedFrames = #PTR_IssueReporter.Data.UnusedFrameComponents.MultipleChoice
    else
        questionFrame = CreateFrame("Frame", nil, frame)
        questionFrame:SetHeight(headerHeight)
        questionFrame.FrameType = "MultipleChoice"
        questionFrame.text = questionFrame:CreateFontString("CheckListText", "OVERLAY", PTR_IssueReporter.Assets.FontString)
        questionFrame.text:SetPoint("TOP", questionFrame, "TOP", 0, 0) 
        questionFrame.text:SetSize(questionFrame:GetWidth(), questionFrame:GetHeight())
        questionFrame.text:SetJustifyV("MIDDLE")
        questionFrame.text:SetJustifyH("CENTER")

        PTR_IssueReporter.AddBorder(questionFrame)
        PTR_IssueReporter.AddBackground(questionFrame, PTR_IssueReporter.Assets.BackgroundTexture)
        
        questionFrame.QuestionBackground = CreateFrame("Frame", nil, questionFrame)  
        questionFrame.QuestionBackground:SetPoint("TOP", questionFrame, "BOTTOM", 0, -PTR_IssueReporter.Data.FrameComponentMargin)        
        questionFrame.QuestionBackground:SetWidth(frame:GetWidth())        
        PTR_IssueReporter.AddBackground(questionFrame, PTR_IssueReporter.Assets.BackgroundTexture) 
    end
    
    function questionFrame:GetReportString()
        local reportString = ""
        
        for key, checkbox in pairs (questionFrame.Checkboxes) do
            if (checkbox:GetChecked()) then
                reportString = string.format("%s%s", reportString, "1")
            else
                reportString = string.format("%s%s", reportString, "0")
            end
        end
        
        return reportString
    end
    
    questionFrame.Checkboxes = {}
    questionFrame:SetParent(frame)
    questionFrame:SetPoint("TOP", frame, "TOP", 0, -frame.FrameHeight)
    questionFrame:SetWidth(frame:GetWidth())    
    
    headerHeight = PTR_IssueReporter.SetupQuestionFrame(questionFrame, question)
    questionFrame:Show()
    
    local numberOfCurrentCheckboxes = #answers
    local questionFrameWidth = questionFrame.QuestionBackground:GetWidth()
    local checkBoxMargin = questionFrameWidth/(numberOfCurrentCheckboxes)
    
    for key, choice in pairs (answers) do
        local height = PTR_IssueReporter.AttachCheckboxToQuestion(questionFrame, choice, canSelectMultiple, displayVertically, checkBoxMargin)
        if (height > verticalCheckboxHeight) then
            verticalCheckboxHeight = height
        end
    end
    
    for key, checkbox in pairs (questionFrame.Checkboxes) do
        if (displayVertically) then
            checkbox:SetPoint("TOP", questionFrame.QuestionBackground, "TOPLEFT", 20, -((key-1) * verticalCheckboxHeight))
        else
            
            checkbox:SetPoint("TOP", questionFrame.QuestionBackground, "TOPLEFT", (key * checkBoxMargin)-(checkBoxMargin * 0.5), 0)
        end
        
        checkbox:Show()
    end
    
    if (displayVertically) then
        editboxHeight = #questionFrame.Checkboxes * verticalCheckboxHeight
    else
        editboxHeight = verticalCheckboxHeight + 2
    end
    questionFrame.QuestionBackground:SetHeight(editboxHeight)
    
    frame.FrameHeight = frame.FrameHeight + headerHeight + editboxHeight + (PTR_IssueReporter.Data.FrameComponentMargin*2)
    table.insert(frame.FrameComponents, questionFrame) 
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.AttachTextBlock(frame, question)

    local questionFrame    
    local editboxHeight = 50 -- 25 min number of characters on a line, 14 is line height, 15 is extra pad to allow for the character counter 
    local headerHeight = 20
    local verticalCheckboxHeight = 30
    
    if not (PTR_IssueReporter.Data.UnusedFrameComponents.TextBlock) then
        PTR_IssueReporter.Data.UnusedFrameComponents.TextBlock = {}
    end
    
    local numberOfUnusedFrames = #PTR_IssueReporter.Data.UnusedFrameComponents.TextBlock
    
    if  numberOfUnusedFrames > 0 then -- Check if there is a frame we should reuse
        questionFrame = PTR_IssueReporter.Data.UnusedFrameComponents.TextBlock[numberOfUnusedFrames]
        PTR_IssueReporter.Data.UnusedFrameComponents.TextBlock[numberOfUnusedFrames] = nil
        numberOfUnusedFrames = #PTR_IssueReporter.Data.UnusedFrameComponents.TextBlock
    else
        questionFrame = CreateFrame("Frame", nil, frame)
        questionFrame:SetHeight(headerHeight)
        questionFrame.FrameType = "TextBlock"
        questionFrame.text = questionFrame:CreateFontString("CheckListText", "OVERLAY", PTR_IssueReporter.Assets.FontString)
        questionFrame.text:SetPoint("TOP", questionFrame, "TOP", 0, 0) 
        questionFrame.text:SetSize(questionFrame:GetWidth(), questionFrame:GetHeight())
        questionFrame.text:SetJustifyV("MIDDLE")
        questionFrame.text:SetJustifyH("CENTER")

        PTR_IssueReporter.AddBorder(questionFrame)
        PTR_IssueReporter.AddBackground(questionFrame, PTR_IssueReporter.Assets.BackgroundTexture)
        
        questionFrame.QuestionBackground = CreateFrame("Frame", nil, questionFrame)  
        questionFrame.QuestionBackground:SetPoint("TOP", questionFrame, "BOTTOM", 0, -PTR_IssueReporter.Data.FrameComponentMargin)        
        questionFrame.QuestionBackground:SetWidth(frame:GetWidth())        
        PTR_IssueReporter.AddBackground(questionFrame, PTR_IssueReporter.Assets.BackgroundTexture)
    end
    
    questionFrame.Checkboxes = {}
    questionFrame:SetParent(frame)
    questionFrame:SetPoint("TOP", frame, "TOP", 0, -frame.FrameHeight)
    questionFrame:SetWidth(frame:GetWidth())
    headerHeight = PTR_IssueReporter.SetupQuestionFrame(questionFrame, question)
    questionFrame:Show()
    
    frame.FrameHeight = frame.FrameHeight + headerHeight + (PTR_IssueReporter.Data.FrameComponentMargin*1)
    table.insert(frame.FrameComponents, questionFrame) 
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupQuestionFrame(questionFrame, question)
    local headerHeight = 20
    local margin = 5
    questionFrame.text:SetText(question)
    questionFrame.text:SetWidth(questionFrame:GetWidth()-10)
    questionFrame.text:SetHeight(0)
    headerHeight = questionFrame.text:GetHeight() + margin
    if (headerHeight < 20) then
        headerHeight = 20
    end

    questionFrame:SetHeight(headerHeight)
    questionFrame.text:SetHeight(headerHeight)
    
    if (questionFrame.QuestionBackground) then
        questionFrame.QuestionBackground:ClearAllPoints()
        questionFrame.QuestionBackground:SetPoint("TOP", questionFrame, "BOTTOM", 0, -PTR_IssueReporter.Data.FrameComponentMargin)
    end
    return headerHeight
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.AttachCheckboxToQuestion(questionFrame, answer, canSelectMultiple, isVertical, checkBoxMargin, keyUpdate, forceSelection)
    
    local newCheckbox
    
    if not (PTR_IssueReporter.Data.UnusedFrameComponents.Checkbox) then
        PTR_IssueReporter.Data.UnusedFrameComponents.Checkbox = {}
    end
    
    local numberOfUnusedFrames = #PTR_IssueReporter.Data.UnusedFrameComponents.Checkbox
    
    if (PTR_IssueReporter.StandaloneSurvey) and (PTR_IssueReporter.StandaloneSurvey.submitButton) and (forceSelection) then
        PTR_IssueReporter.StandaloneSurvey.submitButton.forceSelection = forceSelection
        PTR_IssueReporter.StandaloneSurvey.submitButton.questionFrame = questionFrame
    end    
    
    if  numberOfUnusedFrames > 0 then -- Check if there is a frame we should reuse
        newCheckbox = PTR_IssueReporter.Data.UnusedFrameComponents.Checkbox[numberOfUnusedFrames]
        PTR_IssueReporter.Data.UnusedFrameComponents.Checkbox[numberOfUnusedFrames] = nil
        numberOfUnusedFrames = #PTR_IssueReporter.Data.UnusedFrameComponents.Checkbox
    else
        newCheckbox = CreateFrame("CheckButton", nil, questionFrame.QuestionBackground, "UICheckButtonTemplate")
        newCheckbox.text = newCheckbox:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        newCheckbox.text:SetFont("Fonts\\FRIZQT__.TTF", 9)
        newCheckbox.text:SetJustifyH("CENTER")
        newCheckbox.text:SetJustifyV("MIDDLE")
        newCheckbox.text:SetTextColor(1, 1, 1)
        
        newCheckbox:SetScript("OnClick", function(self)
            if (self.keyUpdate) then
                if (self:GetChecked()) then
                    PTR_IssueReporter.Data.Current_Message_Key = self.keyUpdate
                else
                    PTR_IssueReporter.ResetKey()
                end
            end
            
            if not (canSelectMultiple) and (self:GetChecked()) then
                for key, checkbox in pairs (questionFrame.Checkboxes) do
                    checkbox:SetChecked((checkbox == self))
                end
            end
            
            PTR_IssueReporter.SetSurveyButtonEnabledState()
        end)
    end
    
    newCheckbox.keyUpdate = keyUpdate
    newCheckbox.text:ClearAllPoints()
    
    if (isVertical) then        
        newCheckbox.text:SetPoint("LEFT", newCheckbox, "RIGHT", 0, 0)
        newCheckbox.text:SetWidth(0)
    else
        newCheckbox.text:SetPoint("TOP", newCheckbox, "BOTTOM", 0, 0)

        newCheckbox.text:SetWidth(checkBoxMargin)
    end
    
    newCheckbox:SetChecked(false)
    newCheckbox:SetParent(questionFrame.QuestionBackground)
    newCheckbox.text:SetText(answer)
    newCheckbox:Show()
    
    table.insert(questionFrame.Checkboxes, newCheckbox)
    return newCheckbox:GetHeight() + newCheckbox.text:GetHeight()
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetSurveyButtonEnabledState()
    if (PTR_IssueReporter.StandaloneSurvey) and (PTR_IssueReporter.StandaloneSurvey.submitButton) then        
        if (PTR_IssueReporter.StandaloneSurvey.submitButton.forceSelection) then        
            local submitEnabled = false
            
            for key, checkbox in pairs (PTR_IssueReporter.StandaloneSurvey.submitButton.questionFrame.Checkboxes) do
                if (checkbox:GetChecked()) then
                    submitEnabled = true
                end
            end
            
            PTR_IssueReporter.SetSubmitButtonEnabled(submitEnabled)
        else
            PTR_IssueReporter.SetSubmitButtonEnabled(true)
        end
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetSubmitButtonEnabled(enabledStatus)
    if (enabledStatus) then
        PTR_IssueReporter.StandaloneSurvey.submitButton:SetEnabled(true)
        PTR_IssueReporter.StandaloneSurvey.submitButton.Tooltip:Hide()
    else
        PTR_IssueReporter.StandaloneSurvey.submitButton:SetEnabled(false)
        PTR_IssueReporter.StandaloneSurvey.submitButton.Tooltip:Show()
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.AttachModelViewer(surveyFrame, survey, dataPackage)

    local creatureID = dataPackage[survey.ModelViewerData.key]
    if (survey.ModelViewerData.func) and (type(survey.ModelViewerData.func) == "function") then
        creatureID = survey.ModelViewerData.func(creatureID) or creatureID
    end
    
    if (creatureID) then
        if not (PTR_IssueReporter.Data.UnusedFrameComponents.ModelViewer) then
            PTR_IssueReporter.Data.UnusedFrameComponents.ModelViewer = {}
        end
        
        local numberOfUnusedFrames = #PTR_IssueReporter.Data.UnusedFrameComponents.ModelViewer
        local modelViewerHeight = 300
        local modelViewer
        
        if  numberOfUnusedFrames > 0 then -- Check if there is a frame we should reuse
            modelViewer = PTR_IssueReporter.Data.UnusedFrameComponents.ModelViewer[numberOfUnusedFrames]
            PTR_IssueReporter.Data.UnusedFrameComponents.ModelViewer[numberOfUnusedFrames] = nil
            numberOfUnusedFrames = #PTR_IssueReporter.Data.UnusedFrameComponents.ModelViewer        
        else
            modelViewer = CreateFrame("PlayerModel", nil, frame)
            modelViewer.FrameType = "ModelViewer"
            PTR_IssueReporter.AddBackground(modelViewer, PTR_IssueReporter.Assets.BackgroundTexture)            
        end
        modelViewer:SetParent(surveyFrame)
        modelViewer:ClearAllPoints()
        modelViewer:SetPoint("TOP", surveyFrame, "TOP", 0, 0)
        modelViewer:SetSize(surveyFrame:GetWidth(), modelViewerHeight)
        if (survey.ModelViewerData.useDisplayInfoID) then
            modelViewer:SetDisplayInfo(creatureID)
            modelViewer:SetModelScale(0.75)
        else
            modelViewer:SetCreature(creatureID)
            modelViewer:SetModelScale(0.6)
        end        
        modelViewer:Show()
        
        surveyFrame.FrameHeight = surveyFrame.FrameHeight + modelViewerHeight
        table.insert(surveyFrame.FrameComponents, modelViewer)
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.AttachIconViewer(surveyFrame, survey, dataPackage)
    local dataPackageValue = ""
    if (dataPackage) then
        dataPackageValue = dataPackage[survey.IconViewerData.key]
    end
    if (survey.IconViewerData.func) and (type(survey.IconViewerData.func) == "function") then
        dataPackageValue = survey.IconViewerData.func(dataPackageValue) or dataPackageValue
    end
    
    if (dataPackageValue) then
        if not (PTR_IssueReporter.Data.UnusedFrameComponents.IconViewer) then
            PTR_IssueReporter.Data.UnusedFrameComponents.IconViewer = {}
        end
        
        local numberOfUnusedFrames = #PTR_IssueReporter.Data.UnusedFrameComponents.IconViewer
        local iconViewerHeight = 100
        local iconViewer
        
        if  numberOfUnusedFrames > 0 then -- Check if there is a frame we should reuse
            iconViewer = PTR_IssueReporter.Data.UnusedFrameComponents.IconViewer[numberOfUnusedFrames]
            PTR_IssueReporter.Data.UnusedFrameComponents.IconViewer[numberOfUnusedFrames] = nil
            numberOfUnusedFrames = #PTR_IssueReporter.Data.UnusedFrameComponents.IconViewer        
        else
            iconViewer = CreateFrame("Frame", nil, frame)
            iconViewer.FrameType = "IconViewer"
            PTR_IssueReporter.AddBackground(iconViewer, PTR_IssueReporter.Assets.BackgroundTexture)
            
            iconViewer.Icon = CreateFrame("Frame", nil, iconViewer)
            iconViewer.Icon:SetPoint("TOP", iconViewer, "TOP")
            iconViewer.Icon:SetHeight(iconViewerHeight-PTR_IssueReporter.Data.FrameComponentMargin)
            iconViewer.Icon:SetWidth(iconViewerHeight-PTR_IssueReporter.Data.FrameComponentMargin)
            

            iconViewer.Icon.Texture = iconViewer.Icon:CreateTexture()
            iconViewer.Icon.Texture:SetPoint("TOPLEFT", iconViewer.Icon, "TOPLEFT")
            iconViewer.Icon.Texture:SetPoint("BOTTOMRIGHT", iconViewer.Icon, "BOTTOMRIGHT")
            iconViewer.Icon.Texture:SetVertTile(false)
            iconViewer.Icon.Texture:SetHorizTile(false)
            
            iconViewer.Icon.Texture:SetDrawLayer("ARTWORK")            
        end
    
        iconViewer:SetParent(surveyFrame)
        iconViewer:ClearAllPoints()
        iconViewer:SetPoint("TOP", surveyFrame, "TOP", 0, 0)
        iconViewer:SetSize(surveyFrame:GetWidth(), iconViewerHeight)
        iconViewer.Icon.Texture:SetTexture(dataPackageValue, false, false)
        iconViewer:Show()
        surveyFrame.FrameHeight = surveyFrame.FrameHeight + iconViewerHeight
        table.insert(surveyFrame.FrameComponents, iconViewer)
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.CleanReportFrame(frame)
    
    if (PTR_IssueReporter.StandaloneSurvey) and (PTR_IssueReporter.StandaloneSurvey.submitButton) then
        PTR_IssueReporter.StandaloneSurvey.submitButton.forceSelection = false
        PTR_IssueReporter.SetSurveyButtonEnabledState()
    end
    
    if (frame) and (frame.FrameComponents) then
        for _, component in pairs (frame.FrameComponents) do
            if (component.FrameType) then
                if (component.FrameType == "MultipleChoice") then
                    for _, checkbox in pairs (component.Checkboxes) do
                        checkbox:SetParent(UIParent)
                        checkbox:Hide()            
                        table.insert(PTR_IssueReporter.Data.UnusedFrameComponents.Checkbox, checkbox)
                    end
                end
                
                if component.FrameType ~= "Empty" then
                    component:SetParent(UIParent)
                    component:Hide()
                    table.insert(PTR_IssueReporter.Data.UnusedFrameComponents[component.FrameType], component)
                end
            end
        end
    end
    
    frame.FrameComponents = {}
    frame.FrameHeight = 0
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.GetStandaloneSurveyFrame(followUpSurvey)
    if not (PTR_IssueReporter.StandaloneSurvey) then        
        
        local surveyFrame = PTR_IssueReporter.CreateSurveyFrame()
        
        local titleBox = CreateFrame("Frame", nil, UIParent)      
        titleBox.text = titleBox:CreateFontString("CheckListText", "OVERLAY", PTR_IssueReporter.Assets.FontString)
        titleBox:SetFrameStrata("FULLSCREEN")
        titleBox.text:SetWidth(titleBox:GetWidth())
        titleBox.text:SetHeight(titleBox:GetHeight())
        titleBox.text:SetPoint("CENTER", titleBox, "CENTER", 0, 0)
        titleBox.SurveyFrame = surveyFrame
        
        surveyFrame:SetParent(titleBox)
        surveyFrame:SetPoint("TOP", titleBox, "BOTTOM", 0, -PTR_IssueReporter.Data.FrameComponentMargin)
        
        function titleBox:SetLabelText(text)
            local maxWidth = 253
            
            titleBox.text:SetText(text)
            titleBox.text:SetFont("Fonts\\FRIZQT__.TTF", 12)
            titleBox:SetSize(253, titleBox.text:GetHeight()*2)
            local currentFont = 12
            local currentWidth = titleBox.text:GetWidth()
            while (currentWidth > maxWidth) and (currentFont > 5) do
                currentFont = currentFont - 1
                titleBox.text:SetFont("Fonts\\FRIZQT__.TTF", currentFont)
                titleBox.text:SetText(text)
                currentWidth = titleBox.text:GetWidth()
            end
            if (currentWidth > maxWidth) then
                titleBox:SetHeight(titleBox:GetHeight() * 1.8)
                titleBox.text:SetHeight(titleBox:GetHeight())
            end
        end
        
        titleBox:SetLabelText("Issue Reporter")
        PTR_IssueReporter.AddBorder(titleBox)
        PTR_IssueReporter.AddDrag(titleBox)
        PTR_IssueReporter.AddBackground(titleBox, PTR_IssueReporter.Assets.BackgroundTexture)
        
        --close button
        local closeButton = CreateFrame("Button", nil, surveyFrame, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", surveyFrame, "TOPRIGHT", 6, 6)
        closeButton:SetScript("OnHide", function(self)
            titleBox:Hide()
            PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
        end)
        closeButton:SetFrameLevel(10)
        
        local showFunction = function()
            local yPos = GetScreenHeight()/5
            titleBox:ClearAllPoints()
            titleBox:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, -100)
            surveyFrame:Show()
            closeButton:Show()
        end
        
        -- surveyFrame:SubmitBugReport() will hide the surveyFrame and all child frames, but since surveyFrame is parented to titleBox we need to make sure that gets hidden as well
        surveyFrame:SetScript("OnHide", function() titleBox:Hide() end)
        
        titleBox:SetScript("OnShow", showFunction)
        showFunction()        
        
        local submitButton = CreateFrame("Button", nil, surveyFrame, "UIPanelButtonTemplate")
        submitButton.Tooltip = CreateFrame("Frame", nil, submitButton)
        submitButton.Tooltip:SetPoint("TOPLEFT", submitButton, "TOPLEFT")
        submitButton.Tooltip:SetPoint("BOTTOMRIGHT", submitButton, "BOTTOMRIGHT")
        
        submitButton:SetPoint("TOP", surveyFrame, "BOTTOM")
        submitButton:SetText(PTR_IssueReporter.Data.SubmitText)
        submitButton:SetSize(submitButton:GetTextWidth()*1.5, PTR_IssueReporter.Data.SubmitButtonHeight)
        submitButton:SetScript("OnClick", function()
            surveyFrame:SubmitIssueReport()
            if not(C_Glue.IsOnGlueScreen()) then
                PTR_IssueReporter.CheckSurveyQueue()
            end
        end)
        submitButton:SetScript("OnShow", buttonOnShow)
        
        submitButton.Tooltip:SetScript("OnEnter", function()
            if not (submitButton:IsEnabled()) then
                GameTooltip:ClearAllPoints()
                GameTooltip:SetPoint("TOPLEFT", submitButton, "TOPRIGHT", 0, 0)
                GameTooltip:SetOwner(submitButton, "ANCHOR_PRESERVE")
                GameTooltip:AddLine("Please select either Bug or Feedback")
                GameTooltip:Show()
            end
        end)
        
        submitButton.Tooltip:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        
        titleBox.submitButton = submitButton
        titleBox:Hide()
        PTR_IssueReporter.StandaloneSurvey = titleBox
    end
    if PTR_IssueReporter.InBarbershop then
        PTR_IssueReporter.StandaloneSurvey:SetParent(CharCustomizeFrame)
        PTR_IssueReporter.StandaloneSurvey.SurveyFrame:SetParent(CharCustomizeFrame)
	else
        PTR_IssueReporter.StandaloneSurvey:SetParent(GetAppropriateTopLevelParent())
        PTR_IssueReporter.StandaloneSurvey.SurveyFrame:SetParent(GetAppropriateTopLevelParent())
	end     
	PTR_IssueReporter.StandaloneSurvey:SetFrameStrata("FULLSCREEN")
	PTR_IssueReporter.StandaloneSurvey.SurveyFrame:SetFrameStrata("FULLSCREEN")
    if (followUpSurvey) and (PTR_IssueReporter.StandaloneSurvey.submitButton) then
        PTR_IssueReporter.StandaloneSurvey.submitButton:SetText(PTR_IssueReporter.Data.NextText)
    else
        PTR_IssueReporter.StandaloneSurvey.submitButton:SetText(PTR_IssueReporter.Data.SubmitText)
    end
    
    return PTR_IssueReporter.StandaloneSurvey
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.CreateSurveyFrame()
    local surveyFrame = CreateFrame("Frame", "PTRIssueReporterAlertFrame", UIParent)        
    surveyFrame:SetSize(338, 496)    
    PTR_IssueReporter.AddBorder(surveyFrame)
    PTR_IssueReporter.AddBackground(surveyFrame, PTR_IssueReporter.Assets.TestWatermark)
    
    surveyFrame.FrameHeight = 0
    surveyFrame.FrameComponents = {}
    surveyFrame.SurveyString = ""
    surveyFrame:SetFrameStrata("HIGH")

    if(C_Glue.IsOnGlueScreen()) then
        PTR_IssueReporter:HookScript("OnHide",function() surveyFrame:Hide() end)
    end
    
    function surveyFrame:SubmitIssueReport()
        if (self.SurveyString) and (self.FrameComponents) and (self.SurveyString) and (self:IsShown()) then                
            local userData = {}
            local suppressNotification = false
            for key, component in pairs (self.FrameComponents) do
                if (component.GetReportString) then
                    local componentString = component:GetReportString()
                    table.insert(userData, componentString)
                    if (componentString == "") then
                        suppressNotification = true
                    end
                end
            end
            
            local surveyString = string.format(self.SurveyString, unpack(userData))
            
            -- Resetting any key changes that have happened
            PTR_IssueReporter.ResetKey()
            
            C_UserFeedback.SubmitBug(surveyString, suppressNotification)
            self:Hide()
            PTR_IssueReporter.CleanReportFrame(self)
            
            if (self.CurrentSurvey) and (self.CurrentSurvey.OnSubmitPoppedSurvey) then
                local survey = self.CurrentSurvey.OnSubmitPoppedSurvey
                self.OnSubmitPoppedSurvey = nil
                PTR_IssueReporter.PopStandaloneSurvey(survey)
            end
        end    
    end

    return surveyFrame
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.Reminder(enable, ...)
    if (not Blizzard_PTRIssueReporter_Saved.sawHighlight) then
        for k,v in pairs({...}) do
            if (enable) then
                ActionButtonSpellAlertManager:ShowAlert(v)
            else
                ActionButtonSpellAlertManager:HideAlert(v)
            end
        end
        if (not enable) then
            Blizzard_PTRIssueReporter_Saved.sawHighlight = true
        end
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.CreateIssueButton(name, icon, buttonTooltip, func)
    local scalar = PTR_IssueReporter.Body:GetHeight()
    local newbutton = CreateFrame("Button", name, PTR_IssueReporter)
    newbutton:SetSize(scalar, scalar)
    newbutton:SetHighlightTexture(icon, "ADD")
    newbutton:SetNormalTexture(icon)
    newbutton:SetPushedTexture(PTR_IssueReporter.Assets.PushedTexture)
    PTR_IssueReporter.AddBorder(newbutton)
    newbutton:SetScript("OnEnter", function(self)
        tooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
        tooltip:SetText(name, 1, 1, 1, true);
        tooltip:AddLine(buttonTooltip, nil, nil, nil, true);
        tooltip:SetMinimumWidth(100);
        tooltip:Show()
    end)
    newbutton:SetScript("OnLeave", function(self)
        self:SetButtonState("NORMAL")
        tooltip:Hide()
    end)

    if (func) then
        newbutton:SetScript("OnClick", function(self, button, down)
            func()
        end)
    end
    newbutton:SetScript("OnHide", function(self)
        self:Show()
    end)
    return newbutton
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetBugButtonContext(context, buttonTooltip, bugIcon)
    context = context or PTR_IssueReporter.Data.DefaultBugButtonContext

    if (PTR_IssueReporterPTR_IssueReporter ~= context) then
        PTR_IssueReporter.Data.CurrentBugButtonContext = context

        if (PTR_IssueReporter.ReportBug) then
            PTR_IssueReporter.ReportBug:SetNormalTexture(bugIcon or PTR_IssueReporter.Assets.BugReportIcon)
            PTR_IssueReporter.ReportBug:SetHighlightTexture(bugIcon or PTR_IssueReporter.Assets.BugReportIcon, "ADD")

            PTR_IssueReporter.ReportBug:SetScript("OnEnter", function(self)
                tooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
                tooltip:SetText(PTR_IssueReporter.Data.CurrentBugButtonContext, 1, 1, 1, true);
                tooltip:AddLine(buttonTooltip or PTR_IssueReporter.Data.BugReportString, nil, nil, nil, true);
                tooltip:SetMinimumWidth(100);
                tooltip:Show()
                if not(C_Glue.IsOnGlueScreen()) then
                    ActionButtonSpellAlertManager:HideAlert(PTR_IssueReporter.ReportBug)
                end
            end)

            if (context ~= PTR_IssueReporter.Data.DefaultBugButtonContext) and ActionButtonSpellAlertManager then
                ActionButtonSpellAlertManager:ShowAlert(PTR_IssueReporter.ReportBug) -- Highlights the fact that the button has changed purpose
            end
        end
    end
end

function PTR_IssueReporter.CreateGlueView()
    --information button
    PTR_IssueReporter.AddInfoButton(PTR_IssueReporter)
    PTR_IssueReporter.AddTooltip(PTR_IssueReporter.InfoButton,
        "How Can I Help?",
        "|cffFFFFFFPlease Provide:|r\n-What you expected\n-What you observed\n\n|cffFFFFFFAutomatically Collected:|r\n-Your character customizations\n-Your character information")

    --create buttons
    PTR_IssueReporter.ReportBug = PTR_IssueReporter.CreateIssueButton("Bug",
        PTR_IssueReporter.Assets.BugReportIcon,
        PTR_IssueReporter.Data.bugMouseoverText)

    PTR_IssueReporter.ReportBug:SetScript("OnClick", function(self, button, down)
        PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.UIButtonClicked, PTR_IssueReporter.Data.CurrentBugButtonContext, PTR_IssueReporter.Data.ButtonDataPackage)
        PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
    end)

    PTR_IssueReporter.SetBugButtonContext()
    PTR_IssueReporter.ReportBug:SetPoint("TOPLEFT", PTR_IssueReporter.Body, "TOP", -(PTR_IssueReporter.Body:GetWidth()/4), -6)
    PTR_IssueReporter.ReportBug:SetWidth(PTR_IssueReporter.Body:GetWidth()/2)
    PTR_IssueReporter.ReportBug:SetHeight(PTR_IssueReporter.Body:GetWidth()/2)
    PTR_IssueReporter.Body.Texture = PTR_IssueReporter.Body:CreateTexture()
    PTR_IssueReporter.Body.Texture:SetTexture(PTR_IssueReporter.Assets.BackgroundTexture)
    PTR_IssueReporter.Body.Texture:SetPoint("BOTTOMRIGHT", PTR_IssueReporter.ReportBug, "BOTTOMRIGHT")
    PTR_IssueReporter.Body.Texture:SetPoint("TOPLEFT", PTR_IssueReporter.ReportBug, "TOPLEFT")

    PTR_IssueReporter.Body.Texture:SetDrawLayer("BACKGROUND")
end

function PTR_IssueReporter.CreateInGameMenu()
    PTR_IssueReporter:SetScript("OnEnter", function(self)
        SetCursor("Interface\\CURSOR\\UI-Cursor-Move.blp")
    end)
    PTR_IssueReporter:SetScript("OnLeave", function(self)
        ResetCursor()
    end)

   --information button
   PTR_IssueReporter.AddInfoButton(PTR_IssueReporter)
   PTR_IssueReporter.AddTooltip(PTR_IssueReporter.InfoButton,
       "How Can I Help?",
       "If possible create bugs using the tooltip keybind to help us identify the issue easier.|r\n\n|cffFFFFFFPlease Provide:|r\n-What you were doing\n-What you observed\n\n|cffFFFFFFAutomatically Collected:|r\n-Your world location\n-Your character information")

   --create buttons
   --PTR_IssueReporter.Confused = PTR_IssueReporter.CreateIssueButton("Feedback",
   --    PTR_IssueReporter.Assets.ConfusedIcon,
   --    "I have Feedback for this Zone")
   
   PTR_IssueReporter.ReportBug = PTR_IssueReporter.CreateIssueButton("Bug",
       PTR_IssueReporter.Assets.BugReportIcon,
       PTR_IssueReporter.Data.bugMouseoverText)

   --PTR_IssueReporter.Confused:SetScript("OnClick", function(self, button, down)
   --    PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.UIButtonClicked, "Confused")
   --    PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
   --end)

   PTR_IssueReporter.ReportBug:SetScript("OnClick", function(self, button, down)
       PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.UIButtonClicked, PTR_IssueReporter.Data.CurrentBugButtonContext, PTR_IssueReporter.Data.ButtonDataPackage)
       PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
   end)

    --PTR_IssueReporter.Confused:HookScript("OnEnter", function() PTR_IssueReporter.Reminder(false, PTR_IssueReporter.Confused, PTR_IssueReporter.ReportBug) end)
    PTR_IssueReporter.ReportBug:HookScript("OnEnter", function() PTR_IssueReporter.Reminder(false, PTR_IssueReporter.Confused, PTR_IssueReporter.ReportBug) end)

   PTR_IssueReporter.SetBugButtonContext()
   PTR_IssueReporter.ReportBug:SetPoint("TOP", PTR_IssueReporter.Body, "TOP", 0, -6)
   --PTR_IssueReporter.Confused:SetPoint("TOPRIGHT", PTR_IssueReporter.Body, "TOP", -2, -6)
   PTR_IssueReporter.Body.Texture = PTR_IssueReporter.Body:CreateTexture()
   PTR_IssueReporter.Body.Texture:SetTexture(PTR_IssueReporter.Assets.BackgroundTexture)
   --PTR_IssueReporter.Body.Texture:SetPoint("TOPLEFT", PTR_IssueReporter.Confused, "TOPLEFT")
   PTR_IssueReporter.Body.Texture:SetPoint("TOPLEFT", PTR_IssueReporter.ReportBug, "TOPLEFT")
   PTR_IssueReporter.Body.Texture:SetPoint("BOTTOMRIGHT", PTR_IssueReporter.ReportBug, "BOTTOMRIGHT")
   PTR_IssueReporter.Body.Texture:SetDrawLayer("BACKGROUND")
   PTR_IssueReporter:SetClampRectInsets(0,0,0, -(PTR_IssueReporter.ReportBug:GetHeight()))

    --timers/reminders/notifications, only one time ever on login
    C_Timer.After(1, function(self) PTR_IssueReporter.Reminder(true, PTR_IssueReporter.Confused, PTR_IssueReporter.ReportBug) end)
end

----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.CreateMainView()
    local SetFrameLocation = function(self)
        PTR_IssueReporter:ClearAllPoints()
        if (Blizzard_PTRIssueReporter_Saved.x and Blizzard_PTRIssueReporter_Saved.y) then
            PTR_IssueReporter:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", Blizzard_PTRIssueReporter_Saved.x, Blizzard_PTRIssueReporter_Saved.y)
		elseif Kiosk.IsEnabled() then
            PTR_IssueReporter:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 30, 350);
		else
           PTR_IssueReporter:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, UIParent:GetHeight()*0.25)
        end
    end    
    PTR_IssueReporter:SetScript("OnShow", SetFrameLocation)
    SetFrameLocation(PTR_IssueReporter)
    
    PTR_IssueReporter:SetFrameStrata("DIALOG")
    PTR_IssueReporter.text = PTR_IssueReporter:CreateFontString("CheckListText", "OVERLAY", PTR_IssueReporter.Assets.FontString)
    PTR_IssueReporter.text:SetWidth(PTR_IssueReporter:GetWidth())
    PTR_IssueReporter.text:SetHeight(PTR_IssueReporter:GetHeight())
    PTR_IssueReporter.text:SetPoint("CENTER", PTR_IssueReporter, "CENTER", 0, 0)
    PTR_IssueReporter.text:SetText("Issue\nReporter")
    PTR_IssueReporter:SetSize(PTR_IssueReporter.text:GetStringWidth()*1.3, 32)
    PTR_IssueReporter.AddBorder(PTR_IssueReporter)
    PTR_IssueReporter.Body = CreateFrame("Frame", nil, PTR_IssueReporter)
    PTR_IssueReporter.Body:SetSize(PTR_IssueReporter:GetWidth(), PTR_IssueReporter.Data.Height)
    PTR_IssueReporter.Body:SetPoint("TOP", PTR_IssueReporter, "BOTTOM", 0, PTR_IssueReporter:GetHeight()*0.05)
    PTR_IssueReporter.AddBackground(PTR_IssueReporter, PTR_IssueReporter.Assets.BackgroundTexture)

    PTR_IssueReporter:SetScript("OnUpdate", function(self, elapsed)
        PTR_IssueReporter.Data.lastSubmitTime = PTR_IssueReporter.Data.lastSubmitTime or 0
        if (PTR_IssueReporter.Data.lastSubmitTime > 0) then
            PTR_IssueReporter.Data.lastSubmitTime = PTR_IssueReporter.Data.lastSubmitTime - elapsed
        end
    end)

    if C_Glue.IsOnGlueScreen() then
        PTR_IssueReporter.CreateGlueView()
    else
        PTR_IssueReporter.CreateInGameMenu()
    end

    --behaviors
    PTR_IssueReporter.AddDrag(PTR_IssueReporter)
    PTR_IssueReporter:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local left, bottom = self:GetRect()
        Blizzard_PTRIssueReporter_Saved.x = left
        Blizzard_PTRIssueReporter_Saved.y = bottom
        if not(C_Glue.IsOnGlueScreen()) then
            PTR_IssueReporter.Reminder(false, PTR_IssueReporter.Confused, PTR_IssueReporter.ReportBug)
        end
    end)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.AddBorder(frame)
    frame.Border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.Border:SetFrameStrata(frame:GetFrameStrata(), frame:GetFrameLevel() + 1)
    frame.Border:SetPoint("TOPLEFT", frame, "TOPLEFT", -4, 4)
    frame.Border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 4, -4)
    frame.Border:SetBackdrop(BACKDROP_WATERMARK_DIALOG_0_16)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.AddTooltip(frame, title, text, anchor, minWidth, owner, x, y)
    frame:SetScript("OnEnter", function(self)
        tooltip:SetOwner(owner or self, anchor or "ANCHOR_RIGHT", x or 0, y or 0);
        tooltip:SetText(title, 1, 1, 1, true);
        tooltip:AddLine(text, nil, nil, nil, true);
        tooltip:SetMinimumWidth(minWidth or 100);
        tooltip:Show()
    end)
    frame:SetScript("OnLeave", function(self)
        tooltip:Hide()
    end)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.AddDrag(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self,button)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self,button)
        self:StopMovingOrSizing()
    end)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.AddInfoButton(frame, corner)
    if (not frame.InfoButton) then
        frame.InfoButton = CreateFrame("Button", nil, frame)
        frame.InfoButton:SetSize(20,20)
        frame.InfoButton:SetNormalTexture(PTR_IssueReporter.Assets.InfoIcon)
        frame.InfoButton:SetHighlightTexture(PTR_IssueReporter.Assets.InfoIconHighlight, "ADD")
        frame.InfoButton:SetPoint("CENTER", frame, corner or "TOPLEFT")
        frame.InfoButton:SetFrameStrata(frame:GetFrameStrata(), frame:GetFrameLevel() + 1)
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.AddBackground(frame, texturePath)
    if (not frame.Background) then
        frame.Background = frame:CreateTexture()
        frame.Background:SetPoint("TOPLEFT", frame, "TOPLEFT")
        frame.Background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
        frame.Background:SetVertTile(true)
        frame.Background:SetHorizTile(true)
        frame.Background:SetTexture(texturePath, true, true)
        frame.Background:SetDrawLayer("ARTWORK")
    end
end
----------------------------------------------------------------------------------------------------
PTR_IssueReporter.BugTooltipString = "|c0042b1fePress %s to submit an issue for this %s"
PTR_IssueReporter.BugTooltipPartialString = "to submit an issue for this"
PTR_IssueReporter.MissingBindTooltipString = "|c0042b1feThe 'Open Issue Report' keybind is not bound.\nBind via the PTR section in the Key Bindings Menu."
PTR_IssueReporter.CurrentTooltipSurvey = {}
PTR_IssueReporter.TooltipFrames = {}
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetCurrentTooltipReport(tooltipFrame, tooltipType, tooltipID, tooltipName, tooltipAdditional)
    if (PTR_IssueReporter.Data.RegisteredSurveys.Tooltip[tooltipType]) then
        local currentTooltipSurvey = {
            Frame = tooltipFrame,
            Survey = PTR_IssueReporter.Data.RegisteredSurveys.Tooltip[tooltipType],
            DataPackage = {
                ID = tooltipID,
                Name = tooltipName,
                Additional = tooltipAdditional
            },            
        }
        PTR_IssueReporter.CurrentTooltipSurvey = currentTooltipSurvey
        
        if not(PTR_IssueReporter.TooltipFrames[tooltipFrame]) then -- We don't want to hookscript every time Current Tooltip is set
            PTR_IssueReporter.TooltipFrames[tooltipFrame] = true
            tooltipFrame:HookScript("OnHide", PTR_IssueReporter.TooltipHidden)
        end
        
        return true
    else
        return false
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.TooltipHidden(tooltip)
    if (PTR_IssueReporter.CurrentTooltipSurvey) and (PTR_IssueReporter.CurrentTooltipSurvey.Frame == tooltip) then
        PTR_IssueReporter.CurrentTooltipSurvey = {}
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.HookIntoTooltip(tooltip, tooltipType, tooltipID, tooltipName, noExtraLine, clearAllLines, tooltipAdditional)    
    if (tooltipType) and (tooltipID) then        
        local tooltipText

        if (PTR_IssueReporter.GetKeybind() ~= "") then
            tooltipText = string.format(PTR_IssueReporter.BugTooltipString, PTR_IssueReporter.GetKeybind(), tooltipType)
        else
            tooltipText = PTR_IssueReporter.MissingBindTooltipString
        end
        -- Check if we already added to this tooltip. Happens on the talent frame
        local found = false
        for i = 1,15 do
            local frame = _G[tooltip:GetName() .. "TextLeft" .. i]
            local text
            if frame then text = frame:GetText() end
            if (text) then
                -- Sometimes a tooltip is set two different ways by blizzard UI, for example SetTalent and SetSpell will be both be fired, we want to make sure we are only adding 1 line
                local contains = string.gmatch(text, PTR_IssueReporter.BugTooltipPartialString)() 
                if (contains) then
                    found = true
                    break
                end
            end            
        end
        
        -- Make sure we only display the tooltip text on one tooltip at a time and that the tooltip is registered to a report
        if (tooltip == ItemRefTooltip) or not (ItemRefTooltip:IsShown()) then 
            if not (found) then          
                local tooltipSet = PTR_IssueReporter.SetCurrentTooltipReport(tooltip, tooltipType, tooltipID, tooltipName, tooltipAdditional)
                if (tooltipSet) then
                    if (clearAllLines) and (tooltip.ClearLines) then
                        tooltip:ClearLines()
                    end
                    
                    if not (noExtraLine) then
                        tooltip:AddLine(" ")
                    end
                    tooltip:AddLine(tooltipText)
                    tooltip:Show()
                end                
            end
        end
    end
end
----------------------------------------------------------------------------------------------------