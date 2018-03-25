Global pan_Casino_Nav:fry_TPanel = fry_TPanel(fry_GetGadget("pan_casinonav"))

bx = 10
Global btn_Casino_Home:fry_TButton = fry_CreateImageButton("btn_CasinoHome", gAppLoc+"Skin/Graphics/Buttons/Home.png", bx, 9, 32, 32, pan_Casino_Nav); bx:+42
Global btn_Casino_BlackJack:fry_TButton = fry_CreateImageButton("btn_BlackJack", gAppLoc+"Skin/Graphics/Buttons/BlackJack.png", bx, 9, 32, 32, pan_Casino_Nav); bx:+42
Global btn_Casino_Roulette:fry_TButton = fry_CreateImageButton("btn_Roulette", gAppLoc+"Skin/Graphics/Buttons/Roulette.png", bx, 9, 32, 32, pan_Casino_Nav); bx:+42
Global btn_Casino_Slots:fry_TButton = fry_CreateImageButton("btn_Slots", gAppLoc+"Skin/Graphics/Buttons/Slots.png", bx, 9, 32, 32, pan_Casino_Nav); bx:+42

' Black Jack
Global cmb_BlackJackBetAmount:fry_TComboBox = fry_TComboBox(fry_GetGadget("pan_blackjackcontrols/cmb_betamount"))

Global btn_BlackJackHit:fry_TButton = fry_TButton(fry_GetGadget("pan_blackjackcontrols/btn_hit"))
Global btn_BlackJackHold:fry_TButton = fry_TButton(fry_GetGadget("pan_blackjackcontrols/btn_hold"))

' Roulette
Global cmb_RouletteBetAmount:fry_TComboBox = fry_TComboBox(fry_GetGadget("pan_roulettecontrols/cmb_betamount"))

Global lbl_RouletteTotal:fry_TLabel = fry_TLabel(fry_GetGadget("pan_roulettecontrols/lbl_bettotal"))
Global lbl_RouletteBall:fry_TLabel = fry_TLabel(fry_GetGadget("pan_rouletteball/lbl_ball"))
Global btn_RouletteSpin:fry_TButton = fry_TButton(fry_GetGadget("pan_roulettecontrols/btn_spin"))
Global btn_RouletteClear:fry_TButton = fry_TButton(fry_GetGadget("pan_roulettecontrols/btn_clear"))

' Slot machine
Global pan_SlotsControl:fry_TPanel = fry_TPanel(fry_GetGadget("pan_slotmachinecontrols"))
Global pan_SlotsNudges:fry_TPanel = fry_TPanel(fry_GetGadget("pan_slotmachinenudges"))
Global pan_SlotsNudgeCount:fry_TPanel = fry_TPanel(fry_GetGadget("pan_slotmachinecount"))
Global cmb_SlotMachineBetAmount:fry_TComboBox = fry_TComboBox(fry_GetGadget("pan_slotmachinecontrols/cmb_betamount"))

Global btn_SlotMachinePlay:fry_TButton = fry_TButton(fry_GetGadget("pan_slotmachinecontrols/btn_play"))
Global btn_SlotMachineNudge1:fry_TButton = fry_TButton(fry_GetGadget("pan_slotmachinenudges/btn_nudge1"))
Global btn_SlotMachineNudge2:fry_TButton = fry_TButton(fry_GetGadget("pan_slotmachinenudges/btn_nudge2"))
Global btn_SlotMachineNudge3:fry_TButton = fry_TButton(fry_GetGadget("pan_slotmachinenudges/btn_nudge3"))
Global lbl_nudges:fry_TLabel = fry_TLabel(fry_GetGadget("pan_slotmachinenudgecount/lbl_nudges"))

' Sounds
Global chn_CasinoAmbience:TChannel = AllocChannel()
Global snd_CasinoAmbience:TSound = LoadMySound("Skin/Sounds/CasinoAmbience.ogg",1)

Global chn_Casino:TChannel = AllocChannel()
Global snd_BlackJackSweep:TSound = LoadMySound("Skin/Sounds/BlackJackSweep.ogg")
Global snd_RouletteSpin:TSound = LoadMySound("Skin/Sounds/RouletteSpin.ogg", 1)
Global snd_RouletteHit:TSound = LoadMySound("Skin/Sounds/RouletteHit.ogg")
Global snd_RouletteLand:TSound = LoadMySound("Skin/Sounds/RouletteLand.ogg")
Global snd_SlotsArm:TSound = LoadMySound("Skin/Sounds/SlotsArm.ogg")
Global snd_SlotsStop:TSound = LoadMySound("Skin/Sounds/SlotsStop.ogg")
Global snd_SlotsWin:TSound = LoadMySound("Skin/Sounds/SlotsWin.ogg")
Global snd_Cash:TSound = LoadMySound("Skin/Sounds/Cash.ogg")

Function SetUpScreen_Casino(message:String = "")
	If btn_NavBar_Casino.gAlpha < 1 Then DoMessage("CMESSAGE_NOTIME"); Return
	
	AppLog "SetUpScreen_Casino"
	fry_SetScreen("screen_casino")
	
	ResumeChannel(chn_CasinoAmbience)
	PlaySound(snd_CasinoAmbience, chn_CasinoAmbience)
	SetUpBetAmounts()
	
	If message <> ""
		If DoMessage(message, True)
			Select message
			Case "CMESSAGE_CASINO_FRIENDS"	UpdateRelationship(CRELATION_FRIENDS, 2.5)
			Case "CMESSAGE_CASINO_PITCREW"	UpdateRelationship(CRELATION_PITCREW, 5)
			End Select
		Else
			SetUpScreen_Home()
			Return
		End If
	EndIf
	SaveGame()
	
	SpendTime()
End Function

Function SetUpScreen_BlackJack()
	AppLog "SetUpScreen_BlackJack"
	fry_SetScreen("screen_blackjack")
	'TScreenMessage.Clear()
	Global firstrun:Int = True
	If firstrun
		firstrun = False
	Else
		gameBlackJack.Reset(3)
	EndIf
End Function

Function SetUpScreen_Roulette()
	AppLog "SetUpScreen_Roulette"
	fry_SetScreen("screen_roulette")
	
	gameRoulette.ClearBets()
	'TScreenMessage.Clear()
	Global firstrun:Int = True
	If firstrun
		firstrun = False
	Else
		'gameBlackJack.Reset(3)
	EndIf
End Function

Function SetUpScreen_Slots(mini:Int = 0)
	AppLog "SetUpScreen_Slots"
	fry_SetScreen("screen_slots")
	'TScreenMessage.Clear()
	gameSlotMachine.SetUp(mini)
End Function

Function HideCasinoButtons(hide:Int = True)
	Select hide
	Case True
		btn_ExitGame.Hide()
		btn_Casino_Home.Hide()
		btn_Casino_BlackJack.Hide()
		btn_Casino_Roulette.Hide()
		btn_Casino_Slots.Hide()
	Case False
		btn_ExitGame.Show()
		btn_Casino_Home.Show()
		btn_Casino_BlackJack.Show()
		btn_Casino_Roulette.Show()
		btn_Casino_Slots.Show()
	EndSelect
End Function

Function CasinoBet:Int(b:Int)
	If Not UpdateCash(-b) Then Return False
	
	Local gamblingmoney:Int = GetDatabaseInt("gamblingmoney", "gamedata", 1)
	gamblingmoney:-b
	UpdateDatabaseInt("gamedata", "gamblingmoney", gamblingmoney, 1)
	
	Return True
End Function

Function CasinoWin(w:Int, xpos:Int = -1, ypos:Int = -1)
'	If xpos < 0 And ypos < 0
'		xpos = prg_Title.AbsoluteX()+prg_Title.gW
'		ypos = prg_Title.AbsoluteY()+20
'	End If
	PlaySound(snd_Cash, chn_Casino)
'	TScreenMessage.Create("+"+TCurrency.GetString(OpCurrency,W), 5, CFONT_LARGE, xpos, ypos, -1, True)
	UpdateCash(w)
	
	Local gamblingmoney:Int = GetDatabaseInt("gamblingmoney", "gamedata", 1)
	gamblingmoney:+w
	UpdateDatabaseInt("gamedata", "gamblingmoney", gamblingmoney, 1)
End Function

Function UpdateGambling(g:Float, bettotal:Int)
	Local cash:Int = GetCash()
	
	If bettotal >= cash*5 
		g:*20
	ElseIf bettotal >= cash*2
		g:*10
	ElseIf bettotal >= cash
		g:*5
	EndIf
End Function

Function GetCash:Int()
	Return GetDatabaseInt("cash", "gamedata", 1)
End Function

Function GetStringNumberWithCommas:String(str:String)
	If Len(str) > 3 Then StrInsert(str, ",", Len(str)-3)
	If Len(str) > 7 Then StrInsert(str, ",", Len(str)-7)
	If Len(str) > 11 Then StrInsert(str, ",", Len(str)-11)
	If Len(str) > 15 Then StrInsert(str, ",", Len(str)-15)
	Return str
End Function

Function StrInsert(SourceStr:String Var, inString:String, Index:Int)
	SourceStr = SourceStr[..Index] + inString + SourceStr[Index..]
End Function

Function SetUpBetAmounts()
	cmb_BlackJackBetAmount.ClearItems()
	cmb_BlackJackBetAmount.AddItem(TCurrency.GetString(OpCurrency, 50))
	cmb_BlackJackBetAmount.AddItem(TCurrency.GetString(OpCurrency, 100))
	cmb_BlackJackBetAmount.AddItem(TCurrency.GetString(OpCurrency, 250))
	cmb_BlackJackBetAmount.AddItem(TCurrency.GetString(OpCurrency, 500))
	cmb_BlackJackBetAmount.AddItem(TCurrency.GetString(OpCurrency, 750))
	cmb_BlackJackBetAmount.AddItem(TCurrency.GetString(OpCurrency, 1000))
	cmb_BlackJackBetAmount.AddItem(TCurrency.GetString(OpCurrency, 2500))
	cmb_BlackJackBetAmount.AddItem(TCurrency.GetString(OpCurrency, 5000))
	cmb_BlackJackBetAmount.AddItem(TCurrency.GetString(OpCurrency, 10000))
	cmb_BlackJackBetAmount.AddItem(TCurrency.GetString(OpCurrency, 50000))
	cmb_BlackJackBetAmount.SelectItem(0)
	
	cmb_RouletteBetAmount.ClearItems()
	cmb_RouletteBetAmount.AddItem(TCurrency.GetString(OpCurrency, 50))
	cmb_RouletteBetAmount.AddItem(TCurrency.GetString(OpCurrency, 100))
	cmb_RouletteBetAmount.AddItem(TCurrency.GetString(OpCurrency, 250))
	cmb_RouletteBetAmount.AddItem(TCurrency.GetString(OpCurrency, 500))
	cmb_RouletteBetAmount.AddItem(TCurrency.GetString(OpCurrency, 750))
	cmb_RouletteBetAmount.AddItem(TCurrency.GetString(OpCurrency, 1000))
	cmb_RouletteBetAmount.AddItem(TCurrency.GetString(OpCurrency, 2500))
	cmb_RouletteBetAmount.AddItem(TCurrency.GetString(OpCurrency, 5000))
	cmb_RouletteBetAmount.AddItem(TCurrency.GetString(OpCurrency, 10000))
	
	cmb_RouletteBetAmount.SelectItem(0)

	cmb_SlotMachineBetAmount.ClearItems()
	cmb_SlotMachineBetAmount.AddItem(TCurrency.GetString(OpCurrency, 50))
	cmb_SlotMachineBetAmount.AddItem(TCurrency.GetString(OpCurrency, 100))
	cmb_SlotMachineBetAmount.AddItem(TCurrency.GetString(OpCurrency, 250))
	cmb_SlotMachineBetAmount.AddItem(TCurrency.GetString(OpCurrency, 500))
	cmb_SlotMachineBetAmount.AddItem(TCurrency.GetString(OpCurrency, 750))
	cmb_SlotMachineBetAmount.AddItem(TCurrency.GetString(OpCurrency, 1000))
	cmb_SlotMachineBetAmount.AddItem(TCurrency.GetString(OpCurrency, 2500))
	cmb_SlotMachineBetAmount.AddItem(TCurrency.GetString(OpCurrency, 5000))
	cmb_SlotMachineBetAmount.AddItem(TCurrency.GetString(OpCurrency, 10000))
	cmb_SlotMachineBetAmount.AddItem(TCurrency.GetString(OpCurrency, 50000))
	
	cmb_SlotMachineBetAmount.SelectItem(0)
	
	While fry_PollEvent(); Wend
End Function

Function UpdateCash:Int(amt:Int, verifyspend:Int = True)
	If gDebugMode And KeyDown(KEY_LCONTROL) Then Return True	' Debug Cheat
	
	Local cash:Int = GetCash()
	
	cash:+amt
	
	If amt < 0 And verifyspend = True
		If cash < 0	' Calculation has been done.
			DoMessage("CMESSAGE_NOFUNDS")
			Return False
		End If
	EndIf
	
	If cash < 0 Then cash = 0
	
	UpdateDatabaseInt("gamedata", "cash", cash, 1)
	UpdateProgressTitle()
	
	If amt > 0
		Local txt:String = TCurrency.GetString(OpCurrency, amt)
		TScreenMessage.Create(0,0,txt,imgCash,2000,2)
	End If
	
'	If cash >= 1000000
'		TAchievement.CheckAchievement(CACHIEVEMENT_MILLIONAIRE)
'	EndIf
	
	Return True
End Function
