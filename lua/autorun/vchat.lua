--------------------------------------Vchat----------------------------------
--[[-------------------------------------------------------------------------
VChat Custom Usage License
Copyright (c) 2026 A-m-a2021 and V0ID 

Permission is granted to use, copy, modify, publish, and redistribute
this project and its source code for free and for non-commercial purposes.

REDISTRIBUTION REQUIREMENTS:

* Full reuploads are allowed, but you must make meaningful changes
or updates to the code project before redistributing.
* A completely unchanged copy of VChat may not be redistributed.
* Original copyright notices and this license header must remain intact.
* Any redistributed version must clearly credit the original authors.

CREDITS:
A-m-a2021 (Creator of VChat)
V0ID (Helped develop VChat)

---------------------------------------------------------------------------]]

CreateConVar("vchat_enabled", "1", FCVAR_ARCHIVE, "Enable voice chat detection for all supported NPCs", 0, 1)
CreateConVar("vchat_threshold", "0.15", FCVAR_ARCHIVE, "Mic volume threshold for voice detection", 0, 1)
CreateConVar("vchat_range", "1500", FCVAR_ARCHIVE, "Detection range in units", 0, 5000)
CreateConVar("vchat_vjbase", "1", FCVAR_ARCHIVE, "Enable VJBase SNPC support", 0, 1)
CreateConVar("vchat_drgbase", "1", FCVAR_ARCHIVE, "Enable DrGBase nextbot support", 0, 1)
CreateConVar("vchat_default", "1", FCVAR_ARCHIVE, "Enable default Source NPC support", 0, 1)
CreateConVar("vchat_debug", "0", FCVAR_ARCHIVE, "Enable debug messages", 0, 1)
CreateConVar("vchat_props", "0", FCVAR_ARCHIVE, "Enable NPC reaction to physics props (collisions)", 0, 1)
CreateConVar("vchat_doors", "0", FCVAR_ARCHIVE, "Enable NPC reaction to doors opening/closing", 0, 1)
CreateConVar("vchat_footsteps", "0", FCVAR_ARCHIVE, "Enable NPC reaction to player footsteps", 0, 1)
CreateConVar("vchat_gunshots", "0", FCVAR_ARCHIVE, "Enable NPC reaction to gunshots", 0, 1)
CreateConVar("vchat_explosions", "0", FCVAR_ARCHIVE, "Enable NPC reaction to explosions", 0, 1)
CreateConVar("vchat_textchat", "0", FCVAR_ARCHIVE, "Enable NPC reaction to player text chat messages", 0, 1)

CreateConVar("vchat_teamchat", "0", FCVAR_ARCHIVE, "Allow NPCs to react to team chat messages", 0, 1)
CreateConVar("vchat_los_required", "0", FCVAR_ARCHIVE, "Require line of sight for NPCs to react (why ?)", 0, 1)
CreateConVar("vchat_admin_immune", "0", FCVAR_ARCHIVE, "Admins are immune to NPC detection", 0, 1)
CreateConVar("vchat_props_range", "800", FCVAR_ARCHIVE, "Detection range for prop collisions", 0, 5000)
CreateConVar("vchat_doors_range", "600", FCVAR_ARCHIVE, "Detection range for doors opening/closing", 0, 5000)
CreateConVar("vchat_footsteps_range", "400", FCVAR_ARCHIVE, "Detection range for player footsteps", 0, 5000)
CreateConVar("vchat_gunshots_range", "3000", FCVAR_ARCHIVE, "Detection range for gunshots", 0, 10000)
CreateConVar("vchat_explosions_range", "4500", FCVAR_ARCHIVE, "Detection range for explosions", 0, 15000)
CreateConVar("vchat_textchat_range", "750", FCVAR_ARCHIVE, "Detection range for text chat", 0, 5000)

CreateConVar("vchat_flashlight_sound", "0", FCVAR_ARCHIVE, "Enable NPC reaction to flashlight toggle sound", 0, 1)
CreateConVar("vchat_flashlight_sound_range", "600", FCVAR_ARCHIVE, "Detection range for flashlight toggle sound", 0, 5000)

CreateConVar("vchat_emotes", "0", FCVAR_ARCHIVE, "Enable NPC reaction to ActMod emotes", 0, 1)
CreateConVar("vchat_emotes_range", "1200", FCVAR_ARCHIVE, "Detection range for emotes", 0, 5000)

CreateConVar("vchat_volume_scaling", "1", FCVAR_ARCHIVE, "Scale detection range by voice volume (louder = farther)", 0, 1)
CreateConVar("vchat_volume_scale_factor", "2.0", FCVAR_ARCHIVE, "Volume scaling multiplier for range", 0.1, 5)
CreateConVar("vchat_wall_muffle", "1", FCVAR_ARCHIVE, "Reduce detection range when walls are between source and NPC", 0, 1)
CreateConVar("vchat_wall_muffle_factor", "0.3", FCVAR_ARCHIVE, "Wall muffle range multiplier (0.3 = 30% range through walls)", 0.01, 1)
CreateConVar("vchat_underwater_muffle", "1", FCVAR_ARCHIVE, "Reduce detection range when source is underwater", 0, 1)
CreateConVar("vchat_underwater_muffle_factor", "0.3", FCVAR_ARCHIVE, "Underwater muffle range multiplier (0.3 = 30% range while submerged)", 0.01, 1)
CreateConVar("vchat_ignore_height", "0", FCVAR_ARCHIVE, "Ignore vertical distance in detection range (use 2D horizontal only)", 0, 1)
CreateConVar("vchat_mediaplayer", "0", FCVAR_ARCHIVE, "Enable NPC reaction to Media Player  playback", 0, 1)
CreateConVar("vchat_mediaplayer_range", "1000", FCVAR_ARCHIVE, "Detection range for Media Player ", 0, 5000)
CreateConVar("vchat_mediaplayer_cooldown", "30", FCVAR_ARCHIVE, "Seconds before an NPC can react to the same media player again", 0, 300)

if SERVER then
    util.AddNetworkString("VChatVoiceState")
    util.AddNetworkString("VChatVolume")
end

if CLIENT then
    local speaking = false
    local isReady  = false
    local lastVolume = 0

    local function SetState(newState, volume)
        if not isReady then return end
        if not GetConVar("vchat_enabled"):GetBool() then return end
        if speaking == newState then
            if newState and volume ~= lastVolume then
                lastVolume = volume
                net.Start("VChatVolume")
                    net.WriteFloat(volume)
                net.SendToServer()
            end
            return
        end
        speaking = newState
        lastVolume = volume or 0
        net.Start("VChatVoiceState")
            net.WriteBool(speaking)
            net.WriteFloat(lastVolume)
        net.SendToServer()
    end

    hook.Add("Think", "VChatVoiceCheck", function()
        local lp = LocalPlayer()
        if not IsValid(lp) then return end
        local vol = lp:VoiceVolume()
        SetState(vol > GetConVar("vchat_threshold"):GetFloat(), vol)
    end)

    hook.Add("InitPostEntity", "VChatVoiceReset", function()
        speaking = false
        isReady  = false
        lastVolume = 0
        timer.Simple(3, function() isReady = true end)
    end)

    surface.CreateFont("vchat_header_font", {
        font = "Roboto",
        size = 25,
        weight = 650,
        tall = 15,
        dropshadow = 1,
    })

    hook.Add("PopulateToolMenu", "VChatSettings", function()
        spawnmenu.AddToolMenuOption("Utilities", "VChat", "VChatSettings", "VChat Settings", "", "", function(panel)

            local voiceHeader = panel:ControlHelp("VOICE CHAT SETTINGS")
            voiceHeader:SetFont("vchat_header_font")
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Enabled", Command = "vchat_enabled" })
            panel:AddControl("Label", {Text = "Enable voice chat detection for all supported NPCs"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Debug Mode", Command = "vchat_debug" })
            panel:AddControl("Label", {Text = "Show console debug messages for all NPC reactions"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("Slider", { Label = "Mic Threshold", Command = "vchat_threshold", Type = "Float", Min = "0", Max = "1" })
            panel:AddControl("Label", {Text = "Mic volume required to trigger NPC reaction"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("Slider", { Label = "Detection Range", Command = "vchat_range", Type = "Int", Min = "0", Max = "5000" })
            panel:AddControl("Label", {Text = "Maximum range in perfect conditions (no walls, not underwater, max volume)"})
            panel:AddControl("Label", {Text = "Wall muffle and underwater muffle reduce this range dynamically"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Require Line of Sight", Command = "vchat_los_required" })
            panel:AddControl("Label", {Text = "NPCs must see the sound source to react (why ?)"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Admin Immunity", Command = "vchat_admin_immune" })
            panel:AddControl("Label", {Text = "Admins are immune to NPC voice detection"})
            panel:AddControl("Label", {Text = ""})

            local resetVoiceBtn = panel:Button("Reset Voice Settings")
            resetVoiceBtn.DoClick = function()
                RunConsoleCommand("vchat_enabled", "1")
                RunConsoleCommand("vchat_threshold", "0.15")
                RunConsoleCommand("vchat_range", "1500")
                RunConsoleCommand("vchat_debug", "0")
                RunConsoleCommand("vchat_los_required", "0")
                RunConsoleCommand("vchat_admin_immune", "0")
                chat.AddText(Color(100, 200, 255), "[VChat] Voice settings reset to defaults")
            end

            panel:AddControl("Label", {Text = ""})
            panel:AddControl("Label", {Text = ""})

            local soundHeader = panel:ControlHelp("SOUND FEATURES")
            soundHeader:SetFont("vchat_header_font")
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Volume Scaling", Command = "vchat_volume_scaling" })
            panel:AddControl("Label", {Text = "Scale detection range by voice volume - louder voice = farther detection"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("Slider", { Label = "Volume Scale Factor", Command = "vchat_volume_scale_factor", Type = "Float", Min = "0.1", Max = "5" })
            panel:AddControl("Label", {Text = "Multiplier for how much volume affects detection range"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Wall Muffle", Command = "vchat_wall_muffle" })
            panel:AddControl("Label", {Text = "Reduce detection range when walls block the sound path"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("Slider", { Label = "Wall Muffle Factor", Command = "vchat_wall_muffle_factor", Type = "Float", Min = "0.01", Max = "1" })
            panel:AddControl("Label", {Text = "How much walls reduce range (0.3 = 30% range through walls)"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Underwater Muffle", Command = "vchat_underwater_muffle" })
            panel:AddControl("Label", {Text = "Reduce detection range when the player is underwater"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("Slider", { Label = "Underwater Muffle Factor", Command = "vchat_underwater_muffle_factor", Type = "Float", Min = "0.01", Max = "1" })
            panel:AddControl("Label", {Text = "How much underwater reduces range (0.3 = 30% range while submerged)"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Ignore Height", Command = "vchat_ignore_height" })
            panel:AddControl("Label", {Text = "Use horizontal distance only - NPCs on other floors hear you as if on same floor"})
            panel:AddControl("Label", {Text = ""})

            local resetSoundBtn = panel:Button("Reset Sound Features")
            resetSoundBtn.DoClick = function()
                RunConsoleCommand("vchat_volume_scaling", "1")
                RunConsoleCommand("vchat_volume_scale_factor", "2.0")
                RunConsoleCommand("vchat_wall_muffle", "1")
                RunConsoleCommand("vchat_wall_muffle_factor", "0.3")
                RunConsoleCommand("vchat_underwater_muffle", "1")
                RunConsoleCommand("vchat_underwater_muffle_factor", "0.3")
                RunConsoleCommand("vchat_ignore_height", "0")
                chat.AddText(Color(100, 200, 255), "[VChat] Sound features reset to defaults")
            end

            panel:AddControl("Label", {Text = ""})
            panel:AddControl("Label", {Text = ""})

            local npcHeader = panel:ControlHelp("NPC BASE SUPPORT")
            npcHeader:SetFont("vchat_header_font")
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "DrGBase NextBots", Command = "vchat_drgbase" })
            panel:AddControl("Label", {Text = "Enable reaction for DrGBase nextbots"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "VJBase SNPCs", Command = "vchat_vjbase" })
            panel:AddControl("Label", {Text = "Enable reaction for VJBase SNPCs"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Default Source NPCs", Command = "vchat_default" })
            panel:AddControl("Label", {Text = "Enable reaction for default Source engine NPCs"})
            panel:AddControl("Label", {Text = ""})

            local resetNPCBtn = panel:Button("Reset NPC Settings")
            resetNPCBtn.DoClick = function()
                RunConsoleCommand("vchat_drgbase", "1")
                RunConsoleCommand("vchat_vjbase", "1")
                RunConsoleCommand("vchat_default", "1")
                chat.AddText(Color(100, 200, 255), "[VChat] NPC settings reset to defaults")
            end

            panel:AddControl("Label", {Text = ""})
            panel:AddControl("Label", {Text = ""})

            local generalHeader = panel:ControlHelp("GENERAL HEARING (OPTIONAL)")
            generalHeader:SetFont("vchat_header_font")
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Prop Collisions", Command = "vchat_props" })
            panel:AddControl("Label", {Text = "NPCs react when physics props are thrown/dropped"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("Slider", { Label = "Prop Range", Command = "vchat_props_range", Type = "Int", Min = "0", Max = "5000" })
            panel:AddControl("Label", {Text = "Detection range for prop collisions"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Doors", Command = "vchat_doors" })
            panel:AddControl("Label", {Text = "NPCs react when doors open or close"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("Slider", { Label = "Door Range", Command = "vchat_doors_range", Type = "Int", Min = "0", Max = "5000" })
            panel:AddControl("Label", {Text = "Detection range for door sounds"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Footsteps", Command = "vchat_footsteps" })
            panel:AddControl("Label", {Text = "NPCs react to player footsteps"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("Slider", { Label = "Footstep Range", Command = "vchat_footsteps_range", Type = "Int", Min = "0", Max = "5000" })
            panel:AddControl("Label", {Text = "Detection range for footsteps"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Gunshots", Command = "vchat_gunshots" })
            panel:AddControl("Label", {Text = "NPCs react to player gunshots"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("Slider", { Label = "Gunshot Range", Command = "vchat_gunshots_range", Type = "Int", Min = "0", Max = "10000" })
            panel:AddControl("Label", {Text = "Detection range for gunshots"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Explosions", Command = "vchat_explosions" })
            panel:AddControl("Label", {Text = "NPCs react to explosions"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("Slider", { Label = "Explosion Range", Command = "vchat_explosions_range", Type = "Int", Min = "0", Max = "15000" })
            panel:AddControl("Label", {Text = "Detection range for explosions"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Text Chat", Command = "vchat_textchat" })
            panel:AddControl("Label", {Text = "NPCs react when players type in text chat"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("Slider", { Label = "Text Chat Range", Command = "vchat_textchat_range", Type = "Int", Min = "0", Max = "5000" })
            panel:AddControl("Label", {Text = "Detection range for text chat"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Flashlight Sound", Command = "vchat_flashlight_sound" })
            panel:AddControl("Label", {Text = "NPCs react when they HEAR the flashlight toggle click"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("Slider", { Label = "Flashlight Sound Range", Command = "vchat_flashlight_sound_range", Type = "Int", Min = "0", Max = "5000" })
            panel:AddControl("Label", {Text = "Detection range for flashlight toggle sound"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "ActMod Emotes", Command = "vchat_emotes" })
            panel:AddControl("Label", {Text = "NPCs react when players perform ActMod emotes/dances"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("Slider", { Label = "Emote Range", Command = "vchat_emotes_range", Type = "Int", Min = "0", Max = "5000" })
            panel:AddControl("Label", {Text = "Detection range for emotes"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Media Player ", Command = "vchat_mediaplayer" })
            panel:AddControl("Label", {Text = "NPCs react when Media Player screens play audio/video"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("Slider", { Label = "Media Player Range", Command = "vchat_mediaplayer_range", Type = "Int", Min = "0", Max = "5000" })
            panel:AddControl("Label", {Text = "Detection range for Media Player playback"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("Slider", { Label = "Media Player Cooldown", Command = "vchat_mediaplayer_cooldown", Type = "Int", Min = "0", Max = "300" })
            panel:AddControl("Label", {Text = "Seconds before same NPC reacts to same TV again"})
            panel:AddControl("Label", {Text = ""})

            panel:AddControl("CheckBox", { Label = "Team Chat", Command = "vchat_teamchat" })
            panel:AddControl("Label", {Text = "Allow NPCs to react to team chat messages"})
            panel:AddControl("Label", {Text = ""})

            local resetGeneralBtn = panel:Button("Reset General Hearing")
            resetGeneralBtn.DoClick = function()
                RunConsoleCommand("vchat_props", "0")
                RunConsoleCommand("vchat_doors", "0")
                RunConsoleCommand("vchat_footsteps", "0")
                RunConsoleCommand("vchat_gunshots", "0")
                RunConsoleCommand("vchat_explosions", "0")
                RunConsoleCommand("vchat_textchat", "0")
                RunConsoleCommand("vchat_teamchat", "0")
                RunConsoleCommand("vchat_props_range", "800")
                RunConsoleCommand("vchat_doors_range", "600")
                RunConsoleCommand("vchat_footsteps_range", "400")
                RunConsoleCommand("vchat_gunshots_range", "3000")
                RunConsoleCommand("vchat_explosions_range", "4500")
                RunConsoleCommand("vchat_textchat_range", "750")
                RunConsoleCommand("vchat_flashlight_sound", "0")
                RunConsoleCommand("vchat_flashlight_sound_range", "600")
                RunConsoleCommand("vchat_emotes", "0")
                RunConsoleCommand("vchat_emotes_range", "1200")
                RunConsoleCommand("vchat_mediaplayer", "0")
                RunConsoleCommand("vchat_mediaplayer_range", "1000")
                RunConsoleCommand("vchat_mediaplayer_cooldown", "30")
                chat.AddText(Color(100, 200, 255), "[VChat] General hearing settings reset to defaults")
            end

            panel:AddControl("Label", {Text = ""})
            panel:AddControl("Label", {Text = ""})

            local resetAllBtn = panel:Button("Reset ALL Settings to Defaults")
            resetAllBtn.DoClick = function()
                RunConsoleCommand("vchat_enabled", "1")
                RunConsoleCommand("vchat_threshold", "0.15")
                RunConsoleCommand("vchat_range", "1500")
                RunConsoleCommand("vchat_vjbase", "1")
                RunConsoleCommand("vchat_drgbase", "1")
                RunConsoleCommand("vchat_default", "1")
                RunConsoleCommand("vchat_debug", "0")
                RunConsoleCommand("vchat_props", "0")
                RunConsoleCommand("vchat_doors", "0")
                RunConsoleCommand("vchat_footsteps", "0")
                RunConsoleCommand("vchat_gunshots", "0")
                RunConsoleCommand("vchat_explosions", "0")
                RunConsoleCommand("vchat_textchat", "0")
                RunConsoleCommand("vchat_teamchat", "0")
                RunConsoleCommand("vchat_los_required", "0")
                RunConsoleCommand("vchat_admin_immune", "0")
                RunConsoleCommand("vchat_props_range", "800")
                RunConsoleCommand("vchat_doors_range", "600")
                RunConsoleCommand("vchat_footsteps_range", "400")
                RunConsoleCommand("vchat_gunshots_range", "3000")
                RunConsoleCommand("vchat_explosions_range", "4500")
                RunConsoleCommand("vchat_textchat_range", "750")
                RunConsoleCommand("vchat_flashlight_sound", "0")
                RunConsoleCommand("vchat_flashlight_sound_range", "600")
                RunConsoleCommand("vchat_emotes", "0")
                RunConsoleCommand("vchat_emotes_range", "1200")
                RunConsoleCommand("vchat_volume_scaling", "1")
                RunConsoleCommand("vchat_volume_scale_factor", "2.0")
                RunConsoleCommand("vchat_wall_muffle", "1")
                RunConsoleCommand("vchat_wall_muffle_factor", "0.3")
                RunConsoleCommand("vchat_underwater_muffle", "1")
                RunConsoleCommand("vchat_underwater_muffle_factor", "0.3")
                RunConsoleCommand("vchat_ignore_height", "0")
                RunConsoleCommand("vchat_mediaplayer", "0")
                RunConsoleCommand("vchat_mediaplayer_range", "1000")
                RunConsoleCommand("vchat_mediaplayer_cooldown", "30")
                chat.AddText(Color(255, 100, 100), "[VChat] ALL settings reset to defaults!")
            end

        end)
    end)
end

if SERVER then
    VChat = VChat or {}
    VChat.SoundBehaviors = VChat.SoundBehaviors or {}
    VChat.SoundHistory = VChat.SoundHistory or {}
    VChat.MutedPlayers = VChat.MutedPlayers or {}
	

    VChat.NPCSourceCooldowns = VChat.NPCSourceCooldowns or {}
	VChat.MP_LastPlayingState = VChat.MP_LastPlayingState or {}

    function VChat.IsNPCOnSourceCooldown(npc, sourceId)
        if not sourceId then return false end
        if not IsValid(npc) then return false end
        local sid = npc:EntIndex() .. "_" .. tostring(sourceId)
        local expire = VChat.NPCSourceCooldowns[sid]
        if expire and CurTime() < expire then return true end
        return false
    end

    function VChat.SetNPCSourceCooldown(npc, sourceId, duration)
        if not sourceId or not IsValid(npc) then return end
        local sid = npc:EntIndex() .. "_" .. tostring(sourceId)
        VChat.NPCSourceCooldowns[sid] = CurTime() + duration
    end
	
	local function ClearNPCCooldownsForTV(sourceId)
    if not sourceId then return end
    local suffix = "_" .. tostring(sourceId)
    for key, _ in pairs(VChat.NPCSourceCooldowns) do
        if string.sub(key, -#suffix) == suffix then
            VChat.NPCSourceCooldowns[key] = nil
        end
      end
    end

    local function Debug(msg)
        if not GetConVar("vchat_debug"):GetBool() then return end
        local t = os.date("%H:%M:%S")
        print("["..t.."] [VChat] "..msg)
    end

    local function GetDistance(a, b)
        if not isvector(a) or not isvector(b) then return 0 end
        if GetConVar("vchat_ignore_height"):GetBool() then
            local dx = a.x - b.x
            local dy = a.y - b.y
            return math.sqrt(dx * dx + dy * dy)
        end
        return a:Distance(b)
    end

    VChat.NPCBlacklist = VChat.NPCBlacklist or {}

    function VChat.AddBlacklist(class)
        if not isstring(class) then return false end
        VChat.NPCBlacklist[class] = true
        return true
    end

    function VChat.RemoveBlacklist(class)
        if not isstring(class) then return false end
        VChat.NPCBlacklist[class] = nil
        return true
    end

    function VChat.IsBlacklisted(class)
        if not isstring(class) then return false end
        return VChat.NPCBlacklist[class] == true
    end

    VChat.PlayerImmunity = VChat.PlayerImmunity or {}

    function VChat.IsPlayerImmune(ply)
        if not IsValid(ply) or not ply:IsPlayer() then return true end
        if VChat.PlayerImmunity[ply:SteamID64()] then return true end
        if GetConVar("vchat_admin_immune"):GetBool() and ply:IsAdmin() then return true end
        if ply:IsFlagSet(FL_NOTARGET) then return true end
        return false
    end

    VChat.SoundFeatures = VChat.SoundFeatures or {}
    VChat.SoundFeatures.Custom = VChat.SoundFeatures.Custom or {}

    function VChat.SoundFeatures.GetVolumeScaledRange(baseRange, volume)
        if not GetConVar("vchat_volume_scaling"):GetBool() then return baseRange end
        if not volume then return baseRange end
        local factor = GetConVar("vchat_volume_scale_factor"):GetFloat()
        return baseRange * math.Clamp(volume * factor, 0.1, factor)
    end

    function VChat.SoundFeatures.ApplyWallMuffle(range, sourcePos, listenerPos, sourceEnt)
        if not GetConVar("vchat_wall_muffle"):GetBool() then return range end

        local tr = util.TraceLine({
            start = sourcePos,
            endpos = listenerPos,
            filter = function(ent)
                return ent ~= sourceEnt and not ent:IsPlayer() and not ent:IsNPC() and ent:GetClass() ~= "prop_physics"
            end
        })

        if tr.Hit and (tr.MatType or 0) ~= MAT_GRATE then
            local muffleFactor = GetConVar("vchat_wall_muffle_factor"):GetFloat()
            range = range * muffleFactor
        end

        return range
    end

    function VChat.SoundFeatures.ApplyUnderwaterMuffle(range, sourceEnt)
        if not GetConVar("vchat_underwater_muffle"):GetBool() then return range end
        if not IsValid(sourceEnt) then return range end
        if not sourceEnt:IsPlayer() then return range end

        local waterLevel = sourceEnt:WaterLevel()
        if waterLevel >= 2 then
            local muffleFactor = GetConVar("vchat_underwater_muffle_factor"):GetFloat()
            range = range * muffleFactor
        end

        return range
    end

    function VChat.SoundFeatures.GetEffectiveRange(baseRange, volume, sourcePos, listenerPos, sourceEnt)
        local range = baseRange

        range = VChat.SoundFeatures.GetVolumeScaledRange(range, volume)
        range = VChat.SoundFeatures.ApplyWallMuffle(range, sourcePos, listenerPos, sourceEnt)
        range = VChat.SoundFeatures.ApplyUnderwaterMuffle(range, sourceEnt)

        for name, func in pairs(VChat.SoundFeatures.Custom) do
            if isfunction(func) then
                local ok, result = pcall(func, range, sourcePos, listenerPos, sourceEnt, volume)
                if ok and isnumber(result) then
                    range = result
                end
            end
        end

        return range
    end

    function VChat.ReactAllNPCs(sourcePos, baseRange, sourceEnt, soundType, volume, voiceOnly, sourceId)
        if voiceOnly and not GetConVar("vchat_enabled"):GetBool() then return 0 end
        if GetConVar("ai_disabled"):GetBool() then return 0 end
        if GetConVar("ai_ignoreplayers"):GetBool() then
            if IsValid(sourceEnt) and sourceEnt:IsPlayer() then return 0 end
        end
        if IsValid(sourceEnt) and sourceEnt:IsPlayer() and VChat.IsPlayerImmune(sourceEnt) then return 0 end
        if IsValid(sourceEnt) and sourceEnt:IsPlayer() and VChat.IsPlayerMuted(sourceEnt) then return 0 end

        VChat.RecordSound(sourceEnt, soundType, sourcePos, baseRange)

        local doDrG     = GetConVar("vchat_drgbase"):GetBool()
        local doVJ      = GetConVar("vchat_vjbase"):GetBool()
        local doDefault = GetConVar("vchat_default"):GetBool()

        local soundData = {
            Pos       = sourcePos,
            Entity    = sourceEnt,
            Volume    = volume or 1,
            Channel   = CHAN_VOICE,
            SoundName = soundType or "custom",
        }

        local reactedCount = 0
        local sourceName = (IsValid(sourceEnt) and sourceEnt:IsPlayer() and sourceEnt:Nick()) or (IsValid(sourceEnt) and sourceEnt:GetClass()) or "unknown"

        local function CheckLOS(npc, pos)
            if not GetConVar("vchat_los_required"):GetBool() then return true end
            local tr = util.TraceLine({
                start = npc:EyePos(),
                endpos = pos,
                mask = MASK_VISIBLE_AND_NPCS,
                filter = npc
            })
            return tr.Fraction == 1
        end

        if doDrG and DrGBase then
            for _, bot in ipairs(DrGBase.GetNextbots()) do
                if not IsValid(bot) then continue end
                local effRange = VChat.SoundFeatures.GetEffectiveRange(baseRange, volume, sourcePos, bot:GetPos(), sourceEnt)
                if GetDistance(bot:GetPos(), sourcePos) > effRange then continue end
                if IsValid(bot:GetPossessor()) then continue end
                if VChat.NPCBlacklist[bot:GetClass()] then continue end
                if not CheckLOS(bot, sourcePos) then continue end

                local preResult = hook.Run("VChat_PreNPCReact", bot, sourceEnt, soundType, sourcePos, effRange)
                if preResult == false then continue end

                local cooldown = VChat.GetNPCReactCooldown(bot:GetClass())
                if cooldown > 0 and bot.VChat_NextReact and CurTime() < bot.VChat_NextReact then continue end
                if VChat.IsNPCOnSourceCooldown(bot, sourceId) then continue end
                bot.VChat_NextReact = CurTime() + cooldown

                bot.VChat_LastHeardSource = sourceEnt
                bot.VChat_LastHeardTime = CurTime()

                local behavior = VChat.SoundBehaviors[bot:GetClass()]
                if behavior and isfunction(behavior) then
                    local ok, result = pcall(behavior, bot, sourceEnt, soundType, sourcePos)
                    if ok and result ~= false then
                        reactedCount = reactedCount + 1
                        VChat.SetNPCSourceCooldown(bot, sourceId, GetConVar("vchat_mediaplayer_cooldown"):GetFloat())
                    end
                else
                    bot:OnSound(sourceEnt, soundData)
                    local dist = math.Round(GetDistance(bot:GetPos(), sourcePos))
                    Debug(bot:GetClass() .. " heard " .. sourceName .. " - distance " .. dist .. " units (effRange: " .. math.Round(effRange) .. ")")
                    reactedCount = reactedCount + 1
                    VChat.SetNPCSourceCooldown(bot, sourceId, GetConVar("vchat_mediaplayer_cooldown"):GetFloat())
                end
            end
        end

        if doVJ or doDefault then
            for _, ent in ipairs(ents.FindInSphere(sourcePos, baseRange)) do
                if not IsValid(ent) then continue end
                if ent == sourceEnt then continue end
                if ent:IsFlagSet(FL_NOTARGET) then continue end

                local effRange = VChat.SoundFeatures.GetEffectiveRange(baseRange, volume, sourcePos, ent:GetPos(), sourceEnt)

                if doVJ and ent.IsVJBaseSNPC then
                    if GetDistance(ent:GetPos(), sourcePos) <= effRange then
                        if not CheckLOS(ent, sourcePos) then continue end
                        if VChat.NPCBlacklist[ent:GetClass()] then continue end

                        local preResult = hook.Run("VChat_PreNPCReact", ent, sourceEnt, soundType, sourcePos, effRange)
                        if preResult == false then continue end

                        local cooldown = VChat.GetNPCReactCooldown(ent:GetClass())
                        if cooldown > 0 and ent.VChat_NextReact and CurTime() < ent.VChat_NextReact then continue end
                        if VChat.IsNPCOnSourceCooldown(ent, sourceId) then continue end
                        ent.VChat_NextReact = CurTime() + cooldown

                        ent.VChat_LastHeardSource = sourceEnt
                        ent.VChat_LastHeardTime = CurTime()

                        local behavior = VChat.SoundBehaviors[ent:GetClass()]
                        if behavior and isfunction(behavior) then
                            local ok, result = pcall(behavior, ent, sourceEnt, soundType, sourcePos)
                            if ok and result ~= false then
                                reactedCount = reactedCount + 1
                                VChat.SetNPCSourceCooldown(ent, sourceId, GetConVar("vchat_mediaplayer_cooldown"):GetFloat())
                            end
                            continue
                        elseif behavior and istable(behavior) then
                            if behavior.schedule then ent:SetSchedule(behavior.schedule) end
                            if behavior.vjInvestigate ~= false then
                                local npcData = ent:GetTable()
                                npcData.VJ_SD_InvestLevel = behavior.investLevel or 500
                                npcData.VJ_SD_InvestTime = CurTime()
                            end
                            if ent.OnInvestigate then pcall(ent.OnInvestigate, ent, sourceEnt) end
                            if not IsValid(ent:GetEnemy()) and behavior.moveToPos ~= false then
                                ent:SetLastPosition(sourcePos)
                            end
                            reactedCount = reactedCount + 1
                            VChat.SetNPCSourceCooldown(ent, sourceId, GetConVar("vchat_mediaplayer_cooldown"):GetFloat())
                            continue
                        end

                        local npcData = ent:GetTable()
                        if npcData.CanInvestigate == false then continue end

                        npcData.VJ_SD_InvestLevel = 500
                        npcData.VJ_SD_InvestTime  = CurTime()

                        if ent.OnInvestigate then
                            pcall(ent.OnInvestigate, ent, sourceEnt)
                        end

                        if not IsValid(ent:GetEnemy()) then
                            ent:SetLastPosition(sourcePos)
                            ent:SetSchedule(SCHED_FORCED_GO_RUN)
                        end

                        local dist = math.Round(GetDistance(ent:GetPos(), sourcePos))
                        Debug(ent:GetClass() .. " investigated " .. sourceName .. " - distance " .. dist .. " units (effRange: " .. math.Round(effRange) .. ")")
                        reactedCount = reactedCount + 1
                        VChat.SetNPCSourceCooldown(ent, sourceId, GetConVar("vchat_mediaplayer_cooldown"):GetFloat())
                    end
                elseif doDefault and ent:IsNPC() then
                    if GetDistance(ent:GetPos(), sourcePos) <= effRange then
                        if not CheckLOS(ent, sourcePos) then continue end
                        if VChat.NPCBlacklist[ent:GetClass()] then continue end

                        local preResult = hook.Run("VChat_PreNPCReact", ent, sourceEnt, soundType, sourcePos, effRange)
                        if preResult == false then continue end

                        local cooldown = VChat.GetNPCReactCooldown(ent:GetClass())
                        if cooldown > 0 and ent.VChat_NextReact and CurTime() < ent.VChat_NextReact then continue end
                        if VChat.IsNPCOnSourceCooldown(ent, sourceId) then continue end
                        ent.VChat_NextReact = CurTime() + cooldown

                        ent.VChat_LastHeardSource = sourceEnt
                        ent.VChat_LastHeardTime = CurTime()

                        local behavior = VChat.SoundBehaviors[ent:GetClass()]
                        if behavior and isfunction(behavior) then
                            local ok, result = pcall(behavior, ent, sourceEnt, soundType, sourcePos)
                            if ok and result ~= false then
                                reactedCount = reactedCount + 1
                                VChat.SetNPCSourceCooldown(ent, sourceId, GetConVar("vchat_mediaplayer_cooldown"):GetFloat())
                            end
                            continue
                        elseif behavior and istable(behavior) then
                            if behavior.schedule then ent:SetSchedule(behavior.schedule) end
                            if IsValid(sourceEnt) and sourceEnt:IsPlayer() and behavior.updateEnemyMemory ~= false then
                                ent:UpdateEnemyMemory(sourceEnt, sourcePos)
                            end
                            if behavior.moveToPos ~= false then
                                ent:SetLastPosition(sourcePos)
                            end
                            reactedCount = reactedCount + 1
                            VChat.SetNPCSourceCooldown(ent, sourceId, GetConVar("vchat_mediaplayer_cooldown"):GetFloat())
                            continue
                        end

                        sound.EmitHint(SOUND_PLAYER, sourcePos, effRange, 1.0, sourceEnt)

                        if IsValid(sourceEnt) then
                          ent:UpdateEnemyMemory(sourceEnt, sourcePos)
                        end

                        ent:SetLastPosition(sourcePos)
						if IsValid(sourceEnt) and not sourceEnt:IsPlayer() then
                            ent:SetSchedule(SCHED_FORCED_GO_RUN)
                        else
                            ent:SetSchedule(SCHED_INVESTIGATE_SOUND)
						end

                        local dist = math.Round(GetDistance(ent:GetPos(), sourcePos))
                        Debug(ent:GetClass() .. " investigating sound from " .. sourceName .. " - distance " .. dist .. " units (effRange: " .. math.Round(effRange) .. ")")
                        reactedCount = reactedCount + 1
                        VChat.SetNPCSourceCooldown(ent, sourceId, GetConVar("vchat_mediaplayer_cooldown"):GetFloat())
                    end
                end
            end
        end

        if reactedCount > 0 then
            Debug(sourceName .. " triggered " .. (soundType or "custom") .. " detection - range " .. baseRange .. " (" .. reactedCount .. " NPCs reacted)")
        end

        hook.Run("VChat_OnNPCReact", sourcePos, baseRange, sourceEnt, soundType, volume, reactedCount)

        return reactedCount
    end

    function VChat.IsPlayerMuted(ply)
        if not IsValid(ply) or not ply:IsPlayer() then return false end
        local mute = VChat.MutedPlayers[ply:SteamID64()]
        if not mute then return false end
        if mute == true then return true end
        if CurTime() < mute then return true end
        VChat.MutedPlayers[ply:SteamID64()] = nil
        return false
    end

    function VChat.RecordSound(ply, soundType, pos, range)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        local sid = ply:SteamID64()
        VChat.SoundHistory[sid] = VChat.SoundHistory[sid] or {}
        table.insert(VChat.SoundHistory[sid], {
            time = CurTime(),
            type = soundType,
            pos = pos and Vector(pos.x, pos.y, pos.z) or nil,
            range = range
        })
        while #VChat.SoundHistory[sid] > 100 do
            table.remove(VChat.SoundHistory[sid], 1)
        end
    end

    VChat.NPCReactCooldowns = VChat.NPCReactCooldowns or {}

    function VChat.GetNPCReactCooldown(class)
        if not isstring(class) then return 0 end
        return VChat.NPCReactCooldowns[class] or 0
    end

    local function IsPlayerImmune(ply)
        return VChat.IsPlayerImmune(ply)
    end

    local function OnPropCollide(ent, data)
        if not GetConVar("vchat_props"):GetBool() then return end
        if GetConVar("ai_disabled"):GetBool() then return end
        if GetConVar("ai_ignoreplayers"):GetBool() then return end
        if data.Speed < 200 then return end

        local range = GetConVar("vchat_props_range"):GetFloat()
        VChat.ReactAllNPCs(data.HitPos, range, ent, "prop collision", nil, false)
    end

    for _, ent in ipairs(ents.FindByClass("prop_physics")) do
        if IsValid(ent) then ent:AddCallback("PhysicsCollide", OnPropCollide) end
    end

    net.Receive("VChatVoiceState", function(len, ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        if not GetConVar("vchat_enabled"):GetBool() then return end
        if GetConVar("ai_disabled"):GetBool() then return end
        if GetConVar("ai_ignoreplayers"):GetBool() then return end
        if VChat.IsPlayerImmune(ply) then return end
        if VChat.IsPlayerMuted(ply) then return end

        local speaking = net.ReadBool()
        local volume   = net.ReadFloat()

        if speaking then
            local range = GetConVar("vchat_range"):GetFloat()
            VChat.ReactAllNPCs(ply:GetPos(), range, ply, "voice chat", volume, true)
        end
    end)

    net.Receive("VChatVolume", function(len, ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        if not GetConVar("vchat_enabled"):GetBool() then return end
        if GetConVar("ai_disabled"):GetBool() then return end
        if GetConVar("ai_ignoreplayers"):GetBool() then return end
        if VChat.IsPlayerImmune(ply) then return end
        if VChat.IsPlayerMuted(ply) then return end

        local volume = net.ReadFloat()
        ply.VChat_LastVolume = volume
    end)

    hook.Add("OnEntityCreated", "VChatPropHear", function(ent)
        if ent:GetClass() == "prop_physics" then
            timer.Simple(0, function()
                if IsValid(ent) then ent:AddCallback("PhysicsCollide", OnPropCollide) end
            end)
        end
    end)

    local doorClasses = { ["prop_door_rotating"] = true, ["func_door"] = true, ["func_door_rotating"] = true }
    hook.Add("AcceptInput", "VChatDoorHear", function(ent, input)
        if not GetConVar("vchat_doors"):GetBool() then return end
        if GetConVar("ai_disabled"):GetBool() then return end
        if GetConVar("ai_ignoreplayers"):GetBool() then return end
        if not doorClasses[ent:GetClass()] then return end
        if input ~= "Open" and input ~= "Close" and input ~= "Toggle" then return end

        local range = GetConVar("vchat_doors_range"):GetFloat()
        VChat.ReactAllNPCs(ent:GetPos(), range, ent, "door " .. string.lower(input), nil, false)
    end)

    hook.Add("PlayerFootstep", "VChatFootstepHear", function(ply, pos)
        if not GetConVar("vchat_footsteps"):GetBool() then return end
        if GetConVar("ai_disabled"):GetBool() then return end
        if GetConVar("ai_ignoreplayers"):GetBool() then return end
        if ply:Crouching() then return end

        local range = GetConVar("vchat_footsteps_range"):GetFloat()
        VChat.ReactAllNPCs(pos, range, ply, "footstep", nil, false)
    end)

    hook.Add("EntityFireBullets", "VChatGunshotHear", function(ent, data)
        if not GetConVar("vchat_gunshots"):GetBool() then return end
        if GetConVar("ai_disabled"):GetBool() then return end
        if GetConVar("ai_ignoreplayers"):GetBool() then return end
        if not IsValid(ent) or not ent:IsPlayer() then return end

        local range = GetConVar("vchat_gunshots_range"):GetFloat()
        VChat.ReactAllNPCs(data.Src, range, ent, "gunshot", nil, false)
    end)

    hook.Add("EntityEmitSound", "VChatExplosionHear", function(data)
        if not GetConVar("vchat_explosions"):GetBool() then return end
        if GetConVar("ai_disabled"):GetBool() then return end
        if GetConVar("ai_ignoreplayers"):GetBool() then return end
        if data.OriginalSoundName ~= "BaseExplosionEffect.Sound" then return end

        local range = GetConVar("vchat_explosions_range"):GetFloat()
        local pos = data.Pos or (IsValid(data.Entity) and data.Entity:GetPos()) or Vector(0, 0, 0)
        local ent = IsValid(data.Entity) and data.Entity or game.GetWorld()
        VChat.ReactAllNPCs(pos, range, ent, "explosion", nil, false)
    end)

    hook.Add("PlayerSay", "VChatTextChatHear", function(ply, text, teamChat)
        if not GetConVar("vchat_textchat"):GetBool() then return end
        if GetConVar("ai_disabled"):GetBool() then return end
        if GetConVar("ai_ignoreplayers"):GetBool() then return end
        if not IsValid(ply) or not ply:IsPlayer() then return end
        if teamChat and not GetConVar("vchat_teamchat"):GetBool() then return end

        local range = GetConVar("vchat_textchat_range"):GetFloat()
        local pos = ply:GetPos()

        Debug(ply:Nick() .. " typed: \"" .. text .. "\" (range: " .. math.Round(range) .. " units)")
        VChat.ReactAllNPCs(pos, range, ply, "text chat", nil, false)
    end)

    local flashlightSoundCooldowns = {}

    hook.Add("EntityEmitSound", "VChatFlashlightSoundHear", function(data)
        if not GetConVar("vchat_flashlight_sound"):GetBool() then return end
        if GetConVar("ai_disabled"):GetBool() then return end
        if GetConVar("ai_ignoreplayers"):GetBool() then return end

        local soundName = data.OriginalSoundName or data.SoundName or ""
        if not string.find(string.lower(soundName), "flashlight") then return end

        local ent = data.Entity
        if not IsValid(ent) or not ent:IsPlayer() then return end
        if IsPlayerImmune(ent) then return end

        local uid = ent:UserID()
        local now = CurTime()
        if flashlightSoundCooldowns[uid] and now < flashlightSoundCooldowns[uid] then return end
        flashlightSoundCooldowns[uid] = now + 0.5

        local pos = data.Pos or ent:GetPos()
        local range = GetConVar("vchat_flashlight_sound_range"):GetFloat()

        Debug(ent:Nick() .. " toggled flashlight - sound detected: " .. soundName)
        VChat.ReactAllNPCs(pos, range, ent, "flashlight toggle", nil, false)
    end)

    local emoteCooldowns = {}
    local EMOTE_COOLDOWN = 1.5
    local detourWorking = false
    local emoteStates = {}

    local function OnEmoteStart(ply, emoteName)
        if not GetConVar("vchat_emotes"):GetBool() then return end
        if GetConVar("ai_disabled"):GetBool() then return end
        if GetConVar("ai_ignoreplayers"):GetBool() then return end
        if not IsValid(ply) or not ply:IsPlayer() then return end
        if VChat.IsPlayerImmune(ply) then return end
        if VChat.IsPlayerMuted(ply) then return end

        local uid = ply:UserID()
        local now = CurTime()
        if (emoteCooldowns[uid] or 0) >= now then return end
        emoteCooldowns[uid] = now + EMOTE_COOLDOWN

        local range = GetConVar("vchat_emotes_range"):GetFloat()
        local pos = ply:GetPos()

        local emoteStr = "unknown"
        if isstring(emoteName) then
            emoteStr = emoteName
        elseif istable(emoteName) and emoteName[1] then
            emoteStr = isstring(emoteName[1]) and emoteName[1] or tostring(emoteName[1])
        elseif emoteName ~= nil then
            emoteStr = tostring(emoteName)
        end

        Debug(ply:Nick() .. " started emote: " .. emoteStr .. " (range: " .. math.Round(range) .. " units)")
        VChat.ReactAllNPCs(pos, range, ply, "emote: " .. emoteStr, nil, false)
    end

    hook.Add("ActMod_CStart", "VChatEmoteDetectCStart", function(tbl, tAb, Oall, GHold)
        if not istable(tbl) then return end
        if tbl[1] == "Player" and IsValid(tbl[2]) and tbl[2]:IsPlayer() then
            OnEmoteStart(tbl[2], tAb and tAb[1])
        elseif tbl[1] == "SetPlayers" and tbl[2] then
            for _, pl in player.Iterator() do
                if IsValid(pl) and A_AM and A_AM.ActMod and A_AM.ActMod.ATabData and A_AM.ActMod:ATabData(tbl[2], pl) then
                    OnEmoteStart(pl, tAb and tAb[1])
                end
            end
        elseif tbl[1] == "AllPlayers" then
            for _, pl in player.Iterator() do
                if IsValid(pl) then
                    OnEmoteStart(pl, tAb and tAb[1])
                end
            end
        end
    end)

    timer.Simple(5, function()
        if A_AM and A_AM.ActMod and A_AM.ActMod.StartAniAct then
            local origStartAniAct = A_AM.ActMod.StartAniAct
            A_AM.ActMod.StartAniAct = function(self, ply, TStr, ...)
                local ret = {origStartAniAct(self, ply, TStr, ...)}
                if IsValid(ply) and ply:IsPlayer() then
                    OnEmoteStart(ply, TStr)
                end
                return unpack(ret)
            end
            detourWorking = true
        end
    end)

    timer.Create("VChatEmoteCheck", 0.5, 0, function()
        if detourWorking then return end
        if not GetConVar("vchat_emotes"):GetBool() then return end
        if GetConVar("ai_disabled"):GetBool() then return end
        if GetConVar("ai_ignoreplayers"):GetBool() then return end

        for _, ply in ipairs(player.GetAll()) do
            if not IsValid(ply) or not ply:IsPlayer() then continue end
            if VChat.IsPlayerImmune(ply) then continue end
            if VChat.IsPlayerMuted(ply) then continue end

            local uid = ply:UserID()
            local isActing = ply:GetNW2Bool("A_AM.ActMod.IsAct", false)
            local wasActing = emoteStates[uid] or false

            if isActing and not wasActing then
                local emoteName = ply:GetNW2String("A_ActMod.TmpDir", "") 
                    ~= "" and ply:GetNW2String("A_ActMod.TmpDir", "") 
                    or ply:GetNW2String("A_ActMod.Dir", "")
                OnEmoteStart(ply, emoteName)
            end

            emoteStates[uid] = isActing
        end
    end)

    hook.Add("PlayerDisconnected", "VChatEmoteCleanup", function(ply)
        emoteCooldowns[ply:UserID()] = nil
        emoteStates[ply:UserID()] = nil
    end)

    hook.Add("PostCleanupMap", "VChatCleanup", function()
        table.Empty(flashlightSoundCooldowns)
        table.Empty(emoteCooldowns)
        table.Empty(emoteStates)
    end)

    local mpReactCooldowns = {}
    local cv_mp_enabled = GetConVar("vchat_mediaplayer")
    local cv_mp_range = GetConVar("vchat_mediaplayer_range")

    local function IsMediaPlayerPlaying(mp)
        if not mp then return false end

        
        if mp.IsPlaying then
            return mp:IsPlaying()
        end

        
        if mp.GetPlayerState then
            local state = mp:GetPlayerState()
            return state == 1
        end

        
        if mp._playing ~= nil then return mp._playing == true end

        local media = mp.GetMedia and mp:GetMedia() or mp._media
        return media ~= nil
    end

    local function GetMediaPlayerPos(mp)
        if mp.GetEntity then
            local ent = mp:GetEntity()
            if IsValid(ent) then
                return ent:GetPos(), ent
            end
        end
        if mp.GetPos then return mp:GetPos(), nil end
        return nil, nil
    end
	
    local function GetMediaPlayerOwner(mp, ent)
        if mp.GetOwner then
            local o = mp:GetOwner()
            if IsValid(o) then return o end
        end
        if IsValid(ent) and ent.CPPIGetOwner then
            return ent:CPPIGetOwner()
        end
        return nil
    end

    local function MediaPlayerHasListeners(mp)
        if mp.GetListeners then
            local listeners = mp:GetListeners()
            return istable(listeners) and table.Count(listeners) > 0
        end
        if mp._listeners then
            return table.Count(mp._listeners) > 0
        end
        return true
    end

    local function CheckMediaPlayers()
        if not cv_mp_enabled:GetBool() then return end
        if GetConVar("ai_disabled"):GetBool() then return end
        if not MediaPlayer or not MediaPlayer.List then return end

        local range = cv_mp_range:GetFloat()
        local now = CurTime()
        local anyActive = false

        
        for id, mp in pairs(MediaPlayer.List) do
            if not mp then
                VChat.MP_LastPlayingState[id] = nil
                continue
            end

            local wasPlaying = VChat.MP_LastPlayingState[id]
            local isPlaying = IsMediaPlayerPlaying(mp)

            
            if wasPlaying and not isPlaying then
                ClearNPCCooldownsForTV(id)
            end

            VChat.MP_LastPlayingState[id] = isPlaying
        end

        for id, mp in pairs(MediaPlayer.List) do
            if not mp then continue end
            if not IsMediaPlayerPlaying(mp) then continue end
            if not MediaPlayerHasListeners(mp) then continue end

            anyActive = true

            local cooldown = mpReactCooldowns[id] or 0
            if now < cooldown then continue end

            local pos, ent = GetMediaPlayerPos(mp)
            if not pos then continue end

            mpReactCooldowns[id] = now + 4

            local owner = GetMediaPlayerOwner(mp, ent)
            local sourceName = IsValid(owner) and owner:IsPlayer() and (owner:Nick() .. "'s Media Player") or "Media Player"

            local reactedCount = VChat.ReactAllNPCs(pos, range, ent, "media player", nil, false, id)
            if reactedCount > 0 then
                Debug(sourceName .. " playing - triggering NPC reaction")
            end
        end

        if not anyActive then
            timer.Stop("VChatMediaPlayerCheck")
        end
    end

    hook.Add("MediaPlayerAddListener", "VChatMPStartTimer", function(mp, ply)
        if not cv_mp_enabled:GetBool() then return end
        if not timer.Exists("VChatMediaPlayerCheck") then
            timer.Create("VChatMediaPlayerCheck", 2, 0, CheckMediaPlayers)
        else
            timer.Start("VChatMediaPlayerCheck")
        end
    end)

    hook.Add("PostMediaPlayerMediaRequest", "VChatMPStartTimer2", function(mp, media, ply)
        if not cv_mp_enabled:GetBool() then return end
        if not timer.Exists("VChatMediaPlayerCheck") then
            timer.Create("VChatMediaPlayerCheck", 2, 0, CheckMediaPlayers)
        else
            timer.Start("VChatMediaPlayerCheck")
        end

        timer.Simple(1, function()
            if not mp or not IsMediaPlayerPlaying(mp) then return end
            local pos, ent = GetMediaPlayerPos(mp)
            if not pos then return end

            local id = mp.id or (mp.GetId and mp:GetId()) or 0
            mpReactCooldowns[id] = CurTime() + 4

            local owner = GetMediaPlayerOwner(mp, ent)
            local sourceName = IsValid(owner) and owner:IsPlayer() and (owner:Nick() .. "'s Media Player") or "Media Player"

            local reactedCount = VChat.ReactAllNPCs(pos, cv_mp_range:GetFloat(), ent, "media player", nil, false, id)
            if reactedCount > 0 then
                Debug(sourceName .. " queued media started playing - " .. reactedCount .. " NPCs reacted")
            end
        end)
    end)

    
    hook.Add("PostCleanupMap", "VChatMediaPlayerCleanup", function()
      table.Empty(mpReactCooldowns)
      table.Empty(VChat.NPCSourceCooldowns)
      table.Empty(VChat.MP_LastPlayingState)
       if timer.Exists("VChatMediaPlayerCheck") then
            timer.Remove("VChatMediaPlayerCheck")
       end
    end)

    print("[VChat] Loaded")
end
