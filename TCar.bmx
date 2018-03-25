Type TCar
	Global list:TList
	Global sortby:Int
	Global folder:String	' Where to load images etc
	
	' Networking
	Field lastsendcar:Int = 0
	Field lastsendcarinfo:Int = 0
	
	' Main
	Field randno:Int
	Field l_particles:TList = CreateList()
	Field l_blur:TList = CreateList()
	Field lastparticle:Int	' Record time it was created
	Field lastblur:Int
	
	Field controller:Int = CCONTROLLER_CPU
	Field mydriver:TDriver
	Field sportsname:String
	
	Field lapstartdamage:Float = 0.0
	Field damage:Float = 0.0
	Field fuel:Float
	Field fuellastlap:Float 
	Field fuelconsumption:Float 
	Field tyretype:Int
	Field tyrewear:Float = 0.0
	Field kers:Float = 0			' Amount of kers charge left
		
	Field gassing:Int
	Field steering:Int
	Field boost:Int
	Field pitting:Int = False
	Field pitstop:Int
	Field lastpitstop:Int = -100000
	Field pittimedisplay:Int = -100000
	Field position:Int
	Field pittime:Int
	Field minimumpit:Int			' Minimum pit times depend on tyre change
	Field lastwallcollision:Int
	Field qualifyorder:Int
	Field slipstream:Float 
	Field nocollision:Int
	
	Field strpittime:String
	Global str_Gear:String
	Global str_Throttle:String
	Global str_Brake:String
	Global str_Kers:String
	Global str_LapTimeText:String
	Global str_BestLapText:String
	Global str_LastLapText:String
	Global str_RecordText:String
	Global str_PositionText:String
	Global str_LapText:String
	
	Field colr:Int
	Field colg:Int
	Field colb:Int
	
	' Main car variables
	Field img:TImage
	Field x:Float = 100
	Field y:Float = 100
	Field oldx:Float = 100
	Field oldy:Float = 100
	
	Field xvel:Float
	Field yvel:Float
	
	Field speed# = 0
	Field drift# = 0
	Field steer# = 0
	Field direction# = 0
	Field olddirection# = 0
	Field terrain:Int = 0
	Field oldterrain:Int = 0
	
	' Replays
	Field l_ReplayFrames:TList
	Field link_CurrentFrame:TLink
	Global replaycarid:Int
	
	' Ghost car variable
	Field gsteer:Float
	Field gx:Float = 100
	Field gy:Float = 100
	Field oldgx:Float = 100
	Field oldgy:Float = 100
	Field gdirection# = 0
	
	Field l_GhostLap:TList
	Field link_CurrentGhostFrame:TLink
	
	' Laps and waylines
	Field lapscomplete:Int = -1			' First lap starts after crossing start line
	Field lastqualifyinglap:Int = -99	' Record current flying lap so you can finish your it in qualifying
	Field lastwayline:Int = 0
	Field nextwp:TWayPoint
	Field dir2wp:Float 
	Field limitspeed:Float = 1.0
	Field topspeed:Float = 8.5
	Field handling:Float
	Field accel:Float = 0
	Field startaccel:Float = 0			' The rate of acceleration off the grid
	
	' Times
	Field lapstarttime:Int = 0
	Field lastlaptime:Int = 0
	Field bestlaptime:Int = 0
	Field lastlapmillisecs:Int = 0		' Used to store global time when driver crossed the start/finish line (for car ahead/behind times)
	
	' Display
	Field infoalpha:Float = 0
	Field colour:String
		
	' Sound
	Field chn_MyEngine:TChannel
	Field chn_HumanTerrain:TChannel
	Field chn_HumanCrashFX:TChannel
	
	Field gear:Int = 0
	Field revs:Float
	Field forecast:Int
	Field lastforecast:Int
	
	' AI
	Field randomoffspell:Int 
	
	' Collision circles
	Field coll_fleft:TCollCircle
	Field coll_fright:TCollCircle
	Field coll_left:TCollCircle
	Field coll_right:TCollCircle
	Field coll_rleft:TCollCircle
	Field coll_rright:TCollCircle
	
	Function ClearAll()
		If Not list Then Return
		
		AppLog "TCar.Clear"
		
		For Local c:TCar = EachIn list
			c.Clear()
		Next
		
		list.Clear()
		GCCollect()
	End Function
	
	Method Clear()
		If img Then img = Null
			
		mydriver = Null
		'	l_particles.Clear()
		'	l_blur.Clear()
		l_particles = Null
		l_blur = Null
		link_CurrentFrame = Null
		link_CurrentGhostFrame = Null
		l_ReplayFrames.Clear()
		l_GhostLap.Clear()
		
		If chn_MyEngine Then chn_MyEngine.Stop()
		If chn_HumanTerrain Then chn_HumanTerrain.Stop()
		If chn_HumanCrashFX Then chn_HumanCrashFX.Stop()
		
		chn_MyEngine = Null
		chn_HumanTerrain = Null
		chn_HumanCrashFX = Null
	End Method
	
	Function Create(controller:Int = CCONTROLLER_CPU, drv:TDriver, sportsnm:String = "")
		AppLog "TCar.Create:"+drv.id
		
		' Check globals
		folder = gAppLoc
		If gModLoc <> "" Then folder = gModLoc
		
		If Not list Then list = CreateList()
		If Not str_Gear Then str_Gear = GetLocaleText("Gear")
		If Not str_Throttle Then str_Throttle = GetLocaleText("Throttle")
		If Not str_Brake Then str_Brake = GetLocaleText("Brake")
		If Not str_Kers Then str_Kers = GetLocaleText("Boost")
		If Not str_LapTimeText Then str_LapTimeText = GetLocaleText("Lap Time")+":"
		If Not str_BestLapText Then str_BestLapText = GetLocaleText("Best Lap")+":"
		If Not str_LastLapText Then str_LastLapText = GetLocaleText("Last Lap")+":"
		If Not str_RecordText Then str_RecordText = GetLocaleText("Record")+":"
		If Not str_PositionText Then str_PositionText = GetLocaleText("Position")+": "
		If Not str_LapText Then str_LapText = GetLocaleText("Lap")+": "
	
		Local newcar:TCar = New TCar
		
		newcar.chn_MyEngine = AllocChannel()
		If controller = CCONTROLLER_HUMAN 
			newcar.chn_HumanCrashFX = AllocChannel()
		EndIf
		newcar.controller = controller
		newcar.handling = CHANDLING_STANDARD
		newcar.accel = CACCEL_STANDARD
		newcar.topspeed = CTOPSPEED_STANDARD
		newcar.randno = Rand(1000)
		
		If sportsnm <> ""
			AppLog "Create: "+sportsnm
			newcar.sportsname = sportsnm
			newcar.img = LoadMyImage(folder+"Media/Cars/"+sportsnm+".png")
			If Not newcar.img Then newcar.img = LoadMyImage(gAppLoc+"Media/Cars/sportscar_1.png")
			newcar.LoadCarStats()
			newcar.LoadDefaultColour(sportsnm)
		Else
			newcar.LoadCarImage(TTeam.GetById(drv.team).GetDriverNumber(drv.id), drv.team)
			
			' All cars are equal in online mode, otherwise load stats
			If TOnline.netstatus = CNETWORK_NONE
				newcar.handling:+(TTeam.GetById(drv.team).handling*0.1)
				newcar.accel:+(TTeam.GetById(drv.team).acceleration*0.002)
				newcar.topspeed:+(TTeam.GetById(drv.team).topspeed*0.2)
				
				' Mix up CPU stats every race
				If controller = CCONTROLLER_CPU
					AppLog "Handling:"+newcar.handling
					AppLog "   Accel:"+newcar.accel
					AppLog "TopSpeed:"+newcar.topspeed
					
					AppLog drv.name+":"+drv.skill
					newcar.handling:+(drv.skill/100.0)	' Max boost of +0.1 (Handling is generally 2.3-2.6)
					newcar.accel:+(drv.skill/10000.0)	' Max boost of +0.001
					newcar.topspeed:+(drv.skill/200.0)	' Max boost of +0.05 (TopSpeed is generally 9.3-9.7)
					AppLog "New Handling:"+newcar.handling
					AppLog "   New Accel:"+newcar.accel
					AppLog "New TopSpeed:"+newcar.topspeed
				End If
			EndIf
			
			newcar.startaccel = newcar.accel
			
			newcar.LoadDefaultColour("car_"+drv.team)
		End If
		
		Applog "Set HOTSPOT"
		
		newcar.l_ReplayFrames = CreateList()
		newcar.l_GhostLap = CreateList()
		newcar.mydriver = drv
		newcar.mydriver.qualifyingtime = 0
		newcar.mydriver.lastracetime = 0
		newcar.mydriver.iwaslapped = 0
		newcar.position = list.Count()+1
		newcar.fuel = 100
		newcar.tyrewear = 100
				
		Global x:Int = 10
		Global y:Int = 660
		newcar.x = x
		newcar.y = y
		x:+40
		If y = 600 Then y = 660 Else y = 600
		
		' Collision Circles
		Local dist:Float = LoadVariable(folder+"Settings/Engine.ini", "collisioncheckdist_front", 0.0, 100.0)
		Local ang:Float = LoadVariable(folder+"Settings/Engine.ini", "collisionangle_front", 0.0, 360.0)
		Local size:Float = LoadVariable(folder+"Settings/Engine.ini", "collisionsize_front", 0.0, 100.0)
		
		newcar.coll_fleft = TCollCircle.Create(dist, -ang, size)
		newcar.coll_fright = TCollCircle.Create(dist, ang, size)
		
		dist = LoadVariable(folder+"Settings/Engine.ini", "collisioncheckdist_side", 0.0, 100.0)
		ang = LoadVariable(folder+"Settings/Engine.ini", "collisionangle_side", 0.0, 360.0)
		size = LoadVariable(folder+"Settings/Engine.ini", "collisionsize_side", 0.0, 100.0)
		
		newcar.coll_left = TCollCircle.Create(dist, -ang, size)
		newcar.coll_right = TCollCircle.Create(dist, ang, size)
		
		dist = LoadVariable(folder+"Settings/Engine.ini", "collisioncheckdist_rear", 0.0, 100.0)
		ang = LoadVariable(folder+"Settings/Engine.ini", "collisionangle_rear", 0.0, 360.0)
		size = LoadVariable(folder+"Settings/Engine.ini", "collisionsize_rear", 0.0, 100.0)
		
		newcar.coll_rleft = TCollCircle.Create(dist, -ang, size)
		newcar.coll_rright = TCollCircle.Create(dist, ang, size)
		
		list.AddLast(newcar)
		
		Applog "Car Added"
	End Function
	
	Function CreateReplayCar:TCar(controller:Int = CCONTROLLER_CPU, drv:TDriver)
		folder = gAppLoc
		If gModLoc <> "" Then folder = gModLoc
		
		If Not list Then list = CreateList()
		If Not str_PositionText Then str_PositionText = GetLocaleText("Position")+": "
		If Not str_LapText Then str_LapText = GetLocaleText("Lap")+": "
		Local newcar:TCar = New TCar
		
		newcar.controller = controller
		newcar.LoadCarImage(drv.drivernumber, drv.team)
		newcar.l_ReplayFrames = CreateList()
		newcar.l_GhostLap = CreateList()
		newcar.mydriver = drv
		
		list.AddLast(newcar)
		
		Return newcar
	End Function
	
	Method LoadCarImage(drvnum:Int, teamid:Int)
		If teamid < 1 Or teamid > 12 Then Return
		
		Select drvnum
		Case 1	img = LoadMyImage(folder+"Media/Cars/Car_"+teamid+"a.png")
		Case 2	img = LoadMyImage(folder+"Media/Cars/Car_"+teamid+"b.png")
		End Select
		
		SetImageHandle(img, 24, 17)
	End Method
	
	Method LoadCarStats()
		AppLog "LoadCarStats: "+sportsname
		
		Local folder:String = gAppLoc
		If gModLoc <> "" Then folder = gModLoc
		
		Local ini:TStream = OpenFile(folder+"Media/Cars/Cars.ini")
		Assert ini, "Could not open Cars.ini"

		While Not Eof(ini)
			Local str:String = ReadLine(ini)
			Local comma:Int = 0
			
			If Left(str,1) <> ";"
				' Get name then remove name and comma from string
				comma = str.Find(",")
				Local name:String = str[..comma]
				str = str[comma+1..]
				
				' Get handling
				comma = str.Find(",")
				Local strhandling:String = str[..comma]
				str = str[comma+1..]
				
				' Get handling
				comma = str.Find(",")
				Local stracceleration:String = str[..comma]
				str = str[comma+1..]
				
				' Get topspeed
				comma = str.Find(",")
				Local strtopspeed:String = str[..comma]
				str = str[comma+1..]
				
				' Get hotspots
				comma = str.Find(",")
				Local strxh:String = str[..comma]
				str = str[comma+1..]
				
				Local stryh:String = str
				
				' Store in car				
				If sportsname <> "" And name = sportsname 
					If strhandling.ToFloat() > 5 Then strhandling = "5.0"
					If stracceleration.ToFloat() > 5 Then stracceleration = "5.0"
					If strtopspeed.ToFloat() > 5 Then strtopspeed = "5.0"
					
					handling:+(strhandling.ToFloat()*0.1)
					accel:+(stracceleration.ToFloat()*0.002)
					startaccel = accel
					topspeed:+(strtopspeed.ToFloat()*0.2)
					
					SetImageHandle(img, strxh.ToInt(), stryh.ToInt())
					
					AppLog "Handling:"+handling
					AppLog "Accel:"+accel
					AppLog "TopSpeed:"+topspeed
				EndIf
			EndIf
		Wend
		
		CloseStream ini
	End Method
	
	Method LoadDefaultColour(carname:String)
		AppLog "LoadDefaultColour"
		
		Local folder:String = gAppLoc
		If gModLoc <> "" Then folder = gModLoc
		
		Local ini:TStream = OpenFile(folder+"Media/Cars/Colours.ini")
		Assert ini, "Could not open Colours.ini"

		While Not Eof(ini)
			Local str:String = ReadLine(ini)
			Local comma:Int = 0
			
			If Left(str,1) <> ";"
				' Get name then remove name and comma from string
				comma = str.Find(",")
				Local name:String = str[..comma]
				str = str[comma+1..]
				
				' Store in car				
				If name = carname 
					colour = str
					
					AppLog colour
				EndIf
			EndIf
		Wend
		
		CloseStream ini
	End Method
	
	Function UpdateAll()
		
		' Record old position
		For Local c:TCar = EachIn list
			c.oldx = c.x
			c.oldy = c.y
			c.olddirection = c.direction
		Next
		
		TOnline.UpdateNetwork()
		
		For Local c:TCar = EachIn list
			c.Update()
			c.UpdateInfoAlpha()
			c.UpdateTerrain()
			
			' Remote players will check their own collisions
			If c.controller <> CCONTROLLER_REMOTE Then c.CheckCollisions()
			
			c.CheckWayLines()
			
			If Not gLowDetail
				c.UpdateParticles()
				c.UpdateBlur()
			EndIf
		Next

		UpdatePositionsAll()
	End Function
	
	Function UpdatePositionsAll()
		' Recheck positions
		TCar.sortby = CSORT_POSITION
		If track.racestatus = CRACESTATUS_QUALIFY Then TCar.sortby = CSORT_QUALIFYINGTIME
		TCar.list.Sort()
		
		Local pos:Int = 1
		
		For Local c:TCar = EachIn list
			c.position = pos
			pos:+1
		Next
	End Function
	
	Function UpdateInfoAlphaAll()
		For Local c:TCar = EachIn list
			c.UpdateInfoAlpha()
		Next
	End Function 
	
	Method UpdateInfoAlpha()
		If infoalpha > 0 Then infoalpha:-0.04*GetGameSpeed()
	End Method
	
	Method Update()		
		DoEngineSound()
		
		' Check pre-race
		Select track.racestatus
		Case CRACESTATUS_GRID			Return
		Case CRACESTATUS_QUALIFY
			If mydriver.id <> gMyDriverId 
				If (gMillisecs-track.racestarttime) < (qualifyorder * 3000)
					Return
				EndIf
			EndIf
		End Select
		
		' Check end of race - take control
		Local ctr:Int = controller 
		
		Global raceover:Int = False
		
		If RaceIsOver() And (ctr = CCONTROLLER_HUMAN Or ctr = CCONTROLLER_REMOTE)
			ctr = CCONTROLLER_CPU
			
			' Make sure that when the COM takes control it is looking at the start of the track not the start of the pitlane
			If raceover = False 
				nextwp = track.GetWaypoint(1, track.l_waypoints) 
			EndIf
			
			raceover = True
		EndIf
				
		' Check road ahead
		Local roadclear:Int = CheckRoadClear()
		Local trn:Float = handling-(speed*0.11)
		'If tyretype = CTYRE_SOFT Then trn = (handling*1.10)-(speed*0.11)	' Soft tyres have more grip
		
		' Tyrewear affects steering
		If tyrewear > 20
			If tyretype <> CTYRE_SOFT
				trn:*(0.9 + ((tyrewear-20.0)/800.0))	' Base rate of 90% handling plus up to 10% depending on tyre condition
			Else
				trn:*(0.9 + ((tyrewear-7.5)/800.0))		' An extra 6.75% for soft
			End If
			'trn:-(90.0-tyrewear)/900.0
		Else
			trn:*(0.75 + (tyrewear*0.0075))			' Handling drops from 90% to 75%
		EndIf
		
		Select ctr
		Case CCONTROLLER_REMOTE
			limitspeed = 1.0
			
			Select steering
			Case -1		steer:-trn * GetGameSpeed()
			Case 1		steer:+trn * GetGameSpeed()
			End Select
		
		Case CCONTROLLER_HUMAN
			gassing = 0
			steering = 0
			limitspeed = 1.0
			
			If Not pitting
				If ButtonDown(MYKEY_LEFT) Then steer:-trn * GetGameSpeed(); steering = -1
				If ButtonDown(MYKEY_RIGHT) Then steer:+trn * GetGameSpeed(); steering = 1
				If ButtonDown(MYKEY_UP) Then gassing = 1
				If ButtonDown(MYKEY_DOWN) Then gassing = -1
				
				Local desx:Float = 0
				Local desy:Float = 0
				FindPitBay(desx, desy)
				
				' Then look to next one
				If track.l_waypoints.Count()
					' Find human's way-point
					If Not nextwp Then nextwp = track.GetWayPoint(1, track.l_waypoints)
				
					' Make sure the human car has a valid (close) waypoint for position sorting
					Local nearestwp:TWayPoint = track.GetNearestWaypoint(x, y, track.l_waypoints,False) 
					
					' If it is close then this is the current way point
					If GetDistance(x, y, nearestwp.x, nearestwp.y) < 150 Then nextwp = nearestwp
					
					' Then look to next waypoint
					If GetDistance(x, y, nextwp.x, nextwp.y) < 150 Then nextwp = track.GetWayPoint(nextwp.id+1, track.l_waypoints)
					
				EndIf
			Else
				gassing = 0
				
				Local desx:Float = x
				Local desy:Float = y
				FindPitBay(desx, desy)
				
				dir2wp = GetDiffBetweenTwoAngles(direction, GetDirection(x, y, desx, desy), False)
				If dir2wp < -0.1 Then steer = steer - 2*GetGameSpeed()
				If dir2wp > 0.1 steer = steer + 2*GetGameSpeed()
				x:+Float(desx-x)*0.05*GetGameSpeed()
				y:+Float(desy-y)*0.05*GetGameSpeed()
			End If
			
		Case CCONTROLLER_CPU
			gassing = 0
			steering = 0
			
			If Not nextwp Then nextwp = track.GetWayPoint(1, track.l_waypoints)
			
			' If pitstop needed find the first pit way-point
			Local needpit:Int = False
			
			Local lapsleft:Int = track.totallaps-lapscomplete
			If mydriver.iwaslapped > 0 Then lapsleft = 0; needpit = True
		
			' Check tyres
			Select tyretype
			Case CTYRE_SOFT		If track.weather.doingweather And track.weather.wetness > 0.2 And lapsleft > 1 Then needpit = True
			Case CTYRE_HARD		If track.weather.doingweather And track.weather.wetness > 0.2 And lapsleft > 1 Then needpit = True
			Case CTYRE_WET		If track.weather.doingweather = False And track.weather.wetness < 0.8 And lapsleft > 1 Then needpit = True
			End Select
			
			If (tyrewear < 25 And lapsleft > 2) Or (tyrewear < 20 And lapsleft > 1) Then needpit = True
			
			' Check damage
			If damage > 40 And lapsleft > 4 Then needpit = True
			If damage > 60 And lapsleft > 2 Then needpit = True
			If damage > 80 And lapsleft > 1 Then needpit = True
			
			' Check fuel
			If (fuelconsumption > 0 And fuel < fuelconsumption*1.5) Then needpit = True
			
			If (needpit And pitting = False And lapsleft > 1) Or (pitting = False And lapsleft <= 0)
				Local pitpoint1:TWayPoint = track.GetWayPoint(1, track.l_pitwaypoints)
				
				' If close to first pit point then pick up the pit lane
				If pitpoint1 And GetDistance(x, y, pitpoint1.x, pitpoint1.y) < 120
					pitting = True
					nextwp = pitpoint1
				EndIf
			End If
			
			' If we are in the pit lane pick up the next way-point
			If pitting				
				If GetDistance(x, y, nextwp.x, nextwp.y) < 100 
					' Get next point on pit lane
					nextwp = track.GetWayPoint(nextwp.id+1, track.l_pitwaypoints)
					
					' If we have looped back to first pit waypoint pick up the main track again
					If nextwp.id = 1
						nextwp = track.GetNearestWayPoint(x, y, track.l_waypoints, False)
						pitting = False
					EndIf
				EndIf
			ElseIf nextwp
				' If com car approaches the waypoint move onto the next one
				If GetDistance(x, y, nextwp.x, nextwp.y) < 150 
					nextwp = track.GetWayPoint(nextwp.id+1, track.l_waypoints)
				EndIf
			End If
			
			If nextwp
				Local desx:Float = nextwp.x
				Local desy:Float = nextwp.y
				
				If pitting Then FindPitBay(desx, desy)
				
				If gMillisecs Mod mydriver.id = 1 And Rand(750*mydriver.skill) = 1 Then randomoffspell = gMillisecs; AppLog "Random spell:"+mydriver.name
				If pitting Then randomoffspell = 0
					
				If gMillisecs < randomoffspell+2500 Then trn:*0.35
				
				dir2wp = GetDiffBetweenTwoAngles(direction, GetDirection(x, y, desx, desy), False)
				
				Select roadclear
				Case CROADCLEAR_LEFT 	steer:-(trn*1.7)*GetGameSpeed(); steering = -1
				Case CROADCLEAR_RIGHT	steer:+(trn*1.7)*GetGameSpeed(); steering = 1
				Case CROADCLEAR_NONE
					If dir2wp < 0
						steer:-(trn*1.0)*GetGameSpeed(); steering = -1
					Else
						steer:+(trn*1.0)*GetGameSpeed(); steering = 1
					EndIf
				End Select
				
				If dir2wp < -trn*2 Then steer:-(trn*1.6)*GetGameSpeed(); steering = -1
				If dir2wp > trn*2 Then steer:+(trn*1.6)*GetGameSpeed(); steering = 1
				
				gassing = 0
				If roadclear = CROADCLEAR_LEFT Or roadclear = CROADCLEAR_RIGHT Or roadclear = CROADCLEAR_ALL Then gassing = 1
				
				If Not pitting
					If speed > 1
						If Abs(dir2wp) > 30 Then gassing = 0
						
						Local nextnextwp:TWayPoint = track.GetWayPoint(nextwp.id+1, track.l_waypoints)
						If nextnextwp
							Local wpdir:Float = GetDiffBetweenTwoAngles(direction, GetDirection(x, y, nextnextwp.x, nextnextwp.y))
							
							If wpdir > 40 And speed > topspeed*0.5 Then gassing = 0
							If wpdir > 50 And speed > topspeed*0.6 Then gassing = -1
						EndIf
					End If
				EndIf
				
				' Slow down more for bends when running on slicks in the wet
				If tyretype <> CTYRE_WET And track.weather.wetness > 0.0
					dir2wp:*((1.0+track.weather.wetness)*2)
				ElseIf needpit = True And lastwayline > track.l_waylines.Count()-2
					' Slow down for last few bends if tyrewear is low
					dir2wp:*3
				End If
				
				' Limit top speed depending on angle of turn coming up
				Select OpDifficulty 
				Case 1		limitspeed = 0.985 - Abs(dir2wp/CCOMSPEED_EASY)
							
							' Make it harder If winning
							If TCar.SelectHumanCar().position = 1 Then limitspeed = 0.9925 - Abs(dir2wp/CCOMSPEED_HARD)
							
							' Even easier if in last positions
							If TCar.SelectHumanCar().position >= 15 Then limitspeed = 0.98 - Abs(dir2wp/CCOMSPEED_EASY)
							
				Case 2		limitspeed = 0.9925 - Abs(dir2wp/CCOMSPEED_NORMAL)
							
							' Make it harder if winning
							If TCar.SelectHumanCar().position = 1 Then limitspeed = 0.9975 - Abs(dir2wp/CCOMSPEED_HARD)
							
							' Make it easier if losing
							If TCar.SelectHumanCar().position >= 15 Then limitspeed = 0.99 - Abs(dir2wp/CCOMSPEED_EASY)
							
							' Don't limit when over taking a slow car
							If position > 1
								Local carinfront:TCar = TCar.GetCarByPosition(position-1)
								
								If carinfront.mydriver.id <> gMyDriverId And carinfront.mydriver.seasonpts < mydriver.seasonpts-5 
									 limitspeed = 1.0 - Abs(dir2wp/CCOMSPEED_HARD)
									 If Abs(dir2wp) < 5 Then limitspeed = 1.0
								End If
								
							EndIf
							
				Case 3		limitspeed = 1.0 - Abs(dir2wp/CCOMSPEED_HARD)
							
							' Don't limit when over taking a slow car
							If position > 1
								Local carinfront:TCar = TCar.GetCarByPosition(position-1)
								
								If carinfront.mydriver.id <> gMyDriverId And carinfront.mydriver.seasonpts < mydriver.seasonpts-5 
									 limitspeed = 1.0 - Abs(dir2wp/(CCOMSPEED_HARD*1.5))
								End If
								
							EndIf
							
				Case 4		limitspeed = 1.0	' - Abs(dir2wp/CCOMSPEED_EXTREME)

				End Select
				
				If Abs(dir2wp) < 5 Then limitspeed = 1.0

				' Don't slow down during off spell
				If gMillisecs < randomoffspell+2500 Then limitspeed = 1.0
				If limitspeed > 1.0 Then limitspeed = 1.0
				If limitspeed < 0.5 Then limitspeed = 0.5
				
				' Finish lap
				If RaceIsOver() Then limitspeed = 0.985
			EndIf
			
			' Make sure car slows down enough to pick up start of pit lane
			If pitting And nextwp.id < 3
				If limitspeed > 0.985 Then limitspeed = 0.985
			EndIf
						
		End Select
		
		steer = steer * 0.5
		
		' friction
		Local fric:Float
		
		Select terrain
		Case CTERRAIN_TARMAC 	fric = CFRIC_TARMAC
		Case CTERRAIN_RUMBLE 	fric = CFRIC_RUMBLE
		Case CTERRAIN_GRASS		fric = CFRIC_GRASS
		Case CTERRAIN_GRAVEL	fric = CFRIC_GRAVEL
		Case CTERRAIN_PITLANE	fric = CFRIC_PITLANE
		Default	' CTERRAIN_BLANK
			fric = 0.05
		End Select
		
		' Fuel load affects acceleration
		Local acc:Float = accel
		
		If gMillisecs < track.racestarttime+3500 
			acc = startaccel
		End If
		
		If tyretype = CTYRE_SOFT Then acc:+0.001
		
		' Slipstream
		slipstream:-0.01*GetGameSpeed()
		If controller <> CCONTROLLER_REMOTE 
			For Local c:TCar = EachIn TCar.list
				If c <> Self And c.speed > CTOPSPEED_STANDARD * CSLIPSTREAM_MIN
					If GetDistance(x, y, c.x, c.y) < CSLIPSTREAM_DIST
						Local dir2op:Float = GetDirection(x,y,c.x,c.y)
						If GetDiffBetweenTwoAngles(dir2op, c.direction) < CSLIPSTREAM_ANGLE
							slipstream:+CSLIPSTREAM_GAIN*GetGameSpeed()
							Exit
						EndIf
					End If
				End If
			Next
		EndIf
		
		If TOnline.netstatus And (TOnline.chk_Online_Quali.GetState() = True Or TOnline.chk_Online_Collisions.GetState() = False)
			slipstream = 0
		End If
		
		If controller = CCONTROLLER_CPU 
			If roadclear = CROADCLEAR_NONE Or Abs(dir2wp) > 5
				slipstream = 0
			End If
		EndIf
		ValidateMinMaxFloat(slipstream, 0.0, 0.5)
		
		' Check KERS button
		boost = False
		
		If OpKers And mydriver.kersfitted And kers > 0 And pitting = False And sportsname = "" And terrain <> CTERRAIN_PITLANE
			Select controller 
			Case CCONTROLLER_HUMAN		If ButtonDown(MYKEY_KERS) Then boost = True
			Case CCONTROLLER_CPU	
				Select roadclear 
				Case CROADCLEAR_LEFT 	If Abs(dir2wp) < 6.5 Then boost = True
				Case CROADCLEAR_RIGHT	If Abs(dir2wp) < 6.5 Then boost = True
				Case CROADCLEAR_ALL 	
					Local distleft:Float = 100
					distleft:-(Float(lastwayline)/Float(track.l_waylines.Count()))*100.0
					
					If Abs(dir2wp) < 5.0 And kers > distleft 
						boost = True
					EndIf					
				End Select
			End Select
		EndIf
		
		If boost
			acc:*1.05*GetGameSpeed()
			kers:-0.4*GetGameSpeed()
			If kers < 0 Then kers = 0
		ElseIf slipstream > 0.1
			acc:*1.07*GetGameSpeed()
		End If
		
		Local currentfuel:Float = fuel
		If OpFuel = False Then currentfuel = 50
		
		Select gassing
		Case 1
			speed:+(acc - currentfuel / CFUELWEIGHT) * GetGameSpeed()
			speed:*fric^Double(60.0/UPS)
		Case 0
			speed:*(fric+0.01)^Double(60.0/UPS)
			
		Case -1
			speed:-(acc + currentfuel / CFUELWEIGHT)*0.5*GetGameSpeed()
			speed:*fric^Double(60.0/ups)
		End Select
		
		' Fuel consumption and tyrewear (don't run out during parade lap)
		If Not RaceIsOver() And controller <> CCONTROLLER_REMOTE
			Local laps:Float = OpLaps
			If laps < 10 Then laps = 10
			
			Local cons:Float = CFUEL_CONSUMPTION*(10.0/laps)
			
			If OpFuel And pitting = False
				If boost	' KERS shouldn't use more fuel whilst boosting
					fuel:-Abs(speed*0.95)*cons*GetGameSpeed()
				ElseIf gassing
					fuel:-Abs(speed)*cons*GetGameSpeed()
				End If
			EndIf
			
			If fuel <= 0
				' Check fuel load
				damage:+0.01*GetGameSpeed()
				ValidateDamage()
				
				If controller = CCONTROLLER_HUMAN And currentfuel > 0 Then TScreenMessage.Create(0,0,GetLocaleText("Fuel empty!"), imgSmiley_3, 3000, 2)
				fuel = 0
			EndIf
			
			' Tyre wear
			If OpTyres
				Local twear:Float
				
				Select terrain
				Case CTERRAIN_TARMAC 	twear = CTYRE_WEAR_TARMAC*(10.0/laps)
				Case CTERRAIN_RUMBLE 	twear = CTYRE_WEAR_RUMBLE*(10.0/laps)
				Case CTERRAIN_GRASS		twear = CTYRE_WEAR_GRASS*(10.0/laps)
				Case CTERRAIN_GRAVEL	twear = CTYRE_WEAR_GRAVEL*(10.0/laps)
				End Select
				
				If tyretype = CTYRE_SOFT Then twear:*1.75
				If tyretype = CTYRE_WET Then twear:*1.1
				
				If gassing = -1 
					If Abs(steer) > 3.0 
						twear:*2.0
					Else
						twear:*1.5
					End If
				EndIf
				
				tyrewear:-Abs(speed)*twear*GetGameSpeed()
				
				If tyrewear < 10 Then damage:+(Abs(speed)*twear*GetGameSpeed())*0.5
				ValidateDamage()
				
				' Increase tyrewear for using wets in dry conditions or vice versa
				If (tyretype = CTYRE_WET And track.weather.wetness < 0.2) Or (tyretype <> CTYRE_WET And track.weather.wetness > 0.8)
					tyrewear:-Abs(speed)*twear*GetGameSpeed()
				EndIf
				If tyrewear < 0 Then tyrewear = 0
			EndIf
		EndIf
		
		' Limit CPU speed based on angle of turn
		speed:*limitspeed^Double(60.0/ups)
		
		' Limit speed based on damage 
		Local ts:Float = (topspeed/3) + ((topspeed/100)*(100-damage))
		
		If damage >= 100 Then ts = 0	' CPU can crash and burn
		If ts > topspeed Then ts = topspeed
		
		If boost Or slipstream Then ts:*1.04
		If mydriver.kersfitted Then ts:*0.95							' Lower top speed for KERS cars
		If tyretype <> CTYRE_WET And track.weather.wetness > 0.1		' Lower top speed for slicks in wet
			If track.weather.wetness > 0.75
				ts:*0.8
			ElseIf track.weather.wetness > 0.5
				ts:*0.85
			ElseIf track.weather.wetness > 0.25
				ts:*0.9
			EndIf
		EndIf
		If tyretype = CTYRE_HARD Then ts:*0.975							' Lower top speed for hard tyres
		If tyretype = CTYRE_WET Then ts:*0.8 							' Lower top speed for wet tyres
		If gassing = -1 And speed < 0 Then ts:*0.4						' Limit reverse speed
		If fuel <= 0 And speed > 0 Then ts:*0.5							' Crawl when on fumes
		
		If speed > ts Then speed = ts
		If speed < -ts Then speed = -ts
		
		' turn the wheels
		direction:+steer
		If direction < 0 Then direction:+360
		If direction > 359 Then direction:-360
		
		' forwards
		x:+Cos(direction)*speed*GetGameSpeed()
		y:+Sin(direction)*speed*GetGameSpeed()
		
		' drift
		drift:+(steer * speed) * -0.01
		Local drif:Float = CDRIFT
		
		' Rain
		If track.weather.wetness > 0
			Local w:Float = track.weather.wetness
			If controller = CCONTROLLER_CPU Then w:*0.5	' Don't handicap CPU too much
			
			Select tyretype
			Case CTYRE_SOFT		drif:+(w*0.02)		' 0.98 More slippery
			Case CTYRE_HARD		drif:+(w*0.02)		' 0.98 More slippery
			Case CTYRE_WET		' Grip is fine but slower top speed
			End Select
		EndIf
		
		drif:+(100-tyrewear)/10000
		drift:*(drif^Double(60.0/UPS))
		
		If drift > 0
			x:+Cos(direction+90)*drift*GetGameSpeed()
			y:+Sin(direction+90)*drift*GetGameSpeed()
		ElseIf drift < 0
			x:-Cos(direction-90)*drift*GetGameSpeed()
			y:-Sin(direction-90)*drift*GetGameSpeed()
		End If
		
		xvel:*(0.95^Double(60.0/ups))
		yvel:*(0.95^Double(60.0/ups))
		x:+xvel*GetGameSpeed()
		y:+yvel*GetGameSpeed()
		
		' Send car position to host if online
		If TOnline.netstatus = CNETWORK_RACE And controller <> CCONTROLLER_REMOTE
			If gMillisecs > lastsendcar+TOnline.gPacketSendRate
				lastsendcar = gMillisecs
				TOnline.SendCarData(Self)
			EndIf
			
			If gMillisecs > lastsendcarinfo+2500
				lastsendcarinfo = gMillisecs
				TOnline.SendCarInfo(Self)
			EndIf
		End If
	End Method
	
	Method ValidateDamage()
		If damage > 100 Then damage = 100
		
		If TOnline.netstatus
			If controller = CCONTROLLER_HUMAN
				If damage > 99 Then damage = 99
			End If
		End If
	End Method
	
	Method DoEngineSound()
		If Not chn_MyEngine Then GCCollect(); chn_MyEngine = AllocChannel()
		
		' Set gear
		Local lastgear:Int = gear
		gear = 0
		If speed > 0 Then gear = 1
		If speed > topspeed*0.2 Then gear = 2
		If speed > topspeed*0.4 Then gear = 3
		If speed > topspeed*0.6 Then gear = 4
		If speed > topspeed*0.7 Then gear = 5
		If speed > topspeed*0.8 Then gear = 6
		If speed > topspeed*0.85 Then gear = 7
		
		Select track.racestatus 
		Case CRACESTATUS_GRID
			If Rand(24) = 1 And Not chn_MyEngine.Playing()
				revs = 1-Rnd(-0.2,0.1)
				chn_MyEngine.SetRate(revs)
				revs = 0
				
				If sportsname <> "" Or CSOUND_F1ENGINE = 0
					PlaySound(snd_EngineSports, chn_MyEngine)
				Else
					PlaySound(snd_Rev1, chn_MyEngine)
				EndIf
			EndIf
		Default	' CRACESTATUS_RACE, CRACESTATUS_Practice, CRACESTATUS_QUALIFY
			' Gear Noise
			revs = 0.2+(Abs(speed/topspeed)-0.1)
			chn_MyEngine.SetRate(revs)
			If gear = 0 And speed = 0 Then chn_MyEngine.SetRate(0.6 + Rnd(- 0.05, 0.05))
			
			If lastgear <> gear 
				If sportsname <> "" Or CSOUND_F1ENGINE = 0
					PlaySound(snd_EngineSports, chn_MyEngine)
				Else
					PlaySound(snd_EngineGear, chn_MyEngine)
				EndIf
			EndIf
			
			' Engine Noise
			If Not chn_MyEngine.Playing()
				If sportsname <> "" Or CSOUND_F1ENGINE = 0
					PlaySound(snd_EngineSports, chn_MyEngine)
				Else
					PlaySound(snd_EngineTopSpeed, chn_MyEngine)
				EndIf
			EndIf
		End Select
		
		If controller = CCONTROLLER_HUMAN
			chn_MyEngine.SetVolume(OpVolumeFX*CVOL_ENGINE)
		Else
			Local vol:Float = 200/GetDistanceFromHumanCar()
			If vol > 0.9 Then vol = 0.9
			chn_MyEngine.SetVolume(vol*OpVolumeFX*CVOL_ENGINE)
		End If
	End Method
	
	Method GetDistanceFromHumanCar:Float()
		Local c:TCar = TCar.SelectHumanCar()
		Local dist:Double = GetDistance(x,y,c.x,c.y)
		If dist = 0 
			Return 0.0001
		Else
			Return dist
		EndIf
	End Method
	
	Method UpdateParticles()
		Local px:Float
		Local py:Float
		Local xv:Float = Cos(Rand(360))
		Local yv:Float = Sin(Rand(360))
			
		If damage > 10 And Rand(110) < damage
			px = x+Rnd(-5.0,5.0)+Cos(Direction+180)*26
			py = y+Rnd(-5.0,5.0)+Sin(Direction+180)*26
			Local c:Int = 125-damage+Rand(100)
			l_particles.AddLast(TParticle.CreateParticle(px, py, xv, yv, damage/100, 1,c,c,c))
		End If
		
		If speed > 0.4 Or speed < -0.4
			If (terrain = CTERRAIN_GRASS Or terrain = CTERRAIN_GRAVEL) 
				If gMillisecs > lastparticle+50
					Local r:Int = 150+Rand(35)
					Local g:Int = 120+Rand(35)
					Local b:Int = 30+Rand(35)
					
					px = x+Cos(Direction+192)*32
					py = y+Sin(Direction+192)*32
					l_particles.AddLast(TParticle.CreateParticle(px, py, xv, yv, 0.3, 1.0, r,g,b))
					
					px = x+Cos(direction+168)*32
					py = y+Sin(direction+168)*32
					l_particles.AddLast(TParticle.CreateParticle(px, py, xv, yv, 0.3, 1.0, r,g,b))
					
					lastparticle = gMillisecs
				EndIf
			Else
				If track.weather.wetness > 0.01 And gMillisecs > lastparticle+20 And pitstop = 0
					Local r:Int = 225+Rand(25)
					Local g:Int = r
					Local b:Int = r
					
					px = x+Cos(Direction+192)*22
					py = y+Sin(Direction+192)*22
					l_particles.AddLast(TParticle.CreateParticle(px, py, xv, yv, track.weather.wetness*0.2, 2.5, r,g,b))
					
					px = x+Cos(Direction+168)*22
					py = y+Sin(direction+168)*22
					l_particles.AddLast(TParticle.CreateParticle(px, py, xv, yv, track.weather.wetness*0.2, 2.5, r,g,b))
					
					lastparticle = gMillisecs
				EndIf
			End If
		EndIf
		
		For Local p:TParticle = EachIn l_Particles
			p.a:*0.96
			p.scale:*1.02
			
			p.xvel:*0.95
			p.yvel:*0.95
			
			p.x:+p.xvel
			p.y:+p.yvel
			If p.a < 0.05 Then l_particles.Remove(p)
		Next
	End Method
	
	Method UpdateBlur()
		If gMillisecs > lastblur And speed > CTOPSPEED_STANDARD*0.5
			Local a:Float = 0.125
			If boost Or slipstream > 0 Then a:+0.1
			
			l_blur.AddLast(TBlur.CreateBlur(x, y, (speed/CTOPSPEED_STANDARD)*a, direction))
			lastblur = gMillisecs
		EndIf
		
		For Local p:TBlur = EachIn l_blur
			p.a:*0.85
			p.s:*0.9
			If p.a < 0.05 Then l_blur.Remove(p)
		Next
	
	End Method
	
	Method UpdateTerrain()
		' Check top level terrain
		terrain = GetTerrain(1, x, y)
		
		' If blank, check base level
		If terrain = CTERRAIN_BLANK Then terrain = GetTerrain(0, x, y)
		
		' Base volume on speed
		Local vol:Float = OpVolumeFX*(speed/topspeed)
		If chn_HumanTerrain Then chn_HumanTerrain.SetVolume(vol)
					
		If oldterrain <> terrain And controller = CCONTROLLER_HUMAN
			If chn_HumanTerrain
				StopChannel(chn_HumanTerrain)
				chn_HumanTerrain = Null
			EndIf
			
			Select terrain
			Case CTERRAIN_GRASS
				chn_HumanTerrain = AllocChannel()
				chn_HumanTerrain.SetVolume(vol)
				PlaySound(snd_Gravel, chn_HumanTerrain)
				
			Case CTERRAIN_RUMBLE
				chn_HumanTerrain = AllocChannel()
				chn_HumanTerrain.SetVolume(vol)
				PlaySound(snd_Edge, chn_HumanTerrain)
				
			Case CTERRAIN_GRAVEL
				chn_HumanTerrain = AllocChannel()
				chn_HumanTerrain.SetVolume(vol)
				PlaySound(snd_Gravel, chn_HumanTerrain)
				
			End Select
		EndIf
		
		oldterrain = terrain
	End Method
	
	Method CheckCollisions()
		' Check boundaries
		Local initialdamage:Float = damage
		If x < 0 Then x = oldx
		If y < 0 Then y = oldy
		If x > track.trackw * track.mastertilesize Then x = oldx
		If y > track.trackh * track.mastertilesize Then y = oldy
		
		' Check walls
		Local lastwallpoint:TWayPoint
		
		If Not pitting And Not RaceIsOver()
			For Local w:TWayPoint = EachIn track.l_wallpoints
				If lastwallpoint	' First loop this is NULL
					If w.id > 0		' Don't check point if this is a break in the wall
						Local pt:TInterceptPoint = Lines_Intersect(oldx, oldy, x, y, w.x, w.y, lastwallpoint.x, lastwallpoint.y)
						If pt.intercept
							x = oldx
							y = oldy
							Local walldirec:Float = GetDirection(oldx, oldy, pt.x, pt.y)
							xvel = Cos(walldirec+180)*(1+Abs(speed*2))
							yvel = Sin(walldirec+180)*(1+Abs(speed*2))
							
							If Not pitting
								If OpDamage
									damage:+Abs(speed*CDAMAGE_WALL)
									tyrewear:-1.0
								EndIf
								
								ValidateDamage()
								TParticle.Collision(pt.x, pt.y, direction+180, speed, colour)
								
								Local vol:Float = 200/GetDistanceFromHumanCar()
								If vol > 0.9 Then vol = 0.9
								
								If chn_HumanCrashFX
									chn_HumanCrashFX.SetVolume(OpVolumeFX)
									PlaySound(snd_Crash_Wall, chn_HumanCrashFX)
								Else
									chn_CrashFX.SetVolume(vol*OpVolumeFX)
									PlaySound(snd_Crash_Wall, chn_CrashFX)
								EndIf
							EndIf
							
							' If cpu hits the wall then look for previous waypoint
							If controller = CCONTROLLER_CPU And gMillisecs < lastwallcollision+3000
								Select pitting
								Case False
									Local previd:Int = nextwp.id-4
									If previd < 1 Then previd:+track.l_waypoints.Count()
									
									nextwp = track.GetWayPoint(previd, track.l_waypoints)
								Case True
									Local previd:Int = nextwp.id-4
									If previd < 1 Then previd = 1
									
									nextwp = track.GetWayPoint(previd, track.l_pitwaypoints)
								End Select
								
							EndIf
							
							lastwallcollision = gMillisecs
							drift = 0
							
							Exit
						End If
					EndIf
				EndIf
				
				lastwallpoint = w
			Next
		EndIf
			
		' Check other cars (if not online qualifying)
		If TOnline.netstatus 
			If TOnline.chk_Online_Quali.GetState() = True Then Return
			If TOnline.chk_Online_Collisions.GetState() = False Then Return
		EndIf
		
		If Not pitting And fuel > 0 And damage < 100 And nocollision = False
			For Local c:TCar = EachIn TCar.list
				' Don't collide with cars pitting or out of the race (except for the human car)
				If c <> Self And c.pitstop = 0 And c.pitting = 0 And Not c.RaceIsOver() and Not Self.RaceIsOver()
					Local cx1:Float = x + (Cos(Direction+180)*10)
					Local cy1:Float = y + (Sin(Direction+180)*10)
					Local cx2:Float = c.x + (Cos(Direction+180)*10)
					Local cy2:Float = c.y + (Sin(Direction+180)*10)
					
					Local collisionDistance# = 27
					Local actualDistance# = Sqr((cx2-cx1)^2+(cy2-cy1)^2)
					
					' collided or not?
					If actualDistance < collisionDistance	' ImagesCollide2(img, cx1, cy1, 0, direction, 1, 1, c.img, cx2, cy2, 0, c.direction, 1, 1)
						Local collNormalAngle#=ATan2(cy2-cy1, cx2-cx1)
						
						' position exactly touching, no intersection
						Local moveDist#=(collisionDistance-actualDistance)+1
						
						x = x + (moveDist*Cos(collNormalAngle+180))
						y = y + (moveDist*Sin(collNormalAngle+180))
						xvel:+Cos(collNormalAngle+180)*(c.speed*0.25)
						yvel:+Sin(collNormalAngle+180)*(c.speed*0.25)
						
						' If offline affect other cars velocity. If online everyone handles their own.
						If c.controller <> CCONTROLLER_REMOTE
							c.x = c.x + (moveDist*Cos(collNormalAngle))
							c.y = c.y + (moveDist*Sin(collNormalAngle))
							c.xvel:+Cos(collNormalAngle)*(speed*0.25)
							c.yvel:+Sin(collNormalAngle)*(speed*0.25)
						EndIf
						
						If Not RaceIsOver() And Not c.RaceIsOver() And OpDamage
							Local damcars:Float = CDAMAGE_CARS
							
							If TOnline.netstatus 
								damage:+Abs(speed)*0.5*damcars
							Else
								Select OpDifficulty
								Case 1	damage:+(Abs(speed)+Abs(c.speed))*0.1*damcars
								Case 2	damage:+(Abs(speed)+Abs(c.speed))*0.2*damcars
								Case 3	damage:+(Abs(speed)+Abs(c.speed))*0.3*damcars
								Case 4	damage:+(Abs(speed)+Abs(c.speed))*0.4*damcars
								End Select
								
								Select OpDifficulty
								Case 1	c.damage:+(Abs(speed)+Abs(c.speed))*0.1*damcars
								Case 2	c.damage:+(Abs(speed)+Abs(c.speed))*0.2*damcars
								Case 3	c.damage:+(Abs(speed)+Abs(c.speed))*0.3*damcars
								Case 4	c.damage:+(Abs(speed)+Abs(c.speed))*0.4*damcars
								End Select
							End If

							ValidateDamage()
							c.ValidateDamage()
						EndIf
						
						If damage > 100 Then damage = 100
						If c.damage > 100 Then c.damage = 100
						
						' Slight tyrewear for collisions
						tyrewear:-1
						If tyrewear < 1 Then tyrewear = 1
						
						Local vol:Float = 200/GetDistanceFromHumanCar()
						If vol > 0.9 Then vol = 0.9
						
						If controller = CCONTROLLER_HUMAN Or c.controller = CCONTROLLER_HUMAN Then vol = 1.0
						
						If chn_HumanCrashFX
							chn_HumanCrashFX.SetVolume(OpVolumeFX)
							PlaySound(snd_Crash_Car, chn_HumanCrashFX)
						Else
							chn_CrashFX.SetVolume(vol*OpVolumeFX)
							PlaySound(snd_Crash_Car, chn_CrashFX)
						EndIf
						
						TParticle.Collision(cx1, cy1, direction, speed, colour)
						TParticle.Collision(cx2, cy2, c.direction, c.speed, c.colour)
					EndIf
				End If
			Next
		EndIf
		
		' Pit crew don't like excessive damage
		If controller = CCONTROLLER_HUMAN 
			If Not gQuickRace And sportsname = ""
				If initialdamage < 25 And damage >= 25
					UpdateRelationship(CRELATION_PITCREW, -2.5, False)
				ElseIf initialdamage < 50 And damage >= 50
					UpdateRelationship(CRELATION_PITCREW, -2.5, False)
				ElseIf initialdamage < 75 And damage >= 75
					UpdateRelationship(CRELATION_PITCREW, -2.5, False)
				ElseIf initialdamage < 100 And damage >= 100
					UpdateRelationship(CRELATION_PITCREW, -2.5, False)
				End If
			EndIf
			
			If initialdamage < 100 And damage >= 100
				Local str:String = GetLocaleText("Damage")+" 100%"
				AppLog str
				TScreenMessage.Create(0,0,str,,5000,2)
			EndIf
		End If
	End Method
	
	Method CheckRoadClear:Int()
		If pitting Then Return CROADCLEAR_ALL
		
		Local leftclear:Int = True
		Local rightclear:Int = True
		
		For Local c:TCar = EachIn TCar.list
			If c <> Self And c.fuel > 0 And c.damage < 100
				If coll_fleft.CheckCollision(x, y, c.x, c.y, speed, direction) Then leftclear = False
				If coll_fright.CheckCollision(x, y, c.x, c.y, speed, direction) Then rightclear = False
				
				If coll_left.CheckCollision(x, y, c.x, c.y, 1.0, direction) Then leftclear = False
				If coll_right.CheckCollision(x, y, c.x, c.y, 1.0, direction) Then rightclear = False
				
				' Back markers (and racers finished) should move aside
				If track.racestatus = CRACESTATUS_RACE
					If c.position < position Or (lapscomplete >= track.totallaps And c.lapscomplete < track.totallaps) 'Or c.topspeed > topspeed+0.4
						If coll_rleft.CheckCollision(x, y, c.x, c.y, speed, direction) 
							leftclear = False
						ElseIf coll_rright.CheckCollision(x, y, c.x, c.y, speed, direction) 
							rightclear = False
						EndIf
					EndIf
				EndIf
			End If
		Next
		
		If leftclear = True And rightclear = True Then Return CROADCLEAR_ALL
		If leftclear = True Then Return CROADCLEAR_LEFT
		If rightclear = True Then Return CROADCLEAR_RIGHT
		Return CROADCLEAR_NONE
	End Method
	
	Method GetTerrain:Int(level:Int, x:Float, y:Float)
		' Get co-ords of tile beneath you
		Local tsize:Float = track.mastertilesize
		Local tilex:Int = x / tsize
		Local tiley:Int = y / tsize
		If tilex < 0 Then tilex = 0
		If tilex > track.trackw-1 Then tilex = track.trackw-1
		If tiley < 0 Then tiley = 0
		If tiley > track.trackh-1 Then tiley = track.trackh-1
		
		' Id of tile beneath you
		Local id:Int = track.tile_level[level,tilex, tiley].id
		Local rot:Int = track.tile_level[level,tilex, tiley].rotation
		
		' If tile has a parent
		If track.tile_level[level,tilex, tiley].parentx > -1
			' Store old x,y
			Local tx:Int = tilex
			Local ty:Int = tiley
			
			' Find parent x,y
			tilex = track.tile_level[level,tx, ty].parentx
			tiley = track.tile_level[level,tx, ty].parenty
			
			' Get new id
			id = track.tile_level[level,tilex, tiley].id
			rot = track.tile_level[level,tilex, tiley].rotation
		EndIf
		
		If id < 0 
			Select level
			Case 0	Return CTERRAIN_GRASS
			Case 1	Return CTERRAIN_BLANK
			End Select
		EndIf
		
		' Crossover?
		nocollision = False
		If id > -1 And id < track.tileset.tracktile_array.Length
			If track.tileset.tracktile_array[id].name = "Track_27.png" Then nocollision = True
		EndIf
		
		' Get position to paint tile
		Local posx:Int = tilex * tsize
		Local posy:Int = tiley * tsize
		
		Local pixmap:TPixmap 
		Select level
		Case 0 pixmap = track.tileset.basetile_array[id].imgpat
		Case 1 pixmap = track.tileset.tracktile_array[id].imgpat
		End Select
		
		If pixmap
			Local pixx:Float = x-posx
			Local pixy:Float = y-posy
			
			' Do rotation of pixmap
			Local temp:Int
			
			If rot > 0
				temp = pixx
				pixx = pixy
				pixy = pixmap.width-temp
			EndIf
			
			If rot > 90
				temp = pixx
				pixx = pixy
				pixy = pixmap.width-temp
			EndIf
			
			If rot > 180
				temp = pixx
				pixx = pixy
				pixy = pixmap.width-temp
			EndIf
		
			If pixx < 0 Then pixx = 0
			If pixx > pixmap.width-1 Then pixx = pixmap.width-1
			If pixy < 0 Then pixy = 0
			If pixy > pixmap.height-1 Then pixy = pixmap.height-1
			
			' Get RGB of position on pixmap
			Local p:Byte Ptr = PixmapPixelPtr(pixmap, pixx, pixy)
			Local r:Int = p[0]
			Local g:Int = p[1]
			Local b:Int = p[2]
			
			If r = 0 And g = 0 And b = 0
				Return CTERRAIN_BLANK
			ElseIf r = 128 And g = 128 And b = 128
				Return CTERRAIN_TARMAC
			ElseIf r = 255 And g = 0 And b = 0
				Return CTERRAIN_RUMBLE
			ElseIf r = 0 And g = 255 And b = 0
				Return CTERRAIN_GRASS
			ElseIf r = 255 And g = 255 And b = 0
				Return CTERRAIN_GRAVEL
			ElseIf r = 0 And g = 0 And b = 255
				Return CTERRAIN_PITLANE
			End If
		EndIf
		
		Return CTERRAIN_GRASS
	End Method
	
	Method GetTerrainString:String(t:Int)
		Select t
		Case CTERRAIN_BLANK		Return "Blank"
		Case CTERRAIN_TARMAC	Return "Tarmac"
		Case CTERRAIN_RUMBLE	Return "Rumble"
		Case CTERRAIN_GRASS		Return "Grass"
		Case CTERRAIN_GRAVEL	Return "Gravel"
		Case CTERRAIN_PITLANE 	Return "PitLane"
		End Select
	End Method
	
	Method DrawInfo()
		If gDebugMode And Not gRenderText Then Return
		ResetDrawing()
		
		Global str1:String
		Global str2:String
		Local lps:Int = lapscomplete
		If lps >= track.totallaps Then lps = track.totallaps-1
		
		Select track.racestatus
		Case CRACESTATUS_RACE
			DrawRacePanel((screenW/2)-85,15,170,60,164,164,164,OpPanelAlpha)
			str1 = str_PositionText+GetPositionString()
			fnt_Medium.Draw(str1, (screenW/2),22-fntoffset_Medium,1)
			
			SetColor(205,0,0)
			str2 = str_LapText+(lps+1)+"/"+track.totallaps
			fnt_Medium.Draw(str2, (screenW/2),46-fntoffset_Medium,1)
		Case CRACESTATUS_PRACTICE
			DrawRacePanel((screenW/2)-85,15,170,60,164,164,164,OpPanelAlpha)
			SetColor(205,0,0)
			str1 = str_LapText+(lps+1)+"/"+track.totallaps
			fnt_Medium.Draw(str1, (screenW/2),34-fntoffset_Medium,1)
		Case CRACESTATUS_QUALIFY
			DrawRacePanel((screenW/2)-85,15,170,60,164,164,164,OpPanelAlpha)
			str1 = str_PositionText+GetPositionString()
			fnt_Medium.Draw(str1, (screenW/2),22-fntoffset_Medium,1)
			
			SetColor(205,0,0)
			Local timeleft:Int = (track.racestarttime+track.timelimit)-gMillisecs
			If timeleft < 0 Then timeleft = 0
			If track.mode = CTRACKMODE_DRIVE Then str2 = GetStringTime(timeleft)
			fnt_Medium.Draw(str2, (screenW/2)-45,46-fntoffset_Medium)
		End Select

		Global str_laptime:String
		Global str_lastlap:String
		Global str_bestlap:String
		
		If lapscomplete < 0 
			str_laptime = ""
			str_lastlap = ""
			str_bestlap = ""
		EndIf
		
		If track.mode <> CTRACKMODE_EDIT
			If lapstarttime > 0
				If track.mode = CTRACKMODE_DRIVE Or TOnline.netstatus
					str_laptime = GetStringTime(gMillisecs-lapstarttime)
				EndIf
			EndIf
			
			If lastlaptime > 0
				str_lastlap = GetStringTime(lastlaptime)
			End If
			
			If bestlaptime > 0
				str_bestlap = GetStringTime(bestlaptime)
			End If
			
			DrawRacePanel(screenW-235,15,220,104,164,164,164,OpPanelAlpha)
			
			fnt_Small.Draw(str_LapTimeText, screenW-132, 12-fntoffset_Small, 2)
			fnt_Medium.Draw(str_laptime, screenW-134, 18-fntoffset_Medium)
			
			SetColor(0,150,0)
			
			fnt_Small.Draw(str_BestLapText, screenW-132, 36-fntoffset_Small,2)
			fnt_Medium.Draw(str_bestlap, screenW-134, 42-fntoffset_Medium)
		
			SetColor(205,0,0)
			fnt_Small.Draw(str_LastLapText, screenW-132, 60-fntoffset_Small,2)
			fnt_Medium.Draw(str_lastlap, screenW-134, 66-fntoffset_Medium)
			SetColor(255,255,255)
			
			SetColor(255,255,0)
			fnt_Small.Draw(str_RecordText, screenW-132, 84-fntoffset_Small,2)
			fnt_Medium.Draw(GetStringTime(track.laprecord), screenW-134, 90-fntoffset_Medium)
			SetColor(255,255,255)
			
			If track.laprecord <> 60000 And track.lapholder = gMyDriverId
				DrawImage(imgStar, screenW-230, 97)
			End If
			
			' Weather forecast
			Global changeforecast:Int
			
			forecast = 0
			If track.weather.cloud >= 50 Then forecast = 1	' Cloudy
			If track.weather.cloud >= 100 Then forecast = 3	' Raining
			
			' If forecast has changed then flash warning
			If gMillisecs < track.racestarttime+5000 Then changeforecast = -5000
			
			If (lastforecast = 3 And forecast = 1) Or (lastforecast = 1 And forecast = 3) 
				changeforecast = gMillisecs
				PlaySound(snd_Warning1, chn_FX)
			EndIf
			
			lastforecast = forecast
			
			Local c:Int = 255
			
			If gMillisecs < changeforecast+5000
				If gMillisecs Mod 1000 < 500 Then c = 0
			EndIf
			
			' Draw panel
			Local px:Int = screenW-70
			Local py:Int = screenH-70
			DrawRacePanel(px-5,py-5,60,60,255,c,c,OpPanelAlpha)
			
			ResetDrawing()
			DrawImage(track.weather.imgForecast, px+5, py+5, forecast)
			
			Local cld:Float = track.weather.cloud
			If cld < 1 Then cld = 1
			If cld > 150 Then cld = 150
			cld = (40.0/150.0)*cld
			SetAlpha(1)
			
			SetColor(0,0,0)
			DrawRect(px+4,py+40,42,6)
			
			' Draw weather segments
			SetColor(64,64,255)
			DrawRect(px+5,py+41,40.0,4)
			SetColor(128,128,128)
			DrawRect(px+5,py+41,40.0*0.66,4)
			SetColor(255,255,0)
			DrawRect(px+5,py+41,40.0*0.33,4)
			
			' Draw barometer
			SetColor(0,0,0)
			DrawRect(px+4+Int(cld)-1,py+39,3,8)
			SetColor(255,255,255)
			DrawLine(px+4+Int(cld),py+40,px+4+Int(cld),py+45)
			
			If track.weather.cloudinc > 0 And track.weather.cloud < 150
				SetColor(0,0,0)
				DrawLine(px+5+Int(cld),py+40,px+5+Int(cld),py+45)
				DrawLine(px+6+Int(cld),py+41,px+6+Int(cld),py+44)
				DrawLine(px+7+Int(cld),py+42,px+7+Int(cld),py+43)
				
				SetColor(255,255,255)
				DrawLine(px+5+Int(cld),py+41,px+5+Int(cld),py+44)
				DrawLine(px+6+Int(cld),py+42,px+6+Int(cld),py+43)
			ElseIf track.weather.cloudinc < 0 And track.weather.cloud > 1
				SetColor(0,0,0)
				DrawLine(px+3+Int(cld),py+40,px+3+Int(cld),py+45)
				DrawLine(px+2+Int(cld),py+41,px+2+Int(cld),py+44)
				DrawLine(px+1+Int(cld),py+42,px+1+Int(cld),py+43)
				
				SetColor(255,255,255)
				DrawLine(px+3+Int(cld),py+41,px+3+Int(cld),py+44)
				DrawLine(px+2+Int(cld),py+42,px+2+Int(cld),py+43)
			End If
		EndIf
		
		Global lastupdate:Int
		
		' You have finished
		If controller = CCONTROLLER_HUMAN And RaceIsOver()
			Local winner:Int = False
			
			If track.racestatus = CRACESTATUS_QUALIFY
				winner = True
			Else
				For Local c:TCar = EachIn TCar.list
					If c.lapscomplete >= track.totallaps Then winner = True; Exit
				Next
			EndIf
			
			' Make sure someone has won the race and you have not just been destroyed
			If winner
				If fry_ScreenName() <> "screen_raceinfo" Then MyFlushJoy()
				
				fry_SetScreen("screen_raceinfo")
				If gMillisecs > lastupdate+500
					Select track.racestatus 
					Case CRACESTATUS_RACE 		track.UpdateRaceInfoTable()
					Case CRACESTATUS_QUALIFY	track.UpdateRaceInfoTable()
					End Select
						
					lastupdate = gMillisecs 
				EndIf
				fry_Refresh()
			EndIf
		End If
	End Method
	
	Function ResetMiniInfoAlphaAll(a:Float = 2.0)
		For Local c:TCar = EachIn list
			c.infoalpha = a
		Next
	End Function
	
	Method CheckWayLines()
		For Local w:TWayLine = EachIn track.l_waylines
			If Lines_Intersect(oldx, oldy, x, y, w.x1, w.y1, w.x2, w.y2).intercept
		
				If w.id = lastwayline + 1 
					lastwayline = w.id
					
					' Initial wayline was 0
					If w.id = 1
						' Reset clock
						lapstarttime = gMillisecs
						
						' Start recording lap number
						lapscomplete = 0
						lapstartdamage = damage
						fuellastlap = fuel
						If OpKers And mydriver.kersfitted Then AddKers()
						
						' Start recording replay (+ghost) at start/finish line, not in the pits when Praticing or Qualifying
						If track.racestatus = CRACESTATUS_PRACTICE Or track.racestatus = CRACESTATUS_QUALIFY
							l_ReplayFrames.Clear()
						EndIf
						
					ElseIf w.id = track.l_waylines.Count() And (track.racestatus = CRACESTATUS_RACE) And controller = CCONTROLLER_HUMAN 
						infoalpha = 5.0
						
					ElseIf w.id = track.l_waylines.Count()-2
						' Check fuel
						If controller = CCONTROLLER_HUMAN And RaceIsOver() = False And fuelconsumption > 0 And OpFuel
							Local str:String = GetFloatAsString(Float(fuel/fuelconsumption))+" "+GetLocaleText("Laps")
							TScreenMessage.Create(0,0,str,img_FuelLarge,3000,2)
							
							If fuel < fuelconsumption*1.6 And OpRadio 
								radioqueue.AddLast(snd_Static)
								radioqueue.AddLast(snd_FuelLow); infoalpha = 5.0
								radioqueue.AddLast(snd_Static)
							EndIf
						EndIf
					EndIf
				ElseIf w.id = 1 
					If lastwayline = track.l_waylines.Count() 
						lastwayline = w.id
						
						Local consumption:Float
						
						If fuellastlap > 0 ' Don't calculate on initial start line or if fueled on last lap (because fuel will be more than it was on previous lap)
							consumption = fuellastlap-fuel
							
							If fuelconsumption = 0
								fuelconsumption = consumption
							Else
								fuelconsumption = (fuelconsumption+consumption)/2		' Average out consumption over course of race
							EndIf
						EndIf
						fuellastlap = fuel
						If controller = CCONTROLLER_HUMAN Then AppLog "fuellastlap="+fuellastlap
						If lapscomplete < track.totallaps
							lapscomplete:+1
							
							' For no fuel option, reduce tank by specific amount
							If Not OpFuel
								Select track.racestatus
								Case CRACESTATUS_PRACTICE
									fuel:-10
								Case CRACESTATUS_QUALIFY
									fuel:-10
								Default
									fuel:-(100.0/track.totallaps)
								End Select
								
								If fuel < 1 Then fuel = 1
							End If
							
							' Add kers
							If OpKers And mydriver.kersfitted AddKers()
							
							' Record last lap time
							lastlaptime = gMillisecs-lapstarttime
							mydriver.l_laptimes.AddLast(String(lastlaptime))
							
							TRaceReport.AddLap(gMillisecs-track.racestarttime, mydriver.name, lapscomplete, lastlaptime, GetStringTyre(tyretype, True))
							
							' Check best lap
							If lastlaptime < bestlaptime Or bestlaptime = 0
								bestlaptime = lastlaptime
								
								If bestlaptime < track.laprecord Or track.laprecord = 0
									track.laprecord = bestlaptime; PlaySound(snd_NewRecord, chn_FX) 
									track.lapholder = mydriver.id
								End If
								
								' Record ghost car data
								l_GhostLap.Clear()
								
								If track.racestatus = CRACESTATUS_PRACTICE
									For Local f:TReplayFrame = EachIn l_ReplayFrames
										If f.lap = lapscomplete
											l_GhostLap.AddLast(TReplayFrame.Copy(f))
										EndIf
									Next
								EndIf
								
								If track.racestatus = CRACESTATUS_QUALIFY
									mydriver.qualifyingtime = bestlaptime
								End If
							End If
						
							' Make sure ghost car starts when you start
							ResetGhostLap()
				
							' Report info
							If controller = CCONTROLLER_HUMAN And gMillisecs > lastpitstop+10000
								RadioTime(lastlaptime)
								
								' Impress boss
								If gQuickRace = False And track.racestatus = CRACESTATUS_PRACTICE And sportsname = "" 
									If lastlaptime <= track.laprecord + 2000
										UpdateRelationship(CRELATION_BOSS, +2, False)
									ElseIf lastlaptime <= track.laprecord + 5000
										UpdateRelationship(CRELATION_BOSS, 0, False)
									Else
										UpdateRelationship(CRELATION_BOSS, -2, False)
									EndIf
								End If
							EndIf
				
							' Split time
							lastlapmillisecs = gMillisecs
							
							If track.racestatus = CRACESTATUS_RACE 'And (TOnline.netstatus = False Or TOnline.chk_Online_Quali.GetState() = False)
								Select controller 
								Case CCONTROLLER_HUMAN
									' Show car ahead
									If position > 1
										Local lc:TCar = TCar.GetCarByPosition(position-1)
										
										If lc 
											If lc.lapscomplete = lapscomplete
												Local splittime:Int = gMillisecs-lc.lastlapmillisecs
												TScreenMessage.Create(100, (screenH/2)-50, lc.mydriver.shortname, lc.img, 5000, 1, False)
												TScreenMessage.Create(100, screenH/2, "-"+GetStringTime(splittime), Null, 5000, 1, False)
											ElseIf (lc.lapscomplete-lapscomplete) > 0
												TScreenMessage.Create(100, (screenH/2)-50, lc.mydriver.shortname, lc.img, 5000, 1, False)
												TScreenMessage.Create(100, screenH/2, "-"+String(lc.lapscomplete-lapscomplete)+" "+GetLocaleText("Lap"), Null, 5000, 1, False)
											EndIf
										EndIf
									EndIf
									
									' Check damage and impress pit crew
									If lapstartdamage = damage And Not gQuickRace And gMillisecs > lastpitstop+10000 Then UpdateRelationship(CRELATION_PITCREW, 10.0/track.totallaps, False)
									lapstartdamage = damage
		
								Default
									' Show car behind
									Local humancar:TCar = TCar.SelectByDriverId(gMyDriverId)
									
									If position = humancar.position+1 
										If humancar.lapscomplete = lapscomplete
											Local splittime:Int = gMillisecs-humancar.lastlapmillisecs
											
											TScreenMessage.Create(screenW-100, (screenH/2)-50, mydriver.shortname, Self.img, 5000, 1, False)
											TScreenMessage.Create(screenW-100, screenH/2, "+"+GetStringTime(splittime), Null, 5000, 1, False)
										ElseIf humancar.lapscomplete-lapscomplete > 0
											TScreenMessage.Create(screenW-100, (screenH/2)-50, mydriver.shortname, Self.img, 5000, 1, False)
											TScreenMessage.Create(screenW-100, screenH/2, "+"+String(humancar.lapscomplete-lapscomplete)+" "+GetLocaleText("Lap"), Null, 5000, 1, False)
										EndIf
									EndIf
								End Select
							End If
						EndIf
						
						' Check if completed all laps (or if winner has finished and you have been lapped)
						Local leader:TCar = TCar.GetCarByPosition(1)
						
						If mydriver.lastracetime = 0 And (lapscomplete = track.totallaps Or (leader And leader.lapscomplete >= track.totallaps))
							' Check if driver was lapped
							If lapscomplete < track.totallaps And leader And leader.lapscomplete >= track.totallaps
								mydriver.iwaslapped = leader.lapscomplete - lapscomplete
							End If
							
							If controller <> CCONTROLLER_REMOTE
								mydriver.lastracetime = gMillisecs-track.racestarttime
								
								If TOnline.netstatus
									' Online quali laps use lastracetime to record qualifying lap time
									If TOnline.chk_Online_Quali.GetState() = True Then mydriver.lastracetime = lastlaptime
									
									TOnline.SendRaceTime(Self)
								End If
							EndIf
							
							' Remote drivers finish time is recorded in TOnline
							If controller <> CCONTROLLER_REMOTE
								TRaceReport.AddLap(gMillisecs-track.racestarttime, mydriver.name, 9999, mydriver.lastracetime,, mydriver.iwaslapped)
							End If
							
						End If
						
						' Reset clock
						lapstarttime = gMillisecs
						track.UpdateRaceInfoTable()
					EndIf
				EndIf
			EndIf
		Next
	End Method
	
	Method AddKers()
		If controller = CCONTROLLER_HUMAN
			kers = 100
		Else
			Select OpDifficulty
			Case 1	kers = 60
			Case 2	kers = 80
			Case 3	kers = 100
			Case 4	kers = 120
			End Select
		EndIf
	End Method
	
	Function SelectHumanCar:TCar()
		If Not list Then Return Null
		
		For Local c:TCar = EachIn list
			If c.controller = CCONTROLLER_HUMAN
				Return c
			EndIf
		Next
		
		' No human
		For Local c:TCar = EachIn list
			If c.mydriver.id = 1 Then Return c
		Next
		
		' No id = 1
		For Local c:TCar = EachIn list
			Return c
		Next
		
		' No car at all
		Return Null
	End Function
	
	Function SelectByDriverId:TCar(id:Int)
		If Not list Then Return Null
		
		For Local c:TCar = EachIn list
			If c.mydriver.id = id Then Return c
		Next
				
		' No car at all
		Return Null
	End Function
	
	Function SelectReplayCar:TCar()		
		If Not list Then Return Null
		
		For Local c:TCar = EachIn list
			If c.mydriver.id = replaycarid Then Return c
		Next
				
		For Local c:TCar = EachIn list
			If c.controller = CCONTROLLER_HUMAN
				Return c
			EndIf
		Next
				
		' No car at all
		Return Null
	End Function
	
	Function ReplayCarAhead()
		If Not list Then Return
		
		sortby = CSORT_REPLAYPOSITION
		list.Sort()
		
		Local lastcar:TCar
		
		' Find current replay car then choose previous one
		For Local c:TCar = EachIn list
			' If this is the current replay car then send back id of previous one
			If c.mydriver.id = replaycarid And lastcar 
				replaycarid = lastcar.mydriver.id
				Return
			EndIf
			
			lastcar = c
		Next
		
		' If we got current replay car is the first one then return the last car
		For Local c:TCar = EachIn list
			lastcar = c
		Next
		
		replaycarid = lastcar.mydriver.id
	End Function
	
	Function ReplayCarBehind()
		If Not list Then Return
		
		sortby = CSORT_REPLAYPOSITION
		list.Sort()
		
		Local lastid:Int = 0
		
		' Find current replay car then choose next one
		For Local c:TCar = EachIn list
			If lastid = replaycarid Then replaycarid = c.mydriver.id; Return
			lastid = c.mydriver.id
		Next
		
		' If we got through the whole list then return the first car
		For Local c:TCar = EachIn list
			replaycarid = c.mydriver.id
			Return
		Next
	End Function
	
	Function UpdateReplayDataAll()
		' Don't add replay frames if online or not driving or if on the grid
	'	If TOnline.netstatus Then Return
		If track.mode <> CTRACKMODE_DRIVE Or track.racestatus = CRACESTATUS_GRID Then Return
		
		For Local c:TCar = EachIn list
			c.UpdateReplayData()
		Next
	
	End Function
	
	Method UpdateReplayData()
		l_ReplayFrames.AddLast(TReplayFrame.Create(Self))
	End Method

	Function ResetReplayFramesAll()
		AppLog "ResetReplayFramesAll"
		
		For Local obj:TCar = EachIn list
			obj.link_CurrentFrame = obj.l_ReplayFrames.FirstLink()
		Next
	End Function
	
	Function ClearReplayFramesAll()
		For Local obj:TCar = EachIn list
			obj.l_ReplayFrames.Clear()
		Next
	End Function
	
	Function LastReplayFrameAll()
		AppLog "LastReplayFrameAll"
		
		For Local obj:TCar = EachIn list
			obj.link_CurrentFrame = obj.l_ReplayFrames.LastLink()
			obj.ReplayFrame()
			
			' Make sure cars continue from end of last frame if they have finished the race (as they will continue after replay stops recording)
			If obj.RaceIsOver()
				obj.nextwp = track.GetNearestWaypoint(obj.x, obj.y, track.l_waypoints, False)
				obj.nextwp = track.GetWayPoint(obj.nextwp.id+1, track.l_waypoints)
			End If
		Next
	End Function
	
	Function ReplayStepAll(speed:Float)
		Global lastftime:Int = 0
		
		Local slowmo:Int = 0
		If speed = 2 Then slowmo = 50
		
		If MilliSecs() >= lastftime+update_time+slowmo	'GetGameSpeed()	'(Float(update_time)*Abs(speed))
			If speed < 0
				For Local obj:TCar = EachIn list
					obj.link_CurrentFrame = obj.link_CurrentFrame.PrevLink()
					If obj.link_CurrentFrame = Null Then obj.link_CurrentFrame = obj.l_ReplayFrames.FirstLink()
					
					' Skip frames for rwd
					If speed = -0.1 
						obj.link_CurrentFrame = obj.link_CurrentFrame.PrevLink()
						If obj.link_CurrentFrame = Null Then obj.link_CurrentFrame = obj.l_ReplayFrames.FirstLink()
						obj.link_CurrentFrame = obj.link_CurrentFrame.PrevLink()
						If obj.link_CurrentFrame = Null Then obj.link_CurrentFrame = obj.l_ReplayFrames.FirstLink()
					EndIf
				Next
			Else
				For Local obj:TCar = EachIn list
					obj.link_CurrentFrame = obj.link_CurrentFrame.NextLink()
					If obj.link_CurrentFrame = Null Then obj.link_CurrentFrame = obj.l_ReplayFrames.LastLink()
					
					' Skip frames for ffwd
					If speed = 0.1
						obj.link_CurrentFrame = obj.link_CurrentFrame.NextLink()
						If obj.link_CurrentFrame = Null Then obj.link_CurrentFrame = obj.l_ReplayFrames.LastLink()
						obj.link_CurrentFrame = obj.link_CurrentFrame.NextLink()
						If obj.link_CurrentFrame = Null Then obj.link_CurrentFrame = obj.l_ReplayFrames.LastLink()
					EndIf
				Next
			EndIf
			
			lastftime = MilliSecs()
			
			ReplayFrameAll()
		EndIf
	End Function
	
	Function ReplayFrameAll()
		For Local obj:TCar = EachIn list
			obj.ReplayFrame()
		Next
	End Function

	Method ReplayFrame()
		Local frame:TReplayFrame = TReplayFrame(link_CurrentFrame.Value())
		
		If frame
			x = frame.x
			y = frame.y
			direction = frame.direction
			steer = frame.steer
			position = frame.pos
			fuel = frame.fuel
			damage = frame.damage
			tyrewear = frame.tyrewear
			kers = frame.kers
			gassing = frame.gassing
			tyretype = frame.tyretype
		EndIf
	End Method
	
	Function ReplayFirstFrameAll()
		For Local obj:TCar = EachIn list
			obj.link_CurrentFrame = obj.l_ReplayFrames.FirstLink()
		Next
	End Function
	
	Function ReplayLastFrameAll()
		For Local obj:TCar = EachIn list
			obj.link_CurrentFrame = obj.l_ReplayFrames.LastLink()
		Next
	End Function
	
	Function ReplayNextLapAll()
		Local repcar:TCar = TCar.SelectReplayCar()
		If Not repcar.link_CurrentFrame Then Return
				
		Local currentlap:Int = TReplayFrame(repcar.link_CurrentFrame.Value()).lap
		Local lap:Int = currentlap
		Local raceend:Int = False
		 
		Repeat
			For Local obj:TCar = EachIn list
				obj.link_CurrentFrame = obj.link_CurrentFrame.NextLink()
				If obj.link_CurrentFrame = Null Then obj.link_CurrentFrame = obj.l_ReplayFrames.LastLink(); raceend = True
				
				If obj = repcar
					lap = TReplayFrame(obj.link_CurrentFrame.Value()).lap
				EndIf
			Next
		Until lap > currentlap Or raceend
		
	End Function
	
	Function ReplayPreviousLapAll()
		Local repcar:TCar = TCar.SelectReplayCar()
		If Not repcar.link_CurrentFrame Then Return
				
		Local currentlap:Int = TReplayFrame(repcar.link_CurrentFrame.Value()).lap
		Local lap:Int = currentlap
		Local raceend:Int = False
		 
		Repeat
			For Local obj:TCar = EachIn list
				obj.link_CurrentFrame = obj.link_CurrentFrame.PrevLink()
				If obj.link_CurrentFrame = Null Then obj.link_CurrentFrame = obj.l_ReplayFrames.FirstLink(); raceend = True
				
				If obj = repcar
					lap = TReplayFrame(obj.link_CurrentFrame.Value()).lap
				EndIf
			Next
		Until lap < currentlap-1 Or raceend
		
	End Function
	
	Function GhostStep()
		' Ghost car is for practice only
		If track.racestatus <> CRACESTATUS_PRACTICE Then Return
		
		Local car:TCar = TCar.SelectHumanCar()
		
		If Not car Then Return
		If Not car.link_CurrentGhostFrame Then Return
		
		car.link_CurrentGhostFrame = car.link_CurrentGhostFrame.NextLink()
		If car.link_CurrentGhostFrame = Null Then car.link_CurrentGhostFrame = car.l_GhostLap.LastLink()
			
		car.GhostFrame()
	End Function
	
	Method ResetGhostLap()
		link_CurrentGhostFrame = l_GhostLap.FirstLink()
	End Method
	
	Method GhostFrame()
		Local frame:TReplayFrame = TReplayFrame(link_CurrentGhostFrame.Value())
		
		If frame
			oldgx = gx
			oldgy = gy
			
			gx = frame.x
			gy = frame.y
			gdirection = frame.direction
			gsteer = frame.steer
		EndIf
	End Method
	
	Function DrawAll(tween:Float)
		For Local c:TCar = EachIn list
			c.Draw(tween)
		Next
		
		' Don't show info or spray for replays
		If track.mode <> CTRACKMODE_REPLAYING
			For Local c:TCar = EachIn list
				c.DrawBlur(tween)
				c.DrawParticles(tween)
			Next
		EndIf
		
		SetScale(1,1)
		SetRotation(0)
	End Function
	
	Function DrawAllMini()
		For Local c:TCar = EachIn list
			c.DrawMini()
		Next
		
		SetScale(1,1)
		SetRotation(0)
	End Function
	
	Method Draw(tween:Float)
		SetScale(track.scale,track.scale)
		
		' interpolate between old and actual positions
		Local tx# = x * tween + oldx * (1.0 - tween)
		Local ty# = y * tween + oldy * (1.0 - tween)
		Local ghostx# = gx * tween + oldgx * (1.0 - tween)
		Local ghosty# = gy * tween + oldgy * (1.0 - tween)
		Local ox:Float = originx * tween + oldoriginx * (1.0 - tween)
		Local oy:Float = originy * tween + oldoriginy * (1.0 - tween)
		
		tx:*track.scale
		ty:*track.scale
		
		' Draw car
		ResetDrawing()
		SetRotation(direction)
		
		If track.mode <> CTRACKMODE_REPLAYING And RaceIsOver() Then SetAlpha(0.5)
		
		If ox+tx > -32 And oy+ty > -32 And ox+tx < screenW+32 And oy+ty < screenH+32
			If controller = CCONTROLLER_REMOTE And TOnline.netstatus 
				If TOnline.chk_Online_Quali.GetState() = True Or TOnline.chk_Online_Collisions.GetState() = False
					SetAlpha(0.5)
				EndIf
			End If
			
			DrawImage(img, ox+tx, oy+ty)
			
			SetAlpha(1.0)
			
			If l_GhostLap.Count() > 0 And track.mode = CTRACKMODE_DRIVE And track.racestatus = CRACESTATUS_PRACTICE And OpGhost
				If link_CurrentGhostFrame <> l_GhostLap.LastLink()
					SetAlpha(0.5)
					SetRotation(gdirection)
					DrawImage(img, ox+(ghostx*track.scale), oy+(ghosty*track.scale))
				EndIf
			End If
			
			' Draw hiliter
			If controller = CCONTROLLER_HUMAN
				SetAlpha(0)
				If track.lightsalpha > 0 Then SetAlpha(track.lightsalpha); SetColor(255,255,0)
				If slipstream > 0 Then SetAlpha(slipstream); SetColor(40,40,255)
				
				SetScale(track.scale,track.scale)
				DrawImage(img_HiLite, ox+tx+(Cos(direction+180)*7*track.scale), oy+ty+(Sin(direction+180)*7*track.scale))
				SetColor(255,255,255)
			EndIf
			
			SetRotation(0)
			
			' Draw mini info panel
			If infoalpha > 0 
				DrawMiniInfo(ox,oy, tx, ty)
			Else
				' Boost meter
				If controller = CCONTROLLER_HUMAN And boost
					SetScale(1,1)
					SetAlpha(0.4)
					Local ix:Int = ox+tx
					Local iy:Int = oy+ty-80
					SetColor(50,50,50)
					DrawRect(ix-26, iy, 50, 8)
					SetColor(70,115,255)
					DrawRect(ix-25, iy+1, kers/2, 6)
					SetColor(255,255,255)
				End If
				
				If (OpNames Or TOnline.netstatus <> CNETWORK_NONE) And mydriver.name <> "COM"
					Local name:String = mydriver.shortname
					SetScale(1,1)
					SetAlpha(0.35)
					Local ix:Int = ox+tx+5
					Local iy:Int = oy+ty-45
					fnt_Small.Draw(name, ix, iy-10-fntoffset_Small,1)
				EndIf
			EndIf
		EndIf
		
		SetAlpha(1)
		SetRotation(0)
		
		' Show driver order/speedo
		If controller = CCONTROLLER_HUMAN 
			If infoalpha > 0 And track.racestatus <> CRACESTATUS_PRACTICE
				' Don't show driver order during replays
				If track.mode <> CTRACKMODE_REPLAYING Then DrawDriverOrderPanel()
			ElseIf OpSpeedo
				If track.mode <> CTRACKMODE_REPLAYING Or mydriver.id = replaycarid
					DrawSpeedo()
				EndIf
			EndIf
		EndIf
		
		' Collision check
		If gShowCollCircles
			coll_fleft.Draw()
			coll_fright.Draw()
			coll_left.Draw()
			coll_right.Draw()
			coll_rleft.Draw()
			coll_rright.Draw()
		End If
		
		SetAlpha(1)
	End Method
	
	Method DrawMiniInfo(ox:Float, oy:Float, tx:Float, ty:Float)
		SetScale(1,1)
				
		Local ix:Int = ox+tx+5
		Local iy:Int = oy+ty-90
		
		DrawRacePanel(ix-40,iy-5,82,75,164,164,164,OpPanelAlpha*infoalpha)
		
		SetAlpha(infoalpha)
	
		' Gauges
		SetColor(0,0,0)
		DrawRect(ix-19, iy+24, 52, 8)
		DrawRect(ix-19, iy+38, 52, 8)
		DrawRect(ix-19, iy+52, 52, 8)
		
		' Damage
		SetColor(255,0,0)
		DrawRect(ix-18, iy+25, damage/2, 6)
		DrawImage(img_Damage, ix-35, iy+20)
		
		' Fuel
		SetColor(150,250,80)
		DrawRect(ix-18, iy+39, fuel/2, 6)
		DrawImage(img_Fuel, ix-35, iy+35)
		
		' Tyres
		SetColor(100,100,100)
		DrawRect(ix-18, iy+53, tyrewear/2, 6)
		
		SetColor(255,255,255)
		Select tyretype
		Case CTYRE_SOFT		DrawImage(img_TyreSmall_Soft, ix-34, iy+50)
		Case CTYRE_HARD		DrawImage(img_TyreSmall_Hard, ix-34, iy+50)
		Case CTYRE_WET		DrawImage(img_TyreSmall_Wet, ix-34, iy+50)
		End Select
		
		Local name:String = mydriver.shortname
		fnt_Small.Draw(name, ix, iy-16, 1)
		
		' Position or pittime
		If track.mode = CTRACKMODE_DRIVE 
			If pitstop = 0 And gMillisecs > pittimedisplay + 3500
				strpittime = GetPositionString()
			Else
				If pitstop > 0
					pittime = gMillisecs-pitstop
					pittimedisplay = gMillisecs
				End If
				
				strpittime = GetStringTime(pittime, True)
			EndIf
		EndIf
		
		fnt_Medium.Draw(strpittime, ix, iy-4-fntoffset_Medium,1)
	End Method
	
	Method DrawDriverOrderPanel()
		SetAlpha(infoalpha)
		SetScale(1,1)
		DrawRacePanel(15,screenH-410,240,394,164,164,164,OpPanelAlpha*infoalpha)
		
		Local py:Int = screenH-405
		
		For Local c:TCar = EachIn TCar.list
			SetColor(255,255,255)
			
			Select c.tyretype 
			Case CTYRE_SOFT		DrawImage(img_TyreSoft, 22, py+1)
			Case CTYRE_HARD		DrawImage(img_TyreHard, 22, py+1)
			Case CTYRE_WET		DrawImage(img_TyreWet, 22, py+1) 
			End Select
			
			If c.controller = CCONTROLLER_HUMAN Then SetColor(255,255,0)
			Local nm:String = c.position+" "+c.mydriver.shortname
			fnt_Small.Draw(nm, 38, py+9)
			py:+16
		Next
	End Method
	
	Method DrawSpeedo()
		If sportsname <> "" Then Return
		
		ResetDrawing()
		Local scl:Float = Float(600.0/900.0)
		If scl > 1 Then scl = 1
		SetScale(scl,scl)
		
		Local spx:Int = 10
		Local spy:Int = screenH-(394*scl)
		DrawImage(img_Speedo, spx, spy)
		
		Local rot:Float
		
		rot = (360+(gear*-18))*revs
		
		SetRotation(rot)
		DrawImage(img_Needle, spx+(224*scl), spy+(128*scl))
		
		SetRotation(0)
		SetColor(128,128,128)
		Local tx:Float = 320
		Local ty:Float = 154
		fnt_Medium.Draw(str_Gear + " " + gear, spx + (tx*scl), spy + (ty*scl),1,1); ty:+32
		
		If gassing = 1
			SetColor(0,255,0)
			DrawRect(spx + (259*scl), spy + (163*scl), 92, 26)
		End If
		
		' Throttle
		SetColor(255,255,255)
		fnt_Medium.Draw(str_Throttle, spx + ((tx+4)*scl), spy + (ty*scl),1,1); ty:+32
		
		' Brake
		If gassing = -1
			SetColor(255,0,0)
			DrawRect(spx + (259*scl), spy + (195*scl), 93, 26)
		End If
		
		SetColor(255,255,255)
		fnt_Medium.Draw(str_Brake, spx + (tx*scl), spy + (ty*scl),1,1); ty:+32
		
		' KERS
		If kers > 0
			SetColor(70,115,255)
			DrawRect(spx + (260*scl), spy + (228*scl), (85.0/100.0)*kers, 24)
		End If
		
		SetColor(255,255,255)
		fnt_Medium.Draw(str_Kers, spx + ((tx-4)*scl), spy + (ty*scl),1,1)
		
		' Draw speed		
		Local block:Float = (CTOPSPEED_STANDARD/16.0)
		For Local s:Int = 0 To 17
			If Abs(speed) > block*(s+1) Then speedalpha[s]:+0.01 Else speedalpha[s]:-0.01
			If speedalpha[s] < 0 Then speedalpha[s] = 0
			If speedalpha[s] > 1 Then speedalpha[s] = 1
		Next
		
		SetColor(0, 255, 0)
		SetAlpha(speedalpha[0]); DrawImage(img_SpeedBlocks, spx+6*scl, spy+320*scl, 1)
		SetAlpha(speedalpha[1]); DrawImage(img_SpeedBlocks, spx+24*scl, spy+320*scl, 0)
		SetAlpha(speedalpha[2]); DrawImage(img_SpeedBlocks, spx+46*scl, spy+320*scl, 0)
		SetAlpha(speedalpha[3]); DrawImage(img_SpeedBlocks, spx+68*scl, spy+320*scl, 0)
		SetAlpha(speedalpha[4]); DrawImage(img_SpeedBlocks, spx+90*scl, spy+320*scl, 0)
		SetAlpha(speedalpha[5]); DrawImage(img_SpeedBlocks, spx+112*scl, spy+320*scl, 0)
		SetAlpha(speedalpha[6]); DrawImage(img_SpeedBlocks, spx+134*scl, spy+320*scl, 0)
		SetAlpha(speedalpha[7]); DrawImage(img_SpeedBlocks, spx+156*scl, spy+320*scl, 0)
		SetAlpha(speedalpha[8]); DrawImage(img_SpeedBlocks, spx+178*scl, spy+320*scl, 0)
		
		SetColor(255, 255, 0)
		SetAlpha(speedalpha[9]); DrawImage(img_SpeedBlocks, spx+200*scl, spy+320*scl, 1)
		SetAlpha(speedalpha[10]); DrawImage(img_SpeedBlocks, spx+218*scl, spy+320*scl, 1)
		SetAlpha(speedalpha[11]); DrawImage(img_SpeedBlocks, spx+236*scl, spy+320*scl, 2)
		
		SetColor(240, 105, 0)
		SetAlpha(speedalpha[12]); DrawImage(img_SpeedBlocks, spx+247*scl, spy+315*scl, 3)
		SetAlpha(speedalpha[13]); DrawImage(img_SpeedBlocks, spx+258*scl, spy+308*scl, 4)
		SetAlpha(speedalpha[14]); DrawImage(img_SpeedBlocks, spx+266*scl, spy+300*scl, 5)
		
		SetColor(255, 0, 0)
		SetAlpha(speedalpha[15]); DrawImage(img_SpeedBlocks, spx+270*scl, spy+290*scl, 6)
		SetAlpha(speedalpha[16]); DrawImage(img_SpeedBlocks, spx+272*scl, spy+276*scl, 7)
		SetAlpha(speedalpha[17]); DrawImage(img_SpeedBlocks, spx+272*scl, spy+258*scl, 8)
		
		' Damage
		SetAlpha(1)
		SetColor(255,0,0)
		DrawRect(spx+27*scl, spy+215*scl, (62.0/100.0)*damage, 18)
		
		' Fuel
		SetColor(150,250,80)
		DrawRect(spx+27*scl, spy+247*scl, (62.0/100.0)*fuel, 18)

		' Tyres
		SetColor(100,100,100)
		DrawRect(spx+27*scl, spy+279*scl, (62.0/100.0)*tyrewear, 18)
		
		SetColor(255,255,255)
		Select tyretype
		Case CTYRE_SOFT		DrawImage(img_TyreSmall_Soft, spx+6*scl, spy+282*scl)
		Case CTYRE_HARD		DrawImage(img_TyreSmall_Hard, spx+6*scl, spy+282*scl)
		Case CTYRE_WET		DrawImage(img_TyreSmall_Wet, spx+6*scl, spy+282*scl)
		End Select
		
		SetScale(1,1)
	End Method
	
	Method DrawParticles(tween:Float)
		SetRotation(0)
		
		' interpolate between old and actual positions
		Local tx# = x * tween + oldx * (1.0 - tween)
		Local ty# = y * tween + oldy * (1.0 - tween)
		Local ox:Float = originx * tween + oldoriginx * (1.0 - tween)
		Local oy:Float = originy * tween + oldoriginy * (1.0 - tween)
		
		' Draw Smoke/Dust/Rain Particles
		For Local p:TParticle = EachIn l_Particles
			SetColor(p.r,p.g,p.b)
			SetAlpha(p.a)
			SetScale(p.scale*track.scale, p.scale*track.scale)
			Local px:Int = ox+(p.x*track.scale)
			Local py:Int = oy+(p.y*track.scale)
			
			If px > -32 And py > -32 And px < screenW+32 And py < screenH+32
				SetRotation(p.rot)
				DrawImage(p.imgSmoke, px, py)
				SetRotation(0)
			EndIf
		Next
		
		' Rain light
		If sportsname <> "" Or gRainLight = False Then Return
		
		If track.weather.wetness > 0.2 And (gMillisecs Mod 400) < 200 
			SetColor(255,0,0)
			
			Local lx:Float = ox+(tx-(Cos(direction)*24))*track.scale
			Local ly:Float = oy+(ty-(Sin(direction)*24))*track.scale
			
			If lx > -32 And ly > -32 And lx < screenW+32 And ly < screenH+32
				SetAlpha(0.2)
				SetScale(track.scale*0.75,track.scale*0.75)
				DrawImage(TParticle.imgSpark,lx,ly)
				
				SetAlpha(0.8)
				SetScale(track.scale*0.15,track.scale*0.15)
				DrawImage(TParticle.imgSpark,lx,ly)
			EndIf
		End If
	End Method
	
	Method DrawBlur(tween:Float)
		' Draw motion blur
		SetColor(255,255,255)
		
		For Local p:TBlur = EachIn l_blur
			SetAlpha(p.a)
			SetRotation(p.r)			
			SetScale(p.s*track.scale, p.s*track.scale)
			
			Local px:Int = originx+(p.x*track.scale)
			Local py:Int = originy+(p.y*track.scale)
			
			If px > - 32 And py > - 32 And px < screenW + 32 And py < screenH + 32
				DrawImage(img, px, py)
			EndIf
		Next
	End Method

	Method DrawMini()
		'SetScale(1,1)
	
		' Draw car
		ResetDrawing()
		
		Select controller
		Case CCONTROLLER_HUMAN
			SetScale(0.3,0.3)
			SetColor(255,255,0)
			DrawImage(img_HiLite, track.mapoffsetx+(x/16)-(Cos(direction)*2), track.mapoffsety+(y/16)-(Sin(direction)*2))
			SetColor(255,255,255)
		Case CCONTROLLER_REMOTE
			If mydriver.name <> "COM"
				SetScale(0.3,0.3)
				SetColor(128,128,255)
				DrawImage(img_HiLite, track.mapoffsetx+(x/16)-(Cos(direction)*2), track.mapoffsety+(y/16)-(Sin(direction)*2))
				SetColor(255,255,255)
			EndIf
		End Select
		
		SetRotation(direction)
		SetScale(0.4,0.4)
		DrawImage(img, track.mapoffsetx+(x/16), track.mapoffsety+(y/16))
	End Method
		
	Function ResetStartingPositions()
		AppLog "ResetStartingPositions"
		If Not track.tileset Then Return
		
		' Online qualifying puts all racers on same grid position
		If TOnline.netstatus And TOnline.chk_Online_Quali.GetState() = True
			For Local tx:Int = 0 To track.trackw-1
			For Local ty:Int = 0 To track.trackh-1
				Local id:Int = track.tile_level[1,tx,ty].id
				Local rot:Int = track.tile_level[1,tx,ty].rotation
				
				If id > -1 And track.tileset.tracktile_array[id].name = "Track_10.png"
					Local posx:Float = tx*track.mastertilesize
					Local posy:Float = ty*track.mastertilesize
					
					For Local c:TCar = EachIn TCar.list
						c.fuel = 10
						c.x = 236
						c.y = 98
						DoXYRotation(c.x, c.y, rot, track.mastertilesize)
						c.x:+posx
						c.y:+posy
						c.direction = rot
						c.nextwp = Null
					Next
					
					Exit
				EndIf
			Next
			Next
			Return
		EndIf
			
		Select track.racestatus
		Case CRACESTATUS_PRACTICE
			Local c:TCar = TCar.SelectHumanCar()
			c.fuel = 30
			If c.mydriver.id = gMyDriverId Then c.fuel = 10
			If Not OpFuel Then c.fuel = 75
			
			c.FindPitBay(c.x, c.y, True)
			c.pitting = True
			c.nextwp = track.GetNearestWayPoint(c.x, c.y, track.l_pitwaypoints)
			Return
			
		Case CRACESTATUS_QUALIFY
			For Local c:TCar = EachIn TCar.list
				c.fuel = 30
				
				If c.mydriver.id = gMyDriverId 
					c.fuel = 10
				EndIf
				
				If Not OpFuel Then c.fuel = 75
				
				c.FindPitBay(c.x, c.y, True)
				c.pitting = True
				c.nextwp = track.GetNearestWayPoint(c.x, c.y, track.l_pitwaypoints,False)
				c.nextwp = track.GetWayPoint(c.nextwp.id+1, track.l_pitwaypoints)
			Next	
			Return
				
		Default
			For Local c:TCar = EachIn TCar.list
				If c.controller = CCONTROLLER_HUMAN 
					c.fuel = 10
				Else
					Select c.tyretype 
					Case CTYRE_HARD		c.fuel = 65+Rand(15)
					Case CTYRE_SOFT 	c.fuel = 35+Rand(15)
					Case CTYRE_WET		c.fuel = 65+Rand(15)
					End Select
				EndIf
				
				'If c.controller = CCONTROLLER_CPU And OpLaps < 5 Then c.fuel:*0.75
				If Not OpFuel Then c.fuel = 100
			Next
			
			For Local tx:Int = 0 To track.trackw-1
			For Local ty:Int = 0 To track.trackh-1
				Local car1:TCar
				Local car2:TCar
				Local car3:TCar
				Local car4:TCar
				Local id:Int = track.tile_level[1,tx,ty].id
				Local rot:Int = track.tile_level[1,tx,ty].rotation
				
				If id > -1
					Local name:String = track.tileset.tracktile_array[id].name
					Local posx:Float = tx*track.mastertilesize
					Local posy:Float = ty*track.mastertilesize
				
					Select name
					Case "Track_10.png"		car1 = GetCarByPosition(1); car2 = GetCarByPosition(2);	car3 = GetCarByPosition(3); car4 = GetCarByPosition(4)
					Case "Track_11.png"		car1 = GetCarByPosition(5); car2 = GetCarByPosition(6);	car3 = GetCarByPosition(7); car4 = GetCarByPosition(8)
					Case "Track_12.png"		car1 = GetCarByPosition(9); car2 = GetCarByPosition(10);	car3 = GetCarByPosition(11); car4 = GetCarByPosition(12)
					Case "Track_13.png"		car1 = GetCarByPosition(13); car2 = GetCarByPosition(14);	car3 = GetCarByPosition(15); car4 = GetCarByPosition(16)
					Case "Track_14.png"		car1 = GetCarByPosition(17); car2 = GetCarByPosition(18);	car3 = GetCarByPosition(19); car4 = GetCarByPosition(20)
					Case "Track_15.png"		car1 = GetCarByPosition(21); car2 = GetCarByPosition(22);	car3 = GetCarByPosition(23); car4 = GetCarByPosition(24)
					End Select
					
					If car1
						car1.x = 236
						car1.y = 98
						DoXYRotation(car1.x, car1.y, rot, track.mastertilesize)
						car1.x:+posx
						car1.y:+posy
						car1.direction = rot
						car1.nextwp = Null
					EndIf
					
					If car2
						car2.x = 167
						car2.y = 157
						DoXYRotation(car2.x, car2.y, rot, track.mastertilesize)
						car2.x:+posx
						car2.y:+posy
						car2.direction = rot
						car2.nextwp = Null
					EndIf
					
					If car3
						car3.x = 98
						car3.y = 98
						DoXYRotation(car3.x, car3.y, rot, track.mastertilesize)
						car3.x:+posx
						car3.y:+posy
						car3.direction = rot
						car3.nextwp = Null
					EndIf
					
					If car4
						car4.x = 29
						car4.y = 157
						DoXYRotation(car4.x, car4.y, rot, track.mastertilesize)
						car4.x:+posx
						car4.y:+posy
						car4.direction = rot
						car4.nextwp = Null
					EndIf
				EndIf
				
			Next
			Next
		End Select
	
	End Function
	
	Method FindPitBay(posx:Float Var, posy:Float Var, forcepit:Int = False)
		If Not track.tileset Then Return
		If controller = CCONTROLLER_HUMAN And RaceIsOver() = False Then pitting = False
		
		For Local tx:Int = 0 To track.trackw-1
		For Local ty:Int = 0 To track.trackh-1
			Local id:Int = track.tile_level[1,tx,ty].id
			Local rot:Int = track.tile_level[1,tx,ty].rotation
			
			If id > -1
				Local bay:Int = 0
				Local name:String = track.tileset.tracktile_array[id].name
				
				Select mydriver.team
				Case 1	If name = "Track_18.png" Then bay = 1
				Case 2	If name = "Track_18.png" Then bay = 2
				Case 3	If name = "Track_19.png" Then bay = 1
				Case 4	If name = "Track_19.png" Then bay = 2
				Case 5	If name = "Track_20.png" Then bay = 1
				Case 6	If name = "Track_20.png" Then bay = 2
				Case 7	If name = "Track_21.png" Then bay = 1
				Case 8	If name = "Track_21.png" Then bay = 2
				Case 9	If name = "Track_22.png" Then bay = 1
				Case 10	If name = "Track_22.png" Then bay = 2
				Case 11	If name = "Track_23.png" Then bay = 1
				Case 12	If name = "Track_23.png" Then bay = 2
				'Case 13	If name = "Track_24.png" Then bay = 1
				'Case 14	If name = "Track_24.png" Then bay = 2
				End Select
				
				Local bayx:Float
				Local bayy:Float
				
				Select bay
				Case 1
					bayx = 32
					bayy = 61
				Case 2
					bayx = 163
					bayy = 61
				End Select
				
				' Use 2 bays per team
				If mydriver.drivernumber = 2 Then bayx:+60
				
				' Rotate position if tile rotated
				DoXYRotation(bayx, bayy, rot, track.mastertilesize)
				
				bayx:+(tx*track.mastertilesize)
				bayy:+(ty*track.mastertilesize)
				
				If bay > 0 And (forcepit Or (GetDistance(x,y,bayx,bayy) < 200 And gMillisecs > lastpitstop+10000))
					If controller = CCONTROLLER_HUMAN Then pitting = True
						
					posx = bayx
					posy = bayy
					
					If forcepit Or GetDistance(x,y,bayx,bayy) < 40
						x = posx
						y = posy
						direction = rot+180
						
						If pitstop = 0 
							AppLog "Enter pit bay"
							minimumpit = 1000+Rand(100)	' Reset minimum pit time
							If controller = CCONTROLLER_HUMAN And RaceIsOver() = False Then track.pitstop()
							pitstop = gMillisecs+1
						Else
							' Display damage/fuel if this isn't end of race pit
							If RaceIsOver() = False Then infoalpha = 5.0
							
							' Position car
							speed = 0
							drift = 0
							steer = 0
							xvel = 0
							yvel = 0
							direction = 180
							direction:+rot
							If direction > 360 Then direction:-360
					
							' Check pit entrance/exit direction		
							Local pitpoint1:TWayPoint = track.GetWayPoint(1, track.l_pitwaypoints)
				
							Select rot
							Case 0		If pitpoint1.x < x Then direction:+180; x:+10
							Case 90		If pitpoint1.y < y Then direction:+180; y:+10
							Case 180	If pitpoint1.x > x Then direction:+180; x:-10
							Case 270	If pitpoint1.y > y Then direction:+180; y:-10
							End Select
							
							If direction > 360 Then direction:-360
							Draw(1)
							
							' Fix up car
							Local repairspeed:Float = 0.2
							
							If controller = CCONTROLLER_HUMAN And Not TOnline.netstatus
								repairspeed = 0.15+(Float(gRelPitCrew)/500.0)
							End If
							
							damage:-repairspeed*GetGameSpeed()
							If OpFuel Then fuel:+repairspeed*GetGameSpeed(); fuellastlap = 0
							
							If damage < 0 Then damage = 0
							
							Local maxfuel:Int = 100
							
							Select controller
							Case CCONTROLLER_HUMAN
								maxfuel = track.pitstop_fuel
								
							Case CCONTROLLER_CPU
								ComChooseTyre()
								If fuelconsumption < 1
									maxfuel = 100
								Else
									maxfuel = fuelconsumption*(track.totallaps+1-lapscomplete)	' Fuel for 1 extra lap
									If maxfuel >= 100 Then maxfuel = 65
								End If
								
								If track.racestatus = CRACESTATUS_QUALIFY Then maxfuel = 50
							End Select
							
							If maxfuel < fuel Then maxfuel = fuel
							If fuel >= maxfuel Then fuel = maxfuel
							
							If RaceIsOver() = False
								If chn_HumanCrashFX And Not chn_HumanCrashFX.Playing()
									chn_HumanCrashFX.SetVolume(OpVolumeFX)
									PlaySound(snd_Pits, chn_HumanCrashFX)
								EndIf
							EndIf
							
							If (track.mode <> CTRACKMODE_PITSTOP Or controller <> CCONTROLLER_HUMAN)
								If damage = 0 And (fuel = maxfuel Or OpFuel = 0) And gMillisecs > pitstop+minimumpit And RaceIsOver() = False
									AppLog "Exit pit bay"
									pitstop = 0 
									steer = 0
									speed = 0
									drift = 0
									lastpitstop = gMillisecs
								EndIf
							EndIf
						EndIf
					End If
				End If
			EndIf
			
		Next
		Next
	End Method
	
	Function GetCarByPosition:TCar(pos:Int)
		For Local c:TCar = EachIn list
			If c.position = pos Then Return c
		Next
		
		Return Null
	End Function
	
	Method GetTeamMateCar:TCar()
		For Local c:TCar = EachIn list
			If c.mydriver.team = mydriver.team Then Return c
		Next
		
		Return Null
	End Method
	
	Method GetPositionString:String()
		Select position
		Case 1	Return "1st"
		Case 2	Return "2nd"
		Case 3	Return "3rd"
		Default	Return String(position)+"th"
		EndSelect
	End Method
	
	Function PauseSound(p:Int)
		For Local c:TCar = EachIn list
			If c.chn_MyEngine Then c.chn_MyEngine.SetVolume(0)
			If c.chn_HumanTerrain Then c.chn_HumanTerrain.SetVolume(0)
		Next
	End Function
	
	Function SetTyresAll()
		For Local c:TCar = EachIn list
			c.tyretype = CTYRE_HARD
			If c.mydriver.id <> gMyDriverId 
				If Rand(2) = 1 Or track.racestatus = CRACESTATUS_QUALIFY Then c.tyretype = CTYRE_SOFT
			EndIf
			
			If track.weather.doingweather Or track.weather.wetness > 0.8 Then c.tyretype = CTYRE_WET
		Next
	End Function
	
	Method ComChooseTyre()
		' Change tyre due to weather
		If track.weather.doingweather And track.weather.wetness > 0.2 And tyretype <> CTYRE_WET
			ChangeTyre(CTYRE_WET)
			Return
		EndIf
		
		If track.weather.doingweather = False And track.weather.wetness < 0.8 And tyretype = CTYRE_WET
			If mydriver.id = gMyDriverId
				ChangeTyre(CTYRE_HARD)
			Else
				Select Rand(2)
				Case 1	ChangeTyre(CTYRE_SOFT)
				Case 2	ChangeTyre(CTYRE_HARD)
				End Select
			EndIf
			
			Return
		End If
		
		' Change tyre due to tyre wear or becuase you have time to do it
		If tyrewear < 75 Or damage > 50 Or fuel < 50 
			Select Rand(2)
			Case 1	ChangeTyre(CTYRE_SOFT)
			Case 2	ChangeTyre(CTYRE_HARD)
			End Select
		EndIf
	End Method
	
	Method ChangeTyre(typ:Int)
		tyretype = typ
		tyrewear = 100
		
		' Make sure tyre change adds to pitstop time
		minimumpit = CTYRECHANGETIME
			
		If controller = CCONTROLLER_HUMAN And Not TOnline.netstatus
			minimumpit:+(100-gRelPitCrew)*10
		Else
			minimumpit:+Rand(750)
		EndIf
	End Method
	
	Method FitKers(f:Int)
		If mydriver.kersfitted <> f
			' Make sure kers change adds to pitstop time
			minimumpit:+CKERSCHANGETIME
		
			If controller = CCONTROLLER_HUMAN And Not TOnline.netstatus
				minimumpit:+(100-gRelPitCrew)*10
			Else
				minimumpit:+Rand(750)
			EndIf
		EndIf
		
		mydriver.kersfitted = f
		If mydriver.kersfitted = False Then kers = 0
	End Method
	
	Function ParadeLapComplete:Int()
		If track.racestatus <> CRACESTATUS_RACE Then Return False
		
		For Local c:TCar = EachIn TCar.list
			If Not c.RaceIsOver() Then Return False
			If c.pitstop = 0 And c.fuel > 0 And c.damage < 100 Then Return False
		Next
	
		Return True
	End Function
	
	Method RaceIsOver:Int()
		Select track.racestatus
		Case CRACESTATUS_GRID
		Case CRACESTATUS_RACE
			If lapscomplete >= track.totallaps Then Return True
			If mydriver.iwaslapped > 0 Then Return True
			
		Case CRACESTATUS_PRACTICE
			If lapscomplete >= track.totallaps Then Return True
		Case CRACESTATUS_QUALIFY
			If track.mode <> CTRACKMODE_PAUSED And (track.racestarttime+track.timelimit)-gMillisecs <= 0 
				If lastqualifyinglap = -99 Then lastqualifyinglap = lapscomplete
				If lapscomplete > lastqualifyinglap Then Return True
			EndIf
		End Select
		
	'	If fuel <= 0 Then Return True
		If damage >= 100 Then Return True
		
		Return False
	End Method
	
	Method Compare:Int(O:Object)
		Select sortby
		Case CSORT_POSITION
			' Check car has started and has fuel/no damage
			If TCar(O).lapscomplete = -1 Then Return -1
		'	If TCar(O).fuel <= 0 Then Return -1
			If TCar(O).damage >= 100 Then Return -1
			
			' Get Laps
			Local laps1:Int = TCar(O).lapscomplete
			Local laps2:Int = lapscomplete
			
			' Check laps
			If laps1 < laps2 Then Return -1 
			If laps1 > laps2 Then Return 1
			
			' Check to see if drivers have been lapped
			Local lapped1:Int = TCar(O).mydriver.iwaslapped
			Local lapped2:Int = mydriver.iwaslapped
			
			If lapped1 > lapped2 Then Return -1 
			If lapped1 < lapped2 Then Return 1
			
			' Get last checkpoint
			Local wl1:TWayLine = track.GetWayLine(TCar(O).lastwayline)
			Local wl2:TWayLine = track.GetWayLine(lastwayline)
			If Not wl1 Then Return -1
			If Not wl2 Then Return -1
			If wl1.id < wl2.id Then Return -1
			If wl1.id > wl2.id Then Return 1
			
			' Get Next waypoint id
			Local nwp1:TWayPoint = track.GetNearestWayPoint(TCar(O).x, TCar(O).y, track.l_waypoints, False)
			Local nwp2:TWayPoint = track.GetNearestWayPoint(x, y, track.l_waypoints, False)
			
			' Check way points
			If nwp1.id = 1 And TCar(O).lastwayline > 1 Then Return 1
			If nwp2.id = 1 And lastwayline > 1 Then Return -1
			
			If nwp1.id < nwp2.id Then Return -1 
			If nwp1.id > nwp2.id Then Return 1
			
			nwp1 = track.GetWayPoint(nwp1.id+1, track.l_waypoints)
			nwp2 = track.GetWayPoint(nwp2.id+1, track.l_waypoints)
			Local dist1:Float = GetDistance(TCar(O).x, TCar(O).y, nwp1.x, nwp1.y)
			Local dist2:Float = GetDistance(x, y, nwp2.x, nwp2.y)
			If dist1 > dist2 Then Return -1
			If dist1 < dist2 Then Return 1
		
		Case CSORT_REPLAYPOSITION
			If Not TCar(O).link_CurrentFrame Then Return -1
			If Not link_CurrentFrame Then Return 1
			
			Local pos1:Int = TReplayFrame(TCar(O).link_CurrentFrame.Value()).pos
			Local pos2:Int = TReplayFrame(link_CurrentFrame.Value()).pos
			
			If pos1 < pos2 Then Return 1 
			If pos1 > pos2 Then Return -1
			
		Case CSORT_FINISHTIME
			' Check laps
			Local laps1:Int = TCar(O).lapscomplete
			Local laps2:Int = lapscomplete
			
			If laps1 < laps2 Then Return -1 
			If laps1 > laps2 Then Return 1
			
			' Check lapped
			Local lapped1:Int = TCar(O).mydriver.iwaslapped
			Local lapped2:Int = mydriver.iwaslapped
			
			If lapped1 < lapped2 Then Return 1
			If lapped1 > lapped2 Then Return -1 
			
			Local ft1:Int = TCar(O).mydriver.lastracetime
			Local ft2:Int = mydriver.lastracetime
			
			' Make sure a time has been set
			If ft1 <= 0 Then ft1 = 999999999+TCar(O).position
			If ft2 <= 0 Then ft2 = 999999999+position
			
			If ft1 < ft2 Then Return 1
			If ft1 > ft2 Then Return -1 
			
		Case CSORT_QUALIFYINGTIME
			Local lt1:Int = TCar(O).bestlaptime
			Local lt2:Int = bestlaptime
			
			' Make sure a time has been set
			If lt1 <= 0 Then lt1 = 999999999+TCar(O).position
			If lt2 <= 0 Then lt2 = 999999999+position
			
			If lt1 < lt2 Then Return 1 
			If lt1 > lt2 Then Return -1 
			
		Case CSORT_RANDOM
			If randno < TCar(O).randno Then Return 1 
			If randno > TCar(O).randno Then Return -1
		
		Case CSORT_DRIVERID
			If mydriver.id < TCar(O).mydriver.id Then Return 1 
			If mydriver.id > TCar(O).mydriver.id Then Return -1
	
		End Select
		
		Return Super.Compare(O)
	EndMethod
	
End Type

Type TReplayFrame
	Field id:Byte
	Field controller:Byte
	Field x:Float
	Field y:Float
	Field direction:Float
	Field steer:Float
	Field lap:Byte
	Field pos:Byte
	Field fuel:Float
	Field damage:Float
	Field tyrewear:Float
	Field kers:Float
	Field gassing:Byte
	Field tyretype:Byte
	
	Function Create:TReplayFrame(c:TCar)
		Local newrep:TReplayFrame = New TReplayFrame
		
		newrep.id = c.mydriver.id
		newrep.controller = c.controller
		newrep.x = c.x
		newrep.y = c.y
		newrep.fuel = c.fuel
		newrep.damage = c.damage
		newrep.tyrewear = c.tyrewear
		newrep.kers = c.kers		
		newrep.gassing = c.gassing
		newrep.pos = c.position
		newrep.direction = c.direction
		newrep.steer = c.steer
		newrep.lap = c.lapscomplete+1
		newrep.tyretype = c.tyretype
		
		Return newrep
	End Function
	
	Function Copy:TReplayFrame(f:TReplayFrame)
		Local newrep:TReplayFrame = New TReplayFrame
		
		newrep.id = f.id
		newrep.controller = f.controller
		newrep.x = f.x
		newrep.y = f.y
		newrep.direction = f.direction
		newrep.steer = f.steer
		newrep.lap = f.lap
		newrep.pos = f.pos
		newrep.fuel = f.fuel
		newrep.damage = f.damage
		newrep.tyrewear = f.tyrewear
		newrep.kers = f.kers
		newrep.gassing = f.gassing
		newrep.tyretype = f.tyretype
		
		Return newrep
	End Function
	
	Method WriteToStream(str:TStream)
		str.WriteByte(id)
		str.WriteByte(controller)
		str.WriteFloat(x)
		str.WriteFloat(y)
		str.WriteFloat(direction)
		str.WriteFloat(steer)
		str.WriteByte(lap)
		str.WriteByte(pos)
		str.WriteFloat(fuel)
		str.WriteFloat(damage)
		str.WriteFloat(tyrewear)
		str.WriteFloat(kers)
		str.WriteByte(gassing)
		str.WriteByte(tyretype)
	End Method
	
	Method LoadFromStream(str:TStream)
		id = str.ReadByte()
		controller = str.ReadByte()
		x = str.ReadFloat()
		y = str.ReadFloat()
		direction = str.ReadFloat()
		steer = str.ReadFloat()
		lap = str.ReadByte()
		pos = str.ReadByte()
		fuel = str.ReadFloat()
		damage = str.ReadFloat()
		tyrewear = str.ReadFloat()
		kers = str.ReadFloat()
		gassing = str.ReadByte()
		If Not Eof(str) Then tyretype = str.ReadByte()
	End Method
End Type

Type TParticle
	Global imgSpark:TImage
	Global imgSmoke:TImage
	Global imgBits:TImage
	Global list:TParticle[]	'TList
	
	Field myimg:TImage
	Field x:Float
	Field y:Float
	Field xvel:Float
	Field yvel:Float
	
	Field a:Float
	Field scale:Float
	Field r:Int
	Field g:Int
	Field b:Int
	Field rot:Float
	
	Field life:Int
	Field im:Int
	
	Function SetUpParticleImage()
		imgSpark = LoadMyImage(gAppLoc+"Media/Cars/Spark.png")
		MidHandleImage(imgSpark)
		imgSmoke = LoadMyImage(gAppLoc+"Media/Cars/Smoke.png")
		MidHandleImage(imgSmoke)
		imgBits = LoadMyAnimImage(gAppLoc+"Media/Cars/Bits.png", 4, 4, 0, 4)
	End Function
	
	Function ClearAll()
		list = Null	'	If list Then list.Clear()
	End Function
	
	Function CreateParticle:TParticle(x:Int, y:Int, xvel:Float, yvel:Float, a:Float, s:Float, r:Int, g:Int, b:Int, im:Int = 0, myimg:TImage = Null)
		Local p:TParticle = New TParticle
		p.x = x
		p.y = y
		p.xvel = xvel
		p.yvel = yvel
		p.a = a
		p.scale = s
		p.rot = Rand(360)
		p.r = r
		p.g = g
		p.b = b
		p.life = gMillisecs
		p.im = im
		p.myimg = myimg
		
		Return p
	End Function

	Function Collision(x:Int, y:Int, dir:Float, speed:Float, col:String)
		'If Not list Then list = CreateList()
		
		For Local p:Int = 1 To Rand(2,5)
			Local xv:Float = Cos(dir)*speed
			Local yv:Float = Sin(dir)*speed
			xv:+Rnd(-2.0,2.0)
			yv:+Rnd(-2.0,2.0)
			
			' Smash colours
			Local r:Int = 205, g:Int = 205, b:Int = 205
			If Rand(2) = 1 Then HexColour(col, r, g, b)
			
			'list.AddLast(CreateParticle(x,y,xv,yv,1,Rand(2),r,g,b,Rand(4)-1))
			list = list[..list.Length+1]
			list[list.Length-1] = CreateParticle(x,y,xv,yv,1,Rand(2),r,g,b,Rand(4)-1)
		Next
	End Function
	
	Function UpdateParticlesAll()
		If Not list Then Return
		
		Local num:Int = 0
		For Local p:TParticle = EachIn list
			p.rot:+(10*p.xvel)
			p.x:+p.xvel
			p.y:+p.yvel
			p.xvel:*0.97
			p.yvel:*0.97
			
			If gMillisecs > p.life+1000 
				p.a:*0.95
				If p.a < 0.1
					list[num] = list[list.length - 1]
    				list = list[..list.length - 1]
					num:-1
				EndIf
			EndIf
			num:+1
		Next
	End Function
	
	Function DrawParticlesAll(tween:Float)
		If Not list Then Return
		
		For Local p:TParticle = EachIn list
			p.DrawParticle(tween)
		Next
		
		SetRotation(0)
		SetAlpha(1)
		SetColor(255,255,255)
	End Function
	
	Method DrawParticle(tween:Float)
		SetScale(track.scale, track.scale)
		SetRotation(rot)
		SetAlpha(a)
		SetColor(r,g,b)
		DrawImage(imgBits, originx+(x*track.scale), originy+(y*track.scale), im)
	End Method
End Type

Type TBlur
	Field x:Float
	Field y:Float
	Field a:Float
	Field r:Float
	Field s:Float
	
	Function CreateBlur:TBlur(x:Int, y:Int, a:Float, r:Float)
		Local p:TBlur = New TBlur
		p.x = x
		p.y = y
		p.a = a
		p.r = r
		p.s = 1
		Return p
	End Function
End Type

Type TCollCircle	
	Field distance:Float
	Field angle:Float
	Field size:Float
	
	Field myx:Int
	Field myy:Int
	Field mysize:Float
	Field mystate:Int
	
	Function Create:TCollCircle(dist:Float, ang:Float, size:Float)
		Local folder:String = gAppLoc
		If gModLoc <> "" Then folder = gModLoc
		
		Local cc:TCollCircle = New TCollCircle
		cc.distance = dist
		cc.angle = ang
		cc.size = size
		
		Return cc
	End Function
	
	Method CheckCollision:Int(x:Float, y:Float, cx:Float, cy:Float, speed:Float, direc:Float)
		Local colldist:Float = 24 + (distance * speed)	' Distance of check
		
		mysize = 16 + (size * speed)				' Size of circle
		If TOnline.netstatus
			mysize:*1.5
		End If
		
		myx = x + (Cos(direc+angle) * colldist)
		myy = y + (Sin(direc+angle) * colldist)
		
		' If point cx,cy is too close then collision has occurred
		mystate = False
		Local actualDistance# = Sqr((cx-myx)^2+(cy-myy)^2)
		If actualDistance < mysize Then mystate = True
		
		Return mystate
	End Method
	
	Method Draw()
		Select mystate
		Case False	SetColor(255,255,255)
		Case True	SetColor(255,0,0)
		End Select
		
		SetAlpha(0.1)
		SetScale(track.scale,track.scale)
		Local x:Int = originx+(myx*track.scale)
		Local y:Int = originy+(myy*track.scale)
		
		DrawOval(x-(mysize/2.0), y-(mysize/2.0), mysize, mysize)
		
		SetAlpha(1)
		SetScale(1,1)
		SetColor(255,255,255)
	End Method
End Type

