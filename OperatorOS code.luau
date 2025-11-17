function FindPart(PartName: string)for _,  port in GetPorts() do local found = GetPartFromPort(port, PartName)if found then return found end end local part = GetPart(PartName)if part then return part end return nil end
function FindParts(PartName: string)for _, port in GetPorts() do local found = GetPartsFromPort(port, PartName)if next(found) ~= nil then return found end end local part = GetParts(PartName)if next(part) ~= nil then return part end return nil end


function Restart()
	local port = GetPort(1)
	if port then
		TriggerPort(1)
	else
		ConsoleWarn("no port detected, restart manually")
	end
end


--Voiv'y's simple OS
local screens = {}

--GetScreens
local function GetScreens()
	local RegScren = FindParts("Screen")
	local touch = FindParts("TouchScreen")

	if RegScren ~= nil then
		for _, s in RegScren do
			table.insert(screens, s)
		end
	end
	if touch ~= nil then
		for _, s in touch do
			table.insert(screens, s)
		end
	end
end

GetScreens()

local PartstoGet = {
	"Keyboard" ;
	"Modem";
	"LifeSensor";
	"Instrument";
	"Speaker";
}

--Desc: this is literally a simple terminal based os in which its only purpose is to run and execute  code from github

local Diskcount = 0

local System ={
	Parts = {};
	Threads = {};
	Files = {}; -- deprecated
	Connections = {};
	Configurables = {
		ConsoleColor3 = Color3.fromRGB(255, 255, 255);
		ConsoleWarningColor = Color3.fromRGB(255, 115, 0);
		BackgroundColor3 = Color3.fromRGB(16, 43, 70);
	};
}
local MainFrames = {}
--Cache

local RAM = {
	Buffer= {}
}

local TerminalTextLabels = {}

--file types
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
			Console("Data: "..tostring(Data))
			RunFunction(tostring(Data))
		end
	end
}


--cmds
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
				description = "fetching and executing code from a git URL.";
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

					if FindPart("Microcontroller") then
						Console("procedding with update")
						FindPart("Microcontroller").Code = code
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

						if FindPart("Microcontroller") then
							Console("procedding with update")
							FindPart("Microcontroller").Code = Code
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
			for _, s in screens do
				s:ClearElements()
				MAINFRAMINI()
			end
		end;
	};	
	["wait"] = {
		description = "wait [time]";
		args = "<wait_time>";
		execute = function(args)
			wait(args[1])
		end;
	};
	["write"] = {
		description = "Saves to disk e.x. use t:lua/ to write code that can be executed | Example: write Disk / puter t:lua/gitfile";
		args = "<Disk> <Path> <Data>";
		execute = function(args)
			local disk = System[args[1]].Disk
			if not disk then
				ConsoleWarn("Disk not found: " .. tostring(args[1]))
				return
			end

			Console(`Disk: {args[1]}`)

			-- Combine args[2] and args[3] to make a filename
			local filename = args[2]

			-- Join everything after the 3rd arg as the file content
			local content = table.concat(args, " ", 3)

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
				["/OmoriPuter"] = "t:lua/https://raw.githubusercontent.com/0mori1/puter/refs/heads/main/code/putercode.lua";
				["/ModemCom"] = "t:lua/https://raw.githubusercontent.com/voidstonism/VOIDSTONISMSHIPCODEFORWOS/refs/heads/main/ModemCom.luau";
				["/ArvidCom"] = "t:lua/https://raw.githubusercontent.com/voidstonism/VOIDSTONISMSHIPCODEFORWOS/refs/heads/main/ArvidSilverlockModem.lua.luau";
				["/Text.txt"] = "Hi there";
			}

			for Path, Data in NativePrograms do
				System.Disk1.Disk:Write(Path,Data)
			end
		end;
	};
	["read"] = {
		description = "Reads Disk -- less advanced than open";
		args = "<subcommand> <Disk> <Name>";
		subcommands = {
			["run"] = {
				execute = function(args)
					local path = args[1]
					local Data
					local DiskFound

					--Atempts to find Data
					for i = 1, Diskcount do
						if System[`Disk{i}`].Files[path] then
							Data = System[`Disk{i}`].Files[path]
							DiskFound = i
							break
						end
					end

					if Data == nil then
						ConsoleWarn("File not found")
						return
					end

					local typeTag, data = Indentifytype(path,Data)

					if typeTag and data then
						print("Type:", typeTag)  -- t:lua/
						print("Data:", data)    
						print("Disk:", DiskFound) -- print('Hello from raw code!')

						if types[typeTag] then
							types[typeTag](data)
						else
							ConsoleWarn("Unknown type: " .. typeTag)
						end
					else
						ConsoleWarn("Input format not recognized. Attempting to run.")
						ConsoleWarn(Data)
						RunFunction(Data)
					end
				end;
			};
			["print"] = {

				execute = function(args)
					local path = args[1]
					local Data
					local Disk

					--Atempts to find Data
					for i = 1, Diskcount do
						if System[`Disk{i}`].Files[path] then
							Data = System[`Disk{i}`].Files[path]
							Disk = System[`Disk{i}`].Disk
							break
						end
					end

					if Data == nil then
						ConsoleWarn("File not found")
						return
					end
					
					local data = ReadData(Disk,path)
					
					if typeof(data) == "table" then
						local StringData = ""
						for i,object in data do
							StringData = StringData..`{i}:{object}; `
						end
						data = StringData
						Console("type: table")
					end

					print("Path:", path)  -- t:lua/
					ConsoleWarn("Data:", data)    
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
			Console("[<b>FILES</b>]")
			MirrorDataToFile()

			for i, d in FindParts("Disk") do
				Console(`[<b>Disk{i}Files</b>]`)
				Console("	---------------------")
				for Path, Data in System[`Disk{i}`].Files do
					Console(`	{Path}`)
				end
				Console("	---------------------")
			end
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
	["cleandisk"] = {
		description = "Cleans Disk";
		args = "<PartName>";
		execute = function(args)
			System[args[1]].Disk:Clear()
			ConsoleWarn("DISK CLEARED")
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
			MainFrames:Remove()
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
		description = "finds and opens files reghardless of disk location (WARNING SAME FILES ON TWO DIFFERENT DISK MAY CONFLICT)";
		args = "<Path>";
		execute = function(args)
			local path = args[1]
			local Data
			local DiskFound

			--Atempts to find Data
			for i = 1, Diskcount do
				if System[`Disk{i}`].Files[path] then
					Data = System[`Disk{i}`].Files[path]
					DiskFound = i
					break
				end
			end

			if Data == nil then
				ConsoleWarn("File not found")
				return
			end

			local typeTag, data = Indentifytype(path,Data)

			if typeTag and data then
				print("Type:", typeTag)  -- t:lua/
				print("Data:", data)    
				print("Disk:", DiskFound) -- print('Hello from raw code!')

				if types[typeTag] then
					types[typeTag](data)
				else
					ConsoleWarn("Unknown type: " .. typeTag)
					Console("Data:", data) 
				end
			else
				ConsoleWarn("Input format not recognized. Outputting raw data:")
				Console(Data)
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
								pcall(function()
									coroutine.close(thread)
									System.Threads = {}
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

						for _, thread in ipairs(System.Threads) do
							if coroutine.status(thread) ~= "dead" then
								pcall(function()
									coroutine.close(thread)
									System.Threads = {}
								end)
							end
						end


						MAINFRAMINI()
						Console("All Threads have been ceased restarte may be required")
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
			["-sm"] = {
				args = "<Message>";
				execute = function(args)
					if not System.Parts.Modem then
						ConsoleWarn("Modem Missing")
						return
					end
					System.Parts.Modem:SendMessage(table.concat(args, " ", 1))	
				end;
			};
			["-smmc"] = {
				args = "<Message>";
				execute = function(args)

					local function GenerateID()
						local ID = "MID:"

						for i = 1, 7 do
							ID = ID..tostring(math.random(0,9))
						end

						return ID
					end


					if not System.Parts.Modem then
						ConsoleWarn("Modem Missing")
						return
					end

					local text = `{GenerateID()} OperatorOS | {string.gsub(table.concat(args, " ", 1),"\n","")}`

					System.Parts.Modem:SendMessage(text)	
				end;
			};
			["-smdos"] = {
				args = "<Message> <Channel>";
				execute = function(args)
					if not System.Parts.Modem then
						ConsoleWarn("Modem Missing")
						return
					end

					local msg = table.concat(args, " ", 2)
					local ChannelID = args[1]

					if ChannelID == "_" then
						ChannelID = "dOS-General"
					end

					msg:gsub(ChannelID, "")

					local Table = {
						type = "TEXT_MESSAGE",
						UNIQUE_ID = math.random(1,100000000),
						sender = "MODEMCOM51",
						timestamp = DateTime.now().UnixTimestamp,
						content = msg,
						target_channel_id = ChannelID,
					}

					print(ChannelID)
					System.Parts.Modem:SendMessage(JSONEncode(Table))	
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
			["-c"] = {
				args = "";
				execute = function(args)
					if not System.Parts.Modem then
						ConsoleWarn("Modem Missing")
						return
					end
					System.Connections.ModemConnect = System.Parts.Modem.MessageSent:Connect(function(msg)
						local msgid = string.match(msg, "MID:%d%d%d%d%d%d%d") -- voidstonism message id format for modemcom

						local success, Jsonfile = pcall(function()
							return JSONDecode(msg)
						end)

						if msgid then
							Console(`{System.Parts.Modem.NetworkID}: {string.gsub(msg, "MID:%d%d%d%d%d%d%d ", "")}`)
						elseif success and Jsonfile then
							if Jsonfile.type == "TEXT_MESSAGE" then
								Console(`{System.Parts.Modem.NetworkID}: {Jsonfile.sender}: {Jsonfile.content}`)
								print(Jsonfile.target_channel_id)
							end
						else
							Console(`{System.Parts.Modem.NetworkID}: {msg}`)
						end
					end)	
					ConsoleWarn(`Connected. Modem ID is {System.Parts.Modem.NetworkID}`)
				end;
			};
			["-dc"] = {
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
	for i, Screen1 in screens do 
		print(i)
		local frame = Screen1:CreateElement('ScrollingFrame',{
			Size = UDim2.fromScale(1, 1);
			Position = UDim2.fromScale(0, 0);
			AnchorPoint = Vector2.new(0,0);
			Rotation = 0;
			CanvasSize = UDim2.fromScale(0.5,1);
			AutomaticCanvasSize = Enum.AutomaticSize.Y;
			BackgroundColor3 = System.Configurables.BackgroundColor3
		})

		local UIListLayout = Screen1:CreateElement("UIListLayout",{SortOrder = Enum.SortOrder.LayoutOrder}
		)

		UIListLayout.Parent = frame

		MainFrames["MainFrames"..i] = frame
		print(MainFrames["MainFrames"..i])
	end
end

MAINFRAMINI()

--Universal helpers
function RunFunction(code)
	local Thread = coroutine.create(function()
		local Succes, Error = pcall(function()
			loadstring(code)()
		end)
		if Succes then
			Console(`executed successfully`)
		else
			ConsoleWarn(Error)
		end
	end)

	table.insert(System.Threads, Thread)
	coroutine.resume(Thread)
end



function ModifyConsoleLine(TextLabel:TextLabel,Text)
	TextLabel.Text = Text
end
-- Console printing
function Console(TXT: string, TxtColor: Color3?)
	local label
	for i, Screen1 in screens do
		label = Screen1:CreateElement("TextLabel", {
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

		label.Parent = MainFrames["MainFrames"..i]
	end
	table.insert(TerminalTextLabels, label)
	print(TXT)
	return label
end

function ConsoleWarn(TXT: string)
	Console(TXT, System.Configurables.ConsoleWarningColor)
end

function MirrorDataToFile()
	if Diskcount ~= 0 then
		for i, d in FindParts("Disk") do
			System[`Disk{i}`].Files = d:ReadAll()
		end
	else
		Console("No Disk Found")
	end
end

function Indentifytype(path,Data)
	if typeof(Data) == "table" then
		local StringData = ""
		for i,object in Data do
			StringData = StringData..`{i}:{object}; `
		end
		return "table",StringData
	else
		return string.match(Data, "^(t:[^/]+/)(.+)")
	end
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
function FindPart(PartName: string)for _,  port in GetPorts() do local found = GetPartFromPort(port, PartName)if found then return found end end local part = GetPart(PartName)if part then return part end return nil end
function FindParts(PartName: string)for _, port in GetPorts() do local found = GetPartsFromPort(port, PartName)if next(found) ~= nil then return found end end local part = GetParts(PartName)if next(part) ~= nil then return part end return nil end
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
	Console("Checking Disks...")
	
	local Disks = FindParts("Disk") or nil
	if Disks then
		Diskcount = #Disks or 0
		Console(`[<b>OK</b>] Disk`)
		for i, Di in Disks do
			System["Disk"..i] = {}
			System["Disk"..i].Disk = Di
			print()
		end
		Console(`[<b>DISKS</b>] {#Disks}`)
	else
		Console(`[<b>MISSING</b>] Disk`)
	end

	Console(`[<b>SCREENS</b>] {#screens}`)

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

	if Diskcount ~= 0 then
		Console("[<b>FILES</b>]")
		MirrorDataToFile()

		for i, d in FindParts("Disk") do
			Console(`[<b>Disk{i}Files</b>]`)
			Console("	---------------------")
			for Path, Data in System[`Disk{i}`].Files do
				Console(`	{Path}`)
			end
			Console("	---------------------")
		end
	else
		Console("No Disk Found")
	end

	Console("[<b>READY</b>]")


	Mainloop()
end)

if Success == false then
	Console(Error)
end

coroutine.yield()
