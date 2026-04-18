-- Based on: https://github.com/MLFlexer/smart_workspace_switcher.wezterm
--
-- Modifications:
--   - Added project directory scanning (pub.project_dirs) to discover
--     projects not yet tracked by zoxide
--   - Added InputSelector-based picker for consistent UX and Ctrl+C support
--   - Cross-platform directory listing (Windows & Unix)

local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local is_windows = string.find(wezterm.target_triple, "windows") ~= nil

---@alias action_callback any
---@alias MuxWindow any
---@alias Pane any

---@alias workspace_ids table<string, boolean>
---@alias choice_opts {extra_args?: string, workspace_ids?: workspace_ids}
---@alias InputSelector_choices { id: string, label: string }[]

---@class public_module
---@field zoxide_path string
---@field project_dirs string[]
---@field choices {get_zoxide_elements: (fun(choices: InputSelector_choices, opts: choice_opts?): InputSelector_choices), get_workspace_elements: (fun(choices: InputSelector_choices): (InputSelector_choices, workspace_ids)), get_project_elements: (fun(choices: InputSelector_choices, seen_ids: table<string, boolean>): InputSelector_choices)}
---@field workspace_formatter fun(label: string): string
local pub = {
	zoxide_path = "zoxide",
	project_dirs = {},
	choices = {},
	workspace_formatter = function(label)
		return wezterm.format({
			{ Text = "󱂬 : " .. label },
		})
	end,
}

---@param cmd string
---@return string
local run_child_process = function(cmd)
	local process_args = { os.getenv("SHELL"), "-c", cmd }
	if is_windows then
		process_args = { "cmd", "/c", cmd }
	end
	local success, stdout, stderr = wezterm.run_child_process(process_args)

	if not success then
		wezterm.log_error("Child process '" .. cmd .. "' failed with stderr: '" .. stderr .. "'")
	end
	return stdout
end

---@param choice_table InputSelector_choices
---@param current_workspace? string
---@return InputSelector_choices, workspace_ids
function pub.choices.get_workspace_elements(choice_table, current_workspace)
	local workspace_ids = {}
	for _, workspace in ipairs(mux.get_workspace_names()) do
		local label = pub.workspace_formatter(workspace)
		if workspace == current_workspace then
			label = label .. " (current)"
		end
		table.insert(choice_table, {
			id = workspace,
			label = label,
		})
		workspace_ids[workspace] = true
	end
	return choice_table, workspace_ids
end

---@param choice_table InputSelector_choices
---@param opts? choice_opts
---@return InputSelector_choices
function pub.choices.get_zoxide_elements(choice_table, opts)
	if opts == nil then
		opts = { extra_args = "", workspace_ids = {} }
	end

	local stdout = run_child_process(pub.zoxide_path .. " query -l " .. (opts.extra_args or ""))

	for _, path in ipairs(wezterm.split_by_newlines(stdout)) do
		local updated_path = string.gsub(path, wezterm.home_dir, "~")
		if not opts.workspace_ids[updated_path] then
			table.insert(choice_table, {
				id = path,
				label = updated_path,
			})
			if opts.seen_ids then
				opts.seen_ids[path] = true
			end
		end
	end
	return choice_table
end

---Scan project directories (1 level deep) and add entries not already seen
---@param choice_table InputSelector_choices
---@param seen_ids table<string, boolean>
---@return InputSelector_choices
function pub.choices.get_project_elements(choice_table, seen_ids)
	local sep = is_windows and "\\" or "/"

	for _, dir in ipairs(pub.project_dirs) do
		local expanded = string.gsub(dir, "^~", wezterm.home_dir)
		local pattern = expanded .. sep .. "*"

		for _, full_path in ipairs(wezterm.glob(pattern)) do
			if not seen_ids[full_path] then
				local label = string.gsub(full_path, wezterm.home_dir, "~")
				table.insert(choice_table, {
					id = full_path,
					label = label,
				})
				seen_ids[full_path] = true
			end
		end
	end
	return choice_table
end

---Returns choices for the InputSelector (zoxide + scanned project dirs)
---@param opts? choice_opts
---@return InputSelector_choices
function pub.get_choices(opts)
	if opts == nil then
		opts = { extra_args = "" }
	end
	opts.workspace_ids = opts.workspace_ids or {}
	opts.seen_ids = {}

	---@type InputSelector_choices
	local choices = {}
	choices = pub.choices.get_zoxide_elements(choices, opts)

	if #pub.project_dirs > 0 then
		choices = pub.choices.get_project_elements(choices, opts.seen_ids)
	end

	return choices
end

---@param workspace string
---@return MuxWindow
local function get_current_mux_window(workspace)
	for _, mux_win in ipairs(mux.all_windows()) do
		if mux_win:get_workspace() == workspace then
			return mux_win
		end
	end
	error("Could not find a workspace with the name: " .. workspace)
end

---Check if the workspace exists
---@param workspace string
---@return boolean
local function workspace_exists(workspace)
	for _, workspace_name in ipairs(mux.get_workspace_names()) do
		if workspace == workspace_name then
			return true
		end
	end
	return false
end

---InputSelector callback when zoxide supplied element is chosen
---@param window MuxWindow
---@param pane Pane
---@param path string
---@param label_path string
local function zoxide_chosen(window, pane, path, label_path)
	local workspace_name = path:match("([^\\/]+)$") or label_path
	window:perform_action(
		act.SwitchToWorkspace({
			name = workspace_name,
			spawn = {
				label = "Workspace: " .. workspace_name,
				cwd = path,
			},
		}),
		pane
	)
	wezterm.emit(
		"smart_workspace_switcher.workspace_switcher.created",
		get_current_mux_window(workspace_name),
		path,
		label_path
	)
	-- increment zoxide path score
	run_child_process(pub.zoxide_path .. " add " .. path)
end

---InputSelector callback when workspace element is chosen
---@param window MuxWindow
---@param pane Pane
---@param workspace string
---@param label_workspace string
local function workspace_chosen(window, pane, workspace, label_workspace)
	window:perform_action(
		act.SwitchToWorkspace({
			name = workspace,
		}),
		pane
	)
	wezterm.emit(
		"smart_workspace_switcher.workspace_switcher.chosen",
		get_current_mux_window(workspace),
		workspace,
		label_workspace
	)
end

---@param opts? choice_opts
---@return action_callback
function pub.switch_workspace(opts)
	return wezterm.action_callback(function(window, pane)
		wezterm.emit("smart_workspace_switcher.workspace_switcher.start", window, pane)

		---@type InputSelector_choices
		local choices = {}
		local current = window:active_workspace()
		choices, workspace_ids = pub.choices.get_workspace_elements(choices, current)

		if opts == nil then
			opts = {}
		end
		opts.workspace_ids = workspace_ids
		local path_choices = pub.get_choices(opts)
		for _, choice in ipairs(path_choices) do
			table.insert(choices, choice)
		end

		window:perform_action(
			act.InputSelector({
				action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
					if id and label then
						wezterm.emit("smart_workspace_switcher.workspace_switcher.selected", window, id, label)

						if workspace_exists(id) then
							workspace_chosen(inner_window, inner_pane, id, label)
						else
							zoxide_chosen(inner_window, inner_pane, id, label)
						end
					else
						wezterm.emit("smart_workspace_switcher.workspace_switcher.canceled", window, pane)
					end
				end),
				title = "Choose Workspace",
				description = "Select a workspace and press Enter = accept, Esc = cancel, / = filter",
				fuzzy_description = "Workspace to switch: ",
				choices = choices,
				fuzzy = true,
			}),
			pane
		)
	end)
end

---sets default keybind to ALT-s
---@param config table
function pub.apply_to_config(config)
	if config == nil then
		config = {}
	end

	if config.keys == nil then
		config.keys = {}
	end

	table.insert(config.keys, {
		key = "s",
		mods = "LEADER",
		action = pub.switch_workspace(),
	})
	table.insert(config.keys, {
		key = "S",
		mods = "LEADER",
		action = pub.switch_to_prev_workspace(),
	})
end

function pub.switch_to_prev_workspace()
	return wezterm.action_callback(function(window, pane)
		local current_workspace = window:active_workspace()
		local previous_workspace = wezterm.GLOBAL.previous_workspace

		if current_workspace == previous_workspace or previous_workspace == nil then
			return
		end

		wezterm.GLOBAL.previous_workspace = current_workspace

		window:perform_action(
			act.SwitchToWorkspace({
				name = previous_workspace,
			}),
			pane
		)
		wezterm.emit("smart_workspace_switcher.workspace_switcher.switched_to_prev", window, pane, previous_workspace)
	end)
end

wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, _, _)
	wezterm.GLOBAL.previous_workspace = window:active_workspace()
end)

return pub
