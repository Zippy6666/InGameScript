    -- Run autorun file
if file.Exists("inscautorun.txt", "DATA") then
    RunString( file.Read("inscautorun.txt"), "InGameScript_Server", false )
end


    -- SERVER
if SERVER then

    util.AddNetworkString("INSC_Server")

    net.Receive("INSC_Server", function()

        local msg = RunString( net.ReadString(), "InGameScript_Server", false )

        if msg then
            PrintMessage(HUD_PRINTTALK, msg)
        end

    end)

end


    -- CLIENT
if CLIENT then

    local function INSC( title, text, close, forcerealm, filename )
        
        -- Only superadmins are allowed
        if !LocalPlayer():IsSuperAdmin() then return end


        text = text or ""


        local notepadFrame = vgui.Create("DFrame")
        local executeButton = vgui.Create("DButton", notepadFrame)
        local notepad = vgui.Create("DTextEntry", notepadFrame)
        local RealmDropdown = !forcerealm && vgui.Create("DComboBox", notepadFrame)

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

        notepad:Dock(FILL)
        notepad:SetMultiline(true)
        notepad:SetFont("TargetID")
        notepad:SetTextColor(Color(180, 180, 160))
        notepad:SetText(text)
        notepad:SetTabbingDisabled( true )
        function notepad:OnChange()

            local inptext = notepad:GetText()

            if inptext && #inptext >= 1 then
                executeButton:SetEnabled(true)
            else
                executeButton:SetEnabled(false)
            end

        end
        function notepad:GetAutoComplete( inptext )
            return {inptext, "ass"}
        end


        executeButton:Dock(BOTTOM)
        executeButton:SetText("Execute Code")
        executeButton:SetEnabled(#text >= 1)
        function executeButton:DoClick()
            local realm = forcerealm or RealmDropdown:GetSelected() or "Shared"

            -- Client
            if realm == "Client" or realm == "Shared" then
                local msg = RunString( notepad:GetText(), "InGameScript", false )
                if msg then
                    chat.AddText(Color(255, 0, 0), msg)
                end
            end


            -- Server
            if realm == "Server" or realm == "Shared" then
                net.Start("INSC_Server")
                net.WriteString(notepad:GetText())
                net.SendToServer()
            end


            -- Close frame
            if close then
                notepadFrame:Close()
            end

            -- File save
            if filename then
                file.Write(filename, text)
            end
        end


    end



    local function GetINSCAutorun( name )

        if !file.Exists(name, "DATA") then
            file.Write(name, 'print("sup")')
        end

        return file.Read(name)

    end



    hook.Add("OnPlayerChat", "OpenNotepadCommand", function(ply, text)

        if ply==LocalPlayer() then

            if string.lower(text) == "!insc" then

                -- Edit script
                INSC( "In-game Script", _, true )
                return true

            elseif string.lower(text) == "!ainsc" then

                -- Edit autorun
                INSC( "In-game Autorun", GetINSCAutorun("inscautorun.txt"), true, "Shared", "inscautorun.txt"  )
                return true

            end
        end

    end)

end