function FindPart(PartName: string)for port = 1, 20 do local found = GetPartFromPort(port, PartName)if found then return found end end local part = GetPart(PartName)if part then return part end return nil end

--function FindParts(PartName: string)for port = 1, 20 do local found = GetPartFromPort(port, PartName)if found then return found end end local part = GetPart(PartName)if part then return part end return nil end


function Restart()
	local port = GetPort(1)
	if port then
		TriggerPort(1)
	else
		ConsoleWarn("no port detected, restart manually")
	end
end


--Voiv'y's simple OS
local Screen = FindPart("Screen") or FindPart("TouchScreen")

local PartstoGet = {
	"Keyboard" ;

	"Disk";
	"Modem";
	"LifeSensor";
	"Instrument";
	"Speaker";

}

--Desc: this is literally a simple terminal based os in which its only purpose is to run and execute  code from github

local System ={
	Parts = {};
	Threads = {};
	Files = {};
	Connections = {};
	Configurables = {
		ConsoleColor3 = Color3.fromRGB(255, 255, 255);
		ConsoleWarningColor = Color3.fromRGB(255, 115, 0);
		BackgroundColor3 = Color3.fromRGB(16, 43, 70);
	};
}

local MAINFRAME
--Cache
local TerminalTextLabels = {}

--Cmds
local Commands = {
	["run"] = {
		description = "Reformats and runs code for compadibility.";
		args = "<subcommand> <code_or_url>";
		subcommands = {
			["line"] = {
				description = "Run raw Luau code.";
				execute = function(args)
					local code = table.concat(args, " ")

					-- Warnings for risky calls
					if string.find(code, "loadstring") then ConsoleWarn("Warning: 'loadstring' detected") end
					if string.find(code, "require") then ConsoleWarn("Warning: 'require' detected") end
					if string.find(code, "getfenv") then ConsoleWarn("Warning: 'getfenv' detected") end

					local code = formatcode(code)

					print("Executing code:\n", code)
					local ok, err = pcall(function()
						RunFunction(code)
					end)

					if not ok then
						Console("Error: " .. err)
					else
						Console("Code executed successfully.")
					end
				end;
			};

			["git"] = {
				description = "Simulate fetching and executing code from a git URL.";
				execute = function(args)
					ConsoleWarn("WARNING: this requires a modem")
					if not System.Parts.Modem then
						Console("Modem Missing Cannot Run")
						return
					end

					local url = args[1]
					if not url then
						Console("Usage: -r git <url>")
						return
					end

					Console("Requesting Git Raw")
					wait(1)

					local Code = System.Parts.Modem:GetAsync(url)

					local Code = formatcode(Code)

					print("Executing Git Code:\n", Code)
					local ok, err = pcall(function()
						local thread = coroutine.create(function()
							local func, loadErr = loadstring(Code)
							if not func then error("Code failed to compile: " .. tostring(loadErr)) end
							local success, execErr = pcall(func)
							if not success then error("Code execution error: " .. tostring(execErr)) end
						end)

						table.insert(System.Threads, thread)
						coroutine.resume(thread)
					end)

					if not ok then
						Console("Coroutine start failed: " .. tostring(err))
					else
						Console("Git code executed.")
					end
				end;
			};
		};
	};
	["ru"] = {
		description = "Run code without reformatting them for compatibility.";
		args = "<subcommand> <code_or_url>";
		subcommands = {
			["line"] = {
				description = "Run raw Luau code.";
				execute = function(args)
					local code = table.concat(args, " ")

					-- Warnings for risky calls
					if string.find(code, "loadstring") then ConsoleWarn("Warning: 'loadstring' detected") end
					if string.find(code, "require") then ConsoleWarn("Warning: 'require' detected") end
					if string.find(code, "getfenv") then ConsoleWarn("Warning: 'getfenv' detected") end

					print("Executing code:\n", code)
					local ok, err = pcall(function()
						RunFunction(code)
					end)

					if not ok then
						Console("Error: " .. err)
					else
						Console("Code executed successfully.")
					end
				end;
			};

			["git"] = {
				description = "Fetches code from gists and executes them.";
				execute = function(args)
					ConsoleWarn("WARNING: this requires a modem")
					if not System.Parts.Modem then
						Console("Modem Missing Cannot Run")
						return
					end

					local url = args[1]
					if not url then
						Console("Usage: -sudo git <url>")
						return
					end

					Console("Requesting Git Raw")
					wait(1)

					local Code = System.Parts.Modem:GetAsync(url)

					-- Warnings
					if string.find(Code, "loadstring") then ConsoleWarn("Warning: 'loadstring' detected") end
					if string.find(Code, "require") then ConsoleWarn("Warning: 'require' detected") end
					if string.find(Code, "getfenv") then ConsoleWarn("Warning: 'getfenv' detected") end

					print("Executing Git Code:\n", Code)
					local ok, err = pcall(function()
						local thread = coroutine.create(function()
							local func, loadErr = loadstring(Code)
							if not func then error("Code failed to compile: " .. tostring(loadErr)) end
							local success, execErr = pcall(func)
							if not success then error("Code execution error: " .. tostring(execErr)) end
						end)

						table.insert(System.Threads, thread)
						coroutine.resume(thread)
					end)

					if not ok then
						Console("Coroutine start failed: " .. tostring(err))
					else
						Console("Git code executed.")
					end
				end;
			};
		};
	};
	["update"] = {
		description = "updates system";
		args = "<subcommand> <raw_or_git>";
		subcommands = {
			["line"] = {
				description = "Run raw Luau code.";
				execute = function(args)
					local code = table.concat(args, " ")

					if GetSuperPart("Microcontroller") then
						Console("procedding with update")
						GetSuperPart("Microcontroller").Code = code
						Console("attempting to restart, if it doesnt restart, please do so manually")
						Restart()
					else
						Console("Can't find microcontroller")
					end
				end;
			};

			["git"] = {
				description = "Fetches code from gists and executes them.";
				execute = function(args)
					ConsoleWarn("WARNING: this requires a modem")
					if System.Parts.Modem then
						local url = args[1]

						if not url then
							Console("Usage: -r requestfromgit <url>")
							return
						end

						Console("Requesting Git Raw")

						local Code = System.Parts.Modem:GetAsync(url)

						if GetSuperPart("Microcontroller") then
							Console("procedding with update")
							GetSuperPart("Microcontroller").Code = Code
							Console("attempting to restart, if it doesnt restart, please do so manually")
							Restart()
						else
							Console("Can't find microcontroller")
						end
					else
						Console("Modem Missing Cannot Run")
					end
				end;
			};
		};
	};
	["fetchparts"] = {
		description = "List all detected parts.";
		args = "";
		execute = function()
			Console("Connected parts:")
			for name, part in pairs(System.Parts) do
				Console(`- {name}: {part and "OK" or "MISSING"}`)
			end
		end;
	};
	["clear"] = {
		description = "Clear the terminal screen.";
		args = "";
		execute = function()
			Console("Clearing terminal...")
			for _, label in pairs(TerminalTextLabels) do
				label:Remove()
			end
			TerminalTextLabels = {}
		end;
	};	
	["wait"] = {
		description = "Clear the terminal screen.";
		args = "<wait_time>";
		execute = function(args)
			wait(args[1])
		end;
	};
	["write"] = {
		description = "Saves to disk";
		args = "<Disk> <Key_OR_Path> <Name> <Data>";
		execute = function(args)
			local disk = System.Parts[args[1]]
			if not disk then
				ConsoleWarn("Disk not found: " .. tostring(args[1]))
				return
			end

			Console("Disk found:", disk)

			-- Combine args[2] and args[3] to make a filename
			local filename = (args[2] or "") .. (args[3] or "")

			-- Join everything after the 3rd arg as the file content
			local content = table.concat(args, " ", 4)

			-- Save
			SaveData(disk, filename, content)
			Console(`Saved to disk: {filename} : {content}`)
		end;
	};
	["wp"] = {
		description = "writes other programs";
		args = "";
		execute = function(args)
			Console("Writing neccesary programs on disk")

			local NativePrograms = {
				["/Clock"] = "t:lua/https://raw.githubusercontent.com/voidstonism/VOIDSTONISMSHIPCODEFORWOS/refs/heads/main/Clock.lua";
				["/Radar"] = "t:lua/https://raw.githubusercontent.com/voidstonism/WoSRadar/refs/heads/main/MAINCODE.pilot.luau";
				["/Text.txt"] = "Hi there";
			}

			for Path, Data in NativePrograms do
				System.Parts.Disk:Write(Path,Data)
			end
		end;
	};
	["read"] = {
		description = "Reads Disk -- more advanced than open";
		args = "<subcommand> <Disk> <Key_OR_Path> <Name>";
		subcommands = {
			["run"] = {
				execute = function(args)
					local disk = System.Parts[args[1]]
					local path = args[2]..args[3]
					local Data = ReadData(disk,path)
					--check if its a github raw
					if string.find(Data,"https://raw.githubusercontent.com/") then
						Console("Github File detected")
						ConsoleWarn("WARNING: this requires a modem")
						if not System.Parts.Modem then
							Console("Modem Missing Cannot Run")
							return
						end

						local url = Data
						if not url then
							Console("Usage: -r git <url>")
							return
						end

						Console("Requesting Git Raw")
						wait(1)

						local Code = System.Parts.Modem:GetAsync(url)

						local Code = formatcode(Code)

						print("Executing Git Code:\n", Code)
						local ok, err = pcall(function()
							local thread = coroutine.create(function()
								local func, loadErr = loadstring(Code)
								if not func then error("Code failed to compile: " .. tostring(loadErr)) end
								local success, execErr = pcall(func)
								if not success then error("Code execution error: " .. tostring(execErr)) end
							end)

							table.insert(System.Threads, thread)
							coroutine.resume(thread)
						end)

						if not ok then
							Console("Coroutine start failed: " .. tostring(err))
						else
							Console("Git code executed.")
						end
					else
						Console("Path: "..path)
						Console("Data: "..tostring(Data))
						RunFunction(tostring(Data))
					end

				end;
			};
			["print"] = {

				execute = function(args)
					local disk = System.Parts[args[1]]
					local path = args[2]..args[3]
					local Data = ReadData(disk,path)
					Console("Path: "..path)
					Console("Data: "..tostring(Data))
				end;
			};
		}
	};
	["refresh"] = {
		description = "Refresh terminal output labels.";
		args = "";
		execute = function()
			Console("Refreshing terminal...")
			for _, label in pairs(TerminalTextLabels) do
				label.Text = label.Name
			end
		end;
	};
	["console"] = {
		description = "Prints in console.";
		args = "<string>";
		execute = function(args)
			Console(table.concat(args, " "))
		end;
	};
	["files"] = {
		description = "Prints in console.";
		args = "";
		execute = function(args)
			MirrorDataToFile()

			Console("---------------------")
			for Path, Data in System.Files do
				Console(`{Path}`)
			end
			Console("---------------------")
		end;
	};
	["fetch"] = {
		description = "Display system info";
		args = "";
		execute = function()
			local asciiLogo = [[
			
		]]

			local osInfo = {
				"OS: OperatorOS";
				"Kernel: Pilot.lua";
				"Uptime: " .. math.floor(tick()) .. "s";
				"Packages: " .. tostring(#System.Threads);
			}

			for line in string.gmatch(asciiLogo, "[^\n]+") do
				Console(line)
			end

			Console("")
			for _, line in ipairs(osInfo) do
				Console(line)
			end
		end
	};
	["help"] = {
		description = "Show available commands.";
		args = "";
		execute = function()
			Console("Available commands:")
			for cmd, info in pairs(GetCommands()) do
				Console(`{cmd}: {info.description or "No description"}`)
				Console(`Args: {info.args or "No args"}`)
				if info.subcommands then
					for sub, subInfo in pairs(info.subcommands) do
						Console(`   {sub}: {subInfo.description or "No description"}`)
					end
				end
			end
		end;
	};
	["addpart"] = {
		description = "Adds part to System.Parts";
		args = "<PartName>";
		execute = function(args)

			System.Parts[args[1]] = GetSuperPart(args[1])

			local Part = System.Parts[args[1]]
			if Part then
				Console("Part added")
				Console(args[1])
			else
				ConsoleWarn("Part Not Found")
				ConsoleWarn(args[1])
			end

		end;
	};
	["removepart"] = {
		description = "removes part to System.Parts";
		args = "<PartName>";
		execute = function(args)


			if System.Parts[args[1]] then
				System.Parts[args[1]] = nil
				System.Parts[args[1]]:Remove()
				Console(`Removed {args[1]}`)
			else
				ConsoleWarn(`{args[1]} is not a part in System.Parts`)
			end
		end;
	};
	["exit"] = {
		description = "Shuts down system";
		args = "<PartName>";
		execute = function(args)
			for _, thread in ipairs(System.Threads) do
				if coroutine.status(thread) ~= "dead" then
					-- No native coroutine.kill, so we can only close if coroutine.wrap used or yield checked
					pcall(function()
						coroutine.close(thread) -- Works in Pilot.lua with Luau coroutine extensions
					end)
				end
			end
			Console("Ceasing All Threads")
			MAINFRAME:Remove()
			GetSuperPart("Microcontroller"):Shutdown()
		end;
	};
	["reboot"] = {
		description = "Show available commands.";
		args = "";
		execute = function(args)
			Restart()
		end;
	};
	["power"] = {
		description = "Show available commands.";
		args = "";
		execute = function(args)
			Console("\nCURRENT POWER:")
			local label = Console(tonumber(System.Parts.Instrument:GetReading("Power"),10))
			local POWERTHREAD = coroutine.create(function()
				while true do
					wait(1)
					ModifyConsoleLine(label, math.round(tonumber(System.Parts.Instrument:GetReading("Power"),10)))
				end
			end)
			coroutine.resume(POWERTHREAD)

			table.insert(System.Threads, POWERTHREAD)
		end;
	};
	["open"] = {
		description = "opens app simpler but lacks disk selector";
		args = "<Path>";
		execute = function(args)
			local path = args[1]
			local Data = System.Files[path]

			local types = {
				["t:txt/"] = function(Data)
					Console(Data)
				end,
				["t:lua/"] = function(Data)
					if string.find(Data,"https://raw.githubusercontent.com/") then
						Console("Github File detected")
						ConsoleWarn("WARNING: this requires a modem")
						if not System.Parts.Modem then
							Console("Modem Missing Cannot Run")
							return
						end

						local url = Data
						if not url then
							Console("Usage: -r git <url>")
							return
						end

						Console("Requesting Git Raw")
						wait(1)

						local Code = System.Parts.Modem:GetAsync(url)

						local Code = formatcode(Code)

						print("Executing Git Code:\n", Code)
						local ok, err = pcall(function()
							local thread = coroutine.create(function()
								local func, loadErr = loadstring(Code)
								if not func then error("Code failed to compile: " .. tostring(loadErr)) end
								local success, execErr = pcall(func)
								if not success then error("Code execution error: " .. tostring(execErr)) end
							end)

							table.insert(System.Threads, thread)
							coroutine.resume(thread)
						end)

						if not ok then
							Console("Coroutine start failed: " .. tostring(err))
						else
							Console("Git code executed.")
						end
					else
						Console("Path: "..path)
						Console("Data: "..tostring(Data))
						RunFunction(tostring(Data))
					end
				end
			}

			-- indentifies which type it is

			local typeTag, data = string.match(Data, "^(t:[^/]+/)(.+)")

			if typeTag and data then
				print("Type:", typeTag)  -- t:lua/
				print("Data:", data)     -- print('Hello from raw code!')

				if types[typeTag] then
					types[typeTag](data)
				else
					ConsoleWarn("Unknown type: " .. typeTag)
				end
			else
				ConsoleWarn("Input format not recognized.")
				print(Data)
			end
		end;
	};
	["cease"] = {
		description = "Show available commands.";
		args = "";
		subcommands = {
			["soft"] = {
				execute = function()
					local function CeaseAllThreads()
						Beep()
						Console("Ceasing all threads in System.Threads")

						-- Stop coroutines
						for _, thread in ipairs(System.Threads) do
							if coroutine.status(thread) ~= "dead" then
								-- No native coroutine.kill, so we can only close if coroutine.wrap used or yield checked
								pcall(function()
									coroutine.close(thread) -- Works in Pilot.lua with Luau coroutine extensions
								end)
							end
						end
					end


					CeaseAllThreads();
				end;

			};
			["hard"] = {
				execute = function()
					local function CeaseAllThreads()
						Beep()
						Console("Ceasing all threads in System.Threads")

						-- Stop coroutines
						for _, thread in ipairs(System.Threads) do
							if coroutine.status(thread) ~= "dead" then
								-- No native coroutine.kill, so we can only close if coroutine.wrap used or yield checked
								pcall(function()
									coroutine.close(thread) -- Works in Pilot.lua with Luau coroutine extensions
								end)
							end
						end


						-- Optional: Clear all UI or reset terminal
						Screen:ClearElements()
						MAINFRAMINI()
						Console("All Threads have been ceased restarter required")
					end


					CeaseAllThreads();
				end;
			};

		}

	};

	["modem"] = {
		description = "modem libary";
		args = "<subcommand>";
		subcommands = {
			["sendmessage"] = {
				args = "<Message>";
				execute = function(args)
					if not System.Parts.Modem then
						ConsoleWarn("Modem Missing")
						return
					end
					System.Parts.Modem:SendMessage(table.concat(args, " ", 1))	
				end;
			};
			["postasync"] = {
				args = "<url> <data> <contentType> <compress> <headers>";
				execute = function(args)
					if not System.Parts.Modem then
						ConsoleWarn("Modem Missing")
						return
					end
					System.Parts.Modem:PostAsync(args[1] or nil,args[2] or nil,args[3] or nil,args[4] or nil,args[5] or nil)	
				end;
			};
			["connect"] = {
				args = "";
				execute = function(args)
					if not System.Parts.Modem then
						ConsoleWarn("Modem Missing")
						return
					end
					System.Connections.ModemConnect = System.Parts.Modem.MessageSent:Connect(function(msg)
						local msgid = string.match(msg, "MID:%d%d%d%d%d%d%d") -- voidstonism message id format for modemcom

						if msgid then
							Console(`{System.Parts.Modem.NetworkID}: {string.gsub(msg, "MID:%d%d%d%d%d%d%d ", "")}`)
						else
							Console(`{System.Parts.Modem.NetworkID}: {msg}`)
						end
					end)	
					ConsoleWarn(`Connected. Modem ID is {System.Parts.Modem.NetworkID}`)
				end;
			};
			["disconnect"] = {
				args = "";
				execute = function(args)
					if not System.Parts.Modem then
						ConsoleWarn("Modem Missing")
						return
					end
					System.Connections.ModemConnect:Disconnect()	
					ConsoleWarn("System.Connections.ModemConnect has been disconnected")
				end;
			};
			["changeid"] = {
				args = "<ID>";
				execute = function(args)
					if not System.Parts.Modem then
						ConsoleWarn("Modem Missing")
						return
					end
					System.Parts.Modem.NetworkID = args[1]
					Console(`Modem id has been changed to {args[1]}`)
				end;
			};
		}
	};
}


function GetCommands()
	return Commands
end

function SaveData(Disk,Key_OR_Path,Data)
	Disk:Write(Key_OR_Path,Data)
end

function ReadData(Disk,Key_OR_Path)
	local disk = Disk
	local Data = disk:Read(Key_OR_Path)
	return Data
end

function MAINFRAMINI()
	MAINFRAME = Screen:CreateElement('ScrollingFrame',{
		Size = UDim2.fromScale(1, 1);
		Position = UDim2.fromScale(0, 0);
		AnchorPoint = Vector2.new(0,0);
		Rotation = 0;
		CanvasSize = UDim2.fromScale(0.5,1);
		AutomaticCanvasSize = Enum.AutomaticSize.Y;
		BackgroundColor3 = System.Configurables.BackgroundColor3
	})

	local UIListLayout = Screen:CreateElement("UIListLayout",{SortOrder = Enum.SortOrder.LayoutOrder}
	)

	UIListLayout.Parent = MAINFRAME
end

MAINFRAMINI()

--Universal helpers

function CheckPart(part)
	if part then
		return true, `Part "{part}" detected`
	else
		return false, `Part "{part}" not detected`
	end
end

function RunFunction(code)
	local Thread = coroutine.create(function()
		loadstring(code)()
	end)

	table.insert(System.Threads, Thread)
	coroutine.resume(Thread)
end



function ModifyConsoleLine(TextLabel:TextLabel,Text)
	TextLabel.Text = Text
end
-- Console printing
function Console(TXT: string, TxtColor: Color3?)
	local label = Screen:CreateElement("TextLabel", {
		Name = "> " .. TXT,
		Size = UDim2.fromScale(1, 0),
		Position = UDim2.fromScale(0, 0),
		AnchorPoint = Vector2.new(0, 0),
		Text = "> " .. TXT,
		TextWrapped = true,
		RichText = true,
		Font = "Ubuntu",
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		TextColor3 = TxtColor or System.Configurables.ConsoleColor3,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1
	})

	label.Parent = MAINFRAME
	table.insert(TerminalTextLabels, label)
	print(TXT)
	return label
end

function ConsoleWarn(TXT: string)
	Console(TXT, System.Configurables.ConsoleWarningColor)
end

local function CheckPartAndDisplayOnConsole(Part:string)
	local PartObj = FindPart(Part)
	local Boolean, text = CheckPart(PartObj)

	if Boolean then
		System.Parts[Part] = PartObj
		Console(`{Part} is no longer nil, part assigned`)
	end

	Console(text)
end

function MirrorDataToFile()
	System.Files = System.Parts.Disk:ReadAll()
end

function formatcode(Code:string)
	-- Warnings
	if string.find(Code, "loadstring") then ConsoleWarn("Warning: 'loadstring' detected") end
	if string.find(Code, "require") then ConsoleWarn("Warning: 'require' detected") end
	if string.find(Code, "getfenv") then ConsoleWarn("Warning: 'getfenv' detected") end

	Code = string.gsub(Code, 'GetPartFromPort%(%d+,%s*"(.-)"%)', 'FindPart("%1")')
	Code = string.gsub(Code, 'GetPart%(%s*"(.-)"%)', 'FindPart("%1")')

	Code = string.gsub(Code, 'GetPartsFromPort%(%d+,%s*"(.-)"%)', 'FindParts("%1")')
	Code = string.gsub(Code, 'GetParts%(%s*"(.-)"%)', 'FindParts("%1")')

	if not string.find(Code, "function FindPart") then
		local superPartDef = [[
function FindPart(PartName: string)
	for port = 1, 20 do
		local found = GetPartFromPort(port, PartName)
		if found then return found end
	end
	local part = GetPart(PartName)
	if part then return part end
	return nil
end

function FindParts(PartName: string)
	for port = 1, 20 do
		local found = GetPartsFromPort(port, PartName)
		if found then return found end
	end
	local part = GetParts(PartName)
	if part then return part end
	return nil
end
]]
		Code = superPartDef .. "\n" .. Code
		
		return Code
	end
end


local function Mainloop()
	while task.wait(1) do
	end
end

local Success, Error = pcall(function()
	Console("Checking...")
	Beep()

	for _, PartName in ipairs(PartstoGet) do
		local part = FindPart(PartName)
		if part then
			System.Parts[PartName] = part
			Console(`[<b>OK</b>] {PartName}`)
		else
			Console(`[<b>MISSING</b>] {PartName}`)
		end
	end


	-- ConnectKeyboard
	Console("[<b>Connecting</b>] Keyboard")

	if System.Parts.Keyboard then
		System.Parts.Keyboard.TextInputted:Connect(function(txt)
			--Handle Mulitple commands such as &&
			txt = tostring(txt:gsub("\n", ""))
			Console(`┌ROOT@LocalHost`)
			Console(`└{txt}`)

			local CommandsTable = txt:split(" && ")

			for i, CommandLine in CommandsTable do
				local tokens = string.split(CommandLine, " ")
				local command = tokens[1]
				local args = { unpack(tokens, 2) }

				local cmd = Commands[command]
				if not cmd then
					ConsoleWarn(`Unknown command: {command}`)
					return
				end

				-- Handle subcommands (like -r runnormal)
				if cmd.subcommands then
					local subcmdName = args[1]
					local subcmd = cmd.subcommands[subcmdName]
					if subcmd then
						local subargs = { unpack(args, 2) }
						local ok, err = pcall(function()
							subcmd.execute(subargs)
						end)
						if not ok then
							ConsoleWarn("Error: " .. err)
						end
					else
						ConsoleWarn(`Unknown subcommand for {command}: {subcmdName}`)
					end
				else
					local ok, err = pcall(function()
						cmd.execute(args)
					end)
					if not ok then
						ConsoleWarn("Error: " .. err)
					end
				end
			end
		end)
	else
		ConsoleWarn("[<b>ERROR</b>] Keyboard Missing")
	end

	Console("[<b>FILES</b>]")
	MirrorDataToFile()

	Console("---------------------")
	for Path, Data in System.Files do
		Console(`{Path}`)
	end
	Console("---------------------")

	Console("[<b>READY</b>]")


	Mainloop()
end)

if Success == false then
	Console(Error)
end

coroutine.yield()
