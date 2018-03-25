'=========================='
' BLACKJACK                '
'  by Ragnar Brynjulfsson  '
'=========================='
' ----------------------------------------------------------------------------------------------

Global MidScreenX:Float = screenW/2
Global MidScreenY:Float = screenH/2
Global dealerY:Float = MidScreenY-100
Global playerY:Float = MidScreenY+100
	
' LOAD MEDIA

' Load card graphics
Global Back:TImage	= LoadMyImage( "Media/Casino/BlackJack/back.png")	' Backside of cards.	
Global CardImg:TImage[52]
Global AllSuit:String[52]
Global AllValue:Int[52]
Local iCount:Int = 0
Global Suits:String[] = [ "club","diamond","heart","spade" ]
For Local Suit:String = EachIn Suits
	For Local n:Int=2 To 14
		CardImg[iCount] = LoadMyImage( "Media/Casino/BlackJack/"+n+"_"+Suit+".png")
		AllSuit[iCount] = Suit
		AllValue[iCount] = n
		iCount:+1
	Next
Next

' Text
Global BustImg:TImage = LoadMyImage( "Media/Casino/BlackJack/bust.png" )
Global Bust:TButton = TButton.Create( "Bust", BustImg, BustImg )
Bust.Pos = [ MidScreenX, 0.0, 0.0, 1.0, 1.0, 0.0 ]
Bust.Goal = [ MidScreenX, 0.0, 0.0, 1.0, 1.0, 0.0 ]
Global BlackjackImg:TImage = LoadMyImage( "Media/Casino/BlackJack/blackjack.png" )
Global Blackjack:TButton = TButton.Create( "Blackjack", BlackjackImg, BlackjackImg )
Blackjack.Pos = [ MidScreenX, 0.0, 0.0, 1.0, 1.0, 0.0 ]
Blackjack.Goal = [ MidScreenX, 0.0, 0.0, 1.0, 1.0, 0.0 ]
Global WinImg:TImage = LoadMyImage( "Media/Casino/BlackJack/win.png" )
Global Win:TButton = TButton.Create( "Win", WinImg, WinImg )
Win.Pos = [ MidScreenX, MidScreenY, 0.0, 1.0, 1.0, 0.0 ]
Win.Goal = [ MidScreenX, MidScreenY, 0.0, 1.0, 1.0, 0.0 ]
Global LoseImg:TImage = LoadMyImage( "Media/Casino/BlackJack/lose.png" )
Global Lose:TButton = TButton.Create( "Lose", LoseImg, LoseImg )
Lose.Pos = [ MidScreenX, MidScreenY, 0.0, 1.0, 1.0, 0.0 ]
Lose.Goal = [ MidScreenX, MidScreenY, 0.0, 1.0, 1.0, 0.0 ]
Global TieImg:TImage = LoadMyImage( "Media/Casino/BlackJack/tie.png" )
Global Tie:TButton = TButton.Create( "Tie", TieImg, TieImg )
Tie.Pos = [ MidScreenX, MidScreenY, 0.0, 1.0, 1.0, 0.0 ]
Tie.Goal = [ MidScreenX, MidScreenY, 0.0, 1.0, 1.0, 0.0 ]

' -------------------------------------------------------------------------------------------------

' Initialize the game.
Global gameBlackJack:TGame = New TGame		' Main object for the game itself. 
SeedRnd(MilliSecs())

Global Deck:TDeck = TDeck.Create() 	' Build a deck of 52 cards.
Deck.Shuffle()
Global Human:THand = New THand		' Create a default object for the player.
Human.CPU = 0
Global Computer:THand = New THand	' Create an object for the CPU player.
Computer.CPU = 1

' ----------------------------------------------------------------------------------------------

' TYPE DEFINITIONS

' Class for the main game screen.
Type TGame
	Global timer:TTimer = TTimer.Create( 300 )	' Interval between dealing cards.

	Field bet:Int = 0
	Field ScreenButtons:TList = CreateList()

	Field Stage:String = "init"
	
	Field WinLose:Int = 10
	Field TickCount:Int = 0
	
	Field ButtonTimer:Int = MilliSecs()
	Field BetTimer:Int = MilliSecs()
	
	Method Main()
		Local now:Int = MilliSecs()
				
		Select Stage
		Case "init"
			Initialize()
		Case "deal"
			Deal()
		Case "reset"
			Reset()
		Case "hit"
			' Wait for input
			btn_BlackJackHit.SetText(GetLocaleText("Hit"))
			DrawScores()
		Case "hold"
			Hold()
			DrawScores(True)
		Case "result"
			Result()
			DrawScores(True)
		Case "ready"
			Ready()
			DrawScores(True)
		End Select
		Update()
		
		While MilliSecs() < update_time + now;	Wend
	End Method
	
	Method DrawScores(both:Int = False)
		ResetDrawing(255,255,255,1)
		
		Local comscore:Int = Computer.Evaluate() 
		Local humanscore:Int = Human.Evaluate() 
		
		If both And comscore > 0 Then fnt_Medium.Draw(comscore, screenW/2-15, dealerY-(TCard.h/2)-fntoffset_Medium)
		If humanscore > 0 fnt_Medium.Draw(humanscore, screenW/2-15, playerY+(TCard.h/2)-8)
	End Method
	
	' Updates everything on the game screen.
	Method Update()
	
		Computer.Update()
		Computer.Draw()
		Human.Update()
		Human.Draw()
		
		For Local Butt:TButton = EachIn ScreenButtons
			Butt.Update()
			Butt.Draw()
		Next
		
		Local Card:TCard
		For Card = EachIn Human.Cards
			Card.Goal[5] = 1.0
		Next
		
		For Card = EachIn Computer.Cards
			Card.Goal[5] = 1.0
		Next
	End Method
		
	' --- Game Screen Methods ---
	
	Method Initialize()
		
		ScreenButtons.AddLast( Win )
		ScreenButtons.AddLast( Lose )
		ScreenButtons.AddLast( Tie )
		ScreenButtons.AddLast( Blackjack )
		ScreenButtons.AddLast( Bust )
		
		Stage = "ready"
	End Method
	
	Method Deal()
		HideCasinoButtons()
		timer.Wait = 300
		Select TickCount
		Case 1
			Computer.PutCard( Deck.PullCard() )
			Computer.GetCard().face = 0
			TickCount:+1
		Case 3
			Human.PutCard( Deck.PullCard() )
			TickCount:+1
		Case 5
			Computer.PutCard( Deck.PullCard() )
			TickCount:+1
		Case 7
			Human.PutCard( Deck.PullCard() )
			TickCount = 0
			WinLose = Human.CompareHands( Computer, 1 )
			If WinLose = 2 Or WinLose = -2
				Stage = "result"
			Else
				Stage = "hit"
			End If
		End Select
		If timer.Tick() Then TickCount:+1
	End Method
	
	' Resets the game and shuffles the deck.
	Method Reset(tc:Int = 0)
		If tc Then TickCount = tc	' Used to force a refresh
		
		' Clear the table.
		Win.Goal[5] = 0.0
		Tie.Goal[5] = 0.0
		Lose.Goal[5] = 0.0
		Blackjack.Goal[5] = 0.0
		Bust.Goal[5] = 0.0
		timer.Wait = 300
		
		Local card:TCard		
		If TickCount = 1
			For Card = EachIn Human.Cards
				Card.Goal =  [ 0.0, 896.0, 0.0, 1.0, 1.0, 0.0 ]
			Next
			For Card = EachIn Computer.Cards
				Card.Goal =  [ 0.0, -128.0, 0.0, 1.0, 1.0, 0.0 ]
			Next
		End If
		If TickCount = 3		
			For Card = EachIn Human.Cards
				Deck.PutCard( Human.PullCard(False) )
			Next
			For Card = EachIn Computer.Cards
				Deck.PutCard( Computer.PullCard(false) )
			Next			
			Deck.Shuffle()
			TickCount = 0
			
			' Show result unless this is a forced reset
			If tc = 0 
				Stage = "deal" 
			Else 
				Stage = "ready"
				WinLose = 10
			EndIf
		End If
		If timer.Tick() Then TickCount:+1
	End Method
			
	Method HitButton()
		Select Stage 
		Case "hit" 
			' Hit me button.
			ButtonTimer = MilliSecs()
			Human.PutCard( Deck.PullCard() )
			WinLose = Human.CompareHands( Computer )
			If WinLose = -3 Or Human.GetSize() = 5 Then Stage = "result"
			
		Case "ready"		
			Select cmb_BlackJackBetAmount.SelectedItem()
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
			
			If not CasinoBet(bet) Then Return
			ButtonTimer = MilliSecs()
			TickCount = 0
			Stage = "reset"
			
		Default
			Return
			
		End Select
	End Method
	
	Method HoldButton()
		If Stage <> "hit" Then Return
		ButtonTimer = MilliSecs()
		TickCount = 0
		Stage = "hold"
	End Method

	Method Hold()
		timer.Wait = 400
		Computer.GetCard().face = 1
		Local hisHand:Int = Computer.Evaluate()
		Local myHand:Int = Human.Evaluate()
		If TickCount Then
			TickCount = 0
			If myHand > hisHand And Computer.GetSize() < 5 And hisHand < 17 Then
				Computer.PutCard( Deck.PullCard() )
			Else
				WinLose = Human.CompareHands( Computer )
				Stage = "result"
			End If
		End If
		If timer.Tick() Then TickCount = 1
	End Method 
	
	' Move cash around.
	Method Result()
		UpdateGambling(1,bet)
		If WinLose = 0 Then CasinoWin(bet)			' Tie
		If WinLose > 0 Then CasinoWin(bet*2)		' Win
		Stage = "ready"
		HideCasinoButtons(False)
	End Method
	
	' Displays the result of one round.
	Method Ready()
		Local card:TCard
		Select WinLose
			Case 3
				For Local Card:TCard = EachIn Computer.Cards
					Card.Goal[5] = 0.4
				Next
				Bust.Pos[1] = dealerY
				Bust.Goal[1] = dealerY
				Bust.Goal[5] = 0.8
				Win.Goal[5] = 1.0			
			Case 2
				For Local Card:TCard = EachIn Human.Cards
					Card.Goal[5] = 0.4
				Next
				Blackjack.Pos[1] = playerY
				Blackjack.Goal[1] = playerY
				Blackjack.Goal[5] = 0.8
				Win.Goal[5] = 1.0
			Case 1
				Win.Goal[5] = 1.0
			Case 0
				Tie.Goal[5] = 1.0
			Case -1
				Lose.Goal[5] = 1.0
			Case -2
				Computer.GetCard().face = 1	
				For Local Card:TCard = EachIn Computer.Cards
					Card.Goal[5] = 0.4
				Next
				Blackjack.Pos[1] = dealerY
				Blackjack.Goal[1] = dealerY
				Blackjack.Goal[5] = 0.8
				Lose.Goal[5] = 1.0
			Case -3
				For Local Card:TCard = EachIn Human.Cards
					Card.Goal[5] = 0.4
				Next
				Bust.Pos[1] = playerY
				Bust.Goal[1] = playerY
				Bust.Goal[5] = 0.8
				Lose.Goal[5] = 1.0
		End Select
		
		btn_BlackJackHit.SetText(GetLocaleText("Deal"))
	End Method
	
	Function Create:TGame()
		Return New TGame
	End Function
End Type

' Base class for anything that can hold cards (i.e. the deck, players hands etc.)
Type TDeck
	Field Cards:TList = CreateList()

	
	' Returns one card from the TDeck.
	Method GetCard:TCard( Number:Int = 0 )
		Local n:Int=0
		For Local c:TCard = EachIn Cards
			If n = Number Then Return c
			n:+1
		Next
	End Method
	
	' Returns the number of cards in a deck.
	Method GetSize:Int()
		Return CountList( Cards )
	End Method
	
	' Pulls (draws) the top card from the TDeck.
	Method PullCard:TCard(snd:Int = True)
		If snd Then PlaySound(snd_BlackJackSweep, chn_Casino)
		Local TempCard:TCard = GetCard()
		If TempCard Then Self.Cards.RemoveFirst()
		Return TempCard
	End Method
	
	
	' Puts a card last in the deck.
	Method PutCard:TCard( inCard:TCard )
		Self.Cards.AddLast( inCard )
	End Method
	
	' Shuffles the cards in the TDeck. Shuffling is done by setting the order
	' field to a random value and then sorting the TDeck by that.
	Method Shuffle()
		For Local c:TCard = EachIn Cards
			c.Order = Rnd(0,65000)
		Next
		Cards.Sort(True)
	End Method
	
	' Creates a deck of cards. By default it contains 52 cards, but you can decide
	' to start it from a higher number, such as seven and up. Useless for this game,
	' but handy if I decide to create a different game later. :)
	Function Create:TDeck() Final
		Local TempDeck:TDeck = New TDeck
		For Local i:Int=0 To 51
			TempDeck.Cards.AddLast( TCard.Create( i ) )
		Next
		Return TempDeck
	End Function	
End Type

' Base class for a hand of cards and the player holding that hand. Used for human and CPU players.
Type THand Extends TDeck
	Field CPU:Int					' Human = 0 or CPU = 1
	Field Cash:Int = 1000
	Field Bet:Int =1
	
	' Adds a card To the bottom of the TDeck.
	Method PutCard:TCard( inCard:TCard )
		Self.Cards.AddLast( inCard )
		Local CardCount:int = Cards.Count()
		
		Local w:Int = TCard.w/2
		Local FirstCardPosition:Float = (CardCount*(-W))+W+MidScreenX
		FirstCardPosition:+ (TCard.w)*(CardCount-1)
		inCard.Pos[0] = FirstCardPosition

		If CPU Then 
			inCard.Pos =   [ Float(screenW), 0.0, -90.0, 0.0, 0.0, 0.0 ]
			inCard.Goal =  [ FirstCardPosition, dealerY, 0.0, 1.0, 1.0, 1.0 ]
			inCard.face = 1
		Else
			inCard.Pos =   [ Float(screenW), 0.0, -90.0, 0.0, 0.0, 0.0 ]
			inCard.Goal =  [ FirstCardPosition, playerY, 0.0, 1.0, 1.0, 1.0 ]
			inCard.face = 1
		End If 
	End Method
	
	' Updates the positions of the cards on the screen.
	Method Update()
		Local CardCount:Int = Cards.Count()
		Local w:Int = TCard.w/2
		Local FirstCardPosition:Int = (CardCount*(-W))+W+MidScreenX
		Local i:Int = 0
		Local card:TCard
		For Card = EachIn Cards
			Card.Goal[0] = FirstCardPosition
			FirstCardPosition:+ (TCard.w)
			Card.Update()
		Next
	End Method
	
	' Draws the hand on the screen.
	Method Draw()
		For Local Card:TCard = EachIn Cards
			Card.Draw()
		Next
	End Method
	
	' Figures out the value of a hand. Returns two values in case you havea an ace.
	' Returns -1 if you're bust.
	Method Evaluate:Int()
		Local TotalValue:Int[2]
		Local Ace:Int = 0	' Has an ace on hand.
		For Local myCard:TCard = EachIn Cards
			Local Value:Int = myCard.Value
			If Value > 10 And Value < 14 Then Value = 10
			If Value = 14 Then
				Value = 1
				Ace = 1
			End If
			TotalValue[0] = TotalValue[0] + Value
			If Ace Then
				TotalValue[1] = TotalValue[0] + 10
			End If
		Next
		If TotalValue[1] < 22 And TotalValue[1] > TotalValue[0] Then 
			Return TotalValue[1]
		Else 
			Return TotalValue[0]
		End If
	End Method
	
	' Compares two hands, returns 1 if the owner wins.
	Rem
	 3 - Computer is bust.
	 2 - You got a Blackjack with two cards.
	 1 - You win.
	 0 - It's a tie.
	-1 - Computer wins.
	-2 - Comptur got a Blackjack with two cards.
	-3 - You are bust.
	End Rem
	Method CompareHands:Int( inHand:THand, Initial:Int=0 )
		Local winner:Int
		Local myHand:Int = Evaluate()
		Local hisHand:Int = inHand.Evaluate()
		If Initial Then
			If myHand = 21
				Return 2
			Else If hisHand = 21
				Return -2
			End If
		End If
		If myHand > 21 Then Return -3
		If hisHand > 21 Then Return 3
		If Self.GetSize() = 5 And myHand < 22 Then Return 1
		If inHand.GetSize() = 5 And hisHand < 22 Then Return -1
		If myHand > hisHand And myHand < 22
			Return 1
		Else If myHand < hisHand And hisHand < 22
			Return -1
		Else If myHand = hisHand And myHand < 22
			Return 0
		End If
	End Method
End Type

' Base class for each playing card.
Type TCard
	Field Suit:String			' club, diamond, heart, spade
	Field Value:Int			' 2..14  ( 11=jack, 12=queen, 13=king, 14=ace)
	Field Order:Int			' Used to shuffle the cards with.
	Global w:Int = 100
	Global h:Int = 150

	' Array fields for positioning and moving the card. The index in the array is as follow:
	'[ 0=PositionX, 1=PositionY, 2=Rotate, 3=ScaleX, 4=ScaleY, 5=Alpha ]
	Field Pos:Float[] =   [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
	Field Goal:Float[] =  [ 0.0, 0.0, 0.0, 1.0, 1.0, 1.0 ]
	Field Speed:Float[] = [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
	Field face:Int = 1		' If the card should face up 1 or down 0.
	Field Front:TImage		' Main image to display.
	Global Lag:Float = 8.0

	' Overrides the TList function to make cards be sorted by the Order field.
	Method Compare:Int(Obj:Object)
		If TCard(Obj).Order < Order Then Return 1 Else Return -1
	End Method

	' Updates the position of the card.
	Method Update()
		For Local i:Int = 0 To 5
			Local Distance:Float = Goal[i] - Pos[i]
			Local Acceleration:Float = (Distance - Speed[i]*Lag)*2/(Lag*Lag)
			Speed[i]:+ Acceleration
			Pos[i]:+ Speed[i]
		Next 
	End Method
	
	' Draws an image of the card on the screen at x,y.
	Method Draw()
		SetTransform( Pos[2],Pos[3],Pos[4] )
		SetAlpha( Pos[5] )
		If face Then
			DrawImageRect( Front, Pos[0]-w/2, Pos[1]-h/2, w, h )
		Else
			DrawImageRect( Back, Pos[0]-w/2, Pos[1]-h/2, w, h )
		End If
		SetTransform 0,1,1 
		SetAlpha 1
	End Method
	
	' Create a single card.
	Function Create:TCard( inCount:Int )
		Local Card:TCard = New TCard
		Card.Suit = AllSuit[inCount]
		Card.Value = AllValue[inCount]
		Card.Front = CardImg[inCount]
		'MidHandleImage( Card.Back )
		Return Card
	End Function
End Type

' Used for the graphic representation of buttons.
Type TButton
	Field Pos:Float[] =   [ 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 ]
	Field Goal:Float[] =  [ 0.0, 0.0, 0.0, 1.0, 1.0, 1.0 ]
	Field Speed:Float[] = [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
	Field GlowPos:Float[] =   [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
	Field GlowGoal:Float[] =  [ 0.0, 0.0, 0.0, 1.0, 1.0, 0.0 ]
	Field GlowSpeed:Float[] = [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
	Field Image:TImage
	Field GlowImage:TImage
	Field name:String
	Global Lag:Float = 8.0
	
	' Updates the position of the button.
	Method Update()
		For Local i:Int = 0 To 5
			Local Distance:Float = Goal[i] - Pos[i]
			Local Acceleration:Float = (Distance - Speed[i]*Lag)*2/(Lag*Lag)
			Speed[i]:+ Acceleration
			Pos[i]:+ Speed[i]
			Distance = GlowGoal[i] - GlowPos[i]
			Acceleration = (Distance - GlowSpeed[i]*Lag)*2/(Lag*Lag)
			GlowSpeed[i]:+ Acceleration
			GlowPos[i]:+ GlowSpeed[i]
		Next
	End Method
	
	' Draw the button.
	Method Draw()
		SetTransform( Pos[2],Pos[3],Pos[4] )
		SetAlpha( Pos[5] )
		DrawImage( Image, Pos[0]-(ImageWidth(Image)/2), Pos[1]-(ImageHeight(Image)/2) )
		SetTransform( GlowPos[2],GlowPos[3],GlowPos[4] )
		SetAlpha( GlowPos[5] )
		DrawImage( GlowImage, GlowPos[0]-(ImageWidth(Image)/2), GlowPos[1]-(ImageHeight(Image)/2) )
		SetTransform 0,1,1
		SetAlpha 1
	End Method
	
	' Create a representation for a button.
	Function Create:TButton( inName:String, inImage:TImage, inGlow:TImage )
		Local MyButton:TButton = New TButton
		MyButton.name = inName
		MyButton.Image = inImage
		MyButton.GlowImage = inGlow
		Return MyButton
	End Function
End Type

' Timer function. Use [ If Time.Tick() Then something... ]
Type TTimer
	Field Start:Int		' Start time.
	Field Ticks:Int		' The number of times the timer has clicked.
	Field Wait:Int		' Number of millisecs to wait between ticks.
	
	' Returns true if the timer ticks. Add's one to Tick count.
	Method Tick:Int()
		If MilliSecs() > Start + Wait
			Ticks:+1
			Start = MilliSecs()
			Return 1
		Else
			Return 0
		End If
	End Method
' Creates a timer. Takes time to wait between ticks as input.
	Function Create:TTimer( inWait:Int = 60 )
		Local time:TTimer = New TTimer
		time.Start = MilliSecs()
		time.Ticks = 0
		time.Wait = inWait
		Return time
	End Function
End Type
