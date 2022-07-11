util.require_natives(1651208000)
util.keep_running()

local ptfxIds = {}
local ptfxPower = 1
local ptfxSize = 5
local ptfxDict = "core"
local ptfxName = "exp_grd_grenade_smoke"

function attachPtfx(ppid)
    STREAMING.REQUEST_NAMED_PTFX_ASSET(ptfxDict)
    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(ptfxDict) do
        util.yield()
    end

    for i = 1, ptfxPower, 1 do
        GRAPHICS.USE_PARTICLE_FX_ASSET(ptfxDict)
        local ptfxId =
            GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY(
            ptfxName,
            ppid,
            0,
            0,
            0,
            0,
            0,
            0,
            ptfxSize,
            false,
            false,
            false
        )
        table.insert(ptfxIds, ptfxId)
    end
end

function removePtfx()
    for _, i in pairs(ptfxIds) do
        GRAPHICS.STOP_PARTICLE_FX_LOOPED(i, false)
    end
end

players.on_join(
    function(pid)
        menu.divider(menu.player_root(pid), "Lag PTFX")

        menu.toggle(
            menu.player_root(pid),
            "Lag Player",
            {"lag"},
            "Lag the player with a PTFX.",
            function(toggle)
                local ppid = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if toggle then
                    attachPtfx(ppid)

                    while (true) do
                        if PLAYER.IS_PLAYER_DEAD(pid) then
                            while (PLAYER.IS_PLAYER_DEAD(pid)) do
                                util.yield()
                            end
                            break
                        else
                            util.yield()
                        end
                    end
                    ppid = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    removePtfx()
                    attachPtfx(ppid)
                else
                    removePtfx()
                end
            end
        )

        menu.slider(
            menu.player_root(pid),
            "Lag Power",
            {"lagpower"},
            "Change PTFX power.",
            1,
            300,
            1,
            1,
            function(change)
                ptfxPower = change
            end
        )

        local ptfxSettings =
            menu.list(
            menu.player_root(pid),
            "PTFX Settings",
            {},
            "",
            function()
            end
        )

        menu.slider(
            ptfxSettings,
            "PTFX Size",
            {"ptfxsize"},
            "Change PTFX size.",
            1,
            10,
            5,
            1,
            function(change)
                ptfxSize = change
            end
        )

        menu.text_input(
            ptfxSettings,
            "PTFX Dictionary",
            {"ptfxdictionary"},
            "Select PTFX dictionary.",
            function(change)
                ptfxDict = change
            end,
            "core"
        )

        menu.text_input(
            ptfxSettings,
            "PTFX Name",
            {"ptfxname"},
            "Select PTFX name.",
            function(change)
                ptfxName = change
            end,
            "exp_grd_grenade_smoke"
        )

        menu.hyperlink(
            ptfxSettings,
            "PTFX List",
            "https://github.com/DurtyFree/gta-v-data-dumps/blob/master/particleEffectsCompact.json#L270",
            "List of all GTAV PTFX and Dictionaries."
        )
    end
)

players.dispatch_on_join()
