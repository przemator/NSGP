Global pan_HelpFore:fry_TPanel = fry_TPanel(fry_GetGadget("pan_helpfore"))

Global lbl_Help_PageNo:fry_TLabel = fry_TLabel(fry_GetGadget("pan_helpfore/lbl_page"))
Global btn_Help_Prev:fry_TButton = fry_TButton(fry_GetGadget("pan_helpfore/btn_prev"))
Global btn_Help_Ok:fry_TButton = fry_TButton(fry_GetGadget("pan_helpfore/btn_ok"))
Global btn_Help_Next:fry_TButton = fry_TButton(fry_GetGadget("pan_helpfore/btn_next"))
Global btn_Help_OnlineHelp:fry_TButton = fry_TButton(fry_GetGadget("pan_helpfore/btn_onlinehelp"))

Global can_Help:fry_TCanvas = fry_CreateCanvas("can_Help", 10, 10, pan_HelpFore.gW-20, pan_HelpFore.gH-60, pan_HelpFore)
can_Help.SetBackground(0)
can_Help.SetDraw(THelpPage.DrawHelp)

Function DoHelp()
	MyFlushJoy()
	bMessageBoxIsUp = True
	
	' Position and alpha background
	pan_MessageBoxBack.SetAlpha(0.75)
	pan_MessageBoxBack.SetDimensions(screenW+20, screenH+20)
	pan_MessageBoxBack.PositionGadget(-10,-10)
	
	' Position and alpha foreground
	pan_HelpFore.SetAlpha(0.75)
	Local x:Int = (screenW/2)-(pan_HelpFore.gW/2)
	Local y:Int = (screenH/2)-(pan_HelpFore.gH/2)
	pan_HelpFore.PositionGadget(x,y)
	
	If not THelpPage.LoadHelp()
		DoMessage("CMESSAGE_NOHELP")
	End If
	
	' Show pop-up
	fry_OpenPopUp("pan_messageboxback")
	fry_OpenPopUp("pan_Helpfore")
	
	Repeat
		DoDisplay()
		PollSystem
		While fry_PollEvent()
			Select fry_EventID()
			Case fry_EVENT_GADGETOPEN
			Case fry_EVENT_GADGETCLOSE
			Case fry_EVENT_GADGETSELECT
				
				Select fry_EventSource()
				Case btn_Help_Ok			bMessageBoxIsUp = False; AppLog "Done"
				Case btn_Help_Prev			THelpPage.PagePrevious()
				Case btn_Help_Next			THelpPage.PageNext()
				Case btn_Help_OnlineHelp	OpenWeb(gOnlineHelpURL)
				EndSelect
			End Select
		Wend
	Until KeyHit(KEY_ESCAPE) or bMessageBoxIsUp = False
	
	fry_ClosePopUp("pan_helpfore")
	fry_ClosePopUp("pan_messageboxback")
	While fry_PollEvent();Wend
	
	
	Applog "Returning"
End Function  

Type THelpPage
	Global l_page:TList = CreateList()
	Global pagelength:Int 
	Global totalpages:Int
	Global currentpage:Int = 0
	
	
	Function LoadHelp:Int()
		l_page.Clear()
		
		Local hlp:TStream=OpenFile("UTF8::"+gAppLoc+"Languages/"+gLanguageStr+"/Help/"+fry_ScreenName()+".txt")
		If Not hlp Then AppLog "Could not open file: "+fry_ScreenName()+".txt"; Return False
		
		SetImageFont(fry_GetFont("Medium"))
		pagelength = (pan_HelpFore.gH-80)/(TextHeight("I")+2)
		
		While not Eof(hlp)
			AddToPage(ReadLine(hlp))
		Wend
		CloseStream hlp
		
		totalpages = l_Page.Count()/pagelength
		currentpage = 0
		UpdateHelpButtons()
		
		Return True
	End Function
	
	Function AddToPage(txt:String)
		SetImageFont(fry_GetFont("Medium"))
		
		Local width:Int = 740
		Local words:String[] = SplitString(txt, " ")
		Local gText:String[] = New String[0]
		Local textcount:Int = 0
		
		Local word:Int = 0
		Local fits:Int = True
		Local line:String
				
		'loop to create all the lines
		While word < words.length
		
			Local fit:Int = False
					
			'check if the next word would also fit
			Local length:Int = 0
			If line <> "" Then length = TextWidth(line + " " + words[word])
			
			If length <= width Then
				'fits, so add the word to the line
				If line = "" Then line = words[word] Else line:+ " "+words[word]
				fit = True
				word:+ 1
			End If
			
			If not fit or word = words.length
				'doesn't fit, so add this line to the text array and move on
				gText = gText[0..textcount+1]
				gText[textcount] = line
				line = ""
				textcount:+ 1
			End If
		Wend
		
		Local count:Int = l_page.Count()
		
		For Local lupe:Int = 0 To gText.Length-1
			' Make sure last line of page isn't a heading
			Local md:Int = count mod pagelength
			
			If count > 0
				If gText[lupe].Find("c/") > -1 or gText[lupe].Find("u/") > -1
				'	If md = pagelength-2
				'		Applog gText[lupe]
				'		l_page.AddLast("--")
				'		l_page.AddLast("--")
				'		count:+2
				'	EndIf
					
					If md = pagelength-1
						l_page.AddLast(" ")
						count:+1
					End If
				End If
				
				If gText[lupe].Find("pagebreak/") > -1
					While (l_page.Count() mod pagelength) < pagelength-1
						l_page.AddLast("blank/")
					Wend
				EndIf
			EndIf
			
			l_page.AddLast(gText[lupe])
			count:+1
		Next
		
		Return
	End Function
	
	Function DrawHelp()		
		ResetDrawing()
		SetImageFont(fry_GetFont("Medium"))
		
		If l_page
			Local str:String = GetLocaleText("Page")+" "+String(currentpage+1)+"/"+String(totalpages+1)
			lbl_Help_PageNo.SetText(str)
			
			Local textX:Int = 10
			Local textY:Int = 10
			Local thispage:Int = 0
			Local countlines:Int = -1
			
			For Local txt:String = EachIn l_page
				countlines:+1
				If countlines = pagelength
					thispage:+1
					countlines = 0
					textY = 10
				End If
				
				If thispage = currentpage
					'Local col:Int = CCOL_WHITE
					Local centre:Int = False
					Local underline:Int = False

					If txt.Find("c/") > -1 Then centre = True; txt = txt.Replace("c/", "")
					If txt.Find("u/") > -1 Then underline = True; txt = txt.Replace("u/", "")
					
					Local img:TImage = Null
					Local imscale:Float = 1
					
					If txt.Find("btn_Casino_Home/") > -1 Then img = btn_Casino_Home.gButtonImage; txt = txt.Replace("btn_Casino_Home/", "")
					If txt.Find("btn_Casino_BlackJack/") > -1 Then img = btn_Casino_BlackJack.gButtonImage; txt = txt.Replace("btn_Casino_BlackJack/", "")
					If txt.Find("btn_Casino_Roulette/") > -1 Then img = btn_Casino_Roulette.gButtonImage; txt = txt.Replace("btn_Casino_Roulette/", "")
					If txt.Find("btn_Casino_Slots/") > -1 Then img = btn_Casino_Slots.gButtonImage; txt = txt.Replace("btn_Casino_Slots/", "")
					If txt.Find("btn_ExitGame/") > -1 Then img = btn_ExitGame.gButtonImage; txt = txt.Replace("btn_ExitGame/", "")
					If txt.Find("btn_NewPlayer_Cancel/") > -1 Then img = btn_NewPlayer_Cancel.gButtonImage; txt = txt.Replace("btn_NewPlayer_Cancel/", "")
					If txt.Find("btn_NewPlayer_Proceed/") > -1 Then img = btn_NewPlayer_Proceed.gButtonImage; txt = txt.Replace("btn_NewPlayer_Proceed/", "")
					If txt.Find("btn_Header_Quit/") > -1 Then img = btn_Header_Quit.gButtonImage; txt = txt.Replace("btn_Header_Quit/", "")
					If txt.Find("btn_Header_Help/") > -1 Then img = btn_Header_Help.gButtonImage; txt = txt.Replace("btn_Header_Help/", "")
					If txt.Find("btn_Header_Options/") > -1 Then img = btn_Header_Options.gButtonImage; txt = txt.Replace("btn_Header_Options/", "")
					If txt.Find("btn_NavBar_Home/") > -1 Then img = btn_NavBar_Home.gButtonImage; txt = txt.Replace("btn_NavBar_Home/", "")
					If txt.Find("btn_NavBar_Leaderboards/") > -1 Then img = btn_NavBar_Leaderboards.gButtonImage; txt = txt.Replace("btn_NavBar_Leaderboards/", "")
					If txt.Find("btn_NavBar_Team/") > -1 Then img = btn_NavBar_Team.gButtonImage; txt = txt.Replace("btn_NavBar_Team/", "")
					If txt.Find("btn_NavBar_Finances/") > -1 Then img = btn_NavBar_Finances.gButtonImage; txt = txt.Replace("btn_NavBar_Finances/", "")
					If txt.Find("btn_NavBar_Casino/") > -1 Then img = btn_NavBar_Casino.gButtonImage; txt = txt.Replace("btn_NavBar_Casino/", "")
					If txt.Find("btn_Relations_PitCrewCasino/") > -1 Then img = btn_Relations_PitCrewCasino.gButtonImage; txt = txt.Replace("btn_Relations_PitCrewCasino/", "")
					If txt.Find("btn_Relations_FriendsCasino/") > -1 Then img = btn_Relations_FriendsCasino.gButtonImage; txt = txt.Replace("btn_Relations_FriendsCasino/", "")
					If txt.Find("btn_NavBar_Practice/") > -1 Then img = btn_NavBar_Practice.gButtonImage; txt = txt.Replace("btn_NavBar_Practice/", "")
					If txt.Find("btn_TeamProfile_Back/") > -1 Then img = btn_TeamProfile_Back.gButtonImage; txt = txt.Replace("btn_TeamProfile_Back/", "")
					If txt.Find("btn_TeamProfile_Fwd/") > -1 Then img = btn_TeamProfile_Fwd.gButtonImage; txt = txt.Replace("btn_TeamProfile_Fwd/", "")
					If txt.Find("btn_Track_Back/") > -1 Then img = btn_Track_Back.gButtonImage; txt = txt.Replace("btn_Track_Back/", "")
					If txt.Find("btn_Track_Fwd/") > -1 Then img = btn_Track_Fwd.gButtonImage; txt = txt.Replace("btn_Track_Fwd/", "")
					If txt.Find("btn_History_Back/") > -1 Then img = btn_History_Back.gButtonImage; txt = txt.Replace("btn_Search/", "")
					If txt.Find("btn_History_Fwd/") > -1 Then img = btn_History_Fwd.gButtonImage; txt = txt.Replace("btn_History_Fwd/", "")
					If txt.Find("btn_Options_Cancel/") > -1 Then img = btn_Options_Cancel.gButtonImage; txt = txt.Replace("btn_Options_Cancel/", "")
					If txt.Find("btn_Options_Proceed/") > -1 Then img = btn_Options_Proceed.gButtonImage; txt = txt.Replace("btn_Options_Proceed/", "")
					If txt.Find("btn_News_Proceed/") > -1 Then img = btn_News_Proceed.gButtonImage; txt = txt.Replace("btn_News_Proceed/", "")
					If txt.Find("imgRelationsBoss/") > -1 Then img = imgRelationsBoss; txt = txt.Replace("imgRelationsBoss/", ""); imscale = 0.65
					If txt.Find("imgRelationsPitCrew/") > -1 Then img = imgRelationsPitCrew; txt = txt.Replace("imgRelationsPitCrew/", ""); imscale = 0.75
					If txt.Find("imgRelationsFans/") > -1 Then img = imgRelationsFans; txt = txt.Replace("imgRelationsFans/", ""); imscale = 0.75
					If txt.Find("imgRelationsFriends/") > -1 Then img = imgRelationsFriends; txt = txt.Replace("imgRelationsFriends/", ""); imscale = 0.75
					If txt.Find("btn_TeamProfile_EditTeam/") > -1 Then img = btn_TeamProfile_EditTeam.gButtonImage; txt = txt.Replace("btn_TeamProfile_EditTeam/", "")

					If txt.Find("btn_NavBar_Play/") > -1 Then img = LoadImage(gAppLoc+"Skin/Graphics/Buttons/Play.png"); txt = txt.Replace("btn_NavBar_Play/", "")
					If txt.Find("btn_NavBar_PlayQualify/") > -1 Then img = LoadImage(gAppLoc+"Skin/Graphics/Buttons/Play_Qualify.png"); txt = txt.Replace("btn_NavBar_PlayQualify/", "")
					If txt.Find("btn_NavBar_PlayRace/") > -1 Then img = LoadImage(gAppLoc+"Skin/Graphics/Buttons/Play_Race.png"); txt = txt.Replace("btn_NavBar_PlayRace/", "")
					rem
					If txt.Find("skyblue/") > -1 Then col = CCOL_SKYBLUE; txt = txt.Replace("skyblue/", "")
					If txt.Find("lblue/") > -1 Then col = CCOL_LBLUE; txt = txt.Replace("lblue/", "")
					If txt.Find("blue/") > -1 Then col = CCOL_BLUE; txt = txt.Replace("blue/", "")
					If txt.Find("red/") > -1 Then col = CCOL_RED; txt = txt.Replace("red/", "")
					If txt.Find("green/") > -1 Then col = CCOL_GREEN; txt = txt.Replace("green/", "")
					If txt.Find("yellow/") > -1 Then col = CCOL_YELLOW; txt = txt.Replace("yellow/", "")
					If txt.Find("grey/") > -1 Then col = CCOL_GREY; txt = txt.Replace("grey/", "")
					If txt.Find("purple/") > -1 Then col = CCOL_PURPLE; txt = txt.Replace("purple/", "")
					If txt.Find("orange/") > -1 Then col = CCOL_ORANGE; txt = txt.Replace("orange/", "")
					End rem
					
					textX = 10
					If centre Then textX = 380 - (TextWidth(txt)/2)
					
					If img <> Null
						SetScale(imscale, imscale)
						If centre Then textX:-ImageWidth(img)/2
						DrawImage(img, textX, textY)
						textX:+ImageWidth(img)+10
						textY:+(ImageHeight(img)/2 - TextHeight(txt)/2)-2
					EndIf
					
					SetScale(1,1)
					
					Local txtW:Int = TextWidth(txt)
					Local txtH:Int = TextHeight(txt)
					
					If txt.Contains("blank/") = False and txt.Contains("pagebreak/") = False
						SetColor(0,0,0)
						If underline Then DrawLine(textX, textY+txtH, textX+txtW, textY+txtH)
						DrawText(txt, textX, textY)
						SetColor(255,255,255)
						If underline Then DrawLine(textX+1, textY+1+txtH, textX+txtW, textY+1+txtH)
						DrawText(txt, textX+1, textY+1)
						textY:+txtH+2
					EndIf
					
					If img <> Null
						textY:+4
						img = Null
					End If
				End If
			Next
		EndIf
	End Function
	
	Function PagePrevious()
		If currentpage > 0 Then currentpage:-1
		UpdateHelpButtons()
	End Function
	
	Function PageNext()
		If l_Page.Count() < pagelength Then Applog "No more pages"; Return
		If currentpage < totalpages Then currentpage:+1
		UpdateHelpButtons()
	End Function
	
	Function UpdateHelpButtons()
		btn_Help_Prev.SetAlpha(1)
		btn_Help_Next.SetAlpha(1)
		If currentpage = 0 Then btn_Help_Prev.SetAlpha(0.5)
		If currentpage = totalpages Then btn_Help_Next.SetAlpha(0.5)
	End Function
End Type

Function SplitString:String[](str:String,separator:String)

	Local Text_Array:String[1]
	Local R_Text:String = str
	Local i:Int = 0

	Repeat
		If R_Text.Length = 0 Then Exit
			Local sp_p:Int = R_Text.Find(separator)
			If sp_p = -1 Then
				Text_Array[I] = R_Text
				Exit
			End If
			Text_Array[I] = Left(R_Text,sp_p)
			R_Text = Right(R_Text,(R_text.Length - sp_p)-1)
			I:+1
			Text_Array = Text_array[..I+1]
	Forever

	Return Text_array	

End Function