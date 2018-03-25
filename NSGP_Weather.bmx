   ' Time & Date
Const SUNDAY:Int=0, MONDAY:Int=1, TUESDAY:Int=2, WEDNESDAY:Int=3, THURSDAY:Int=4, FRIDAY:Int=5, SATURDAY:Int=6
Const JANUARY:Int=1, FEBRUARY:Int=2, MARCH:Int=3, APRIL:Int=4, MAY:Int=5, JUNE:Int=6, JULY:Int=7, AUGUST:Int=8, SEPTEMBER:Int=9, OCTOBER:Int=10, NOVEMBER:Int=11, DECEMBER:Int=12
Const JAN:Int=1, FEB:Int=2, MAR:Int=3, APR:Int=4, JUN:Int=6, JUL:Int=7, AUG:Int=8, SEP:Int=9, OCT:Int=10, NOV:Int=11, DEC:Int=12
Const CSEASON_SPRING:Int=0, CSEASON_SUMMER:Int=1, CSEASON_AUTUMN:Int=2, CSEASON_WINTER:Int=3
Const CWEATHER_RAIN_POSSIBLE:Int=1, CWEATHER_RAIN_UNLIKELY:Int=2, CWEATHER_SUNNY:Int=3

Type TWeather
	Field doingweather:Int = False
	Field weatherType:Int
	Field cloud:Int					' How much cloud cover there is
	Field cloudinc:Int				' Cloud building or dissipating
	Field wetness:Float
	
	' Rain
	Global imgRain:TImage
	Global imgForecast:TImage
	
	Field rainFrame:Int
	Field rainTime:Int
	Field volRain:Float = 0
	Field alphaRain:Float = 0
	
	' Rain sounds
	Global channelWeather:TChannel
	Global soundRain:TSound
	
	Field starfield:TStarfield
	
	Method FreeWeather()
		doingweather = False
		volRain = 0
		alphaRain = 0
		
		StopChannel(channelWeather)
		channelWeather = Null
		soundRain = Null
	End Method
	
	Function Create:TWeather()
		Local weather:TWeather = New TWeather
		
		weather.starfield = TStarfield.Create()
		
		weather.channelWeather = AllocChannel()
		weather.imgForecast = LoadMyAnimImage("Media/Weather/Forecast.png", 40, 32, 0, 4)
		'weather.imgRain = LoadMyAnimImage("Media/Weather/Rain.png", 64, 64, 0, 8)
		weather.soundRain = LoadMySound("Media/Sounds/Rain.ogg", SOUND_LOOP)
		weather.wetness = 0
		
		AppLog "Created Weather Object"
		Return weather
	End Function
	
	Method SetUpWeather(climate:Int)		
		weatherType = climate
		SeedRnd(MilliSecs())
		
		Select weatherType
		Case CWEATHER_RAIN_POSSIBLE
			AppLog "CWEATHER_RAIN_POSSIBLE"
			cloud = Rand(3)
			If cloud = 1 Then cloud = Rand(1,200)
		Case CWEATHER_RAIN_UNLIKELY
			AppLog "CWEATHER_RAIN_UNLIKELY"
			cloud = Rand(5)
			If cloud = 1 Then cloud = Rand(1,100)
		Case CWEATHER_SUNNY
			AppLog "CWEATHER_SUNNY"
			cloud = 1
		End Select
		
		'cloud = 100
		PlaySound(soundRain, channelWeather)
		volRain = 0
		channelWeather.SetVolume(volRain*OpVolumeFX)
		
		alphaRain = 0.0	
		wetness = 0.0
		doingweather = False
		
		If cloud >= 100
			volRain = 1
			alphaRain = 0.5
			wetness = 0.5
			doingweather = True
		End If
	End Method
	
	Method Update()
		Global oldtime:Int = gMillisecs
		
		' Update weather if offline or hosting
		If TOnline.netstatus = CNETWORK_NONE Or TOnline.hosting
			If gDebugMode 
				If KeyDown(KEY_LCONTROL) And KeyHit(KEY_R) 
					If cloud < 100
						cloud = 100; cloudinc = 1; wetness = 0
					Else
						cloud = 0; cloudinc = 0; wetness = 0
					EndIf
				Else
					If KeyHit(KEY_NUMADD)
						cloudinc = 1
						cloud:+1
					End If
					
					If KeyHit(KEY_NUMSUBTRACT)
						cloudinc = -1
						cloud:-1
					End If
				EndIf
			EndIf
			
			' Update cloud cover if rain is possible
			If weatherType = CWEATHER_SUNNY
				cloudinc = 0
				cloud = 0
			ElseIf gMillisecs > oldtime + 1000
				oldtime = gMillisecs
				
				If track.mode = CTRACKMODE_DRIVE
					' Every 10 seconds cloud can change direction (unless weather is currently starting/stopping)
					If Rand(3*track.totallaps) = 1 And (volRain = 0 Or volRain = 1)
					
						Select weatherType
						Case CWEATHER_RAIN_POSSIBLE		cloudinc = Rand(-1,1)
						Case CWEATHER_RAIN_UNLIKELY		cloudinc = Rand(-1,1)
						Case CWEATHER_SUNNY
						End Select
						
					End If
				EndIf
				
				cloud:+cloudinc
			EndIf
		EndIf
		
		ValidateMinMax(cloud, -50, 200)	' Make sure weather doesn't disappear off scale
		If cloud >= 100 Then doingweather = True
		If cloud < 100 Then doingweather = False
		
		' Only send new weather data if it changed
		Global lastcloud:Int = cloud
		Global lastsend:Int = 0
		If TOnline.hosting
			If cloud <> lastcloud And gMillisecs > lastsend+1000
				TOnline.SendWeatherData()
				lastcloud = cloud
				lastsend = gMillisecs
			EndIf
		EndIf
		
		Select doingweather
		Case True
			' Increase volume
			If volRain < 1 Then volRain:+0.0002
			If volRain > 1 Then volRain = 1
						
			channelWeather.SetVolume(volRain*OpVolumeFX)
			
			' Increase alpha
			If alphaRain < 0.5 Then alphaRain:+0.0002
			If alphaRain > 0.5 Then alphaRain = 0.5
			SetAlpha(alphaRain)
			
			' Select tile and display
			If gMillisecs > rainTime+70 Then rainFrame:-1; rainTime = gMillisecs
			If rainFrame < 0 Then rainFrame = 7
	'		TileImage( imgRain, 0, 0-(rainTime mod 128), rainFrame)
			starfield.Update()
			
			wetness:+0.0005
			If wetness > 1 Then wetness = 1
		Case False
			' Decrease volume
			If volRain > 0 Then volRain:-0.0002
			If volRain < 0 Then volRain = 0
			channelWeather.SetVolume(volRain*OpVolumeFX)
			
			' Decrease alpha
			If alphaRain > 0 
				alphaRain:-0.0002
				If alphaRain < 0 Then alphaRain = 0
				SetAlpha(alphaRain)
				If gMillisecs > rainTime+70 Then rainFrame:-1; rainTime = gMillisecs
				If rainFrame < 0 Then rainFrame = 7
	'			TileImage( imgRain, 0, 0-(rainTime mod 128), rainFrame)
	
				starfield.Update()
			End If
			
			wetness:-0.00015
			If wetness < 0 Then wetness = 0
		End Select
	End Method
	
	Method Draw()
		If alphaRain > 0 starfield.Draw(alphaRain)
	End Method

	Method StopWeather()
		alphaRain = 0
		volRain = 0
		channelWeather.SetVolume(0)
		wetness = 0
	End Method
End Type

Type TStarfield
	Global NUM_OF_STARS:Int = 0
	Field stars:TStar[NUM_OF_STARS]
	Field speed:Float = 12.0
	
	Function Create:TStarfield()
		Local folder:String = gAppLoc
		If gModLoc <> "" Then folder = gModLoc
		NUM_OF_STARS = LoadVariable(folder+"Settings/Engine.ini", "raindrops", 100, 10000)
		If gLowDetail And NUM_OF_STARS > 50 Then NUM_OF_STARS = 50 
		
		Local n:TStarfield = New TStarfield
	
		For Local i:Int = 0 To NUM_OF_STARS - 1
			n.stars[i] = TStar.Create(screenW/2, screenH/2)
		Next
		Return n
	EndFunction
	
	Method Update()
		For Local i:TStar = EachIn stars
			i.Move( speed )
			i.Translate()
		Next
	EndMethod
	
	Method Draw(a:Float)
		SetAlpha(a)
		SetColor(255,255,255)
		
		For Local i:Tstar = EachIn stars
			i.Draw()
		Next
		SetAlpha 1.0
		SetColor(255,255,255)
		SetScale(1,1)
	EndMethod
EndType

Type TStar
	Global imgRain:TImage
	Field x:Float
	Field y:Float
	Field z:Float
	Field sx:Float
	Field sy:Float
	Field size:Float
	
	Field CentreX:Int
	Field CentreY:Int
	
	Function Create:TStar(cx:Int,cy:Int)
		If Not imgRain Then imgRain = LoadMyImage("Media/Weather/RainDrop.png")
		Local n:TStar = New TStar
		n.ResetPosition()
		n.z = Rand( 1, 255 )
		n.CentreX = cx
		n.CentreY = cy
		Return n
	EndFunction

	Method ResetPosition()
		x = Rand( -screenW, screenW)
		y = Rand( -screenH, screenH)
	
		z = 600
		size = 1
	EndMethod

	Method Move( speed:Float )
		size = (750-z)/150
		
 		If z > 750
			resetposition()
		Else
			z :+ speed
		EndIf
	EndMethod

	Method Translate()
  		sx = ( x * screenW ) / ( (0.00001+z) ) + CentreX
  		sy = ( y * screenH ) / ( (0.00001+z) ) + CentreY
		
		sx:+(originx-oldoriginx)*TCar.SelectHumanCar().speed*3
		sy:+(originy-oldoriginy)*TCar.SelectHumanCar().speed*3
		
  		If sx < 0 Or sx > screenW Or sy < 0 Or sy > screenH
			ResetPosition()
		EndIf
	EndMethod
	
	Method Draw()
		SetScale(size, size)
		DrawImage(imgRain, sx, sy)
	EndMethod
EndType