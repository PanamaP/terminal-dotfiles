local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local prev_workspace = nil

-- Track workspace changes so we can switch back
wezterm.on("update-status", function(window)
  local current = window:active_workspace()
  if M._last_seen_workspace and M._last_seen_workspace ~= current then
    prev_workspace = M._last_seen_workspace
  end
  M._last_seen_workspace = current
end)

--- Query zoxide for top-ranked directories and present an InputSelector
function M.switch_workspace()
  return wezterm.action_callback(function(window, pane)
    local success, stdout, _ = wezterm.run_child_process({ "zoxide", "query", "-l" })
    if not success then
      wezterm.log_error("zoxide query failed")
      return
    end

    local choices = {}
    for line in stdout:gmatch("[^\r\n]+") do
      local label = line:gsub("\\", "/")
      table.insert(choices, { id = line, label = label })
    end

    window:perform_action(
      act.InputSelector({
        title = "Switch Workspace (zoxide)",
        choices = choices,
        fuzzy = true,
        action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
          if not id then return end
          local workspace_name = label:match("([^/]+)$") or label
          inner_window:perform_action(
            act.SwitchToWorkspace({
              name = workspace_name,
              spawn = { cwd = id },
            }),
            inner_pane
          )
        end),
      }),
      pane
    )
  end)
end

--- Switch back to the previously active workspace
function M.switch_to_prev_workspace()
  return wezterm.action_callback(function(window, pane)
    if prev_workspace then
      window:perform_action(
        act.SwitchToWorkspace({ name = prev_workspace }),
        pane
      )
    else
      wezterm.log_info("No previous workspace to switch to")
    end
  end)
end

return M
