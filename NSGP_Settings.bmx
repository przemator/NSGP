 
' --------------------------------------------
' IncBins
' --------------------------------------------
Incbin "Inc/Credits.txt"
Incbin "Inc/bg.jpg"
Incbin "Inc/Splash1.jpg"
Incbin "Inc/Splash2.jpg"
Incbin "Inc/BuyNow.png"
Incbin "Inc/Price.png"
Incbin "Inc/ARLRDBD.TTF"
Incbin "Inc/trebucbd.ttf"
Incbin "Inc/meiryo12b.fmf"
Incbin "Inc/meiryo13b.fmf"
Incbin "Inc/DestVel.ogg"

Incbin "Inc/Settings/Engine.ini"
Incbin "Inc/NSGP.db"
Incbin "Inc/NSGP.blf"
Incbin "Inc/Track_0.trk"
Incbin "Inc/Track_1.trk"
Incbin "Inc/Track_2.trk"
Incbin "Inc/Track_3.trk"
Incbin "Inc/Track_4.trk"
Incbin "Inc/Track_5.trk"
Incbin "Inc/Track_6.trk"
Incbin "Inc/Track_7.trk"
Incbin "Inc/Track_8.trk"
Incbin "Inc/Track_9.trk"
Incbin "Inc/Track_10.trk"
Incbin "Inc/Track_11.trk"
Incbin "Inc/Track_12.trk"
Incbin "Inc/Track_13.trk"
Incbin "Inc/Track_14.trk"
Incbin "Inc/Track_15.trk"
Incbin "Inc/Track_16.trk"
Incbin "Inc/Track_17.trk"
Incbin "Inc/Track_18.trk"
Incbin "Inc/Track_19.trk"
Incbin "Inc/Track_20.trk"

' --------------------------------------------
' Globals
' --------------------------------------------
AppTitle = "New Star GP"
Global appName:String = StripDir(AppFile) + ".app"
Global gAppLoc:String
Global gSaveloc:String
Global gModLoc:String
Global db:TSQLiter = New TSQLiter
Global gStartYear:Int = 2010
Global fntname:String = "ARLRDBD.TTF"
DebugLog "Dir:"+CurrentDir()

?Win32
	If CurrentDir().Contains("Code") Then ChangeDir("../")
?MacOs
	gAppLoc = appName+"/Contents/Resources/Data/"
?

gSaveloc = Trim(LoadVariableString(gAppLoc + "Settings/Engine.ini", "saveloc"))
If Len(gSaveloc) < 4
	gSaveloc = GetUserDocumentsDir()+"/New Star GP/"	' Home for saves and written file
EndIf

' Set Up Save Folder
CreateDir(gSaveloc)
CreateDir(gSaveloc+"Settings/")
CreateDir(gSaveloc+"Save/")
CreateDir(gSaveloc+"Tracks/")
CreateDir(gSaveloc+"Mods/")
CreateDir(gSaveloc+"Database/")
CreateDir(gSaveloc+"Replays/")
CreateDir(gSaveloc+"Screenshots/")

' Make sure a Settings file exists
If FileType(gSaveloc+"Settings/Settings.ini") <> 1 
	Print "Settings.ini doesn't exist. Writing new one. (1)"
	WriteNewIni()
	
	If FileType(gSaveloc + "Settings/Settings.ini") <> 1
		Notify("Error 1: Unable to create save folder. Please go to www.newstarsoccer.com/newstarforum/ for assistance.", True)
		End
	EndIf
EndIf

CopyTracks()

Function CopyTracks(force:Int = False)
	If FileType(gSaveloc+"Database\NSGP.db") <> 1 Or force Then CopyFile("incbin::Inc/NSGP.db", gSaveloc+"Database\NSGP.db")
	If FileType(gSaveloc+"Tracks\01_Bahrain.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_1.trk", gSaveloc+"Tracks\01_Bahrain.trk")
	If FileType(gSaveloc+"Tracks\02_Australia.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_2.trk", gSaveloc+"Tracks\02_Australia.trk")
	If FileType(gSaveloc+"Tracks\03_Malaysia.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_3.trk", gSaveloc+"Tracks\03_Malaysia.trk")
	If FileType(gSaveloc+"Tracks\04_China.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_4.trk", gSaveloc+"Tracks\04_China.trk")
	If FileType(gSaveloc+"Tracks\05_Spain.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_5.trk", gSaveloc+"Tracks\05_Spain.trk")
	If FileType(gSaveloc+"Tracks\06_Monaco.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_6.trk", gSaveloc+"Tracks\06_Monaco.trk")
	If FileType(gSaveloc+"Tracks\07_Turkey.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_7.trk", gSaveloc+"Tracks\07_Turkey.trk")
	If FileType(gSaveloc+"Tracks\08_Canada.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_8.trk", gSaveloc+"Tracks\08_Canada.trk")
	If FileType(gSaveloc+"Tracks\09_Europe.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_9.trk", gSaveloc+"Tracks\09_Europe.trk")
	If FileType(gSaveloc+"Tracks\10_Britain.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_10.trk", gSaveloc+"Tracks\10_Britain.trk")
	If FileType(gSaveloc+"Tracks\11_Germany.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_11.trk", gSaveloc+"Tracks\11_Germany.trk")
	If FileType(gSaveloc+"Tracks\12_Hungary.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_12.trk", gSaveloc+"Tracks\12_Hungary.trk")	
	If FileType(gSaveloc+"Tracks\13_Belgium.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_13.trk", gSaveloc+"Tracks\13_Belgium.trk")
	If FileType(gSaveloc+"Tracks\14_Italy.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_14.trk", gSaveloc+"Tracks\14_Italy.trk")
	If FileType(gSaveloc+"Tracks\15_Singapore.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_15.trk", gSaveloc+"Tracks\15_Singapore.trk")
	If FileType(gSaveloc+"Tracks\16_Japan.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_16.trk", gSaveloc+"Tracks\16_Japan.trk")
	If FileType(gSaveloc+"Tracks\17_Korea.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_17.trk", gSaveloc+"Tracks\17_Korea.trk")
	If FileType(gSaveloc+"Tracks\18_Brasil.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_18.trk", gSaveloc+"Tracks\18_Brasil.trk")
	If FileType(gSaveloc+"Tracks\19_Abu Dhabi.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_19.trk", gSaveloc+"Tracks\19_Abu Dhabi.trk")
	If FileType(gSaveloc+"Tracks\20_India.trk") <> 1 Or force Then CopyFile("incbin::Inc/Track_20.trk", gSaveloc+"Tracks\20_India.trk")
End Function

SetGraphicsDriver GLMax2DDriver() 'D3D7Max2DDriver()

' Set up Gfx
Graphics(600,400)

SetUpLanguage()

HideMouse
SetColor 255,255,255
SetBlend ALPHABLEND

' Image
Global imgNSGP:TImage = LoadMyImage(gAppLoc+"Skin/Graphics/Buttons/LogoNSGP_Small.png")

Global btn_ok:fry_TButton = fry_TButton(fry_GetGadget("pan_settings/btn_ok"))
Global ok:Int = False

Global cmb_Language:fry_TComboBox = fry_TComboBox(fry_GetGadget("pan_settings/cmb_language"))
Global locales:String[] = GetAvailableLocales()
For Local i:Int = 0 Until locales.length
	cmb_Language.AddItem(GetLanguage(locales[i], True))
Next

Global cmb_Screen:fry_TComboBox = fry_TComboBox(fry_GetGadget("pan_settings/cmb_screen"))
cmb_Screen.AddItem(GetLocaleText("Window"))
cmb_Screen.AddItem(GetLocaleText("Full Screen"))

Local lowdetail:Int = LoadVariable(gSaveloc+"Settings/Settings.ini", "lowdetail", 0, 1)
Global lbl_Detail:fry_TLabel = fry_TLabel(fry_GetGadget("pan_settings/lbl_detail"))
lbl_Detail.SetText("Gfx")
Global cmb_Detail:fry_TComboBox = fry_TComboBox(fry_GetGadget("pan_settings/cmb_detail"))
cmb_Detail.AddItem(GetLocaleText("High"))
cmb_Detail.AddItem(GetLocaleText("Low"))
cmb_Detail.SelectItem(lowdetail)

Global cmb_Mod:fry_TComboBox = fry_TComboBox(fry_GetGadget("pan_settings/cmb_mod"))
UpdateModCombo()

Global cmb_Res:fry_TComboBox = fry_TComboBox(fry_GetGadget("pan_settings/cmb_res"))

Local sw:Int = LoadVariable(gSaveloc+"Settings/Settings.ini", "screenW",800,999999)
Local sh:Int = LoadVariable(gSaveloc+"Settings/Settings.ini", "screenH",600,999999)
Local count:Int = -1
Local selno:Int

For Local mode:TGraphicsMode=EachIn GraphicsModes()
	If mode.width >= 800 And mode.height >= 600 And Not TMyGfxModes.OnListAlready(mode.width, mode.height)
		cmb_Res.AddItem(mode.width+" x "+mode.height); count:+1
		TMyGfxModes.Create(mode.width, mode.height)
		If sw = mode.width And sh = mode.height Then selno = count
	EndIf
Next
cmb_Res.SelectItem(selno)

cmb_Language.SelectItem(GetLanguageNum(LoadVariableString(gSaveloc+"Settings/Settings.ini", "language")))

cmb_Screen.SelectItem(LoadVariable(gSaveloc+"Settings/Settings.ini", "fullscreen", 0, 1))

Global lbl_Joypad:fry_TLabel = fry_TLabel(fry_GetGadget("pan_settings/lbl_joypad"))
Global imgLang:TImage

Global gDebugMode:Int = LoadVariable(gSaveLoc+"Settings/Settings.ini", "debug",0,1)
Global gFreeSound:Int = LoadVariable(gSaveLoc+"Settings/Settings.ini", "freesound", 0, 1)
Global gSaveRaceReport:Int = LoadVariable(gSaveLoc+"Settings/Settings.ini", "saveracereport", 0, 1)
Global gJoyCount:Int = 0

' Flush frys events
While fry_PollEvent() Wend
Local starttime:Int = MilliSecs()
 
' Main game loop
Repeat
	Cls
	fry_Refresh()
	DrawImage(imgNSGP,300-(ImageWidth(imgNSGP)/2),20)
	If imgLang Then DrawImage(imgLang, cmb_Language.gX+cmb_Language.gW+20,cmb_Language.gY-12)
	PollSystem
	CheckSettingsInput()
	
	Global tmr:Int = 0
	If MilliSecs()-starttime > tmr + 1500
		tmr = MilliSecs()-starttime 

		If gJoyCount = 0 Then gJoyCount = JoyCount() 
		
		If gJoyCount > 0
			lbl_Joypad.SetText(GetLocaleText("JOYFOUND"))
		Else
			lbl_Joypad.SetText(GetLocaleText("JOYNOTFOUND"))
		End If
	EndIf	
	
	If KeyHit(KEY_ENTER) Then ok = True
	
	Flip
Until KeyHit(KEY_ESCAPE) Or AppTerminate() Or ok = True

WriteIni()

If ok = False Then End

If cmb_Mod.SelectedItem() > 0 Then gModLoc = gSaveloc+"Mods/"+cmb_Mod.SelectedText()+"/"

Global gLanguageStr:String = LoadVariableString(gSaveLoc+"Settings/Settings.ini", "language")

Function CheckSettingsInput()
	While fry_PollEvent()
		Select fry_EventID()
			Case fry_EVENT_GADGETSELECT
				Select fry_EventSource()
					Case btn_ok							ok=True
					Case cmb_Language					
						WriteIni()
						If FileType(gAppLoc+"New Star GP.exe") = 1
							OpenURL(gAppLoc+"New Star GP.exe")
						EndIf
						
						End
				EndSelect
		
		End Select
	Wend
End Function

Function WriteIni()
	Local ini:TStream=WriteFile(gSaveLoc+"Settings/Settings.ini")
	Local count:Int 
	
	For Local mode:TMyGfxModes = EachIn TMyGfxModes.list
		If count = cmb_Res.SelectedItem()
			WriteLine(ini, "screenw="+mode.w)
			WriteLine(ini, "screenh="+mode.h)
		EndIf
		
		count:+1
	Next

	WriteLine(ini, "fullscreen="+cmb_Screen.SelectedItem())
	WriteLine(ini, "language="+GetLanguageName(cmb_Language.SelectedItem()))
	WriteLine(ini, "debug="+gDebugMode)
	WriteLine(ini, "lowdetail="+cmb_Detail.SelectedItem())
	WriteLine(ini, "freesound="+gFreeSound)
	WriteLine(ini, "saveracereport="+gSaveRaceReport)
	
	CloseStream ini
End Function

Function GetLanguageNum:Int(l:String = "en")
	For Local i:Int = 0 Until locales.length
		If l = locales[i] Then Return i
	Next
	
	Return -1
End Function

Function GetLanguageName:String(l:Int = 0)
	ValidateMinMax(l, 0, locales.Length-1)
	Return locales[l]
End Function

Function WriteNewIni()
	Local ini:TStream = WriteFile(gSaveloc + "Settings/Settings.ini")
	If Not ini Then Return
	WriteLine(ini, "screenw=800")
	WriteLine(ini, "screenh=600")
	WriteLine(ini, "fullscreen=1")
	WriteLine(ini, "language=en")
	WriteLine(ini, "debug=0")
	WriteLine(ini, "lowdetail=0")
	WriteLine(ini, "freesound=0")
	WriteLine(ini, "saveracereport=0")
	CloseStream ini
End Function

Function SetUpLanguage()
	LoadLocaleFile(gAppLoc+"Languages/NSGP.blf")
	Local lang:String = LoadVariableString(gSaveloc+"Settings/Settings.ini", "language")
	SetCurrentLocale(lang)
	
	SetMaskColor(255,0,255)
	imgLang = Null
	imgLang = LoadMyImage("Media/Nations/NationIm_"+GetLocaleText("Tag_NationId")+".png")
	
	'Do FryGui
	If lang <> "en" Then fntname = "trebucbd.ttf"
	
	Applog "Load Skin"
	fry_Initialise_XML()
	fry_LoadSkin(gAppLoc+"Skin")
	fry_AddFont("Default", fntname, 11)
	fry_AddFont("Small", fntname, 9)
	fry_AddFont("Medium", fntname, 16)
	fry_AddFont("Large", fntname, 24)
	fry_ParseGUI()
	fry_SetScreen("screen_settings")

End Function

Global credits:TList = CreateList()
LoadCredits()

Function LoadCredits()
	Applog "LoadCredits"
	
	Local ini:TStream=ReadFile("incbin::Inc/Credits.txt")
	If Not ini RuntimeError "Could not open file: Credits.txt"
	
	While Not Eof(ini)
		credits.AddLast(ReadLine(ini))
	Wend
	CloseStream ini
	
	Applog "CreditsLoaded"
End Function

Function DoCredits()
	Global lasttime:Int = 0
	Global line:Int = 0
	
	If gMillisecs > lasttime+5000
		Local creds:Object[] = credits.ToArray()
		Local txt:String = String(creds[line])
		
		line:+1
		lasttime = gmillisecs
		If line = credits.Count() Then line = 0
		
		TScreenMessage.Create(screenW/4, screenH-78, txt, , 3000, 1)
		
		creds = Null
		txt = Null
	EndIf
End Function

Function ReadRegIni(name:String Var, license:String Var)
	AppLog "ReadRegIni"
	Local ini:TStream=ReadFile(gSaveloc+"Settings/Reg.ini")
	
	If ini
		name = ReadLine(ini)
		license = ReadLine(ini)
		CloseStream ini
	EndIf
End Function

Function WriteRegIni(name:String, code:String)
	Local ini:TStream=WriteFile(gSaveloc+"Settings/Reg.ini")
	If ini
		WriteLine(ini, name)
		WriteLine(ini, code)
		CloseStream ini
	EndIf
End Function

Function UpdateModCombo()
	cmb_Mod.ClearItems()
	cmb_Mod.AddItem(GetLocaleText("No"))
	Local dir:Int = ReadDir(gSaveloc+"Mods/")
	
	Repeat
		Local dirname$=NextFile( dir )
		If dirname="" Exit
		If dirname = "." Or dirname = ".." Then Continue
		
		If FileType(gSaveloc+"Mod/"+dirname) <> 1
			cmb_Mod.AddItem(dirname)
		EndIf
	Forever
	
	CloseDir dir
	
	cmb_Mod.SelectItem(0)
End Function

Type TMyGfxModes
	Global list:TList
	Field w:Int
	Field h:Int
	
	Function Create(w:Int, h:Int)
		DebugLog "TMyGfxModes.Create"
		Local newmode:TMyGfxModes = New TMyGfxModes
		newmode.w = w
		newmode.h = h
		
		If Not list Then list = CreateList()
		list.AddLast(newmode)
	End Function
	
	Function OnListAlready:Int(w:Int, h:Int)
		DebugLog "TMyGfxModes.OnlistAlready"
		If Not list Then Return False
		
		For Local m:TMyGfxModes = EachIn list
			If m.w = w And m.h = h Then Return True
		Next
		
		Return False
	End Function
End Type
