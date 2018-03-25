AppLog "Include Roulette.bmx"
Const CNOOF_POCKETS:Float = 38		' EU wheel has 37 pockets/US has 38 
Const CPOCKET_ANGLE:Float = 9.473	' 360/37

Global gameRoulette:TRoulette = New TRoulette
gameRoulette.SetUp()

Type TRoulette
	Field imgRouletteTable:TImage = LoadMyImage("Media/Casino/Roulette/Table.png")
	Field imgChip_50:TImage = LoadMyImage("Media/Casino/Roulette/Chip_50.png")
	Field imgChip_100:TImage = LoadMyImage("Media/Casino/Roulette/Chip_100.png")
	Field imgChip_250:TImage = LoadMyImage("Media/Casino/Roulette/Chip_250.png")
	Field imgChip_500:TImage = LoadMyImage("Media/Casino/Roulette/Chip_500.png")
	Field imgChip_750:TImage = LoadMyImage("Media/Casino/Roulette/Chip_750.png")
	Field imgChip_1000:TImage = LoadMyImage("Media/Casino/Roulette/Chip_1000.png")
	Field imgChip_2500:TImage = LoadMyImage("Media/Casino/Roulette/Chip_2500.png")
	Field imgChip_5000:TImage = LoadMyImage("Media/Casino/Roulette/Chip_5000.png")
	Field imgChip_10000:TImage = LoadMyImage("Media/Casino/Roulette/Chip_10000.png")
	Field wheel:TRouletteWheel = New TRouletteWheel
	Field roulball:TRouletteBall = New TRouletteBall
	Field tableX:Int = 400
	Field tableY:Int = 80
	Field tableW:Int = ImageWidth(imgRouletteTable)
	Field tableH:Int = ImageHeight(imgRouletteTable)
	Field tableColW:Int = tableW/5
	Field tableRowH:Int = (tableH)/14
	
	Field result:Int = True
	
	' Bet record
	Field bet:Int[50]	' 0-36, 37=00, 38 = 1-18, 39 = Even, 40 = Red, 41 = Black, 42 = Odd, 43 = 19-36, 44 = 1st 12, 45 = 2nd 12, 46 = 3rd 12, 47 = 2 to 1, 48 = 2 to 1, 49 = 2-1
	
	Method SetUp()
		tableX = 400 + gOffsetX
		tableY = 80 + gOffsetY
		
		MidHandleImage(wheel.imageOuter)
		MidHandleImage(wheel.imageInner)
		MidHandleImage(roulball.imBallIm)
		MidHandleImage(imgChip_50)
		MidHandleImage(imgChip_100)
		MidHandleImage(imgChip_250)
		MidHandleImage(imgChip_500)
		MidHandleImage(imgChip_750)
		MidHandleImage(imgChip_1000)
		MidHandleImage(imgChip_2500)
		MidHandleImage(imgChip_5000)
		MidHandleImage(imgChip_10000)
		ClearBets()
	End Method
	
	Method Main()
		Local now:Int = MilliSecs()
		DrawImage(imgRouletteTable, tableX, tableY)
		
		wheel.Update()
		wheel.Draw()
		roulball.Update(wheel)
		roulball.Draw()
		
		CheckTableInput()					' Check for bet clicks
		DrawChips()							' Show chips on table
		If result = False And roulball.bStopped = 1 Then GetResult()	' Get result after bet
		While MilliSecs() < update_time + now;	Wend
	End Method 
	
	Method Spin()
		' Lock the spin button
		If not CasinoBet(GetBetTotal()) Then Return
		
		If result = False Then Return
		result = False
		wheel.Reset()
		roulball.Reset(wheel)
		HideCasinoButtons()
	End Method
	
	Method CheckTableInput()
		If bMessageBoxIsUp Then Return
		
		' Lock the clear button
		If result = False Then Return
		
		Local mX:Int = MouseX() - tableX
		Local mY:Int = MouseY() - tableY
		
		If mX > 0 and mX < tableW and mY > 0 and mY < tableH
			If MouseDown(1) 
				While MouseDown(1) Wend
				PlaceBet(GetCol(mX), GetRow(mY))
			EndIf
		EndIf
		
	End Method
	
	Method GetCol:Int(mx:Int)
		mx:+1
		If mx > tableColW * 4 Then Return 5
		If mx > tableColW * 3 Then Return 4
		If mx > tableColW * 2 Then Return 3
		If mx > tableColW Then Return 2
		Return 1
	End Method
	
	Method GetRow:Int(my:Int)
		If my > tableRowH * 13 Then Return 14
		If my > tableRowH * 12 Then Return 13
		If my > tableRowH * 11 Then Return 12
		If my > tableRowH * 10 Then Return 11
		If my > tableRowH * 9 Then Return 10
		If my > tableRowH * 8 Then Return 9
		If my > tableRowH * 7 Then Return 8
		If my > tableRowH * 6 Then Return 7
		If my > tableRowH * 5 Then Return 6
		If my > tableRowH * 4 Then Return 5
		If my > tableRowH * 3 Then Return 4
		If my > tableRowH * 2 Then Return 3
		If my > tableRowH Then Return 2
		Return 1
	End Method
	
	Method PlaceBet(col:Int, row:Int)
		' Ignore empty space
		If row = 1 Or row = 14
			If col < 3 Then Return
		EndIf
		
		' Check groups
		Select Col
		Case 1
			If row = 2 Or row = 3 Then SetBet(38)
			If row = 4 or row = 5 Then SetBet(39)
			If row = 6 Or row = 7 Then SetBet(40)
			If row = 8 Or row = 9 Then SetBet(41)
			If row = 10 Or row = 11 Then SetBet(42)
			If row = 12 Or row = 13 Then SetBet(43)
			
		Case 2
			If row = 2 or row = 3 or row = 4 or row = 5 Then SetBet(44)
			If row = 6 Or row = 7 Or row = 8 Or row = 9 Then SetBet(45)
			If row = 10 Or row = 11 Or row = 12 Or row = 13 Then SetBet(46)
			
		Default
			Select row
			Case 1
				' Bet on the naughts
				If Col = 3 Then SetBet(0)
				If Col = 4
					If MouseX() - tableX < (tableColW * 3)+(tableColW/2) 
						SetBet(0)
					Else
						SetBet(37)
					EndIf
				End If
				If Col = 5 Then SetBet(37)
			Case 2
				Select Col
				Case 3	SetBet(1)
				Case 4	SetBet(2)
				Case 5	SetBet(3)
				End Select
			Case 3
				Select Col
				Case 3	SetBet(4)
				Case 4	SetBet(5)
				Case 5	SetBet(6)
				End Select
			Case 4
				Select Col
				Case 3	SetBet(7)
				Case 4	SetBet(8)
				Case 5	SetBet(9)
				End Select
			Case 5
				Select Col
				Case 3	SetBet(10)
				Case 4	SetBet(11)
				Case 5	SetBet(12)
				End Select
			Case 6
				Select Col
				Case 3	SetBet(13)
				Case 4	SetBet(14)
				Case 5	SetBet(15)
				End Select
			Case 7
				Select Col
				Case 3	SetBet(16)
				Case 4	SetBet(17)
				Case 5	SetBet(18)
				End Select
			Case 8
				Select Col
				Case 3	SetBet(19)
				Case 4	SetBet(20)
				Case 5	SetBet(21)
				End Select
			Case 9
				Select Col
				Case 3	SetBet(22)
				Case 4	SetBet(23)
				Case 5	SetBet(24)
				End Select
			Case 10
				Select Col
				Case 3	SetBet(25)
				Case 4	SetBet(26)
				Case 5	SetBet(27)
				End Select
			Case 11
				Select Col
				Case 3	SetBet(28)
				Case 4	SetBet(29)
				Case 5	SetBet(30)
				End Select
			Case 12
				Select Col
				Case 3	SetBet(31)
				Case 4	SetBet(32)
				Case 5	SetBet(33)
				End Select
			Case 13
				Select Col
				Case 3	SetBet(34)
				Case 4	SetBet(35)
				Case 5	SetBet(36)
				End Select
			Case 14
				' Bet on the 2 to 1s
				If Col = 3 Then SetBet(47)
				If Col = 4 Then SetBet(48)
				If Col = 5 Then SetBet(49)
			End Select
		End Select
	End Method
	
	Method DrawChips()
		' 0-36, 37=00, 38 = 1-18, 39 = Even, 40 = Red, 41 = Black, 42 = Odd, 43 = 19-36, 44 = 1st 12, 45 = 2nd 12, 46 = 3rd 12, 47 = 2 to 1, 48 = 2 to 1, 49 = 2-1
		If bet[0] > 0 Then PlaceChip(3,1, bet[0])
		
		If bet[1] > 0 Then PlaceChip(3,2, bet[1])
		If bet[2] > 0 Then PlaceChip(4,2, bet[2])
		If bet[3] > 0 Then PlaceChip(5,2, bet[3])
		If bet[4] > 0 Then PlaceChip(3,3, bet[4])
		If bet[5] > 0 Then PlaceChip(4,3, bet[5])
		If bet[6] > 0 Then PlaceChip(5,3, bet[6])
		If bet[7] > 0 Then PlaceChip(3,4, bet[7])
		If bet[8] > 0 Then PlaceChip(4,4, bet[8])
		If bet[9] > 0 Then PlaceChip(5,4, bet[9])
		If bet[10] > 0 Then PlaceChip(3,5, bet[10])
		If bet[11] > 0 Then PlaceChip(4,5, bet[11])
		If bet[12] > 0 Then PlaceChip(5,5, bet[12])
		If bet[13] > 0 Then PlaceChip(3,6, bet[13])
		If bet[14] > 0 Then PlaceChip(4,6, bet[14])
		If bet[15] > 0 Then PlaceChip(5,6, bet[15])
		If bet[16] > 0 Then PlaceChip(3,7, bet[16])
		If bet[17] > 0 Then PlaceChip(4,7, bet[17])
		If bet[18] > 0 Then PlaceChip(5,7, bet[18])
		If bet[19] > 0 Then PlaceChip(3,8, bet[19])
		If bet[20] > 0 Then PlaceChip(4,8, bet[20])
		If bet[21] > 0 Then PlaceChip(5,8, bet[21])
		If bet[22] > 0 Then PlaceChip(3,9, bet[22])
		If bet[23] > 0 Then PlaceChip(4,9, bet[23])
		If bet[24] > 0 Then PlaceChip(5,9, bet[24])
		If bet[25] > 0 Then PlaceChip(3,10, bet[25])
		If bet[26] > 0 Then PlaceChip(4,10, bet[26])
		If bet[27] > 0 Then PlaceChip(5,10, bet[27])
		If bet[28] > 0 Then PlaceChip(3,11, bet[28])
		If bet[29] > 0 Then PlaceChip(4,11, bet[29])
		If bet[30] > 0 Then PlaceChip(5,11, bet[30])
		If bet[31] > 0 Then PlaceChip(3,12, bet[31])
		If bet[32] > 0 Then PlaceChip(4,12, bet[32])
		If bet[33] > 0 Then PlaceChip(5,12, bet[33])
		If bet[34] > 0 Then PlaceChip(3,13, bet[34])
		If bet[35] > 0 Then PlaceChip(4,13, bet[35])
		If bet[36] > 0 Then PlaceChip(5,13, bet[36])
		
		If bet[37] > 0 Then PlaceChip(5,1, bet[37])
		
		If bet[38] > 0 Then PlaceChip(1,2, bet[38])
		If bet[39] > 0 Then PlaceChip(1,4, bet[39])
		If bet[40] > 0 Then PlaceChip(1,6, bet[40])
		If bet[41] > 0 Then PlaceChip(1,8, bet[41])
		If bet[42] > 0 Then PlaceChip(1,10, bet[42])
		If bet[43] > 0 Then PlaceChip(1,12, bet[43])
		
		If bet[44] > 0 Then PlaceChip(2,3, bet[44])
		If bet[45] > 0 Then PlaceChip(2,7, bet[45])
		If bet[46] > 0 Then PlaceChip(2,11, bet[46])
		
		If bet[47] > 0 Then PlaceChip(3,14, bet[47])
		If bet[48] > 0 Then PlaceChip(4,14, bet[48])
		If bet[49] > 0 Then PlaceChip(5,14, bet[49])
		
		Local TotalBet:Int = 0
		
		For Local b:Int = 0 To bet.Length-1
			TotalBet:+bet[b]
		Next	
		lbl_RouletteTotal.SetText(TCurrency.GetString(OpCurrency,TotalBet))
		
	End Method
	
	Method PlaceChip(col:Int, row:Int, amount:Int)
		
		Local x:Int = tableX+(col*tableColW)-(tableColW/2)
		Local y:Int = tableY+(row*tableRowH)-(tableRowH/2)
		
		If row = 1 Then x:+tableColW/2
		If col < 3 Then y:+tableRowH/2
		
		Select amount
		Case 0	
		Case 50		DrawImage(imgChip_50, x, y)
		Case 100	DrawImage(imgChip_100, x, y)
		Case 250	DrawImage(imgChip_250, x, y)
		Case 500	DrawImage(imgChip_500, x, y)
		Case 750	DrawImage(imgChip_750, x, y)
		Case 1000	DrawImage(imgChip_1000, x, y)
		Case 2500	DrawImage(imgChip_2500, x, y)
		Case 5000	DrawImage(imgChip_5000, x, y)
		Case 10000	DrawImage(imgChip_10000, x, y)
		End Select
		
	End Method
	
	Method SetBet(b:Int)
		Local Amount:Int = 0
		
		Select cmb_RouletteBetAmount.SelectedItem()
		Case 0	Amount = 50
		Case 1	Amount = 100
		Case 2	Amount = 250
		Case 3	Amount = 500
		Case 4	Amount = 750
		Case 5	Amount = 1000
		Case 6	Amount = 2500
		Case 7	Amount = 5000
		Case 8	Amount = 10000
		End Select
		
		While fry_PollEvent(); Wend
			
		If bet[b] > 0
			' Refund
			'UpdateCash(bet[b])
			bet[b] = 0
		Else
			' Place bet
			bet[b] = Amount
			If GetCash() < GetBetTotal() Then DoMessage("CMESSAGE_NOFUNDS"); bet[b] = 0; Return
		End If
	End Method
	
	Method GetBetTotal:Int()
		Local total:Int = 0
		For Local n:Int = 0 To bet.Length-1
			total:+bet[n]
		Next
		Return total
	End Method
	
	Method ClearBets()
		' Lock the clear button
		If result = False Then Return
		
		For Local b:Int = 0 To bet.Length-1
			bet[b] = 0
		Next
	End Method
	
	Method GetResult()
		' 0-36, 37=00, 38 = 1-18, 39 = Even, 40 = Red, 41 = Black, 42 = Odd, 43 = 19-36, 44 = 1st 12, 45 = 2nd 12, 46 = 3rd 12, 47 = 2 to 1, 48 = 2 to 1, 49 = 2-1
		result = True
		
		Local winnings:Int = 0
		
		' Ball
		Local ballnum:Int = Int(roulball.fPocket)
		ballnum = TRouletteWheel.PocketNum[ballnum]
		Local gambler:Int = False
		
		' Do Winnings
		For Local n:Int = 0 To bet.Length-1
			If bet[n] > 0
				gambler = True
				
				' Bet on individual number
				If n < 38
					If ballnum = n Then winnings:+(bet[n]*36)
				EndIf
				
				' Do column 1
				Select n
				Case 38	'1-18
					If ballnum > 0 and ballnum < 9 Then winnings:+(bet[n]*2)
				Case 39	'EVEN
					
					If ballnum > 0 and ballnum < 37 and (ballnum mod 2) = 0 Then winnings:+(bet[n]*2)
				Case 40	'RED
					If TRouletteWheel.GetColour(ballnum) = 1 Then winnings:+(bet[n]*2)
				Case 41	'BLACK
					If TRouletteWheel.GetColour(ballnum) = 0 Then winnings:+(bet[n]*2)
				Case 42	'ODD
					If ballnum > 0 and ballnum < 37 and (ballnum mod 2) = 1 Then winnings:+(bet[n]*2)
				Case 43	'19-36
					If ballnum > 19 and ballnum < 37 Then winnings:+(bet[n]*2)
				' Do column 2
				Case 44	'1-12
					If ballnum > 0 and ballnum < 13 Then winnings:+(bet[n]*3)
				Case 45	'13-24
					If ballnum > 12 and ballnum < 25 Then winnings:+(bet[n]*3)
				Case 46	'25-36
					If ballnum > 24 and ballnum < 37 Then winnings:+(bet[n]*3)
				' Do row 14 (2-1s)
				Case 47
					Select ballnum
					Case 1		winnings:+(bet[n]*3)
					Case 4		winnings:+(bet[n]*3)
					Case 7		winnings:+(bet[n]*3)
					Case 10		winnings:+(bet[n]*3)
					
					Case 13		winnings:+(bet[n]*3)
					Case 16		winnings:+(bet[n]*3)
					Case 19		winnings:+(bet[n]*3)
					Case 22		winnings:+(bet[n]*3)
					
					Case 25		winnings:+(bet[n]*3)
					Case 28		winnings:+(bet[n]*3)
					Case 31		winnings:+(bet[n]*3)
					Case 34		winnings:+(bet[n]*3)
					End Select
					
				Case 48
					Select ballnum
					Case 2		winnings:+(bet[n]*3)
					Case 5		winnings:+(bet[n]*3)
					Case 8		winnings:+(bet[n]*3)
					Case 11		winnings:+(bet[n]*3)
					
					Case 14		winnings:+(bet[n]*3)
					Case 17		winnings:+(bet[n]*3)
					Case 20		winnings:+(bet[n]*3)
					Case 23		winnings:+(bet[n]*3)
					
					Case 26		winnings:+(bet[n]*3)
					Case 29		winnings:+(bet[n]*3)
					Case 32		winnings:+(bet[n]*3)
					Case 35		winnings:+(bet[n]*3)
					End Select
					
				Case 49
					Select ballnum
					Case 3		winnings:+(bet[n]*3)
					Case 6		winnings:+(bet[n]*3)
					Case 9		winnings:+(bet[n]*3)
					Case 12		winnings:+(bet[n]*3)
					
					Case 15		winnings:+(bet[n]*3)
					Case 18		winnings:+(bet[n]*3)
					Case 21		winnings:+(bet[n]*3)
					Case 24		winnings:+(bet[n]*3)
					
					Case 27		winnings:+(bet[n]*3)
					Case 30		winnings:+(bet[n]*3)
					Case 33		winnings:+(bet[n]*3)
					Case 36		winnings:+(bet[n]*3)
					End Select
				End Select
			EndIf
		Next
		
		If gambler
			UpdateGambling(1, GetBetTotal())
		EndIf
		
		If winnings > 0
			CasinoWin(winnings)
		EndIf
		
		HideCasinoButtons(False)
	End Method
EndType

Type TRouletteWheel
	' Inner and outer limits of the gulley
	Field iWheelSize:Int = 150
	Field iRimSize:Int = 270
	Field imageOuter:TImage = LoadMyImage("Media/Casino/Roulette/Wheel.png")
	Field imageInner:TImage = LoadMyImage("Media/Casino/Roulette/Wheel_Inner.png")
	
	' Place the wheel in centre of screen
	Field fX:Float = 200
	Field fY:Float = 300
	
	' Rotation and speed of the wheel
	Field fRot:Float = 0
	Field fSpeed:Float = 0
	
	' Actual pocket numbers
	Global PocketNum:Int[] = [0,1,13,36,24,3,15,34,22,5,17,32,20,7,11,30,26,9,28,37,2,14,35,23,4,16,33,21,6,18,31,19,8,12,29,25,10,27]
	
	Method Reset()		
		' Start wheel spinning
		fSpeed = 6.0+Rnd(0.1,1.1)
	End Method
	
	Method Update()
		' Spin da wheel
		fRot:+fSpeed*GetRouletteSpeed()
		
		If fSpeed <= 0 
			fSpeed = 0
		Else
			fSpeed :- 0.025*GetRouletteSpeed()
		End If
		
		' Bounds check
		If fRot > 360 Then fRot = 1
	End Method
	
	Method Draw()
		DrawImage(imageOuter, fX+gOffsetX, fY+gOffsetY)
		SetRotation fRot+280
		DrawImage(imageInner, fX+gOffsetX, fY+gOffsetY)
	End Method
	
	Function GetColour:Int(pocket:Int)
		Select pocket
		Case 0	Return -1
		Case 1	Return 1
		Case 3	Return 1
		Case 5	Return 1
		Case 7	Return 1
		Case 9	Return 1
		Case 12	Return 1
		Case 14	Return 1
		Case 16	Return 1
		Case 18	Return 1
		Case 19	Return 1
		Case 21	Return 1
		Case 23	Return 1
		Case 25	Return 1
		Case 27	Return 1
		Case 30	Return 1
		Case 32	Return 1
		Case 34	Return 1
		Case 36	Return 1
		Case 37	Return -1	' 00
		Default
			Return 0
		End Select
		
	End Function
End Type

Type TRouletteBall
	' Gravity needed to make ball descend
	' at a reasonable speed
	Global fGrav:Float = 0.35
	
	' Ball size
	Global iSize:Int = 8
	
	' The ball position is actually calculated using 
	' a line that extends from the center of wheel. 
	' An oval is simply drawn at the end of the line.
	Field imBallIm:TImage = LoadMyImage("Media/Casino/Roulette/Ball.png")
	
	' Angle of line
	Field fLineRot:Float
	
	' Ball speed
	Field fSpeed:Float
	
	' Distance from the center of the wheel
	Field fDist:Float
	
	' Velocity that ball descends towards wheel
	Field fVel:Float
	
	' Balls actual position
	Field fX:Float
	Field fY:Float
	
	' Pocket where ball sits
	Field fPocket:Float = 0
	
	Field bStopped:Int
	Global bDropped:Int	'	Has ball hit a pin?
	
	Method Reset(wheel:TRouletteWheel)
		' Start ball moving
		fLineRot = Rand(360)
		fSpeed = -9.6
		fDist = wheel.iRimSize/2
		fVel = -0.1
		bDropped = False
		bStopped = False
		PlaySound(snd_RouletteSpin, chn_Casino)
	End Method
	
	Method Update(wheel:TRouletteWheel)
		SetRotation 0		
		
		' Ball rolls around wheel (in opposition direction)
		fLineRot:+fSpeed*GetRouletteSpeed()
		If fLineRot > 360 Then fLineRot:-360
		If fLineRot < 1 Then fLineRot:+360
		
		' Calculate current pocket it is over
		fPocket = (fLineRot/CPOCKET_ANGLE) - (wheel.fRot/CPOCKET_ANGLE)
		If fPocket < 0 Then fPocket:+CNOOF_POCKETS
		
		' Drop ball into gulley after wheels slows down a bit
		If wheel.fSpeed < 4
			' Increase velocity of fall
			fVel:-fGrav*GetRouletteSpeed()
			
			' Adjust distance of ball from center (length of line)
			fDist:+fVel*GetRouletteSpeed()
		
			' If ball hits wheel
			If fDist <= wheel.iWheelSize/2
				If not bDropped
					PlaySound(snd_RouletteHit, chn_Casino)
				End If
				
				' Reset ball to inner boundary
				fDist = wheel.iWheelSize/2
				
				' Reverse ball velocity to bounce it
				fVel = -(fVel*0.6)	
				
				' If bouncing has decreased enough then stay in current pocket
				If fVel > -0.5 and fVel < 0.5					
					If not bDropped
						PlaySound(snd_RouletteLand, chn_Casino)
						bDropped = True
					End If
					
					' Move ball around at same speed as wheel
					fSpeed = wheel.fSpeed
					
					' Settle in center of pocket
					Local movement:Int = False
					If fPocket > Float(Int(fPocket))+0.62 Then fLineRot :-0.2*GetRouletteSpeed(); movement = True
					If fPocket < Float(Int(fPocket))+0.58 Then fLineRot :+0.2*GetRouletteSpeed(); movement = True
					
					' If ball was settling then by now it has stopped moving
					If movement = False Then bStopped = true
				Else
					' Set random deflection of ball
					' Ball is more likely to get hit in the direction
					' of the wheel so give it a positive bias
					fSpeed = Rnd(-0.1, wheel.fSpeed+fSpeed*GetRouletteSpeed())
				EndIf
			EndIf
		EndIf
	
		' Calculate actual ball position
		fX = wheel.fX + Cos(fLineRot) * fDist
		fY = wheel.fY + Sin(fLineRot) * fDist
	End Method

	Method Draw()
		' Draw ball 
		DrawImage(imBallIm, fx+gOffsetX, fy+gOffsetY)
		
		' Update number display
		Local pocket:Int = fPocket
		If pocket > -1 And pocket < 38
			Local numStr:String = TRouletteWheel.PocketNum[pocket]
			
			Select TRouletteWheel.GetColour(numStr.ToInt())
			Case -1	lbl_RouletteBall.SetTextColour(0,200,0)
			Case 0	lbl_RouletteBall.SetTextColour(0,0,0)
			Case 1	lbl_RouletteBall.SetTextColour(230,0,0)
			End Select
			
			If numStr = "37" Then numStr = "00"
			lbl_RouletteBall.SetText(numStr)
			
		EndIf
		
	End Method
	
	
End Type

Function GetRouletteSpeed:Float()
	Return 0.5
End Function