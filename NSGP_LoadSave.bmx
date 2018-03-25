Function LoadVariable:Float(file:String, varstr:String, minval:Float, maxval:Float)
	If file.Contains("incbin") = False And file.Contains(gAppLoc) = False And file.Contains(gSaveloc) = False And (gModLoc = "" Or file.Contains(gModLoc) = False) Then file = gAppLoc+file
	
	varstr = Lower(varstr)
	AppLog "Load variable: "+varstr
	DebugLog "Load variable: "+file+"/"+varstr
	
	Local retval:Float
	Local pos:Float
	Local ini:TStream=ReadFile(file)
	If Not ini Then AppLog "Could not open file: "+file+": "+varstr; Return minval+((maxval-minval)/2)
	
	Local found:Int = False
	While Not Eof(ini)
		Local l$ = ReadLine(ini).ToLower()
		
		If Left(l, Len(varstr)) = varstr
			retval = Mid(l, Len(varstr)+2).ToFloat()
			found = True
		EndIf
	Wend
	CloseStream ini

	If Not found
		AppLog "Could not find "+varstr+" trying incbin..."
		ini = ReadFile("incbin::Inc/"+file)
		If Not ini Then AppLog "Could not open file from incbin:"+file+": "+varstr; Return minval+((maxval-minval)/2)
		
		While Not Eof(ini)
			Local l$ = ReadLine(ini).ToLower()
			
			If Left(l, Len(varstr)) = varstr
				retval = Mid(l, Len(varstr)+2).ToFloat()
				found = True
			EndIf
		Wend
		CloseStream ini
	End If
	
	If Not found Then AppLog "Could not load variable: "+varstr
	
	If retval < minval Then retval = minval
	If retval > maxval Then retval = maxval

	DebugLog "Load variable: "+file+"/"+varstr+" = "+retval
	
	Return retval
End Function

Function LoadVariableString:String(file:String, varstr:String)
	If file.Contains("incbin") = False And file.Contains(gAppLoc) = False And file.Contains(gSaveLoc) = False And (gModLoc = "" Or file.Contains(gModLoc) = False) Then file = gAppLoc+file
	varstr = Lower(varstr)
	AppLog "Load variable: "+varstr
	
	Local retval:String
	Local pos:Float
	Local ini:TStream=OpenFile(file)
	If Not ini Then AppLog "Could not open file: "+file+": "+varstr
	
	Local found:Int = False
	While Not Eof(ini)
		Local l$ = ReadLine(ini)
		l = Lower(l)
		
		If Left(l, Len(varstr)) = varstr
			retval = Mid(l, Len(varstr) + 2)
			found = True
		EndIf
	Wend
	CloseStream ini

	If Not found Then AppLog "Could not load variable: " + varstr

	Return retval
End Function

Function LoadMyImage:TImage(url$)
	If url.Contains("incbin") = False
		If url.Contains(gSaveloc) = False And url.Contains(gAppLoc) = False And (gModLoc = "" Or url.Contains(gModLoc) = False) Then url = gAppLoc+url
		
		If FileType(url)=1
			AppLog "Loading image: "+url
		Else
			AppLog "WARNING! >>>>>>>>>>>> Cannot see image: "+url
			Return Null
		End If
	EndIf
	
	Local img:TImage = LoadImage(url)
	
	If img
		AppLog "Image loaded"
	Else
		AppLog "ERROR! >>>>>>>>>>>>>> Image could not be loaded: "+url; DebugStop
	EndIf
	
	Return img
End Function

Function LoadMyPixmapPNG:TPixmap(url$)
	If url.Contains("incbin") = False
		If url.Contains(gSaveloc) = False And url.Contains(gAppLoc) = False And (gModLoc = "" Or url.Contains(gModLoc) = False) Then url = gAppLoc+url
		If FileType(url)=1
			AppLog "Loading pixmap: "+url
		Else
			AppLog "WARNING! >>>>>>>>>>>> Cannot see pixmap: "+url
			Return Null
		End If
	EndIf
	
	Local pix:TPixmap = LoadPixmapPNG(url)
	If pix
		AppLog "Pixmap loaded"
	Else
		AppLog "ERROR! >>>>>>>>>>>>>> Pixmap could not be loaded: "+url; DebugStop
	EndIf
	
	Return pix
End Function

Function LoadMySound:TSound(url$, flags:Int=0)
	If url.Contains("incbin") = False
		If url.Contains(gSaveloc) = False And url.Contains(gAppLoc) = False And (gModLoc = "" Or url.Contains(gModLoc) = False) Then url = gAppLoc+url
		
		If FileType(url)=1
			AppLog "Loading sound: "+url
		Else
			AppLog "WARNING! >>>>>>>>>>>> Cannot see sound: "+url; DebugStop
			Return Null
		End If
	EndIf
	
	Local snd:TSound = LoadSound(url, flags)
	If snd
		AppLog "Sound loaded"
	Else
		AppLog "ERROR! >>>>>>>>>>>>>> Sound could not be loaded: "+url; DebugStop
	EndIf
	
	Return snd
End Function

Function LoadMyAnimImage:TImage(url$, w:Int, h:Int, first:Int, count:Int)
	If url.Contains("incbin") = False
		If url.Contains(gSaveloc) = False And url.Contains(gAppLoc) = False And (gModLoc = "" Or url.Contains(gModLoc) = False) Then url = gAppLoc+url
		If FileType(url)=1
			AppLog "Loading anim image: "+url
		Else
			AppLog "WARNING! >>>>>>>>>>>> Cannot see anim image: "+url; DebugStop
			Return Null
		End If
	EndIf
	
	Local img:TImage = LoadAnimImage(url, w, h, first, count)
	If img
		AppLog "Anim Image loaded"
	Else
		AppLog "ERROR! >>>>>>>>>>>>>> Anim Image could not be loaded: "+url; DebugStop
	EndIf
	
	Return img
End Function

Function LoadMyImageFont:TImageFont(url:String, size:Int, style:Int = SMOOTHFONT)
	If url.Contains("incbin") = False
		If url.Contains(gSaveloc) = False And url.Contains(gAppLoc) = False And (gModLoc = "" Or url.Contains(gModLoc) = False) Then url = gAppLoc+url
		If FileType(url)=1
			AppLog "Loading font: "+url
		Else
			AppLog "WARNING! >>>>>>>>>>>> Cannot see font: "+url
			Return Null
		End If
	EndIf
	
	Local font:TImageFont = LoadImageFont(url, size, style)
	If font
		AppLog "Font loaded"
	Else
		AppLog "ERROR! >>>>>>>>>>>>>> Font could not be loaded: "+url; DebugStop
	EndIf
	
	Return font
End Function
