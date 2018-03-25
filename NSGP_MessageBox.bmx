 ' ----------------------------------
' Message Box
' ----------------------------------
Global pan_MessageBoxBack:fry_TPanel = fry_TPanel(fry_GetGadget("pan_messageboxback"))
Global pan_MessageBoxFore:fry_TPanel = fry_TPanel(fry_GetGadget("pan_messageboxfore"))
Global lbl_MessageBox_Description:fry_TLabel = fry_TLabel(fry_GetGadget("pan_messageboxfore/lbl_Description"))
Global btn_MessageBox_Yes:fry_TButton = fry_TButton(fry_GetGadget("pan_messageboxfore/btn_yes"))
Global btn_MessageBox_No:fry_TButton = fry_TButton(fry_GetGadget("pan_messageboxfore/btn_no"))

Global bMessageBoxIsUp:Int = False
Global txt_MessageBox_Txt:fry_TTextField = fry_TTextField(fry_GetGadget("pan_messageboxfore/txt_field"))

Function DoMessage:Int(messagetype:String, yesno:Int = False, item:String="", btntxt1:String="", btntxt2:String="", amount:String="", txtfield:Int = False)
	MyFlushJoy()
	bMessageBoxIsUp = True
	
	' Position and alpha background
	pan_MessageBoxBack.SetAlpha(0.5)
	pan_MessageBoxBack.SetDimensions(screenW+20, screenH+20)
	pan_MessageBoxBack.PositionGadget(-10,-10)
	
	' Position and alpha foreground
	pan_MessageBoxFore.SetAlpha(1)
	Local x:Int = (screenW/2)-(pan_MessageBoxFore.gW/2)
	Local y:Int = (screenH/2)-(pan_MessageBoxFore.gH/2)
	pan_MessageBoxFore.PositionGadget(x,y)
	txt_MessageBox_Txt.Hide()
	If txtfield Then txt_MessageBox_Txt.Show()
	
	' Reset button pos
	btn_MessageBox_Yes.PositionGadget(10,btn_MessageBox_Yes.gY)
	
	' Reset Yes/No
	Select YesNo
	Case True
		Local txt1:String = GetLocaleText("Yes")
		Local txt2:String = GetLocaleText("No")
		
		If btntxt1 <> "" Then txt1 = btntxt1
		If btntxt2 <> "" Then txt2 = btntxt2
		
		btn_MessageBox_Yes.SetText(txt1)
		btn_MessageBox_No.SetText(txt2)
		
		btn_MessageBox_Yes.Show()
		btn_MessageBox_No.Show()
	
	Case False
		btn_MessageBox_Yes.SetText(GetLocaleText("OK"))
		btn_MessageBox_Yes.PositionGadget((pan_MessageBoxFore.gW/2)-(btn_MessageBox_Yes.gW/2), btn_MessageBox_Yes.gY)
		btn_MessageBox_Yes.Show()
		btn_MessageBox_No.Hide()
		
	EndSelect
	
	' Display text
	Local str:String
	str = GetLocaleText(messagetype)
	'ReplaceTextModifiers(str)
	
	' Update text in box
	str = str.Replace("$item", item)
	str = str.Replace("$amount", amount)
	lbl_MessageBox_Description.SetText(str)
	
	' Show pop-up
	fry_OpenPopUp("pan_messageboxback")
	fry_OpenPopUp("pan_messageboxfore")
	
	Local retval:Int = -1
	
	Repeat
		DoDisplay()
		CheckFryButtonControls(pan_MessageBoxFore)
		
		If KeyHit(KEY_ENTER) Then retval = 1
		If KeyHit(KEY_ESCAPE) Then retval = 0
		CheckTextBoxModes()
			
		While fry_PollEvent()
			Select fry_EventID()
			Case fry_EVENT_GADGETOPEN
				If Not chn_FX.Playing() Then PlaySound(snd_Open, chn_FX)
			Case fry_EVENT_GADGETCLOSE
				If Not chn_FX.Playing() Then PlaySound(snd_Open, chn_FX)
			Case fry_EVENT_GADGETSELECT
				' Buttons and combos
				If Not chn_FX.Playing() Then PlaySound(snd_Click, chn_FX)
				
				Select fry_EventSource()
					Case btn_MessageBox_Yes		retval = 1
					Case btn_MessageBox_No		retval = 0
				EndSelect
			End Select
		Wend
	Until retval > -1
	
	txt_MessageBox_Txt.Deactivate()
	fry_ClosePopUp("pan_messageboxfore")
	fry_ClosePopUp("pan_messageboxback")
	While fry_PollEvent();Wend
	MyFlushJoy()
	
	bMessageBoxIsUp = False
	
	Select retval
	Case 0	Return False
	Case 1	Return True
	End Select

	Return False
End Function

Function ButtonCheckForUpdate:Int()
	AppLog "ButtonCheckForUpdate"
	Local curl:TCurlEasy = TCurlEasy.Create()
	
	curl.setOptInt(CURLOPT_CONNECTTIMEOUT, 5)
	curl.setOptInt(CURLOPT_TIMEOUT, 5)
	
	If Len(gProxy) > 3 
		curl.setOptString(CURLOPT_PROXY, gProxy) 
	Else
		curl.setOptInt(CURLOPT_PORT, gPort)
	EndIf
	curl.setWriteString()' use the internal string  to store the content
	curl.setOptString(CURLOPT_URL, gVersionURL)
	If gDebugMode Then AppLog "Curl CURLOPT_URL"
	
	Local res:Int = curl.perform()
	
	If gDebugMode Then AppLog "Curl.Perform()"
	
	If res
		DoMessage("CMESSAGE_INTERNETCONNECTION")
		Return True
	End If
	curl.cleanup()
	
	AppLog "This version: "+gVersion
	AppLog "Current version: "+curl.toString()
	
	If curl.toString() <> "" And curl.toString().ToFloat() > gVersion.ToFloat()
		If DoMessage("CMESSAGE_VERSIONUPDATE")
			OpenWeb(gDownloadURL)
	'		ButtonExitGame()
			Return False
		End If
	End If
	
	DoMessage("CMESSAGE_VERSIONOK")
	Return True
End Function

Function OpenWeb(url:String)
	AppLog "OpenWeb:"+url
	Local curl:TCurlEasy = TCurlEasy.Create()

	curl.setWriteString()' use the internal string  to store the content

	curl.setOptInt(CURLOPT_CONNECTTIMEOUT, 5)
	curl.setOptInt(CURLOPT_TIMEOUT, 5)
	
	If Len(gProxy) > 3 
		curl.setOptString(CURLOPT_PROXY, gProxy) 
	Else
		curl.setOptInt(CURLOPT_PORT, gPort)
	EndIf
	curl.setOptString(CURLOPT_URL, url)
	
	Local res:Int = curl.perform()
	
	If res
		AppLog CurlError(res)
		DoMessage("CMESSAGE_INTERNETCONNECTION")
		Return
	End If

	curl.cleanup()
	
	If curl.toString() <> ""
		If gFullscreen <> 0 
			gFullscreen = 0
			SetUpGraphicsWindow(gFullscreen)
		EndIf
		
		OpenURL(url)
	EndIf
End Function

Function CheckPlimusKeyLibCurl:Int(check:String, name:String, key:String)
	AppLog "RegisterPlimusKey"
	Local curl:TCurlEasy = TCurlEasy.Create()

	curl.setOptInt(CURLOPT_CONNECTTIMEOUT, 5)
	curl.setOptInt(CURLOPT_TIMEOUT, 5)
	
	If Len(gProxy) > 3 
		curl.setOptString(CURLOPT_PROXY, gProxy) 
	Else
		curl.setOptInt(CURLOPT_PORT, gPort)
	EndIf
	curl.setWriteString()' use the internal string  to store the content
	
	Local url:String = gPlimusRegURL
	url = url.Replace("MYCHECK", check)
	url = url.Replace("MYKEY", key)
	url = url.Replace("MYNAME", name)
	curl.setOptString(CURLOPT_URL, url)
	AppLog url
	
	Local res:Int = curl.perform()
	If res Then AppLog CurlError(res)
	AppLog curl.toString()
	curl.cleanup()
	
	If curl.toString().ToUpper().Contains("SUCCESS") Then Return True
	
	Return False
End Function

Function CheckPlimusKey:Int(check:String, name:String, key:String)
	If KeyDown(KEY_LCONTROL) Then Return CheckPlimusKeyLibCurl(check, name, key)
	
	AppLog "CheckPlimusKey2"
	
	Local url:String = gPlimusRegURL
	url = url.Replace("MYCHECK", check)
	url = url.Replace("MYKEY", key)
	url = url.Replace("MYNAME", name)
	url = url.Replace("://", "::")
	AppLog url
	
	Local plimus:TStream = ReadStream(url)
	
	If Not plimus 
		AppLog "Could not open plimus url"
		Return False
	EndIf
	
	Local res:Int = False
	
	While Not Eof(plimus)
		Local l$ = ReadLine(plimus)
		AppLog l
		If l.ToUpper().Contains("SUCCESS") Then res = True
	Wend
	CloseStream plimus

	Return res
End Function
