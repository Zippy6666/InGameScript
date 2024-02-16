

if file.Exists("inscautorun.txt", "DATA") then
    RunString( file.Read("inscautorun.txt"), "InGameScript_Server", false )
end



if SERVER then

    util.AddNetworkString("INSC_Server")

    net.Receive("INSC_Server", function()

        local msg = RunString( net.ReadString(), "InGameScript_Server", false )

        if msg then
            PrintMessage(HUD_PRINTTALK, msg)
        end

    end)

end


if CLIENT then

    local function INSC( title, text, close, endfunc, forcerealm )
        
        if !LocalPlayer():IsSuperAdmin() then return end


        text = text or ""


        local notepadFrame = vgui.Create("DFrame")
        local executeButton = vgui.Create("DButton", notepadFrame)
        local codeInput = vgui.Create("DTextEntry", notepadFrame)
        local RealmDropdown = vgui.Create("DComboBox", notepadFrame)

        notepadFrame:SetSize(ScrW()*0.85, ScrH()*0.85)
        notepadFrame:SetTitle(title)
        notepadFrame:Center()
        notepadFrame:MakePopup()

        if !forcerealm then
            RealmDropdown:Dock(TOP)
            RealmDropdown:AddChoice("Server")
            RealmDropdown:AddChoice("Client")
            RealmDropdown:AddChoice("Shared")
            RealmDropdown:ChooseOption("Shared")
        end

        codeInput:Dock(FILL)
        codeInput:SetMultiline(true)
        codeInput:SetFont("TargetID")
        codeInput:SetTextColor(Color(180, 180, 160))
        codeInput:SetText(text)
        function codeInput:OnChange()

            local inptext = codeInput:GetText()

            if inptext && #inptext >= 1 then
                executeButton:SetEnabled(true)
            else
                executeButton:SetEnabled(false)
            end

        end

        executeButton:Dock(BOTTOM)
        executeButton:SetText("Execute Code")
        executeButton:SetEnabled(#text >= 1)
        function executeButton:DoClick()
            local realm = forcerealm or RealmDropdown:GetSelected() or "Shared"

            if realm == "Client" or realm == "Shared" then
                local msg = RunString( codeInput:GetText(), "InGameScript", false )

                if msg then
                    chat.AddText(Color(255, 0, 0), msg)
                end
            end

            if realm == "Server" or realm == "Shared" then
                net.Start("INSC_Server")
                net.WriteString(codeInput:GetText())
                net.SendToServer()
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

        if !file.Exists("inscautorun.txt", "DATA") then
            file.Write("inscautorun.txt", 'print("sup")')
        end

        return file.Read("inscautorun.txt")

    end


    local function SaveINSCAutoRun( text )
        file.Write("inscautorun.txt", text)
    end


    hook.Add("OnPlayerChat", "OpenNotepadCommand", function(ply, text)

        if ply==LocalPlayer() then

            if string.lower(text) == "!insc" then
                INSC( "In-game Script", _, true )
                return true
            elseif string.lower(text) == "!ainsc" then
                INSC( "In-game Autorun", GetINSCAutorun(), true, SaveINSCAutoRun, "Shared" )
                return true
            end
        end

    end)

end