' Slot Machine
Global gameSlotMachine:TSlotMachine = New TSlotMachine

Type TSlotMachine
	Field slot1:TSlotStrip = New TSlotStrip
	Field slot2:TSlotStrip = New TSlotStrip
	Field slot3:TSlotStrip = New TSlotStrip
	Field spinning:Int = False
	Field nudging:Int = False
	Field nudges:Int = 0
	Field hiddennudges:Int = 0
	Field minislots:Int = 0
	Field imgBG:TImage
	
	Method SetUp(mini:Int = 0)
		minislots = mini
		
		' Pass a relationship type to set up mini version of slots
		If minislots  > 0
			MoveMouse(screenW/2+150, screenH/2)
			fry_Refresh()			
			imgBG = Null
			imgBG = CreateImage(screenW,screenH,1,DYNAMICIMAGE)
			GrabImage(imgBG, 0, 0)
			pan_Casino_Nav.Hide()
			pan_Date.Hide()
			pan_Header.Hide()
			pan_SlotsControl.Hide()
			pan_SlotsNudges.Hide()
			pan_SlotsNudgeCount.Hide()
		End If
		
		spinning = False
		nudging = False
		nudges = 0
		hiddennudges = 0
		slot1.SetUp(256, mini)
		slot2.SetUp(357, mini)
		slot3.SetUp(458, mini)
		UpdateNudgeButtons()
	End Method
	
	Method Main()
		Local now:Int = MilliSecs()
		Global pause:Int = 0
		
		slot1.Update()
		slot2.Update()
		slot3.Update()
		
		If slot1.reelstopped And slot2.reelstopped And slot3.reelstopped
			If spinning = True 
				pause = MilliSecs()
				spinning = False
				DoPrize()
				HideCasinoButtons(False)
			End If
			
			If minislots And MilliSecs() > pause+1500
				pan_Casino_Nav.Show()
				pan_Date.Show()
				pan_Header.Show()
				pan_SlotsControl.Show()
				pan_SlotsNudges.Show()
				pan_SlotsNudgeCount.Show()
				'fry_SetScreen("relationscreen")
				'SetUpScreen_Relations()
			End If
		End If
		
		' Reset viewport
		SetViewport(0,0,screenW, screenH)
		
		While MilliSecs() < update_time + now;	Wend
	End Method
	
	Method Spin(mini:Int = False)	
		If spinning = True Then Return
		
		If Not mini
			Local bet:Int = 0
			Select cmb_SlotMachineBetAmount.SelectedItem()
			Case 0	bet = 50
			Case 1	bet = 100
			Case 2	bet = 250
			Case 3	bet = 500
			Case 4	bet = 750
			Case 5	bet = 1000
			Case 6	bet = 2500
			Case 7	bet = 5000
			Case 8	bet = 10000
			Case 9	bet = 50000
			End Select
			
			If Not CasinoBet(bet) Then Return
			HideCasinoButtons()
		EndIf
		
		slot1.Spin(1)
		slot2.Spin(2)
		slot3.Spin(3)
		spinning = True
		nudging = False
		
		' Use hiddennudges to update nudges. This way you won't get nudges until next go.
		nudges:+hiddennudges
		If nudges > 3 Then nudges = 3
		hiddennudges = 0
		UpdateNudgeButtons()
	End Method
	
	Method DoPrize()
		If minislots
			If slot1.fruit = slot2.fruit And slot2.fruit = slot3.fruit
		'		TScreenMessage.Create("+10", 10, CFONT_LARGE, slot2.xPos+gOffSetX+40, screenH/2, 0, True)
		'		UpdateRelationship(minislots, 10, False, True)
				Return
			ElseIf slot1.fruit = slot2.fruit
		'		TScreenMessage.Create("+5", 10, CFONT_LARGE, slot2.xPos+gOffSetX+40, screenH/2, 0, True)
		'		UpdateRelationship(minislots, 5, False, True)
				Return
			ElseIf slot1.fruit = slot3.fruit
		'		TScreenMessage.Create("+5", 10, CFONT_LARGE, slot2.xPos+gOffSetX+40, screenH/2, 0, True)
		'		UpdateRelationship(minislots, 5, False, True)
				Return
			ElseIf slot2.fruit = slot3.fruit
		'		TScreenMessage.Create("+5", 10, CFONT_LARGE, slot2.xPos+gOffSetX+40, screenH/2, 0, True)
		'		UpdateRelationship(minislots, 5, false, true)
				Return
			Else
				' Nothing
				Return
			EndIf
		Else
			UpdateGambling(0.35, GetBetTotal())
		EndIf
		
		' Can't gain new nudges from nudging
		If nudging = False
			If slot1.fruit = slot2.fruit And slot2.fruit <> slot3.fruit	Then hiddennudges:+1		' 1 and 2
			If slot1.fruit <> slot2.fruit And slot2.fruit = slot3.fruit	Then hiddennudges:+1		' 2 and 3
			If slot1.fruit <> slot2.fruit And slot1.fruit = slot3.fruit	Then hiddennudges:+1		' 1 and 3
		Else
			' Reset so you can nudge again
			nudging = False
		EndIf
		
		If slot1.fruit = slot2.fruit And slot2.fruit = slot3.fruit
			Local prize:Int
			Local bet:Int = GetBetTotal()
			
			Select slot1.fruit
			Case 0	prize = bet*3
			Case 1	prize = bet*5
			Case 2	prize = bet*10
			Case 3	prize = bet*15
			Case 4	prize = bet*20
			Case 5	prize = bet*25
			Case 6	prize = bet*30
			Case 7	prize = bet*35
			End Select 
			
			CasinoWin(prize)
			nudges = 0
			hiddennudges = 0
		End If
		
		UpdateNudgeButtons()
	End Method
	
	Method GetBetTotal:Int()
		Local bet:Int = 0
		
		Select cmb_SlotMachineBetAmount.SelectedItem()
		Case 0	bet = 50
		Case 1	bet = 100
		Case 2	bet = 250
		Case 3	bet = 500
		Case 4	bet = 750
		Case 5	bet = 1000
		Case 6	bet = 2500
		Case 7	bet = 5000
		Case 8	bet = 10000
		Case 9	bet = 50000
		End Select
		
		Return bet
	End Method
	
	Method UpdateNudgeButtons()
		If nudges > 0
			cmb_SlotMachineBetAmount.Hide()
			btn_SlotMachineNudge1.SetAlpha(1)
			btn_SlotMachineNudge2.SetAlpha(1)
			btn_SlotMachineNudge3.SetAlpha(1)
		Else
			cmb_SlotMachineBetAmount.Show()
			btn_SlotMachineNudge1.SetAlpha(0.5)
			btn_SlotMachineNudge2.SetAlpha(0.5)
			btn_SlotMachineNudge3.SetAlpha(0.5)
		End If
		
		lbl_nudges.SetText(String(nudges))
	End Method
	
	Method Nudge(n:Int)
		If nudges < 1 Or nudging = True Then Return
		
		Select n
		Case 1	slot1.Nudge()
		Case 2	slot2.Nudge()
		Case 3	slot3.Nudge()
		End Select
		
		spinning = True
		nudging = True
		nudges:-1
		UpdateNudgeButtons()
	End Method

End Type

Type TSlotStrip
	Field imgStrip:TImage
	Field imgStripCasino:TImage = LoadMyImage("Media/Casino/Slots/Strip.png")
	Field imgStripTeam:TImage = LoadMyImage("Media/Casino/Slots/MiniStripTeam.png")
	Field imgStripFans:TImage = LoadMyImage("Media/Casino/Slots/MiniStripFans.png")
	Field imgStripFamily:TImage = LoadMyImage("Media/Casino/Slots/MiniStripFamily.png")
	Field imgStripFriends:TImage = LoadMyImage("Media/Casino/Slots/MiniStripFriends.png")
	Field imgStripGirl:TImage = LoadMyImage("Media/Casino/Slots/MiniStripGirl.png")
	Field imgStripChildren:TImage = LoadMyImage("Media/Casino/Slots/MiniStripChildren.png")
	
	Field reelH:Int
	Field fruitCount:Int
	
	Field xPos:Int
	Field yPos1:Float = 0
	Field yPos2:Float = 0
	Field yVel:Float = 0
	Field spintime:Int = 0
	Field spinlength:Int = 0
	Field reelstopped:Int
	Field fruit:Int
	
	Method SetUp(x:Int, mini:Int = 0)
		
		Select mini
'		Case CRELATION_TEAM			imgStrip = imgStripTeam
'		Case CRELATION_FANS			imgStrip = imgStripFans
'		Case CRELATION_FAMILY		imgStrip = imgStripFamily
'		Case CRELATION_FRIENDS		imgStrip = imgStripFriends
'		Case CRELATION_GIRLFRIEND	imgStrip = imgStripGirl
'		Case CRELATION_CHILDREN		imgStrip = imgStripChildren
		Default						imgStrip = imgStripCasino
		End Select
		
		fruitCount = 8
		If mini Then fruitCount = 6
		
		reelH:Int = ImageHeight(imgStrip)
		xPos = x
		yPos1 = 0
		yPos2 = yPos1-reelH
		yVel = 0
		reelstopped = True
		Draw()
	End Method
	
	Method Update()
		If yVel > 0
			yVel:-0.1
			yPos1:+yVel
			yPos2:+yVel
		EndIf
		
		If reelstopped = False And MilliSecs() > spintime+spinlength			'yVel < 10 And 
			Local fruitH:Int = (reelH/fruitCount)
			Local pos1:Int = yPos1
			If pos1 < 0 Then pos1:+reelH
			If pos1 > reelH Then pos1:-reelH
			
			For Local l:Int = 0 To fruitCount
				If pos1 >= l*fruitH And pos1 <= (l*fruitH)+fruitH/2
					yPos1 = l*fruitH
					yPos2 = yPos1-reelH
					fruit = l
					
					Local str:String
					Select l
					Case 0	str = GetLocaleText("Orange")
					Case 1	str = GetLocaleText("Plum")
					Case 2	str = GetLocaleText("Banana")
					Case 3	str = GetLocaleText("Apple")
					Case 4	str = GetLocaleText("Grapes")
					Case 5	str = GetLocaleText("Cherries")
					Case 6	str = GetLocaleText("Pineapple")
					Case 7	str = GetLocaleText("Strawberry")
					Case 8	str = GetLocaleText("Orange"); fruit = 0
					End Select 
					
					PlaySound(snd_SlotsStop, chn_Casino)
					'TScreenMessage.Create(str, 10, CFONT_LARGE, xPos+(fruitH/2), screenH/2, 0, True)
					
					If fruitCount = 6 
						fruit = fruit Mod 3
						AppLog "Fruit: "+fruit
					Else
						AppLog str
					EndIf
					
					reelstopped = True
					yVel = 0
					
					Exit
				EndIf
			Next
		End If
		
		If yPos1 > reelH Then yPos1 = yPos2-reelH
		If yPos2 > reelH Then yPos2 = yPos1-reelH
		
		Draw()
	End Method
	
	Method Nudge()
		yVel = 8
		reelstopped = False
		spintime = MilliSecs()
		spinlength = 200
	End Method
	
	Method Spin(s:Int)
		spintime = MilliSecs()
		
		Select s
		Case 1	yVel = Rnd(22, 24); spinlength = 1500+Rand(250)
		Case 2	yVel = Rnd(24, 26); spinlength = 2000+Rand(250)
		Case 3	yVel = Rnd(26, 28); spinlength = 2500+Rand(250)
		End Select
		
		If fruitCount = 6
			yVel:-4
			spinlength:-750
		EndIf
		
		reelstopped = False
		
		PlaySound(snd_SlotsArm, chn_Casino)

	End Method
	
	Method Draw()
		SetViewport(xPos+gOffsetX,203+gOffsetY,86,192)
		DrawImage(imgStrip, xPos+gOffsetX, yPos1+gOffsetY)
		DrawImage(imgStrip, xPos+gOffsetX, yPos2+gOffsetY)
	End Method
End Type