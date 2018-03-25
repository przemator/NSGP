Global originx:Float = 0
Global originy:Float = 0
Global oldoriginx:Float = 0
Global oldoriginy:Float = 0
	
Function UpdateOrigin()
	Local car:TCar = TCar.SelectHumanCar() 
	
	If track.mode = CTRACKMODE_REPLAYING
		car = TCar.SelectReplayCar()
	End If
	
	Local carx:Float
	Local cary:Float
	
	If car
		carx = car.x*track.scale
		cary = car.y*track.scale
	EndIf
	
	oldoriginx = originx
	oldoriginy = originy
	
	' Update screen according to drivemode
	Select track.mode 
	Case CTRACKMODE_EDIT
		If KeyDown(KEY_LEFT) Or ButtonDown(MYKEY_LEFT) Then originx:+10
		If KeyDown(KEY_RIGHT) Or ButtonDown(MYKEY_RIGHT) Then originx:-10
		If KeyDown(KEY_UP) Or ButtonDown(MYKEY_UP) Then originy:+10
		If KeyDown(KEY_DOWN) Or ButtonDown(MYKEY_DOWN) Then originy:-10
	Case CTRACKMODE_EDITPAUSED
	Default
		originx = -carx+(screenW/2)
		originy = -cary+(screenH/2)
	End Select
	
	If track.editing = True or gLimitScroll
		If originx > 0 Then originx = 0
		If originx < -(track.trackw*track.tilesize)+screenW Then originx = -(track.trackw*track.tilesize)+screenW
	
		If originy > 0 Then originy = 0
		If originy < -(track.trackh*track.tilesize)+screenH Then originy = -(track.trackh*track.tilesize)+screenH
	EndIf
	
End Function

Function GetDistance:Float(x1#, y1#, x2#, y2#)
	Local a# = x1 - x2
	Local b# = y1 - y2
	Return Sqr(a*a + b*b)
End Function

Function GetDirection:Float(x1:Float,y1:Float,x2:Float,y2:Float)
	Local direction:Float = ATan2( y2 - y1, x2 - x1 )
	If direction > 359 Then direction:-360
	If direction < 0 Then direction:+360
	Return direction
End Function

Function ResetDrawing(r:Int = 255, g:Int = 255, b:Int = 255, a:Float = 1)
	SetBlend(ALPHABLEND)
	SetAlpha(a)
	SetColor(r, g, b)
	SetRotation(0)
End Function

Function GetDiffBetweenTwoAngles:Double(a1:Float, a2:Float, ab:Int = True)
	'Find the signed angle between two vectors of arbitrary but non-zero length in 2D
	Local prevA1:Int = a1
	
	Local v1:TMyVector = New TMyVector
	v1.x = Cos(a1)*10
	v1.y = Sin(a1)*10
	
	Local v2:TMyVector = New TMyVector
	v2.x = Cos(a2)*10
	v2.y = Sin(a2)*10
	
	Local pd:Float = perp_dot(v1,v2)
	
	If ab Then Return Abs(ATan2(pd,v1.GetDotPV(v2)))
	
	Return ATan2(pd,v1.GetDotPV(v2))
End Function

Function perp_dot:Float(v1:TMyVector,v2:TMyVector)
	Return -v1.y * v2.x + v1.x * v2.y
End Function

Type TMyVector

	Field X:Double
	Field Y:Double
	Field Z:Double
	
	Function Create:TMyVector(vx:Double, vy:Double, vz:Double)
		Local v:TMyVector = New TMyVector
		v.X = vx
		v.Y = vy
		v.Z = vz
		Return v
	End Function
	
	Method SetXYZ:TMyVector(vx:Double, vy:Double, vz:Double)
	
		X = vx
		Y = vy
		Z = vz
		
		Return Self
	
	EndMethod
	
	Method Set:TMyVector(v:TMyVector)
	
		X = v.X
		Y = v.Y
		Z = v.Z
		
		Return Self
	
	EndMethod
	
	Method Add:TMyVector(v:TMyVector)
	
		If v
		
			X = X + v.X
			Y = Y + v.Y
			Z = Z + v.Z
		
		EndIf
		
		Return Self
	
	EndMethod
	
	Method Sub:TMyVector(v:TMyVector)
	
		If v
		
			X = X - v.X
			Y = Y - v.Y
			Z = Z - v.Z
		
		EndIf
		
		Return Self
	
	EndMethod	
	
	Method SubXYZ:TMyVector(vx:Double, vy:Double, vz:Double)
	
		X = X - vx
		Y = Y - vy
		Z = Z - vz
		
		Return Self
	
	EndMethod	
	
	Method GetDotPV:Double(v:TMyVector)
	
		If v
		
			Return X * v.X + Y * v.Y + Z * v.Z
				
		EndIf
		
		Return 0
	
	EndMethod
	
	Method CrossPV:TMyVector(v:TMyVector)
	
		Local tx:Double, ty:Double, tz:Double

		If v 
		
			tx = X 
			ty = Y 
			tz = Z 
			X = ty * v.Z - tz * v.Y 
			Y = tz * v.X - tx * v.Z 
			Z = tx * v.Y - ty * v.X 
		
		EndIf 	
	
		Return Self
	
	EndMethod
	
	Method Mul:TMyVector(factor:Double)
	
		X :* factor
		Y :* factor
		Z :* factor
		
		Return Self
	
	EndMethod
	
	Method Div:TMyVector(divisor:Double)
	
		Local factor:Double
		
		factor = 1 / divisor
		
		X :* factor
		Y :* factor
		Z :* factor
		
		Return Self		
	
	EndMethod
	
	Method Normalize:TMyVector()

		Local factor:Double
		
		factor = 1.0 / Self.GetLength()
		
		X :* factor
		Y :* factor
		Z :* factor
		
		Return Self				
	
	EndMethod
	
	Method RotateAroundX:TMyVector(angle:Double)
	
		Local tx:Double, ty:Double, tz:Double
		
		tx = X 
		ty = Y 
		tz = Z 
		' X = tx 
		Y = Cos(angle) * ty - Sin(angle) * tz 
		Z = Sin(angle) * ty + Cos(angle) * tz  		
		
		Return Self
	
	EndMethod
	
	Method RotateAroundY:TMyVector(angle:Double)
	
		Local tx:Double, ty:Double, tz:Double
		
		tx = X 
		ty = Y 
		tz = Z 
		X = Cos(angle) * tx + Sin(angle) * tz
		' Y = ty   
		Z = -Sin(angle) * tx + Cos(angle) * tz		
		
		Return Self
	
	EndMethod
	
	Method RotateAroundZ:TMyVector(angle:Double)
	
		Local tx:Double, ty:Double, tz:Double
		
		tx = X 
		ty = Y 
		tz = Z 
		X = Cos(angle) * tx - Sin(angle) * ty
		Y = Sin(angle) * tx + Cos(angle) * ty   
		' Z = tz		
		
		Return Self
	
	EndMethod
	
	Method RotateAroundV:TMyVector(v:TMyVector, angle:Double)
	
		Local tx:Double, ty:Double, tz:Double, cosa:Double, sina:Double, ecosa:Double

		cosa = Cos(angle) 
		sina = Sin(angle) 
		ecosa = 1.0 - cosa

		tx = X 
		ty = Y 
		tz = Z 
		
		X = tx * (cosa + v.X * v.X * ecosa) + ty * (v.X * v.Y * ecosa - v.Z * sina) + tz * (v.X * v.Z * ecosa + v.Y * sina) 
		Y = tx * (v.Y * v.X * ecosa + v.Z * sina) + ty * (cosa + v.Y * v.Y * ecosa) + tz * (v.Y * v.Z * ecosa - v.X * sina)
		Z = tx * (v.Z * v.X * ecosa - v.Y * sina) + ty * (v.Z * v.Y * ecosa + v.X * sina) + tz * (cosa + v.Z * v.Z * ecosa)
		
		Return Self				
	
	EndMethod	
	
	Method Copy2Vec:TMyVector()
	
		Local v:TMyVector = New TMyVector
	
		If v
		
			v.X = X
			v.Y = Y
			v.Z = Z
		
		EndIf
		
		Return v
		
	EndMethod
		
	Method GetX:Double()
	
		Return X:Double

	EndMethod
	
	Method GetY:Double()
	
		Return Y:Double

	EndMethod

	Method GetZ:Double()
	
		Return Z:Double

	EndMethod
	
	Method GetLength:Double()
	
		Return Sqr(X * X + Y * Y + Z * Z) 
	
	EndMethod
	
	Method GetLengthSqr:Double()
	
		Return X * X + Y * Y + Z * Z
	
	EndMethod
	
	Method SetX:TMyVector(newX:Double)
	
		X = newX

	EndMethod
	
	Method SetY:TMyVector(newY:Double)
	
		Y = newY

	EndMethod

	Method SetZ:TMyVector(newZ:Double)
	
		Z = newZ

	EndMethod	

EndType


Function Lines_Intersect:TInterceptPoint(Ax#, Ay#, Bx#, By#, Cx#, Cy#, Dx#, Dy#)

' -------------------------------------------------------------------------------------------------------------------
' This Function determines If two lines intersect in 2D.
' 
' A & B are the endpoints of the first line segment.  C & D are the endpoints of the second.
'
'
' If the lines DO Not instersect, the Function returns False.
'
' If the lines DO intersect, the point of intersection is returned in the Global variables: 
' Intersection_X#, Intersection_Y#, Intersection_AB#, And Intersection_CD#
'
'
' Those last two variables indicate the location along each line segment where the point of intersection lies.
'
' For example:
'
' If Intersection_AB# is 0, Then the point of intersection is at point A.  If it is 1, Then it is at point B.
' If it is 0.5, Then it is halfway between the two.  And If it is less than 0 Or greater than 1, Then the point lies
' on the line but outside of the specified line segment.
'
'
' Because you can determine If the intersection point lies within both line segments, you can also use this Function
' To check To see If the line segments themselves intersect.
'
' Also, If these line segments indicate vectors of motion, Then If either of the location values returned is negative
' Then you know that the objects paths intersected in the past, And will Not intersect in the future.
'
' And finally, please note that segments which are coincident (lie on the same line) are considered To be
' non-intersecting, as there is no single point of intersection.  You can easily detect this condition by changing
' the code below slightly as indicated.
' -------------------------------------------------------------------------------------------------------------------
	Local ipoint:TInterceptPoint = New TInterceptPoint
	
	Local Rn# = (Ay#-Cy#)*(Dx#-Cx#) - (Ax#-Cx#)*(Dy#-Cy#)
    Local Rd# = (Bx#-Ax#)*(Dy#-Cy#) - (By#-Ay#)*(Dx#-Cx#)

	If Rd# = 0 
		' Lines are parralel.	
		ipoint.intercept = False
	Else
		' The lines intersect at some point.  Calculate the intersection point.
		ipoint.intercept = True

        Local Sn# = (Ay#-Cy#)*(Bx#-Ax#) - (Ax#-Cx#)*(By#-Ay#)

		ipoint.intercept_AB# = Rn# / Rd#
		ipoint.intercept_CD# = Sn# / Rd#

		ipoint.x# = Ax# + ipoint.intercept_AB#*(Bx#-Ax#)
		ipoint.y# = Ay# + ipoint.intercept_AB#*(By#-Ay#)
			
		If ipoint.intercept_AB > 1 Then ipoint.intercept = False
		If ipoint.intercept_AB < 0 Then ipoint.intercept = False
		If ipoint.intercept_CD > 1 Then ipoint.intercept = False
		If ipoint.intercept_CD < 0 Then ipoint.intercept = False
	EndIf

	Return ipoint
End Function

Function DoXYRotation(x:Float Var, y:Float Var, rot:Float, tilesize:Int)
	 ' Do rotation of tile
	Local temp:Float
	
	If rot > 0
		temp = y
		y = x
		x = tilesize-temp
	EndIf
	
	If rot > 90
		temp = y
		y = x
		x = tilesize-temp
	EndIf
	
	If rot > 180
		temp = y
		y = x
		x = tilesize-temp
	EndIf
End Function

Function DrawDriverProfileFlag1()
	ResetDrawing()
	If imgDriverProfileFlag1 Then DrawImageRect(imgDriverProfileFlag1, 1, 1, can_DriverNationality1.gW-2, can_DriverNationality1.gH-2)
End Function

Function DrawDriverProfileFlag2()
	ResetDrawing()
	If imgDriverProfileFlag2 Then DrawImageRect(imgDriverProfileFlag2, 1, 1, can_DriverNationality1.gW-2, can_DriverNationality1.gH-2)
End Function

Function DrawTeamProfileImg()
	ResetDrawing()
	If imgTeamProfile Then DrawImageRect(imgTeamProfile, 1, 1, can_TeamProfileImg.gW-2, can_TeamProfileImg.gH-2)
	SetColor(255,255,255)
	fnt_Small.Draw(GetLocaleText("Handling"), 10, 40)
	fnt_Small.Draw(GetLocaleText("Acceleration"), 10, 80)
	fnt_Small.Draw(GetLocaleText("Speed"), 10, 120)
End Function

Function DrawNewPlayerTeamImg()
	ResetDrawing()
	If imgTeamProfile Then DrawImageRect(imgTeamProfile, 1, 1, can_NewPlayer_TeamImg.gW-2, can_NewPlayer_TeamImg.gH-2)
End Function

Function DrawNewPlayerTeamRating1()
	ResetDrawing()
	If imgStar 
		For Local r:Int = 0 To NewPlayerTeamRating1-1
			DrawImage(imgStar, r*16,0)
		Next
	EndIf
End Function

Function DrawNewPlayerTeamRating2()
	ResetDrawing()
	If imgStar 
		For Local r:Int = 0 To NewPlayerTeamRating2-1
			DrawImage(imgStar, r*16,0)
		Next
	EndIf
End Function

Function DrawNewPlayerTeamRating3()
	ResetDrawing()
	If imgStar 
		For Local r:Int = 0 To NewPlayerTeamRating3-1
			DrawImage(imgStar, r*16,0)
		Next
	EndIf
End Function

Function DrawTeamProfileNat()
	ResetDrawing()
	If imgTeamProfileNat Then DrawImageRect(imgTeamProfileNat, 1, 1, can_TeamProfileNat.gW-2, can_TeamProfileNat.gH-2)
End Function

Function DrawTrackProfileFlag()
	ResetDrawing()
	If imgTrackProfileFlag Then DrawImageRect(imgTrackProfileFlag, 1, 1, can_TrackProfile_Flag.gW-2, can_TrackProfile_Flag.gH-2)
End Function

Function DrawTrackProfileImg()
	ResetDrawing()
	If imgTrackProfile Then DrawImageRect(imgTrackProfile, 1, 1, can_TrackProfile_Track.gW-2, can_TrackProfile_Track.gH-2)
End Function

Function GetFloatAsString:String(float_nr:Float, dp:Int=1)
	If dp = 0 Then dp = -1	' Don't return just the dot
	Return Left(float_nr,Instr(float_nr,".")+dp)
End Function

Function SetUpSlider(sld:fry_TSlider, low:Int, high:Int, pos:Int, inc:Int = 1)
	sld.SetRange(low,high)
	sld.SetIncrement(inc)
	sld.SetValue(pos)
	While fry_PollEvent() Wend
End Function

Function SetProgressColour(prg:fry_TProgressBar)
	Local val:Int = prg.GetValue()
	Local col:Float = val*2.55
	
	If val > 90
		prg.SetColour(0,255,0,1)
	Else
		prg.SetColour(255,col,0,1)
	EndIf
	
End Function

Function DrawRacePanel(rX:Int, rY:Int, gW:Int, gH:Int, r:Int, g:Int, b:Int, alpha:Float = 1)
	ResetDrawing(r,g,b,Alpha)
	
	'draw four corners
	DrawImage(imgRacePanel[0], rX, rY)
	DrawImage(imgRacePanel[2], (rX + gW) - 10, rY)
	DrawImage(imgRacePanel[6], rX, (rY + gH) - 10)
	DrawImage(imgRacePanel[8], (rX + gW) - 10, (rY + gH) - 10)

	'draw four sides
	DrawImageRect(imgRacePanel[1], rX + 10, rY, gW - 20, 10)
	DrawImageRect(imgRacePanel[7], rX + 10, (rY + gH) - 10, gW - 20, 10)
	DrawImageRect(imgRacePanel[3], rX, rY + 10, 10, gH - 20)
	DrawImageRect(imgRacePanel[5], (rX + gW) - 10, rY + 10, 10, gH - 20)
	
	'draw centre
	DrawImageRect(imgRacePanel[4], rX + 10, rY + 10, gW - 20, gH - 20)
	
	SetColor(255,255,255)
End Function

Function GetStringTyre:String(tyre:Int, shrt:Int = False)
	If shrt = True
		Select tyre
		Case CTYRE_HARD	Return "H"
		Case CTYRE_SOFT	Return "S"
		Case CTYRE_WET	Return "W"
		End Select
	Else
		Select tyre
		Case CTYRE_HARD	Return "Hard"
		Case CTYRE_SOFT	Return "Soft"
		Case CTYRE_WET	Return "Wet"
		End Select
	EndIf
End Function

Function GetStringTime:String(t:Int, secsonly:Int = False, iwaslapped:Int = 0)
	If iwaslapped = 1 
		Return "+"+iwaslapped+" "+GetLocaleText("Lap")
	ElseIf iwaslapped > 1 
		Return "+"+iwaslapped+" "+GetLocaleText("Laps")
	EndIf
	
	Local mins:String = (t/1000) / 60
	Local secs:String = (t Mod 60000)/1000
	Local hundreds:String = t Mod 1000
	
	If mins.ToInt() < 10 Then mins = "0"+mins
	If secs.ToInt() < 10 Then secs = "0"+secs
	If hundreds.ToInt() < 10 Then hundreds = "0"+hundreds
	If hundreds.ToInt() < 100 Then hundreds = "0"+hundreds
	
	If secsonly
		Return secs+":"+Left(hundreds,2)
	End If
	
	Return mins+":"+secs+":"+hundreds
	
End Function

Global radioqueue:TList = CreateList()

Function UpdateRadio()
	If radioqueue.Count() > 0 And chn_Radio.Playing() = False
		chn_Radio.SetVolume(OpVolumeFX*0.35)
		chn_Radio.SetRate(1)
		PlaySound(TSound(radioqueue.First()), chn_Radio)
		radioqueue.RemoveFirst()
	EndIf
End Function

Function RadioTime(time:Int)
	If Not OpRadio Then Return
	
	AppLog "RadioTime:"+time
	
	Local strTime:String = GetStringTime(time) 
	AppLog strTime 
	
	radioqueue.AddLast(snd_Static)
	
	Local mins:Int = (time/1000) / 60
	Local secs:Int = (time Mod 60000)/1000
	Local hundreds:Int = time Mod 1000
	
	AppLog "Mins:"+mins
	
	Select mins
	Case 0
	Case 1 radioqueue.AddLast(snd_1)
	Case 2 radioqueue.AddLast(snd_2)
	Case 3 radioqueue.AddLast(snd_3)
	Case 4 radioqueue.AddLast(snd_4)
	Case 5 radioqueue.AddLast(snd_5)
	Case 6 radioqueue.AddLast(snd_6)
	Case 7 radioqueue.AddLast(snd_7)
	Case 8 radioqueue.AddLast(snd_8)
	Case 9 radioqueue.AddLast(snd_9)
	Case 10 radioqueue.AddLast(snd_10)
	Case 20 radioqueue.AddLast(snd_20)
	Case 30 radioqueue.AddLast(snd_30)
	Case 40 radioqueue.AddLast(snd_40)
	Case 50 radioqueue.AddLast(snd_50)
	Case 60 radioqueue.AddLast(snd_60)
	End Select
	
	Select mins
	Case 0
	Case 1	radioqueue.AddLast(snd_minute)
	Default	radioqueue.AddLast(snd_minutes)
	End Select
	
	AppLog "Secs:"+secs
	
	Select secs
	Case 0 radioqueue.AddLast(snd_0)
	Case 1 radioqueue.AddLast(snd_1)
	Case 2 radioqueue.AddLast(snd_2)
	Case 3 radioqueue.AddLast(snd_3)
	Case 4 radioqueue.AddLast(snd_4)
	Case 5 radioqueue.AddLast(snd_5)
	Case 6 radioqueue.AddLast(snd_6)
	Case 7 radioqueue.AddLast(snd_7)
	Case 8 radioqueue.AddLast(snd_8)
	Case 9 radioqueue.AddLast(snd_9)
	
	Case 10 radioqueue.AddLast(snd_10)
	Case 11 radioqueue.AddLast(snd_11)
	Case 12 radioqueue.AddLast(snd_12)
	Case 13 radioqueue.AddLast(snd_13)
	Case 14 radioqueue.AddLast(snd_14)
	Case 15 radioqueue.AddLast(snd_15)
	Case 16 radioqueue.AddLast(snd_16)
	Case 17 radioqueue.AddLast(snd_17)
	Case 18 radioqueue.AddLast(snd_18)
	Case 19 radioqueue.AddLast(snd_19)
	
	Case 20 radioqueue.AddLast(snd_20)
	Case 21 radioqueue.AddLast(snd_20); radioqueue.AddLast(snd_1)
	Case 22 radioqueue.AddLast(snd_20); radioqueue.AddLast(snd_2)
	Case 23 radioqueue.AddLast(snd_20); radioqueue.AddLast(snd_3)
	Case 24 radioqueue.AddLast(snd_20); radioqueue.AddLast(snd_4)
	Case 25 radioqueue.AddLast(snd_20); radioqueue.AddLast(snd_5)
	Case 26 radioqueue.AddLast(snd_20); radioqueue.AddLast(snd_6)
	Case 27 radioqueue.AddLast(snd_20); radioqueue.AddLast(snd_7)
	Case 28 radioqueue.AddLast(snd_20); radioqueue.AddLast(snd_8)
	Case 29 radioqueue.AddLast(snd_20); radioqueue.AddLast(snd_9)
	
	Case 30 radioqueue.AddLast(snd_30)
	Case 31 radioqueue.AddLast(snd_30); radioqueue.AddLast(snd_1)
	Case 32 radioqueue.AddLast(snd_30); radioqueue.AddLast(snd_2)
	Case 33 radioqueue.AddLast(snd_30); radioqueue.AddLast(snd_3)
	Case 34 radioqueue.AddLast(snd_30); radioqueue.AddLast(snd_4)
	Case 35 radioqueue.AddLast(snd_30); radioqueue.AddLast(snd_5)
	Case 36 radioqueue.AddLast(snd_30); radioqueue.AddLast(snd_6)
	Case 37 radioqueue.AddLast(snd_30); radioqueue.AddLast(snd_7)
	Case 38 radioqueue.AddLast(snd_30); radioqueue.AddLast(snd_8)
	Case 39 radioqueue.AddLast(snd_30); radioqueue.AddLast(snd_9)
	
	Case 40 radioqueue.AddLast(snd_40)
	Case 41 radioqueue.AddLast(snd_40); radioqueue.AddLast(snd_1)
	Case 42 radioqueue.AddLast(snd_40); radioqueue.AddLast(snd_2)
	Case 43 radioqueue.AddLast(snd_40); radioqueue.AddLast(snd_3)
	Case 44 radioqueue.AddLast(snd_40); radioqueue.AddLast(snd_4)
	Case 45 radioqueue.AddLast(snd_40); radioqueue.AddLast(snd_5)
	Case 46 radioqueue.AddLast(snd_40); radioqueue.AddLast(snd_6)
	Case 47 radioqueue.AddLast(snd_40); radioqueue.AddLast(snd_7)
	Case 48 radioqueue.AddLast(snd_40); radioqueue.AddLast(snd_8)
	Case 49 radioqueue.AddLast(snd_40); radioqueue.AddLast(snd_9)
	
	Case 50 radioqueue.AddLast(snd_50)
	Case 51 radioqueue.AddLast(snd_50); radioqueue.AddLast(snd_1)
	Case 52 radioqueue.AddLast(snd_50); radioqueue.AddLast(snd_2)
	Case 53 radioqueue.AddLast(snd_50); radioqueue.AddLast(snd_3)
	Case 54 radioqueue.AddLast(snd_50); radioqueue.AddLast(snd_4)
	Case 55 radioqueue.AddLast(snd_50); radioqueue.AddLast(snd_5)
	Case 56 radioqueue.AddLast(snd_50); radioqueue.AddLast(snd_6)
	Case 57 radioqueue.AddLast(snd_50); radioqueue.AddLast(snd_7)
	Case 58 radioqueue.AddLast(snd_50); radioqueue.AddLast(snd_8)
	Case 59 radioqueue.AddLast(snd_50); radioqueue.AddLast(snd_9)
	
	Case 60 radioqueue.AddLast(snd_60)
	Case 61 radioqueue.AddLast(snd_60); radioqueue.AddLast(snd_1)
	Case 62 radioqueue.AddLast(snd_60); radioqueue.AddLast(snd_2)
	Case 63 radioqueue.AddLast(snd_60); radioqueue.AddLast(snd_3)
	Case 64 radioqueue.AddLast(snd_60); radioqueue.AddLast(snd_4)
	Case 65 radioqueue.AddLast(snd_60); radioqueue.AddLast(snd_5)
	Case 66 radioqueue.AddLast(snd_60); radioqueue.AddLast(snd_6)
	Case 67 radioqueue.AddLast(snd_60); radioqueue.AddLast(snd_7)
	Case 68 radioqueue.AddLast(snd_60); radioqueue.AddLast(snd_8)
	Case 69 radioqueue.AddLast(snd_30); radioqueue.AddLast(snd_9)
	End Select
	
	radioqueue.AddLast(snd_point)
	
	Local strHundreds:String = String(hundreds)
	If hundreds < 10 Then strHundreds = "0"+hundreds
	If hundreds < 100 Then strHundreds = "0"+hundreds
	
	For Local l:Int = 1 To 3
		AppLog Mid(strHundreds, l, 1).ToInt()
		Select Mid(strHundreds, l, 1).ToInt()
		Case 0 radioqueue.AddLast(snd_0)
		Case 1 radioqueue.AddLast(snd_1)
		Case 2 radioqueue.AddLast(snd_2)
		Case 3 radioqueue.AddLast(snd_3)
		Case 4 radioqueue.AddLast(snd_4)
		Case 5 radioqueue.AddLast(snd_5)
		Case 6 radioqueue.AddLast(snd_6)
		Case 7 radioqueue.AddLast(snd_7)
		Case 8 radioqueue.AddLast(snd_8)
		Case 9 radioqueue.AddLast(snd_9)
		End Select
	Next
	
	Select secs
	Case 1	radioqueue.AddLast(snd_second)
	Default	radioqueue.AddLast(snd_seconds)
	End Select
	
	radioqueue.AddLast(snd_Static)
End Function

Function ValidateMinMax(val:Int Var, minval:Int, maxval:Int)
	If val < minval Then val = minval
	If val > maxval Then val = maxval
End Function 

Function ValidateMinMaxFloat(val:Float Var, minval:Float, maxval:Float)
	If val < minval Then val = minval
	If val > maxval Then val = maxval
End Function 

Function DoSplashScreen:Int(img:TImage, tdelay:Int)
	MyFlushJoy()
	Local time:Int = MilliSecs()
	Local col1:Int = 0
	Local col2:Int = 255
	
	ResetDrawing(col1,col1,col1)
	
	Local running:Int = True
	Repeat
		If col1 < 255 
			col1:+5
			ResetDrawing(col1,col1,col1)
			time = MilliSecs()
		EndIf
	
		Cls
		DrawImageRect(img, 0, 0, screenW, screenH)
			
		Flip
		
		If AppTerminate() Then running = False

	Until KeyDown(KEY_ESCAPE) Or MouseHit(1) Or MilliSecs() > time+tdelay Or running = False 
	If running = False Then EndGraphics; End
	
	ResetDrawing(255,255,255)
	
	Return True
End Function

Function DoLoading:Int(percent:Int)
	Global img_car:TImage = LoadMyImage(gAppLoc+"Media/Cars/Car_"+Rand(10)+"a.png")
	
	Cls
	SetColor(255,255,255)
	DrawImageRect(img_Loading, 0, 0, screenW, screenH)
	DrawImage(img_car, (screenW/100)*percent, screenH-36)
	
	Flip
End Function

Function DrawRelationsBoss()
	ResetDrawing()
	If imgRelationsBoss Then DrawImageRect(imgRelationsBoss, 0, 0, 50, 50)
End Function

Function DrawRelationsPitCrew()
	ResetDrawing()
	If imgRelationsPitCrew Then DrawImageRect(imgRelationsPitCrew, 0, 0, 50, 50)
End Function

Function DrawRelationsFans()
	ResetDrawing()
	If imgRelationsFans Then DrawImageRect(imgRelationsFans, 0, 0, 50, 50)
End Function

Function DrawRelationsFriends()
	ResetDrawing()
	If imgRelationsFriends Then DrawImageRect(imgRelationsFriends, 0, 0, 50, 50)
End Function

Function DrawRelationsBossStars()
	ResetDrawing()
	If imgStarLarge 
		SetColor(64,64,64)
		For Local r:Int = 1 To 10
			DrawImage(imgStarLarge, (r-1)*28,0)
		Next
		
		SetColor(255,255,255)
		For Local r:Int = 1 To gRelBoss/10
			DrawImage(imgStarLarge, (r-1)*28,0)
		Next
	EndIf
End Function

Function DrawRelationsPitCrewStars()
	ResetDrawing()
	If imgStarLarge 
		SetColor(64,64,64)
		For Local r:Int = 1 To 10
			DrawImage(imgStarLarge, (r-1)*28,0)
		Next
		
		SetColor(255,255,255)
		
		For Local r:Int = 1 To gRelPitCrew/10
			DrawImage(imgStarLarge, (r-1)*28,0)
		Next
	EndIf
End Function

Function DrawRelationsFansStars()
	ResetDrawing()
	If imgStarLarge 
		SetColor(64,64,64)
		For Local r:Int = 1 To 10
			DrawImage(imgStarLarge, (r-1)*28,0)
		Next
		
		SetColor(255,255,255)
		For Local r:Int = 1 To gRelFans/10
			DrawImage(imgStarLarge, (r-1)*28,0)
		Next
	EndIf
End Function

Function DrawRelationsFriendsStars()
	ResetDrawing()
	If imgStarLarge 
		SetColor(64,64,64)
		For Local r:Int = 1 To 10
			DrawImage(imgStarLarge, (r-1)*28,0)
		Next
		
		SetColor(255,255,255)
		For Local r:Int = 1 To gRelFriends/10
			DrawImage(imgStarLarge, (r-1)*28,0)
		Next
	EndIf
End Function

Function GetDateString:String(julian:Int)
	Local dob:FryDate = New FryDate
	dob.SetJulian(julian)
	Local d:Int, m:Int, y:Int
	dob.GetDate(d, m, y)
	
	Local month:String 
	
	Select m
	Case 1 month = GetLocaleText("January")
	Case 2 month = GetLocaleText("February")
	Case 3 month = GetLocaleText("March")
	Case 4 month = GetLocaleText("April")
	Case 5 month = GetLocaleText("May")
	Case 6 month = GetLocaleText("June")
	Case 7 month = GetLocaleText("July")
	Case 8 month = GetLocaleText("August")
	Case 9 month = GetLocaleText("September")
	Case 10 month = GetLocaleText("October")
	Case 11 month = GetLocaleText("November")
	Case 12 month = GetLocaleText("December")
	End Select
	
	Return String(d)+" "+month+" "+String(y)
End Function

Function HexColour(col:String, r:Int Var, g:Int Var, b:Int Var)

	'convert the hex into r, g, b values
	If col.length <> 6 Then Return
		
	r = Int("$"+col[0..2])
	g = Int("$"+col[2..4])
	b = Int("$"+col[4..6])
	
End Function

Function SetHexColour(col:String)

	Local r:Int, g:Int, b:Int
	HexColour(col, r, g, b)
	
	SetColor r, g, b
	
End Function

Type TFontText
	'Field fnt:TImageFont
	Field fnt:TBitmapFont
	
	Function Create:TFontText(furl:String, sz:Int)
		Local newtfont:TFontText = New TFontText
		newtfont.fnt = New TBitmapFont
		newtfont.fnt.Load(furl)
		Return newtfont
		
		'Local newtfont:TFontText = New TFontText
		'newtfont.fnt = LoadImageFont(furl, sz)
		'Return newtfont
	End Function
	
	Method Draw(txt:String, x:Float, y:Float, offsetx:Int = 0, offsety:Int = 1, scl:Float = 1.0)
		Select offsetx
		Case 0
		Case 1	x:-fnt.GetTxtWidth(txt)*scl*0.5
		Case 2	x:-fnt.GetTxtWidth(txt)*scl
		End Select
		
		Select offsety
		Case 0
		Case 1	y:-fnt.GetFontHeight()*scl*0.5
		Case 2	y:-fnt.GetFontHeight()*scl
		End Select
		
		fnt.DrawText(txt,x,y)
	End Method
	
	Rem
	Method DrawOld(txt:String, x:Float, y:Float, offsetx:Int = 0, offsety:Int = 1, scl:Float = 1.0)
		SetImageFont(fnt)
		
		Select offsetx
		Case 0
		Case 1	x:-TextWidth(txt)*scl*0.5
		Case 2	x:-TextWidth(txt)*scl
		End Select
		
		Select offsety
		Case 0
		Case 1	y:-TextHeight(txt)*scl*0.5
		Case 2	y:-TextHeight(txt)*scl
		End Select
		
		DrawText(txt,x,y)
	End Method
	endrem
End Type