Const CMAXRACERS:Int = 23
Const gServerListURL:String = "http::www.newstargames.com/gameservers/gameservers_nsgp127.php"
Const gThreaded:Int = False

' Packet type
Const CPACKET_PING:Byte = 1, CPACKET_PONG:Byte = 2, CPACKET_CHAT:Byte = 3, CPACKET_STATUS:Byte = 4, CPACKET_CARDATA:Byte = 5, CPACKET_CARINFO:Byte = 6
Const CPACKET_WEATHERDATA:Byte = 7, CPACKET_USERNAME:Byte = 8, CPACKET_PLAYERLIST:Int = 9, CPACKET_FINISHTIME:Int = 10, CPACKET_TEAMCHOICE:Int = 11
Const CPACKET_LIGHTS:Byte = 12, CPACKET_READYORNOT:Byte = 13

' Network status
Const CNETWORK_NONE:Byte = 0, CNETWORK_LOBBY:Byte = 1, CNETWORK_LOADRACE:Byte = 2, CNETWORK_RACESETUP:Byte = 3, CNETWORK_RACEREADY:Byte = 4
Const CNETWORK_RACE:Byte = 5

' Network channels
Const CNETCHANNEL_PING:Int = 1, CNETCHANNEL_CHAT:Int = 2, CNETCHANNEL_STATUS:Int = 3, CNETCHANNEL_WEATHERDATA:Int = 4, CNETCHANNEL_TIMES:Int = 5

' Car data is sent on channel 100+CarId. This is so a car data packet (car 1) isn't discarded when another packet (car 2) beats it to the destination.
Const CNETCHANNEL_CARDATA:Int = 6

Type TOnline
	' Globals
	Global udpport:Int
	Global gPacketSendRate:Int
	Global gLan:Int = False
	Global gLastServerCheck:Int = 0	
	
	' Screen stuff
	Global pan_Online:fry_TPanel
	Global btn_Online_Exit:fry_TButton 
	Global btn_Online_Lan:fry_TButton 
	Global tbl_Online_Servers:fry_TTable
	Global tbl_Online_Chat:fry_TTable
	Global tbl_Online_Players:fry_TTable
	Global btn_Online_Refresh:fry_TButton
	Global btn_Online_Host:fry_TButton
	Global btn_Online_Join:fry_TButton
	Global btn_Online_Quit:fry_TButton
	Global btn_Online_Play:fry_TButton
	Global btn_Online_Kick:fry_TButton
	Global txt_Online_Chat:fry_TTextField
	Global lbl_Online_Chat:fry_TLabel
	Global lbl_Online_Track:fry_TLabel
	Global cmb_Online_Track:fry_TComboBox
	Global cmb_Online_Team:fry_TComboBox
	Global lbl_Online_ConnectedTo:fry_TLabel
	Global chk_Online_Bots:fry_TCheckBox
	Global chk_Online_Collisions:fry_TCheckBox
	Global chk_Online_Quali:fry_TCheckBox
	
	' Online stuff
	Global netstatus:Byte = CNETWORK_NONE	' Current status for a networked game
	Global username:String = ""
	Global gamename:String = "" 
	Global hosting:Int = False				' Host or client
	Global myhost:THost						' Every player has a host object (even if not hosting)
	Global passwordlist:TList = CreateList()' Keeps a list of passwords for the host servers
	Global mypts:Int = 0					' Host stores own points
	Global mylaptime:Int = 0
	Global readyornot:Int = False
	
	' ------
	' Set Up
	' ------
	
	Function SetUpOnline()
		AppLog "TOnline.SetUpOnline()"
		udpport = LoadVariable(gAppLoc+"Settings/Engine.ini", "udpport", 0, 99999999)
		gPacketSendRate = LoadVariable(gAppLoc+"Settings/Engine.ini", "packetsendrate", 0, 9999)
			
		pan_Online = fry_TPanel(fry_GetGadget("pan_online"))
		tbl_Online_Servers = fry_TTable(fry_GetGadget("pan_online/tbl_servers"))
		tbl_Online_Chat = fry_TTable(fry_GetGadget("pan_online/tbl_chat"))
		tbl_Online_Players = fry_TTable(fry_GetGadget("pan_online/tbl_players"))
		btn_Online_Lan = fry_TButton(fry_GetGadget("pan_online/btn_lan"))
		btn_Online_Refresh = fry_TButton(fry_GetGadget("pan_online/btn_refresh"))
		btn_Online_Host = fry_TButton(fry_GetGadget("pan_online/btn_host"))
		btn_Online_Join = fry_TButton(fry_GetGadget("pan_online/btn_join"))
		btn_Online_Quit = fry_TButton(fry_GetGadget("pan_online/btn_quit"))
		btn_Online_Play = fry_TButton(fry_GetGadget("pan_online/btn_play"))
		btn_Online_Kick = fry_TButton(fry_GetGadget("pan_online/btn_kick"))
		btn_Online_Exit = fry_CreateImageButton("btn_Online_Exit", gAppLoc+"Skin/Graphics/Buttons/QuitSmall.png", pan_Online.gW-26, 10, 16, 16, pan_Online)
		txt_Online_Chat = fry_TTextField(fry_GetGadget("pan_online/txt_chat"))
		lbl_Online_Chat = fry_TLabel(fry_GetGadget("pan_online/lbl_chat"))
		lbl_Online_Track = fry_TLabel(fry_GetGadget("pan_online/lbl_track"))
		cmb_Online_Track = fry_TComboBox(fry_GetGadget("pan_online/cmb_track"))
		cmb_Online_Team = fry_TComboBox(fry_GetGadget("pan_online/cmb_team"))
		lbl_Online_ConnectedTo = fry_TLabel(fry_GetGadget("pan_online/lbl_connectedto"))
		chk_Online_Bots = fry_TCheckBox(fry_GetGadget("pan_online/chk_bots"))
		chk_Online_Collisions = fry_TCheckBox(fry_GetGadget("pan_online/chk_collisions"))
		chk_Online_Quali = fry_TCheckBox(fry_GetGadget("pan_online/chk_quali"))
		chk_Online_Bots.SetState(True)
		chk_Online_Collisions.SetState(True)
		chk_Online_Quali.SetState(False)
	End Function
	
	Function SetUpOnlineLobby1()
		AppLog "TOnline.SetUpOnlineLobby1()"
		' Make sure your server isn't remaining from last logon
		Local stream:TStream = OpenStream(gServerListURL+"?action=removeserver")
		If stream Then stream.Close()
		
		If gDebugMode = True	' RELEASE NOTE
			DoMessage("CMESSAGE_ONLINEDEBUGMODE")
			Return
		End If
		
		txt_MessageBox_Txt.SetText(username.Replace(" (M)", "").Replace(" (D)", ""))
		DoMessage("Name", False,,,,,True)
		username = txt_MessageBox_Txt.GetText()
		If Len(username) > 16 Then username = Left(username, 16)
		username = username.Replace(":", "")
		
		If username.Length < 3 Then username = "User_"+Rand(9999)
		
		If gDemo
			If cmb_Mod.SelectedItem() > 0
				username:+" (D,M)"
			Else
				username:+" (D)"
			EndIf
		ElseIf cmb_Mod.SelectedItem() > 0
			username:+" (M)"
		End If
		
		' Open quickrace file and load options
		If db Then db.Close()
		
		' Open db
		OpenQuickRaceDb()
		
		' Update track combo
		cmb_Online_Track.ClearItems()
		Local dir:Int = ReadDir(gSaveloc+"/Tracks")
		
		Repeat
			Local trackname$=NextFile( dir )
			If Right(trackname,4) = ".trk" 
				cmb_Online_Track.AddItem(Left(trackname, Len(trackname)-4))
			EndIf
			If trackname="" Exit
		Forever
		
		CloseDir dir
		
		cmb_Online_Track.SelectItem(0)
		SetUpOnlineLobby2()
	End Function
	
	Function SetUpOnlineLobby2()
		AppLog "TOnline.SetUpOnlineLobby2()"
		
		netstatus = CNETWORK_LOBBY
		fry_SetScreen("screen_online")
		
		' If peers exist (post race) then refresh last comms so it doesn't disconnect
		If myhost And chk_Online_Quali.GetState() = False 		
			' Update player points
			If hosting
				TCar.sortby = CSORT_FINISHTIME
				TCar.list.Sort()
				
				Local pos:Int = 1
				For Local c:TCar = EachIn TCar.list
					AppLog c.mydriver.name+": "+track.GetPositionPoints(pos)
					
					If c.mydriver.name = username
						mypts:+track.GetPositionPoints(pos)
						mylaptime = 0
					Else
						For Local p:TPeer = EachIn myhost.peers
							If TPeerObject(p.userdata).name = c.mydriver.name
								TPeerObject(p.userdata).points:+track.GetPositionPoints(pos)
							End If
						Next
					End If
					
					pos:+1
				Next
			End If
		EndIf
		
		If hosting 
			For Local p:TPeer = EachIn myhost.peers
				If TPeerObject(p.userdata) Then TPeerObject(p.userdata).readyornot = False
			Next
			
			BroadcastPlayerList()
		Else
			readyornot = False
			RefreshReadyButton()
		EndIf
		
		If myhost Then SendNetStatus(netstatus)
		RefreshHostInfo()
		
		' Reset quali option after race
		chk_Online_Quali.SetState(False)
		
		RefreshButtons()
		
		' Set up race objects
		TNation.SelectAll()
		TTeam.SelectAll()
		TDriver.SelectAll()
		TCar.ClearAll()
		
		Local sel:Int = cmb_Online_Team.SelectedItem()
		If sel < 0 Then sel = 0
		cmb_Online_Team.ClearItems()
		cmb_Online_Team.AddItem(GetLocaleText("Random"))
		
		TDriver.sortby = CSORT_DRIVERID
		TDriver.list.Sort()
		
		For Local drv:TDriver = EachIn TDriver.list
			If drv.team > 0
				TCar.Create(CCONTROLLER_CPU, drv)
				
				Local tname:String = TTeam.GetById(drv.team).name
				If drv.drivernumber = 1 Then cmb_Online_Team.AddItem(tname); AppLog tname
			EndIf
		Next
		cmb_Online_Team.SelectItem(sel)
		
		' Flush combo events
		While fry_PollEvent() Wend
		
		AddPlayerToList()
	End Function
	
	Function Quit()
		AppLog "TOnline.Quit()"
		
		db.Close()
		netstatus = CNETWORK_NONE
		TCar.ClearAll()
		gMyDriverId = 1
				
		If myhost
			myhost = Null
			GCCollect
			hosting = False
			tbl_Online_Chat.ClearItems()
		EndIf
		
		fry_SetScreen("screen_start")
	End Function
	
	Function RefreshButtons()
		' Refresh buttons
		
		btn_Online_Lan.SetAlpha(1.0)
		Select gLan
		Case True	btn_Online_Lan.SetText(GetLocaleText("LAN"))
		Case False	btn_Online_Lan.SetText(GetLocaleText("Internet"))
		End Select
		
		btn_Online_Host.SetText(GetLocaleText("Host Game"))
		btn_Online_Host.SetAlpha(1.0)
		btn_Online_Join.SetText(GetLocaleText("Join Game"))
		btn_Online_Join.SetAlpha(1.0)
		btn_Online_Play.Hide()
		btn_Online_Play.SetAlpha(1.0)
		btn_Online_Kick.Hide()
		lbl_Online_Track.Hide()
		cmb_Online_Track.Hide()
		chk_Online_Bots.Hide()
		chk_Online_Collisions.Hide()
		chk_Online_Quali.Hide()
		tbl_Online_Chat.Hide()
		txt_Online_Chat.Hide()
		lbl_Online_Chat.Hide()
		
		If myhost
			btn_Online_Lan.SetAlpha(0.5)
			tbl_Online_Chat.Show()
			txt_Online_Chat.Show()
			lbl_Online_Chat.Show()
			btn_Online_Kick.Show()
			
			If readyornot
				btn_Online_Kick.SetText(GetLocaleText("Ready"))
				btn_Online_Kick.SetColour(0,255,0)
			Else
				btn_Online_Kick.SetText(GetLocaleText("Not Ready"))
				btn_Online_Kick.SetColour(255,0,0)
			EndIf
		End If
		
		If hosting
			lbl_Online_ConnectedTo.SetText(GetLocaleText("Host"))
			btn_Online_Host.SetText(GetLocaleText("Cancel Host"))
			btn_Online_Join.SetAlpha(0.5)
			btn_Online_Play.Show()
			btn_Online_Kick.SetText(GetLocaleText("Kick"))
			lbl_Online_Track.Show()
			cmb_Online_Track.Show()
			chk_Online_Bots.Show()
			chk_Online_Collisions.Show()
			chk_Online_Quali.Show()
						
			If netstatus >= CNETWORK_LOADRACE
				btn_Online_Play.SetAlpha(0.5)
				lbl_Online_Track.Hide()
				cmb_Online_Track.Hide()
				chk_Online_Bots.Hide()
				chk_Online_Collisions.Hide()
				chk_Online_Quali.Hide()
			EndIf
		Else
			If myhost
				btn_Online_Host.SetAlpha(0.5)
				btn_Online_Join.SetText(GetLocaleText("Leave Game"))
			Else
				lbl_Online_ConnectedTo.SetText("")
			End If
		EndIf
	End Function
	
	' -------------
	' Host Controls
	' -------------
	
	Function SwitchLanMode()
		If btn_Online_Lan.gAlpha <> 1.0 Then Return
		If myhost Then Return
		
		gLan = Not gLan
		
		Global message:Int = False
		If gLan And Not message Then DoMessage("CMESSAGE_LANGAMEINSTRUCS"); message = True
		
		RefreshHostTable()
		RefreshButtons()
	End Function
	
	Function Host()
		If btn_Online_Host.gAlpha <> 1.0 Then Return
		AppLog "TOnline.Host()"
		
'		If gDemo Then DoMessage("CMESSAGE_DEMOHOSTING"); Return	' RELEASE NOTE
		
		mypts = 0
		mylaptime = 0
		readyornot = False
		
		' Already hosting so disconnect
		If hosting
			DisconnectPeersAll()
			RefreshHostTable()
		Else	
			' Choose race settings before hosting	
			If fry_ScreenName() <> "screen_options"
				SetUpScreen_Options()
				Return
			End If
			
			' Create host
			myhost = THost.Create(DottedIP(HostIp("")), udpport, CMAXRACERS)
			
			If Not myhost 
				DoMessage("CMESSAGE_COULDNOTHOST")
				Return
			ElseIf gLan
				hosting = True
			Else
				' Set name for hosts game
				txt_MessageBox_Txt.SetText(username)
				DoMessage("CMESSAGE_HOSTGAMENAME",,,,,,True)
				gamename = txt_MessageBox_Txt.GetText()
				
				If Len(gamename) < 3 Then gamename = username
				gamename = gamename.Replace("*", "")
				gamename = gamename.Replace(":", "")
				gamename = gamename.Replace("|", "")
				gamename = gamename.Replace("/", "")
				gamename = gamename.Replace("\", "")
				gamename = gamename.Replace(" ", "_")
				
				' Set password
				txt_MessageBox_Txt.SetText("")
				DoMessage("CMESSAGE_HOSTPASSWORD",,,,,,True)
				
				Local pass:String = txt_MessageBox_Txt.GetText()
				pass = pass.Replace("*", "")
				pass = pass.Replace(":", "")
				pass = pass.Replace("|", "")
				pass = pass.Replace("/", "")
				pass = pass.Replace("\", "")
				pass = pass.Replace(" ", "_")
				If Len(pass) > 0 Then gamename:+":"+pass
				
				If myhost.Publish(gServerListURL, gamename, GetTrackName(), GetStringSettings(), 1, GetStringNetStatus(netstatus))
					hosting = True
					If Len(pass) > 0 Then DoMessage("CMESSAGE_PASSWORDSET",,pass)
				Else
					myhost = Null
					GCCollect
					DoMessage("CMESSAGE_COULDNOTHOST")
				End If
			EndIf
		EndIf
		
		RefreshHostInfo()
		RefreshButtons()
	End Function
	
	Function GetTrackName:String()
		Return "01_Australia"
	End Function
	
	Function GetStringSettings:String()
		Local settings:String = String(OpLaps)+"_Laps"
		
		Select OpDifficulty
		Case 1	settings:+",Lvl1"
		Case 2	settings:+",Lvl2"
		Case 3	settings:+",Lvl3"
		Case 4	settings:+",Lvl4"
		End Select
		
		If OpFuel
			settings:+",F"
		EndIf
	
		If OpDamage
			settings:+"D"
		EndIf
		
		If OpTyres
			settings:+"T"
		EndIf
		
		If OpKers
			settings:+"K"
		EndIf
		
		If chk_Online_Bots.GetState()
			settings:+"C"
		EndIf
		
		If chk_Online_Quali.GetState()
			settings:+"Q"
		EndIf
		
		If chk_Online_Collisions.GetState()
			settings:+"X"
		EndIf
		
		Return settings
	End Function
	
	Function GetStringNetStatus:String(st:Int)
		Select st
		Case CNETWORK_NONE			Return "Offline"
		Case CNETWORK_LOBBY			Return "Lobby"
		Case CNETWORK_LOADRACE		Return "Loading"
		Case CNETWORK_RACESETUP		Return "Race Setup"
		Case CNETWORK_RACEREADY		Return "Grid"
		Case CNETWORK_RACE			Return "Racing"
		End Select
	End Function
	
	Function Kick()
		Local sel:Int = tbl_Online_Players.SelectedItem()
		If sel < 0 Then DoMessage("CMESSAGE_SELECTAPLAYER"); Return
		
		Local kickname:String = tbl_Online_Players.GetText(sel, 0)
		
		' Host kicks self?
		If kickname = username Then Return
		
		For Local p:TPeer = EachIn myhost.peers
			If p.userdata
				Local data:TPeerObject = TPeerObject(p.userdata)
				If data.name = kickname
					myhost.Disconnect(p)
					WaitForEvents(1000)
					p = Null
				End If
			EndIf
		Next
		GCCollect
		
		' Make sure host isn't only one loading race
		If netstatus = CNETWORK_LOADRACE
			Local onlyme:Int = True
			For Local p:TPeer = EachIn myhost.peers
				If p.userdata
					Local data:TPeerObject = TPeerObject(p.userdata)
					If data.status = CNETWORK_LOADRACE Or data.status = CNETWORK_RACESETUP Or data.status = CNETWORK_RACEREADY
						onlyme = False
					EndIf
				EndIf
			Next
			
			If onlyme
				' Cancel start race
				netstatus = CNETWORK_LOBBY
			Else
				' If someone kicked during loadrace then see if remaining players are all ready to go
				CheckAllReady()
			EndIf
		EndIf
		
		BroadcastPlayerList()
		RefreshHostInfo()
		RefreshButtons()
	End Function
	
	Function Play()
		AppLog "Play"
		If Not gDebugMode 
			If myhost.peers.Count() < 1 Then DoMessage("CMESSAGE_NEEDCLIENTS"); Return
			If btn_Online_Play.gAlpha <> 1 Then Return
		EndIf
		
		For Local peer:TPeer = EachIn myhost.peers
			If peer.userdata And TPeerObject(peer.userdata).readyornot = 0 Then DoMessage("CMESSAGE_CLIENTNOTREADY"); Return
		Next
	
		' Set weather and tell clients what to load
		Local id:Int = 0
		Select cmb_Online_Track.SelectedText()
		Case "01_Bahrain"			id = 1
		Case "02_Australia"			id = 2
		Case "03_Malaysia"			id = 3
		Case "04_China"				id = 4
		Case "05_Spain"				id = 5
		Case "06_Monaco"			id = 6
		Case "07_Turkey"			id = 7
		Case "08_Canada"			id = 8
		Case "09_Europe"			id = 9
		Case "10_Britain"			id = 10
		Case "11_Germany"			id = 11
		Case "12_Hungary"			id = 12
		Case "13_Belgium"			id = 13
		Case "14_Italy"				id = 14
		Case "15_Singapore"			id = 15
		Case "16_Japan"				id = 16
		Case "17_Korea"				id = 17
		Case "18_Brasil"			id = 18
		Case "19_Abu Dhabi"			id = 19
		End Select
		
		Local climate:Int = Rand(3)
		If id > 0 Then GetDatabaseInt("climate", "track", id)
		track.weather.SetUpWeather(climate)
		
		' Host needs to assign car ids
		SetUpCars()
		
		SendNetStatus(CNETWORK_LOADRACE)	'Only host sends this status. Clients will load track then send back CNETWORK_RACEREADY.
		
		If myhost.peers.Count() = 0 And gDebugMode
			netstatus = CNETWORK_RACEREADY
			OnlineRace(TOnline.cmb_Online_Track.SelectedText())
		End If
		
	End Function
	
	Function SetUpCars()
		' Reset all and randomize cars
		For Local s:TCar = EachIn TCar.list
			s.randno = Rand(256)
			s.mydriver.name = "COM"
			s.mydriver.shortname = "COM"
			s.controller = CCONTROLLER_CPU
		Next
		
		TCar.sortby = CSORT_RANDOM
		TCar.list.Sort()
		
		' Assign car to self
		For Local c:TCar = EachIn TCar.list
			If c.mydriver.name = "COM" 
				c.mydriver.name = username
				c.mydriver.shortname = username
				c.controller = CCONTROLLER_HUMAN
				gMyDriverId = c.mydriver.id
				Exit
			EndIf
		Next
			
		' Assign each peer a car
		For Local p:TPeer = EachIn myhost.peers
			For Local c:TCar = EachIn TCar.list
				If c.mydriver.name = "COM" 
					c.mydriver.name = TPeerObject(p.userdata).name
					c.mydriver.shortname = TPeerObject(p.userdata).name
					c.controller = CCONTROLLER_REMOTE
					Exit
				EndIf
			Next
		Next
		
		' Reset rand number to set up grid order
		For Local s:TCar = EachIn TCar.list
			s.randno = -(9999999+Rand(9999))	' Use high number so if someone didn't complete quali they will be at the back
			
			' Check to see if a quali time was set. If so use that as your grid order 
			If s.mydriver.name = username
				If mylaptime > 0 Then s.randno = -mylaptime
				mylaptime = 0
			Else
				' Do same for peers
				For Local p:TPeer = EachIn myhost.peers
					If TPeerObject(p.userdata).name = s.mydriver.name
						If TPeerObject(p.userdata).qlaptime > 0 Then s.randno = -TPeerObject(p.userdata).qlaptime
						TPeerObject(p.userdata).qlaptime = 0
					EndIf
				Next
			EndIf
		Next
	End Function
	
	Function CheckAllReady()
		Local allready:Int = True
				
		For Local p:TPeer = EachIn myhost.peers
			If TPeerObject(p.userdata).status <> CNETWORK_RACEREADY Then allready = False					
		Next
		
		If allready
			netstatus = CNETWORK_RACEREADY
			OnlineRace(TOnline.cmb_Online_Track.SelectedText())
		EndIf
	End Function
	
	' -------------
	' Peer Controls
	' -------------
	
	Function Join()
		If btn_Online_Join.gAlpha <> 1.0 Then Return
		AppLog "TOnline.Join()"
		readyornot = False
		
		' Disconnect from host
		If myhost
			DisconnectPeersAll()
			gamename = ""
			RefreshHostTable()
		Else
			' Connect to host
			AppLog "Connect to host"
			Local sel:Int = tbl_Online_Servers.SelectedItem()
			Local gamehostport:Int = udpport
			Local gamehostip:String = tbl_Online_Servers.GetText(sel, 4)
			
			If gLan
				' Input lan address of host
				txt_MessageBox_Txt.SetText(DottedIP(HostIp("")))
				DoMessage("CMESSAGE_GETLANADDRESS",,,,,,True)
				gamehostip = txt_MessageBox_Txt.GetText().Replace(" ", "")
				
				' If host and client on same machine then increment port number of client
				If gamehostip = DottedIP(HostIp("")) Then gamehostport:+1
			Else
				RefreshHostTable()
				
				' Check host is ready and able
				If sel < 0 Then DoMessage("CMESSAGE_SELECTHOST"); Return
				If tbl_Online_Servers.GetText(,2) = "24 / 24" Then DoMessage("CMESSAGE_HOSTFULL"); Return
				If tbl_Online_Servers.GetText(,5) <> "Lobby" Then DoMessage("CMESSAGE_HOSTRACING"); Return
				
				' Check password
				Local count:Int = 0
				AppLog "passwordlist:"+passwordlist.Count()
				For Local pass:String = EachIn passwordlist
					AppLog "Password:"+pass
					If Len(pass) > 0 And count = sel
						txt_MessageBox_Txt.SetText("")
						DoMessage("CMESSAGE_JOINPASSWORD",,,,,,True)
						
						If txt_MessageBox_Txt.GetText() <> pass Then DoMessage("CMESSAGE_WRONGPASS"); Return
					End If
					count:+1
				Next
				
				' Make sure you have the track
				Local trackname:String = tbl_Online_Servers.GetText(sel, 1)
				Local file:String = gSaveloc+"Tracks/"+trackname+".trk"
				If FileType(file) <> 1
					DoMessage("CMESSAGE_TRACKDOESNOTEXIST",,trackname)
					Return
				EndIf
			EndIf
				
			myhost = THost.Create(DottedIP(HostIp("")), gamehostport, 1)
		
			If myhost
				myhost.Connect(gamehostip, udpport)
				
				For Local peer:TPeer = EachIn myhost.peers
					peer.userdata = New TPeerObject
					TPeerObject(peer.userdata).status = CNETWORK_LOBBY
				Next
				
				gamename = tbl_Online_Servers.GetText(sel, 0)
			EndIf
		EndIf
		
		AddPlayerToList()
		RefreshButtons()
	End Function
	
	Function DisconnectPeersAll()
		AppLog "Attempt disconnect from peers:"+myhost.peers.Count()
			
		For Local p:TPeer = EachIn myhost.peers
			myhost.Disconnect(p)
		Next
		WaitForEvents(1000)
		
		netstatus = CNETWORK_LOBBY
		myhost = Null	' This will call delete and clean up peers and server
		hosting = False
		tbl_Online_Chat.ClearItems()
		tbl_Online_Players.ClearItems()
		RefreshButtons()
		GCCollect
	End Function
	
	Function DoChatBox()
		Local txt:String = txt_Online_Chat.GetText()
		If Len(txt) > 256 Then txt = txt[..256]
		
		If Not myhost Then DoMessage("CMESSAGE_NOHOSTCHAT"); Return
		
		If Len(txt) > 0
			' Host sends chat to all, client sends chat to host. 
			' When host receives he sends to all too, so it bounces back to sender.
			SendChat(username, txt, hosting)
		End If
		
		ResetChatBox(True)
	End Function
	
	Function ResetChatBox(mode:Int)
		FlushKeys()
		txt_Online_Chat.SetText("")
		txt_Online_Chat.gCursor = 0
		txt_Online_Chat.gMode = mode
		txt_Online_Chat.gState = mode
		txt_Online_Chat.Refresh()
	End Function
	
	' ---------------
	' Sending Packets
	' ---------------
	
	Function AddPlayerToList:Object(data:Object = Null)
		AppLog "AddPlayerToList"
		If gLan Then Return Null
		
		' license
		Local license:String = "None"
	
		Local room:String = gamename.Replace(" ", "%20") 
		If room = "" Then room = "None"
		
		Local stream:TStream = OpenStream(gServerListURL+"?action=addplayer&playername="+username.Replace(" ", "%20")+"&license="+license+"&room="+room)
		If stream Then stream.close()
	End Function
	
	Function RefreshHostInfo:Object(data:Object = Null)
		If gLan Then Return Null
		
		If hosting And myhost And myhost.server
			AppLog "RefreshHostInfo"
			Local track:String = TOnline.cmb_Online_Track.SelectedText()
			track = track.Replace(" ", "%20")
			Local racers:Int = TOnline.myhost.peers.Count()+1
			myhost.server.Publish(gamename, track, GetStringSettings(), racers, GetStringNetStatus(netstatus))
		EndIf
		
		RefreshHostTable()
	EndFunction
	
	Function PingAll()
		If Not myhost Then Return
		
		Local packet:TPacket = New TPacket
		packet.WriteByte(CPACKET_PING)
		
		For Local peer:TPeer = EachIn myhost.peers
			AppLog "Ping: "+TPeerObject(peer.userdata).name
			TPeerObject(peer.userdata).pingsent = gMillisecs	
			myhost.SendPacket(peer,packet,CNETCHANNEL_PING)
		Next
	End Function
	
	Function Pong(peer:TPeer)
		AppLog "Pong"
		Local packet:TPacket = New TPacket
		packet.WriteByte(CPACKET_PONG)
		myhost.SendPacket(peer,packet,CNETCHANNEL_PING)
	End Function
	
	Function SendReadyOrNot()
		If Not myhost Then Return
		
		AppLog "SendReadyOrNot"
		Local packet:TPacket = New TPacket
		packet.WriteByte(CPACKET_READYORNOT)
		packet.WriteByte(readyornot)
		myhost.BroadcastPacket(packet, CNETCHANNEL_STATUS, PACKET_RELIABLE)
	End Function
	
	Function SendUsername()
		AppLog "SendUsername"
		
		Local tid:Int = 0
		If cmb_Online_Team.SelectedItem() > 0 Then tid = TTeam.GetByName(cmb_Online_Team.SelectedText()).id
		
		Local packet:TPacket = New TPacket
		packet.WriteByte(CPACKET_USERNAME)
		packet.WriteLine(username)
		packet.WriteByte(tid)
		myhost.BroadcastPacket(packet, CNETCHANNEL_STATUS, PACKET_RELIABLE)
	End Function
	
	Function SendTeamChoice()
		AppLog "SendTeamChoice"
		If Not myhost Then Return
		
		Local tid:Int = 0
		If cmb_Online_Team.SelectedItem() > 0 Then tid = TTeam.GetByName(cmb_Online_Team.SelectedText()).id
		
		Local packet:TPacket = New TPacket
		packet.WriteByte(CPACKET_TEAMCHOICE)
		packet.WriteByte(tid)
		
		For Local peer:TPeer = EachIn myhost.peers
			myhost.SendPacket(peer, packet, CNETCHANNEL_STATUS, PACKET_RELIABLE)
		Next
	End Function
	
	Function SendChat(from:String, txt:String, updatetable:Int = False)
		AppLog "SendChat"
		
		' Break long chats into separate lines
		Repeat
			Local str:String = txt	' str is the actual text that will be sent
			
			If Len(txt) > 54
				str = txt[..54]
				txt = txt[54..]
			Else
				txt = ""
			End If
			
			Local packet:TPacket = New TPacket
			packet.WriteByte(CPACKET_CHAT)
			packet.WriteLine(from)
			packet.WriteLine(str)
			myhost.BroadcastPacket(packet, CNETCHANNEL_CHAT, PACKET_RELIABLE)
			
			' Hosts chats don't bounce Back so stick it straight in the chat window
			If updatetable
				tbl_Online_Chat.AddItem([from, str])
				tbl_Online_Chat.ShowItem(tbl_Online_Chat.CountItems())
			End If
		Until txt = ""
		
		RefreshButtons()
	End Function
	
	Function SendNetStatus(status:Byte)
		AppLog "SendNetStatus:"+status		
		netstatus = status
			
		Local packet:TPacket = New TPacket
				
		' Set up packet
		packet.WriteByte(CPACKET_STATUS)
		packet.WriteByte(netstatus)
		
		Select netstatus
		Case CNETWORK_LOBBY
		Case CNETWORK_LOADRACE		' Only host sends this
			' Send race details
			packet.WriteLine(TOnline.cmb_Online_Track.SelectedText())
			packet.WriteInt(track.weather.cloud)
			packet.WriteInt(track.weather.cloudinc)
			packet.WriteInt(track.weather.doingweather)
			packet.WriteFloat(track.weather.wetness)
			packet.WriteByte(OpFuel)
			packet.WriteByte(OpDamage)
			packet.WriteByte(OpTyres)
			packet.WriteByte(OpKers)
			packet.WriteByte(OpLaps)
			packet.WriteByte(chk_Online_Bots.GetState())
			packet.WriteByte(chk_Online_Collisions.GetState())
			packet.WriteByte(chk_Online_Quali.GetState())
						
			' Pass names and new rands to clients
			TCar.sortby = CSORT_DRIVERID
			TCar.list.Sort()
			For Local s:TCar = EachIn TCar.list
				' Set driver team for car choice
				If s.mydriver.name = username
					If cmb_Online_Team.SelectedItem() > 0 Then s.mydriver.team = TTeam.GetByName(cmb_Online_Team.SelectedText()).id
				Else
					For Local peer:TPeer = EachIn myhost.peers
						If TPeerObject(peer.userdata).name = s.mydriver.name
							If TPeerObject(peer.userdata).teamid > 0 Then s.mydriver.team = TPeerObject(peer.userdata).teamid
						EndIf
					Next
				End If
				
				packet.WriteByte(s.mydriver.team)
				packet.WriteInt(s.randno)
				packet.WriteLine(s.mydriver.name)
			Next
		
			TCar.sortby = CSORT_RANDOM
			TCar.list.Sort()
		Case CNETWORK_RACESETUP
		Case CNETWORK_RACEREADY		' Only client sends this
		Case CNETWORK_RACE			' Only host sends this
		End Select
		
		' Send to all peers
		myhost.BroadcastPacket(packet, CNETCHANNEL_STATUS, PACKET_RELIABLE)
		
		' If netstatus has changed then refresh the host server details
		RefreshHostInfo()
		RefreshButtons()
	End Function
	
	Function BroadcastPlayerList()
		If Not hosting Then Return
		tbl_Online_Players.SetColumnTextAll([GetLocaleText("Player"), GetLocaleText("Status")+" / "+GetLocaleText("Ping"), GetLocaleText("tla_Points")])
		tbl_Online_Players.ClearItems()
		
		Local packet:TPacket = New TPacket
		packet.WriteByte(CPACKET_PLAYERLIST)
		packet.WriteByte(myhost.peers.Count()+1)
		
		packet.WriteLine(username)
		packet.WriteByte(netstatus)
		packet.WriteByte(0)	' Host doesn't have ready or not status
		packet.WriteInt(mypts)
		tbl_Online_Players.AddItem([username, GetStringNetStatus(netstatus), String(mypts)])
		
		For Local peer:TPeer = EachIn myhost.peers
			If peer.userdata
				' Send client data
				packet.WriteLine(TPeerObject(peer.userdata).name)
				packet.WriteByte(TPeerObject(peer.userdata).status)
				packet.WriteByte(TPeerObject(peer.userdata).readyornot)
				Local pts:Int = TPeerObject(peer.userdata).points 
				packet.WriteInt(pts)
				
				Local status:String = GetStringNetStatus(TPeerObject(peer.userdata).status)
				If status = "Lobby" And TPeerObject(peer.userdata).readyornot Then status = "Ready"
				status:+" / "+TPeerObject(peer.userdata).pingdelay

				
				tbl_Online_Players.AddItem([TPeerObject(peer.userdata).name, status, String(pts)])
			EndIf
		Next
		
		myhost.BroadcastPacket(packet, CNETCHANNEL_STATUS, PACKET_RELIABLE)
	End Function
	
	Function SendCarData(c:TCar)
		If Not myhost Then Return
		If myhost.peers.Count() = 0 Then Return

		Local packet:TPacket = New TPacket
		packet.WriteByte(CPACKET_CARDATA)
		packet.WriteByte(c.mydriver.id)
		packet.WriteByte(c.gassing)
		packet.WriteByte(c.steering)
		packet.WriteByte(c.boost)
		packet.WriteShort(c.direction)
		packet.WriteFloat(c.x+Cos(c.direction)*c.speed)
		packet.WriteFloat(c.y+Sin(c.direction)*c.speed)
		packet.WriteFloat(c.drift)
		packet.WriteFloat(c.steer)
		packet.WriteFloat(c.speed)
		packet.WriteFloat(c.xvel)
		packet.WriteFloat(c.yvel)
		packet.WriteShort(c.slipstream)
		
		' Clients will send to host. Host will send to all clients.
		For Local peer:TPeer = EachIn myhost.peers
			' Host sends car data to all clients except the client who controls this car itself
			If TPeerObject(peer.userdata).name <> c.mydriver.name
				myhost.SendPacket(peer, packet, CNETCHANNEL_CARDATA+c.mydriver.id)
			EndIf
		Next
	End Function
	
	Function SendCarInfo(c:TCar)
		If Not myhost Then Return
		If myhost.peers.Count() = 0 Then Return

		AppLog "CarSend:"+c.mydriver.id
		
		Local packet:TPacket = New TPacket
		packet.WriteByte(CPACKET_CARINFO)
		packet.WriteByte(c.mydriver.id)
		packet.WriteByte(c.tyretype)
		packet.WriteShort(c.tyrewear)
		packet.WriteShort(c.damage)
		packet.WriteShort(c.fuel)
		
		' Clients will send to host. Host will send to all clients.
		For Local peer:TPeer = EachIn myhost.peers
			' Host sends car data to all clients except the client who controls this car itself
			If TPeerObject(peer.userdata).name <> c.mydriver.name
				myhost.SendPacket(peer, packet, CNETCHANNEL_CARDATA+c.mydriver.id)
			EndIf
		Next
	End Function	
	
	Function SendWeatherData()		
		Local packet:TPacket = New TPacket
		packet.WriteByte(CPACKET_WEATHERDATA)
		packet.WriteInt(track.weather.cloud)
		packet.WriteInt(track.weather.cloudinc)
		packet.WriteInt(track.weather.doingweather)
		packet.WriteFloat(track.weather.wetness)
		myhost.BroadcastPacket(packet, CNETCHANNEL_WEATHERDATA)
		
	End Function
	
	Function SendRaceTime(c:TCar)
		Local packet:TPacket = New TPacket
		packet.WriteByte(CPACKET_FINISHTIME)
		packet.WriteByte(c.mydriver.id)
		packet.WriteInt(c.mydriver.lastracetime)
		packet.WriteInt(c.mydriver.iwaslapped)
		myhost.BroadcastPacket(packet, CNETCHANNEL_TIMES, PACKET_RELIABLE)
		
		If hosting Then mylaptime = c.mydriver.lastracetime
	End Function
	
	Function SendLightsInfo()
		Local packet:TPacket = New TPacket
		packet.WriteByte(CPACKET_LIGHTS)
		
		For Local peer:TPeer = EachIn myhost.peers
			myhost.SendPacket(peer, packet, CNETCHANNEL_TIMES, PACKET_RELIABLE)
		Next
	End Function
	
	' -----------------
	' Receiving Packets
	' -----------------
	
	Function GetServerList:Object(data:Object = Null)
		Local sel:Int = tbl_Online_Servers.SelectedItem()
		Local slist:String[] = TServer.Request(gServerListURL)
	
		passwordlist.Clear()
		tbl_Online_Servers.ClearItems()
		
		If gLan 
			If hosting
				Local track:String = TOnline.cmb_Online_Track.SelectedText()
				Local racers:String = TOnline.myhost.peers.Count()+1
				Local settings:String = GetStringSettings()
				settings = settings.Replace("_", " ")
				settings = settings.Replace(",", "  /  ")
				tbl_Online_Servers.AddItem([username, track, racers, settings, DottedIP(HostIp("")), GetStringNetStatus(netstatus)])
			EndIf
		Else
			For Local srv:String = EachIn slist
				AppLog srv
				Local ip:String = srv[..srv.find("|")]; srv = srv[srv.find("|")+1..]
				Local name:String = srv[..srv.find("|")]; srv = srv[srv.find("|")+1..]
				
				' Check for password
				Local pass:String = ""
				If name.Contains(":")
					pass = name[name.Find(":")+1..]
					name = "* "+name[..name.Find(":")]
				EndIf
				
				passwordlist.AddLast(pass)
				
				Local track:String = srv[..srv.find("|")]; srv = srv[srv.find("|")+1..]
				Local settings:String = srv[..srv.find("|")]; srv = srv[srv.find("|")+1..]
				Local racers:String = srv[..srv.find("|")]; srv = srv[srv.find("|")+1..]
				racers:+" / 24"
				Local status:String = srv
				
				settings = settings.Replace("_", " ")
				settings = settings.Replace(",", "  /  ")
				
				' If on lan, only update hosts table, don't send data to NSG
				tbl_Online_Servers.AddItem([name, track, racers, settings, ip, status])
			Next
		End If
		
		tbl_Online_Servers.SelectItem(sel)
	End Function
	
	Function GetPlayerList:Object(data:Object = Null)
		If gLan Then Return Null
		
		AppLog "GetPlayerList"
		tbl_Online_Players.SetColumnTextAll([GetLocaleText("Players Online"), GetLocaleText("Game"), ""])
		Local sel:Int = tbl_Online_Players.SelectedItem()
		tbl_Online_Players.ClearItems()
		
		Local stream:TStream=OpenStream(gServerListURL+"?action=listplayers")
		If Not stream Return Null
		
		While Not stream.Eof()
			Local s:String = ReadLine(stream)
			AppLog s
			
			If s.Trim().length > 0
				Local playername:String = s[..s.find("|")]; s = s[s.find("|")+1..]
				Local room:String = s
				
				If room.Contains(":") Then room = room[..room.Find(":")]	' Remove password
				tbl_Online_Players.AddItem([playername, room])
			EndIf
		Wend
		stream.close()
		
		tbl_Online_Players.SelectItem(sel)
	End Function
	
	Function UpdateNetwork()
		' If in lobby then refresh server list
		If netstatus = CNETWORK_LOBBY 
			If gMillisecs > gLastServerCheck+20000 Then RefreshHostTable()
			
			If KeyHit(KEY_ESCAPE) Then ResetChatBox(Not txt_Online_Chat.gMode)
		EndIf
		
		' If no host yet then return
		If Not myhost Then Return
		
		' Read events
		WaitForEvents(0)
		
		' Check if disconnected from host
		If myhost And hosting = False And myhost.peers.Count() = 0
			DoMessage("CMESSAGE_HOSTCONNECTIONLOST")
			myhost = Null
			GCCollect
			netstatus = CNETWORK_LOBBY
			tbl_Online_Chat.ClearItems()
			tbl_Online_Players.ClearItems()
			RefreshHostTable()
			RefreshButtons()
		End If
				
	End Function
	
	Function RefreshHostTable()
		AppLog "RefreshHostTable"
		PingAll()
				
		If gThreaded 
		'	DetachThread(CreateThread(RefreshHostInfo, Null))
		'	DetachThread(CreateThread(GetServerList, Null))
		'	DetachThread(CreateThread(AddPlayerToList, Null))	' Refresh player room
		'	If myhost = Null Then DetachThread(CreateThread(GetPlayerList, Null))	' If not in a room then get list of players in general lobby
		Else
			GetServerList(Null)	' Get list of available servers
			AddPlayerToList()	' Refresh player room
			If myhost = Null Then GetPlayerList(Null)	' If not in a room then get list of players in general lobby
		End If
		
		gLastServerCheck = gMillisecs
	End Function
	
	Function WaitForEvents(wait:Int)
		' Read events
		Local event:TEvent
		
		Repeat
			' See if skipping WaitEvent fixes slow down
			event = myhost.WaitEvent(wait)
			
			If event
				Local peer:TPeer = TPeer(event.source)
				
				' Make sure client has a custom data object
				If Not peer.userdata Then peer.userdata = New TPeerObject
				
				Select event.id
				Case EVENT_CONNECT
					AppLog "EVENT_CONNECT"
					
					If netstatus <> CNETWORK_LOBBY 
						myhost.Disconnect(peer)
					Else
						' Send out connection message when new player joins
						SendUsername()
						SendChat(username, "<Connected> "+gVersion)
						TPeerObject(peer.userdata).status = CNETWORK_LOBBY
				
						' Update host details
						BroadcastPlayerList()
						RefreshHostInfo()
					EndIf
					
				Case EVENT_DISCONNECT
					AppLog "EVENT_DISCONNECT"
					If hosting
						SendChat(TPeerObject(peer.userdata).name, "<Disconnected>")
						tbl_Online_Chat.AddItem([TPeerObject(peer.userdata).name, "<Disconnected>"])
						ResetDriverToCPU(TPeerObject(peer.userdata).name)
						BroadcastPlayerList()
						If netstatus = CNETWORK_LOBBY Then RefreshHostInfo()
					Else
						RefreshHostTable()
					EndIf
					
				Case EVENT_PACKETRECEIVE
					HandlePacket(peer, TPacket(event.extra))
					
				EndSelect
				
				' If no longer connected then cancel network updates
				If Not myhost Then Return
			EndIf
		
		Until Not event
	End Function
	
	Function HandlePacket(peer:TPeer, packet:TPacket)
		Select packet.ReadByte()
		Case CPACKET_USERNAME
			AppLog "CPACKET_USERNAME"
			TPeerObject(peer.userdata).name = packet.ReadLine()
			TPeerObject(peer.userdata).teamid = packet.ReadByte()
			BroadcastPlayerList()
			
		Case CPACKET_TEAMCHOICE
			AppLog "CPACKET_TEAMCHOICE"
			TPeerObject(peer.userdata).teamid = packet.ReadByte()
			
		Case CPACKET_PLAYERLIST
			AppLog "CPACKET_PLAYERLIST"
			tbl_Online_Players.SetColumnTextAll([GetLocaleText("Player"), GetLocaleText("Status"), GetLocaleText("tla_Points")])
			Local sel:Int = tbl_Online_Players.SelectedItem()
			tbl_Online_Players.ClearItems()	
			For Local u:Int = 1 To packet.ReadByte()
				Local hname:String = packet.ReadLine()
				
				' Show host name and ping time
				If u = 1 
					Local pingdelay:String = ""
					Local hst:TPeer = TPeer(myhost.peers.First())
					Local pob:TPeerObject
					If hst Then pob = TPeerObject(hst.userdata)
					If pob Then pingdelay = "  Ping: "+String(pob.pingdelay)
					
					Local hn:String = Left(hname,18)+pingdelay
					lbl_Online_ConnectedTo.SetText(GetLocaleText("Host")+": "+hn)
				EndIf
				
				Local status:String = GetStringNetStatus(packet.ReadByte())
				Local readyornot:Int = packet.ReadByte()
				Local points:String = String(packet.ReadInt())
				If readyornot = True And status = "Lobby" Then status = "Ready"
				tbl_Online_Players.AddItem([hname, status, points])
			Next
			tbl_Online_Players.SelectItem(sel)
			
		Case CPACKET_PING
			' Send back the pong
			Pong(peer)
			
		Case CPACKET_PONG
			Local d:Int = gMillisecs-TPeerObject(peer.userdata).pingsent
			TPeerObject(peer.userdata).pingdelay = d
			BroadcastPlayerList()
			
		Case CPACKET_CHAT
			AppLog "CPACKET_CHAT"
			Local from:String = packet.ReadLine()
			Local txt:String = packet.ReadLine()
			tbl_Online_Chat.AddItem([from, txt])
			tbl_Online_Chat.ShowItem(tbl_Online_Chat.CountItems())
			
			PlaySound(snd_SlotsWin, chn_FX)
			
			' Host is only player to receive chat from clients (as they only have 1 peer)
			' So broadcast this message to everyone else
			If hosting Then SendChat(from, txt)
			
			While tbl_Online_Chat.CountItems() > 50
				tbl_Online_Chat.RemoveItem(0)
			Wend
			
		Case CPACKET_STATUS
			AppLog "CPACKET_STATUS"
			Local status:Int = packet.ReadByte()
			TPeerObject(peer.userdata).status = status
			
			Select status
			Case CNETWORK_LOBBY
				AppLog "CNETWORK_LOBBY"
				
				' Host says, get back in lobby
				If Not hosting
					netstatus = status
				EndIf
					
			Case CNETWORK_LOADRACE
				AppLog "CNETWORK_LOADRACE"
				If Not hosting And netstatus = CNETWORK_LOBBY
					netstatus = status
					
					' Get race settings and race order
					Local trackname:String = packet.ReadLine()
					track.weather.cloud = packet.ReadInt()
					track.weather.cloudinc = packet.ReadInt()
					track.weather.doingweather = packet.ReadInt()
					track.weather.wetness = packet.ReadFloat()
					OpFuel = packet.ReadByte()
					OpDamage = packet.ReadByte()
					OpTyres = packet.ReadByte()
					OpKers = packet.ReadByte()
					OpLaps = packet.ReadByte()
					chk_Online_Bots.SetState(packet.ReadByte())
					chk_Online_Collisions.SetState(packet.ReadByte())
					chk_Online_Quali.SetState(packet.ReadByte())
					
					' Now order cars by driver id read new rands
					TCar.sortby = CSORT_DRIVERID
					TCar.list.Sort()
					
					For Local s:TCar = EachIn TCar.list
						' Set up remote and human controllers
						s.controller = CCONTROLLER_REMOTE
						
						s.mydriver.team = packet.ReadByte()
						
						' Get rand for every driver to mimic hosts grid
						s.randno = packet.ReadInt()
						
						' Read driver names
						s.mydriver.name = packet.ReadLine()
						s.mydriver.shortname = s.mydriver.name
						
						If s.mydriver.name = username 
							s.controller = CCONTROLLER_HUMAN
							gMyDriverId = s.mydriver.id
						EndIf
					Next
					
					TCar.sortby = CSORT_RANDOM
					TCar.list.Sort()
					
					If FileType(gSaveloc+"Tracks/"+trackname+".trk") = 1
						OnlineRace(trackname)
					Else
						DoMessage("CMESSAGE_TRACKDOESNOTEXIST",,trackname)
						Join()
					EndIf
				EndIf
			Case CNETWORK_RACESETUP
				AppLog "CNETWORK_RACESETUP"
				
			Case CNETWORK_RACEREADY		' Only client sends this. Host needs to count ready players then start race.
				AppLog "CNETWORK_RACEREADY"
				CheckAllReady()
				
			Case CNETWORK_RACE		' Clients need to get racing
				AppLog "CNETWORK_RACE"
				netstatus = status
			Default
			
			End Select
			
			BroadcastPlayerList()
			
		Case CPACKET_CARDATA
			Local id:Int = packet.ReadByte()
			AppLog "CPACKET_CARDATA:"+id
			Local s:TCar = TCar.SelectByDriverId(id)
			
			If s And s.controller = CCONTROLLER_REMOTE
				s.gassing = packet.ReadByte()
				s.steering = packet.ReadByte()
				s.boost = packet.ReadByte()
				s.direction = packet.ReadShort()
'				s.x = (s.x+packet.ReadShort())/2
'				s.y = (s.y+packet.ReadShort())/2
				s.x:+(packet.ReadFloat()-s.x)*0.5
				s.y:+(packet.ReadFloat()-s.y)*0.5				
				s.drift = packet.ReadFloat()
				s.steer = packet.ReadFloat()
				s.speed = packet.ReadFloat()
				s.xvel = packet.ReadFloat()
				s.yvel = packet.ReadFloat()
			'	s.slipstream = packet.ReadFloat()
			
				If hosting
					For Local p:TPeer = EachIn myhost.peers
						If TPeerObject(p.userdata).name <> s.mydriver.name
							myhost.SendPacket(p, packet, CNETCHANNEL_CARDATA+s.mydriver.id)
						EndIf
					Next
				End If
			EndIf
		
		Case CPACKET_CARINFO
			Local s:TCar = TCar.SelectByDriverId(packet.ReadByte())
			
			If s And s.controller = CCONTROLLER_REMOTE
				s.tyretype = packet.ReadByte()
				s.tyrewear = packet.ReadShort()
				s.damage = packet.ReadShort()
				s.fuel = packet.ReadShort()
				
				If hosting
					For Local p:TPeer = EachIn myhost.peers
						If TPeerObject(p.userdata).name <> s.mydriver.name
							myhost.SendPacket(p, packet, CNETCHANNEL_CARDATA+s.mydriver.id)
						EndIf
					Next
				End If
			EndIf
			
		Case CPACKET_WEATHERDATA
			AppLog "CPACKET_WEATHERDATA"
			track.weather.cloud = packet.ReadInt()
			track.weather.cloudinc = packet.ReadInt()
			track.weather.doingweather = packet.ReadInt()
			track.weather.wetness = packet.ReadFloat()
			
			' Just a quick check so that if race starts in the rain the volume and alpha are updated
			If track.weather.wetness >= 0.5
				If track.weather.volRain < 0.5 Then track.weather.volRain = 0.5
				If track.weather.alphaRain < 0.5 Then track.weather.alphaRain = 0.5
			End If
			
		Case CPACKET_FINISHTIME
			AppLog "CPACKET_FINISHTIME"
			Local s:TCar = TCar.SelectByDriverId(packet.ReadByte())
			
			If s And s.controller = CCONTROLLER_REMOTE
				s.mydriver.lastracetime = packet.ReadInt()
				s.mydriver.iwaslapped = packet.ReadInt()
				TPeerObject(peer.userdata).qlaptime = s.mydriver.lastracetime
				
				AppLog "Id:"+s.mydriver.id+"  Time:"+s.mydriver.lastracetime+"  Lapped:"+s.mydriver.iwaslapped
				
				TRaceReport.AddLap(gMillisecs-track.racestarttime, s.mydriver.name, 9999, s.mydriver.lastracetime,, s.mydriver.iwaslapped)
				
				If hosting
					For Local p:TPeer = EachIn myhost.peers
						If TPeerObject(p.userdata).name <> s.mydriver.name
							myhost.SendPacket(p, packet, CNETCHANNEL_TIMES, PACKET_RELIABLE)
						EndIf
					Next
				End If
			EndIf
		
		Case CPACKET_LIGHTS
			AppLog "CPACKET_LIGHTS"
			track.gridstarttime = 1
			
		Case CPACKET_READYORNOT
			If hosting
				TPeerObject(peer.userdata).readyornot = packet.ReadByte()
				BroadcastPlayerList()
			EndIf
		End Select
	End Function

	' ----------
	' Start Race
	' ----------
	
	Function OnlineRace(trackname:String = "")
		AppLog "OnlineRace:"+trackname
		MyFlushJoy()
		
		' Disable chat box
		ResetChatBox(False)
		
		' Delete com cars from the game
		If chk_Online_Bots.GetState() = False Or chk_Online_Quali.GetState() = True
			For Local c:TCar = EachIn TCar.list
				If c.mydriver.name = "COM" Then c.Clear(); TCar.list.Remove(c)
			Next
		EndIf
		GCCollect()
		
		Local pos:Int = 1
		For Local c:TCar = EachIn TCar.list
			c.position = pos
			pos:+1
		Next
		
		' Load your car image
		For Local c:TCar = EachIn TCar.list
			c.LoadCarImage(1, c.mydriver.team)
		Next
				
		track.mode = CTRACKMODE_DRIVE
		track.racestatus = CRACESTATUS_GRID
		track.LoadTrack(trackname, 0)
		SendNetStatus(CNETWORK_RACESETUP)
		track.totallaps = OpLaps
		If chk_Online_Quali.GetState() Then track.totallaps = 1
		track.PitStop()
		
		RaceEngine()
	End Function
	
	Function ResetDriverToCPU(name:String)
		For Local c:TCar = EachIn TCar.list
			If c.mydriver.name = name
				c.controller = CCONTROLLER_CPU
				c.mydriver.name = "COM"
				c.mydriver.shortname = "COM"
				c.fuel = 0
				c.damage = 100
			EndIf
		Next
		
	End Function
	
	Function ButtonReady()
		readyornot = Not readyornot
		RefreshReadyButton()
		SendReadyOrNot()
	End Function
	
	Function RefreshReadyButton()
		Select readyornot
		Case False	
			btn_Online_Kick.SetText(GetLocaleText("Not Ready"))
			btn_Online_Kick.SetColour(255,0,0)
		Case True	
			btn_Online_Kick.SetText(GetLocaleText("Ready"))
			btn_Online_Kick.SetColour(0,255,0)
		End Select
	End Function
	
End Type

Type TPeerObject
	' Peer objects are used to store information sent by clients to host (or host to client)
	Field name:String = ""	' Client username
	Field status:Int = 0	' Current network status of peer
	Field readyornot:Int = 0' Client race ready?
	Field points:Int = 0	' Host keeps track of player points
	Field qlaptime:Int = 0	' Keeps track of last race time
	Field teamid:Int = 0	' Able to select car image by setting teamid
	
	Field pingsent:Int	' Time that myhost sent ping to this peer
	Field pingdelay:Int	' Delay between ping sent and pong received
End Type