 ' ----------------------------------
' Start Screen
' ----------------------------------
Global pan_ExitGame:fry_TPanel = fry_TPanel(fry_GetGadget("pan_exitgame"))
Global btn_ExitGame:fry_TButton = fry_CreateImageButton("btn_ExitGame", gAppLoc+"Skin/Graphics/Buttons/QuitSmall.png", 7, 7, 16, 16, pan_ExitGame)

Global lbl_Version:fry_TLabel = fry_TLabel(fry_GetGadget("pan_title/lbl_version"))

Global btn_NewGame:fry_TButton = fry_TButton(fry_GetGadget("pan_start/btn_newgame"))
Global btn_LoadGame:fry_TButton = fry_TButton(fry_GetGadget("pan_start/btn_loadgame"))
Global btn_Options:fry_TButton = fry_TButton(fry_GetGadget("pan_start/btn_options"))
Global btn_QuickRace:fry_TButton = fry_TButton(fry_GetGadget("pan_start/btn_quickrace"))
Global btn_Online:fry_TButton = fry_TButton(fry_GetGadget("pan_start/btn_online"))
Global btn_Editor:fry_TButton = fry_TButton(fry_GetGadget("pan_start/btn_editor"))
Global btn_LoadReplay:fry_TButton = fry_TButton(fry_GetGadget("pan_start/btn_replays"))

Global pan_LoadGame:fry_TPanel = fry_TPanel(fry_GetGadget("pan_loadgame"))
Global tbl_LoadGame:fry_TTable = fry_TTable(fry_GetGadget("pan_loadgame/tbl_load"))
Global btn_LoadGame_Load:fry_TButton = fry_TButton(fry_GetGadget("pan_loadgame/btn_loadgame"))
Global btn_LoadGame_Delete:fry_TButton = fry_TButton(fry_GetGadget("pan_loadgame/btn_delgame"))

Global gLoadedReplay:Int = False
Global pan_LoadReplay:fry_TPanel = fry_TPanel(fry_GetGadget("pan_loadreplay"))
Global tbl_LoadReplay:fry_TTable = fry_TTable(fry_GetGadget("pan_loadreplay/tbl_load"))
Global btn_LoadReplay_Load:fry_TButton = fry_TButton(fry_GetGadget("pan_loadreplay/btn_loadreplay"))
Global btn_LoadReplay_Delete:fry_TButton = fry_TButton(fry_GetGadget("pan_loadreplay/btn_delreplay"))

Global pan_QuickRace:fry_TPanel = fry_TPanel(fry_GetGadget("pan_quickrace"))
Global tbl_QuickRace:fry_TTable = fry_TTable(fry_GetGadget("pan_quickrace/tbl_load"))
Global cmb_QuickRace_Driver:fry_TComboBox = fry_TComboBox(fry_GetGadget("pan_quickrace/cmb_driver"))
Global btn_QuickRace_Options:fry_TButton = fry_TButton(fry_GetGadget("pan_quickrace/btn_options"))
Global btn_QuickRace_Race:fry_TButton = fry_TButton(fry_GetGadget("pan_quickrace/btn_race"))

Function SetUpScreen_Start()
	gQuickRace = True
	LoadOptions()	' Refresh options from ini 
	gMyDriverId = 1
	lbl_Version.SetText(gVersion)
	fry_SetScreen("screen_start")
	pan_LoadGame.Hide()
	pan_LoadReplay.Hide()
	pan_QuickRace.Hide()
	btn_NewGame.gAlpha = 1
	btn_LoadGame.gAlpha = 1
	btn_QuickRace.gAlpha = 1
	btn_Options.gAlpha = 1
	btn_Online.gAlpha = 1
	btn_Editor.gAlpha = 1
	btn_LoadReplay.gAlpha = 1
	SetUpToolTips()
End Function

Function SetUpToolTips()
	btn_Casino_Home.gTip = GetLocaleText("btn_Casino_Home")
	btn_Casino_BlackJack.gTip = GetLocaleText("btn_Casino_BlackJack")
	btn_Casino_Roulette.gTip = GetLocaleText("btn_Casino_Roulette")
	btn_Casino_Slots.gTip = GetLocaleText("btn_Casino_Slots")
	btn_ExitGame.gTip = GetLocaleText("btn_ExitGame")
	btn_NewPlayer_Cancel.gTip = GetLocaleText("btn_NewPlayer_Cancel")
	btn_NewPlayer_Proceed.gTip = GetLocaleText("btn_NewPlayer_Proceed")
	btn_Header_Help.gTip = GetLocaleText("btn_Header_Help")
	btn_Header_Quit.gTip = GetLocaleText("btn_Header_Quit")
	btn_Header_Options.gTip = GetLocaleText("btn_Header_Options")
	btn_NavBar_Home.gTip = GetLocaleText("btn_NavBar_Home")
	btn_NavBar_Leaderboards.gTip = GetLocaleText("btn_NavBar_Leaderboards")
	btn_NavBar_Team.gTip = GetLocaleText("btn_NavBar_Team")
	btn_NavBar_Finances.gTip = GetLocaleText("btn_NavBar_Finances")
	btn_NavBar_Casino.gTip = GetLocaleText("btn_NavBar_Casino")
	btn_Relations_PitCrewCasino.gTip = GetLocaleText("btn_NavBar_Casino")
	btn_Relations_FriendsCasino.gTip = GetLocaleText("btn_NavBar_Casino")
	btn_NavBar_Play.gTip = GetLocaleText("btn_NavBar_Play")
	btn_NavBar_Practice.gTip = GetLocaleText("btn_NavBar_Practice")
	btn_TeamProfile_Back.gTip = GetLocaleText("btn_TeamProfile_Back")
	btn_TeamProfile_Fwd.gTip = GetLocaleText("btn_TeamProfile_Fwd")
	btn_Track_Back.gTip = GetLocaleText("btn_Track_Back")
	btn_Track_Fwd.gTip = GetLocaleText("btn_Track_Fwd")
	btn_History_Back.gTip = GetLocaleText("btn_History_Back")
	btn_History_Fwd.gTip = GetLocaleText("btn_History_Fwd")
	btn_Options_Cancel.gTip = GetLocaleText("btn_Options_Cancel")
	btn_Options_Proceed.gTip = GetLocaleText("btn_Options_Proceed")
	btn_News_Proceed.gTip = GetLocaleText("btn_News_Proceed")

	btn_TeamProfile_EditTeam.gTip = GetLocaleText("btn_TeamProfile_EditTeam")
	btn_TeamProfile_EditPrincipal.gTip = GetLocaleText("btn_TeamProfile_EditTeam")
	btn_TeamProfile_EditDriver1.gTip = GetLocaleText("btn_TeamProfile_EditTeam")
	btn_TeamProfile_EditDriver2.gTip = GetLocaleText("btn_TeamProfile_EditTeam")
	
End Function

Function ButtonNewGame()
	db.Close()
	
	LoadOptions()	' Refresh options from ini
	gQuickRace = False
	SetUpScreen_NewPlayer()
End Function

Function ButtonLoadGamePanel()	
	db.Close()
	UpdateLoadTable()
	pan_QuickRace.Hide()
	pan_LoadReplay.Hide()
	
	If pan_LoadGame.gHidden 
		pan_LoadGame.Show()
		btn_NewGame.SetAlpha(0.5)
		btn_LoadGame.SetAlpha(1)
		btn_QuickRace.SetAlpha(0.5)
		btn_Online.SetAlpha(0.5)
		btn_Options.SetAlpha(0.5)
		btn_Editor.SetAlpha(0.5)
		btn_LoadReplay.SetAlpha(0.5)
	Else
		pan_LoadGame.Hide()
		btn_NewGame.SetAlpha(1.0)
		btn_QuickRace.SetAlpha(1.0)
		btn_Online.SetAlpha(1.0)
		btn_Options.SetAlpha(1.0)	
		btn_Editor.SetAlpha(1.0)
		btn_LoadReplay.SetAlpha(1.0)
	EndIf
End Function

Function ButtonQuickRacePanel()	
	db.Close()
	UpdateQuickRaceTable()
	pan_LoadGame.Hide()
	pan_LoadReplay.Hide()
	
	If pan_QuickRace.gHidden 
		pan_QuickRace.Show()
		btn_NewGame.SetAlpha(0.5)
		btn_LoadGame.SetAlpha(0.5)
		btn_QuickRace.SetAlpha(1)
		btn_Online.SetAlpha(0.5)
		btn_Options.SetAlpha(0.5)
		btn_Editor.SetAlpha(0.5)
		btn_LoadReplay.SetAlpha(0.5)
	Else
		pan_QuickRace.Hide()
		btn_NewGame.SetAlpha(1.0)
		btn_LoadGame.SetAlpha(1.0)
		btn_Online.SetAlpha(1.0)
		btn_Options.SetAlpha(1.0)
		btn_Editor.SetAlpha(1.0)
		btn_LoadReplay.SetAlpha(1.0)
	EndIf
End Function

Function ButtonLoadReplayPanel()	
	db.Close()
	UpdateReplayTable()
	pan_LoadGame.Hide()
	pan_QuickRace.Hide()
	
	If pan_LoadReplay.gHidden 
		pan_LoadReplay.Show()
		
		btn_NewGame.SetAlpha(0.5)
		btn_LoadGame.SetAlpha(0.5)
		btn_QuickRace.SetAlpha(0.5)
		btn_Online.SetAlpha(0.5)
		btn_Options.SetAlpha(0.5)
		btn_Editor.SetAlpha(0.5)
		btn_LoadReplay.SetAlpha(1)
	Else
		pan_LoadReplay.Hide()
		
		btn_NewGame.SetAlpha(1.0)
		btn_QuickRace.SetAlpha(1.0)
		btn_Online.SetAlpha(1.0)
		btn_Options.SetAlpha(1.0)	
		btn_Editor.SetAlpha(1.0)
		btn_LoadReplay.SetAlpha(1.0)
	EndIf
End Function

Function UpdateQuickRaceTable()
	
	' Open db
	OpenQuickRaceDb()
	
	' Check db version number
	If GetDatabaseString("version", "options", 1) <> gVersion 
		AppLog "QuickRace db version doesn't match"
		CopyTracks(True)
		CreateNewQuickRaceDb()
		OpenQuickRaceDb()
	EndIf
	
	tbl_QuickRace.ClearItems();	While fry_PollEvent() Wend
	
	Local dir:Int = ReadDir(gSaveloc+"/Tracks")
	
	Repeat
		Local trackname$=NextFile( dir )
		If Right(trackname,4) = ".trk" 
			tbl_QuickRace.AddItem([Left(trackname, Len(trackname)-4)],0,Null)
		EndIf
		If trackname="" Exit
	Forever
	
	CloseDir dir
	
	tbl_QuickRace.SelectItem(0)
	
	' Load drivers 
	TDriver.SelectAll()
	TDriver.sortby = CSORT_ID
	TDriver.list.Sort()
	
	cmb_QuickRace_Driver.ClearItems()
	For Local d:TDriver = EachIn TDriver.list
		cmb_QuickRace_Driver.AddItem(d.name, d.id)
	Next
	
	cmb_QuickRace_Driver.SelectItem(0)
End Function

Function OpenQuickRaceDb()
	If gModLoc <> "" 
		If Not FileType(gSaveloc+"Save/QuickRace_"+cmb_Mod.SelectedText()+".db") Then CreateNewQuickRaceDb()
		db.Open(gSaveloc+"Save/QuickRace_"+cmb_Mod.SelectedText()+".db")
		db.Query("PRAGMA synchronous = OFF;")
	Else
		If Not FileType(gSaveloc+"Save/QuickRace.db") Then CreateNewQuickRaceDb()
		db.Open(gSaveloc+"Save/QuickRace.db")
		db.Query("PRAGMA synchronous = OFF;")
	End If
End Function

Function CreateNewQuickRaceDb()
	If gModLoc <> "" 
		DeleteFile(gSaveloc+"Save/QuickRace_"+cmb_Mod.SelectedText()+".db")
		CopyFile(gModLoc+"Database/NSGP.db", gSaveloc+"Save/QuickRace_"+cmb_Mod.SelectedText()+".db")
		db.Open(gSaveloc+"Save/QuickRace_"+cmb_Mod.SelectedText()+".db")
	Else
		DeleteFile(gSaveloc+"Save/QuickRace.db")
		CopyFile(gSaveloc+"Database/NSGP.db", gSaveloc+"Save/QuickRace.db")
		db.Open(gSaveloc+"Save/QuickRace.db")
	End If
	
	db.Query("BEGIN;")
	InsertOptionTable()
	db.Query("COMMIT;")
	db.Close()
End Function

Function UpdateLoadTable()	
	tbl_LoadGame.ClearItems();	While fry_PollEvent() Wend
	
	Local dir:Int = ReadDir(gSaveloc+"Save/")
	
	Repeat
		Local savename:String=NextFile( dir )
		If Right(savename,3) = ".db" And savename.Contains("QuickRace") = False
			tbl_LoadGame.AddItem([Left(savename, Len(savename)-3)],0,Null)
		EndIf
		If savename="" Exit
	Forever
	
	CloseDir dir
	
	tbl_LoadGame.SelectItem(0)
End Function

Function ButtonDeleteGame()
	If tbl_LoadGame.SelectedItem() < 0 Then Return
	If Not DoMessage("CMESSAGE_DELETE", True, tbl_LoadGame.GetText(tbl_LoadGame.SelectedItem(),0)) Then Return
	
	DeleteFile(gSaveLoc+"Save/"+tbl_LoadGame.GetText(tbl_LoadGame.SelectedItem(),0)+".db")
	DeleteFile(gSaveLoc+"Save/"+tbl_LoadGame.GetText(tbl_LoadGame.SelectedItem(),0)+".bak")
	UpdateLoadTable()
End Function

Function LoadGame(save:String)
	gQuickRace = False
	AppLog "LoadGame"
	
	If FileType(gSaveloc + "Save/" + save + ".db") = 1
		db.Open(gSaveloc + "Save/" + save + ".db")
		db.Query("PRAGMA synchronous = OFF;")
		
		Local v:Float = GetDatabaseString("version", "options", 1).Replace("v","").Replace(" DEMO", "").ToFloat()
		AppLog "Current Version:"+gVersion
		AppLog "   Save Version: "+v
		If v <= 1.17
			DoMessage("CMESSAGE_CANNOTLOADSAVEVERSION")
			db.Close()
			Return
		EndIf
		
		TNation.SelectAll()
		TTeam.SelectAll()
		TDriver.SelectAll()
		
		gMyDriverId = 21
		gDay = GetDatabaseInt("day", "gamedata", 1)
		gWeek = GetDatabaseInt("week", "gamedata", 1)
		gYear = GetDatabaseInt("year", "gamedata", 1)
		gRelBoss = GetDatabaseInt("relboss", "gamedata", 1)
		gRelPitCrew = GetDatabaseInt("relpitcrew", "gamedata", 1)
		gRelFans = GetDatabaseInt("relfans", "gamedata", 1)
		gRelFriends = GetDatabaseInt("relfriends", "gamedata", 1)
		
		LoadOptions()
		SetUpScreen_Home()
		UpdatePracticeButton()
		
		' Make sure iwaslapped column exists
		db.Query("ALTER TABLE driver ADD COLUMN iwaslapped INTEGER")
		db.Query("ALTER TABLE history ADD COLUMN iwaslapped INTEGER")
	EndIf
End Function

Function UpdateReplayTable()	
	tbl_LoadReplay.ClearItems();	While fry_PollEvent() Wend
	
	Local dir:Int = ReadDir(gSaveloc+"Replays/")
	
	Repeat
		Local savename:String=NextFile( dir )
		If Right(savename,4) = ".rep"
			tbl_LoadReplay.AddItem([Left(savename, Len(savename)-4)],0,Null)
		EndIf
		If savename="" Exit
	Forever
	
	CloseDir dir
	
	tbl_LoadReplay.SelectItem(0)
End Function

Function ButtonDeleteReplay()
	If tbl_LoadReplay.SelectedItem() < 0 Then Return
	If Not DoMessage("CMESSAGE_DELETE", True, tbl_LoadReplay.GetText(tbl_LoadReplay.SelectedItem(),0)) Then Return
	
	DeleteFile(gSaveloc+"Replays/"+tbl_LoadReplay.GetText(tbl_LoadReplay.SelectedItem(),0)+".rep")
	UpdateReplayTable()
End Function

Function LoadReplay(filename:String)
	AppLog "LoadReplay:"+filename
	
	Local repfile:TStream = ReadFile(gSaveloc+"/Replays/"+filename+".rep")
	If Not repfile Then Return
	
	gQuickRace = True
	gLoadedReplay = True
	
	' Header
	Local trackname:String = repfile.ReadLine()
	Local carcount:Int = repfile.ReadByte()
	
	' Set Up Cars
	For Local count:Int = 1 To carcount
		Local name:String = repfile.ReadLine()
		Local id:Int = repfile.ReadByte()
		Local drvnum:Int = repfile.ReadByte()
		Local team:Int = repfile.ReadByte()
		Local controller:Int = repfile.ReadByte()
		
		Local drv:TDriver = TDriver.CreateReplayDriver(id, team, name)
		drv.drivernumber = drvnum
		TCar.CreateReplayCar(controller, drv)
	Next
	
	' Load replay data
	While Not Eof(repfile)
		Local rep:TReplayFrame = New TReplayFrame
		rep.LoadFromStream(repfile)
		
		Local c:TCar = TCar.SelectByDriverId(rep.id)
		c.l_ReplayFrames.AddLast(rep)
	Wend
	
	repfile.Close()
	
	OpenQuickRaceDb()
	track.mode = CTRACKMODE_REPLAYING
	track.racestatus = CRACESTATUS_RACE
	track.LoadTrack(trackname)
	track.totallaps = 99
	TCar.ReplayFirstFrameAll()
	RaceEngine()
	
	gLoadedReplay = False
End Function

' ----------------------------------
' Race Screens
' ----------------------------------

' Pause Screen
Global pan_RacePaused:fry_TPanel = fry_TPanel(fry_GetGadget("pan_racepaused"))
Global lbl_RacePaused:fry_TLabel = fry_TLabel(fry_GetGadget("pan_racepaused/lbl_title"))
Global btn_RacePausedQuit:fry_TButton = fry_TButton(fry_GetGadget("pan_racepaused/btn_quit"))
Global btn_RacePausedOptions:fry_TButton = fry_TButton(fry_GetGadget("pan_racepaused/btn_options"))
Global btn_RacePausedReplay:fry_TButton = fry_TButton(fry_GetGadget("pan_racepaused/btn_replay"))
Global btn_RacePausedContinue:fry_TButton = fry_TButton(fry_GetGadget("pan_racepaused/btn_continue"))

Function ButtonRaceQuit:Int()
	' Don't do message box if online
	If TOnline.netstatus
		track.Quit()
		If Not TOnline.hosting Then TOnline.Join()
		Return True	
	Else
		If track.ButtonQuit() 
			track.Quit()
			Return True	
		End If
	End If
	
	Return False
End Function

' Race Option Screen
Global pan_RaceOptions:fry_TPanel = fry_TPanel(fry_GetGadget("pan_raceoptions"))

' Race Pit Stop Screen
Global pan_RacePitStop:fry_TPanel = fry_TPanel(fry_GetGadget("pan_racepitstop"))

' Race info screen
Global pan_RaceInfo:fry_TPanel = fry_TPanel(fry_GetGadget("pan_raceinfo"))
Global lbl_RaceInfo_Title:fry_TLabel = fry_TLabel(fry_GetGadget("pan_raceinfo/lbl_title"))
Global tbl_RaceInfo:fry_TTable = fry_TTable(fry_GetGadget("pan_raceinfo/tbl_info"))
Global btn_RaceInfoReplay:fry_TButton = fry_TButton(fry_GetGadget("pan_raceinfo/btn_replay"))
Global btn_RaceInfoContinue:fry_TButton = fry_TButton(fry_GetGadget("pan_raceinfo/btn_continue"))

' ----------------------------------
' New Player
' ----------------------------------
Global txt_NewPlayer_Name:fry_TTextField = fry_TTextField(fry_GetGadget("pan_newplayer/txt_name"))
Global cmb_NewPlayer_Nationality:fry_TComboBox = fry_TComboBox(fry_GetGadget("pan_newplayer/cmb_nationality"))
Global cmb_NewPlayer_DOBDay:fry_TComboBox = fry_TComboBox(fry_GetGadget("pan_newplayer/cmb_dobday"))
Global cmb_NewPlayer_DOBMonth:fry_TComboBox = fry_TComboBox(fry_GetGadget("pan_newplayer/cmb_dobmonth"))
Global cmb_NewPlayer_Team:fry_TComboBox = fry_TComboBox(fry_GetGadget("pan_newplayer/cmb_team"))
Global cmb_NewPlayer_Driver:fry_TComboBox = fry_TComboBox(fry_GetGadget("pan_newplayer/cmb_driver"))
Global txt_NewPlayer_POB:fry_TTextField = fry_TTextField(fry_GetGadget("pan_newplayer/txt_birthplace"))
Global txt_NewPlayer_SaveName:fry_TTextField = fry_TTextField(fry_GetGadget("pan_newplayer/txt_savename"))

Global pan_NewPlayer_Nav:fry_TPanel = fry_TPanel(fry_GetGadget("pan_newplayer_nav"))
Global btn_NewPlayer_Cancel:fry_TButton = fry_CreateImageButton("btn_NPCancel", gAppLoc+"Skin/Graphics/Buttons/Cancel.png", pan_NewPlayer_Nav.gW-74-42, 9, 32, 32, pan_NewPlayer_Nav)
Global btn_NewPlayer_Proceed:fry_TButton = fry_CreateImageButton("btn_NPProceed", gAppLoc+"Skin/Graphics/Buttons/Play.png", pan_NewPlayer_Nav.gW-74, 9, 64, 32, pan_NewPlayer_Nav)

Global pan_NewPlayer:fry_TPanel = fry_TPanel(fry_GetGadget("pan_newplayer"))
Global can_NewPlayer_TeamImg:fry_TCanvas = fry_CreateCanvas("can_NewPlayer_TeamImg", 20, 220, 160, 80, pan_NewPlayer)
can_NewPlayer_TeamImg.SetBackground(1)
can_NewPlayer_TeamImg.SetColour(128,128,128)
can_NewPlayer_TeamImg.SetDraw(DrawNewPlayerTeamImg)

Global can_NewPlayer_TeamRating1:fry_TCanvas = fry_CreateCanvas("can_NewPlayer_TeamRating1", 280, 228, 100, 16, pan_NewPlayer)
can_NewPlayer_TeamRating1.SetBackground(0)
can_NewPlayer_TeamRating1.SetDraw(DrawNewPlayerTeamRating1)

Global can_NewPlayer_TeamRating2:fry_TCanvas = fry_CreateCanvas("can_NewPlayer_TeamRating2", 280, 248, 100, 16, pan_NewPlayer)
can_NewPlayer_TeamRating2.SetBackground(0)
can_NewPlayer_TeamRating2.SetDraw(DrawNewPlayerTeamRating2)

Global can_NewPlayer_TeamRating3:fry_TCanvas = fry_CreateCanvas("can_NewPlayer_TeamRating3", 280, 268, 100, 16, pan_NewPlayer)
can_NewPlayer_TeamRating3.SetBackground(0)
can_NewPlayer_TeamRating3.SetDraw(DrawNewPlayerTeamRating3)

Global NewPlayerTeamRating1:Float
Global NewPlayerTeamRating2:Float
Global NewPlayerTeamRating3:Float

Function SetUpScreen_NewPlayer()
	AppLog "SetUpScreen_NewPlayer"
	fry_SetScreen("screen_newplayer")
	prg_Title.Hide()
	btn_Header_Options.Hide()
	btn_Header_Quit.Hide()
	
	Local name:String
	Local license:String
	ReadRegIni(name, license)
	
	txt_NewPlayer_Name.SetText(name)
		
	' Nations
	cmb_NewPlayer_Nationality.ClearItems()

	If gModLoc <> ""
		db.Open(gModLoc+"Database/NSGP.db")
	Else
		db.Open(gSaveloc+"Database/NSGP.db")
	End If
	
	TNation.SelectAll()
	TTeam.SelectAll()
	TDriver.SelectAll()
	db.Close()
	AppLog "db.Close"
	
	If Not TNation.list Then Notify("Database error: No Nations", True); End
	
	TNation.sortby = CSORT_NATIONALITY
	TNation.list.Sort()
	
	Local count:Int = 0
	Local sel:Int = 0
	Local natid:Int = GetLocaleText("Tag_NationId").ToInt() 
	If natid = 0 Then natid = 61
	
	For Local nation:TNation = EachIn TNation.list
		cmb_NewPlayer_Nationality.AddItem(nation.nationality)
		If nation.id = natid Then sel = count
		count:+1
	Next
	
	cmb_NewPlayer_Nationality.SelectItem(sel)
	
	' Teams & drivers
	cmb_NewPlayer_Team.ClearItems();	While fry_PollEvent() Wend

	If Not TTeam.list Then Notify("Database error: No Nations", True); End
	
	For Local team:TTeam = EachIn TTeam.list
		cmb_NewPlayer_Team.AddItem(Team.name)
	Next
	
	cmb_NewPlayer_Team.SelectItem(0)
	UpdateReplaceDriver()
	
	' Date of birth
	cmb_NewPlayer_DOBDay.ClearItems();	While fry_PollEvent() Wend
	cmb_NewPlayer_DOBMonth.ClearItems();	While fry_PollEvent() Wend
	
	For Local day:Int = 1 To 31
		cmb_NewPlayer_DOBDay.AddItem(String(day))
	Next
	
	cmb_NewPlayer_DOBDay.SelectItem(0)
	
	cmb_NewPlayer_DOBMonth.AddItem(GetLocaleText("January"))
	cmb_NewPlayer_DOBMonth.AddItem(GetLocaleText("February"))
	cmb_NewPlayer_DOBMonth.AddItem(GetLocaleText("March"))
	cmb_NewPlayer_DOBMonth.AddItem(GetLocaleText("April"))
	cmb_NewPlayer_DOBMonth.AddItem(GetLocaleText("May"))
	cmb_NewPlayer_DOBMonth.AddItem(GetLocaleText("June"))
	cmb_NewPlayer_DOBMonth.AddItem(GetLocaleText("July"))
	cmb_NewPlayer_DOBMonth.AddItem(GetLocaleText("August"))
	cmb_NewPlayer_DOBMonth.AddItem(GetLocaleText("September"))
	cmb_NewPlayer_DOBMonth.AddItem(GetLocaleText("October"))
	cmb_NewPlayer_DOBMonth.AddItem(GetLocaleText("November"))
	cmb_NewPlayer_DOBMonth.AddItem(GetLocaleText("December"))
	
	cmb_NewPlayer_DOBMonth.SelectItem(0)
	
	Local sv:String = "MySave"
	If gModLoc <> "" Then sv:+"_"+cmb_Mod.SelectedText()
	txt_NewPlayer_SaveName.SetText(sv)
End Function

Function UpdateReplaceDriver()
	AppLog "UpdateReplaceDriver"
	cmb_NewPlayer_Driver.ClearItems();	While fry_PollEvent() Wend

	If Not TDriver.list Then Notify("Database error: No Nations", True); End
	
	For Local drv:TDriver = EachIn TDriver.list
		If drv.team = cmb_NewPlayer_Team.SelectedItem()+1
			cmb_NewPlayer_Driver.AddItem(drv.name)
		EndIf
	Next
	
	cmb_NewPlayer_Driver.SelectItem(0)
	Local team:Int = cmb_NewPlayer_Team.SelectedItem()+1
	
	imgTeamProfile = TTeam.GetById(team).img
	
	' Load stats
	NewPlayerTeamRating1 = TTeam.GetById(team).handling
	NewPlayerTeamRating2 = TTeam.GetById(team).acceleration
	NewPlayerTeamRating3 = TTeam.GetById(team).topspeed
	
	ValidateMinMaxFloat(NewPlayerTeamRating1, -10, 5)
	ValidateMinMaxFloat(NewPlayerTeamRating2, -10, 5)
	ValidateMinMaxFloat(NewPlayerTeamRating3, -10, 5)
	
	AppLog NewPlayerTeamRating1
	AppLog NewPlayerTeamRating2
	AppLog NewPlayerTeamRating3
End Function

Function NewPlayer_Cancel()
	SetUpScreen_Start()
End Function

Function NewPlayer_Proceed()
	Local name:String = txt_NewPlayer_Name.GetText()
	If name = "" Then name = "Player"
	
	For Local drv:TDriver = EachIn TDriver.list
		If name = drv.name
			DoMessage("CMESSAGE_INVALIDNAME")
			Return
		End If
	Next
	
	If name = "Ayrton Senna" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "A Senna" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Michael Schumacher" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "M Schumacher" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Ralf Schumacher" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Nigel Mansell" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Alain Prost" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Juan Manuel Fangio" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Jackie Stewart" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Niki Lauda" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Gilles Villeneuve" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Jacques Villeneuve" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Stirling Moss" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Alberto Ascari" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Tazio Nuvolari" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Damon Hill" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Mika Häkkinen" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Mika Hakkinen" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Mario Andretti" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Jack Brabham" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	If name = "Nelson Piquet" Then DoMessage("CMESSAGE_INVALIDNAME"); Return
	
	name = name.Replace(",", "")
	name = name.Replace("'", "")
	
	Local newsavename:String = txt_NewPlayer_SaveName.GetText()
	
	Local dir:Int = ReadDir(gSaveloc+"Save/")
	
	Repeat
		Local savename$=NextFile( dir )
		If Right(savename,3) = ".db"
			If Left(savename, Len(savename)-3) = newsavename
				If DoMessage("CMESSAGE_OVERWRITE", True, savename) = False 
					CloseDir dir
					Return
				EndIf
			EndIf
		EndIf
		If savename="" Exit
	Forever
	
	CloseDir dir
	
	DeleteFile(gSaveloc+"Save/"+newsavename+".db")
	
	If gModLoc <> ""
		CopyFile(gModLoc+"Database/NSGP.db", gSaveloc+"Save/"+newsavename+".db")
	Else
		CopyFile(gSaveLoc+"Database/NSGP.db", gSaveloc+"Save/"+newsavename+".db")
	EndIf
	
	AppLog "Copy options from QuickRace.db"
	
	db.Open(gSaveloc+"Save/"+newsavename+".db")
	db.Query("PRAGMA synchronous = OFF;")
	
	Local nat:TNation = TNation.SelectByNationality(cmb_NewPlayer_Nationality.SelectedText())
	Local nationality:Int = nat.id
	Local dob:FryDate = FryDate.Create(cmb_NewPlayer_DOBDay.SelectedItem()+1, cmb_NewPlayer_DOBMonth.SelectedItem()+1, gStartYear-21)
	Local pob:String = txt_NewPlayer_POB.GetText()
	If pob = "" Then pob = nat.name
	
	gMyDriverId = 21
	gWeek = 1
	gDay = 1
	gYear = 1

	db.Query("BEGIN;")
	db.Query("INSERT INTO driver VALUES("+gMyDriverId+", '"+name+"', "+nationality+", "+dob.GetJulian()+", '"+pob+"', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0)")
	
	AppLog "INSERT INTO driver VALUES"
	
	Select cmb_NewPlayer_Driver.SelectedItem()
	Case 0	AppLog "Update Driver1"
		db.Query("UPDATE team SET driver1 = "+gMyDriverId+" WHERE id = "+Int(cmb_NewPlayer_Team.SelectedItem()+1))
	Case 1	AppLog "Update Driver2"
		db.Query("UPDATE team SET driver2 = "+gMyDriverId+" WHERE id = "+Int(cmb_NewPlayer_Team.SelectedItem()+1))
	End Select
	
	AppLog "CREATE TABLE gamedata" 
	db.Query("CREATE TABLE gamedata (id INTEGER PRIMARY KEY, day INTEGER, week INTEGER, year INTEGER, cash INTEGER, prizemoney INTEGER, gamblingmoney INTEGER, sponsormoney INTEGER, relboss INTEGER, relpitcrew INTEGER, relfans INTEGER, relfriends INTEGER, license TEXT, licensekey TEXT)")
	
	OpDifficulty = 2
		
	Select OpDifficulty
	Case 1	
		gRelBoss = 75
		gRelPitCrew = 75
		gRelFans = 75
		gRelFriends = 75
	Case 2	
		gRelBoss = 50
		gRelPitCrew = 50
		gRelFans = 50
		gRelFriends = 50
	Case 3
		gRelBoss = 25
		gRelPitCrew = 25
		gRelFans = 25
		gRelFriends = 25
	Case 4
		gRelBoss = 10
		gRelPitCrew = 10
		gRelFans = 10
		gRelFriends = 10
	End Select
	
	AppLog "INSERT INTO gamedata"
	db.Query("INSERT INTO gamedata VALUES(1, "+gDay+", "+gWeek+", "+gYear+", 1000, 0, 0, 0, "+gRelBoss+", "+gRelPitCrew+", "+gRelFans+", "+gRelFriends+", '0', '0')")
	
	InsertOptionTable()
	
	AppLog "INSERT INTO track VALUES"
	db.Query("INSERT INTO track VALUES(0, 'Test Track', 61, 4.000, 0, 0, 0, 1)")
	db.Query("COMMIT;")
	
	AppLog "CREATE TABLE history"
	db.Query("CREATE TABLE history (id INTEGER PRIMARY KEY, year INTEGER, track INTEGER, driver TEXT, team TEXT, position INTEGER, time INTEGER, points INTEGER)")
	
	TShopItem.SetUpShopDatabase()
	
	db.Close()
	LoadGame(newsavename)
	
	SetUpScreen_Options()
	btn_Options_Cancel.Hide()
End Function

Function InsertOptionTable()
	db.Query("CREATE TABLE options (id INTEGER PRIMARY KEY, difficulty INTEGER, laps INTEGER, view INTEGER, volfx FLOAT, volmusic FLOAT, keyleft INTEGER, keyright INTEGER, keyup INTEGER, keydown INTEGER, keypause INTEGER, keyinfo INTEGER, radio INTEGER, map INTEGER, fuel INTEGER, damage INTEGER, tyres INTEGER, version TEXT, keykers INTEGER, speedo INTEGER, kers INTEGER)")
	Local q:String = "INSERT INTO options VALUES(1, "+OpDifficulty+", "+OpLaps+", "+OpView+", "+OpVolumeFX+", "+OpVolumeMusic+", "+OpControls[0]+", "+OpControls[1]+", "+OpControls[2]+", "+OpControls[3]+", "+OpControls[4]+", "+OpControls[5]+", "+OpRadio+", "+OpMap+", "+OpFuel+", "+OpDamage+", "+OpTyres+", '"+gVersion+"', "+OpControls[6]+", "+OpSpeedo+", "+OpKers+")"
	AppLog q
	db.Query(q)
End Function

' ----------------------------------
' Header and Nav Bar
' ----------------------------------
Global pan_Header:fry_TPanel = fry_TPanel(fry_GetGadget("pan_header"))

Local bx:Int = pan_Header.gW-42
Global btn_Header_Quit:fry_TButton = fry_CreateImageButton("btn_HeaderQuit", gAppLoc+"Skin/Graphics/Buttons/Quit.png", bx, 9, 32, 32, pan_Header); bx:-42
Global btn_Header_Options:fry_TButton = fry_CreateImageButton("btn_HeaderOptions", gAppLoc+"Skin/Graphics/Buttons/Options.png", bx, 9, 32, 32, pan_Header); bx:-42
Global btn_Header_Help:fry_TButton = fry_CreateImageButton("btn_HeaderHelp", gAppLoc+"Skin/Graphics/Buttons/Help.png", bx, 9, 32, 32, pan_Header)

Global prg_Title:fry_TProgressBar = fry_TProgressBar(fry_GetGadget("pan_header/prg_title"))

Global pan_NavBar:fry_TPanel = fry_TPanel(fry_GetGadget("pan_navbar"))
bx = 10
Global btn_NavBar_Home:fry_TButton = fry_CreateImageButton("btn_Home", gAppLoc+"Skin/Graphics/Buttons/Home.png", bx, 9, 32, 32, pan_NavBar); bx:+42
Global btn_NavBar_Leaderboards:fry_TButton = fry_CreateImageButton("btn_Leaderboards", gAppLoc+"Skin/Graphics/Buttons/Tracks.png", bx, 9, 32, 32, pan_NavBar); bx:+42
Global btn_NavBar_Team:fry_TButton = fry_CreateImageButton("btn_Team", gAppLoc+"Skin/Graphics/Buttons/Team.png", bx, 9, 32, 32, pan_NavBar); bx:+42
Global btn_NavBar_Finances:fry_TButton = fry_CreateImageButton("btn_Finances", gAppLoc+"Skin/Graphics/Buttons/Finances.png", bx, 9, 32, 32, pan_NavBar); bx:+42
Global btn_NavBar_Casino:fry_TButton = fry_CreateImageButton("btn_Casino", gAppLoc+"Skin/Graphics/Buttons/Casino.png", bx, 9, 32, 32, pan_NavBar); bx:+42

Global btn_NavBar_Play:fry_TButton = fry_CreateImageButton("btn_Home", gAppLoc+"Skin/Graphics/Buttons/Play.png", pan_NavBar.gW-74, 9, 64, 32, pan_NavBar)
Global btn_NavBar_Practice:fry_TButton = fry_CreateImageButton("btn_Practice", gAppLoc+"Skin/Graphics/Buttons/Practice.png", pan_NavBar.gW-116, 9, 32, 32, pan_NavBar)

Function QuitGame()
	If Not DoMessage("CMESSAGE_QUIT", True) Then Return
	SaveGame()
	db.Close()
	SetUpScreen_Start()
End Function

' ----------------------------------
' Home
' ----------------------------------

Global pan_Date:fry_TPanel = fry_TPanel(fry_GetGadget("pan_date"))
Global lbl_Date_Week:fry_TLabel = fry_TLabel(fry_GetGadget("pan_date/lbl_week"))
Global lbl_Date_Day:fry_TLabel = fry_TLabel(fry_GetGadget("pan_date/lbl_day"))

Global pan_Championship:fry_TPanel = fry_TPanel(fry_GetGadget("pan_driverchampionship"))
Global tbl_Championship_Drivers:fry_TTable = fry_TTable(fry_GetGadget("pan_driverchampionship/tbl_championship_drivers"))
Global tbl_Championship_Teams:fry_TTable = fry_TTable(fry_GetGadget("pan_driverchampionship/tbl_championship_teams"))

Global pan_Results:fry_TPanel = fry_TPanel(fry_GetGadget("pan_results"))
Global lbl_Results_Title:fry_TLabel = fry_TLabel(fry_GetGadget("pan_results/lbl_title"))
Global tbl_Results:fry_TTable = fry_TTable(fry_GetGadget("pan_results/tbl_results"))

Function SetUpScreen_Home()
	AppLog "SetUpScreen_Home"
	fry_SetScreen("screen_home")
	
	btn_Header_Options.Show()
	btn_Header_Quit.Show()
	prg_Title.Show()
	btn_Track_Back.Hide()
	btn_Track_Fwd.Hide()
	
	PauseChannel(chn_CasinoAmbience)
	gViewTeam = 1
	
	' Monday show results of last race. Otherwise show next race track.
	gViewTrack = gWeek
	If gDay = CDAY_MONDAY And gWeek > 1 Then gViewTrack:-1
	
	UpdateProgressTitle()
	SetUpPanel_TrackProfile()
	SetUpPanel_Results()
	SetUpPanel_Championship()
	SetUpPanel_Date()
	
	CheckBossMood()
	SaveGame()
End Function

Function SetUpPanel_TrackProfile()
	Local nat:Int = GetDatabaseInt("nation", "track", gViewTrack)
	If nat = 61 Or nat = 159 Or nat = 203 Then nat = 0
	imgTrackProfileFlag = LoadMyImage("Media\Nations\NationIm_"+nat+".png")
	imgTrackProfile = LoadMyImage("Media\Tracks\TrackIm_"+gViewTrack+".png")
	
	lbl_TrackProfile_Name.SetText(GetDatabaseString("name", "track", gViewTrack))
	Local length:String = GetFloatAsString(GetDatabaseFloat("length", "track", gViewTrack), 3)+" "+GetLocaleText("tla_kilometers")
	lbl_TrackProfile_Length.SetText(length)
	
	Local str:String = GetLocaleText("Week")+" "+gViewTrack
	lbl_TrackProfile_Nation.SetText(str)
	
	Local time:Int = GetDatabaseInt("laprecord", "track", gViewTrack)
	lbl_TrackProfile_LapTime.SetText(GetStringTime(time))

	Local holder:String = GetDatabaseString("name", "driver", GetDatabaseInt("lapholder", "track", gViewTrack))
	lbl_TrackProfile_LapHolder.SetText(holder)
	
	If time = "0" 
		lbl_TrackProfile_LapTime.SetText("")
		lbl_TrackProfile_LapHolder.SetText("")
	EndIf	
	
	SetUpPanel_History()
End Function

Function SetUpPanel_Results()	
	TDriver.SelectAll()
	
	Local trackno:Int = gWeek
	If gDay = CDAY_MONDAY And gWeek > 1 Then trackno:-1
	Local trackname:String = GetDatabaseString("name", "track", trackno)
		
	pan_Results.Hide()
	pan_Relationships.Show()
		
	Select gDay
	Case CDAY_SUNDAY
		pan_Results.Show()
		pan_Relationships.Hide()
	
		TDriver.sortby = CSORT_QUALIFYINGTIME
		TDriver.list.Sort()
		lbl_Results_Title.SetText(trackname+" "+GetLocaleText("Grid"))
		
		tbl_Results.ClearItems()
		
		Local sel:Int = -1
		Local pos:Int = 1
		
		For Local drv:TDriver = EachIn TDriver.list
			If drv.team > 0
				Local team:TTeam = TTeam.GetTeamByDriverId(drv.id)
				Local tm:String = GetStringTime(drv.qualifyingtime)
				If drv.qualifyingtime = 0 Then tm = GetLocaleText("tla_DidNotQualify")
				
				tbl_Results.AddItem([String(pos), drv.name, team.name, tm])
				If drv.id = gMyDriverId Then sel = pos-1
				
				pos:+1
			EndIf
		Next
		
		tbl_Results.SelectItem(sel)
		If sel > 9 Then tbl_Results.ShowItem(sel - 4)
		
	Case CDAY_MONDAY
		' Don't show results on week 1
		If gWeek = 1 Then Return
		
		pan_Results.Show()
		pan_Relationships.Hide()
	
		TDriver.sortby = CSORT_FINISHTIME
		TDriver.list.Sort()
		lbl_Results_Title.SetText(trackname+" "+GetLocaleText("Result"))
		
		tbl_Results.ClearItems()
		
		Local sel:Int = -1
		Local pos:Int = 1
		For Local drv:TDriver = EachIn TDriver.list
			Local team:TTeam = TTeam.GetTeamByDriverId(drv.id)
			Local pts:String = String(track.GetPositionPoints(pos))
			If drv.lastracetime = 0 Then pts = GetLocaleText("tla_DidNotFinish")
			
			If team And team.id > 0
				tbl_Results.AddItem([String(pos), drv.name, team.name, GetStringTime(drv.lastracetime, False, drv.iwaslapped), pts])
				If drv.id = gMyDriverId Then sel = pos-1
				pos:+1
			EndIf
		Next
	
		tbl_Results.SelectItem(sel)
		If sel > 9 Then tbl_Results.ShowItem(sel - 4)
	End Select
End Function

Function SetUpPanel_Championship()
	TTeam.SelectAll()
	
	TDriver.SelectAll()
	TDriver.sortby = CSORT_SEASONPOINTS
	TDriver.list.Sort()
	
	tbl_Championship_Drivers.ClearItems()
	
	Local myteam:Int = 0
	Local sel:Int = 1
	Local pos:Int = 1
	For Local drv:TDriver = EachIn TDriver.list
		Local nat:String = GetDatabaseString("name", "nation", drv.nationality)
		Local team:TTeam = TTeam.GetTeamByDriverId(drv.id)
		
		If team And team.id > 0 
			tbl_Championship_Drivers.AddItem([String(pos), drv.name, nat, team.name, String(drv.seasonpts)])
			If drv.id = gMyDriverId Then sel = pos-1; myteam = team.id 
			pos:+1
		EndIf
	Next
	
	tbl_Championship_Drivers.SelectItem(sel)
	If sel > 7 Then tbl_Championship_Drivers.ShowItem(sel - 4)
	
	TTeam.SelectAll()
	TTeam.sortby = CSORT_SEASONPOINTS
	TTeam.list.Sort()
	
	tbl_Championship_Teams.ClearItems()
	sel = 0
	pos = 1
	For Local team:TTeam = EachIn TTeam.list
		tbl_Championship_Teams.AddItem([String(pos), team.name, String(team.seasonpts)])
		If team.id = myteam Then sel = pos-1
		pos:+1
	Next
	
	tbl_Championship_Teams.SelectItem(sel)
	If sel > 7 Then tbl_Championship_Drivers.ShowItem(sel - 4)
End Function

Function SetUpPanel_Date()
	lbl_Date_Week.SetText(GetLocaleText("Week")+" "+gWeek)
	
	Local day:String = GetStringDayOfTheWeek(gDay)
	
'	If gWeek > gNoofWeeks Then day = GetLocaleText("Monday")
	lbl_Date_Day.SetText(day)
End Function

Function GetStringDayOfTheWeek:String(day:Int)

	Select day
	Case 1 	Return GetLocaleText("Monday")
	Case 2 	Return GetLocaleText("Tuesday")
	Case 3 	Return GetLocaleText("Wednesday")
	Case 4 	Return GetLocaleText("Thursday")
	Case 5 	Return GetLocaleText("Friday")
	Case 6 	Return GetLocaleText("Saturday")
	Case 7 	Return GetLocaleText("Sunday")
	End Select
	
End Function

Function UpdateProgressTitle()
	prg_Title.SetText(TCurrency.GetString(OpCurrency, GetCash()))
	prg_Title.SetValue(0)
End Function

Function TrackProfileBack()
	gViewTrack:-1
	If gViewTrack < 1 Then gViewTrack = gNoofWeeks
	SetUpPanel_TrackProfile()
	SetUpPanel_LeaderboardControls()
End Function

Function TrackProfileFwd()
	gViewTrack:+1
	If gViewTrack > gNoofWeeks Then gViewTrack = 1
	SetUpPanel_TrackProfile()
	SetUpPanel_LeaderboardControls()
End Function

Function CheckBossMood()
	If gWeek < 3 Then Return
	
	Local drv:TDriver = TDriver.GetDriverById(gMyDriverId)
	Local team:TTeam = TTeam.GetById(drv.team)
	
	' If you have impressed the boss he will make you driver 1. If not you will be demoted to driver 2.
	If team.driver1 = gMyDriverId
		If gRelBoss <= 30
			DoMessage("CMESSAGE_BOSSDEMOTION")
			UpdateDatabaseInt("team", "driver1", team.driver2, team.id)
			UpdateDatabaseInt("team", "driver2", team.driver1, team.id)
		EndIf
	Else
		If gRelBoss >= 70
			DoMessage("CMESSAGE_BOSSPROMOTION")
			UpdateDatabaseInt("team", "driver1", team.driver2, team.id)
			UpdateDatabaseInt("team", "driver2", team.driver1, team.id)
		EndIf
	EndIf
	
	TTeam.SelectAll()
	TDriver.SelectAll()
End Function

' ----------------------------------
' Team profile
' ----------------------------------

Global pan_DriverProfile1:fry_TPanel = fry_TPanel(fry_GetGadget("pan_driverprofile1"))
Global lbl_DriverProfile1_Name:fry_TLabel = fry_TLabel(fry_GetGadget("pan_driverprofile1/lbl_name2"))
Global lbl_DriverProfile1_DOB:fry_TLabel = fry_TLabel(fry_GetGadget("pan_driverprofile1/lbl_dob2"))
Global lbl_DriverProfile1_POB:fry_TLabel = fry_TLabel(fry_GetGadget("pan_driverprofile1/lbl_pob2"))
Global tbl_DriverProfile1:fry_TTable = fry_TTable(fry_GetGadget("pan_driverprofile1/tbl_profile"))
Global can_DriverNationality1:fry_TCanvas = fry_CreateCanvas("can_DriverNat1", 10, 100, 62, 42, pan_driverprofile1)
can_DriverNationality1.SetBackground(1)
can_DriverNationality1.SetColour(128,128,128)
can_DriverNationality1.SetDraw(DrawDriverProfileFlag1)

Global pan_DriverProfile2:fry_TPanel = fry_TPanel(fry_GetGadget("pan_driverprofile2"))
Global lbl_DriverProfile2_Name:fry_TLabel = fry_TLabel(fry_GetGadget("pan_driverprofile2/lbl_name2"))
Global lbl_DriverProfile2_DOB:fry_TLabel = fry_TLabel(fry_GetGadget("pan_driverprofile2/lbl_dob2"))
Global lbl_DriverProfile2_POB:fry_TLabel = fry_TLabel(fry_GetGadget("pan_driverprofile2/lbl_pob2"))
Global tbl_DriverProfile2:fry_TTable = fry_TTable(fry_GetGadget("pan_driverprofile2/tbl_profile"))
Global can_DriverNationality2:fry_TCanvas = fry_CreateCanvas("can_DriverNat2", 10, 100, 62, 42, pan_driverprofile2)
can_DriverNationality2.SetBackground(1)
can_DriverNationality2.SetColour(128,128,128)
can_DriverNationality2.SetDraw(DrawDriverProfileFlag2)

Global pan_TeamProfile:fry_TPanel = fry_TPanel(fry_GetGadget("pan_teamprofile"))
Global lbl_TeamProfile_Name:fry_TLabel = fry_TLabel(fry_GetGadget("pan_teamprofile/lbl_name"))
Global lbl_TeamProfile_Nationality:fry_TLabel = fry_TLabel(fry_GetGadget("pan_teamprofile/lbl_nationality2"))
Global lbl_TeamProfile_Principal:fry_TLabel = fry_TLabel(fry_GetGadget("pan_teamprofile/lbl_principal2"))
Global lbl_TeamProfile_Driver1A:fry_TLabel = fry_TLabel(fry_GetGadget("pan_teamprofile/lbl_driver1A"))
Global lbl_TeamProfile_Driver2A:fry_TLabel = fry_TLabel(fry_GetGadget("pan_teamprofile/lbl_driver2A"))
Global lbl_TeamProfile_Driver1B:fry_TLabel = fry_TLabel(fry_GetGadget("pan_teamprofile/lbl_driver1B"))
Global lbl_TeamProfile_Driver2B:fry_TLabel = fry_TLabel(fry_GetGadget("pan_teamprofile/lbl_driver2B"))
Global lbl_TeamProfile_Champs:fry_TLabel = fry_TLabel(fry_GetGadget("pan_teamprofile/lbl_champs"))
Global tbl_TeamProfile:fry_TTable = fry_TTable(fry_GetGadget("pan_teamprofile/tbl_profile"))

Global can_TeamProfileImg:fry_TCanvas = fry_CreateCanvas("can_TeamProfileImg", 10, 10, 280, 160, pan_TeamProfile)
can_TeamProfileImg.SetBackground(1)
can_TeamProfileImg.SetColour(128,128,128)
can_TeamProfileImg.SetDraw(DrawTeamProfileImg)

Global can_TeamProfileNat:fry_TCanvas = fry_CreateCanvas("can_TeamProfileNat", 300, 10, 62, 42, pan_TeamProfile)
can_TeamProfileNat.SetBackground(1)
can_TeamProfileNat.SetColour(128,128,128)
can_TeamProfileNat.SetDraw(DrawTeamProfileNat)

Global btn_TeamProfile_Back:fry_TButton = fry_CreateImageButton("btn_TeamProfile_Back", gAppLoc+"Skin/Graphics/Buttons/SkipLeft.png", pan_TeamProfile.gW-42-42-42, 9, 32, 32, pan_TeamProfile)
Global btn_TeamProfile_Fwd:fry_TButton = fry_CreateImageButton("btn_TeamProfile_Fwd", gAppLoc+"Skin/Graphics/Buttons/SkipRight.png", pan_TeamProfile.gW-42-42, 9, 32, 32, pan_TeamProfile)

Const CEDITNAME_TEAM:Int = 1, CEDITNAME_PRINCIPAL:Int = 2, CEDITNAME_DRIVER1:Int = 3,CEDITNAME_DRIVER2:Int = 4
Global btn_TeamProfile_EditTeam:fry_TButton = fry_CreateImageButton("btn_EditTeam", gAppLoc+"Skin/Graphics/Buttons/Edit.png", pan_TeamProfile.gW-42, 9, 32, 32, pan_TeamProfile)
Global btn_TeamProfile_EditPrincipal:fry_TButton = fry_CreateImageButton("btn_EditP", gAppLoc+"Skin/Graphics/Buttons/EditSmall.png", 300, 56, 16, 16, pan_TeamProfile)
Global btn_TeamProfile_EditDriver1:fry_TButton = fry_CreateImageButton("btn_EditD1", gAppLoc+"Skin/Graphics/Buttons/EditSmall.png", pan_driverprofile1.gW-26, 9, 16, 16, pan_driverprofile1)
Global btn_TeamProfile_EditDriver2:fry_TButton = fry_CreateImageButton("btn_EditD2", gAppLoc+"Skin/Graphics/Buttons/EditSmall.png", pan_driverprofile2.gW-26, 9, 16, 16, pan_driverprofile2)

Global can_TeamProfile_TeamRating1:fry_TCanvas = fry_CreateCanvas("can_TeamProfile_TeamRating1", 22, 58, 100, 16, pan_TeamProfile)
can_TeamProfile_TeamRating1.SetBackground(0)
can_TeamProfile_TeamRating1.SetDraw(DrawNewPlayerTeamRating1)

Global can_TeamProfile_TeamRating2:fry_TCanvas = fry_CreateCanvas("can_TeamProfile_TeamRating2", 22, 98, 100, 16, pan_TeamProfile)
can_TeamProfile_TeamRating2.SetBackground(0)
can_TeamProfile_TeamRating2.SetDraw(DrawNewPlayerTeamRating2)

Global can_TeamProfile_TeamRating3:fry_TCanvas = fry_CreateCanvas("can_TeamProfile_TeamRating3", 22, 138, 100, 16, pan_TeamProfile)
can_TeamProfile_TeamRating3.SetBackground(0)
can_TeamProfile_TeamRating3.SetDraw(DrawNewPlayerTeamRating3)

Global gViewTeam:Int = 1

Function SetUpScreen_Team(t:Int = 0)
	fry_SetScreen("screen_team")
	If t = 0
		gViewTeam = TTeam.GetTeamByDriverId(gMyDriverId).id
	Else
		gViewTeam = t
	EndIf
	
	UpdateLapRecords()
	SetUpPanel_TeamProfile(gViewTeam)
End Function

Function UpdateLapRecords()
	' Lap records have a database field but I decided that they can fluctuate
	' to reflect the current lap record holders. So should be updated every time 
	' the player wishes to view stats
	
	' First reset lap records
	For Local drv:TDriver = EachIn TDriver.list
		drv.careerlaps = 0
	Next
	
	For Local team:TTeam = EachIn TTeam.list
		team.careerlaps = 0
	Next
	
	' Then tally laps
	Local prep_Select:Int = db.PrepareQuery("SELECT lapholder FROM track")
	
	While db.StepQuery(prep_SELECT) = SQLITE_ROW 
		' Get driver
		Local drv:TDriver = TDriver.GetDriverById(db.P(prep_Select, "lapholder").ToInt())
		
		' Update his stat and the team stat
		If drv
			drv.careerlaps:+1
			TTeam.GetById(drv.team).careerlaps:+1
		EndIf
	Wend
	
	db.FinalizeQuery(prep_Select)
	
	' Update in database
	TTeam.UpdateDbAll()
	TDriver.UpdateDbAll()
End Function

Function SetUpPanel_DriverProfile1(id:Int = 21)	
	btn_TeamProfile_EditDriver1.SetAlpha(1)
	If id = gMyDriverId Then btn_TeamProfile_EditDriver1.SetAlpha(0.2)
	
	Local nat:Int = GetDatabaseInt("nationality", "driver", id)
	If nat = 61 Or nat = 159 Or nat = 203 Then nat = 0
	imgDriverProfileFlag1 = LoadMyImage("Media\Nations\NationIm_"+nat+".png")
	
	tbl_DriverProfile1.ClearItems()
	
	lbl_DriverProfile1_Name.SetText(GetDatabaseString("name", "driver", id))
	lbl_DriverProfile1_DOB.SetText(GetDateString(GetDatabaseInt("dob", "driver", id)))
	lbl_DriverProfile1_POB.SetText(GetDatabaseString("pob", "driver", id))
	
	Local sraces:String = GetDatabaseString("seasonraces", "driver", id)
	Local spts:String = GetDatabaseString("seasonpts", "driver", id)
	Local swins:String = GetDatabaseString("seasonwins", "driver", id)
	Local spoles:String = GetDatabaseString("seasonpoles", "driver", id)
	Local spodiums:String = GetDatabaseString("seasonpodiums", "driver", id)
	
	Local craces:String = GetDatabaseString("careerraces", "driver", id)
	Local cpts:String = GetDatabaseString("careerpts", "driver", id)
	Local cchamps:String = GetDatabaseString("championships", "driver", id)
	Local cwins:String = GetDatabaseString("careerwins", "driver", id)
	Local cpoles:String = GetDatabaseString("careerpoles", "driver", id)
	Local cpodiums:String = GetDatabaseString("careerpodiums", "driver", id)
	Local claps:String = GetDatabaseString("careerlaps", "driver", id)
	
	tbl_DriverProfile1.AddItem([GetLocaleText("Races"), sraces, craces])
	tbl_DriverProfile1.AddItem([GetLocaleText("Points"), spts, cpts])
	tbl_DriverProfile1.AddItem([GetLocaleText("Wins"), swins, cwins])
	tbl_DriverProfile1.AddItem([GetLocaleText("Poles"), spoles, cpoles])
	tbl_DriverProfile1.AddItem([GetLocaleText("Podiums"), spodiums, cpodiums])
	
	tbl_DriverProfile1.AddItem([GetLocaleText("Championships"), "-", cchamps])
	tbl_DriverProfile1.AddItem([GetLocaleText("Lap Records"), "-", claps])
	
	tbl_DriverProfile1.SelectItem(1)
End Function

Function SetUpPanel_DriverProfile2(id:Int = 21)	
	btn_TeamProfile_EditDriver2.SetAlpha(1)
	If id = gMyDriverId Then btn_TeamProfile_EditDriver2.SetAlpha(0.2)
	
	Local nat:Int = GetDatabaseInt("nationality", "driver", id)
	If nat = 61 Or nat = 159 Or nat = 203 Then nat = 0
	imgDriverProfileFlag2 = LoadMyImage("Media\Nations\NationIm_"+nat+".png")
	
	tbl_DriverProfile2.ClearItems()
	
	lbl_DriverProfile2_Name.SetText(GetDatabaseString("name", "driver", id))
	lbl_DriverProfile2_DOB.SetText(GetDateString(GetDatabaseInt("dob", "driver", id)))
	lbl_DriverProfile2_POB.SetText(GetDatabaseString("pob", "driver", id))
	
	Local sraces:String = GetDatabaseString("seasonraces", "driver", id)
	Local spts:String = GetDatabaseString("seasonpts", "driver", id)
	Local swins:String = GetDatabaseString("seasonwins", "driver", id)
	Local spoles:String = GetDatabaseString("seasonpoles", "driver", id)
	Local spodiums:String = GetDatabaseString("seasonpodiums", "driver", id)
	
	Local craces:String = GetDatabaseString("careerraces", "driver", id)
	Local cpts:String = GetDatabaseString("careerpts", "driver", id)
	Local cchamps:String = GetDatabaseString("championships", "driver", id)
	Local cwins:String = GetDatabaseString("careerwins", "driver", id)
	Local cpoles:String = GetDatabaseString("careerpoles", "driver", id)
	Local cpodiums:String = GetDatabaseString("careerpodiums", "driver", id)
	Local claps:String = GetDatabaseString("careerlaps", "driver", id)
	
	tbl_DriverProfile2.AddItem([GetLocaleText("Races"), sraces, craces])
	tbl_DriverProfile2.AddItem([GetLocaleText("Points"), spts, cpts])
	tbl_DriverProfile2.AddItem([GetLocaleText("Wins"), swins, cwins])
	tbl_DriverProfile2.AddItem([GetLocaleText("Poles"), spoles, cpoles])
	tbl_DriverProfile2.AddItem([GetLocaleText("Podiums"), spodiums, cpodiums])
	
	tbl_DriverProfile2.AddItem([GetLocaleText("Championships"), "-", cchamps])
	tbl_DriverProfile2.AddItem([GetLocaleText("Lap Records"), "-", claps])
	
	tbl_DriverProfile2.SelectItem(1)
End Function

Function SetUpPanel_TeamProfile(id:Int = 1)
	imgTeamProfile = TTeam.GetById(id).img
	
	Local nat:Int = GetDatabaseInt("nationality", "team", id)
	If nat = 61 Or nat = 159 Or nat = 203 Then nat = 0
	imgTeamProfileNat = LoadMyImage("Media\Nations\NationIm_"+nat+".png")
	
	tbl_TeamProfile.ClearItems()
	
	lbl_TeamProfile_Name.SetText(GetDatabaseString("name", "team", id))
	lbl_TeamProfile_Principal.SetText(GetDatabaseString("principal", "team", id))
	Local driverid1:Int = GetDatabaseInt("driver1", "team", id)
	Local driverid2:Int = GetDatabaseInt("driver2", "team", id)
	lbl_TeamProfile_Driver1A.SetText(GetLocaleText("Driver")+" 1")
	lbl_TeamProfile_Driver2A.SetText(GetLocaleText("Driver")+" 2")
	lbl_TeamProfile_Driver1B.SetText(GetDatabaseString("name", "driver", driverid1))
	lbl_TeamProfile_Driver2B.SetText(GetDatabaseString("name", "driver", driverid2))
	
	Local cchamps:String = GetDatabaseString("championships", "team", id)
	lbl_TeamProfile_Champs.SetText(GetLocaleText("Championships")+": "+cchamps)
	
	Local spts:String = GetDatabaseString("seasonpts", "team", id)
	Local swins:String = GetDatabaseString("seasonwins", "team", id)
	Local spoles:String = GetDatabaseString("seasonpoles", "team", id)
	Local spodiums:String = GetDatabaseString("seasonpodiums", "team", id)
	Local cwins:String = GetDatabaseString("careerwins", "team", id)
	Local cpoles:String = GetDatabaseString("careerpoles", "team", id)
	Local claps:String = GetDatabaseString("careerlaps", "team", id)
		
	tbl_TeamProfile.AddItem([GetLocaleText("Wins"), swins, cwins])
	tbl_TeamProfile.AddItem([GetLocaleText("Poles"), spoles, cpoles])
	tbl_TeamProfile.AddItem([GetLocaleText("Points"), spts, "-"])
	tbl_TeamProfile.AddItem([GetLocaleText("Podiums"), spodiums, "-"])
	tbl_TeamProfile.AddItem([GetLocaleText("Lap Records"), "-", claps])
	
	tbl_TeamProfile.SelectItem(2)
	
	SetUpPanel_DriverProfile1(driverid1)
	SetUpPanel_DriverProfile2(driverid2)
	
	NewPlayerTeamRating1 = TTeam.GetById(id).handling
	NewPlayerTeamRating2 = TTeam.GetById(id).acceleration
	NewPlayerTeamRating3 = TTeam.GetById(id).topspeed
	
	ValidateMinMaxFloat(NewPlayerTeamRating1, -10, 5)
	ValidateMinMaxFloat(NewPlayerTeamRating2, -10, 5)
	ValidateMinMaxFloat(NewPlayerTeamRating3, -10, 5)
	
	AppLog NewPlayerTeamRating1
	AppLog NewPlayerTeamRating2
	AppLog NewPlayerTeamRating3
End Function

Function TeamProfileBack()
	gViewTeam:-1
	If gViewTeam < 1 Then gViewTeam = TTeam.list.Count()
	SetUpPanel_TeamProfile(gViewTeam)
End Function

Function TeamProfileFwd()
	gViewTeam:+1
	If gViewTeam > TTeam.list.Count() Then gViewTeam = 1
	SetUpPanel_TeamProfile(gViewTeam)
End Function

Function EditName(nm:Int)
	Select nm 
	Case CEDITNAME_TEAM			
		txt_MessageBox_Txt.SetText(lbl_TeamProfile_Name.GetText())
		If DoMessage("CMESSAGE_EDITNAME",True,GetLocaleText("team"),GetLocaleText("OK"),GetLocaleText("Cancel"),,True)
			If txt_MessageBox_Txt.GetText().Length > 0
				UpdateDatabaseString("team", "name", txt_MessageBox_Txt.GetText(), gViewTeam)
			EndIf
		End If
	Case CEDITNAME_PRINCIPAL	
		txt_MessageBox_Txt.SetText(lbl_TeamProfile_Principal.GetText())
		If DoMessage("CMESSAGE_EDITNAME",True,GetLocaleText("principal"),GetLocaleText("OK"),GetLocaleText("Cancel"),,True)
			If txt_MessageBox_Txt.GetText().Length > 0
				UpdateDatabaseString("team", "principal", txt_MessageBox_Txt.GetText(), gViewTeam)
			EndIf
		End If
	Case CEDITNAME_DRIVER1
		Local drv:Int = GetDatabaseInt("driver1", "team", gViewTeam)
		If drv = gMyDriverId Then Return
		
		txt_MessageBox_Txt.SetText(lbl_TeamProfile_Driver1B.GetText())
		If DoMessage("CMESSAGE_EDITNAME",True,GetLocaleText("driver"),GetLocaleText("OK"),GetLocaleText("Cancel"),,True)
			If txt_MessageBox_Txt.GetText().Length > 0
				UpdateDatabaseString("driver", "name", txt_MessageBox_Txt.GetText(), drv)
			EndIf
		End If
	Case CEDITNAME_DRIVER2		
		Local drv:Int = GetDatabaseInt("driver2", "team", gViewTeam)
		If drv = gMyDriverId Then Return
		
		txt_MessageBox_Txt.SetText(lbl_TeamProfile_Driver2B.GetText())
		If DoMessage("CMESSAGE_EDITNAME",True,GetLocaleText("driver"),GetLocaleText("OK"),GetLocaleText("Cancel"),,True)
			If txt_MessageBox_Txt.GetText().Length > 0
				UpdateDatabaseString("driver", "name", txt_MessageBox_Txt.GetText(), drv)
			EndIf
		End If
	End Select
	
	SetUpScreen_Team(gViewTeam)
End Function
' ----------------------------------
' Finances
' ----------------------------------
Global pan_Finances_Balance:fry_TPanel = fry_TPanel(fry_GetGadget("pan_financesbalance"))
Global tbl_Finances_Balance:fry_TTable = fry_TTable(fry_GetGadget("pan_financesbalance/tbl_balance"))

Global pan_Finances_Cars:fry_TPanel = fry_TPanel(fry_GetGadget("pan_financescars"))
Global tbl_Finances_Cars:fry_TTable = fry_TTable(fry_GetGadget("pan_financescars/tbl_shopitems"))
Global btn_Finances_CarsBuy:fry_TButton = fry_TButton(fry_GetGadget("pan_financescars/btn_carbuy"))
Global btn_Finances_CarsDrive:fry_TButton = fry_TButton(fry_GetGadget("pan_financescars/btn_cardrive"))

Global pan_Finances_Property:fry_TPanel = fry_TPanel(fry_GetGadget("pan_financesproperty"))
Global tbl_Finances_Property:fry_TTable = fry_TTable(fry_GetGadget("pan_financesproperty/tbl_shopitems"))
Global btn_Finances_PropertyBuy:fry_TButton = fry_TButton(fry_GetGadget("pan_financesproperty/btn_propertybuy"))

Global can_Finances_CarImg:fry_TCanvas = fry_CreateCanvas("can_Finances_CarImg", 49, 30, 152, 102, pan_Finances_Cars)
can_Finances_CarImg.SetBackground(1)
can_Finances_CarImg.SetColour(128,128,128)
can_Finances_CarImg.SetDraw(TShopItem.DrawFinancesCarImg)

Global can_Finances_PropertyImg:fry_TCanvas = fry_CreateCanvas("can_Finances_PropertyImg", 49, 30, 152, 102, pan_Finances_Property)
can_Finances_PropertyImg.SetBackground(1)
can_Finances_PropertyImg.SetColour(128,128,128)
can_Finances_PropertyImg.SetDraw(TShopItem.DrawFinancesPropertyImg)


Function SetUpScreen_Finances()
	fry_SetScreen("screen_finances")
	
	TShopItem.RefreshTable(CSHOPITEM_CAR)
	TShopItem.RefreshTable(CSHOPITEM_PROPERTY)
	TShopItem.UpdateShopImages(CSHOPITEM_CAR)
	TShopItem.UpdateShopImages(CSHOPITEM_PROPERTY)
	SetUpPanel_Balance()
End Function

Function SetUpPanel_Balance()
	tbl_Finances_Balance.ClearItems()
	
	Local amt:Int = GetDatabaseInt("prizemoney", "gamedata", 1)
	tbl_Finances_Balance.AddItem([GetLocaleText("Prize Money"), TCurrency.GetString(OpCurrency, amt)])
	
	amt = GetDatabaseInt("gamblingmoney", "gamedata", 1)
	tbl_Finances_Balance.AddItem([GetLocaleText("Gambling"), TCurrency.GetString(OpCurrency, amt)])
	
	amt = -TShopItem.GetValueOfItemsOwned(CSHOPITEM_CAR)
	tbl_Finances_Balance.AddItem([GetLocaleText("Cars"), TCurrency.GetString(OpCurrency, amt)])
	
	amt = -TShopItem.GetValueOfItemsOwned(CSHOPITEM_PROPERTY)
	tbl_Finances_Balance.AddItem([GetLocaleText("Property"), TCurrency.GetString(OpCurrency, amt)])
	
	amt = GetDatabaseInt("sponsormoney", "gamedata", 1)
	tbl_Finances_Balance.AddItem([GetLocaleText("Sponsorship"), TCurrency.GetString(OpCurrency, amt)])
End Function

' ----------------------------------
' Editor
' ----------------------------------
Global btn_Editor_ControlsBase:fry_TButton = fry_TButton(fry_GetGadget("pan_editorcontrols/btn_base"))
Global btn_Editor_ControlsTrack:fry_TButton = fry_TButton(fry_GetGadget("pan_editorcontrols/btn_track"))
Global btn_Editor_ControlsObjects:fry_TButton = fry_TButton(fry_GetGadget("pan_editorcontrols/btn_objects"))
Global btn_Editor_ControlsCheckPoints:fry_TButton = fry_TButton(fry_GetGadget("pan_editorcontrols/btn_checkp"))
Global btn_Editor_ControlsRacingLine:fry_TButton = fry_TButton(fry_GetGadget("pan_editorcontrols/btn_racing"))
Global btn_Editor_ControlsPitLane:fry_TButton = fry_TButton(fry_GetGadget("pan_editorcontrols/btn_pit"))
Global btn_Editor_ControlsWalls:fry_TButton = fry_TButton(fry_GetGadget("pan_editorcontrols/btn_walls"))

Global pan_Editor_LoadTrack:fry_TPanel = fry_TPanel(fry_GetGadget("pan_editorloadtrack"))
Global tbl_Editor_LoadTrack:fry_TTable = fry_TTable(fry_GetGadget("pan_editorloadtrack/tbl_load"))
Global btn_Editor_LoadTrack:fry_TButton = fry_TButton(fry_GetGadget("pan_editorloadtrack/btn_loadtrack"))
Global btn_Editor_DeleteTrack:fry_TButton = fry_TButton(fry_GetGadget("pan_editorloadtrack/btn_deletetrack"))

Global txt_Editor_TrackName:fry_TTextField = fry_TTextField(fry_GetGadget("pan_editorsavetrack/txt_name"))
Global btn_Editor_SaveTrack:fry_TButton = fry_TButton(fry_GetGadget("pan_editorsavetrack/btn_savetrack"))

Global btn_Editor_Continue:fry_TButton = fry_TButton(fry_GetGadget("pan_editorcontinue/btn_continue"))
Global btn_Editor_Exit:fry_TButton = fry_TButton(fry_GetGadget("pan_editorexit/btn_exit"))
Global btn_Editor_Help:fry_TButton = fry_TButton(fry_GetGadget("pan_editorhelp/btn_help"))

Global txt_Editor_TrackMap:fry_TTextField = fry_TTextField(fry_GetGadget("pan_editortrackmap/txt_name"))
Global chk_Editor_TrackMap:fry_TCheckBox = fry_TCheckBox(fry_GetGadget("pan_editortrackmap/chk_map"))
txt_Editor_TrackMap.SetText("TrackIm_1.png")

Function SetUpScreen_Editor()
	fry_SetScreen("screen_editor")
	UpdateLoadTrackTable()
End Function

Function EditorSaveTrack()
	Local name:String = txt_Editor_TrackName.GetText()
	
	If name = "" Then name = "Track_0"
	
	If Right(name, 4) = ".trk"
		name = Left(name, Len(name)-4)
	End If
	
	txt_Editor_TrackName.SetText(name)
	
	track.SaveTrack(name)
	UpdateLoadTrackTable()
End Function

Function EditorExit:Int()
	If DoMessage("CMESSAGE_QUITEDITOR", True)
		track.editing = False
		track.Quit()
		Return True
	EndIf
	
	Return False
End Function

Function UpdateLoadTrackTable()
	tbl_Editor_LoadTrack.ClearItems();	While fry_PollEvent() Wend
	
	Local dir:Int = ReadDir(gSaveLoc+"Tracks")
	
	Repeat
		Local trackname$=NextFile( dir )
		If Right(trackname,4) = ".trk" 'and trackname <> "QuickMatch.db"
			tbl_Editor_LoadTrack.AddItem([Left(trackname, Len(trackname)-4)],0,Null)
		EndIf
		If trackname="" Exit
	Forever
	
	CloseDir dir
	
	tbl_Editor_LoadTrack.SelectItem(0)
End Function

Function EditorLoadTrack()	
	Local name:String = tbl_Editor_LoadTrack.GetText(tbl_Editor_LoadTrack.SelectedItem(), 0)
	track.LoadTrack(name)
	txt_Editor_TrackName.SetText(name)
End Function

Function EditorMap()
	If chk_Editor_TrackMap.GetState()
		If FileType(gSaveloc+"Tracks/"+txt_Editor_TrackMap.GetText()) = 1
			track.img = LoadMyImage(gSaveloc+"Tracks/"+txt_Editor_TrackMap.GetText())
		EndIf
	Else
		track.img = Null
	End If
End Function

Function EditorDeleteTrack()
	If tbl_Editor_LoadTrack.SelectedItem() < 0 Then Return
	If Not DoMessage("CMESSAGE_DELETE", True, tbl_Editor_LoadTrack.GetText(tbl_Editor_LoadTrack.SelectedItem(),0)) Then Return
	
	DeleteFile(gSaveloc+"Tracks/"+tbl_Editor_LoadTrack.GetText(tbl_Editor_LoadTrack.SelectedItem(),0)+".trk")
	UpdateLoadTrackTable()
End Function

Function QuickRace()
	If tbl_QuickRace.SelectedItem() < 0 Then Return
	
	gMyDriverId = cmb_QuickRace_Driver.SelectedData()
	TNation.SelectAll()
	Race(tbl_QuickRace.GetText(tbl_QuickRace.SelectedItem(),0))
End Function

Function CheckTextBoxModes()
	Local r:Int=200, g:Int=200, b:Int=200
	Select txt_NewPlayer_Name.gMode
	Case 0	txt_NewPlayer_Name.SetColour(r,g,b)
	Case 1	txt_NewPlayer_Name.SetColour(255,0,0)
	End Select
	
	Select txt_NewPlayer_POB.gMode
	Case 0	txt_NewPlayer_POB.SetColour(r,g,b)
	Case 1	txt_NewPlayer_POB.SetColour(255,0,0)
	End Select
	
	Select txt_NewPlayer_SaveName.gMode
	Case 0	txt_NewPlayer_SaveName.SetColour(r,g,b)
	Case 1	txt_NewPlayer_SaveName.SetColour(255,0,0)
	End Select
	
	Select txt_Editor_TrackName.gMode
	Case 0	txt_Editor_TrackName.SetColour(r,g,b)
	Case 1	txt_Editor_TrackName.SetColour(255,0,0)
	End Select
	
	Select txt_Editor_TrackMap.gMode
	Case 0	txt_Editor_TrackMap.SetColour(r,g,b)
	Case 1	txt_Editor_TrackMap.SetColour(255,0,0)
	End Select
	
	Select txt_MessageBox_Txt.gMode
	Case 0	txt_MessageBox_Txt.SetColour(r,g,b)
	Case 1	txt_MessageBox_Txt.SetColour(255,0,0)
	End Select

	
	Select TOnline.txt_Online_Chat.gMode
	Case 0	TOnline.txt_Online_Chat.SetColour(r,g,b)
	Case 1	TOnline.txt_Online_Chat.SetColour(255,0,0)
	End Select
	
End Function

' ----------------------------------
' Tracks (Online leaderboard)
' ----------------------------------

Global pan_TrackProfile:fry_TPanel = fry_TPanel(fry_GetGadget("pan_trackprofile"))
Global btn_Track_Back:fry_TButton = fry_CreateImageButton("btn_Track_Back", gAppLoc+"Skin/Graphics/Buttons/SkipLeftSmall.png", pan_TrackProfile.gW-24-22, 8, 16, 16, pan_TrackProfile)
Global btn_Track_Fwd:fry_TButton = fry_CreateImageButton("btn_Track_Fwd", gAppLoc+"Skin/Graphics/Buttons/SkipRightSmall.png", pan_TrackProfile.gW-24, 8, 16, 16, pan_TrackProfile)

Global lbl_TrackProfile_Name:fry_TLabel = fry_TLabel(fry_GetGadget("pan_trackprofile/lbl_name"))
Global lbl_TrackProfile_Nation:fry_TLabel = fry_TLabel(fry_GetGadget("pan_trackprofile/lbl_nation"))
Global lbl_TrackProfile_Length:fry_TLabel = fry_TLabel(fry_GetGadget("pan_trackprofile/lbl_length"))
Global lbl_TrackProfile_LapTime:fry_TLabel = fry_TLabel(fry_GetGadget("pan_trackprofile/lbl_fastestlap"))
Global lbl_TrackProfile_LapHolder:fry_TLabel = fry_TLabel(fry_GetGadget("pan_trackprofile/lbl_lapholder"))

Global can_TrackProfile_Flag:fry_TCanvas = fry_CreateCanvas("can_TrackProfile_Nat", 10, 10, 62, 42, pan_TrackProfile)
can_TrackProfile_Flag.SetBackground(1)
can_TrackProfile_Flag.SetColour(128,128,128)
can_TrackProfile_Flag.SetDraw(DrawTrackProfileFlag)

Global can_TrackProfile_Track:fry_TCanvas = fry_CreateCanvas("can_TrackProfile_Track", 10, 62, 152, 107, pan_TrackProfile)
can_TrackProfile_Track.SetBackground(1)
can_TrackProfile_Track.SetColour(128,128,128)
can_TrackProfile_Track.SetDraw(DrawTrackProfileImg)

Global pan_Leaderboard:fry_TPanel = fry_TPanel(fry_GetGadget("pan_leaderboard"))
Global tbl_Leaderboard:fry_TTable = fry_TTable(fry_GetGadget("pan_leaderboard/tbl_leaderboard"))

Global lbl_LeaderBoard_TrackName:fry_TLabel = fry_TLabel(fry_GetGadget("pan_leaderboardcontrols/lbl_trackname"))
Global lbl_LeaderBoard_PersonalBest:fry_TLabel = fry_TLabel(fry_GetGadget("pan_leaderboardcontrols/lbl_personalbest"))

Global btn_Leaderboard_Refresh:fry_TButton = fry_TButton(fry_GetGadget("pan_leaderboard/btn_refresh"))
Global btn_Leaderboard_Upload:fry_TButton = fry_TButton(fry_GetGadget("pan_leaderboardcontrols/btn_upload"))

Global pan_History:fry_TPanel = fry_TPanel(fry_GetGadget("pan_history"))
Global lbl_History:fry_TLabel = fry_TLabel(fry_GetGadget("pan_history/lbl_history"))
Global btn_History_Back:fry_TButton = fry_CreateImageButton("btn_History_Back", gAppLoc+"Skin/Graphics/Buttons/SkipLeftSmall.png", pan_history.gW-24-22, 8, 16, 16, pan_history)
Global btn_History_Fwd:fry_TButton = fry_CreateImageButton("btn_History_Fwd", gAppLoc+"Skin/Graphics/Buttons/SkipRightSmall.png", pan_history.gW-24, 8, 16, 16, pan_history)
Global tbl_History:fry_TTable = fry_TTable(fry_GetGadget("pan_history/tbl_history"))

Global gViewTrack:Int = 1
Global gViewHistory:Int = 1

Function SetUpScreen_Leaderboards()
	fry_SetScreen("screen_leaderboards")
	gViewHistory = gYear
	
	btn_Track_Back.Show()
	btn_Track_Fwd.Show()
	SetUpPanel_TrackProfile()
	SetUpPanel_History()
	SetUpPanel_LeaderboardControls()
End Function

Function SetUpPanel_LeaderboardControls()
	lbl_LeaderBoard_TrackName.SetText(lbl_TrackProfile_Name.GetText())
	Local mytime:Int = GetDatabaseInt("playerlaprecord", "track", gViewTrack)
	
	mytime:-TDriver.GetDriverById(gMyDriverId).dob
	mytime:/gViewTrack+1
	
	If mytime < 20000 Then mytime = 0
		
	lbl_LeaderBoard_PersonalBest.SetText(GetStringTime(mytime))
	
	btn_Leaderboard_Upload.SetAlpha(1)
	If mytime <= 0 Or gModLoc <> "" Then btn_Leaderboard_Upload.SetAlpha(0.5)
	RetrieveLeaderboard(gViewTrack)
	
End Function

Function Leaderboard_SubmitTime()
	If btn_Leaderboard_Upload.gAlpha <> 1 Then Return
	
	Local team:TTeam = TTeam.GetTeamByDriverId(gMyDriverId)
	Local me:TDriver = TDriver.GetDriverById(gMyDriverId)
	Local myname:String = me.name
	
	Local mytimestr:String = GetDatabaseString("playerlaprecord", "track", gViewTrack)
	AppLog "mytimestr="+mytimestr
	
	Local mytime:Int
	Local myhandling:String
	Local myacceleration:String
	Local mytopspeed:String
	
	If mytimestr.Contains(":")
		mytopspeed = mytimestr[mytimestr.Length-3..mytimestr.Length]
		AppLog mytopspeed
		mytimestr = mytimestr[0..mytimestr.Length-4]
		
		myacceleration = mytimestr[mytimestr.Length-3..mytimestr.Length]
		AppLog myacceleration
		mytimestr = mytimestr[0..mytimestr.Length-4]
		
		myhandling = mytimestr[mytimestr.Length-3..mytimestr.Length]
		AppLog myhandling
		mytimestr = mytimestr[0..mytimestr.Length-4]
		
		AppLog mytimestr
		mytime = mytimestr.ToInt()	
		mytime:-TDriver.GetDriverById(gMyDriverId).dob
		mytime:/gViewTrack+1
	Else
		mytime = GetDatabaseInt("playerlaprecord", "track", gViewTrack)
		mytime:-TDriver.GetDriverById(gMyDriverId).dob
		mytime:/gViewTrack+1
		
		myhandling = GetFloatAsString(team.handling)
		myacceleration = GetFloatAsString(team.acceleration)
		mytopspeed = GetFloatAsString(team.topspeed)
	End If
	
	AppLog "mytime"+mytime
	Local mynat:String = TNation.SelectById(me.nationality).name
	Local license:String = GetDatabaseString("license", "gamedata", 1)
	
	SubmitLaptime(myname, gViewTrack, mytime, mynat, team.name, myhandling, myacceleration, mytopspeed, license)
End Function

Function SetUpPanel_History()
	AppLog "SetUpPanel_History"
	btn_History_Back.SetAlpha(1)
	btn_History_Fwd.SetAlpha(1)
	
	If gViewHistory = 1 Then btn_History_Back.SetAlpha(0.5)
	If gViewHistory >= gYear Then btn_History_Fwd.SetAlpha(0.5)
	
	lbl_History.SetText(GetLocaleText("Season")+" "+String(gViewHistory))
	tbl_History.ClearItems()
	
	' CREATE TABLE history (id INTEGER PRIMARY KEY, year INTEGER, track INTEGER, driver TEXT, team TEXT, position INTEGER, time INTEGER, points INTEGER)
	Local q:String = "SELECT * FROM history WHERE year="+gViewHistory+" AND track="+gViewTrack+" ORDER BY position"
	AppLog q
	Local prep_Select:Int = db.PrepareQuery(q)
	
	Local pos:Int = 1
	Local sel:Int
	
	While db.StepQuery(prep_SELECT) = SQLITE_ROW 
		Local drv:String = db.P(prep_Select, "driver")
		AppLog drv
		Local team:String = db.P(prep_Select, "team")
		
		Local time:String = GetStringTime(db.P(prep_Select, "time").ToInt(),,db.P(prep_Select, "iwaslapped").ToInt())
		If db.P(prep_Select, "time").ToInt() = 0 Then time = GetLocaleText("tla_DidNotFinish")
		
		Local points:String = db.P(prep_Select, "points")
		
		tbl_History.AddItem([String(pos), drv, team, time, points])
		
		If drv = TDriver.GetDriverById(gMyDriverId).name Then sel = pos-1
		pos:+1
	Wend
	
	db.FinalizeQuery(prep_Select)
	
	tbl_History.SelectItem(sel)
	If sel > 9 Then tbl_History.ShowItem(sel - 4)
End Function

Function HistoryBack()
	gViewHistory:-1
	If gViewHistory < 1 Then gViewHistory = 1
	 
	SetUpPanel_History()
End Function

Function HistoryFwd()
	gViewHistory:+1
	If gViewHistory > gYear Then gViewHistory = gYear
	
	SetUpPanel_History()
End Function

' ----------------------------------
' Options
' ----------------------------------
Global pan_Options_Nav:fry_TPanel = fry_TPanel(fry_GetGadget("pan_options_nav"))
Global btn_Options_Cancel:fry_TButton = fry_CreateImageButton("btn_OpCancel", gAppLoc+"Skin/Graphics/Buttons/Cancel.png", pan_Options_Nav.gW-74-42, 9, 32, 32, pan_Options_Nav)
Global btn_Options_Proceed:fry_TButton = fry_CreateImageButton("btn_OpProceed", gAppLoc+"Skin/Graphics/Buttons/Play.png", pan_Options_Nav.gW-74, 9, 64, 32, pan_Options_Nav)

Global pan_Options:fry_TPanel = fry_TPanel(fry_GetGadget("pan_options"))

Global sld_Options_Laps:fry_TSlider = fry_TSlider(fry_GetGadget("pan_options/sld_laps"))
Global sld_Options_View:fry_TSlider = fry_TSlider(fry_GetGadget("pan_options/sld_view"))

Global lbl_Options_Laps:fry_TLabel = fry_TLabel(fry_GetGadget("pan_options/lbl_lap"))
Global lbl_Options_View:fry_TLabel = fry_TLabel(fry_GetGadget("pan_options/lbl_view"))

Global chk_Options_Radio:fry_TCheckBox = fry_TCheckBox(fry_GetGadget("pan_options/chk_radio"))
Global chk_Options_Map:fry_TCheckBox = fry_TCheckBox(fry_GetGadget("pan_options/chk_map"))
Global chk_Options_Fuel:fry_TCheckBox = fry_TCheckBox(fry_GetGadget("pan_options/chk_fuel"))
Global chk_Options_Damage:fry_TCheckBox = fry_TCheckBox(fry_GetGadget("pan_options/chk_damage"))
Global chk_Options_Tyres:fry_TCheckBox = fry_TCheckBox(fry_GetGadget("pan_options/chk_tyres"))
Global chk_Options_Speedo:fry_TCheckBox = fry_TCheckBox(fry_GetGadget("pan_options/chk_speedo"))
Global chk_Options_Kers:fry_TCheckBox = fry_TCheckBox(fry_GetGadget("pan_options/chk_kers"))
chk_Options_Kers.SetText(GetLocaleText("KERS")+" ("+GetLocaleText("Boost")+")")
Global chk_Options_FullScreen:fry_TCheckBox = fry_TCheckBox(fry_GetGadget("pan_options/chk_fullscreen"))

Global sld_Options_SoundFX:fry_TSlider = fry_TSlider(fry_GetGadget("pan_options/sld_volumefx"))
Global sld_Options_Music:fry_TSlider = fry_TSlider(fry_GetGadget("pan_options/sld_volumemusic"))

Global lbl_Options_SoundFX:fry_TLabel = fry_TLabel(fry_GetGadget("pan_options/lbl_volumefx"))
Global lbl_Options_Music:fry_TLabel = fry_TLabel(fry_GetGadget("pan_options/lbl_volumemusic"))

Global btn_Options_Easy:fry_TButton = fry_TButton(fry_GetGadget("pan_options/btn_easy"))
Global btn_Options_Normal:fry_TButton = fry_TButton(fry_GetGadget("pan_options/btn_normal"))
Global btn_Options_Hard:fry_TButton = fry_TButton(fry_GetGadget("pan_options/btn_hard"))
Global btn_Options_Extreme:fry_TButton = fry_TButton(fry_GetGadget("pan_options/btn_extreme"))

Global btn_Options_Left:fry_TButton = fry_TButton(fry_GetGadget("pan_options/btn_left"))
Global btn_Options_Right:fry_TButton = fry_TButton(fry_GetGadget("pan_options/btn_right"))
Global btn_Options_Up:fry_TButton = fry_TButton(fry_GetGadget("pan_options/btn_up"))
Global btn_Options_Down:fry_TButton = fry_TButton(fry_GetGadget("pan_options/btn_down"))
Global btn_Options_Pause:fry_TButton = fry_TButton(fry_GetGadget("pan_options/btn_pause"))
Global btn_Options_Info:fry_TButton = fry_TButton(fry_GetGadget("pan_options/btn_info"))
Global btn_Options_Kers:fry_TButton = fry_TButton(fry_GetGadget("pan_options/btn_kers"))

Global lbl_Options_LReg:fry_TLabel = fry_TLabel(fry_GetGadget("pan_options/lbl_title6"))
Global lbl_Options_LName:fry_TLabel = fry_TLabel(fry_GetGadget("pan_options/lbl_lname"))
Global lbl_Options_LStatus:fry_TLabel = fry_TLabel(fry_GetGadget("pan_options/lbl_lstatus"))
Global lbl_Options_Name:fry_TLabel = fry_TLabel(fry_GetGadget("pan_options/lbl_name"))
Global lbl_Options_Status:fry_TLabel = fry_TLabel(fry_GetGadget("pan_options/lbl_status"))
Global btn_Options_Reg:fry_TButton = fry_TButton(fry_GetGadget("pan_options/btn_reg"))

Global options_prevscreen:String

Function SetUpScreen_Options()
	AppLog "SetUpScreen_Options"
	options_prevscreen = fry_ScreenName()
	
	fry_SetScreen("screen_options")
	
	btn_Header_Quit.Hide()
	btn_Header_Options.Hide()
	btn_Options_Cancel.Show()
	prg_Title.Hide()
	
	LoadOptions()
	SetUpPanel_Options()
End Function

Function SetUpPanel_Options()
	AppLog "SetUpPanel_Options"
	' Flush joy to allow control changes
	MyFlushJoy(False)	' Don't flush mouse or slide bars cannot be moved
	
	' Update Channels
	chn_FX.SetVolume(OpVolumeFX)
	chn_CasinoAmbience.SetVolume(OpVolumeFX)
	
	If track.mode = CTRACKMODE_PAUSED
		chn_Music.SetVolume(0)
	Else
		chn_Music.SetVolume(OpVolumeMusic)
	EndIf
	
	' Update race
	If track And track.mode = CTRACKMODE_PAUSED And track.racestatus <> CRACESTATUS_PRACTICE And track.racestatus <> CRACESTATUS_QUALIFY
		AppLog "Update race"
		Local mostlapscomplete:Int = 0
		
		For Local car:TCar = EachIn TCar.list
			If car.lapscomplete > mostlapscomplete Then mostlapscomplete = car.lapscomplete
		Next
		
		If OpLaps > mostlapscomplete 
			track.totallaps = OpLaps
			
			For Local car:TCar = EachIn TCar.list
				If car.fuel < 50 Then car.fuel = 50
			Next
		Else
			track.totallaps = mostlapscomplete+1
		End If
		
		track.UpdateTrackScale()
	End If
	
	AppLog "Set Up Sliders"
	SetUpSlider(sld_Options_Laps, 3, 60, OpLaps, 1)
	SetUpSlider(sld_Options_View, 1, 5, OpView, 1)
	
	chk_Options_Radio.SetState(OpRadio)
	chk_Options_Map.SetState(OpMap)
	chk_Options_Fuel.SetState(OpFuel)
	chk_Options_Damage.SetState(OpDamage)
	chk_Options_Tyres.SetState(OpTyres)
	chk_Options_Speedo.SetState(OpSpeedo)
	chk_Options_Kers.SetState(OpKers)
	chk_Options_FullScreen.SetState(gFullscreen)
	
	SetUpSlider(sld_Options_SoundFX, 0, 10, Int(OpVolumeFX*10), 1)
	SetUpSlider(sld_Options_Music, 0, 10, Int(OpVolumeMusic*10), 1)
	
	lbl_Options_Laps.SetText(OpLaps)
	lbl_Options_View.SetText(GetStringView())
	lbl_Options_SoundFX.SetText(String(sld_Options_SoundFX.GetValue()*10)+"%")
	lbl_Options_Music.SetText(String(sld_Options_Music.GetValue()*10)+"%")
	
	btn_Options_Easy.SetAlpha(0.5)
	btn_Options_Normal.SetAlpha(0.5)
	btn_Options_Hard.SetAlpha(0.5)
	btn_Options_Extreme.SetAlpha(0.5)
	
	Select OpDifficulty
	Case 1	btn_Options_Easy.SetAlpha(1)
	Case 2	btn_Options_Normal.SetAlpha(1)
	Case 3	btn_Options_Hard.SetAlpha(1)
	Case 4	btn_Options_Extreme.SetAlpha(1)
	End Select
	
	AppLog "Update Control Buttons"
	btn_Options_Left.SetText(GetButtonLabel(MYKEY_LEFT))
	btn_Options_Right.SetText(GetButtonLabel(MYKEY_RIGHT))
	btn_Options_Up.SetText(GetButtonLabel(MYKEY_UP))
	btn_Options_Down.SetText(GetButtonLabel(MYKEY_DOWN))
	btn_Options_Pause.SetText(GetButtonLabel(MYKEY_PAUSE))
	btn_Options_Info.SetText(GetButtonLabel(MYKEY_INFO))
	btn_Options_Kers.SetText(GetButtonLabel(MYKEY_KERS))
	
	If gMyDriverId = 21
		AppLog "Show reg details"
		lbl_Options_LReg.Show()
		lbl_Options_LName.Show()
		lbl_Options_LStatus.Show()
		lbl_Options_Name.Show()
		lbl_Options_Status.Show()
		
		lbl_Options_Name.SetText(TDriver.GetDriverById(gMyDriverId).name)
		If Not gDemo
			lbl_Options_Status.SetText(GetLocaleText("Registered"))
			btn_Options_Reg.Hide()
		Else
			lbl_Options_Status.SetText(GetLocaleText("Not Registered"))
			btn_Options_Reg.Show()
		EndIf
	Else
		AppLog "Hide Reg Details"
		lbl_Options_LReg.Hide()
		lbl_Options_LName.Hide()
		lbl_Options_LStatus.Hide()
		lbl_Options_Name.Hide()
		lbl_Options_Status.Hide()
		btn_Options_Reg.Hide()
	EndIf
	AppLog "PanelSetupComplete"
End Function

Function LoadOptions()
	If gQuickRace
		AppLog "LoadOptions"
		Local ini:TStream=ReadFile(gSaveloc+"Settings/Options.ini")
		
		' Create new ini if one doesn't exist
		If Not ini Then SaveOptions(); Return
			
		OpLaps = ReadLine(ini).ToInt()
		OpView = ReadLine(ini).ToInt()
		OpVolumeFX = ReadLine(ini).ToFloat()
		OpVolumeMusic = ReadLine(ini).ToFloat()
		OpDifficulty = ReadLine(ini).ToInt()
		
		OpRadio = ReadLine(ini).ToInt()
		OpMap = ReadLine(ini).ToInt()
		OpSpeedo = ReadLine(ini).ToInt()
		
		OpFuel = ReadLine(ini).ToInt()
		OpDamage = ReadLine(ini).ToInt()
		OpTyres = ReadLine(ini).ToInt()
		OpKers = ReadLine(ini).ToInt()
		
		OpControls[0] = ReadLine(ini).ToInt()
		OpControls[1] = ReadLine(ini).ToInt()
		OpControls[2] = ReadLine(ini).ToInt()
		OpControls[3] = ReadLine(ini).ToInt()
		OpControls[4] = ReadLine(ini).ToInt()
		OpControls[5] = ReadLine(ini).ToInt()
		OpControls[6] = ReadLine(ini).ToInt()
		
		CloseStream ini
	Else	
		AppLog "LoadOptionsDB"
		OpLaps = GetDatabaseInt("laps", "options", 1) 
		OpView = GetDatabaseInt("view", "options", 1)
		OpRadio = GetDatabaseInt("radio", "options", 1)
		OpMap = GetDatabaseInt("map", "options", 1)
		OpFuel = GetDatabaseInt("fuel", "options", 1)
		OpDamage = GetDatabaseInt("damage", "options", 1)
		OpTyres = GetDatabaseInt("tyres", "options", 1)
		OpVolumeFX = GetDatabaseFloat("volfx", "options", 1)
		OpVolumeMusic = GetDatabaseFloat("volmusic", "options", 1)
		OpDifficulty = GetDatabaseInt("difficulty", "options", 1)
		OpSpeedo = GetDatabaseInt("speedo", "options", 1)
		OpKers = GetDatabaseInt("kers", "options", 1)
		
		OpControls[0] = GetDatabaseInt("keyleft", "options", 1)
		OpControls[1] = GetDatabaseInt("keyright", "options", 1)
		OpControls[2] = GetDatabaseInt("keyup", "options", 1)
		OpControls[3] = GetDatabaseInt("keydown", "options", 1)
		OpControls[4] = GetDatabaseInt("keypause", "options", 1)
		OpControls[5] = GetDatabaseInt("keyinfo", "options", 1)
		OpControls[6] = GetDatabaseInt("keykers", "options", 1)
	EndIf
	
	' Reset to keyboard if joypad missing
	If gJoyCount = 0
		For Local c:Int = 0 To 6
			If OpControls[c] < 0
				OpControls = [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN, KEY_ESCAPE, KEY_SPACE, KEY_LSHIFT]
				Exit
			End If
		Next
	EndIf
	
	' Update Channels
	chn_FX.SetVolume(OpVolumeFX)
End Function

Function SaveOptions()
	If gQuickRace
		AppLog "SaveOptions"
		Local ini:TStream=WriteFile(gSaveloc+"Settings/Options.ini")
		If Not ini Then AppLog "Could not open options file"
		
		WriteLine(ini, OpLaps)
		WriteLine(ini, OpView)
		WriteLine(ini, OpVolumeFX)
		WriteLine(ini, OpVolumeMusic)
		WriteLine(ini, OpDifficulty)
		
		WriteLine(ini, OpRadio)
		WriteLine(ini, OpMap)
		WriteLine(ini, OpSpeedo)
		
		WriteLine(ini, OpFuel)
		WriteLine(ini, OpDamage)
		WriteLine(ini, OpTyres)
		WriteLine(ini, OpKers)
		
		WriteLine(ini, OpControls[0])
		WriteLine(ini, OpControls[1])
		WriteLine(ini, OpControls[2])
		WriteLine(ini, OpControls[3])
		WriteLine(ini, OpControls[4])
		WriteLine(ini, OpControls[5])
		WriteLine(ini, OpControls[6])
		
		CloseFile ini
	Else
		AppLog "SaveOptionsDB"
		UpdateDatabaseInt("options", "laps", OpLaps, 1)
		UpdateDatabaseInt("options", "view", OpView, 1)
		UpdateDatabaseFloat("options", "volfx", OpVolumeFX, 1)
		UpdateDatabaseFloat("options", "volmusic", OpVolumeMusic, 1)
		UpdateDatabaseInt("options", "difficulty", OpDifficulty, 1)
		
		UpdateDatabaseInt("options", "radio", OpRadio, 1)
		UpdateDatabaseInt("options", "map", OpMap, 1)
		UpdateDatabaseFloat("options", "fuel", OpFuel, 1)
		UpdateDatabaseFloat("options", "damage", OpDamage, 1)
		UpdateDatabaseInt("options", "tyres", OpTyres, 1)
		UpdateDatabaseInt("options", "speedo", OpSpeedo, 1)
		UpdateDatabaseInt("options", "kers", OpKers, 1)
		
		UpdateDatabaseInt("options", "keyleft", OpControls[0], 1)
		UpdateDatabaseInt("options", "keyright", OpControls[1], 1)
		UpdateDatabaseInt("options", "keyup", OpControls[2], 1)
		UpdateDatabaseInt("options", "keydown", OpControls[3], 1)
		UpdateDatabaseInt("options", "keypause", OpControls[4], 1)
		UpdateDatabaseInt("options", "keyinfo", OpControls[5], 1)
		UpdateDatabaseInt("options", "keykers", OpControls[6], 1)
	EndIf
End Function

Function GetStringView:String()
	Select OpView
	Case 1	Return GetLocaleText("Very Low")
	Case 2	Return GetLocaleText("Low")
	Case 3	Return GetLocaleText("Medium")
	Case 4	Return GetLocaleText("High")
	Case 5	Return GetLocaleText("Very High")
	End Select
	
	Return String(OpView)
End Function

Function GetButtonLabel:String(j:Int)
	If OpControls[j] < -99
		If OpControls[j] = -100 Then Return GetLocaleText("tla_JoyAxis")+" X"
		If OpControls[j] = -101 Then Return GetLocaleText("tla_JoyAxis")+" X"
		If OpControls[j] = -102 Then Return GetLocaleText("tla_JoyAxis")+" Y"
		If OpControls[j] = -103 Then Return GetLocaleText("tla_JoyAxis")+" Y"
		
		If OpControls[j] = -104 Then Return GetLocaleText("tla_JoyAxis")+" Z"
		If OpControls[j] = -105 Then Return GetLocaleText("tla_JoyAxis")+" Z"
		
		If OpControls[j] = -106 Then Return GetLocaleText("tla_JoyAxis")+" R"
		If OpControls[j] = -107 Then Return GetLocaleText("tla_JoyAxis")+" R"
		If OpControls[j] = -108 Then Return GetLocaleText("tla_JoyAxis")+" U"
		If OpControls[j] = -109 Then Return GetLocaleText("tla_JoyAxis")+" U"
		
		If OpControls[j] = -110 Then Return GetLocaleText("tla_JoyHat")+" "+GetLocaleText("Up")
		If OpControls[j] = -111 Then Return GetLocaleText("tla_JoyHat")+" "+GetLocaleText("Right")
		If OpControls[j] = -112 Then Return GetLocaleText("tla_JoyHat")+" "+GetLocaleText("Down")
		If OpControls[j] = -113 Then Return GetLocaleText("tla_JoyHat")+" "+GetLocaleText("Left")
	ElseIf OpControls[j] < 0
		Return GetLocaleText("tla_JoyButton")+" "+String(-OpControls[j])
	Else
		Return keystring[OpControls[j]]
	EndIf
End Function

Function ButtonDown:Int(c:Int)
	If OpControls[c] < -99
		If OpControls[c] = -100 And JoyX() < -0.4 Then Return True
		If OpControls[c] = -101 And JoyX() > 0.4 Then Return True	
		If OpControls[c] = -102 And JoyY() < -0.4 Then Return True
		If OpControls[c] = -103 And JoyY() > 0.4 Then Return True	
		
		If JoyZ() > -1.1
			If OpControls[c] = -104 And JoyZ() < -0.4 Then Return True
			If OpControls[c] = -105 And JoyZ() > 0.4 Then Return True
		EndIf
		
	ElseIf OpControls[c] < 0
		If JoyDown((-OpControls[c])-1) Then Return True
	Else
		If KeyDown(OpControls[c]) Then Return True
	End If
	
	Return False
End Function

Function ButtonHit:Int(c:Int)	
	If OpControls[c] < 0
		Local b:Int = (-OpControls[c])-1
		ValidateMinMax(b, 0, 15)
		If JoyHit(b) Then Return True
	Else
		If KeyHit(OpControls[c]) Then Return True
	End If
	
	Return False
End Function

Function GetNewControl:Int()
	MyFlushJoy()
	gJoyCount = JoyCount()
	
	Local key:Int = -1
	Local joy:Int = -1
	
	Repeat
		For Local k:Int = 0 To 255
			If KeyDown(k) Then Return k
		Next
		
		If gJoyCount
			For Local j:Int = 0 To 31
				If JoyDown(j) Then Return -(j+1)
			Next
			
			If JoyX() < -0.4 Then Return -100
			If JoyX() > 0.4 Then Return -101
			If JoyY() < -0.4 Then Return -102
			If JoyY() > 0.4 Then Return -103
			
			If JoyZ() > -1.1
				If JoyZ() < -0.4 Then Return -104
				If JoyZ() > 0.4 Then Return -105
			EndIf
			
		'	If JoyR() < -0.4 Then Return -106
		'	If JoyR() > 0.4 Then Return -107
		'	If JoyU() < -0.4 Then Return -108
		'	If JoyU() > 0.4 Then Return -109
			
		'	If JoyHat() > -1.0
		'		If JoyHat() >= 0.0 Then Return -110
		'		If JoyHat() >= 0.125 And JoyHat() <= 0.375 Then Return -111
		'		If JoyHat() >= 0.5 Then Return -112
		'		If JoyHat() >= 0.625 And JoyHat() <= 0.875 Then Return -113
		'	EndIf
		EndIf
	Until key > -1 Or joy > -1
End Function

Function OptionsCancel()
	btn_Header_Quit.Show()
	btn_Header_Options.Show()
	prg_Title.Show()
	LoadOptions()
	
	fry_SetScreen(options_prevscreen)
	
End Function

Function OptionsProceed()
	Global welcomedone:Int = False
	
	SaveOptions()
	
	' Set up hosting if online
	If options_prevscreen = "screen_online" 
		TOnline.Host()
	EndIf
	
	fry_SetScreen(options_prevscreen)
	
	If Not welcomedone And options_prevscreen = "screen_home" And gYear = 1 And gDay = 1 And gWeek = 1
		DoMessage("CMESSAGE_WELCOME")
		welcomedone = True
	EndIf
	
	btn_Header_Quit.Show()
	btn_Header_Options.Show()
	prg_Title.Show()
End Function

Function MyFlushJoy(incmouse:Int = True)
	If gJoyCount		
		For Local b:Int = 0 To 15
			JoyHit(b)
		Next
		
		FlushJoy()
	EndIf
	
	FlushKeys()
	If incmouse Then FlushMouse()	' Sometimes you don't want to flush mouse (fixes slider bar issue)
End Function

' ----------------------------------
' Relations
' ----------------------------------
Const CRELATION_BOSS:Int = 1, CRELATION_PITCREW:Int = 2, CRELATION_FANS:Int = 3, CRELATION_FRIENDS:Int = 4
	
Global pan_Relationships:fry_TPanel = fry_TPanel(fry_GetGadget("pan_relationships"))

Global btn_Relations_PitCrewCasino:fry_TButton = fry_CreateImageButton("btn_Relations_PitCrewCasino", gAppLoc+"Skin/Graphics/Buttons/CasinoSmall.png", pan_Relationships.gW-26, 102, 16, 16, pan_Relationships)
Global btn_Relations_FriendsCasino:fry_TButton = fry_CreateImageButton("btn_Relations_FriendsCasino", gAppLoc+"Skin/Graphics/Buttons/CasinoSmall.png", pan_Relationships.gW-26, 212, 16, 16, pan_Relationships)

Global can_Relations_Boss:fry_TCanvas = fry_CreateCanvas("can_Relations_Boss", 20, 45, 50, 50, pan_Relationships)
can_Relations_Boss.SetBackground(0)
can_Relations_Boss.SetDraw(DrawRelationsBoss)

Global can_Relations_PitCrew:fry_TCanvas = fry_CreateCanvas("can_Relations_PitCrew", 20, 100, 50, 50, pan_Relationships)
can_Relations_PitCrew.SetBackground(0)
can_Relations_PitCrew.SetDraw(DrawRelationsPitCrew)

Global can_Relations_Fans:fry_TCanvas = fry_CreateCanvas("can_Relations_Fans", 20, 155, 50, 50, pan_Relationships)
can_Relations_Fans.SetBackground(0)
can_Relations_Fans.SetDraw(DrawRelationsFans)

Global can_Relations_Friends:fry_TCanvas = fry_CreateCanvas("can_Relations_Friends", 20, 210, 50, 50, pan_Relationships)
can_Relations_Friends.SetBackground(0)
can_Relations_Friends.SetDraw(DrawRelationsFriends)

Global can_Relations_BossStars:fry_TCanvas = fry_CreateCanvas("can_Relations_BossStars", 85, 67, 280, 26, pan_Relationships)
can_Relations_BossStars.SetBackground(0)
can_Relations_BossStars.SetDraw(DrawRelationsBossStars)

Global can_Relations_PitCrewStars:fry_TCanvas = fry_CreateCanvas("can_Relations_PitCrewStars", 85, 122, 280, 26, pan_Relationships)
can_Relations_PitCrewStars.SetBackground(0)
can_Relations_PitCrewStars.SetDraw(DrawRelationsPitCrewStars)

Global can_Relations_FansStars:fry_TCanvas = fry_CreateCanvas("can_Relations_FansStars", 85, 177, 280, 26, pan_Relationships)
can_Relations_FansStars.SetBackground(0)
can_Relations_FansStars.SetDraw(DrawRelationsFansStars)

Global can_Relations_FriendsStars:fry_TCanvas = fry_CreateCanvas("can_Relations_FriendsStars", 85, 232, 280, 26, pan_Relationships)
can_Relations_FriendsStars.SetBackground(0)
can_Relations_FriendsStars.SetDraw(DrawRelationsFriendsStars)

Function UpdateRelationship(rel:Int, amt:Float, save:Int = True)
	Local txt:String
	
	Select rel
	Case CRELATION_BOSS			
		txt = GetLocaleText("Boss")
		gRelBoss:+amt
		ValidateMinMax(gRelBoss, 0, 100)
	Case CRELATION_PITCREW		
		txt = GetLocaleText("Pit Crew")
		gRelPitCrew:+amt
		ValidateMinMax(gRelPitCrew, 0, 100)
	Case CRELATION_FANS			
		txt = GetLocaleText("Fans")
		gRelFans:+amt
		ValidateMinMax(gRelFans, 0, 100)
	Case CRELATION_FRIENDS		
		txt = GetLocaleText("Friends")
		gRelFriends:+amt
		ValidateMinMax(gRelFriends, 0, 100)
	End Select
	
	If amt > 0 Then TScreenMessage.Create(0,0,txt,imgSmiley_1,2000,2)
	If amt = 0 Then TScreenMessage.Create(0,0,txt,imgSmiley_2,2000,2)
	If amt < 0 Then TScreenMessage.Create(0,0,txt,imgSmiley_3,2000,2)
	
	If save Then SaveGame()
End Function
	
Function SaveGame()
	'db.Query(day INTEGER, week INTEGER, year INTEGER, cash INTEGER, prizemoney INTEGER, gamblingmoney INTEGER, sponsormoney INTEGER, relboss INTEGER, relpitcrew INTEGER, relfans INTEGER, relfriends INTEGER, license Text, licensekey Text)")
	
	Local qlist:TList = CreateList()
	qlist.AddLast("UPDATE gamedata SET day = "+gDay+" WHERE id = 1")
	qlist.AddLast("UPDATE gamedata SET week = "+gWeek+" WHERE id = 1")
	qlist.AddLast("UPDATE gamedata SET year = "+gYear+" WHERE id = 1")
	
	qlist.AddLast("UPDATE gamedata SET relboss = "+gRelBoss+" WHERE id = 1")
	qlist.AddLast("UPDATE gamedata SET relpitcrew = "+gRelPitCrew+" WHERE id = 1")
	qlist.AddLast("UPDATE gamedata SET relfans = "+gRelFans+" WHERE id = 1")
	qlist.AddLast("UPDATE gamedata SET relfriends = "+gRelFriends+" WHERE id = 1")
	
	db.Query("BEGIN;")
	For Local q:String = EachIn qlist
		db.Query(q)
	Next
	db.Query("COMMIT;")
	
End Function

' ----------------------------------
' News
' ----------------------------------
Global pan_News:fry_TPanel = fry_TPanel(fry_GetGadget("pan_news"))
Global lbl_News_Headline:fry_TLabel = fry_TLabel(fry_GetGadget("pan_news/lbl_headline"))
Global tbl_News_Results:fry_TTable = fry_TTable(fry_GetGadget("pan_news/tbl_results"))

Global pan_News_Nav:fry_TPanel = fry_TPanel(fry_GetGadget("pan_news_nav"))
Global btn_News_Proceed:fry_TButton = fry_CreateImageButton("btn_NewsProceed", gAppLoc+"Skin/Graphics/Buttons/Play.png", pan_News_Nav.gW-74, 9, 64, 32, pan_News_Nav)

Function SetUpScreen_News(drivername:String, trackname:String, pos:Int)
	AppLog "SetUpScreen_News"
	fry_SetScreen("screen_news")
	
	pan_News.SetAlpha(0)
	lbl_News_Headline.SetTextColour(255,255,255)
	
	Local txt:String = GetLocaleText("CMESSAGE_HEADLINE_RACEWINNER_"+Rand(10))
	txt = txt.Replace("$item1", drivername)
	txt = txt.Replace("$item2", trackname)
	
	lbl_News_Headline.SetText(txt)
	
	TTeam.UpdateStatOrderAll()	
	Local t:TTeam = TTeam.GetTeamByDriverId(gMyDriverId)
						
	' Impress boss
	If pos = 1 
		UpdateRelationship(CRELATION_BOSS, 10)
		UpdateRelationship(CRELATION_FANS, 10)
	ElseIf pos = 20
		UpdateRelationship(CRELATION_BOSS, -10)
		UpdateRelationship(CRELATION_FANS, -20)
	ElseIf pos <= t.statorder+1
		UpdateRelationship(CRELATION_BOSS, 5)
		UpdateRelationship(CRELATION_FANS, 5)
	ElseIf pos < t.statorder*2
		UpdateRelationship(CRELATION_BOSS, 0)
		UpdateRelationship(CRELATION_FANS, 0)
	Else
		UpdateRelationship(CRELATION_BOSS, -5)
		UpdateRelationship(CRELATION_FANS, -10)
	End If
	
	Local amt:Int = 0
	
	Select pos
	Case 1	amt = 10000
	Case 2	amt = 9000
	Case 3	amt = 8000
	Case 4	amt = 7000
	Case 5	amt = 6000
	Case 6	amt = 5000
	Case 7	amt = 4000
	Case 8	amt = 3000
	Case 9	amt = 2000
	Default	amt = 1000
	End Select
	
	If t.driver1 = gMyDriverId Then amt:*2
	
	If TDriver.GetDriverById(gMyDriverId).lastracetime = 0 Then amt = 0
	
	UpdateCash(amt)
	Local prizemoney:Int = GetDatabaseInt("prizemoney", "gamedata", 1)
	prizemoney:+amt
	UpdateDatabaseInt("gamedata", "prizemoney", prizemoney, 1)					
End Function

Function EndChampionship()
	AppLog "SetUpScreen_News_Championship"
	fry_SetScreen("screen_news")
	
	pan_News.SetAlpha(0)
	lbl_News_Headline.SetTextColour(255,255,255)
	tbl_News_Results.ClearItems()
	
	TDriver.SelectAll()
	TDriver.sortby = CSORT_SEASONPOINTS
	TDriver.list.Sort()
	
	Local mypos:Int
	Local champion:TDriver
	Local sel:Int = 1
	Local pos:Int = 1
	
	For Local drv:TDriver = EachIn TDriver.list
		If pos = 1 Then champion = drv
		
		Local nat:String = GetDatabaseString("name", "nation", drv.nationality)
		Local team:TTeam = TTeam.GetTeamByDriverId(drv.id)
		
		If team And team.id > 0 
			tbl_News_Results.AddItem([String(pos), drv.name, team.name, String(drv.seasonpts)])
			If drv.id = gMyDriverId Then sel = pos-1; mypos = pos
			pos:+1
		EndIf
	Next
	
	tbl_News_Results.SelectItem(sel)
	tbl_News_Results.ShowItem(sel)
	
	
	Local txt:String = GetLocaleText("CMESSAGE_CHAMPIONSHIP")
	txt = txt.Replace("$item1", champion.name)
	
	champion.championships:+1
	champion.UpdateDb()
	
	Local constructor:TTeam = TTeam.GetTeamByDriverId(champion.id)
	constructor.championships:+1
	constructor.UpdateDb()
	
	TTeam.SelectAll()
	TTeam.sortby = CSORT_SEASONPOINTS
	TTeam.list.Sort()
	
	For Local t:TTeam = EachIn TTeam.list
		txt = txt.Replace("$item2", t.name)
		Exit
	Next
	
	lbl_News_Headline.SetText(txt)
	lbl_News_Headline.SetFont("Large")
						
	' Impress fans
	Select mypos
	Case 1	UpdateRelationship(CRELATION_FANS, 50); TScreenMessage.Create(0,0,GetLocaleText("Congratulations!"),imgSmiley_1,5000,2)
	Case 2	UpdateRelationship(CRELATION_FANS, 30)
	Case 3	UpdateRelationship(CRELATION_FANS, 25)
	Case 4	UpdateRelationship(CRELATION_FANS, 20)
	Case 5	UpdateRelationship(CRELATION_FANS, 15)
	Case 6	UpdateRelationship(CRELATION_FANS, 10)
	Case 7	UpdateRelationship(CRELATION_FANS, 5)
	Case 8	UpdateRelationship(CRELATION_FANS, 0)
	Case 9	UpdateRelationship(CRELATION_FANS, 0)
	Case 10	UpdateRelationship(CRELATION_FANS, 0)
	Case 11	UpdateRelationship(CRELATION_FANS, 0)
	Case 12	UpdateRelationship(CRELATION_FANS, -5)
	Case 13	UpdateRelationship(CRELATION_FANS, -10)
	Case 14	UpdateRelationship(CRELATION_FANS, -15)
	Case 15	UpdateRelationship(CRELATION_FANS, -20)
	Case 16	UpdateRelationship(CRELATION_FANS, -25)
	Case 17	UpdateRelationship(CRELATION_FANS, -30)
	Case 18	UpdateRelationship(CRELATION_FANS, -35)
	Case 19	UpdateRelationship(CRELATION_FANS, -40)
	Default	UpdateRelationship(CRELATION_FANS, -45)
	End Select
		
	
	Local amt:Int = 0
	
	Select mypos
	Case 1	amt = 1000000
	Case 2	amt = 500000
	Case 3	amt = 250000
	Case 4	amt = 100000
	Case 5	amt = 50000
	Case 6	amt = 40000
	Case 7	amt = 30000
	Case 8	amt = 20000
	Case 9	amt = 10000
	Case 10	amt = 9000
	Case 11	amt = 8000
	Case 12	amt = 7000
	Case 13	amt = 6000
	Case 14	amt = 5000
	Case 15	amt = 4000
	Case 16	amt = 3000
	Case 17	amt = 2000
	Default	amt = 1000
	End Select
	
	UpdateCash(amt)
	Local prizemoney:Int = GetDatabaseInt("prizemoney", "gamedata", 1)
	prizemoney:+amt
	UpdateDatabaseInt("gamedata", "prizemoney", prizemoney, 1)
	
	If mypos = 1
		DoMessage("CMESSAGE_CHAMPIONSHIPWINNINGS1",,TCurrency.GetString(OpCurrency,amt))
	Else
		DoMessage("CMESSAGE_CHAMPIONSHIPWINNINGS2",,TCurrency.GetString(OpCurrency,amt))
	End If
	
	' Update driver skills
	For Local drv:TDriver = EachIn TDriver.list
		drv.skill:+Rnd(-1.0, 1.0)
		ValidateMinMaxFloat(drv.skill, 1.0, 10.0)
	Next
End Function

Function EndCareer()
	AppLog "SetUpScreen_News_EndCareer"
	fry_SetScreen("screen_news")
	
	pan_News.SetAlpha(0)
	lbl_News_Headline.SetTextColour(255,255,255)
	tbl_News_Results.ClearItems()
	
	TDriver.SelectAll()
	TDriver.sortby = CSORT_CAREERPOINTS
	TDriver.list.Sort()
	
	
	Local me:TDriver
	Local sel:Int = 1
	Local pos:Int = 1
	
	For Local drv:TDriver = EachIn TDriver.list		
		Local nat:String = GetDatabaseString("name", "nation", drv.nationality)
		Local team:TTeam = TTeam.GetTeamByDriverId(drv.id)
		
		If team And team.id > 0 
			tbl_News_Results.AddItem([String(pos), drv.name, nat, String(drv.careerpts)])
			If drv.id = gMyDriverId Then sel = pos-1; me = drv
			pos:+1
		EndIf
	Next
	
	tbl_News_Results.SelectItem(sel)
	tbl_News_Results.ShowItem(sel)
	
	
	'$item1 is retiring from racing after 10 seasons in GP. During his career he achieved $championships, $wins, $poles and $podiums amassing a total of $points!
	Local txt:String = GetLocaleText("CMESSAGE_RETIREMENT")
	txt = txt.Replace("$item1", me.name)
	txt = txt.Replace("$numseasons", gNoofSeasons)
	txt = txt.Replace("$championships", me.championships)
	txt = txt.Replace("$wins", me.careerwins)
	txt = txt.Replace("$poles", me.careerpoles)
	txt = txt.Replace("$podiums", me.careerpodiums)
	txt = txt.Replace("$points", me.careerpts)
	
	lbl_News_Headline.SetText(txt)
	lbl_News_Headline.SetFont("Medium")
						
	TScreenMessage.Create(0,0,GetLocaleText("Congratulations on a wonderful career!"),imgSmiley_1,5000,2)
End Function


' ----------------------------------
' New Contract
' ----------------------------------
Global pan_NewContract:fry_TPanel = fry_TPanel(fry_GetGadget("pan_newcontract"))
Global lbl_NewContract:fry_TLabel = fry_TLabel(fry_GetGadget("pan_newcontract/lbl_contract"))
Global cmb_NewContract_Team:fry_TComboBox = fry_TComboBox(fry_GetGadget("pan_newcontract/cmb_team"))
Global btn_NewContract_Accept:fry_TButton = fry_TButton(fry_GetGadget("pan_newcontract/btn_accept"))

Global can_NewContract_TeamImg:fry_TCanvas = fry_CreateCanvas("can_NewContract_TeamImg", 20, 150, 160, 80, pan_newcontract)
can_NewContract_TeamImg.SetBackground(1)
can_NewContract_TeamImg.SetColour(128,128,128)
can_NewContract_TeamImg.SetDraw(DrawNewPlayerTeamImg)

Global can_NewContract_TeamRating1:fry_TCanvas = fry_CreateCanvas("can_NewContract_TeamRating1", 280, 160, 80, 16, pan_newcontract)
can_NewContract_TeamRating1.SetBackground(0)
can_NewContract_TeamRating1.SetDraw(DrawNewPlayerTeamRating1)

Global can_NewContract_TeamRating2:fry_TCanvas = fry_CreateCanvas("can_NewContract_TeamRating2", 280, 180, 100, 16, pan_newcontract)
can_NewContract_TeamRating2.SetBackground(0)
can_NewContract_TeamRating2.SetDraw(DrawNewPlayerTeamRating2)

Global can_NewContract_TeamRating3:fry_TCanvas = fry_CreateCanvas("can_NewContract_TeamRating3", 280, 200, 120, 16, pan_newcontract)
can_NewContract_TeamRating3.SetBackground(0)
can_NewContract_TeamRating3.SetDraw(DrawNewPlayerTeamRating3)

Global contractofferids:TList = CreateList()

Function SetUpScreen_NewContract()
	fry_SetScreen("screen_newcontract")
	prg_Title.Hide()
	btn_Header_Options.Hide()
	btn_Header_Quit.Hide()
	
	' Update cars
	SetUpNewTeamStats()
	
	Local str:String = GetLocaleText("CMESSAGE_NEWCONTRACT")
	str = str.Replace("$season", gYear-1)
	lbl_NewContract.SetText(str)
	
	' Teams
	contractofferids.Clear()
	cmb_NewContract_Team.ClearItems();	While fry_PollEvent() Wend
	
	' Get my position in the championship
	TDriver.SelectAll()
	TDriver.sortby = CSORT_SEASONPOINTS
	TDriver.list.Sort()
	
	Local mypos:Int = 1
	For Local drv:TDriver = EachIn TDriver.list
		If drv.id = gMyDriverId Then Exit
		mypos:+1
	Next
	
	' Sort teams by season result
	TTeam.SelectAll()
	TTeam.sortby = CSORT_SEASONPOINTS
	TTeam.list.Sort()
	
	Local myteam:Int = TTeam.GetTeamByDriverId(gMyDriverId).id
	Local teampos:Int = 1
	
	For Local team:TTeam = EachIn TTeam.list
		If (teampos*2 >= mypos And (Rand(3) <> 1 Or team.id = myteam)) Or teampos = 10
			contractofferids.AddLast(String(team.id))
			cmb_NewContract_Team.AddItem(team.name)
		EndIf
			
		teampos:+1
	Next
	cmb_NewContract_Team.SelectItem(0)
	
	Combo_NewContractTeam()
End Function

Function Combo_NewContractTeam()
	Local team:TTeam = TTeam.GetByName(cmb_NewContract_Team.SelectedText())
	
	imgTeamProfile = team.img
	
	' Load stats
	NewPlayerTeamRating1 = team.handling
	NewPlayerTeamRating2 = team.acceleration
	NewPlayerTeamRating3 = team.topspeed
	
	ValidateMinMaxFloat(NewPlayerTeamRating1, -10, 5)
	ValidateMinMaxFloat(NewPlayerTeamRating2, -10, 5)
	ValidateMinMaxFloat(NewPlayerTeamRating3, -10, 5)
	
	AppLog NewPlayerTeamRating1
	AppLog NewPlayerTeamRating2
	AppLog NewPlayerTeamRating3
End Function

Function Button_NewContractAccept()
	Local oldteam:TTeam = TTeam.GetTeamByDriverId(gMyDriverId)
	Local newteam:TTeam = TTeam.GetByName(cmb_NewContract_Team.SelectedText())
	
	If oldteam.id <> newteam.id
		Select OpDifficulty
		Case 1	
			gRelBoss = 75
			gRelPitCrew = 75
		Case 2	
			gRelBoss = 50
			gRelPitCrew = 50
		Case 3
			gRelBoss = 25
			gRelPitCrew = 25
		Case 4
			gRelBoss = 20
			gRelPitCrew = 20
		End Select
		
		' Find weakest driver of the new team
		Local me:TDriver = TDriver.GetDriverById(gMyDriverId)
		Local drv:TDriver		' Which driver to swap		
		Local d1:TDriver = TDriver.GetDriverById(newteam.driver1)
		Local d2:TDriver = TDriver.GetDriverById(newteam.driver2)
		
		If d1.seasonpts < d2.seasonpts
			drv = d1
		Else
			drv = d2
		EndIf
		
		' Put weak driver into your old team spot
		Select me.drivernumber
		Case 1	UpdateDatabaseInt("team", "driver1", drv.id, oldteam.id)
		Case 2	UpdateDatabaseInt("team", "driver2", drv.id, oldteam.id)
		End Select
		
		' Put you into weak driver's team spot
		Select drv.drivernumber
		Case 1	UpdateDatabaseInt("team", "driver1", gMyDriverId, newteam.id)
		Case 2	UpdateDatabaseInt("team", "driver2", gMyDriverId, newteam.id)
		End Select
	EndIf
	
	' Refresh driver details
	TDriver.SelectAll()
	
	SaveGame()
	
	' Shuffle drivers
	SetUpNewTeams()
	
	' Bring back orphan driver
	PromoteOrphanDriver()
	
	' Make sure you exist in a team
	CheckNewTeam(newteam.id)
	
	' Reset season points
	TDriver.ResetSeasonPointsAll()
	TTeam.ResetSeasonPointsAll()
	
	SetUpScreen_Home()
End Function

Function SetUpNewTeamStats()
	' Vary stats slightly for new season
	For Local t:TTeam = EachIn TTeam.list
		t.handling:+Rand(-1.0,1.0)
		t.acceleration:+Rand(-1.0,1.0)
		t.topspeed:+Rand(-1.0,1.0)
		
		ValidateMinMaxFloat(t.handling,2.5,5.0)
		ValidateMinMaxFloat(t.acceleration,2.5,5.0)
		ValidateMinMaxFloat(t.topspeed,2.5,5.0)
		
		If t.handling+t.acceleration+t.topspeed > 14
			Select Rand(3)
			Case 1	t.handling = 4.0
			Case 2	t.acceleration = 4.0
			Case 3	t.topspeed = 4.0
			End Select
		EndIf
		
		UpdateDatabaseFloat("team", "handling", t.handling, t.id)
		UpdateDatabaseFloat("team", "acceleration", t.acceleration, t.id)
		UpdateDatabaseFloat("team", "topspeed", t.topspeed, t.id)
	Next
	
	' Reset KERS
	For Local drv:TDriver = EachIn TDriver.list
		If drv.id <> gMyDriverId Then UpdateDatabaseInt("driver", "kers", Rand(0,1), drv.id)
	Next
	
	TTeam.SelectAll()
End Function

Function SetUpNewTeams()		
	'Swap all Driver 2s around based on season points and team season points
	
	TTeam.SelectAll()
	TTeam.sortby = CSORT_SEASONPOINTS
	TTeam.list.Sort()
	
	Local count:Int = 0
	
	' Loop through all teams in order of last seasons performance (best first)
	For Local t1:TTeam = EachIn TTeam.list
		count:+1
		AppLog "Count:"+count
		
		' Reload drivers so that their team ids and driver numbers are up to date
		TDriver.SelectAll()
		
		' Find weakest driver of the two
		Local drv1:TDriver		' Which driver to swap		
		Local d1:TDriver = TDriver.GetDriverById(t1.driver1)
		Local d2:TDriver = TDriver.GetDriverById(t1.driver2)
		
		If d1.seasonpts < d2.seasonpts
			drv1 = d1
		Else
			drv1 = d2
		EndIf
		
		' Don't swap human player
		If drv1.id = gMyDriverId Or Rand(2) = 1 Then Continue
		
		AppLog "Offloading "+drv1.name+" from "+t1.name
		
		' Sort drivers in order of season performance (best first)
		TDriver.sortby = CSORT_SEASONPOINTS
		TDriver.list.Sort()
		
		' Now loop through all the drivers
		For Local drv2:TDriver = EachIn TDriver.list
		
			' Get this driver's team
			Local t2:TTeam = TTeam.GetById(drv2.team)
			
			If Not t2 Then Continue
			
			' If this driver is better than the one being offloaded and he is at a lesser team then poach him
			If drv2.seasonpts > drv1.seasonpts And t2.seasonpts < t1.seasonpts
				' Don't swap human player
				If drv2.id = gMyDriverId Then Continue
			
				' Update the team 1 driver depending on whether we are swapping driver 1 or 2
				Select drv1.drivernumber
				Case 1	t1.driver1 = drv2.id
				Case 2	t1.driver2 = drv2.id 
				End Select
				
				' Update team 2 driver with the one being offloaded
				Select drv2.drivernumber
				Case 1	t2.driver1 = drv1.id
				Case 2	t2.driver2 = drv1.id
				End Select
				
				' Update drivers with new teams
				drv1.team = t2.id
				drv2.team = t1.id
				
				AppLog "Swapping him with "+drv2.name+" from "+t2.name
				Exit
			EndIf
		Next
	Next
	
	TTeam.UpdateDbAll()
	TDriver.SelectAll()	' Refresh
	
	For Local t:TTeam = EachIn TTeam.list
		AppLog "Team:"+t.name
		AppLog "Driver1:"+TDriver.GetDriverById(t.driver1).name
		AppLog "Driver2:"+TDriver.GetDriverById(t.driver2).name
	Next
	
	'Update drivers 1&2 based on season points
	SortDrivers1and2ByPerformance()
End Function

Function PromoteOrphanDriver()
	'Always bring Back dropped Driver For last place Driver?
	TDriver.sortby = CSORT_SEASONPOINTS
	TDriver.list.Sort(False)
	
	Local worst:TDriver
	Local orphan:TDriver
	
	For Local d:TDriver = EachIn TDriver.list
		' Find driver without team
		If orphan = Null And d.team = 0
			orphan = d
		ElseIf worst = Null	' Other lowest driver must be the worst
			worst = d
		EndIf
		
		If orphan And worst Then Exit
	Next
	
	If worst.id <> gMyDriverId And orphan.id <> gMyDriverId
		' Put orphan driver into worst driver spot
		Select worst.drivernumber
		Case 1	UpdateDatabaseInt("team", "driver1", orphan.id, worst.team)
		Case 2	UpdateDatabaseInt("team", "driver2", orphan.id, worst.team)
		End Select
		
		' Refresh driver details. This will reset worst drivers team and driver number fields
		TDriver.SelectAll()
	EndIf
		
End Function

Function SortDrivers1and2ByPerformance()
	TTeam.SelectAll()
	
	For Local t:TTeam = EachIn TTeam.list
		Local d1:TDriver = TDriver.GetDriverById(t.driver1)
		Local d2:TDriver = TDriver.GetDriverById(t.driver2)
		
		If d1.seasonpts < d2.seasonpts
			UpdateDatabaseInt("team", "driver1", d2.id, t.id)
			UpdateDatabaseInt("team", "driver2", d1.id, t.id)
		EndIf
	Next
	
	TTeam.SelectAll()
End Function

Function CheckNewTeam(newteamid:Int)
	' There seems to be a bug that sometime erases a driver 
	' This does a double check to make sure you exist in a team
	
	TTeam.SelectAll()
	Local team:TTeam = TTeam.GetById(newteamid)	
	
	If team.driver1 = 21 Or team.driver2 = 21 
		' Found you
	Else
		team.driver2 = 21
		team.UpdateDb()
	EndIf
	
	' Refresh drivers
	TDriver.SelectAll()
End Function
