-- https://wiki.facepunch.com/gmod/Global.RunString

if CLIENT then

    local function INSC( text, close, endfunc )
        
        if !LocalPlayer():IsSuperAdmin() then return end


        text = text or ""


        local notepadFrame = vgui.Create("DFrame")
        notepadFrame:SetSize(ScrW()*0.85, ScrH()*0.85)
        notepadFrame:SetTitle("In-game Script Editor")
        notepadFrame:Center()
        notepadFrame:MakePopup()

        local RealmDropdown = vgui.Create("DComboBox", notepadFrame)
        RealmDropdown:Dock(TOP)
        RealmDropdown:AddChoice("Server")
        RealmDropdown:AddChoice("Client")
        RealmDropdown:AddChoice("Shared")
        RealmDropdown:ChooseOption("Shared")

        local codeInput = vgui.Create("DTextEntry", notepadFrame)
        codeInput:Dock(FILL)
        codeInput:SetMultiline(true)
        codeInput:SetFont("TargetID")
        codeInput:SetTextColor(Color(180, 180, 160))
        codeInput:SetText(text)

        local executeButton = vgui.Create("DButton", notepadFrame)
        executeButton:Dock(BOTTOM)
        executeButton:SetText("Execute Code")


        function executeButton:DoClick()
            local msg = RunString( codeInput:GetText(), "InGameScript", false )
    
            if msg then
                chat.AddText(Color(255, 0, 0), msg)
            end

            if close then
                notepadFrame:Close()
            end

            if endfunc then
                endfunc( codeInput:GetText() )
            end
        end

    end

    local function GetINSCAutorun()
        
    end


    local function SaveINSCAutoRun( text )
        
    end


    hook.Add("OnPlayerChat", "OpenNotepadCommand", function(ply, text)

        if ply==LocalPlayer() then

            if string.lower(text) == "!insc" then
                INSC( _, true )
                return true
            elseif string.lower(text) == "!ainsc" then
                INSC( GetINSCAutorun(), true, SaveINSCAutoRun )
                return true
            end
        end

    end)

end