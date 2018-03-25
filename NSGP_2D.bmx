t = MilliSecs()
TOnline.SetUpOnline()
 
Main()

If gDemo
	If DoMessage("CMESSAGE_PURCHASE", True)
		OpenWeb(gBuyURL)
	End If
EndIf

If TOnline.myhost
	TOnline.DisconnectPeersAll()
End If

End

Function Main()	
	Local quit:Int = False
	SetUpScreen_Start()
	
	Repeat
		chn_Music.SetVolume(OpVolumeMusic)
		
		DoDisplay()
		quit = CheckFryInput()
		TOnline.UpdateNetwork()
	Until quit Or AppTerminate()
End Function

Function DoDisplay()
	gMillisecs = MilliSecs()-gStartTime
	
	Cls
		
	' Draw Bg
	ResetDrawing()
	SetScale(1,1)
	
	Select fry_ScreenName()
	Case "screen_casino"
		DrawImageRect(imgBg_Casino, 0, 0, screenW, screenH)
		
	Case "screen_blackjack"
		DrawImageRect(imgBg_FeltBlue, 0, 0, screenW, screenH)
		gameBlackJack.Main()
		
	Case "screen_roulette"
		DrawImageRect(imgBg_Felt, 0, 0, screenW, screenH)
		gameRoulette.Main()
		
	Case "screen_slots"
		If gameSlotMachine.minislots = 0
			SetColor(130,130,255)
			DrawRect(0,0,screenW, screenH)
			ResetDrawing(255,255,255,1)
			DrawImageRect(imgBg_SlotMachine, 0+gOffSetX, 0+gOffSetY, 800, 600)
		Else
			DrawImageRect(gameSlotMachine.imgBG, 0, 0, screenW, screenH)
			DrawImageRect(imgBg_SlotMachineMini, 0+gOffSetX+225, 0+gOffSetY+168, 350, 260)
			SetViewport(2000,2000,1,1)
		EndIf
		gameSlotMachine.Main()
	
	Case "screen_home"
		DrawImageRect(img_Bg_Home, 0, 0, screenW, screenH)
			
	Case "screen_finances"
		DrawImageRect(img_Bg_Finances, 0, 0, screenW, screenH)
		
	Case "screen_leaderboards"
		DrawImageRect(img_Bg_Tracks, 0, 0, screenW, screenH)
		
	Case "screen_team"
		DrawImageRect(img_Bg_Teams, 0, 0, screenW, screenH)
		
	Case "screen_news"
		DrawImageRect(img_Bg, 0, 0, screenW, screenH)
		DrawImage(img_Bg_News, (screenW/2)-390, (screenH/2)-230)
		
	Default
		If fry_ScreenName() = "screen_start" Then DoCredits()
		DrawImageRect(img_Bg, 0, 0, screenW, screenH)
		
	EndSelect
	
	' Draw GUI
	fry_Refresh()
	
	' Count FPS
	If MilliSecs() > lastframetime + 1000
		lastframetime = MilliSecs()
		fps = framecount
		framecount = 0
	EndIf
	
	framecount:+1
	If gDebugMode 
		DrawText("FPS: " + fps, 10, 20-fntoffset_Medium)
		DrawText("Mem: " + GCMemAlloced(), 10, 40-fntoffset_Medium)
	EndIf 
	
	TScreenMessage.DrawAll()
	Flip 1
	PollSystem
	
	If KeyHit(KEY_PRINT) Or KeyHit(KEY_F8) Then PrintScreen()
End Function

Function RaceEngine()
	Applog "RaceEngine"
	Local quit:Int = False
	
	Repeat
		chn_Music.SetVolume(0)
		
		gMillisecs = MilliSecs()-gStartTime
		
		dt = MilliSecs() - t	' How long the last loop took to complete
		t = MilliSecs()
	
		execution_time:+ dt		' Add the time of the last loop to execution_time
		
		Local framestart:Int = gMillisecs
		
		' fixed interval update loop
		While execution_time >= update_time		' While execution time > 60 ups (16.6 millisecs)
			Select track.mode
			Case CTRACKMODE_EDIT
				track.Update()
				
			Case CTRACKMODE_EDITPAUSED
				track.Update()
				
			Case CTRACKMODE_DRIVE
				TCar.UpdateAll()
				TCar.UpdateReplayDataAll()
				TCar.GhostStep()
				TParticle.UpdateParticlesAll()
				track.Update()
				
				If TOnline.netstatus And KeyHit(KEY_F1) Then SaveReplayOnline()
				
			Case CTRACKMODE_PAUSED 
				If TOnline.netstatus
					TCar.UpdateAll()
					TParticle.UpdateParticlesAll()
				End If
				
				track.Update()
				
			Case CTRACKMODE_PITSTOP
				' If pitting then don't pause game
				If TOnline.netstatus and track.racestatus <> CRACESTATUS_GRID
					TCar.UpdateAll()
					TParticle.UpdateParticlesAll()
				ElseIf TOnline.netstatus = CNETWORK_RACESETUP
					' While paused on grid, make sure you can send receive packets
					TOnline.UpdateNetwork()
				End If
				
				track.Update()
				
			Case CTRACKMODE_REPLAYING
				TCar.UpdateInfoAlphaAll()
				
				If ButtonDown(MYKEY_LEFT)
					TCar.ReplayStepAll(-0.1)
				ElseIf ButtonDown(MYKEY_RIGHT)
					TCar.ReplayStepAll(0.1)
				ElseIf ButtonDown(MYKEY_KERS)
					TCar.ReplayStepAll(2)
				Else
					TCar.ReplayStepAll(1)
				End If
				
				If KeyDown(KEY_HOME) Then TCar.ReplayFirstFrameAll()
				If KeyDown(KEY_END) Then TCar.ReplayLastFrameAll()
				
				If ButtonHit(MYKEY_UP) Then TCar.ReplayCarAhead()
				If ButtonHit(MYKEY_DOWN) Then TCar.ReplayCarBehind()
				
				If KeyHit(KEY_PAGEUP) Then TCar.ReplayNextLapAll()
				If KeyHit(KEY_PAGEDOWN) Then TCar.ReplayPreviousLapAll()
				
				If track.racestatus = CRACESTATUS_RACE
					If KeyHit(KEY_F1) Then SaveReplay()
				EndIf
			End Select
			
			If TCar.ParadeLapComplete() Then track.Quit(); quit = True; Exit
			If CheckFryInput() Then quit = True; Exit
			If TOnline.netstatus = CNETWORK_LOBBY Then track.Quit(); quit = True; Exit
			track.CheckInput()
			UpdateOrigin()
			UpdateRadio()
					
			execution_time:-update_time	' Subtract update time (16.6) from execution time
			If track.mode = CTRACKMODE_REPLAYING Then execution_time = update_time-1
		Wend
	
		' calculate the remainder for motion interpolation
		Local et# = execution_time
		Local ut# = update_time
		Local tween# = et / ut
		
		If Not quit Then Render(tween)
		
		If KeyHit(KEY_PRINT) Or KeyHit(KEY_F8) Then PrintScreen()
	Until quit Or AppTerminate()
End Function

Function Render(tween:Float)
	If MilliSecs() > lastframetime + 1000
		lastframetime = MilliSecs()
		fps = framecount
		framecount = 0
	EndIf
	
	ResetDrawing()
	
	Select track.mode
	Case CTRACKMODE_EDIT
		track.Draw(tween)
		track.DrawMiniMap()
		
	Case CTRACKMODE_EDITPAUSED
		track.Draw(tween)
		SetScale(1,1)
		SetRotation(0)
		fry_Refresh()
		PollSystem
		
	Case CTRACKMODE_DRIVE
		track.Draw(tween)
		TParticle.DrawParticlesAll(tween)
		TCar.DrawAll(tween)
		track.DrawMiniMap()
		track.DrawInfo()
		
	Case CTRACKMODE_REPLAYING
		track.Draw(1)
		TCar.DrawAll(1)
		track.DrawReplayInfo()
		
	Case CTRACKMODE_PAUSED
		track.Draw(1)
		TCar.DrawAll(1)
		track.DrawMiniMap()
		track.DrawInfo()
		fry_Refresh()
		PollSystem
		
	Case CTRACKMODE_PITSTOP
		track.Draw(1)
		TCar.DrawAll(1)
		track.DrawMiniMap()
		track.DrawInfo()
		
	End Select
	
	TScreenMessage.DrawAll()
	
	' Do Info after scale
	If gDebugMode
		ResetDrawing()
		SetScale(1,1)
		fnt_Medium.Draw("Fps: "+fps, screenW/2-50, screenH-30-fntoffset_Medium)
		fnt_Medium.Draw("Mem: "+GCMemAlloced(), screenW/2-80, screenH-60-fntoffset_Medium)
	EndIf
	
	framecount:+1
	Flip 1
	
	
End Function

End

Function GetGameSpeed:Double()
	' time independent speed
	Return 1.6 'Double(cGameSpeed) / Double(UPS)
End Function

Function CheckFryInput:Int()
	Local quit:Int = False
	
	CheckFryButtonControls()
	CheckTextBoxModes()
	
	While fry_PollEvent()
		Select fry_EventID()
		Case fry_EVENT_GADGETOPEN
			If Not chn_FX.Playing() Then PlaySound(snd_Open, chn_FX)
		Case fry_EVENT_GADGETCLOSE
			If Not chn_FX.Playing() Then PlaySound(snd_Open, chn_FX)
		Case fry_EVENT_GADGETSELECT
			' Buttons and combos
			If Not chn_FX.Playing() Then PlaySound(snd_Click, chn_FX)

			Select fry_EventSource()
			' Start Screen
			Case btn_ExitGame				db.Close(); Return True
			Case btn_NewGame 				ButtonNewGame()
			Case btn_LoadGame				ButtonLoadGamePanel()
			Case btn_Options				SetUpScreen_Options()
			Case btn_QuickRace				ButtonQuickRacePanel()
			Case btn_QuickRace_Race			QuickRace()
			Case btn_Editor					TrackEditor()
			Case btn_Online					TScreenMessage.ClearAll(); TOnline.SetUpOnlineLobby1()
			Case btn_LoadReplay				ButtonLoadReplayPanel()
			
			Case btn_LoadGame_Load 			LoadGame(tbl_LoadGame.GetText(tbl_LoadGame.SelectedItem(),0))
			Case btn_LoadGame_Delete		ButtonDeleteGame()
			
			Case btn_LoadReplay_Load 		LoadReplay(tbl_LoadReplay.GetText(tbl_LoadReplay.SelectedItem(),0))
			Case btn_LoadReplay_Delete		ButtonDeleteReplay()
			
			
			' New Player
			Case cmb_NewPlayer_Team			UpdateReplaceDriver()
			Case btn_NewPlayer_Cancel		NewPlayer_Cancel()
			Case btn_NewPlayer_Proceed		NewPlayer_Proceed()
			
			' New Contract
			Case cmb_NewContract_Team		Combo_NewContractTeam()
			Case btn_NewContract_Accept		Button_NewContractAccept()
			
			' Header and Nav Bar
			Case btn_Header_Help			DoHelp()
			Case btn_Header_Options			SetUpScreen_Options()
			Case btn_Header_Quit			QuitGame()
			
			Case btn_NavBar_Home			SetUpScreen_Home()
			Case btn_NavBar_Leaderboards	SetUpScreen_Leaderboards()
			Case btn_NavBar_Team			SetUpScreen_Team()
			Case btn_NavBar_Finances		SetUpScreen_Finances()
			Case btn_NavBar_Casino				SetUpScreen_Casino()
			Case btn_Relations_PitCrewCasino	SetUpScreen_Casino("CMESSAGE_CASINO_PITCREW")
			Case btn_Relations_FriendsCasino	SetUpScreen_Casino("CMESSAGE_CASINO_FRIENDS")

			Case btn_NavBar_Practice		Practice()
			Case btn_NavBar_Play			Play()
			
			Case btn_News_Proceed			SetUpScreen_Home()
			
			' Track Profile
			Case btn_Track_Back				TrackProfileBack()
			Case btn_Track_Fwd				TrackProfileFwd()
			
			' History
			Case btn_History_Back			HistoryBack()
			Case btn_History_Fwd			HistoryFwd()
			
			' Leaderboard
			Case btn_Leaderboard_Refresh	gConnectToLeaderboards = True; RetrieveLeaderboard(gViewTrack)
			Case btn_Leaderboard_Upload		gConnectToLeaderboards = True; Leaderboard_SubmitTime()
			
			' Team Screen
			Case btn_TeamProfile_Back			TeamProfileBack()
			Case btn_TeamProfile_Fwd			TeamProfileFwd()
			Case btn_TeamProfile_EditTeam		EditName(CEDITNAME_TEAM)
			Case btn_TeamProfile_EditPrincipal	EditName(CEDITNAME_PRINCIPAL)
			Case btn_TeamProfile_EditDriver1	EditName(CEDITNAME_DRIVER1)
			Case btn_TeamProfile_EditDriver2	EditName(CEDITNAME_DRIVER2)
			
			' Casino
			Case btn_Casino_Home			SetUpScreen_Home()
			Case btn_Casino_BlackJack		SetUpScreen_BlackJack()
			Case btn_Casino_Roulette		SetUpScreen_Roulette()
			Case btn_Casino_Slots			SetUpScreen_Slots()
			
			Case btn_BlackJackHit			gameBlackJack.HitButton()
			Case btn_BlackJackHold			gameBlackJack.HoldButton()
			Case btn_RouletteSpin			gameRoulette.Spin()
			Case btn_RouletteClear			gameRoulette.ClearBets()
			Case btn_SlotMachinePlay		gameSlotMachine.Spin()
			Case btn_SlotMachineNudge1		gameSlotMachine.Nudge(1)
			Case btn_SlotMachineNudge2		gameSlotMachine.Nudge(2)
			Case btn_SlotMachineNudge3		gameSlotMachine.Nudge(3)

			' Race screens
			Case btn_RacePausedContinue			track.Pause()
			Case btn_RacePausedOptions			If btn_RacePausedOptions.gAlpha = 1 Then SetUpScreen_Options()
			Case btn_RacePausedQuit				quit = ButtonRaceQuit()
			Case btn_RacePausedReplay			If btn_RacePausedReplay.gAlpha = 1 Then track.Replay()
			
			Case btn_RaceInfoReplay				If btn_RaceInfoReplay.gAlpha = 1 Then track.Replay()
			Case btn_RaceInfoContinue			track.quit(); quit = True
			
			' Editor
			Case btn_Editor_ControlsBase		track.editlevel = 1; FlushMouse; track.tileset.selectedtile = 0; track.tileset.page = 0; track.mode = CTRACKMODE_EDIT; ShowMouse
			Case btn_Editor_ControlsTrack		track.editlevel = 2; FlushMouse; track.tileset.selectedtile = 0; track.tileset.page = 0; track.mode = CTRACKMODE_EDIT; ShowMouse
			Case btn_Editor_ControlsObjects		track.editlevel = 3; FlushMouse; track.tileset.selectedtile = 0; track.tileset.page = 0; track.mode = CTRACKMODE_EDIT; ShowMouse
			Case btn_Editor_ControlsCheckPoints	track.editlevel = 4; FlushMouse; track.tileset.selectedtile = 0; track.tileset.page = 0; track.mode = CTRACKMODE_EDIT; ShowMouse
			Case btn_Editor_ControlsRacingLine	track.editlevel = 5; FlushMouse; track.tileset.selectedtile = 0; track.tileset.page = 0; track.mode = CTRACKMODE_EDIT; ShowMouse
			Case btn_Editor_ControlsPitLane		track.editlevel = 6; FlushMouse; track.tileset.selectedtile = 0; track.tileset.page = 0; track.mode = CTRACKMODE_EDIT; ShowMouse
			Case btn_Editor_ControlsWalls		track.editlevel = 7; FlushMouse; track.tileset.selectedtile = 0; track.tileset.page = 0; track.mode = CTRACKMODE_EDIT; ShowMouse
			
			Case btn_Editor_LoadTrack			EditorLoadTrack()
			Case btn_Editor_DeleteTrack			EditorDeleteTrack()
			Case btn_Editor_SaveTrack			EditorSaveTrack()
			Case btn_Editor_Continue			FlushMouse; track.mode = CTRACKMODE_EDIT; ShowMouse
			Case btn_Editor_Exit				quit = EditorExit()
			Case txt_Editor_TrackMap			EditorMap()
			Case btn_Editor_Help				DoHelp()

			' Finances
			Case tbl_Finances_Cars				TShopItem.UpdateShopImages(CSHOPITEM_CAR)
			Case tbl_Finances_Property			TShopItem.UpdateShopImages(CSHOPITEM_PROPERTY)
			Case btn_Finances_CarsBuy			TShopItem.Buy(CSHOPITEM_CAR)
			Case btn_Finances_CarsDrive			ButtonFinancesDrive()
			Case btn_Finances_PropertyBuy		TShopItem.Buy(CSHOPITEM_PROPERTY)
			
			' Options
			Case btn_Options_Easy				OpDifficulty = 1; SetUpPanel_Options()
			Case btn_Options_Normal				OpDifficulty = 2; SetUpPanel_Options()
			Case btn_Options_Hard				OpDifficulty = 3; SetUpPanel_Options()
			Case btn_Options_Extreme			OpDifficulty = 4; SetUpPanel_Options()
			
			Case btn_Options_Left				OpControls[MYKEY_LEFT] = GetNewControl(); SetUpPanel_Options()
			Case btn_Options_Right				OpControls[MYKEY_RIGHT] = GetNewControl(); SetUpPanel_Options()
			Case btn_Options_Up					OpControls[MYKEY_UP] = GetNewControl(); SetUpPanel_Options()
			Case btn_Options_Down				OpControls[MYKEY_DOWN] = GetNewControl(); SetUpPanel_Options()
			Case btn_Options_Pause				OpControls[MYKEY_PAUSE] = GetNewControl(); SetUpPanel_Options()
			Case btn_Options_Info				OpControls[MYKEY_INFO] = GetNewControl(); SetUpPanel_Options()
			Case btn_Options_Kers				OpControls[MYKEY_KERS] = GetNewControl(); SetUpPanel_Options()
			
			Case btn_Options_Reg				OpenWeb(gBuyURL)
			
			Case btn_Options_Cancel				OptionsCancel()
			Case btn_Options_Proceed			OptionsProceed()
			
			' Online
			Case TOnline.btn_Online_Lan			TOnline.SwitchLanMode()
			Case TOnline.btn_Online_Refresh		TOnline.RefreshHostTable()
			Case TOnline.btn_Online_Host		TOnline.Host()
			Case TOnline.btn_Online_Join		TOnline.Join()
			Case TOnline.btn_Online_Play		TOnline.Play()
			Case TOnline.btn_Online_Exit		TOnline.Quit()
			Case TOnline.cmb_Online_Track		TOnline.RefreshHostInfo()
			Case TOnline.cmb_Online_Team		TOnline.SendTeamChoice()
			Case TOnline.btn_Online_Kick		If TOnline.hosting Then TOnline.Kick() Else TOnline.ButtonReady()
			EndSelect
			
		Case fry_EVENT_GADGETACTION
			' sliders, text boxes and check boxes			
			Select fry_EventSource()
			Case chk_Editor_TrackMap			EditorMap()
			Case chk_Options_Radio				OpRadio = chk_Options_Radio.GetState()
			Case chk_Options_Map				OpMap = chk_Options_Map.GetState()
			Case chk_Options_Fuel				OpFuel = chk_Options_Fuel.GetState()
			Case chk_Options_Damage				OpDamage = chk_Options_Damage.GetState()
			Case chk_Options_Tyres				OpTyres = chk_Options_Tyres.GetState()
			Case chk_Options_Speedo				OpSpeedo = chk_Options_Speedo.GetState()
			Case chk_Options_Kers				OpKers = chk_Options_Kers.GetState()
			Case chk_Options_FullScreen			gFullscreen = chk_Options_FullScreen.GetState();	SetUpGraphicsWindow(gFullscreen)
			Case sld_Options_Laps				OpLaps = sld_Options_Laps.GetValue(); SetUpPanel_Options()
			Case sld_Options_View				OpView = sld_Options_View.GetValue(); SetUpPanel_Options()
			Case sld_Options_SoundFX			OpVolumeFX = Float(sld_Options_SoundFX.GetValue())/10; SetUpPanel_Options()
			Case sld_Options_Music				OpVolumeMusic = Float(sld_Options_Music.GetValue())/10; SetUpPanel_Options()
			Case TOnline.txt_Online_Chat		TOnline.DoChatBox()
			Case TOnline.chk_Online_Bots		TOnline.RefreshHostInfo()
			Case TOnline.chk_Online_Collisions	TOnline.RefreshHostInfo()
			Case TOnline.chk_Online_Quali		TOnline.RefreshHostInfo()
			
			EndSelect
			
		End Select
	Wend
	
	Return quit
End Function

' ----------------------------------
' Play
' ----------------------------------

Function Play()				
	Global gFriendRequest:Int = False
	
	SetUpScreen_Home()
	
	If gYear > gNoofSeasons Then DoMessage("CMESSAGE_GAMEOVER"); Return
	
	' Check registration
	If gDemo And gWeek > 3 And gDay = CDAY_SATURDAY 
		DoMessage("CMESSAGE_DEMOFINISHED")
		If DoMessage("CMESSAGE_PURCHASE", True)
			OpenWeb(gBuyURL)
		End If
		
		Return
	End If
	
	If gDay = CDAY_SATURDAY Then Qualify()
	If gDay = CDAY_SUNDAY Then Race()
	
	gDay:+1
	If gDay > CDAY_SUNDAY
		gDay = CDAY_MONDAY 
		gWeek:+1
		gFriendRequest = False
	End If
	
	' Clear days of the week from screen messages
	For Local mess:TScreenMessage = EachIn TScreenMessage.list
		If mess.y = screenH/2 Then TScreenMessage.list.Remove(mess)
	Next
	
	TScreenMessage.Create(0,screenH/2,GetStringDayOfTheWeek(gDay),,2000,2)
	
	UpdateDatabaseInt("gamedata", "day", gDay, 1)
	UpdateDatabaseInt("gamedata", "week", gWeek, 1)
	UpdateDatabaseInt("gamedata", "year", gYear, 1)
	SetUpPanel_Date()
	UpdatePracticeButton()
	
	If gWeek > gNoofWeeks
		Select gDay 
		Case CDAY_MONDAY
			EndChampionship()
			Return
		Case CDAY_TUESDAY
			gDay = 1; gWeek = 1; gYear:+1
			UpdateDatabaseInt("gamedata", "day", gDay, 1)
			UpdateDatabaseInt("gamedata", "week", gWeek, 1)
			UpdateDatabaseInt("gamedata", "year", gYear, 1)
			
			If gYear > gNoofSeasons
				EndCareer()
				Return
			Else
				SetUpScreen_NewContract()
				Return
			EndIf
			
		End Select
	EndIf
	
	' Check sponsorships
	Select gDay 
	Case CDAY_MONDAY
		
	Case CDAY_TUESDAY
		If gRelFans > 50 And Rand(4) = 1
			Local item:String
			
			Select Rand(6)
			Case 1	item = GetLocaleText("sponsor_clothing")
			Case 2	item = GetLocaleText("sponsor_sportsdrink")
			Case 3	item = GetLocaleText("sponsor_cellphone")
			Case 4	item = GetLocaleText("sponsor_sportscar")
			Case 5	item = GetLocaleText("sponsor_wristwatch")
			Case 6	item = GetLocaleText("sponsor_jewelry")
			End Select
			
			Local amt:Int = gRelFans*1000
			DoMessage("CMESSAGE_NEWSPONSOR", False, item, Null, Null, TCurrency.GetString(OpCurrency, amt))
			UpdateCash(amt)
			
			Local sponsormoney:Int = GetDatabaseInt("sponsormoney", "gamedata", 1)
			sponsormoney:+amt
			UpdateDatabaseInt("gamedata", "sponsormoney", sponsormoney, 1)	
		End If
	
		SetUpScreen_Home()
		
	Case CDAY_SATURDAY
		SetUpScreen_Home()
		
	Case CDAY_SUNDAY
		SetUpScreen_Home()
		
	Default 'gDay = CDAY_WEDNESDAY Or gDay = CDAY_THURSDAY Or gDay = CDAY_FRIDAY
		If Rand(4) = 1 And Not gFriendRequest 
			gFriendRequest = True
			
			If DoMessage("CMESSAGE_FRIENDINVITE", True)
				UpdateRelationship(CRELATION_FRIENDS, 2.5)
				SpendTime()
			Else
				UpdateRelationship(CRELATION_FRIENDS, -10)
			End If
		End If
		
		SetUpScreen_Home()
	End Select
End Function

Function UpdatePracticeButton()
	Select gDay
	Case CDAY_MONDAY	
		If gWeek <> 1 Then SpendTime()'; TScreenMessage.Create(0,0,GetLocaleText("Rest day"),,2000,1)
	Case CDAY_TUESDAY
		btn_NavBar_Practice.gAlpha = 1
	Case CDAY_WEDNESDAY	btn_NavBar_Practice.gAlpha = 1
	Case CDAY_THURSDAY	btn_NavBar_Practice.gAlpha = 1
	Case CDAY_FRIDAY	btn_NavBar_Practice.gAlpha = 1
	Case CDAY_SATURDAY	SpendTime()
	Case CDAY_SUNDAY	SpendTime()
	End Select
	
	btn_NavBar_Casino.gAlpha = btn_NavBar_Practice.gAlpha
	btn_Relations_PitCrewCasino.gAlpha = btn_NavBar_Practice.gAlpha
	btn_Relations_FriendsCasino.gAlpha = btn_NavBar_Practice.gAlpha
	
	Select gDay
	Case CDAY_MONDAY	btn_NavBar_Play.LoadImage(gAppLoc+"Skin/Graphics/Buttons/Play.png"); btn_NavBar_Play.gTip = GetLocaleText("btn_NavBar_Play")
	Case CDAY_TUESDAY	
	Case CDAY_WEDNESDAY	
	Case CDAY_THURSDAY	
	Case CDAY_FRIDAY	
	Case CDAY_SATURDAY	btn_NavBar_Play.LoadImage(gAppLoc+"Skin/Graphics/Buttons/Play_Qualify.png");btn_NavBar_Play.gTip = GetLocaleText("btn_NavBar_PlayQualify") 
	Case CDAY_SUNDAY	btn_NavBar_Play.LoadImage(gAppLoc+"Skin/Graphics/Buttons/Play_Race.png"); btn_NavBar_Play.gTip = GetLocaleText("btn_NavBar_PlayRace")
	End Select
	
End Function

Function Practice()
	If btn_NavBar_Practice.gAlpha < 1 Then DoMessage("CMESSAGE_NOTIME"); Return
	chn_Music.SetVolume(0)
	
	' Set Up Cars	
	For Local drv:TDriver = EachIn TDriver.list
		If drv.id = gMyDriverId
			TCar.Create(CCONTROLLER_HUMAN, drv)
		EndIf
	Next
	
	track.mode = CTRACKMODE_DRIVE
	track.racestatus = CRACESTATUS_PRACTICE
	track.LoadTrack("", gWeek)
	track.totallaps = 5
	RaceEngine()
	SpendTime()
End Function

Function Qualify()
	If gWeek = 1 And gDay = 6 And gYear = 1 Then DoMessage("CMESSAGE_FIRSTQUALIFY")
	chn_Music.SetVolume(0)
	
	' Set Up Cars	
	TTeam.SelectAll()
	TDriver.SelectAll()
	
	For Local drv:TDriver = EachIn TDriver.list
		If drv.team > 0 
			If drv.id = gMyDriverId
				TCar.Create(CCONTROLLER_HUMAN, drv)
			Else
				TCar.Create(CCONTROLLER_CPU, drv)
			EndIf
		EndIf
	Next
	
	TDriver.sortby = CSORT_RANDOM
	TDriver.list.Sort()
	
	Local count:Int = 1
	For Local drv:TDriver = EachIn TDriver.list
		Local car:TCar = TCar.SelectByDriverId(drv.id)
		
		If car
			car.qualifyorder = count
			count:+1
		EndIf
	Next
	
	track.mode = CTRACKMODE_DRIVE
	track.racestatus = CRACESTATUS_QUALIFY
	track.LoadTrack("", gWeek)
	track.totallaps = 100
	track.timelimit = CQUALIFYING_TIME
	
	RaceEngine()
End Function

Function Race(trackname:String = "")
	If gMyDriverId = 21 And gWeek = 1 And gDay = 7 And gYear = 1 Then DoMessage("CMESSAGE_FIRSTRACE")
	
	AppLog "Race:"+trackname
	
	chn_Music.SetVolume(0)
	
	' Set Up Cars	
	TTeam.SelectAll()
	TDriver.SelectAll()
	
	If gQuickRace
		gWeek = 99
		TTeam.UpdateStatOrderAll()
		TTeam.sortby = CSORT_CARSTATS
		TTeam.list.Sort()
		
		Local count:Int = 1
		For Local team:TTeam = EachIn TTeam.list
			TDriver.GetDriverById(team.driver1).qualifyingtime = count+Rand(6)
			TDriver.GetDriverById(team.driver2).qualifyingtime = count+Rand(6)
			count:+1
		Next
	EndIf
	
	TDriver.sortby = CSORT_QUALIFYINGTIME
	TDriver.list.Sort()
	
	For Local drv:TDriver = EachIn TDriver.list
		If drv.team > 0 
			If drv.id = gMyDriverId
				TCar.Create(CCONTROLLER_HUMAN, drv)
			Else
				TCar.Create(CCONTROLLER_CPU, drv)
			EndIf
		EndIf
	Next
	
	track.mode = CTRACKMODE_DRIVE
	track.racestatus = CRACESTATUS_GRID
	track.LoadTrack(trackname, gWeek)
	track.totallaps = OpLaps
	track.PitStop()
	
	RaceEngine()
	SpendTime()
End Function

Function TrackEditor()
	chn_Music.SetVolume(0)
		
	gMyDriverId = 1
	db.Open(gSaveLoc + "Database/NSGP.db")
	db.Query("PRAGMA synchronous = OFF;")
		
	TNation.SelectAll()
	TTeam.SelectAll()
	TDriver.SelectAll()
	
	For Local drv:TDriver = EachIn TDriver.list
		If drv.team > 0 
			If drv.id = gMyDriverId
				TCar.Create(CCONTROLLER_HUMAN, drv)
			Else
				TCar.Create(CCONTROLLER_CPU, drv)
			EndIf
		EndIf
	Next
	
	track.mode = CTRACKMODE_EDITPAUSED
	track.racestatus = CRACESTATUS_RACE
	track.editing = True
	track.scale = 1.0
	SetScale(1,1)
	track.totallaps = 1000
	track.weather.StopWeather()
	ShowMouse
	FlushMouse
	
	txt_Editor_TrackName.SetText("NewTrack")
	SetUpScreen_Editor()
	
	RaceEngine()
	
	db.Close()
End Function

Function ButtonFinancesDrive()
	If btn_Finances_CarsDrive.gAlpha < 1 Then DoMessage("CMESSAGE_CARNOTOWNED"); Return
	If btn_NavBar_Practice.gAlpha < 1 Then DoMessage("CMESSAGE_NOTIME"); Return
	
	Local FriendOwned:Int = TShopItem.CountCarsOwnedByFriends()
		
	If FriendOwned > 0 And DoMessage("CMESSAGE_DRIVEORRACE", True, "", GetLocaleText("Practice"), GetLocaleText("Race")) = False
		FreeDrive(FriendOwned)
		UpdateRelationship(CRELATION_FRIENDS,0.5)
	Else
		FreeDrive(0)
	End If
	
End Function

Function FreeDrive(cars:Int)	
	chn_Music.SetVolume(0)
	
	' Set Up Cars	
	For Local drv:TDriver = EachIn TDriver.list
		If drv.id = gMyDriverId
			drv.team = 1
			TCar.Create(CCONTROLLER_HUMAN, drv, TShopItem.GetSelectedItemFromList(tbl_Finances_Cars.SelectedItem(), CSHOPITEM_CAR).m_Name)
		EndIf
	Next
	track.racestatus = CRACESTATUS_PRACTICE
	
	If cars > 0
		Local friend:TDriver = New TDriver
		friend.name = GetLocaleText("Friend")
		
		For Local t:Int = 1 To cars
			friend.team = 1
			friend.id = t
			TCar.Create(CCONTROLLER_CPU, friend, TShopItem.GetSelectedItemFromList(tbl_Finances_Cars.SelectedItem(), CSHOPITEM_CAR).m_Name)
		Next
		
		track.racestatus = CRACESTATUS_GRID
	EndIf
	
	track.mode = CTRACKMODE_DRIVE
	track.LoadTrack("", 0)
	track.totallaps = 5
	RaceEngine()
	SpendTime()
End Function

Function SpendTime()
	' Can only do 1 activity per day
	btn_NavBar_Practice.gAlpha = 0.5
	btn_NavBar_Casino.gAlpha = 0.5
	btn_Relations_PitCrewCasino.gAlpha = 0.5
	btn_Relations_FriendsCasino.gAlpha = 0.5
End Function

Function SaveReplay()
	txt_MessageBox_Txt.SetText("")
	
	If DoMessage("CMESSAGE_REPLAYFILENAME",True,,GetLocaleText("Save"), GetLocaleText("Cancel"),, True)
		Local repname:String = txt_MessageBox_Txt.GetText()
		
		repname = repname.Replace(".", "")
		repname = repname.Replace(",", "")
		repname = repname.Replace(":", "")
		repname = repname.Replace("|", "")
		repname = repname.Replace("/", "")
		repname = repname.Replace("\", "")
		If (repname) < 1 Then repname = "Replay"
		If cmb_Mod.SelectedItem() > 0 Then repname:+" ("+cmb_Mod.SelectedText()+")"
		
		Local dir:Int = ReadDir(gSaveloc+"\Replays\")
	
		Repeat
			Local filename$=NextFile(dir)
			If Right(filename,4) = ".rep"
				If Left(filename, Len(filename)-4) = repname
					If DoMessage("CMESSAGE_OVERWRITE", True, repname) = False 
						CloseDir dir
						Return
					EndIf
				EndIf
			EndIf
			If filename="" Exit
		Forever
		
		CloseDir dir
		
		Local file:TStream = WriteFile(gSaveloc+"\Replays\"+repname+".rep")
		
		If Not file
			DoMessage("CMESSAGE_SAVEFAILED")
		EndIf		
		
		' Header
		file.WriteLine(track.name)
		file.WriteByte(TCar.list.Count())
		
		TCar.sortby = CSORT_DRIVERID
		TCar.list.Sort()
		
		For Local c:TCar = EachIn TCar.list
			file.WriteLine(c.mydriver.name)
			file.WriteByte(c.mydriver.id)
			file.WriteByte(c.mydriver.drivernumber)
			file.WriteByte(c.mydriver.team)
			file.WriteByte(c.controller)
		Next
		
		For Local c:TCar = EachIn TCar.list
			For Local f:TReplayFrame = EachIn c.l_ReplayFrames
				f.WriteToStream(file)
			Next
		Next
		
		file.Close()
		
		DoMessage("CMESSAGE_SAVESUCCESS")
	End If
End Function

Function SaveReplayOnline()
	Global lastsavetime:Int = 0
	If gMillisecs < lastsavetime+2000 
		Return
	Else 
		lastsavetime = gMillisecs
	EndIf
	
	Local file:TStream = WriteFile(gSaveloc+"\Replays\Online_"+CurrentDate().Replace(" ", "-")+"_"+CurrentTime().Replace(":", "-")+".rep")
	If Not file Then Return
	
	' Header
	file.WriteLine(track.name)
	file.WriteByte(TCar.list.Count())
	
	TCar.sortby = CSORT_DRIVERID
	TCar.list.Sort()
	
	For Local c:TCar = EachIn TCar.list
		file.WriteLine(c.mydriver.name)
		file.WriteByte(c.mydriver.id)
		file.WriteByte(c.mydriver.drivernumber)
		file.WriteByte(c.mydriver.team)
		file.WriteByte(c.controller)
	Next
	
	For Local c:TCar = EachIn TCar.list
		For Local f:TReplayFrame = EachIn c.l_ReplayFrames
			f.WriteToStream(file)
		Next
	Next
	
	file.Close()
	
	TScreenMessage.Create(screenW/2, screenH-100, GetLocaleText("replay_Save"),,1000,1)
End Function

Function CheckFryButtonControls(panonly:fry_TPanel = Null)
	If AppSuspended() Then Return
	
	' No key or joy input when entering text
	If txt_MessageBox_Txt.gMode = 1 Then Return
	If txt_NewPlayer_Name.gMode = 1 Then Return
	If txt_NewPlayer_POB.gMode = 1 Then Return
	If txt_NewPlayer_SaveName.gMode = 1 Then Return
	If TOnline.txt_Online_Chat.gMode = 1 
		If KeyHit(KEY_DELETE) Then TOnline.ResetChatBox(1)
		Return
	EndIf
	
	' No key/joy input during editing
	If fry_ScreenName() <> "screen_raceinfo" And track.mode <> CTRACKMODE_NONE And track.mode <> CTRACKMODE_PAUSED Then Return
	If track.mode = CTRACKMODE_EDIT Or track.mode = CTRACKMODE_EDITPAUSED Or track.mode = CTRACKMODE_REPLAYING Then Return

	' Don't check input whilst racing, unless race is over
	Global lastcheck:Int = False
	
	If Track.mode = CTRACKMODE_DRIVE
		Local car:TCar = Tcar.SelectHumanCar()
		
		If car
			Local raceover:Int = car.RaceIsOver()
			
			If lastcheck = False And raceover = True Then lastcheck = raceover; MyFlushJoy(); Return
			lastcheck = raceover
			
			If Not raceover
				Return
			'Else
				' Don't check input until info screen is up
			'	If gMillisecs < car.dietime + 2500 Then MyFlushJoy(); Return
			EndIf
		EndIf
	EndIf
	
	' Read keyboard or joystick input for gui control
	Local btn:fry_TGadget
	Global lastjoyread:Int = 0
	
	' If using analogue Joy then ignore actual controls (because up/down are most probably buttons) and read axis
	If OpControls[MYKEY_LEFT] <= -100 Or OpControls[MYKEY_RIGHT] <= -100 Or OpControls[MYKEY_UP] <= -100 Or OpControls[MYKEY_DOWN] <= -100
		If Abs(JoyX()) < 0.5 And Abs(JoyY()) < 0.5 Then lastjoyread = 0
			
		If lastjoyread = 0
			If JoyY() < -0.6 Then btn = fry_GetClosestButton(MouseX(), MouseY(), 1, panonly)
			If JoyY() > 0.6 Then btn = fry_GetClosestButton(MouseX(), MouseY(), 3, panonly)
			If JoyX() < -0.6 Then btn = fry_GetClosestButton(MouseX(), MouseY(), 4, panonly)
			If JoyX() > 0.6 Then btn = fry_GetClosestButton(MouseX(), MouseY(), 2, panonly)
			If btn Then lastjoyread = MilliSecs()
		End If
	Else
		If ButtonHit(MYKEY_UP) Then btn = fry_GetClosestButton(MouseX(), MouseY(), 1, panonly)
		If ButtonHit(MYKEY_DOWN) Then btn = fry_GetClosestButton(MouseX(), MouseY(), 3, panonly)
		If ButtonHit(MYKEY_LEFT) Then btn = fry_GetClosestButton(MouseX(), MouseY(), 4, panonly)
		If ButtonHit(MYKEY_RIGHT) Then btn = fry_GetClosestButton(MouseX(), MouseY(), 2, panonly)
	EndIf
	
	If btn
		MoveMouse(btn.AbsoluteX()+(btn.gW/2), btn.AbsoluteY()+(btn.gH/2))
	End If
	
	If ButtonHit(MYKEY_INFO) Or ButtonHit(MYKEY_KERS)
		btn = fry_GetClosestButton(MouseX(), MouseY(),0,panonly)
				
		Select btn 
		Case fry_TGadget(btn_Options_Left)		MyFlushJoy()
		Case fry_TGadget(btn_Options_Right)		MyFlushJoy()
		Case fry_TGadget(btn_Options_Up)		MyFlushJoy()
		Case fry_TGadget(btn_Options_Down)		MyFlushJoy()
		Case fry_TGadget(btn_Options_Pause)		MyFlushJoy()
		Case fry_TGadget(btn_Options_Info)		MyFlushJoy()
		Case fry_TGadget(btn_Options_Kers)		MyFlushJoy()
		End Select
	
		If btn
			MoveMouse(btn.AbsoluteX()+(btn.gW/2), btn.AbsoluteY()+(btn.gH/2))
			Local md:fry_TEvent = fry_TEvent.Create(fry_EVENT_GADGETSELECT, btn)
		End If
	EndIf
End Function

Function PrintScreen()
	Local picture:TPixmap = GrabPixmap(0,0,GraphicsWidth(),GraphicsHeight())
	SavePixmapPNG (picture, gSaveloc+"Screenshots/Img_"+MilliSecs()+".png")
End Function