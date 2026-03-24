--[[MBEE_HEADER__DO_NOT_EDIT]]
if game then
	PilotLua = require(game.ReplicatedStorage.PilotLua)
	Beep, FileSystem, GetCPUTime, GetPart, GetPartFromPort, GetParts, GetPartsFromPort, GetPort, GetPorts, JSONDecode, JSONEncode, Microcontroller, Network, RawFileSystem, SandboxID, SandboxRunID, TriggerPort, logError, pilot = PilotLua()
end
-- Version 1755562366
-- Automatically generated header, provides typechecking. Disable "Microcontroller Typechecking" in advanced settings to remove.
--[[MBEE_HEADER__DO_NOT_EDIT]]
local System ={
	LocalHost = "127.0.0.1";
	KeyBoardFocus = {
		Mode = nil;
		SubMode = nil;
	};
	Terminal = {
		TerminalTextLabels = {};
		MainFrames = {};
	};
	Information = {
		Name = "NeoOpOS"
	};
	Parts = {};
	Configurables = {
		ConsoleColor3 = Color3.fromHex("#DCD7BA");
		ConsoleWarningColor = Color3.fromHex("#FF9E3B");
		BackgroundColor3 = Color3.fromHex("#2A2A37");
		CMDFONT = Enum.Font.Arcade;
		CMDTextSize = 12;
	};
	DiskCount = 0;
	PIDCount = 0;
	Connections = {};
	Threads = {};
	Daemons = {};
}



function FindPart(PartName: string)for _,  port in GetPorts() do local found = GetPartFromPort(port, PartName)if found then return found end end local part = GetPart(PartName)if part then return part end return nil end
function FindParts(PartName: string)for _, port in GetPorts() do local found = GetPartsFromPort(port, PartName)if next(found) ~= nil then return found end end local part = GetParts(PartName)if next(part) ~= nil then return part end return nil end

local screens = {}

local SYSTEMINITFUNC

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

function Restart()
	local port = GetPort(1)
	if port then
		TriggerPort(1)
	else
		ConsoleWarn("no port detected, restart manually")
	end
end

GetScreens()

function MirrorDataToFile()
	System.DiskCount = #FindParts("Disk")

	Console("[<b>#Disk</b>] "..System.DiskCount)

	if System.DiskCount ~= 0 then
		for i, d in FindParts("Disk") do
			System[`Disk{i}`] = {}
			System[`Disk{i}`].Disk = d
			System[`Disk{i}`].Files = d:ReadAll()
		end
	else
		Console("No Disk Found")
	end
end

function MD2F_Silent()
	System.DiskCount = #FindParts("Disk")
	if System.DiskCount ~= 0 then
		for i, d in FindParts("Disk") do
			System[`Disk{i}`] = {}
			System[`Disk{i}`].Files = d:ReadAll()
		end
	else
		Console("No Disk Found")
	end
end

function KillPID(PID)
	for i, proc in pairs(System.Threads) do
		if proc.Descriptor == PID then
			Console("PID FOUND")
			for _, e in pairs(proc.Elements) do
				e:Destroy()
			end
			coroutine.yield(proc.Thread)
			coroutine.close(proc.Thread)
			table.remove(System.Threads,i)
			Console(`PID {PID} killed.`)
		else
			Console("PID NOT FOUND")
		end
	end
end

function RunGitFile(Data,Format)
	if string.find(Data,"https://raw.githubusercontent.com/") or string.find(Data,"https://gist.githubusercontent.com/") then
		Console("Github File detected")
		ConsoleWarn("WARNING: this requires a modem")
		if not System.Parts.Modem then
			Console("Modem Missing Cannot Run")
			return
		end

		local url = Data
		Console(url)
		if not url then
			Console("Data Missing")
			return
		end

		Console("Requesting Git Raw")

		local Code = System.Parts.Modem:GetAsync(url)

		if Format then
			Code = formatcode(Code)
		end

		RunFunction(Code)
	else
		Console("Data: "..tostring(Data))
		RunFunction(tostring(Data))
	end
end

function SaveData(Disk,Key_OR_Path,Data)
	Disk:Write(Key_OR_Path,Data)
	MD2F_Silent()
end

function ReadData(Disk,Key_OR_Path)
	local disk = Disk
	local Data = disk:Read(Key_OR_Path)
	return Data
end

local PartstoGet = {
	"Keyboard" ;
	"Modem";
	"LifeSensor";
	"Instrument";
	"Speaker";
	"Microphone";
	"Telescope";
}

--Desc: this is literally a simple terminal based os in which its only purpose is to run and execute  code from github


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

			print("Executing Git Code")
			RunFunction(Code)
		else
			Console("Data: "..tostring(Data))
			RunFunction(tostring(Data))
		end
	end
}

--cmds

local CMDS = {
	echo = {
		Flags = {
			w = function(arg)
				ConsoleWarn(ArgMerger(arg))
			end,
		},
		Desc = "";
		Function = function(commandName, segment)
			local parsed = ParseCommandLine(segment)

			for _, entry in ipairs(parsed) do
				if entry.Flag then
					RunFlags(commandName, {entry.Flag}, entry.Args)
				else
					Console(ArgMerger(entry.Args))
				end
			end
		end
	};
	reboot = {
		Flags = {
			n = function(arg)
				Restart()
			end,
		},
		Desc = "";
		Function = function(commandName, segment)
			local parsed = ParseCommandLine(segment, true)

			if #parsed == 0 then
				Console("RESTARTING IN")
				for i = 5, 1, -1 do
					Console(i)
					task.wait(1)
				end
				Restart()
				return
			end

			for _, entry in ipairs(parsed) do
				if entry.Flag then
					RunFlags(commandName, {entry.Flag}, entry.Args)
				end
			end
		end
	};
	open = {
		Flags = {
			raw = function(arg)

			end,
		},
		Function = function(commandName, segment)
			local parsed = ParseCommandLine(segment)

			for _, entry in ipairs(parsed) do
				if entry.Flag then
					RunFlags(commandName, {entry.Flag}, entry.Args)
				else
					local path = entry.Args[1]
					local Data = FindFile(path)


					local typeTag, data = Indentifytype(path,Data)

					if typeTag and data then
						print("Type:", typeTag)  -- t:lua/
						--print("Data:", data)    
						if types[typeTag] then
							types[typeTag](data)
						else
							ConsoleWarn("Unknown type: " .. typeTag)
							Console("Data: "..data) 
						end
					else
						ConsoleWarn("Input format not recognized. Outputting raw data:")
						Console(Data)
					end
				end
			end
		end
	};
	run = {
		Flags = {
			raw = function(arg)
				local Data = ArgMerger(arg)

				RunGitFile(Data,false)
			end,
		},
		Function = function(commandName, segment)
			local parsed = ParseCommandLine(segment)

			for _, entry in ipairs(parsed) do
				if entry.Flag then
					RunFlags(commandName, {entry.Flag}, entry.Args)
				else
					local Data = ArgMerger(entry.Args)

					RunGitFile(Data,true)
				end
			end
		end
	};
	ls = {
		Flags = {
			s = function(arg)
				MirrorDataToFile()
				Console("Disk Mirrored")
			end,
		},

		Function = function(commandName, segment)
			local parsed = ParseCommandLine(segment, true)

			if #parsed == 0 then
				Console("[<b>FILES</b>]")
				for i, d in FindParts("Disk") do
					Console(`[<b>Disk{i}Files</b>]`)
					Console("	---------------------")
					for Path, Data in System[`Disk{i}`].Files do
						Console(`{Path}`)
					end
					Console("	---------------------")
				end
				return
			end

			for _, entry in ipairs(parsed) do
				if entry.Flag then
					RunFlags(commandName, {entry.Flag}, entry.Args)
				end
			end
		end
	};
	pkill = {
		Flags = {
			a = function(arg)
				pkillall()
			end,
		},

		Function = function(commandName, segment)
			local parsed = ParseCommandLine(segment)

			for _, entry in ipairs(parsed) do
				if entry.Flag then
					RunFlags(commandName, {entry.Flag}, entry.Args)
				else
					local PID = tonumber(entry.Args[1])
					print(PID)

					KillPID(PID)
				end
			end
		end
	};
	disk = {
		Flags = {
			w = function(arg)
				local DiskNumber = arg[1]
				local filename = arg[2]
				local data = table.concat(arg," ",3)
				SaveData(System[`Disk{DiskNumber}`].Disk,filename,data)
				MirrorDataToFile()
			end,
			wc = function(arg)
				local DiskNumber = arg[1]
				local filename = arg[2]
				local data = "t:lua/"..table.concat(arg," ",3)
				SaveData(System[`Disk{DiskNumber}`].Disk,filename,data)
				MirrorDataToFile()
			end,
			r = function(arg)
				local DiskNumber = arg[1]
				local filename = arg[2]
				local Data = ReadData(System[`Disk{DiskNumber}`].Disk,filename)
				Console(`{filename} on Disk {DiskNumber}:`)
				Console(`	{Data}`)
			end,
			d = function(arg)
				local file = arg[1]
				MirrorDataToFile()
			end,
		},

		Function = function(commandName, segment)
			local parsed = ParseCommandLine(segment)

			for _, entry in ipairs(parsed) do
				if entry.Flag then
					RunFlags(commandName, {entry.Flag}, entry.Args)
				else
					FlagInterater(commandName)
				end
			end
		end,
	};
	cm = {
		Flags = {
			smmc = function(arg)
				System.KeyBoardFocus.SubMode = "smmc"
			end,
			sm = function(arg)
				System.KeyBoardFocus.SubMode = "sm"
			end,
			atms = function(arg)
				System.KeyBoardFocus.SubMode = "atms"
			end,
		},

		Function = function(commandName, segment)
			local parsed = ParseCommandLine(segment)
			
			System.KeyBoardFocus.Mode = "modem"
			
			local PrevMsg = ""

			System.Connections.ModemConnect = System.Parts.Modem.MessageSent:Connect(function(msg)
				if PrevMsg == msg then
					return
				end
				
				PrevMsg = msg
				
				local msgid = string.match(msg, "MID:%d%d%d%d%d%d%d ") -- voidstonism message id format for modemcom

				local success, Jsonfile = pcall(function()
					return JSONDecode(msg)
				end)

				if msgid then
					Console(`[SMMC][{System.Parts.Modem.NetworkID}]: {string.gsub(msg, "MID:%d%d%d%d%d%d%d ", "")}`,Color3.fromRGB(255, 223, 148))
				elseif success and Jsonfile then
					Console(`[ATMS][{System.Parts.Modem.NetworkID}][{Jsonfile.sender}]: {Jsonfile.content}`)
				else
					Console(`[Standard][{System.Parts.Modem.NetworkID}]: {msg}`)
				end
			end)	

			Console(`[{System.Parts.Modem.NetworkID}] : Connection Establised`,Color3.fromRGB(85, 170, 0))

			for _, entry in ipairs(parsed) do
				if entry.Flag then
					RunFlags(commandName, {entry.Flag}, entry.Args)
				else
					FlagInterater(commandName)
				end
			end
		end,
	};
	fetch = {
		Flags = {
		},

		Function = function(commandName, segment)
			Console(
				[[
							OS: OperatorOsRebuilt
							Kernel: pilot.lua
							Version: 1.0.0
				]])
			Console("Threads")
			local s=""
			local g=""
			for i, t in System.Threads do
				g=g..`PID: {t.Descriptor} | `
				g=g..`{tostring(t.Thread)}`
				g=g..` | STATUS: {coroutine.status(t.Thread)}`
				g=g.."\n"
			end


			g=g..`{#System.Threads} Threads`

			Console(g)

			Console("Daemons")
			local s=""
			for i, t in System.Daemons do
				s=s..`PID: {i} | `
				s=s..`{tostring(t)}`
				s=s..` | STATUS: {coroutine.status(t)}`
				s=s.."\n"
			end


			s=s..`{#System.Daemons} Threads`
			s=s.."\n"
			s=s..`{#System.Connections} Connections`

			Console(s)
		end
	};
}


--CMDS STUFF

function ArgMerger(args)
	return table.concat(args, " ")
end

function RunFlags(commandName, flags, args)
	local command = CMDS[commandName]
	if not command.Flags then return end

	if not command.Flags[flags[1]] then
		Console("Invalid flag: "..`"{flags[1]}"`)
	end

	for _, flag in ipairs(flags) do
		local flagFunc = command.Flags[flag]
		if flagFunc then
			flagFunc(args)
		end
	end
end

function ParseCommandLine(segment: string, disableArguments)
	disableArguments = disableArguments or false

	if segment == "" and not disableArguments then
		Console("Arguments Missing")
		return {}
	end

	local tokens = {}
	for token in segment:gmatch("%S+") do
		table.insert(tokens, token)
	end

	local parsed = {}
	local i = 1

	while i <= #tokens do
		local token = tokens[i]

		if token:sub(1,1) == "-" then
			local flag = token:sub(2)
			local collectedArgs = {}
			i += 1

			while i <= #tokens and tokens[i]:sub(1,1) ~= "-" do
				table.insert(collectedArgs, tokens[i])
				i += 1
			end

			table.insert(parsed, {
				Flag = flag,
				Args = collectedArgs
			})
		else
			local collectedArgs = {}

			while i <= #tokens and tokens[i]:sub(1,1) ~= "-" do
				table.insert(collectedArgs, tokens[i])
				i += 1
			end

			table.insert(parsed, {
				Flag = nil,
				Args = collectedArgs
			})
		end
	end

	return parsed
end

--THE CMD INTERPETER

function CMDInterpeter(TxT: string)
	local cmdchunks = string.split(TxT, "&&")

	for _, rawCmd in ipairs(cmdchunks) do
		rawCmd = string.gsub(rawCmd, "^%s+", "") -- trim left space

		local tokens = {}
		for token in rawCmd:gmatch("%S+") do
			table.insert(tokens, token)
		end

		local cmdName = tokens[1]
		table.remove(tokens, 1)

		local segment = table.concat(tokens, " ")

		local SelectCommand = CMDS[cmdName]

		if SelectCommand then
			local Success, Error = pcall(function()
				SelectCommand.Function(cmdName, segment)
			end)

			if not Success then
				ConsoleWarn(Error,Color3.fromRGB(255, 0, 4))
			end
		else
			ConsoleWarn("Command not found: "..tostring(cmdName))
		end
	end
end
-- Console printing
function Console(TXT: string, TxtColor: Color3?)
	if #System.Terminal.TerminalTextLabels > 100 then
		for _, label in pairs(System.Terminal.TerminalTextLabels) do
			label:Remove()
		end
		System.Terminal.TerminalTextLabels = {}
	end

	if string.len(TXT) > 1000 then
		ConsoleWarn("String too long, cannot be displayed")
		return
	end

	local label
	for i, Screen1 in screens do
		label = Screen1:CreateElement("TextLabel", {
			Name = TXT,
			Size = UDim2.fromScale(1, 0),
			Position = UDim2.fromScale(0, 0),
			AnchorPoint = Vector2.new(0, 0),
			Text = TXT,
			TextWrapped = true,
			RichText = true,
			Font  = System.Configurables.CMDFONT,
			TextSize = System.Configurables.CMDTextSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			TextColor3 = TxtColor or System.Configurables.ConsoleColor3,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1
		})

		label.Parent = System.Terminal.MainFrames["MainFrames"..i]
	end
	table.insert(System.Terminal.TerminalTextLabels, label)
	print(TXT)
	return label
end

function ConsoleWarn(TXT: string)
	Console(TXT, System.Configurables.ConsoleWarningColor)
end

--Daemons

local Daemons = {
	DiskSyncer = function()
		while task.wait(1) do
			local num = #FindParts("Disk")
			if num ~= System.DiskCount then
				if num > System.DiskCount  then
					MirrorDataToFile()
					Beep(1)
					Console("New Disk Detected")
				elseif num < System.DiskCount then
					MirrorDataToFile()
					Beep(1)
					Console("Disk Removed")
				end
			end
		end
	end,
}

--applets

--keyboard modes

local KeyboardModes = {
	modem = function(txt,plr)
		if txt == "qa!" then
			System.KeyBoardFocus.Mode = nil
			System.KeyBoardFocus.SubMode = nil

			if not System.Parts.Modem then
				ConsoleWarn("Modem Missing")
				return
			end
			System.Connections.ModemConnect:Disconnect()	
			ConsoleWarn("System.Connections.ModemConnect has been disconnected")

			txt = `{plr} has disconnected.`
		end
		
		local Modem = System.Parts.Modem
		
		local ContentToSend = txt

		local function GenerateID(Len:number)
			local Length = Len or 7 -- standard is 7 digits
			local ID = "MID:"
			for i = 1, Len do
				ID = ID..tostring(math.random(0,9))
			end
			return ID
		end

		local MMCM = {
			SMMC = function() -- standard Messaging for Modem Com

				ContentToSend = `{GenerateID(7)} {plr} | {txt}`

				Console(`[You][SMMC][{Modem.NetworkID}]: {plr} | {txt}`,Color3.fromRGB(85, 0, 255))
			end,
			SM = function() -- standard Messaging
				ContentToSend = `{plr} | {txt}`
				Console(`[You][SM][{Modem.NetworkID}]: {txt}`,Color3.fromRGB(85, 0, 255))
			end,
			ATMS = function() -- Advanced Table-based Message System
				local Message = {
					sender = plr;
					content = txt;
					MSGID = GenerateID(64)
				}
				ContentToSend = JSONEncode(Message)
				Console(`[You][ATMS][{Modem.NetworkID}]: {txt}`,Color3.fromRGB(85, 0, 255))
			end,
		}

		local Submode = string.upper(System.KeyBoardFocus.SubMode)

		if MMCM[Submode] then
			MMCM[Submode]()
		else
			MMCM.SM()
			Console("Submode not specified, defaulting to SM.")
			System.KeyBoardFocus.SubMode = "sm"
		end 

		Modem:SendMessage(ContentToSend)	
	end;
	response = function(txt,plr)

	end;
}

--SYSTEM INITIALIZATION FUNC

SYSTEMINITFUNC = {
	INITFRAMES = function()
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

			System.Terminal.MainFrames["MainFrames"..i] = frame
			print(System.Terminal.MainFrames["MainFrames"..i])
		end
	end,
	INITPARTS = function()
		Console("Finding Parts..")
		local PartCache
		for _, PartName in PartstoGet do
			PartCache = GetPart(PartName)
			if PartCache then
				System.Parts[PartCache.ClassName] = PartCache
				Console("[<b>OK</b>] "..PartName,Color3.fromHex("#76946A"))
			else
				ConsoleWarn("[<b>MISSING</b>] "..PartName)
			end
		end
	end,
	INITPORTS = function()
		Console("Finding Ports..")
		for _, port in GetPorts() do
			Console(`[<b>PORT</b>] {port.PortID}`)
		end
	end,
	INITKEYBOARD = function()
		Console("Starting Keyboard..")
		local Keyboard = GetPart("Keyboard")

		if Keyboard then
			Console("Connecting Keyboard..")
			local Connection
			Connection = Keyboard.TextInputted:Connect(function(txt,plr)
				local Cleanedtxt = string.gsub(txt, "\n", "")
				if KeyboardModes[System.KeyBoardFocus.Mode] then
					KeyboardModes[System.KeyBoardFocus.Mode](Cleanedtxt,plr)
				else
					System.KeyBoardFocus.Mode = nil
					Console("root",Color3.fromHex("#7E9CD8"))
					Console("	$ "..Cleanedtxt,Color3.fromHex("#98BB6C"))
					CMDInterpeter(Cleanedtxt)
				end
			end)

			table.insert(System.Connections,Connection)
		else
			Console("Keyboard missing!")
		end
	end,
	INITDISK = function()
		Console("Finding and copying Disk Data to System..")
		Console("[<b>FILES</b>]")
		MirrorDataToFile()

		for i, d in FindParts("Disk") do
			Console(`[<b>Disk{i}Files</b>]`)
			Console("	---------------------")
			local d = ""
			for Path, Data in System[`Disk{i}`].Files do
				Console(`{Path}`,Color3.fromHex("#7FB4CA"))
			end
			Console("	---------------------")
		end
	end,
	INITDAEMON = function()
		for name, d in Daemons do
			local daemonthread = coroutine.create(d)
			coroutine.resume(daemonthread)
			Console("DAEMON: "..name)
			table.insert(System.Daemons, daemonthread)
		end
	end,
}


function InitSystem()
	for _, func in pairs(SYSTEMINITFUNC) do
		func()
	end
end

--Universal helpers


--WOS helpers

local function tableReplicate(tableToCopy)
	local newTable = {}
	for i, v in pairs(tableToCopy) do
		newTable[i] = v
	end
	return newTable
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



	return Code

end

function pkillall()
	Console("Attempting to kill all threads")

	for i, PID in pairs(System.Threads) do
		local m, e = pcall(function()
			-- destroy elements first
			for _, e in pairs(PID.Elements) do
				if e then
					pcall(function()
						e:Destroy()
					end)
				end
			end

			-- then kill thread
			if coroutine.status(PID.Thread) ~= "dead" then
				pcall(function()
					coroutine.close(PID.Thread)
				end)
			end
		end)
		Beep()
	end

	System.Threads = {}
end

function RunFunction(code)
	Console([[
	VTBOS SANBOXED RUNFUNCTION HELPER
	]])

	local sandboxFunc = {}
	local PID = {
		Descriptor = System.PIDCount+1;
		Thread = nil;
		Elements = {};
	}

	local function MethodSubsituter(Method)
		code = string.gsub(code, `([%a_][%w_]*)%s*:%s*{Method}%(`, `{Method}(`)
	end

	System.PIDCount+=1

	sandboxFunc.GetPartFromSystem = function(partName)
		local part = System.Parts[partName]
		if not part then
			ConsoleWarn("Process failed to find " .. partName)
		end
		return part
	end

	local FunctionFrame = screens[1]:CreateElement('Frame',{
		AnchorPoint = Vector2.new(0.5,0.5);
		Position = UDim2.fromScale(0.5,0.5);
		Size = UDim2.fromScale(0.6,0.6);
		BackgroundColor3 = Color3.fromRGB(0, 0, 0);
	})

	table.insert(PID.Elements,FunctionFrame)

	sandboxFunc.CreateElementSandboxed = function(type1, params)
		local element = screens[1]:CreateElement(type1, params)
		element.Parent = FunctionFrame
		table.insert(PID.Elements,element)
		--Console("Element Created			"..type1)
		--Beep()
		return element
	end

	local sandboxEnv = {
		Console = Console,
		ConsoleWarn = ConsoleWarn,
	}

	local sandboxmethods = {
		CreateElement = sandboxFunc.CreateElementSandboxed,
		ClearElements = function() Console("Cannot Clear Elements") Beep(0.1) end,
	}

	setmetatable(sandboxEnv, {
		__index = _G
	})

	local env = tableReplicate(getfenv())

	env.getfenv = function()
		return env
	end

	for i,v in sandboxEnv do
		env[i] = v
	end

	for i,v in sandboxmethods do
		env[i] = v
		Console(i)
		MethodSubsituter(i)
	end

	local thread = coroutine.create(function()
		local func, compileErr = loadstring(code)
		setfenv(func,env)
		if not func then
			ConsoleWarn("Compile error: " .. tostring(compileErr))
			KillPID(PID.Descriptor)
			return
		end

		local success, execErr = pcall(func)
		if not success then
			ConsoleWarn("Runtime error: " .. tostring(execErr))
			KillPID(PID.Descriptor)
		else
			Console("executed successfully")
		end
	end)

	PID.Thread = thread

	table.insert(System.Threads, PID)
	coroutine.resume(thread)
end

function ModifyConsoleLine(TextLabel:TextLabel,Text)
	TextLabel.Text = Text
end

function FlagInterater(cmd)
	Console("options")
	for _, v in CMDS[cmd].Flags do
		Console("	"..v)
	end
	Console("	")
end

function FindFile(path)
	local Data
	local DiskFound

	--Atempts to find Data
	for i = 1, System.DiskCount do
		if System[`Disk{i}`].Files[path] then
			Data = System[`Disk{i}`].Files[path]
			DiskFound = i
			break
		end
	end

	if Data == nil then
		ConsoleWarn("File not found")
		return
	else
		return Data
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


--Initialize System (pcall wrapped)
local Success, Error = pcall(function()
	InitSystem()
end)

if not Success then
	ConsoleWarn("SYSTEM FAILED TO START")
	ConsoleWarn(Error)
	Beep(0.2)
else
	Console("SYSTEM STARTED")
	Beep()
end

coroutine.yield()
