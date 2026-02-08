// amazing hook library 

Msg("This Server's running CLib!")

CLib = {
    Hooks = {
        ["GameEvent"] = {
            engine = true, // engine meaning this hook can be hooked via hook.Add
            alias = "GameEvents",
        },

        ["CLib"] = {engine = false}, // internal hook only hookable via this hook library
        ["Gmod"] = {engine = true},
        ["ULib"] = {
            engine = true,
            alias = "ULibHooks",
        },
    },

    ["ULibHooks"] = { // ULIB SUPPORT !!
        ["PlayerBanned"] = "ULibPlayerBanned",
        ["UCLAuthed"] = "UCLAuthed",
        ["GetUserCustomKeyword"] = "ULibGetUserCustomKeyword",
        ["GroupRemoved"] = "ULibGroupRemoved",
        ["PlayerUnBanned"] = "ULibPlayerUnBanned",
        ["CommandCalled"] = "ULibCommandCalled",
        ["UserAccessChanged"] = "ULibUserAccessChange",
        ["GroupRenamed"] = "ULibGroupRenamed",
        ["UCLChanged"] = "UCLChanged",
        ["PlayerTarget"] = "ULibPlayerTarget",
        ["GetUsersCustomKeyword"] = "ULibGetUsersCustomKeyword",
        ["GroupCreated"] = "ULibGroupCreated",
        ["ReplicatedCvarChanged"] = "ULibReplicatedCvarChanged",
        ["UserGroupChanged"] = "ULibUserGroupChange",
        ["PlayerNameChanged"] = "ULibPlayerNameChanged",
        ["LocalPlayerReady"] = "ULibLocalPlayerReady",
        ["GroupAccessChanged"] = "ULibGroupAccessChanged",
        ["PlayerTargets"] = "ULibPlayerTargets",
        ["PlayerKicked"] = "ULibPlayerKicked",
        ["UserRemoved"] = "ULibUserRemoved",
        ["GroupCanTargetChanged"] = "ULibGroupCanTargetChanged",
        ["GroupInheritanceChanged"] = "ULibGroupInheritanceChanged",
        ["PostTranslatedCommand"] = "ULibPostTranslatedCommand",
        ["UCLAccessRegistered"] = "UCLAccessRegistered",
    },

    ["GameEvents"] = {
        ["PlayerSpawn"] = "player_spawn",
        ["ClientBeginConnect"] = "client_beginconnect",
        ["HltvRankEntity"] = "hltv_rank_entity",
        ["BreakBreakable"] = "break_breakable",
        ["FreezeCamStarted"] = "freezecam_started",
        ["ServerRemoveban"] = "server_removeban",
        ["PlayerConnect"] = "player_connect",
        ["HltvTitle"] = "hltv_title",
        ["ShowFreezePanel"] = "show_freezepanel",
        ["EntityKilled"] = "entity_killed",
        ["ClientDisconnect"] = "client_disconnect",
        ["HltvChangedMode"] = "hltv_changed_mode",
        ["RagdollDissolved"] = "ragdoll_dissolved",
        ["PlayerSay"] = "player_say",
        ["HltvCameraman"] = "hltv_cameraman",
        ["UserDataDownloaded"] = "user_data_downloaded",
        ["GameNewMap"] = "game_newmap",
        ["AchievementEarned"] = "achievement_earned",
        ["BreakProp"] = "break_prop",
        ["ServerSpawn"] = "server_spawn",
        ["PlayerActivate"] = "player_activate",
        ["HltvMessage"] = "hltv_message",
        ["ServerAddBan"] = "server_addban",
        ["PlayerDisconnect"] = "player_disconnect",
        ["FlareIgniteNPC"] = "flare_ignite_npc",
        ["ClientConnected"] = "client_connected",
        ["HltvChangedTarget"] = "hltv_changed_target",
        ["OnRequestFullUpdate"] = "OnRequestFullUpdate",
        ["HltvChase"] = "hltv_chase",
        ["HideFreezePanel"] = "hide_freezepanel",
        ["PlayerInfo"] = "player_info",
        ["HostQuit"] = "host_quit",
        ["PlayerHurt"] = "player_hurt",
        ["PlayerConnectClient"] = "player_connect_client",
        ["ServerCvar"] = "server_cvar",
        ["AchievementEvent"] = "achievement_event",
        ["HltvRankCamera"] = "hltv_rank_camera",
        ["PlayerChangeName"] = "player_changename",
        ["HltvStatus"] = "hltv_status",
        ["HltvFixed"] = "hltv_fixed",
    }
}



/* =======================================
||  CLib :: Helper Function
*/// =====================================

function CLib:ParseEvent(event)
    if istable(event) then return event end

    for basename, basetable in pairs(self.Hooks) do
        local prefix = basename .. "::"
        if string.StartsWith(event, prefix) then
            local name = string.sub(event, #prefix + 1)
            local engine = name

            if basetable.engine and basetable.alias then // why would an internal hook need an alias, whole point of alias is to make engine hooks look cleaner
                engine = self[basetable.alias][name] or name
            end

            return {
                base = basename,
                name = name,
                engine = engine
            }
        end
    end
end



/* =======================================
||  CLib :: API
*/// =====================================

function CLib:Add(event, identifier, func)
    local eventt = self:ParseEvent(event)
    if !eventt then return end

    local etable = self.Hooks[eventt.base][eventt.name]
    local first = !etable

    etable = etable or {}
    self.Hooks[eventt.base][eventt.name] = etable
    etable[identifier] = func

    if !self.Hooks[eventt.base].engine then return end // internal hooks do not use hook.Add

    if first then
        if eventt.base == "GameEvent" then
            gameevent.Listen(eventt.engine)
        end

        hook.Add(eventt.engine, "CLib::" .. eventt.base .. "::" .. eventt.name, function(...)
            return self:Run(eventt, ...)
        end)
    end
end


function CLib:Remove(event, identifier)
    local eventt = self:ParseEvent(event)
    if !eventt then return end

    local etable = self.Hooks[eventt.base][eventt.name]
    if !etable then return end

    etable[identifier] = nil 

    if next(etable) == nil and self.Hooks[eventt.base].engine then // clean up
        hook.Remove(eventt.engine, "CLib::" .. eventt.base .. "::" .. eventt.name)
        self.Hooks[eventt.base][eventt.name] = nil
    end
end


function CLib:Run(event, ...) // only meant for internal hooks
    local eventt = self:ParseEvent(event)
    if !eventt then return end

    local etable = self.Hooks[eventt.base][eventt.name]
    if !etable then
        if !self.Hooks[eventt.base].engine then
            self.Hooks[eventt.base][eventt.name] = {}
            etable = self.Hooks[eventt.base][eventt.name]
        else return end
    end

    for ligma, func in pairs(etable) do
        local returns = func(...)

        if returns ~= nil then
            return returns
        end
    end
end


function CLib:Exists(event, identifier)
    local eventt = self:ParseEvent(event)
    if !eventt then return false end

    return self.Hooks[eventt.base][eventt.name] and self.Hooks[eventt.base][eventt.name][identifier] ~= nil // im sorry
end


function CLib:GetTable(base)
    if !self.Hooks[base] then return end
    return self.Hooks[base]
end


function CLib:AddBase(base, engine, alias, aliaslist)
    CLib.Hooks[base] = {
        engine = engine,
        alias = engine and alias or nil,
    }

    if engine and alias then
        CLib[alias] = aliaslist or {}
    end
end