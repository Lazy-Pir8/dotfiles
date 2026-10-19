-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

-- Workspace rules migrated from workspaces.conf (auto-generated).
-- Edit ~/.config/hypr/UserConfigs/workspaces.lua to modify workspace rules in Lua mode.

hl.workspace_rule({
    workspace = "3",
    no_rounding = false,
    decorate = true,
    gaps_in = 10,
    gaps_out = 25,
    no_border = false,
    border_size = 3,
})

hl.workspace_rule({
    workspace = "1",
    gaps_in = 2,
    gaps_out = 5,
    no_rounding = true,
    no_border = true,
    decorate = false,
})

hl.workspace_rule({
    workspace = "2",
    gaps_in = 6,
    gaps_out = 12,
    no_rounding = true,
    no_border = false,
    border_size = 2,
})

hl.workspace_rule({
    workspace = "4",
    gaps_in = 8,
    gaps_out = 20,
    no_rounding = false,
    no_border = false,
    border_size = 3,
    decorate = true,
})

hl.workspace_rule({
    workspace = "5",
    gaps_in = 12,
    gaps_out = 30,
    no_rounding = false,
    no_border = false,
    border_size = 4,
    decorate = true,
})
hl.workspace_rule({ workspace = "3", monitor = "eDP-1", layout = "dwindle" })
