Type TTrack
	Global weather:TWeather
	
	Field id:Int
	Field img:TImage	' Used for single image background
	Field name:String
	
	Field mode:Int = CTRACKMODE_NONE
	Field racestatus:Int = CRACESTATUS_GRID
	Field editing:Int = False
	
	Field racestarttime:Int = 0
	Field gridstarttime:Int = 0
	Field rnd_racestart:Int	' Race lights go out between 4-7 seconds. Set this in LoadTrack
	
	Field totallaps:Int
	Field timelimit:Int
	Field laprecord:Int
	Field lapholder:Int
	Field playerlaprecord:Int

	Field scale:Float = 1.0
	Field mastertilesize:Float = 256		' Basic tile size
	Field tilesize:Float = 256				' Tile size after scaling
	Field obgrid:Int = 2					' Snap-to grid
	Field trackw:Int = 30
	Field trackh:Int = 24
	Field mapoffsetx:Int					' Position the mini map
	Field mapoffsety:Int
	
	Field tileset:TTileSet
	Field editlevel:Int = 1
	Field tile_level:TTileData[2,30,24]
	Field l_objects:TList
	Field l_waylines:TList					' Check points to make sure car completes a full lap
	Field l_waypoints:TList					' Used for the ai racing line
	Field l_pitwaypoints:TList				' Used for the pit line only
	Field l_wallpoints:TList				' Defines track walls
	
	Field currentrot:Int = 0
	Field lightsalpha:Float
	
	Field pitstop_op:Int = 1
	Field pitstop_fuel:Float = 1
	Field pitstop_tyre:Int = 1
	Field pitstop_kers:Int = 1
	
	Function Create:TTrack()
		Local newtrack:TTrack = New TTrack
		newtrack.tileset = TTileSet.Create()
		
		For Local tx:Int = 0 To newtrack.trackw-1
		For Local ty:Int = 0 To newtrack.trackh-1
			newtrack.tile_level[0,tx,ty] = New TTileData
			newtrack.tile_level[1,tx,ty] = New TTileData
		Next
		Next
		
		newtrack.totallaps = 10
		newtrack.l_objects = CreateList()
		newtrack.l_waylines = CreateList()
		newtrack.l_waypoints = CreateList()
		newtrack.l_pitwaypoints = CreateList()
		newtrack.l_wallpoints = CreateList()
		
		' Add weather object for rain
		newtrack.weather = TWeather.Create()
		
		Return newtrack
	End Function
	
	Method CheckInput()
		Select mode 
		Case CTRACKMODE_EDIT			
			If KeyHit(KEY_E) Then mode = CTRACKMODE_DRIVE; HideMouse; FlushMouse
			If KeyHit(KEY_R) Then currentrot = 0
			If KeyHit(KEY_1) Then obgrid = 1
			If KeyHit(KEY_2) Then obgrid = 2
			If KeyHit(KEY_3) Then obgrid = 4
			If KeyHit(KEY_4) Then obgrid = 8
			If KeyHit(KEY_5) Then obgrid = 16
			If KeyHit(KEY_6) Then obgrid = 32
			If KeyHit(KEY_7) Then obgrid = 64
			If KeyHit(KEY_8) Then obgrid = 128
			
		Case CTRACKMODE_DRIVE			
			If KeyHit(KEY_E) And editing Then mode = CTRACKMODE_EDIT; ShowMouse; scale = 1; FlushMouse
			
			If gDebugMode And KeyDown(KEY_LCONTROL) And KeyHit(KEY_C)
				Local id:Int = Rand(24)
				For Local car:TCar = EachIn TCar.list
					track.totallaps = 1
					If car.mydriver.id = id
						car.fuel = 0
					End If
				Next
			End If
			
			If ButtonHit(MYKEY_PAUSE) Or KeyHit(KEY_ESCAPE)
				If editing
					mode = CTRACKMODE_EDIT; ShowMouse; scale = 1
				Else
					Pause()
				EndIf
			EndIf
			
			' Debugging modes
			'If KeyDown(KEY_LCONTROL) And KeyHit(KEY_M) Then gDebugMode = Not gDebugMode
			
			If gDebugMode
				Local c:TCar = TCar.SelectHumanCar()
				
				If KeyDown(KEY_LCONTROL) And KeyHit(KEY_T) Then gRenderText = Not gRenderText
				If KeyDown(KEY_LCONTROL) And KeyHit(KEY_O) Then gRenderObjects = Not gRenderObjects
				If KeyDown(KEY_LCONTROL) And KeyHit(KEY_W) 
					For Local c:TCar = EachIn TCar.list
						If c.tyrewear > 90 Then c.tyrewear = 0 Else c.tyrewear = 100
					Next
				End If
				
				If KeyDown(KEY_LCONTROL) 
					If KeyHit(KEY_EQUALS) 
						c.lapscomplete:+1
					ElseIf KeyHit(KEY_MINUS) 
						c.lapscomplete:-1
					EndIf
				End If
				
				If KeyDown(KEY_LCONTROL) And KeyHit(KEY_F) 	
					If c.fuel > 90 Then c.fuel = 0 Else c.fuel = 100
				End If
				
				If KeyDown(KEY_LCONTROL) And KeyHit(KEY_D) 	
					If c.damage > 90 Then c.damage = 0 Else c.damage = 100
				End If
				
				If KeyDown(KEY_LCONTROL) And KeyHit(KEY_P) Then PitStop()
			EndIf
			
			If KeyDown(KEY_LCONTROL) And KeyDown(KEY_LSHIFT) And KeyHit(KEY_N) Then OpNames = Not OpNames
			If KeyDown(KEY_LCONTROL) And KeyDown(KEY_LSHIFT) And KeyHit(KEY_G) Then OpGhost = Not OpGhost
			
		Case CTRACKMODE_REPLAYING		
			If ButtonHit(MYKEY_PAUSE) Or KeyHit(KEY_ESCAPE)
				If gLoadedReplay
					track.Quit()
					Return
				End If
				Replay()
				
				' If this isn't the final replay then re-pause
				Local c:TCar = TCar.SelectHumanCar()
				If c And c.RaceIsOver() = False Then mode = CTRACKMODE_PAUSED
				
			EndIf
			
		Case CTRACKMODE_PAUSED
			If (ButtonHit(MYKEY_PAUSE) Or KeyHit(KEY_ESCAPE)) And fry_ScreenName() <> "screen_options" Then Pause()
			
		End Select
			
		If ButtonDown(MYKEY_INFO) Then TCar.ResetMiniInfoAlphaAll()
		
		tilesize = mastertilesize*scale
	End Method
	
	Method Pause()
		AppLog "Pause"
		Global pausetime:Int = gMillisecs
		
		lbl_RacePaused.SetText(GetLocaleText("Paused"))
		btn_RacePausedReplay.gAlpha = 1.0
		btn_RacePausedOptions.gAlpha = 1.0
		
		If racestatus = CRACESTATUS_GRID Then btn_RacePausedReplay.gAlpha = 0.5
		
		If TOnline.netstatus
			lbl_RacePaused.SetText(GetLocaleText("Online Racing"))
			btn_RacePausedOptions.gAlpha = 0.5
			btn_RacePausedReplay.gAlpha = 0.5
		EndIf
		
		If mode = CTRACKMODE_PAUSED
			mode = CTRACKMODE_DRIVE
			TCar.PauseSound(False)
			
			If Not TOnline.netstatus
				gStartTime:+(gMillisecs-pausetime)
				gMillisecs = MilliSecs()-gStartTime
			EndIf
		Else
			fry_SetScreen("screen_racepaused")
			
			Select racestatus
			Case CRACESTATUS_QUALIFY	btn_RacePausedQuit.SetText(GetLocaleText("Skip Time"))
			Default						btn_RacePausedQuit.SetText(GetLocaleText("Quit"))
			End Select
			
			mode = CTRACKMODE_PAUSED
			TCar.PauseSound(True)
			pausetime = gMillisecs
		EndIf
		
		MyFlushJoy()
	End Method
	
	Method Replay()		
		Global pausetime:Int = gMillisecs
		
		If mode = CTRACKMODE_REPLAYING
			mode = CTRACKMODE_DRIVE
			TCar.LastReplayFrameAll()
			
			If TCar.SelectHumanCar().RaceIsOver() 
				gStartTime:+(gMillisecs-pausetime)
			End If
		Else
			TCar.replaycarid = gMyDriverId
			mode = CTRACKMODE_REPLAYING
			pausetime = gMillisecs
			TCar.ResetReplayFramesAll()
		EndIf
		
		TCar.ReplayFrameAll()
		MyFlushJoy()
	End Method
	
	Method PitStop()
		AppLog "PitStop"
		Global pausetime:Int = gMillisecs
		Global instrucs:Int = True
		
		If mode = CTRACKMODE_PITSTOP
			mode = CTRACKMODE_DRIVE
			TCar.PauseSound(False)
						
			Select pitstop_tyre
			Case 1 
			Case 2 TCar.SelectHumanCar().ChangeTyre(CTYRE_HARD)
			Case 3 TCar.SelectHumanCar().ChangeTyre(CTYRE_SOFT)
			Case 4 TCar.SelectHumanCar().ChangeTyre(CTYRE_WET)
			End Select
			
			TCar.SelectHumanCar().FitKers(pitstop_kers)
			
			TScreenMessage.ClearAll()
			If racestatus = CRACESTATUS_GRID
				TCar.SelectHumanCar().fuel = pitstop_fuel
				TScreenMessage.Create(0,screenH/2, GetLocaleText("grid_Instructions"),,5000,1) 
			Else 
				If Not TOnline.netstatus
					gStartTime:+(gMillisecs-pausetime)
					gMillisecs = MilliSecs()-gStartTime
				End If
			EndIf
		Else
			mode = CTRACKMODE_PITSTOP
			TCar.PauseSound(True)
			pausetime = gMillisecs
			
			pitstop_op = 1
			pitstop_fuel = TCar.SelectHumanCar().fuel
			pitstop_tyre = 1
			pitstop_kers = TCar.SelectHumanCar().mydriver.kersfitted
			If Not OpKers Then pitstop_kers = False
			
			If instrucs
				TScreenMessage.Create(0,screenH/2, GetLocaleText("pitstop_Instructions"),,5000,1)
				instrucs = False
			EndIf
		EndIf
		
		MyFlushJoy()
	End Method
	
	Method ButtonQuit:Int()
		Select racestatus
		Case CRACESTATUS_GRID		Return DoMessage("CMESSAGE_QUITRACE", True)
		Case CRACESTATUS_RACE		Return DoMessage("CMESSAGE_QUITRACE", True)
		Case CRACESTATUS_PRACTICE	Return DoMessage("CMESSAGE_QUITPRACTICE", True)
		Case CRACESTATUS_QUALIFY	Return DoMessage("CMESSAGE_QUITQUALIFYING", True)
		End Select
	End Method
	
	Method Quit()
		AppLog "Quit Track:"+track.id
		
		' Close race report
		If gSaveRaceReport Then TRaceReport.SaveReport()
		
		' Update track record
		If Not gLoadedReplay And mode <> CTRACKMODE_EDIT And mode <> CTRACKMODE_EDITPAUSED And track.id >= 0 And track.id <= gNoofWeeks Then UpdateDb()
		
		weather.StopWeather()
		radioqueue.Clear()
		TScreenMessage.ClearAll()
		MyFlushJoy()
		
		If Not gLoadedReplay And TOnline.netstatus = CNETWORK_NONE And track.id = 0 And mode <> CTRACKMODE_EDIT And mode <> CTRACKMODE_EDITPAUSED
			TCar.ClearAll()
			SetUpScreen_Home()
			mode = CTRACKMODE_NONE
			Return
		End If 
		
		If gLoadedReplay Or gQuickRace Or mode = CTRACKMODE_EDIT Or mode = CTRACKMODE_EDITPAUSED
			' If online, return to lobby, refreshing status and server info
			If TOnline.netstatus
				TOnline.SetUpOnlineLobby2()
			Else
				TCar.ClearAll()
				db.Close()
				SetUpScreen_Start()
			End If
		Else
			TCar.UpdatePositionsAll()
			Local winnername:String
			Local trackname:String = GetDatabaseString("name", "track", id)
			Local mypos:Int = 0
			tbl_News_Results.ClearItems()
			
			' Update any points or qualifying times
			Select racestatus 
			Case CRACESTATUS_PRACTICE
				
			Case CRACESTATUS_QUALIFY
				' First check through cars in order of team to see if they have set a qualifying time
				TTeam.UpdateStatOrderAll()
				
				For Local c:TCar = EachIn TCar.list
					' Don't give human a finish time if he quit
					If c.mydriver.qualifyingtime = 0 And c.mydriver.id <> gMyDriverId
						Local lrec:Int = laprecord
						If laprecord = 0 Then lrec = 60000
						
						' Get a lap time based on the existing lap record and driver id
						If TTeam.GetById(c.mydriver.id)
							c.mydriver.qualifyingtime = lrec+Rand(500,750)+(TTeam.GetById(c.mydriver.id).statorder*Rand(100,250))
						EndIf
					End If
				Next
				
				TTeam.UpdateStatOrderAll()				
				TCar.sortby = CSORT_QUALIFYINGTIME
				TCar.list.Sort()
				
				Local pos:Int = 1
				For Local c:TCar = EachIn TCar.list
					If pos = 1 
						c.mydriver.careerpoles:+1
						c.mydriver.seasonpoles:+1
					EndIf
					
					' Team
					Local t:TTeam = TTeam.GetTeamByDriverId(c.mydriver.id)
					If pos = 1 
						t.seasonpoles:+1
						t.careerpoles:+1
					EndIf
					
					' Impress boss
					If c.mydriver.id = gMyDriverId
						If pos = 1
							UpdateRelationship(CRELATION_BOSS, 5)
							UpdateRelationship(CRELATION_FANS, 5)
						ElseIf pos <= t.statorder+5-OpDifficulty
							UpdateRelationship(CRELATION_BOSS, 3)
						ElseIf pos < t.statorder*2
							UpdateRelationship(CRELATION_BOSS, 0)
						Else
							UpdateRelationship(CRELATION_BOSS, -3)
						End If
					End If
					
					pos:+1
				Next
			Default	' Grid or race
				
				' First check through cars in order of position to see if they have finished yet
				TCar.sortby = CSORT_POSITION
				TCar.list.Sort()
				
				Local previouscartime:Int = 0
				
				For Local c:TCar = EachIn TCar.list
					' Don't give human a finish time if he quit, don't give CPU a race time if out of fuel or completely damaged
					If c.mydriver.lastracetime = 0 And c.mydriver.id <> gMyDriverId And c.fuel > 0 And c.damage < 100
						' Check that previous car set a race time
						Local lrec:Int = laprecord
						If laprecord = 0 Then lrec = 60000
						
						If previouscartime = 0 Then previouscartime = totallaps*(lrec+Rand(500,750))
						
						' Now calculate rough time of how much later than previous car this one should be
						c.mydriver.lastracetime = previouscartime + Rand(500,2500)
					End If
					
					previouscartime = c.mydriver.lastracetime
				Next
			
				' Now sort through cars to apply points/stats
				TCar.sortby = CSORT_FINISHTIME
				TCar.list.Sort()
				
				db.Query("BEGIN;")
				
				Local pos:Int = 1
				For Local c:TCar = EachIn TCar.list			
					' Career
					If pos < 4 Then c.mydriver.careerpodiums:+1
					c.mydriver.careerpts:+GetPositionPoints(pos)
					c.mydriver.careerraces:+1
					If pos = 1 Then c.mydriver.careerwins:+1
					
					' Season
					If pos < 4 Then c.mydriver.seasonpodiums:+1
					c.mydriver.seasonpts:+GetPositionPoints(pos)
					c.mydriver.seasonraces:+1
					If pos = 1 Then c.mydriver.seasonwins:+1; winnername = c.mydriver.name
					
					' Team
					Local t:TTeam = TTeam.GetTeamByDriverId(c.mydriver.id)
					If pos = 1 Then t.careerwins:+1
					If pos < 4 Then t.seasonpodiums:+1
					t.seasonpts:+GetPositionPoints(pos)
					If pos = 1 Then t.seasonwins:+1
					
					If c.mydriver.id = gMyDriverId Then mypos = pos
					
					' Update news table
					tbl_News_Results.AddItem([String(pos), c.mydriver.name, t.name, String(GetPositionPoints(pos))])
					
					' Update history
					Local q:String = "INSERT INTO history VALUES(NULL, "+gYear+", "+gWeek+", '"+c.mydriver.name+"', '"+t.name+"', "+pos+", "+c.mydriver.lastracetime+", "+GetPositionPoints(pos)+", "+c.mydriver.iwaslapped+")"
					AppLog q
					db.Query(q)
					
					pos:+1
				Next
				
				db.Query("COMMIT;")
			End Select
			
			tbl_News_Results.SelectItem(mypos-1)
		'	tbl_News_Results.ShowItem(mypos-1)
			
			TTeam.UpdateDbAll()
			TDriver.UpdateDbAll()
			TCar.ClearAll()
			SaveGame()
			
			Select racestatus
			Case CRACESTATUS_GRID
				SetUpScreen_News(winnername, trackname, mypos)
			Case CRACESTATUS_RACE
				SetUpScreen_News(winnername, trackname, mypos)
			Case CRACESTATUS_PRACTICE
				SetUpScreen_Home()
			Case CRACESTATUS_QUALIFY
				SetUpScreen_Home()
			End Select
		End If
		
		mode = CTRACKMODE_NONE
	End Method
	
	Method UpdateDb()
		If TOnline.netstatus Then Return
		
		AppLog "Track.UpdateDb: "+track.id
			
		' Update lap record
		UpdateDatabaseInt("track", "laprecord", laprecord, track.id)
		UpdateDatabaseInt("track", "lapholder", lapholder, track.id)
		
		For Local c:TCar = EachIn TCar.list
			If c.mydriver.id = gMyDriverId And gMyDriverId = 21
				If c.bestlaptime < playerlaprecord Or playerlaprecord = 0
				
					playerlaprecord = c.bestlaptime
					playerlaprecord:*track.id+1
					playerlaprecord:+c.mydriver.dob
					
					Local team:TTeam = TTeam.GetTeamByDriverId(21)
					Local str:String 
					If team
						str = String(playerlaprecord)+":"+GetFloatAsString(team.handling)+":"+GetFloatAsString(team.acceleration)+":"+GetFloatAsString(team.topspeed)
					End If
					
					UpdateDatabaseString("track", "playerlaprecord", str, track.id)
				End If
			EndIf
		Next
	End Method
	
	Method Update()		
		Global joyreset:Int = True
			
		UpdateTrackScale()
		
		' Check mouse if not in drive mode
		Select mode 
		Case CTRACKMODE_EDIT	
			If KeyHit(OpControls[MYKEY_PAUSE]) Or KeyHit(KEY_ESCAPE) Then mode = CTRACKMODE_EDITPAUSED; HideMouse; FlushMouse; SetUpScreen_Editor()
			
			tileset.Update(editlevel)
			
			If MouseX() < screenW-64 Or editlevel > 3
				Select editlevel
				Case 3
					If MouseHit(1) 
						If KeyDown(KEY_LCONTROL)
							Local closestob:Int = GetClosestOb(Abs(originx)+MouseX(), Abs(originy)+MouseY())
							
							If closestob > -1
								Local count:Int = 0
								For Local ob:TTileData = EachIn l_objects
									count:+1
									If count = closestob Then l_objects.Remove(ob)
								Next
							EndIf
						ElseIf tileset.selectedtile > -1
							Local img:TImage = tileset.objecttile_array[tileset.selectedtile].img
							Local newob:TTileData = New TTileData
							newob.id = tileset.selectedtile
							
							Local msx:Int = Abs(originx)+MouseX()
							Local msy:Int = Abs(originy)+MouseY()
							msx:/obgrid; msx:*obgrid
							msy:/obgrid; msy:*obgrid
							
							newob.parentx = msx
							newob.parenty = msy
							newob.rotation = currentrot
							
							If KeyDown(KEY_LSHIFT)
								l_objects.AddFirst(newob)
							Else
								l_objects.AddLast(newob)
							EndIf
						EndIf
					EndIf
					
					If MouseHit(2) 
						If KeyDown(KEY_LSHIFT)
							currentrot:-15
							If currentrot < 0 Then currentrot = 360
						Else
							currentrot:+15
							If currentrot > 360 Then currentrot = 0
						EndIf
					EndIf
					
					If KeyDown(KEY_LCONTROL) And KeyHit(KEY_DELETE) Then l_objects.Clear()
				Case 4
					If MouseHit(1) Then PlaceWayline()
					If MouseHit(2) Then DeleteWayline()
					If KeyHit(KEY_DELETE) Then l_waylines.Clear()
				Case 5
					If MouseHit(1) Then PlaceWayPoint(l_waypoints)
					If MouseHit(2) Then DeleteWayPoint(l_waypoints)
					If KeyHit(KEY_DELETE) Then l_waypoints.Clear()
				Case 6
					If MouseHit(1) Then PlaceWayPoint(l_pitwaypoints)
					If MouseHit(2) Then DeleteWayPoint(l_pitwaypoints)
					If KeyHit(KEY_DELETE) Then l_pitwaypoints.Clear()
				Case 7
					If MouseHit(1) Then PlaceWayPoint(l_wallpoints)
					If MouseHit(2) Then DeleteWayPoint(l_wallpoints)
					If KeyHit(KEY_DELETE) Then l_wallpoints.Clear()
				Default
					If MouseHit(2) 
						currentrot:+90
						If currentrot > 270 Then currentrot = 0
					EndIf
					
					If MouseHit(1) Then PlaceTile()
				End Select
			
			Else
				FlushMouse
			EndIf
		Case CTRACKMODE_EDITPAUSED
			If ButtonHit(MYKEY_PAUSE) Or KeyHit(KEY_ESCAPE) Then mode = CTRACKMODE_EDIT; ShowMouse; FlushMouse
			
		Case CTRACKMODE_PITSTOP
			Local car:TCar = TCar.SelectHumanCar()
			
			If ButtonHit(MYKEY_PAUSE) Or KeyHit(KEY_ESCAPE) Then track.PitStop(); If Not chn_FX.Playing() Then PlaySound(snd_Click, chn_FX)
			If ButtonHit(MYKEY_UP) Or (joyreset And JoyY() < -0.5) 
				pitstop_op:-1; MyFlushJoy(); joyreset = 0
				If Not chn_FX.Playing() Then PlaySound(snd_Click, chn_FX)
				If pitstop_op = 3 And (racestatus = CRACESTATUS_RACE Or Not OpKers) Then pitstop_op = 2
			EndIf
			
			If ButtonHit(MYKEY_DOWN) Or (joyreset And JoyY() > 0.5) 
				pitstop_op:+1; MyFlushJoy(); joyreset = 0; 
				If Not chn_FX.Playing() Then PlaySound(snd_Click, chn_FX)
				If pitstop_op = 3 And (racestatus = CRACESTATUS_RACE Or Not OpKers) Then pitstop_op = 4
			EndIf
			
			If pitstop_op < 1 Then pitstop_op = 1
			If pitstop_op > 4 Then pitstop_op = 4
			
			Select pitstop_op
			Case 1	
				If OpFuel
					If ButtonDown(MYKEY_LEFT) Or (JoyX() < -0.5) Then pitstop_fuel:-1*GetGameSpeed(); joyreset = 0; If Not chn_FX.Playing() Then PlaySound(snd_Open, chn_FX)
					If ButtonDown(MYKEY_RIGHT) Or (JoyX() > 0.5) Then pitstop_fuel:+1*GetGameSpeed(); joyreset = 0; If Not chn_FX.Playing() Then PlaySound(snd_Open, chn_FX)
				
					pitstop_fuel = Int(pitstop_fuel)
					If pitstop_fuel < 0 Then pitstop_fuel = 0
					If pitstop_fuel < car.fuel Then pitstop_fuel = car.fuel
					If pitstop_fuel > 100 Then pitstop_fuel = 100
				EndIf
				
			Case 2
				If ButtonHit(MYKEY_LEFT) Or (joyreset And JoyX() < -0.5) Then pitstop_tyre:-1; joyreset = 0; If Not chn_FX.Playing() Then PlaySound(snd_Click, chn_FX)
				If ButtonHit(MYKEY_RIGHT) Or (joyreset And JoyX() > 0.5) Then pitstop_tyre:+1; joyreset = 0; If Not chn_FX.Playing() Then PlaySound(snd_Click, chn_FX)
				
				If pitstop_tyre < 1 Then pitstop_tyre = 1
				If pitstop_tyre > 4 Then pitstop_tyre = 4
			
			Case 3
				If OpKers
					If ButtonHit(MYKEY_LEFT) Or (joyreset And JoyX() < -0.5) Then pitstop_kers:-1; joyreset = 0; If Not chn_FX.Playing() Then PlaySound(snd_Click, chn_FX)
					If ButtonHit(MYKEY_RIGHT) Or (joyreset And JoyX() > 0.5) Then pitstop_kers:+1; joyreset = 0; If Not chn_FX.Playing() Then PlaySound(snd_Click, chn_FX)
				
					If pitstop_kers < 0 Then pitstop_kers = 0
					If pitstop_kers > 1 Then pitstop_kers = 1
				EndIf
				
			Case 4
				If ButtonDown(MYKEY_RIGHT) Then track.PitStop(); If Not chn_FX.Playing() Then PlaySound(snd_Click, chn_FX)
				
			End Select
		Case CTRACKMODE_DRIVE
			weather.Update()
			
		End Select
		
		If JoyX() > -0.25 And JoyX() < 0.25 And JoyY() > -0.25 And JoyY() < 0.25 
			joyreset = True
		End If
		
		If lightsalpha > 0 Then lightsalpha:-0.005*GetGameSpeed()
	End Method
	
	Method GetClosestOb:Int(msx:Int, msy:Int)
		Local closestob:Int = -1
		Local closest:Float = 9999999
		
		Local count:Int = 0
		For Local ob:TTileData = EachIn l_objects
			count:+1
			
			Local dist:Float = GetDistance(msx, msy, ob.parentx, ob.parenty) 
			If dist < closest
				closest = dist
				closestob = count
			EndIf
		Next
		
		Return closestob
	End Method
	
	Method Draw(tween:Float)
		SetScale(scale, scale)
		ResetDrawing()
		
		' interpolate between old and actual positions
		Local ox:Float = originx * tween + oldoriginx * (1.0 - tween)
		Local oy:Float = originy * tween + oldoriginy * (1.0 - tween)
		
		' Base level 1 (grass)
		If img And ImageWidth(img) > 0 
			Local div:Float = (mastertilesize*trackw)/ImageWidth(img)
			Local h:Float = ImageHeight(img)*div
			
			DrawImageRect(img,ox,oy,mastertilesize*trackw,h)
		Else
			Local basetileid:Int = tile_level[0,0,0].id
			If basetileid < 0 Then basetileid = 0 
			TileImage(tileset.basetile_array[basetileid].img, ox, oy)
		EndIf
		
		' Base level 2 (other tiles grass, tarmac)
		For Local tx:Int = 0 To trackw-1
		For Local ty:Int = 0 To trackh-1
			Local id:Int = tile_level[0,tx,ty].id
			
			If id > 0
				ResetDrawing()
			
				' Set up image
				Local rot:Int = tile_level[0,tx,ty].rotation
				Local img:TImage = tileset.basetile_array[id].img
					
				Local posx:Float = ox+(tx*tilesize)+((ImageWidth(img)*scale)/2)
				Local posy:Float = oy+(ty*tilesize)+((ImageHeight(img)*scale)/2)
				
				' If position is on screen
				If posx > -256 And posy > -256
				If posx < screenW+256 And posy < screenH+256
					
					MidHandleImage(img)
					SetRotation(rot)
					
					' Draw tile
					DrawImage(img, posx, posy)
					SetImageHandle(img,0,0)
				EndIf
				EndIf
			EndIf
		Next
		Next
		
		' Track level
		For Local tx:Int = 0 To trackw-1
		For Local ty:Int = 0 To trackh-1
			Local id:Int = tile_level[1,tx,ty].id 
			
			If id > -1
				ResetDrawing()
			
				' Set up image
				Local rot:Int = tile_level[1,tx,ty].rotation
				Local img:TImage = tileset.tracktile_array[id].img
					
				Local posx:Float = ox+(tx*tilesize)+((ImageWidth(img)*scale)/2)
				Local posy:Float = oy+(ty*tilesize)+((ImageHeight(img)*scale)/2)
				
				' If position is on screen
				If posx > -320 And posy > -320
				If posx < screenW+320 And posy < screenH+320
					
					MidHandleImage(img)
					SetRotation(rot)
					
					' Draw tile
					DrawImage(img, posx, posy)
					SetImageHandle(img,0,0)
				EndIf
				EndIf
			EndIf

		Next
		Next
		
		If gDebugMode And Not gRenderObjects Then Return
		
		' Draw objects
		Local drawcount:Int = 0
		ResetDrawing()
		Local closestob:Int = -1
		If mode = CTRACKMODE_EDIT And KeyDown(KEY_LCONTROL) And editlevel = 3
			closestob = GetClosestOb(Abs(originx)+MouseX(), Abs(originy)+MouseY())
		EndIf
		
		Local count:Int
		For Local ob:TTileData = EachIn l_objects
			If ob.id > -1
				count:+1
				If ob.id < tileset.objecttile_array.Length
					Local drawob:Int = True
					
					If gLowDetail
						drawob = False
						
						If ob.id >= 11 And ob.id <= 25
							drawob = True
						ElseIf ob.id >= 31 And ob.id <= 41
							drawob = True
						ElseIf ob.id = 47
							drawob = True
						ElseIf ob.id >= 55 And ob.id <= 60
							drawob = True
						EndIf
					EndIf
					
					If drawob
						Local img:TImage = tileset.objecttile_array[ob.id].img
						SetRotation(ob.rotation)
						Local posx:Float = ox+ob.parentx*scale
						Local posy:Float = oy+ob.parenty*scale
						' If position is on screen
						If posx > -512 And posy > -512
						If posx < screenW+512 And posy < screenH+512
							MidHandleImage(img)
							SetColor(255,255,255)
							If count = closestob Then SetColor(255,90,90)
							DrawImage(img, posx, posy)
							drawcount:+1
						EndIf
						EndIf
					EndIf
					
					If count = closestob
						SetColor(255,0,0)
						SetRotation(0)
						DrawLine(ox+ob.parentx,oy+ob.parenty, MouseX(), MouseY())
						ResetDrawing()
					End If
				EndIf
			EndIf
		Next
		
		' Draw pit team logos
		For Local tx:Int = 0 To track.trackw-1
		For Local ty:Int = 0 To track.trackh-1
			Local id:Int = track.tile_level[1,tx,ty].id
			Local rot:Int = track.tile_level[1,tx,ty].rotation
			
			If id > -1
				SetRotation(rot)
				
				' Bay 1
				Local imx:Float = 2
				Local imy:Float = -53
				DoXYRotation(imx, imy, rot, track.mastertilesize)
				
				Local posx:Float = ox+(tx*tilesize)+(imx*scale)
				Local posy:Float = oy+(ty*tilesize)+(imy*scale)
				
				Local t:TTeam
				Select track.tileset.tracktile_array[id].name
				Case "Track_18.png"	t = TTeam.GetById(1); If t Then DrawImageRect(t.img, posx, posy, 124, 30)
				Case "Track_19.png" t = TTeam.GetById(3); If t Then DrawImageRect(t.img, posx, posy, 124, 30)
				Case "Track_20.png" t = TTeam.GetById(5); If t Then DrawImageRect(t.img, posx, posy, 124, 30)
				Case "Track_21.png" t = TTeam.GetById(7); If t Then DrawImageRect(t.img, posx, posy, 124, 30)
				Case "Track_22.png" t = TTeam.GetById(9); If t Then DrawImageRect(t.img, posx, posy, 124, 30)
				Case "Track_23.png" t = TTeam.GetById(11); If t Then DrawImageRect(t.img, posx, posy, 124, 30)
				End Select
				
				' Bay 2
				imx = 130
				imy = -53
				DoXYRotation(imx, imy, rot, track.mastertilesize)
				
				posx = ox+(tx*tilesize)+(imx*scale)
				posy = oy+(ty*tilesize)+(imy*scale)
				
				Select track.tileset.tracktile_array[id].name
				Case "Track_18.png"	t = TTeam.GetById(2); If t Then DrawImageRect(t.img, posx, posy, 126, 30)
				Case "Track_19.png" t = TTeam.GetById(4); If t Then DrawImageRect(t.img, posx, posy, 126, 30)
				Case "Track_20.png" t = TTeam.GetById(6); If t Then DrawImageRect(t.img, posx, posy, 126, 30)
				Case "Track_21.png" t = TTeam.GetById(8); If t Then DrawImageRect(t.img, posx, posy, 126, 30)
				Case "Track_22.png" t = TTeam.GetById(10); If t Then DrawImageRect(t.img, posx, posy, 126, 30)
				Case "Track_23.png" t = TTeam.GetById(12); If t Then DrawImageRect(t.img, posx, posy, 126, 30)
				End Select
			EndIf		
		Next
		Next
		
		' Do weather
		If mode <> CTRACKMODE_REPLAYING Then track.weather.Draw()
		
		' Now draw current tile if you are not in drive mode
		If mode <> CTRACKMODE_EDIT Then Return
		
		' Draw Way Lines
		ResetDrawing()
		If editlevel = 4
			For Local wl:TWayLine = EachIn l_waylines
				If mode = CTRACKMODE_DRIVE And TCar.SelectHumanCar().lastwayline >= wl.id
					SetColor(128,128,128)
				Else
					SetColor(255,0,255)
				End If
				
				DrawRect(ox+wl.x1 - 2, oy+wl.y1 - 2, 4, 4)
				fnt_Medium.Draw(wl.id, ox+wl.x1 + 4, oy+wl.y1 - 2-fntoffset_Medium)
				
				If wl.x2 > -1
					DrawRect(ox+wl.x2 - 2, oy+wl.y2 - 2, 4, 4)
					DrawLine(ox+wl.x1, oy+wl.y1,ox+wl.x2, oy+wl.y2)
				End If
			Next
			
			' Highlight adjustment
			If KeyDown(KEY_LCONTROL)
				Local wx:Int
				Local wy:Int
				
				GetNearestWayLineXY(MouseX(), MouseY(), wx, wy)
				SetColor(0,255,255)
				DrawLine(ox+wx, oy+wy, MouseX(), MouseY())
			EndIf
		End If
		
		' Draw way-points
		If editlevel = 3 Or editlevel = 5 Or editlevel = 6 Or editlevel = 7
			Local listpoints:TList
			
			Select editlevel
			Case 3	listpoints = l_wallpoints; SetColor(64,64,64)  	' Show walls when placing objects
			Case 5	listpoints = l_waypoints; SetColor(0,0,255)
			Case 6	listpoints = l_pitwaypoints; SetColor(255,255,0)
			Case 7	listpoints = l_wallpoints; SetColor(64,64,64)
			End Select
			
			Local lastwp:TWayPoint
			
			For Local wp:TWayPoint = EachIn listpoints				
				If TCar.SelectHumanCar().nextwp 
					If TCar.SelectHumanCar().nextwp.id = wp.id Then SetColor(255,255,255)
				EndIf
				
				DrawRect(ox+wp.x - 2, oy+wp.y - 2, 4, 4)
				fnt_Medium.Draw(wp.id, ox+wp.x + 4, oy+wp.y - 2-fntoffset_Medium)
				
				If wp.id > 1 And lastwp
					DrawLine(ox+lastwp.x, oy+lastwp.y, ox+wp.x, oy+wp.y)
				End If
				
				lastwp = wp
			Next
			
			' Highlight adjustment
			If KeyDown(KEY_LCONTROL) And editlevel > 3 
				Local nearestwp:TWayPoint = GetNearestWayPoint(MouseX(), MouseY(), listpoints)
				
				If nearestwp
					SetColor(0,255,255)
					DrawLine(ox+nearestwp.x, oy+nearestwp.y, MouseX(), MouseY())
				EndIf
			EndIf
		End If
		
		' Draw track grid
		ResetDrawing()
		SetAlpha(0.25)
		SetColor(255,255,255)
		For Local gridx:Int = 0 To trackw-1
			DrawLine(ox+(gridx*tilesize), 0, ox+(gridx*tilesize), 6000)
		Next
		
		For Local gridy:Int = 0 To trackh-1
			DrawLine(0, oy+(gridy*tilesize), 8000, oy+(gridy*tilesize))
		Next
		
		' Draw tile panel 
		tileset.DrawTileSetPanel(editlevel)
		
		' Show current tile and placement area
		If MouseX() < screenW-64 And tileset.selectedtile > -1 And Not KeyDown(KEY_LCONTROL) 
			Local img:TImage 
			
			Select editlevel
			Case 1 
				img = tileset.basetile_array[tileset.selectedtile].img
			Case 2 
				img = tileset.tracktile_array[tileset.selectedtile].img
			Case 3 
				img = tileset.objecttile_array[tileset.selectedtile].img
			Default Return
			End Select 
			
			' Draw placement area
			Local msx:Int = Abs(originx)+MouseX()
			Local msy:Int = Abs(originy)+MouseY()
			msx:/obgrid; msx:*obgrid
			msy:/obgrid; msy:*obgrid
						
			Local ptilex:Int = (msx / mastertilesize)
			Local ptiley:Int = (msy / mastertilesize)
		
			If editlevel < 3
				SetAlpha(0.5)
				SetColor(255,255,0)
				DrawRect(ox+(ptilex*mastertilesize), oy+(ptiley*mastertilesize), ImageWidth(img)*scale, ImageHeight(img)*scale)
				
				SetAlpha(0.5)
				SetColor(255,255,0)
				DrawRect(MouseX()-((ImageWidth(img)*scale)/2)-1, MouseY()-((ImageHeight(img)*scale)/2)-1, (ImageWidth(img)*scale)+2, (ImageHeight(img)*scale)+2)
			EndIf
			
			' Draw selected tile
			SetAlpha(1)
			SetColor(255,255,255)
			MidHandleImage(img)
			SetRotation(currentrot)
			
			If editlevel = 3
				DrawImage(img, msx-Abs(originx), msy-Abs(originy))
			Else
				DrawImage(img, MouseX(), MouseY())
			EndIf
			
			SetImageHandle(img,0,0)
			SetRotation(0)
		EndIf	
	End Method
	
	Method DrawInfo()
		Local car:TCar = TCar.SelectHumanCar()
		
		If Not car Then Return
				
		car.DrawInfo()

		Select mode 
		Case CTRACKMODE_DRIVE
			Local lx:Int = (screenW/2)-ImageWidth(imgLights)/2
			Local ly:Int = (screenH/2)-250
			Local startdelay:Int = 2000
				
			Select racestatus
			Case CRACESTATUS_GRID
				lightsalpha = 1
				SetAlpha(lightsalpha)
				SetScale(1,1)
				
				' If online then wait for signal from host
				If TOnline.netstatus > CNETWORK_NONE And TOnline.netstatus < CNETWORK_RACE
					' Host sends signal to start race
					If gridstarttime = 0
						If TOnline.hosting
							TOnline.SendNetStatus(CNETWORK_RACE)
						Else
							' Client sends signal that he is ready to start race
							TOnline.SendNetStatus(CNETWORK_RACEREADY)
						EndIf
					EndIf
					
					' Don't start race yet
					gridstarttime = gMillisecs
					If Not TOnline.hosting Then gridstarttime = gMillisecs-300
				Else
					' Record grid start time
					If gridstarttime = 0 Then gridstarttime = gMillisecs
				EndIf
				
				' Show race lights
				DrawImage(imgLights, lx, ly, 0)
				Global lightsound:Int = 0
				If gMillisecs > gridstarttime+startdelay+1000 Then DrawImage(imgLights, lx, ly, 1); If lightsound < 1 Then PlaySound(snd_Lights1, chn_FX); lightsound:+1
				If gMillisecs > gridstarttime+startdelay+2000 Then DrawImage(imgLights, lx, ly, 2); If lightsound < 2 Then PlaySound(snd_Lights1, chn_FX); lightsound:+1
				If gMillisecs > gridstarttime+startdelay+3000 Then DrawImage(imgLights, lx, ly, 3); If lightsound < 3 Then PlaySound(snd_Lights1, chn_FX); lightsound:+1
				If gMillisecs > gridstarttime+startdelay+4000 Then DrawImage(imgLights, lx, ly, 4); If lightsound < 4 Then PlaySound(snd_Lights1, chn_FX); lightsound:+1
				If gMillisecs > gridstarttime+startdelay+5000 Then DrawImage(imgLights, lx, ly, 5); If lightsound < 5 Then PlaySound(snd_Lights1, chn_FX); lightsound:+1
				If gMillisecs > gridstarttime+startdelay+8000+rnd_racestart Or (gDebugMode And KeyHit(KEY_1))
					lightsound = 0
					
					' Tell clients that lights are done
					If TOnline.netstatus And TOnline.hosting
						TOnline.SendLightsInfo()
					End If
					
					racestatus = CRACESTATUS_RACE
					racestarttime = gMillisecs
					
					' Make sure you can't instantly accelerate from start
					For Local c:TCar = EachIn TCar.list
						Select c.controller
						Case CCONTROLLER_HUMAN
							If QuickRace 
								If ButtonDown(MYKEY_UP) Then c.startaccel:*0.75
							Else
								If ButtonDown(MYKEY_UP) 
									c.startaccel:*(0.5+(gRelFriends/200))
								Else
									c.startaccel:*(0.6+(gRelFriends/250))
								EndIf
							End If
							
						Case CCONTROLLER_CPU
							
							Select OpDifficulty 
							Case 1	c.startaccel:*Rnd(0.7,0.9)
							Case 2	c.startaccel:*Rnd(0.8,1.0)
							Case 3	c.startaccel:*Rnd(0.85,1.0)
							Case 4	c.startaccel:*Rnd(0.95,1.0)
							End Select
								
						End Select
					Next
					
				EndIf
				
				DrawGridControls()
			Case CRACESTATUS_RACE
				If lightsalpha > 0 
					SetAlpha(lightsalpha)
					DrawImage(imgLights, lx, ly, 0)
				EndIf
			End Select
		Case CTRACKMODE_PITSTOP
			Local car:TCar = TCar.SelectHumanCar()
			If Not car Then Return
			
			Local c:Float = (MilliSecs()/2) Mod 255
			Local px:Int = (screenW/2)-200 
			Local py:Int = (screenH/2)-255 
			
			If track.racestatus = CRACESTATUS_GRID
				DrawRacePanel(px,py,400,510,164,164,164,1.0)
			Else
				DrawRacePanel(px,py,400,510,164,164,164,0.8)
			EndIf
			
			SetAlpha(1)
			Local str:String = GetLocaleText("Pit Stop")
			If track.racestatus = CRACESTATUS_GRID 
				str = GetLocaleText("Car Set Up")
				If TOnline.netstatus
					Select TOnline.chk_Online_Quali.GetState()
					Case False	str:+" - "+GetLocaleText("Race")
					Case True	str:+" - "+GetLocaleText("Qualifying")
					End Select
				End If
			EndIf
		'	SetColor(0,0,0)
		'	fnt_Medium.Draw(str, (screenW/2)-1, py+11-fntoffset_Medium,1)
			SetColor(255,255,0)
			fnt_Medium.Draw(str, (screenW/2), py+10-fntoffset_Medium,1)
			
			If pitstop_op = 1
				SetColor(255,0,0)
				DrawRacePanel(px+20, py+45, 360, 80, 128, 128, c, 1)
			End If
			
			' Fuel
			If OpFuel SetAlpha(1) Else SetAlpha(0.25)
			SetColor(255,255,255)
			str = GetLocaleText("Fuel")
			fnt_Medium.Draw(str, (screenW/2), py+50-fntoffset_Medium,1)
			
			SetColor(0,0,0)
			DrawRect(px+40, py+80, 320, 30)
			
			SetColor(150,250,80)
			Local f:Float = (316.0/100.0)*car.fuel
			DrawRect(px+42, py+82, f, 26)
			
			SetAlpha(0.5)
			f = (316.0/100.0)*pitstop_fuel
			DrawRect(px+42, py+82, f, 26)
			
			SetAlpha(1)
			SetColor(255,255,255)
			str = Int(pitstop_fuel)+"%"
			fnt_Medium.Draw(str, (screenW/2), py+85-fntoffset_Medium,1)
			
			' Tyres
			SetColor(255,0,0)
				
			Local tc:Float = c
			Local ta:Float = 1
			If pitstop_op <> 2 Then tc = 255; ta = 0.5
			
			Select pitstop_tyre
			Case 1	DrawRacePanel((screenW/2)-180, py+175, 90, 90, 128, 128, tc, ta)
			Case 2	DrawRacePanel((screenW/2)-90, py+175, 90, 90, 128, 128, tc, ta)
			Case 3	DrawRacePanel((screenW/2), py+175, 90, 90, 128, 128, tc, ta)
			Case 4	DrawRacePanel((screenW/2)+90, py+175, 90, 90, 128, 128, tc, ta)
			End Select
			
			SetAlpha(1)
			SetColor(255,255,255)
			str = GetLocaleText("Tyres")
			fnt_Medium.Draw(str, (screenW/2), py+140-fntoffset_Medium,1)
			
			str = GetLocaleText("Current")
			fnt_Medium.Draw(str, (screenW/2)-135, py+180-fntoffset_Medium,1)
			
			Select car.tyretype
			Case CTYRE_HARD		DrawImage(img_TyreHard, (screenW/2)-135-ImageWidth(img_TyreHard)/2, py+210)
			Case CTYRE_SOFT		DrawImage(img_TyreSoft, (screenW/2)-135-ImageWidth(img_TyreSoft)/2, py+210)
			Case CTYRE_WET		DrawImage(img_TyreWet, (screenW/2)-135-ImageWidth(img_TyreWet)/2, py+210)
			End Select
			
			str = GetLocaleText("tyre_Hard")
			fnt_Medium.Draw(str, (screenW/2)-45, py+180-fntoffset_Medium,1)
			DrawImage(img_TyreHard, (screenW/2)-45-ImageWidth(img_TyreHard)/2, py+210)
			
			str = GetLocaleText("tyre_Soft")
			fnt_Medium.Draw(str, (screenW/2)+45, py+180-fntoffset_Medium,1)
			DrawImage(img_TyreSoft, (screenW/2)+45-ImageWidth(img_TyreSoft)/2, py+210)
			
			str = GetLocaleText("tyre_Wet")
			fnt_Medium.Draw(str, (screenW/2)+135, py+180-fntoffset_Medium,1)
			DrawImage(img_TyreWet, (screenW/2)+135-ImageWidth(img_TyreWet)/2, py+210)
			
			SetColor(0,0,0)
			DrawRect((screenW/2)-175, py+234, 80, 16)
			DrawRect((screenW/2)-85, py+234, 80, 16)
			DrawRect((screenW/2)+5, py+234, 80, 16)
			DrawRect((screenW/2)+95, py+234, 80, 16)
			
			SetColor(255,255,255)
			DrawImage(img_TyreTread, (screenW/2)-174, py+235)
			DrawImage(img_TyreTread, (screenW/2)-84, py+235)
			DrawImage(img_TyreTread, (screenW/2)+6, py+235)
			DrawImage(img_TyreTread, (screenW/2)+96, py+235)
			
			SetColor(0,0,0)
			Local t:Float = (78.0/100.0)*(100-car.tyrewear)
			DrawRect((screenW/2)-175+79-t, py+235, t, 14)
			
			' KERS
			If OpKers SetAlpha(1) Else SetAlpha(0.25)
			SetColor(255,255,255)
			str = GetLocaleText("KERS")+" ("+GetLocaleText("Boost")+")"
			fnt_Medium.Draw(str, (screenW/2), py+280-fntoffset_Medium,1)
			
			tc = c
			ta = 1
			If pitstop_op <> 3 Then tc = 255; ta = 0.5
			
			Select pitstop_kers
			Case 0	DrawRacePanel((screenW/2)-100-80, py+315, 160, 90, 128, 128, tc, ta)
			Case 1	DrawRacePanel((screenW/2)+100-80, py+315, 160, 90, 128, 128, tc, ta)
			End Select
			
			If OpKers SetAlpha(1) Else SetAlpha(0.25)
			SetColor(64,64,64)
			str = GetLocaleText("Not Fitted")
			fnt_Medium.Draw(str, (screenW/2)-100, py+320-fntoffset_Medium,1)
			DrawImage(img_Kers, (screenW/2)-100, py+370)
			
			SetColor(255,255,255)
			str = GetLocaleText("Fitted")
			fnt_Medium.Draw(str, (screenW/2)+100, py+320-fntoffset_Medium,1)
			DrawImage(img_Kers, (screenW/2)+100, py+370)
			
			' CONTINUE
			If pitstop_op = 4
				SetColor(255,0,0)
				DrawRacePanel((screenW/2)-100-80, py+415, 160, 75, 128, 128, c, 1)
			End If
			
			SetAlpha(1)
			SetColor(255,255,255)
			str = GetLocaleText("Paused")
			fnt_Medium.Draw(str, (screenW/2)-100, py+440-fntoffset_Medium,1)
			
			str = GetLocaleText("Continue")
			fnt_Medium.Draw(str, (screenW/2)+100, py+440-fntoffset_Medium,1)
			
			' Pitstop Controls
			DrawRacePanel(20,15,200,100,164,164,164,OpPanelAlpha)
					
			Local tx:Int = 30
			Local ty:Int = 10-fntoffset_Small
			str = GetLocaleText("Pit Stop")+" "+GetLocaleText("Controls")
		'	SetColor(0,0,0)
		'	fnt_Small.Draw(str, 125,ty,1)
			SetColor(255,255,0)
			fnt_Small.Draw(str, 1+125,-1+ty,1); ty:+20
			
			str = GetLocaleText("Up")+": "+GetButtonLabel(MYKEY_UP)
		'	SetColor(0,0,0)
		'	fnt_Small.Draw(str, tx,ty)
			SetColor(255,255,255)
			fnt_Small.Draw(str, 1+tx,-1+ty); ty:+16
			
			str = GetLocaleText("Down")+": "+GetButtonLabel(MYKEY_DOWN)
		'	SetColor(0,0,0)
		'	fnt_Small.Draw(str, tx,ty)
			SetColor(255,255,255)
			fnt_Small.Draw(str, 1+tx,-1+ty); ty:+16
			
			str = GetLocaleText("Left")+": "+GetButtonLabel(MYKEY_LEFT)
		'	SetColor(0,0,0)
		'	fnt_Small.Draw(str, tx,ty)
			SetColor(255,255,255)
			fnt_Small.Draw(str, 1+tx,-1+ty); ty:+16
			
			str = GetLocaleText("Right")+": "+GetButtonLabel(MYKEY_RIGHT)
		'	SetColor(0,0,0)
		'	fnt_Small.Draw(str, tx,ty)
			SetColor(255,255,255)
			fnt_Small.Draw(str, 1+tx,-1+ty); ty:+16
		EndSelect
	End Method
	
	Method DrawGridControls()
			DrawRacePanel(10,15,220,147,164,164,164,OpPanelAlpha)
					
			Local tx:Int = 20
			Local ty:Int = 10-fntoffset_Small
			Local str:String = GetLocaleText("Controls")
		'	SetColor(0,0,0)
		'	fnt_Small.Draw(str, 110,ty,1)
			SetColor(255,255,0)
			fnt_Small.Draw(str, 120, ty, 1); ty:+20
			
			str = GetLocaleText("Accelerate")+": "+GetButtonLabel(MYKEY_UP)
		'	SetColor(0,0,0)
		'	fnt_Small.Draw(str, tx,ty)
			SetColor(255,255,255)
			fnt_Small.Draw(str, 1+tx,-1+ty); ty:+16
			
			str = GetLocaleText("Brake")+": "+GetButtonLabel(MYKEY_DOWN)
		'	SetColor(0,0,0)
		'	fnt_Small.Draw(str, tx,ty)
			SetColor(255,255,255)
			fnt_Small.Draw(str, 1+tx,-1+ty); ty:+16
			
			str = GetLocaleText("Left")+": "+GetButtonLabel(MYKEY_LEFT)
		'	SetColor(0,0,0)
		'	fnt_Small.Draw(str, tx,ty)
			SetColor(255,255,255)
			fnt_Small.Draw(str, 1+tx,-1+ty); ty:+16
			
			str = GetLocaleText("Right")+": "+GetButtonLabel(MYKEY_RIGHT)
		'	SetColor(0,0,0)
		'	fnt_Small.Draw(str, tx,ty)
			SetColor(255,255,255)
			fnt_Small.Draw(str, 1+tx,-1+ty); ty:+16
			
			str = GetLocaleText("Boost")+": "+GetButtonLabel(MYKEY_KERS)
		'	SetColor(0,0,0)
		'	fnt_Small.Draw(str, tx,ty)
			SetColor(255,255,255)
			fnt_Small.Draw(str, 1+tx,-1+ty); ty:+16
			
			str = GetLocaleText("Info")+": "+GetButtonLabel(MYKEY_INFO)
		'	SetColor(0,0,0)
		'	fnt_Small.Draw(str, tx,ty)
			SetColor(255,255,255)
			fnt_Small.Draw(str, 1+tx,-1+ty); ty:+16
			
			str = GetLocaleText("Pause")+": "+GetButtonLabel(MYKEY_PAUSE)
		'	SetColor(0,0,0)
		'	fnt_Small.Draw(str, tx,ty)
			SetColor(255,255,255)
			fnt_Small.Draw(str, 1+tx,-1+ty); ty:+16
	End Method
	
	Method DrawReplayInfo()
		Local repcar:TCar = TCar.SelectReplayCar()
		If Not repcar.link_CurrentFrame Then Return
		
		DrawRacePanel((screenW/2)-120,15,240,60,164,164,164,OpPanelAlpha)
		
		Local pos:Int = TReplayFrame(repcar.link_CurrentFrame.Value()).pos
		Local lap:Int = TReplayFrame(repcar.link_CurrentFrame.Value()).lap
		Local str:String
		
		Select pos
		Case 1	str = "1st"
		Case 2	str = "2nd"
		Case 3	str = "3rd"
		Default	str = String(pos)+"th"
		EndSelect
		
		Local ty:Int = 32
		fnt_Medium.Draw(repcar.mydriver.name, (screenW/2),ty,1); ty:+24
		fnt_Medium.Draw(str, (screenW/2)-50,ty,1)
		
		str = GetLocaleText("Lap")+": "+lap
		fnt_Medium.Draw(str, (screenW/2)+50,ty,1); ty:+24
		
		' Replay Controls
		DrawRacePanel(10,15,240,175,164,164,164,OpPanelAlpha)
				
		Local tx:Int = 20
		ty = 10-fntoffset_Small
		str = GetLocaleText("replay_SlowMo")+": "+GetButtonLabel(MYKEY_KERS)
		fnt_Small.Draw(str, tx,ty); ty:+16
		
		str = GetLocaleText("replay_Rewind")+": "+GetButtonLabel(MYKEY_LEFT)
		fnt_Small.Draw(str, tx,ty); ty:+16
		
		str = GetLocaleText("replay_Forward")+": "+GetButtonLabel(MYKEY_RIGHT)
		fnt_Small.Draw(str, tx,ty); ty:+16
		
		str = GetLocaleText("replay_CarAhead")+": "+GetButtonLabel(MYKEY_UP)
		fnt_Small.Draw(str, tx,ty); ty:+16
		
		str = GetLocaleText("replay_CarBehind")+": "+GetButtonLabel(MYKEY_DOWN)
		fnt_Small.Draw(str, tx,ty); ty:+16
		
		str = GetLocaleText("replay_NextLap")+": "+GetLocaleText("key_PageUp")
		fnt_Small.Draw(str, tx,ty); ty:+16
		
		str = GetLocaleText("replay_PreviousLap")+": "+GetLocaleText("key_PageDown")
		fnt_Small.Draw(str, tx,ty); ty:+16
		
		str = GetLocaleText("replay_ReplayStart")+": "+GetLocaleText("key_Home")
		fnt_Small.Draw(str, tx,ty); ty:+16
		
		str = GetLocaleText("replay_ReplayEnd")+": "+GetLocaleText("key_End")
		fnt_Small.Draw(str, tx,ty); ty:+16

		If track.racestatus = CRACESTATUS_RACE
			str = GetLocaleText("replay_Save")+": "+GetLocaleText("key_F1")
			fnt_Small.Draw(str, tx,ty); ty:+16
		EndIf
	End Method
	
	Method DrawMiniMap()
		If Not OpMap Then Return
		
		' Find current mouse position on large map
		Local msx:Int = Abs(originx)+MouseX()
		Local msy:Int = Abs(originy)+MouseY()
		Local tilex:Int = msx / tilesize
		Local tiley:Int = msy / tilesize
		
		' Track level
		For Local tx:Int = 0 To trackw-1
		For Local ty:Int = 0 To trackh-1
			Local id:Int = tile_level[1,tx,ty].id 
			
			If id > -1
				SetAlpha(0.2)
				SetScale(1,1)
				SetColor(255,255,255)
				
				If mode = CTRACKMODE_EDIT And tx = tilex And ty = tiley Then SetColor(255,255,0)
			
				' Set up image
				Local rot:Int = tile_level[1,tx,ty].rotation
				Local img:TImage = tileset.tracktile_array[id].imgmini
				If Not img Then img = tileset.tracktile_array[0].imgmini
				
				Local posx:Float = mapoffsetx+(tx*16)+(ImageWidth(img)/2)
				Local posy:Float = mapoffsety+(ty*16)+(ImageHeight(img)/2)
					
				MidHandleImage(img)
				SetRotation(rot)
					
				' Draw tile
				DrawImage(img, posx, posy)
				SetImageHandle(img,0,0)
			EndIf
		Next
		Next
		
		TCar.DrawAllMini()
	End Method
		
	Method PlaceTile()
		Local w:Int
		Local h:Int
		
		Local msx:Int = Abs(originx)+MouseX()
		Local msy:Int = Abs(originy)+MouseY()
			
		Local tilex:Int = msx / tilesize
		Local tiley:Int = msy / tilesize
		
		If tileset.selectedtile < 0 Or KeyDown(KEY_LCONTROL)
			DeleteTile(tilex, tiley)
			Return
		End If
		
		' Get width and height of tile
		Select editlevel
		Case 1
			w = tileset.basetile_array[tileset.selectedtile].img.width / tilesize
		 	h = tileset.basetile_array[tileset.selectedtile].img.height / tilesize
			AppLog "PLACE EditLevel 1 W:"+w+" H:"+h+" id:"+tileset.selectedtile
		Case 2
			w = tileset.tracktile_array[tileset.selectedtile].img.width / tilesize
		 	h = tileset.tracktile_array[tileset.selectedtile].img.height / tilesize
			AppLog "PLACE EditLevel 2 W:"+w+" H:"+h+" id:"+tileset.selectedtile
		End Select
		
		If w < 1 Then w = 1
		If h < 1 Then h = 1
		
		' Delete tiles being replaced
		For Local tx:Int = tilex To tilex+w-1
		For Local ty:Int = tiley To tiley+h-1
			DeleteTile(tx, ty)
		Next
		Next		
		
		' Hold shift+a to cover base with same tile
		If (editlevel = 1 And KeyDown(KEY_A) And KeyDown(KEY_LSHIFT)) 
			For Local tx:Int = 0 To trackw-1
			For Local ty:Int = 0 To trackh-1
				tile_level[editlevel-1, tx, ty].id = tileset.selectedtile
				tile_level[editlevel-1, tx, ty].rotation = currentrot
				tile_level[editlevel-1, tx, ty].parentx = -1
				tile_level[editlevel-1, tx, ty].parenty = -1
			Next
			Next
			
			Return
		EndIf
		
		' Place new tile(s)
		For Local tx:Int = tilex To tilex+w-1
		For Local ty:Int = tiley To tiley+h-1
			If (tx = tilex And ty = tiley)
				tile_level[editlevel-1, tilex, tiley].id = tileset.selectedtile
				tile_level[editlevel-1, tilex, tiley].rotation = currentrot
			Else
				tile_level[editlevel-1, tx, ty].id = -1
				tile_level[editlevel-1, tx, ty].rotation = 0
				tile_level[editlevel-1, tx, ty].parentx = tilex
				tile_level[editlevel-1, tx, ty].parenty = tiley
			EndIf	
		Next
		Next
	End Method
	
	Method DeleteTile(x:Int, y:Int)
		If x < 0 Or y < 0 Then Return
		If x > trackw Or y > trackh Then Return
		
		' Get width and height of tile
		Local w:Int = mastertilesize / tilesize
		Local h:Int = mastertilesize / tilesize
		AppLog "W:"+w+" H:"+h
		
		Local id:Int = tile_level[editlevel-1, x, y].id
		If id > -1
		
			Select editlevel
			Case 1
				w = tileset.basetile_array[id].img.width / tilesize
		 		h = tileset.basetile_array[id].img.height / tilesize
			Case 2
				w = tileset.tracktile_array[id].img.width / tilesize
		 		h = tileset.tracktile_array[id].img.height / tilesize
			End Select
			
		EndIf
		
		For Local tx:Int = x To x+w-1
		For Local ty:Int = y To y+h-1
			AppLog "Deleting Tile: "+tx+","+ty
			
			' If tile being erased has a parent then delete the parent
			If tile_level[editlevel-1, tx, ty].parentx > -1 Or tile_level[editlevel-1, tx, ty].parenty > -1
				AppLog "Delete parent"
				DeleteTile(tile_level[editlevel-1, tx, ty].parentx, tile_level[editlevel-1, tx, ty].parenty)
			EndIf
			
			tile_level[editlevel-1, tx, ty].id = -1
			tile_level[editlevel-1, tx, ty].rotation = 0
			tile_level[editlevel-1, tx, ty].parentx = -1
			tile_level[editlevel-1, tx, ty].parenty = -1
		Next
		Next
	End Method
	
	Method PlaceWayPoint(lst:TList)
		If KeyDown(KEY_LCONTROL)
			Local nearestwp:TWayPoint = GetNearestWaypoint(MouseX(), MouseY(), lst)
			
			If nearestwp
				nearestwp.x = Abs(originx)+MouseX()
				nearestwp.y = Abs(originy)+MouseY()
			End If
		Else
			Local wid:Int = lst.Count()+1
			If KeyDown(KEY_LSHIFT) Then wid = 0
			
			lst.AddLast(TWayPoint.Create(wid, Abs(originx)+MouseX(), Abs(originy)+MouseY()))
		End If
		
	End Method
	
	Method DeleteWayPoint(lst:TList)
		If lst.Count() > 0
			lst.RemoveLast()
		End If
	End Method
	
	Method GetNearestWaypoint:TWayPoint(x:Int, y:Int, lst:TList, addorigin:Int = True)
		Local nearestwp:TWayPoint
		Local nearestwpdist:Float = 99999999
		
		Local ox:Float = Abs(originx)
		Local oy:Float = Abs(originy)
		If Not addorigin Then ox = 0; oy = 0
		
		For Local wp:TWayPoint = EachIn lst
			Local dist:Float = GetDistance(wp.x, wp.y, ox+x, oy+y)
			
			If dist < nearestwpdist
				nearestwpdist = dist
				nearestwp = wp
			EndIf
		Next
		
		Return nearestwp
	End Method
	
	Method GetNearestWayLineXY(x:Int, y:Int, wx:Int Var, wy:Int Var, addorigin:Int = True)
		Local nearestwldist:Float = 99999999
		
		Local ox:Float = Abs(originx)
		Local oy:Float = Abs(originy)
		If Not addorigin Then ox = 0; oy = 0
		
		For Local wl:TWayLine = EachIn l_waylines
			Local dist1:Float = GetDistance(ox+x, oy+y, wl.x1, wl.y1)
			
			If dist1 < nearestwldist
				nearestwldist = dist1
				wx = wl.x1
				wy = wl.y1
			EndIf
			
			Local dist2:Float = GetDistance(ox+x, oy+y, wl.x2, wl.y2)
			
			If dist2 < nearestwldist
				nearestwldist = dist2
				wx = wl.x2
				wy = wl.y2
			EndIf
		Next
	End Method
	
	Method MoveNearestWayLineXY(x:Int, y:Int)
		Local nearestwldist:Float = 99999999
		Local nearestid:Int = 0
		Local point:Int = 0
		
		Local ox:Float = Abs(originx)
		Local oy:Float = Abs(originy)
		
		For Local wl:TWayLine = EachIn l_waylines
			Local dist1:Float = GetDistance(ox+x, oy+y, wl.x1, wl.y1)
			
			If dist1 < nearestwldist
				nearestwldist = dist1
				nearestid = wl.id
				point = 1
			EndIf
			
			Local dist2:Float = GetDistance(ox+x, oy+y, wl.x2, wl.y2)
			
			If dist2 < nearestwldist
				nearestwldist = dist2
				nearestid = wl.id
				point = 2
			EndIf
		Next
		
		For Local wl:TWayLine = EachIn l_waylines
			If wl.id = nearestid
				Select point
				Case 1	
					wl.x1 = ox+x
					wl.y1 = oy+y
				Case 2
					wl.x2 = ox+x
					wl.y2 = oy+y 
				End Select
			End If
		Next
	End Method
	
	Method PlaceWayline()
		If KeyDown(KEY_LCONTROL)
			MoveNearestWayLineXY(MouseX(), MouseY())
		Else
			' Create first way line if needed
			If l_waylines.Count() = 0
				l_waylines.AddLast(TWayLine.Create(1, Abs(originx)+MouseX(), Abs(originy)+MouseY()))
				Return
			End If
			
			' Add new way line or finish current way line off
			Local count:Int = 2
			For Local wl:TWayLine = EachIn l_waylines
				If count > l_waylines.Count() 
					If wl.x2 > -1
						l_waylines.AddLast(TWayLine.Create(count, Abs(originx)+MouseX(), Abs(originy)+MouseY()))
						Return
					Else
						wl.x2 = Abs(originx)+MouseX()
						wl.y2 = Abs(originy)+MouseY()
					EndIf
				EndIf
				
				count:+1
			Next
		EndIf
	End Method
	
	Method DeleteWayline()
		If l_waylines.Count() > 0
			l_waylines.RemoveLast()
		End If
	End Method
	
	Method SaveTrack(name:String)
		Local file:TStream = WriteFile(gSaveloc + "Tracks/"+name+".trk")
		
		For Local lev:Int = 0 To 1
			For Local tx:Int = 0 To trackw-1
			For Local ty:Int = 0 To trackh-1
				WriteInt(file, tile_level[lev,tx,ty].id)
				WriteInt(file, tile_level[lev,tx,ty].rotation)
				WriteInt(file, tile_level[lev,tx,ty].parentx)
				WriteInt(file, tile_level[lev,tx,ty].parenty)
			Next
			Next
		Next
		
		For Local ob:TTileData = EachIn l_objects
			WriteInt(file, COBJECT)
			WriteInt(file, ob.id)
			WriteInt(file, ob.rotation)
			WriteInt(file, ob.parentx)
			WriteInt(file, ob.parenty)
		Next
		
		For Local wl:TWayLine = EachIn l_waylines
			WriteInt(file, CWAYLINE)
			WriteInt(file, wl.id)
			WriteInt(file, wl.x1)
			WriteInt(file, wl.y1)
			WriteInt(file, wl.x2)
			WriteInt(file, wl.y2)
		Next
		
		For Local wp:TWayPoint = EachIn l_waypoints
			WriteInt(file, CWAYPOINT)
			WriteInt(file, wp.id)
			WriteInt(file, wp.x)
			WriteInt(file, wp.y)
		Next
		
		For Local wp:TWayPoint = EachIn l_pitwaypoints
			WriteInt(file, CPITWAYPOINT)
			WriteInt(file, wp.id)
			WriteInt(file, wp.x)
			WriteInt(file, wp.y)
		Next
		
		For Local wp:TWayPoint = EachIn l_wallpoints
			WriteInt(file, CWALLPOINT)
			WriteInt(file, wp.id)
			WriteInt(file, wp.x)
			WriteInt(file, wp.y)
		Next
		
		CloseStream file
	End Method
	
	Method LoadTrack(nm:String, tid:Int = 0)
		id = tid
		
		If nm = "" 
			name = "Track_"+id
		Else
			name = nm
			
			Select name
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
			Case "20_India"				id = 20
			End Select
		EndIf
		
		Local file:TStream
		
		If gQuickRace
			AppLog "LoadTrack:"+gSaveloc+"Tracks/"+name+".trk"
			file = ReadFile(gSaveloc+"Tracks/"+name+".trk")
			If Not file Then file = ReadFile("incbin::Inc/"+name+".trk")
			If Not file Then file = ReadFile(gModLoc+"Media/Tracks/"+name+".trk")
		Else
			If gModLoc <> ""
				file = ReadFile(gModLoc+"Media/Tracks/"+name+".trk")
				If Not file Then file = ReadFile("incbin::Inc/"+name+".trk")
				If Not file Then file = ReadFile(gSaveloc+"Media/Tracks/"+name+".trk")
			Else
				file = ReadFile("incbin::Inc/"+name+".trk")
			End If
		End If
		
		If Not file Then DoMessage("CMESSAGE_TRACKDOESNOTEXIST",,name); End
			
		For Local lev:Int = 0 To 1
			For Local tx:Int = 0 To trackw-1
			For Local ty:Int = 0 To trackh-1
				tile_level[lev,tx,ty].id = ReadInt(file)
				'If lev = 0 then tile_level[lev,tx,ty].id = 0	' Remove base tiles
				tile_level[lev,tx,ty].rotation = ReadInt(file)
				tile_level[lev,tx,ty].parentx = ReadInt(file)
				tile_level[lev,tx,ty].parenty = ReadInt(file)
			Next
			Next
		Next
		
		l_objects.Clear()
		l_waylines.Clear()
		l_waypoints.Clear()
		l_pitwaypoints.Clear()
		l_wallpoints.Clear()
		
		While Not Eof(file)
			Select ReadInt(file)
			Case COBJECT
				Local newob:TTileData = New TTileData
				newob.id = ReadInt(file)
				newob.rotation = ReadInt(file)
				newob.parentx = ReadInt(file)
				newob.parenty = ReadInt(file)
				
				If newob.id > -1
					l_objects.AddLast(newob)
				EndIf
				
			Case CWAYLINE
				Local newwl:TWayLine = New TWayLine
				newwl.id = ReadInt(file)
				newwl.x1 = ReadInt(file)
				newwl.y1 = ReadInt(file)
				newwl.x2 = ReadInt(file)
				newwl.y2 = ReadInt(file)
				l_waylines.AddLast(newwl)
				
			Case CWAYPOINT
				Local newwp:TWayPoint = New TWayPoint
				newwp.id = ReadInt(file)
				newwp.x = ReadInt(file)
				newwp.y = ReadInt(file)
				l_waypoints.AddLast(newwp)
			
			Case CPITWAYPOINT
				Local newwp:TWayPoint = New TWayPoint
				newwp.id = ReadInt(file)
				newwp.x = ReadInt(file)
				newwp.y = ReadInt(file)
				l_pitwaypoints.AddLast(newwp)
				
			Case CWALLPOINT
				Local newwp:TWayPoint = New TWayPoint
				newwp.id = ReadInt(file)
				newwp.x = ReadInt(file)
				newwp.y = ReadInt(file)
				l_wallpoints.AddLast(newwp)
			
			End Select
		Wend
		
		CloseStream file
		
		AppLog "TrackId:"+tid
		
		laprecord = GetDatabaseInt("laprecord", "track", id)
		lapholder = GetDatabaseInt("lapholder", "track", id)
		playerlaprecord = GetDatabaseInt("playerlaprecord", "track", id)
		If playerlaprecord > 0
			playerlaprecord:-TDriver.GetDriverById(gMyDriverId).dob
			playerlaprecord:/id+1
		EndIf
		
		If playerlaprecord < 20000
			playerlaprecord = 0
		End If
		
		If TOnline.netstatus <> CNETWORK_NONE
			laprecord = 0
			lapholder = 0
			playerlaprecord = 0
		EndIf
					
		' Set session start time (racestart time resets after lights go out)
		racestarttime = gMillisecs 
		gridstarttime = 0
		
		' Set the random lights out time
		rnd_racestart = Rand(2000)
		If TOnline.netstatus <> CNETWORK_NONE Then rnd_racestart = Rand(1250)
		
		' Reset weather
		If TOnline.netstatus = CNETWORK_NONE
			weather.SetUpWeather(GetDatabaseInt("climate", "track", id))
		EndIf
	
		' Put correct tyres on
		TCar.SetTyresAll()
		
		' After loading track put the cars in position
		TCar.ResetStartingPositions()
		
		mapoffsetx = -1
		mapoffsety = -1
		
		' Find offset position of mini map
		For Local tx:Int = 0 To trackw-1
		For Local ty:Int = 0 To trackh-1
			If tile_level[1,tx,ty].id > -1 And mapoffsetx = -1 Then mapoffsetx = 10+(tx*-16)
		Next
		Next
		
		For Local ty:Int = 0 To trackh-1
		For Local tx:Int = 0 To trackw-1
			If tile_level[1,tx,ty].id > -1 And mapoffsety = -1 Then mapoffsety = 10+(ty*-16)
		Next
		Next
		
		UpdateTrackScale()
		
		TParticle.ClearAll()
		TScreenMessage.ClearAll()
		
		AppLog "racestarttime: "+racestarttime
	End Method
	
	Method UpdateTrackScale()
		If mode = CTRACKMODE_EDIT Or mode = CTRACKMODE_EDITPAUSED Then scale = 1.0; Return
		
		Select OpView
		Case 1	scale = 1.2
		Case 2	scale = 1.0
		Case 3	scale = 0.8
		Case 4	scale = 0.6
		Case 5	scale = 0.4
		Case 6	scale = 0.2
		End Select
		
		If gDebugMode And KeyDown(KEY_F1) Then scale = 0.2
	End Method
	
	Method GetWayPoint:TWayPoint(id:Int, lst:TList)
		For Local wp:TWayPoint = EachIn lst
			If wp.id >= id Then Return wp
		Next
		
		For Local wp:TWayPoint = EachIn lst
			Return wp
		Next
	End Method
	
	Method GetWayLine:TWayLine(id:Int)
		For Local wl:TWayLine = EachIn l_waylines
			If wl.id >= id Then Return wl
		Next
		
		For Local wl:TWayLine = EachIn l_waylines
			Return wl
		Next
	End Method
	
	Method UpdateRaceInfoTable()
		btn_RaceInfoReplay.gAlpha = 1.0
		If TOnline.netstatus Then btn_RaceInfoReplay.gAlpha = 0.5
		
		Select racestatus
		Case CRACESTATUS_RACE	
			TCar.sortby = CSORT_FINISHTIME
			TCar.list.Sort()
			
			lbl_RaceInfo_Title.SetText(GetLocaleText("Finish"))
			tbl_RaceInfo.ClearItems()
			tbl_RaceInfo.SetColumnHeading(0, GetLocaleText("tla_Position"))
			tbl_RaceInfo.SetColumnHeading(4, GetLocaleText("tla_Points"))
			
			Local sel:Int = 0
			Local pos:Int = 1
			For Local c:TCar = EachIn TCar.list
				Local tm:String = GetStringTime(c.mydriver.lastracetime,,c.mydriver.iwaslapped)
				Local pts:String = String(GetPositionPoints(pos))
				If c.mydriver.lastracetime = 0 Then tm = ""; pts = ""
				
				If TOnline.netstatus And TOnline.chk_Online_Quali.GetState() = True
					pts = ""
				EndIf
				
				tbl_RaceInfo.AddItem([String(pos), c.mydriver.name, TTeam.GetById(c.mydriver.team).name, tm, pts])
					
				c.position = pos
				If c.mydriver.id = gMyDriverId Then sel = pos-1
				pos:+1
			Next
			
			tbl_RaceInfo.SelectItem(sel)
			
		Case CRACESTATUS_PRACTICE
			lbl_RaceInfo_Title.SetText(GetLocaleText("Practice"))
			tbl_RaceInfo.ClearItems()
			tbl_RaceInfo.SetColumnHeading(0, GetLocaleText("Lap"))
			tbl_RaceInfo.SetColumnHeading(4, "")
			
			Local c:TCar =  TCar.SelectHumanCar()
			Local count:Int = 1
			Local sel:Int = -1
			Local bestlap:Int = String(c.mydriver.l_laptimes.First()).ToInt()
			
			For Local laptime:String = EachIn c.mydriver.l_laptimes
				AppLog laptime
				tbl_RaceInfo.AddItem([String(count), c.mydriver.name, TTeam.GetById(c.mydriver.team).name, GetStringTime(laptime.ToInt()), ""])
				If laptime.ToInt() <= bestlap
					bestlap = laptime.ToInt()
					sel = count
				EndIf
				count:+1
			Next
			
			tbl_RaceInfo.SelectItem(sel-1)
			
		Case CRACESTATUS_QUALIFY
			TCar.sortby = CSORT_QUALIFYINGTIME
			TCar.list.Sort()
			
			lbl_RaceInfo_Title.SetText(GetLocaleText("Qualifying"))
			tbl_RaceInfo.ClearItems()
			tbl_RaceInfo.SetColumnHeading(0, GetLocaleText("tla_Position"))
			tbl_RaceInfo.SetColumnHeading(4, "")
			Local sel:Int = 0
			Local pos:Int = 1
			
			For Local c:TCar = EachIn TCar.list
				Local tm:String = GetStringTime(c.bestlaptime)
				If c.bestlaptime = 0 Then tm = ""
				
				tbl_RaceInfo.AddItem([String(pos), c.mydriver.name, TTeam.GetById(c.mydriver.team).name, tm, ""])
				If c.mydriver.id = gMyDriverId Then sel = pos-1
				pos:+1
			Next
			
			tbl_RaceInfo.SelectItem(sel)
		End Select
	End Method
	
	Method GetPositionPoints:Int(pos:Int)
		If pos < 1 Or pos > 24 Then Return 0
		Return pointsaward[pos]
	End Method
End Type

Type TTileSet
	Global selectedtile:Int = 0
	Global tilesperpage:Int
	
	Field basetile_array:TTile[]
	Field tracktile_array:TTile[]
	Field objecttile_array:TTile[]
	Field page:Int = 0
	
	Function Create:TTileSet()
		AppLog "CreateTileSet"		
		Local newtileset:TTileSet = New TTileSet
		
		LoadTiles("Media/Tiles/Base/", newtileset.basetile_array)
		LoadTiles("Media/Tiles/Track/", newtileset.tracktile_array)
		LoadTiles("Media/Tiles/Objects/", newtileset.objecttile_array, False)
		
		Return newtileset 
	End Function
	
	Function LoadTiles(url:String, tileset:TTile[] Var, loadpattern:Int = True)
		AppLog "LoadTiles:"+url
		Local tpp:Int = (screenH/64)-1 
		tilesperpage = tpp
		
		Local tile_files:String[] = LoadDir(gApploc+url)
		Local filename:String
		Local id:Int = 0
		Local y:Int = 64

		tile_files.sort()
		
		For filename:String = EachIn tile_files
			
			If Right(filename,4) = ".png" And filename.Contains("Pat") = False And filename.Contains("Mini") = False 
				' Create new tile
				Local newtile:TTile = New TTile
				
				' Set Id and TileSet position
				newtile.id = id
				newtile.setPosX = screenW-64
				newtile.setPosY = y
				
				' Load image
				newtile.img = LoadMyImage(url+filename)
				newtile.name = filename
				
				' Load pattern and mini map files
				If loadpattern
					Local patname:String = "Pat"+filename
					newtile.imgpat = LoadMyPixmapPNG(url+patname)
					
					Local mininame:String = "Mini"+filename
					newtile.imgmini = LoadMyImage(url+mininame)
				EndIf
						
				' Put tile in TileSet array
				tileset = tileset[..tileset.Length+1]
				tileset[id] = newtile
				
				id:+1
				y:+64
				If (id Mod tilesperpage) = 0 Then y = 64
			EndIf
		Next
		
	End Function
	
	Method Update(level:Int)			
		Local tilearray:TTile[]
		
		Select level
		Case 1	tilearray = basetile_array
		Case 2	tilearray = tracktile_array
		Case 3	tilearray = objecttile_array
		End Select
		
		If MouseX() >= screenW-64 And MouseX() < screenW
			If (MouseY() >= 0 And MouseY() < 64 And MouseHit(1)) Or MouseHit(2)
				page:+1
				If page > tilearray.Length / tilesperpage Then page = 0
			End If
		End If
		
		Local count:Int
		
		For Local t:TTile = EachIn tilearray
			If MouseX() >= t.setPosX And MouseX() < screenW And MouseY() >= t.setPosY And MouseY() < t.setPosY+64
				If MouseHit(1)
					selectedtile = count+(page*tilesperpage)
				EndIf
			EndIf
			
			count:+1
		Next
	End Method
	
	Method DrawTileSetPanel(level:Int)
		ResetDrawing()
		
		Local str:String
		Select level
		Case 1	str = "Base Level"
		Case 2	str = "Track Level"
		Case 3	str = "Objects"
		Case 4	str = "CheckPoints"
		Case 5	str = "Racing Line"
		Case 6	str = "Pit Lane"
		Case 7	str = "Walls"
		End Select
		fnt_Medium.Draw(str, screenW-74, 10-fntoffset_Medium,2)
		
		Local tx:Int = 10
		Local ty:Int = screenH-130-fntoffset_Medium
		
		fnt_Medium.Draw("Escape: Options", tx, ty)
		ty:+20
				
		Select level
		Case 4	
				Local txt:String = "Left Button: Place check point"
				fnt_Medium.Draw(txt, tx, ty)
				
				ty:+20
				txt = "Right Button: Remove check point"
				fnt_Medium.Draw(txt, tx, ty)
				
				ty:+20
				txt = "Ctrl + Left Button: Adjust check point"
				fnt_Medium.Draw(txt, tx, ty)
				
		Case 5	
				Local txt:String = "Left Button: Place way-point"
				fnt_Medium.Draw(txt, tx, ty)
				
				ty:+20
				txt = "Right Button: Remove way-point"
				fnt_Medium.Draw(txt, tx, ty)
				
				ty:+20
				txt = "Ctrl + Left Button: Adjust way-point"
				fnt_Medium.Draw(txt, tx, ty)
		Case 6
				Local txt:String = "Left Button: Place way-point"
				fnt_Medium.Draw(txt, tx, ty)
				
				ty:+20
				txt = "Right Button: Remove way-point"
				fnt_Medium.Draw(txt, tx, ty)
				
				ty:+20
				txt = "Ctrl + Left Button: Adjust way-point"
				fnt_Medium.Draw(txt, tx, ty)
				
		Case 7
				Local txt:String = "Left Button: Place wall point"
				fnt_Medium.Draw(txt, tx, ty)
				
				ty:+20
				txt = "Right Button: Remove wall point"
				fnt_Medium.Draw(txt, tx, ty)
				
				ty:+20
				txt = "Ctrl + Left Button: Adjust wall point"
				fnt_Medium.Draw(txt, tx, ty)
				
				ty:+20
				txt = "Shift + Left Button: Start new wall"
				fnt_Medium.Draw(txt, tx, ty)
				
		Default				
				Local txt:String = "Left Button:Place Tile"
				fnt_Medium.Draw(txt, tx, ty)
				
				ty:+20
				txt = "Right Button: Rotate Tile Right"
				fnt_Medium.Draw(txt, tx, ty)
				
				If level = 3
					ty:+20
					txt = "Shift + Right Button: Rotate Left"
					fnt_Medium.Draw(txt, tx, ty)
				EndIf
			
				ty:+20
				txt = "Ctrl + Left Button: Delete tile"
				fnt_Medium.Draw(txt, tx, ty)
				
				If level = 3
					ty:+20
					txt = "Key 1 - 8: Change Snap-To grid ("+track.obgrid+")"
					fnt_Medium.Draw(txt, tx, ty)
				EndIf
				
		End Select
		
		If MouseX() > screenW-64 And track.editlevel < 4
			SetColor(64,64,64)
			DrawLine(screenW-65, 0, screenW-65, screenH)
			SetAlpha(0.5)
			SetColor(128,128,128)
			DrawRect(screenW-64, 0, 64, screenH)

			ResetDrawing()
			
			Select level
			Case 1	
				fnt_Small.Draw("Page "+String(page+1), screenW-62, 0-fntoffset_Small)
			Case 2	
				fnt_Small.Draw("Page "+String(page+1), screenW-62, 0-fntoffset_Small)
			Case 3	
				fnt_Small.Draw("Page "+String(page+1), screenW-62, 0-fntoffset_Small)
			End Select
			
			
			Local tilearray:TTile[]
			Select level
			Case 1	tilearray = basetile_array
			Case 2	tilearray = tracktile_array
			Case 3	tilearray = objecttile_array
			End Select
			
			Local tilesperpage:Int = (screenH/64)-1 
			Local count:Int = 0
			Local firsttile:Int = page * tilesperpage
			
			For Local t:TTile = EachIn tilearray				
				If count >= firsttile And count < firsttile+tilesperpage
					SetColor(255,255,255)
					SetImageHandle(t.img,0,0)
					DrawImageRect(t.img, t.setPosX, t.setPosY, 64, 64)
					
					If count = selectedtile
						SetColor(255,0,0)
						DrawLine(t.setPosX, t.setPosY, t.setPosX+63, t.setPosY)
						DrawLine(t.setPosX+63, t.setPosY, t.setPosX+63, t.setPosY+63)
						DrawLine(t.setPosX+63, t.setPosY+63, t.setPosX, t.setPosY+63)
						DrawLine(t.setPosX, t.setPosY+63, t.setPosX, t.setPosY)
					EndIf
					
					If MouseX() >= t.setPosX And MouseX() < screenW And MouseY() >= t.setPosY And MouseY() < t.setPosY+64
						SetColor(255,255,0)
						DrawLine(t.setPosX, t.setPosY, t.setPosX+63, t.setPosY)
						DrawLine(t.setPosX+63, t.setPosY, t.setPosX+63, t.setPosY+63)
						DrawLine(t.setPosX+63, t.setPosY+63, t.setPosX, t.setPosY+63)
						DrawLine(t.setPosX, t.setPosY+63, t.setPosX, t.setPosY)
					EndIf
				EndIf
				
				count:+1
			Next
		EndIf
		
		SetAlpha(1)
		SetColor(255,255,255)
	End Method
End Type

Type TTile
	Field id:Int
	Field name:String
	Field img:TImage
	Field imgmini:TImage
	Field imgpat:TPixmap
	Field setPosX:Int = 0
	Field setPosY:Int = 0	
End Type

Type TTileData
	Field id:Int = -1
	Field rotation:Int = 0
	Field parentx:Int = -1
	Field parenty:Int = -1	
End Type

Type TWayPoint
	Field id:Int = 0
	Field x:Int = -1
	Field y:Int = -1
	
	Function Create:TWayPoint(id:Int, x:Int, y:Int)
		Local newwp:TWayPoint = New TWayPoint
		newwp.id = id
		newwp.x = x
		newwp.y = y
		Return(newwp)
	End Function
	
	Method Compare:Int(O:Object)
		If TWayPoint(O).id < id Return 1 Else Return -1
	EndMethod

End Type

Type TWayLine
	Field id:Int = 0
	Field x1:Int = -1
	Field y1:Int = -1
	Field x2:Int = -1
	Field y2:Int = -1
	
	Function Create:TWayLine(id:Int, x:Int, y:Int)
		Local newwl:TWayLine = New TWayLine
		newwl.id = id
		newwl.x1 = x
		newwl.y1 = y
		Return(newwl)
	End Function
	
	Method Compare:Int(O:Object)
		If TWayLine(O).id < id Return 1 Else Return -1
	EndMethod
End Type

Type TInterceptPoint
	Field x#				' Point of interception
	Field y#
	Field intercept_AB#		' Position of interception on AB line
	Field intercept_CD#		' Position of interception on CD line
	Field intercept:Int		' Interception true or false
End Type

Type TRaceReport
	Global list:TList
	
	Field name:String
	Field lap:Int
	Field time:Int
	Field tyretype:String
	Field iwaslapped:Int
	Field timestamp:Int
	
	Method New()
		If Not list Then list = CreateList()
		list.AddLast(Self)
	End Method
	
	Function AddLap(racetime:Int, nm:String, l:Int, t:Int, tyr:String = "", lpd:Int = 0)
		Local r:TRaceReport = New TRaceReport
		r.name = nm
		r.lap = l
		r.time = t
		r.tyretype = tyr
		r.iwaslapped = lpd
		r.timestamp = racetime
	End Function
	
	Function SaveReport()
		If Not list Then Return
		
		list.Sort()
		
		Local reportfile:TStream = WriteFile(gSaveloc+"Replays/"+track.name+"_"+CurrentDate().Replace(" ", "_")+".csv")
		If Not reportfile Then Return
		
		WriteLine(reportfile, "Driver,Lap,Time,Tyre,Timestamp")
		
		Local donefinish:Int = False
		
		For Local r:TRaceReport = EachIn list
			If r.lap = 9999
				If Not donefinish Then WriteLine(reportfile, "Finish Times"); donefinish = True
				
				If r.iwaslapped > 0
					WriteLine(reportfile, r.name+",,"+GetStringTime(r.time)+",+"+String(r.iwaslapped)+","+GetStringTime(r.timestamp))
				Else
					WriteLine(reportfile, r.name+",,"+GetStringTime(r.time)+",,"+GetStringTime(r.timestamp))
				End If
				
			Else
				WriteLine(reportfile, r.name+","+r.lap+","+GetStringTime(r.time)+","+r.tyretype+","+GetStringTime(r.timestamp))
			End If
		Next
		
		CloseStream(reportfile)
		list.Clear()
	End Function
	
	Method Compare:Int(O:Object)
		' Check laps
		If TRaceReport(O).lap > lap Then Return -1 
		If TRaceReport(O).lap < lap Then Return 1
	
		' Check lapped
		If TRaceReport(O).iwaslapped > iwaslapped Then Return -1 
		If TRaceReport(O).iwaslapped < iwaslapped Then Return 1
		
		' Check times
		If TRaceReport(O).time > time Then Return -1 
		If TRaceReport(O).time < time Then Return 1
	
		Return Super.Compare(O)
	EndMethod
End Type