' --------------------------------------------
' Game Timing
' --------------------------------------------
Local folder:String = gAppLoc
If gModLoc <> "" Then folder = gModLoc

Global ups:Int = 40
Global update_time:Int = 1000 / ups
Global t:Int, dt:Int, execution_time:Int = 0
Global fps:Int
Global gMillisecs:Int
Global gStartTime:Int = MilliSecs()
Global lastframetime:Int = 0
Global framecount:Int = 0

gFreeSound = LoadVariable(gSaveloc+"Settings/Settings.ini", "freesound", 0, 1)
Global gLowDetail:Int = LoadVariable(gSaveloc+"Settings/Settings.ini", "lowdetail", 0, 1)
Global screenW:Int = LoadVariable(gSaveLoc+"Settings/Settings.ini", "screenw", 800, 12000)
Global screenH:Int = LoadVariable(gSaveLoc+"Settings/Settings.ini", "screenh", 600, 12000)
Global gFullscreen:Int = LoadVariable(gSaveLoc+"Settings/Settings.ini", "fullscreen", 0, 1)
gSaveRaceReport = LoadVariable(gSaveloc+"Settings/Settings.ini", "saveracereport", 0, 1)
Global gOffSetX:Int = (screenW-800)/2
Global gOffSetY:Int = (screenH-600)/2

SetUpGraphicsWindow(gFullscreen)

Function SetUpGraphicsWindow(window:Int)
	Select window
	Case 0	Graphics(screenW, screenH)
	Case 1	Graphics(screenW, screenH, 32, 0)
	End Select
End Function

SeedRnd(MilliSecs())
Global img_Loading:TImage = LoadMyImage("incbin::Inc/Splash1.jpg")
DoSplashScreen(img_Loading, 250)
DoLoading(0)

' Set Up FryGui
Global CDEFCOL1:String = LoadVariableString(folder+"Settings/Engine.ini", "colpanel")
Global CDEFCOL2:String = LoadVariableString(folder+"Settings/Engine.ini", "colbutton")
Global CDEFCOL3:String = LoadVariableString(folder+"Settings/Engine.ini", "coltext")
Global CDEFCOL4:String = LoadVariableString(folder+"Settings/Engine.ini", "col4")
Global OpPanelAlpha:Float = LoadVariable(folder+"Settings/Engine.ini", "panalpha", 0.0, 1.0)

AppLog "Load Skin"
fry_Initialise_XML()
fry_LoadSkin(gAppLoc+"Skin")
fry_AddFont("Default", fntname, 11)
fry_AddFont("Small", fntname, 9)
fry_AddFont("Medium", fntname, 15)
fry_AddFont("Large", fntname, 24)
fry_ParseGUI()
fry_SetGuiColour(CDEFCOL1, CDEFCOL2, CDEFCOL3, OpPanelAlpha, CDEFCOL4)
fry_SetGuiResolution(screenW, screenH)

DoLoading(10)

JoyCount()
HideMouse
SetBlend(ALPHABLEND)

Global fnt_Small:TFontText = TFontText.Create("incbin::Inc/meiryo12b.fmf", 14)
Global fnt_Medium:TFontText = TFontText.Create("incbin::Inc/meiryo13b.fmf", 22)
Const fntoffset_Small:Int = -18
Const fntoffset_Medium:Int = -12

' --------------------------------------------
' Sorts
' --------------------------------------------
Const CSORT_NAME:Int = 0, CSORT_NATIONALITY:Int = 1, CSORT_SEASONPOINTS:Int = 2, CSORT_FINISHTIME:Int = 3, CSORT_POSITION:Int = 4
Const CSORT_QUALIFYINGTIME:Int = 5, CSORT_REPLAYPOSITION:Int = 6, CSORT_CAREERPOINTS:Int = 7, CSORT_CARSTATS:Int = 8, CSORT_RANDOM:Int = 9
Const CSORT_DRIVERID:Int = 10, CSORT_ID:Int = 11

' --------------------------------------------
' Dates
' --------------------------------------------
Const CDAY_MONDAY:Int = 1, CDAY_TUESDAY:Int = 2, CDAY_WEDNESDAY:Int = 3, CDAY_THURSDAY:Int = 4, CDAY_FRIDAY:Int = 5, CDAY_SATURDAY:Int = 6, CDAY_SUNDAY:Int = 7

' --------------------------------------------
' Cars
' --------------------------------------------
Const CSHOPITEM_CAR:Int = 1, CSHOPITEM_PROPERTY:Int = 2

AppLogMode(gDebugMode)

' --------------------------------------------
' Localisation - Load the BLF before any includes
' --------------------------------------------
AppLog "Load Language file"
LoadLocaleFile(gAppLoc+"Languages/NSGP.blf")

SetCurrentLocale(LoadVariableString(gSaveloc+"Settings/Settings.ini", "language"))

' --------------------------------------------
' Sounds
' --------------------------------------------
' Set up Sound
?Win32
	If gFreeSound = 1
		SetAudioDriver("FreeAudio")
		AppLog "AudioDriver: FreeAudio"	
	Else
		EnableOpenALAudio()
		
		If SetAudioDriver("OpenAL") 
			AppLog "AudioDriver: OpenAL"
		Else
			SetAudioDriver("FreeAudio")
			AppLog "AudioDriver: FreeAudio"	
		EndIf
	EndIf
	
?MacOs
	SetAudioDriver("FreeAudio")
	AppLog "AudioDriver: FreeAudio"	
?

' Music
Global chn_Music:TChannel = AllocChannel()
Global OpVolumeMusic:Float = 1
Global snd_BGM:TSound = LoadMySound("incbin::Inc/DestVel.ogg", SOUND_LOOP)
CueSound(snd_BGM, chn_Music)
chn_Music.SetVolume(1)
ResumeChannel(chn_Music)

DoLoading(20)

' FX
Global chn_FX:TChannel = AllocChannel()			' Global channel for interface sounds
Global chn_CrashFX:TChannel = AllocChannel()	' Global channel for non-human crash noises
Global OpVolumeFX:Float = 1

' Interface sounds
Global snd_Click:TSound = LoadMySound("Skin/Sounds/Click.ogg")
Global snd_Open:TSound = LoadMySound("Skin/Sounds/Open.ogg")

' Car sounds
Global snd_EngineGear:TSound = LoadMySound("Media/Sounds/Gear2.ogg")
Global snd_EngineTopSpeed:TSound = LoadMySound("Media/Sounds/MyTopSpeed2.ogg",SOUND_LOOP)
Global snd_EngineSports:TSound = LoadMySound("Media/Sounds/Engine.ogg")
Global snd_Warning1:TSound = LoadMySound("Media/Sounds/Warning1.ogg")
Global snd_Rev1:TSound = LoadMySound("Media/Sounds/Rev1.ogg") 
Global snd_Gravel:TSound = LoadMySound("Media/Sounds/Gravel.ogg",SOUND_LOOP)
Global snd_Edge:TSound = LoadMySound("Media/Sounds/Edge.ogg",SOUND_LOOP)
Global snd_Rumble:TSound = LoadMySound("Media/Sounds/Rumble.ogg",SOUND_LOOP)
Global snd_Crash_Car:TSound = LoadMySound("Media/Sounds/Crash_Car.ogg")
Global snd_Crash_Wall:TSound = LoadMySound("Media/Sounds/Crash_Wall.ogg")
Global snd_Pits:TSound = LoadMySound("Media/Sounds/Pits.ogg")
Global snd_NewRecord:TSound = LoadMySound("Media/Sounds/NewRecord.ogg")
Global snd_Lights1:TSound = LoadMySound("Media/Sounds/Lights1.ogg")

DoLoading(30)

' Voice
Global chn_Radio:TChannel = AllocChannel()
Global snd_Static:TSound = LoadMySound("Media/Sounds/Voice/Static.ogg")
Global snd_0:TSound = LoadMySound("Media/Sounds/Voice/0.ogg")
Global snd_1:TSound = LoadMySound("Media/Sounds/Voice/1.ogg")
Global snd_2:TSound = LoadMySound("Media/Sounds/Voice/2.ogg")
Global snd_3:TSound = LoadMySound("Media/Sounds/Voice/3.ogg")
Global snd_4:TSound = LoadMySound("Media/Sounds/Voice/4.ogg")
Global snd_5:TSound = LoadMySound("Media/Sounds/Voice/5.ogg")
Global snd_6:TSound = LoadMySound("Media/Sounds/Voice/6.ogg")
Global snd_7:TSound = LoadMySound("Media/Sounds/Voice/7.ogg")
Global snd_8:TSound = LoadMySound("Media/Sounds/Voice/8.ogg")
Global snd_9:TSound = LoadMySound("Media/Sounds/Voice/9.ogg")

DoLoading(40)

Global snd_10:TSound = LoadMySound("Media/Sounds/Voice/10.ogg")
Global snd_11:TSound = LoadMySound("Media/Sounds/Voice/11.ogg")
Global snd_12:TSound = LoadMySound("Media/Sounds/Voice/12.ogg")
Global snd_13:TSound = LoadMySound("Media/Sounds/Voice/13.ogg")
Global snd_14:TSound = LoadMySound("Media/Sounds/Voice/14.ogg")
Global snd_15:TSound = LoadMySound("Media/Sounds/Voice/15.ogg")
Global snd_16:TSound = LoadMySound("Media/Sounds/Voice/16.ogg")
Global snd_17:TSound = LoadMySound("Media/Sounds/Voice/17.ogg")
Global snd_18:TSound = LoadMySound("Media/Sounds/Voice/18.ogg")
Global snd_19:TSound = LoadMySound("Media/Sounds/Voice/19.ogg")

DoLoading(50)

Global snd_20:TSound = LoadMySound("Media/Sounds/Voice/20.ogg")
Global snd_30:TSound = LoadMySound("Media/Sounds/Voice/30.ogg")
Global snd_40:TSound = LoadMySound("Media/Sounds/Voice/40.ogg")
Global snd_50:TSound = LoadMySound("Media/Sounds/Voice/50.ogg")
Global snd_60:TSound = LoadMySound("Media/Sounds/Voice/60.ogg")

Global snd_second:TSound = LoadMySound("Media/Sounds/Voice/secs.ogg")
Global snd_seconds:TSound = LoadMySound("Media/Sounds/Voice/secs.ogg")
Global snd_minute:TSound = LoadMySound("Media/Sounds/Voice/min.ogg")
Global snd_minutes:TSound = LoadMySound("Media/Sounds/Voice/mins.ogg")
Global snd_point:TSound = LoadMySound("Media/Sounds/Voice/point.ogg")
Global snd_FuelLow:TSound = LoadMySound("Media/Sounds/Voice/fuellow.ogg")

DoLoading(60)

' --------------------------------------------
' Interface 
' --------------------------------------------
Global img_Fuel:TImage = LoadMyImage("Media\Interface\Fuel.png")
Global img_FuelLarge:TImage = LoadMyImage("Media\Interface\Fuel_Large.png")
Global img_Damage:TImage = LoadMyImage("Media\Interface\Damage.png")
Global img_TyreSmall_Soft:TImage = LoadMyImage("Media\Interface\TyreSmall_Dry.png")
Global img_TyreSmall_Hard:TImage = LoadMyImage("Media\Interface\TyreSmall_Hard.png")
Global img_TyreSmall_Wet:TImage = LoadMyImage("Media\Interface\TyreSmall_Wet.png")
Global img_TyreSoft:TImage = LoadMyImage(gAppLoc+"Media\Interface\Tyre_Dry.png")
Global img_TyreHard:TImage = LoadMyImage(gAppLoc+"Media\Interface\Tyre_Hard.png")
Global img_TyreWet:TImage = LoadMyImage(gAppLoc+"Media\Interface\Tyre_Wet.png")
Global img_TyreTread:TImage = LoadMyImage(gAppLoc+"Media\Interface\Tyre_Tread.png")
Global img_Speedo:TImage = LoadMyImage(gAppLoc+"Media\Interface\Speedo.png")
Global img_Kers:TImage = LoadMyImage(gAppLoc+"Media\Interface\KERS.png")
MidHandleImage(img_Kers)
Global img_Needle:TImage = LoadMyImage(gAppLoc+"Media\Interface\Needle.png")
SetImageHandle(img_Needle, 15, 33)

Global img_SpeedBlocks:TImage = LoadMyAnimImage(gAppLoc+"Media\Interface\SpeedBlocks.png", 38, 38, 0, 9)
Global speedalpha:Float[18]

DoLoading(70)

' --------------------------------------------
' Physics
' --------------------------------------------
Global CQUALIFYING_TIME:Float = LoadVariable(folder+"Settings/Engine.ini", "qualifyingtime", 10000, 1800000)
Global CSOUND_F1ENGINE:Int = LoadVariable(folder+"Settings/Engine.ini", "sound_f1engine", 0, 1)

Global CFUELWEIGHT:Float
Global CFUEL_CONSUMPTION:Float
Global CTYRE_WEAR_TARMAC:Float
Global CTYRE_WEAR_RUMBLE:Float
Global CTYRE_WEAR_GRASS:Float
Global CTYRE_WEAR_GRAVEL:Float

Global CTYRECHANGETIME:Float
Global CKERSCHANGETIME:Float

Global CHANDLING_STANDARD:Float
Global CACCEL_STANDARD:Float
Global CTOPSPEED_STANDARD:Float
Global CSLIPSTREAM_MIN:Float
Global CSLIPSTREAM_DIST:Float
Global CSLIPSTREAM_GAIN:Float
Global CSLIPSTREAM_ANGLE:Float
	
Global CDRIFT:Float
Global CFRIC_TARMAC:Float
Global CFRIC_RUMBLE:Float
Global CFRIC_GRASS:Float
Global CFRIC_GRAVEL:Float
Global CFRIC_PITLANE:Float
Global CVOL_ENGINE:Float

Global CDAMAGE_CARS:Float
Global CDAMAGE_WALL:Float

Global CCOMSPEED_EASY:Float
Global CCOMSPEED_NORMAL:Float
Global CCOMSPEED_HARD:Float
Global CCOMSPEED_EXTREME:Float

LoadCarIni(folder)
Function LoadCarIni(f:String)
	' Only use gApploc+Settings/Engine.ini if using a mod
	' This way a non-mod career will always use default Engine.ini in incbin.
	If gModLoc = "" Then f = "incbin::Inc/"
	DebugLog f
	CFUELWEIGHT = LoadVariable(f+"Settings/Engine.ini", "fuelweight", 1, 10000)
	CFUEL_CONSUMPTION = LoadVariable(f+"Settings/Engine.ini", "fuelconsumption", 0, 10)
	CTYRE_WEAR_TARMAC = LoadVariable(f+"Settings/Engine.ini", "tyreweartarmac", 0, 10)
	CTYRE_WEAR_RUMBLE = LoadVariable(f+"Settings/Engine.ini", "tyrewearrumble", 0, 10)
	CTYRE_WEAR_GRASS = LoadVariable(f+"Settings/Engine.ini", "tyreweargrass", 0, 10)
	CTYRE_WEAR_GRAVEL = LoadVariable(f+"Settings/Engine.ini", "tyreweargravel", 0, 10)
	
	CTYRECHANGETIME = LoadVariable(f+"Settings/Engine.ini", "tyrechangetime", 10, 10000)
	CKERSCHANGETIME = LoadVariable(f+"Settings/Engine.ini", "kerschangetime", 10, 10000)
	
	CHANDLING_STANDARD = LoadVariable(f+"Settings/Engine.ini", "handling_standard", 0.0, 10.0)
	CACCEL_STANDARD = LoadVariable(f+"Settings/Engine.ini", "accel_standard", 0.0, 1.0)
	CTOPSPEED_STANDARD = LoadVariable(f+"Settings/Engine.ini", "topspeed_standard", 5, 15)
	CSLIPSTREAM_MIN = LoadVariable(f+"Settings/Engine.ini", "slipstream_min", 0.25, 1.0)
	CSLIPSTREAM_DIST = LoadVariable(f+"Settings/Engine.ini", "slipstream_dist", 10, 200)
	CSLIPSTREAM_GAIN = LoadVariable(f+"Settings/Engine.ini", "slipstream_gain", 0.01, 0.25)
	CSLIPSTREAM_ANGLE = LoadVariable(f+"Settings/Engine.ini", "slipstream_angle", 1, 45)

	CDRIFT = LoadVariable(f+"Settings/Engine.ini", "drift", 0.0, 1.0)
	CFRIC_TARMAC = LoadVariable(f+"Settings/Engine.ini", "fric_tarmac", 0.0, 1.0)
	CFRIC_RUMBLE = LoadVariable(f+"Settings/Engine.ini", "fric_rumble", 0.0, 1.0)
	CFRIC_GRASS = LoadVariable(f+"Settings/Engine.ini", "fric_grass", 0.0, 1.0)
	CFRIC_GRAVEL = LoadVariable(f+"Settings/Engine.ini", "fric_gravel", 0.0, 1.0)
	CFRIC_PITLANE = LoadVariable(f+"Settings/Engine.ini", "fric_pitlane", 0.0, 1.0)
	CVOL_ENGINE = LoadVariable(f+"Settings/Engine.ini", "enginevolume", 0.1, 1.0)
	
	CDAMAGE_CARS = LoadVariable(f+"Settings/Engine.ini", "damage_cars", 0.1, 10.0)
	CDAMAGE_WALL = LoadVariable(f+"Settings/Engine.ini", "damage_wall", 0.1, 10.0)
	
	CCOMSPEED_EASY = LoadVariable(f+"Settings/Engine.ini", "comspeed_easy", 500, 10000.0)
	CCOMSPEED_NORMAL = LoadVariable(f+"Settings/Engine.ini", "comspeed_normal", 500, 10000.0)
	CCOMSPEED_HARD = LoadVariable(f+"Settings/Engine.ini", "comspeed_hard", 500, 10000.0)
	CCOMSPEED_EXTREME = LoadVariable(f+"Settings/Engine.ini", "comspeed_hard", 500, 10000.0)
End Function

DoLoading(80)

' --------------------------------------------
' Backgrounds and Images
' --------------------------------------------
SetMaskColor(255,0,255)
Global img_Bg:TImage = LoadMyImage("incbin::Inc/bg.jpg")

Global l_imgBgs:TList = CreateList()
Global img_Bg_Home:TImage = LoadMyImage(folder+"Media/Backgrounds/bg_home.jpg")
Global img_Bg_Finances:TImage = LoadMyImage(folder+"Media/Backgrounds/bg_finances.jpg")
Global img_Bg_Tracks:TImage = LoadMyImage(folder+"Media/Backgrounds/bg_tracks.jpg")
Global img_Bg_Teams:TImage = LoadMyImage(folder+"Media/Backgrounds/bg_teams.jpg")
Global img_Bg_News:TImage = LoadMyImage(folder+"Media\Interface\News.png")

If Not img_Bg_Home Then img_Bg_Home = LoadMyImage(gAppLoc+"Media/Backgrounds/bg_home.jpg")
If Not img_Bg_Finances Then img_Bg_Finances = LoadMyImage(gAppLoc+"Media/Backgrounds/bg_finances.jpg")
If Not img_Bg_Tracks Then img_Bg_Tracks = LoadMyImage(gAppLoc+"Media/Backgrounds/bg_tracks.jpg")
If Not img_Bg_Teams Then img_Bg_Teams = LoadMyImage(gAppLoc+"Media/Backgrounds/bg_teams.jpg")
If Not img_Bg_News Then img_Bg_News = LoadMyImage(gAppLoc+"Media\Interface\News.png")

Global imgBg_Casino:TImage = LoadMyImage(folder+"Media/Backgrounds/bg_casino.jpg")
Global imgBg_Felt:TImage = LoadMyImage(folder+"Media/Backgrounds/bg_felt.png")
Global imgBg_FeltBlue:TImage = LoadMyImage(folder+"Media/Backgrounds/bg_feltblue.png")
Global imgBg_SlotMachine:TImage = LoadMyImage(folder+"Media/Backgrounds/bg_machine.png")
Global imgBg_SlotMachineMini:TImage = LoadMyImage(folder+"Media/Backgrounds/bg_minimachine.png")

If Not imgBg_Casino Then imgBg_Casino = LoadMyImage(gAppLoc+"Media/Backgrounds/bg_casino.jpg")
If Not imgBg_Felt Then imgBg_Felt = LoadMyImage(gAppLoc+"Media/Backgrounds/bg_felt.png")
If Not imgBg_FeltBlue Then imgBg_FeltBlue = LoadMyImage(gAppLoc+"Media/Backgrounds/bg_feltblue.png")
If Not imgBg_SlotMachine Then imgBg_SlotMachine = LoadMyImage(gAppLoc+"Media/Backgrounds/bg_machine.png")
If Not imgBg_SlotMachineMini Then imgBg_SlotMachineMini = LoadMyImage(gAppLoc+"Media/Backgrounds/bg_minimachine.png")

Global imgTrackProfileFlag:TImage
Global imgTrackProfile:TImage
Global imgTeamProfile:TImage 
Global imgTeamProfileNat:TImage 
Global imgDriverProfileFlag1:TImage
Global imgDriverProfileFlag2:TImage
Global imgLights:TImage = LoadMyAnimImage(gAppLoc+"Media\Interface\Lights2.png", 240, 112, 0, 6)
Global img_HiLite:TImage = LoadMyImage(gAppLoc+"Media\Cars\HiLite.png")
MidHandleImage(img_HiLite)

DoLoading(90)

TParticle.SetUpParticleImage()

' Relation images
Global imgRelationsBoss:TImage = LoadMyImage(gAppLoc+"Media\Relations\Rel_Boss.png")
Global imgRelationsPitCrew:TImage = LoadMyImage(gAppLoc+"Media\Relations\Rel_PitCrew.png")
Global imgRelationsFans:TImage = LoadMyImage(gAppLoc+"Media\Relations\Rel_Fans.png")
Global imgRelationsFriends:TImage = LoadMyImage(gAppLoc+"Media\Relations\Rel_Friends.png")

Global imgCash:TImage = LoadMyImage(gAppLoc+"Media\Interface\Cash.png")
Global imgStar:TImage = LoadMyImage(gAppLoc+"Media\Interface\Star.png")
Global imgStarLarge:TImage = LoadMyImage(gAppLoc+"Media\Interface\Star_Large.png")
Global imgSmiley_1:TImage = LoadMyImage(gAppLoc+"Media\Interface\Smiley_1.png")
Global imgSmiley_2:TImage = LoadMyImage(gAppLoc+"Media\Interface\Smiley_2.png")
Global imgSmiley_3:TImage = LoadMyImage(gAppLoc+"Media\Interface\Smiley_3.png")

DoLoading(100)

' --------------------------------------------
' Race panels
' --------------------------------------------
Global imgRacePanel:TImage[9]
SetUpRacePanels()

Function SetUpRacePanels()
	'load in skin image
	Local image:TImage = LoadImage(gAppLoc+"Skin/graphics/panel.png")
	Local mainmap:TPixmap = LockImage(image)
	
	'create the nine images
	Local pixmap:TPixmap[9]
	For Local count:Int = 0 To 8
		imgRacePanel[count] = CreateImage(10,10)
		pixmap[count] = LockImage(imgRacePanel[count])
	Next
	
	'copy the pixels across
	For Local y:Int = 0 To 29
		For Local x:Int = 0 To 29
		
			'get correct pixmap to write to
			Local map:Int = ((y/10) * 3) + (x/10)
			
			'copy pixels
			WritePixel(pixmap[map], (x Mod 10), (y Mod 10), ReadPixel(mainmap, x, y))
		Next
	Next
	
	'unlock images
	For Local count:Int = 0 To 8
		UnlockImage(imgRacePanel[count])
	Next
	UnlockImage(image)
End Function

' --------------------------------------------
' Game Variables
' --------------------------------------------
Global gNoofWeeks:Int = LoadVariable(folder + "Settings/Engine.ini", "seasonlength", 1, 100)
Global gNoofSeasons:Int = LoadVariable(folder + "Settings/Engine.ini", "careerlength", 1, 1000)
Global gShowCollCircles:Int = LoadVariable(folder + "Settings/Engine.ini", "showcollcircles", 0, 1)
Global gLimitScroll:Int = LoadVariable(folder + "Settings/Engine.ini", "limitscroll", 0, 1)

Global pointsaward:Int[25]
For Local i:Int = 1 To 24
	Local istr:String = String(i)
	If i < 10 Then istr = "0"+String(i)
	pointsaward[i] = LoadVariable(folder+"Settings/Engine.ini", "points_"+istr, 0, 9999)
Next
		
Global gWeek:Int = 1
Global gDay:Int = 1
Global gYear:Int = 1
Global gConnectToLeaderboards:Int = True 
Global gDemo:Int = 0
Global gVersion:String = "v1.34"
If gDemo Then gVersion:+" DEMO"
Global gMyDriverId:Int = 1
Global gQuickRace:Int = True
Global gRelBoss:Int
Global gRelPitCrew:Int
Global gRelFans:Int
Global gRelFriends:Int

Global OpCurrency:String = "EUR"
TCurrency.SetUpCurrencies()
Global OpLaps:Int = 5
Global OpView:Int = 3
Global OpDifficulty:Int = 1
Global OpRadio:Int = 1
Global OpMap:Int = 1
Global OpFuel:Int = 1
Global OpDamage:Int = 1
Global OpTyres:Int = 1
Global OpSpeedo:Int = 1
Global OpKers:Int = 1
Global OpNames:Int = 0
Global OpGhost:Int = 1
Global OpControls:Int[7]
Const MYKEY_LEFT:Int = 0, MYKEY_RIGHT:Int = 1, MYKEY_UP:Int = 2, MYKEY_DOWN:Int = 3, MYKEY_PAUSE:Int = 4, MYKEY_INFO:Int = 5, MYKEY_KERS:Int = 6
OpControls = [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN, KEY_ESCAPE, KEY_SPACE, KEY_LSHIFT]

Global gRainLight:Int = LoadVariable(folder+"Settings/Engine.ini", "rainlight", 0, 1)

' Set up objects
Global track:TTrack = TTrack.Create()

' Debugging checks
Global gRenderText:Int = True
Global gRenderObjects:Int = True

' URLs
Global gVersionURL:String = "download.newstargames.com/version_nsgppc.dat"
Global gDownloadURL:String = "download.newstargames.com/Install_NSGP.exe"

?MacOs
	gVersionURL = "download.newstargames.com/version_nsgpmac.dat"
	gDownloadURL = "download.newstargames.com/NSGP.dmg"
?

Global gBlackListURL:String = "download.newstargames.com/blist.dat"

Global gNSGPURL:String = "http://www.newstargames.com/nsgp.html"
Global gBuyURL:String = "http://www.newstargames.com/nsgp.html"
Global gRegHelpURL:String = "http://www.newstargames.com/contact.html"
Global gForumURL:String = "http://www.newstargames.com/newstarforum"
Global gOnlineHelpURL:String = "http://www.newstarsoccer.com/newstarforum/forumdisplay.php?f=97"
Global gPlimusRegURL:String = "http://www.plimus.com/jsp/validateKey.jsp?action=MYCHECK&productId=372870&key=MYKEY&uniqueMachineId=MYNAME"

' Unreg
' http://www.plimus.com/jsp/validateKey.jsp?action=UNREGISTER&productId=372870&key=XXX-XXXX-XXXX-XXXX&uniqueMachineId=YYYYYYY

 
' Network
Global gPort:Int = LoadVariable(folder+"Settings/Engine.ini", "port", 0,99999999)
Global gProxy:String = LoadVariableString(folder+"Settings/Engine.ini", "proxy")

DoLoading(110)
