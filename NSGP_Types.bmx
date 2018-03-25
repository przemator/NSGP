Const COBJECT:Int = 1, CWAYLINE:Int = 2, CWAYPOINT:Int = 3, CPITWAYPOINT:Int = 4, CWALLPOINT:Int = 5
Const CTERRAIN_BLANK:Int=0, CTERRAIN_TARMAC:Int=1, CTERRAIN_RUMBLE:Int=2, CTERRAIN_GRASS:Int=3, CTERRAIN_GRAVEL:Int=4, CTERRAIN_PITLANE:Int=5
Const CCONTROLLER_CPU:Int = 0, CCONTROLLER_HUMAN:Int = 1, CCONTROLLER_REMOTE:Int = 2
Const CTRACKMODE_NONE:Int = 0, CTRACKMODE_EDIT:Int = 1, CTRACKMODE_DRIVE:Int = 2, CTRACKMODE_REPLAYING:Int = 3, CTRACKMODE_PAUSED:Int = 4, CTRACKMODE_PITSTOP:Int = 5, CTRACKMODE_EDITPAUSED:Int = 6
Const CRACESTATUS_GRID:Int = 0, CRACESTATUS_RACE:Int = 1, CRACESTATUS_PRACTICE:Int = 2, CRACESTATUS_QUALIFY:Int = 3
Const CROADCLEAR_NONE:Int = 0, CROADCLEAR_LEFT:Int = 1, CROADCLEAR_RIGHT:Int = 2, CROADCLEAR_ALL:Int = 3
Const CTYRE_SOFT:Int=0, CTYRE_HARD:Int=1, CTYRE_WET:Int=2

Type TNation
	Global list:TList
	Global sortby:Int
	
	Field id:Int
	Field name:String
	Field tla:String
	Field nationality:String
	Field climate:Int
	
	Function SelectAll()
		AppLog "TNation.SelectAll"
		
		If TNation.list Then TNation.list.Clear()

		Local prep_Q:Int  = db.PrepareQuery("SELECT * FROM nation")
	
		While db.StepQuery(prep_Q) = SQLITE_ROW
			TNation.Create(db.P(prep_Q, "id").ToInt(),..
				db.P(prep_Q, "name"),..
				db.P(prep_Q, "tla"),..
			 	db.P(prep_Q, "nationality"))
		Wend
		
		db.FinalizeQuery(prep_Q)
		
		AppLog TNation.list.Count()+" Nations Selected"
		
	End Function
	
	Function Create(id:Int, name:String, tla:String, nationality:String)
		Local NewNation:TNation = New TNation
	
		NewNation.id = id
		NewNation.name = name
		NewNation.tla = tla
		NewNation.nationality = nationality
		
		If Not list Then list = CreateList()
		list.AddLast(NewNation)
	End Function
	
	Function SelectById:TNation(id:Int)
		For Local nat:TNation = EachIn list
			If nat.id = id Then Return nat
		Next
	End Function
	
	Function SelectByNationality:TNation(nationality:String)
		For Local nat:TNation = EachIn list
			If nat.nationality = nationality Then Return nat
		Next
	End Function
	
	Method Compare:Int(O:Object)
		If O = Self Then Return 0
		
		Select sortby 
		Case CSORT_NAME
			If TNation(O).name < name Return 1 Else Return -1
		Case CSORT_NATIONALITY
			If TNation(O).nationality < nationality Return 1 Else Return -1
		End Select
	EndMethod
End Type

Type TTeam
	Global list:TList
	Global sortby:Int
	
	Field id:Int
	Field img:TImage
	Field name:String
	Field nationality:Int
	Field principal:String
	
	Field driver1:Int
	Field driver2:Int
	
	Field championships:Int
	Field careerwins:Int
	Field careerpoles:Int
	Field careerlaps:Int
	
	Field seasonpts:Int
	Field seasonwins:Int
	Field seasonpoles:Int
	Field seasonpodiums:Int
	
	Field handling:Float
	Field acceleration:Float
	Field topspeed:Float
	Field statorder:Int 		' Order teams by car stats to determine boss expectations
	
	Function SelectAll()
		AppLog "TTeam.SelectAll"
		
		If TTeam.list Then TTeam.list.Clear()

		Local prep_Q:Int  = db.PrepareQuery("SELECT * FROM team")
	
		While db.StepQuery(prep_Q) = SQLITE_ROW
		
			TTeam.Create(db.P(prep_Q, "id").ToInt(),..
				db.P(prep_Q, "name"),..
				db.P(prep_Q, "nationality").ToInt(),..
				db.P(prep_Q, "principal"),..
				db.P(prep_Q, "driver1").ToInt(),..
				db.P(prep_Q, "driver2").ToInt(),..
				db.P(prep_Q, "championships").ToInt(),..
				db.P(prep_Q, "careerwins").ToInt(),..
				db.P(prep_Q, "careerpoles").ToInt(),..
				db.P(prep_Q, "careerlaps").ToInt(),..
				db.P(prep_Q, "seasonpts").ToInt(),..
				db.P(prep_Q, "seasonwins").ToInt(),..
				db.P(prep_Q, "seasonpoles").ToInt(),..
				db.P(prep_Q, "seasonpodiums").ToInt(),..
				db.P(prep_Q, "handling").ToFloat(),..
				db.P(prep_Q, "acceleration").ToFloat(),..
				db.P(prep_Q, "topspeed").ToFloat())
		Wend
		
		db.FinalizeQuery(prep_Q)
		AppLog TTeam.list.Count()+" Teams Selected"
	End Function
	
	Function Create(id:Int, name:String, nationality:Int, principal:String, driver1:Int, driver2:Int, championships:Int, careerwins:Int,.. 
		careerpoles:Int, careerlaps:Int, seasonpts:Int, seasonwins:Int, seasonpoles:Int, seasonpodiums:Int, handling:Float, acceleration:Float,..
		topspeed:Float)
		
		Local NewTeam:TTeam = New TTeam
	
		NewTeam.id = id
		Local folder:String = gAppLoc
		If gModLoc <> "" Then folder = gModLoc
		NewTeam.img = LoadMyImage(folder+"Media/Teams/Team_"+id+".png")
		NewTeam.name = name
		NewTeam.nationality = nationality 
		NewTeam.principal = principal
		NewTeam.driver1 = driver1 
		NewTeam.driver2 = driver2
		NewTeam.championships = championships
		NewTeam.careerwins = careerwins
		NewTeam.careerpoles = careerpoles
		NewTeam.careerlaps = careerlaps
		NewTeam.seasonpts = seasonpts
		NewTeam.seasonwins = seasonwins
		NewTeam.seasonpoles = seasonpoles
		NewTeam.seasonpodiums = seasonpodiums
		NewTeam.handling = handling
		NewTeam.acceleration = acceleration
		NewTeam.topspeed = topspeed
		
		ValidateMinMaxFloat(NewTeam.handling, -10, 5)
		ValidateMinMaxFloat(NewTeam.acceleration, -10, 5)
		ValidateMinMaxFloat(NewTeam.topspeed, -10, 5)
		
		If Not list Then list = CreateList()
		list.AddLast(NewTeam)
		AppLog "Team:"+NewTeam.name
		
	End Function
	
	Function GetById:TTeam(id:Int)
		If Not list Then SelectAll()
		
		For Local team:TTeam = EachIn list
			If team.id = id Then Return team
		Next
		
		Return Null
	End Function
	
	Function GetByName:TTeam(name:String)
		If Not list Then SelectAll()
		
		For Local team:TTeam = EachIn list
			If team.name = name Then Return team
		Next
	End Function
	
	Function GetTeamByDriverId:TTeam(id:Int)
		If Not list Then SelectAll()
		
		For Local team:TTeam = EachIn list
			If team.driver1 = id Then Return team
			If team.driver2 = id Then Return team
		Next
		
		Return Null
	End Function
	
	Method GetDriverNumber:Int(id:Int)
		If driver1 = id Then Return 1
		If driver2 = id Then Return 2
		
		Return 0
	End Method
	
	Function UpdateDbAll()
		db.Query("BEGIN;")
		For Local t:TTeam = EachIn list
			t.UpdateDb()
		Next
		db.Query("COMMIT;")
	End Function
	
	Method UpdateDb()
		AppLog "Update: "+name
		
		Local q:String = "UPDATE team SET driver1 = "+driver1
		q:+", driver2 = "+driver2
		q:+", championships = "+championships
		q:+", careerwins = "+careerwins
		q:+", careerpoles = "+careerpoles
		q:+", careerlaps = "+careerlaps
		q:+", seasonpts = "+seasonpts
		q:+", seasonwins = "+seasonwins
		q:+", seasonpoles = "+seasonpoles
		q:+", seasonpodiums = "+seasonpodiums
		
		q:+" WHERE id = "+id
		
		db.Query(q)
		
	End Method
	
	Function ResetSeasonPointsAll()
		SelectAll()
		
		db.Query("BEGIN;")
		For Local team:TTeam = EachIn list
			team.ResetSeasonPoints()
			team.UpdateDb()
		Next
		db.Query("COMMIT;")
		
	End Function
	
	Method ResetSeasonPoints()
		seasonpts = 0
		seasonwins = 0
		seasonpoles = 0
		seasonpodiums = 0
	End Method
	
	Function UpdateStatOrderAll()
		sortby = CSORT_CARSTATS
		list.Sort()
		
		Local order:Int = 1
		
		For Local team:TTeam = EachIn list
			team.statorder = order
			order:+1
		Next
	End Function
	
	Method Compare:Int(O:Object)
		If O = Self Then Return 0
		
		Select sortby
		Case CSORT_ID
			If TTeam(O).id < id Return 1 
			If TTeam(O).id > id Return -1
		Case CSORT_NAME
			If TTeam(O).name < name Return 1 Else Return -1
		Case CSORT_NATIONALITY
			If TTeam(O).nationality < nationality Return 1 Else Return -1
		Case CSORT_SEASONPOINTS
			If TTeam(O).seasonpts > seasonpts Return 1 Else Return -1
		Case CSORT_CARSTATS	
			Local stats1:Float = TTeam(O).handling + TTeam(O).acceleration + TTeam(O).topspeed
			Local stats2:Float = handling + acceleration + topspeed
			
			If stats1 > stats2 Then Return 1 Else Return -1
		End Select
		
		Return Super.Compare(O)
	EndMethod
End Type

Type TDriver
	Global list:TList
	Global sortby:Int
	
	Field randno:Int
	Field id:Int
	Field name:String
	Field shortname:String
	Field team:Int
	Field drivernumber:Int
	Field nationality:Int
	Field dob:Int
	Field pob:String
	Field skill:Float
	
	Field careerraces:Int
	Field careerpts:Int
	Field championships:Int
	Field careerwins:Int
	Field careerpoles:Int
	Field careerpodiums:Int
	Field careerlaps:Int
	
	Field seasonraces:Int
	Field seasonpts:Int
	Field seasonwins:Int
	Field seasonpoles:Int
	Field seasonpodiums:Int
	
	Field qualifyingtime:Int
	Field lastracetime:Int
	Field iwaslapped:Int
	Field kersfitted:Int
	
	Field l_laptimes:TList = CreateList()
	
	Function SelectAll()
		If TDriver.list Then TDriver.list.Clear()

		Local prep_Q:Int  = db.PrepareQuery("SELECT * FROM driver")
	
		While db.StepQuery(prep_Q) = SQLITE_ROW
		
			TDriver.Create(db.P(prep_Q, "id").ToInt(),..
				db.P(prep_Q, "name"),..
				db.P(prep_Q, "nationality").ToInt(),..
				db.P(prep_Q, "dob").ToInt(),..
				db.P(prep_Q, "pob"),..
				db.P(prep_Q, "careerraces").ToInt(),..
				db.P(prep_Q, "careerpts").ToInt(),..
				db.P(prep_Q, "championships").ToInt(),..
				db.P(prep_Q, "careerwins").ToInt(),..
				db.P(prep_Q, "careerpoles").ToInt(),..
				db.P(prep_Q, "careerpodiums").ToInt(),..
				db.P(prep_Q, "careerlaps").ToInt(),..
				db.P(prep_Q, "seasonraces").ToInt(),..
				db.P(prep_Q, "seasonpts").ToInt(),..
				db.P(prep_Q, "seasonwins").ToInt(),..
				db.P(prep_Q, "seasonpoles").ToInt(),..
				db.P(prep_Q, "seasonpodiums").ToInt(),..
				db.P(prep_Q, "qualifyingtime").ToInt(),..
				db.P(prep_Q, "lastracetime").ToInt(),..
				db.P(prep_Q, "kers").ToInt(),..
				db.P(prep_Q, "skill").ToFloat(),..
				db.P(prep_Q, "iwaslapped").ToInt())
		Wend
		
		db.FinalizeQuery(prep_Q)
		
		AppLog "TDriver.SelectAll:"+TDriver.list.Count()
	End Function
	
	Function Create(id:Int, name:String, nationality:Int, dob:Int, pob:String, careerraces:Int, careerpts:Int, championships:Int, careerwins:Int, careerpoles:Int, careerpodiums:Int, careerlaps:Int, seasonraces:Int, seasonpts:Int, seasonwins:Int, seasonpoles:Int, seasonpodiums:Int, qualifyingtime:Int, lastracetime:Int, kers:Int, skill:Float, iwaslapped:Int)
		
		Local NewDriver:TDriver = New TDriver
	
		NewDriver.randno = Rand(1000)
		NewDriver.id = id
		NewDriver.name = name.Trim()
		Local space:Int = name.Find(" ")
		If space > -1 then NewDriver.shortname = name[space..]
		NewDriver.nationality = nationality 
		NewDriver.dob = dob
		NewDriver.pob = pob
		NewDriver.careerraces = careerraces 
		NewDriver.careerpts = careerpts
		NewDriver.championships = championships
		NewDriver.careerwins = careerwins
		NewDriver.careerpoles = careerpoles
		NewDriver.careerpodiums = careerpodiums
		NewDriver.careerlaps = careerlaps
		NewDriver.seasonraces = seasonraces
		NewDriver.seasonpts = seasonpts
		NewDriver.seasonwins = seasonwins
		NewDriver.seasonpoles = seasonpoles
		NewDriver.seasonpodiums = seasonpodiums
		NewDriver.qualifyingtime = qualifyingtime
		NewDriver.lastracetime = lastracetime
		NewDriver.kersfitted = kers
		NewDriver.skill = skill
		NewDriver.iwaslapped = iwaslapped 
		
		Local team:TTeam = TTeam.GetTeamByDriverId(id)
		
		If Not team 
			NewDriver.team = 0
			NewDriver.drivernumber = 0
		Else
			NewDriver.team = team.id
			NewDriver.drivernumber = team.GetDriverNumber(id)
		EndIf
		
		If Not list Then list = CreateList()
		list.AddLast(NewDriver)
		
		AppLog "Team:"+NewDriver.name
	End Function
	
	Function CreateReplayDriver:TDriver(id:Int, team:Int, name:String)
		If Not list Then list = CreateList()
		
		Local newdriver:TDriver = New TDriver
		newdriver.id = id
		newdriver.team = team
		newdriver.name = name
		list.AddLast(newdriver)
		Return newdriver
	End Function
	
	Function UpdateDbAll()
		db.Query("BEGIN;")
		For Local drv:TDriver = EachIn list
			drv.UpdateDb()
		Next
		db.Query("COMMIT;")
	End Function
	
	Method UpdateDb()
		AppLog "Update: "+name
		Local q:String = "UPDATE driver SET careerraces = "+careerraces
		q:+", careerpts = "+careerpts
		q:+", championships = "+championships
		q:+", careerwins = "+careerwins
		q:+", careerpoles = "+careerpoles
		q:+", careerpodiums = "+careerpodiums
		q:+", careerlaps = "+careerlaps
		q:+", seasonraces = "+seasonraces
		q:+", seasonpts = "+seasonpts
		q:+", seasonwins = "+seasonwins
		q:+", seasonpoles = "+seasonpoles
		q:+", seasonpodiums = "+seasonpodiums
		q:+", qualifyingtime = "+qualifyingtime
		q:+", lastracetime = "+lastracetime
		q:+", kers = "+kersfitted
		q:+", skill = "+skill
		q:+", iwaslapped = "+iwaslapped
		q:+" WHERE id = "+id
		
		db.Query(q)
		AppLog q
	End Method
	
	Function ResetSeasonPointsAll()
		SelectAll()
		
		db.Query("BEGIN;")
		For Local drv:TDriver = EachIn list
			drv.ResetSeasonPoints()
			drv.UpdateDb()
		Next
		db.Query("COMMIT;")
		
	End Function
	
	Method ResetSeasonPoints()
		seasonraces = 0
		seasonpts = 0
		seasonwins = 0
		seasonpoles = 0
		seasonpodiums = 0
		qualifyingtime = 0
		lastracetime = 0
	End Method
	
	Function GetDriverById:TDriver(id:Int)
		If Not list Then SelectAll()
		
		AppLog "GetDriverById:"+id
		
		For Local drv:TDriver = EachIn list
			If drv.id = id Then Return drv
		Next
		
		' Return blank type
		Return Null
	End Function
	
	Function GetDriverByName:TDriver(name:String)
		If Not list Then SelectAll()
		
		For Local drv:TDriver = EachIn list
			If drv.name = name Then Return drv
		Next
		
		Return Null
	End Function
	
	Method Compare:Int(O:Object)
		If O = Self Then Return 0
		
		Select sortby 
		Case CSORT_NAME
			If TDriver(O).name < name Return 1 Else Return -1
		Case CSORT_NATIONALITY
			If TDriver(O).nationality < nationality Return 1 Else Return -1
		Case CSORT_SEASONPOINTS
			If TDriver(O).seasonpts > seasonpts Return 1
			If TDriver(O).seasonpts < seasonpts Return -1
			
			If TDriver(O).seasonwins > seasonwins  Return 1
			If TDriver(O).seasonwins < seasonwins  Return -1
		
			If TDriver(O).seasonpodiums > seasonpodiums  Return 1
			If TDriver(O).seasonpodiums < seasonpodiums  Return -1
			
			If TDriver(O).seasonpoles > seasonpoles  Return 1 Else Return -1
			
		Case CSORT_QUALIFYINGTIME
			Local lt1:Int = TDriver(O).qualifyingtime
			Local lt2:Int = qualifyingtime
			
			' Make sure a time has been set
			If lt1 <= 0 Then lt1 = 999999999+id
			If lt2 <= 0 Then lt2 = 999999999+id
			
			If lt1 < lt2 Then Return 1 Else Return -1 
		Case CSORT_FINISHTIME
			If TDriver(O).iwaslapped < iwaslapped Then Return 1
			If TDriver(O).iwaslapped > iwaslapped Then Return -1
			
			Local lt1:Int = TDriver(O).lastracetime
			Local lt2:Int = lastracetime
			
			' Make sure a time has been set
			If lt1 <= 0 Then lt1 = 999999999+id
			If lt2 <= 0 Then lt2 = 999999999+id			
			If lt1 < lt2 Then Return 1 Else Return -1 
			
		Case CSORT_CAREERPOINTS
			If TDriver(O).careerpts > careerpts Return 1 Else Return -1
		
		Case CSORT_RANDOM
			If randno < TDriver(O).randno Then Return 1 Else Return -1
			
		End Select
		
	EndMethod
End Type

Type TCurrency
	Global list:TList
	Global iSelectedCurrency:String
	
	Field m_sName:String
	Field m_sSymbol:String
	Field m_fExchangeRate:Float
	Field m_sDescription:String
	
	Function SetUpCurrencies()
		AppLog "SetUpCurrencies"
		
		If Not list 
			list = CreateList()
		Else
			list.Clear()
		EndIf
		
		Local ini:TStream = OpenFile(gAppLoc+"Media\Spend\Currencies.ini")
		Assert ini, "Could not open Currencies.ini"

		While Not Eof(ini)
			Local newCurrency:TCurrency = New TCurrency
			
			Local str:String = ReadLine(ini)
			Local comma:Int = 0
			
			If Left(str,1) <> ";"
				' Get name then remove name and comma from string
				comma = str.Find(",")
				newCurrency.m_sName = str[..comma]
				str = str[comma+1..]
				
				' Description
				comma = str.Find(",")
				newCurrency.m_sDescription = str[..comma]
				str = str[comma+1..]
				
				' Get value
				comma = str.Find(",")
				newCurrency.m_fExchangeRate = str[..comma].ToFloat()
				str = str[comma+1..]
				
				' Symbol
				newCurrency.m_sSymbol = str
				If newCurrency.m_sName = "EUR" Then newCurrency.m_sSymbol = "€"
				
				list.AddLast(newCurrency)
			EndIf
		Wend
		
		CloseStream ini
		
		list.Sort()
	End Function
	
	Function GetCurrency:TCurrency(name:String)
		Local currenciesarebuggered:Int = True
		For Local curr:TCurrency = EachIn TCurrency.list
			If curr.m_sName = name Then Return curr
			If curr.m_sName = "EUR" Then currenciesarebuggered = False
		Next
		
		If currenciesarebuggered Then Return Null Else Return GetCurrency("EUR")
	End Function
	
	Method DoConversion:Float(val:Float)
		Return val*m_fExchangeRate
	End Method
	
	Function GetString:String(name:String, val:Float)
		Local curr:TCurrency = GetCurrency(name)
		
		val = curr.DoConversion(val)
		
		Local str:String = GetStringNumberWithCommas(Int(val))
		
		StrInsert(str, curr.m_sSymbol, 0)
				
		Return str
	End Function
	
	Function GetStringShort:String(name:String, val:Float)
		Local curr:TCurrency = GetCurrency(name)
		Local ival:Int = curr.DoConversion(val)
		
		' Hundreds
		If ival < 1000
			Return curr.m_sSymbol+String(ival)
		EndIf 
		
		' Thousands
		If ival < 1000000
			ival = ival/1000
			Return curr.m_sSymbol+String(ival)+GetLocaleText("sla_Thousand")
		EndIf 
		
		' Millions
		Local hundredthousands:Int = ival Mod 1000000
		hundredthousands = hundredthousands/100000
		ival = ival/1000000
		
		If hundredthousands Then Return curr.m_sSymbol+String(ival)+"."+String(hundredthousands)+GetLocaleText("sla_Million")
		Return curr.m_sSymbol+String(ival)+GetLocaleText("sla_Million")
	End Function
	
	Function GetDescription:String(name:String)
		For Local currency:TCurrency = EachIn TCurrency.list
			
			If currency.m_sName = name 
				Local str:String = currency.m_sDescription
				If currency.m_sSymbol <> "" Then str:+" ("+currency.m_sSymbol+")"
				Return str
			EndIf
		Next
		
		Return ""
	End Function
	
	Method Compare:Int(O:Object) 
		If TCurrency(O).m_sName < m_sName Return 1 Else Return -1
	EndMethod
End Type

Type TShopItem
	Global list:TList
	Global idlist_cars:TList
	Global idlist_property:TList
	Global imgFinancesCar:TImage
	Global imgFinancesProperty:TImage
	Global carowned:Int
	Global propertyowned:Int

	Field m_Id:Int
	Field m_Name:String
	Field m_ItemType:Int
	Field m_Value:Int
	Field m_Owned:Int
	Field m_FriendOwned:Int
	
	Function SetUpShopDatabase()
		Applog "SetUpShopDatabase"
		
		db.Query("BEGIN;")
		db.Query("DROP TABLE shopitems")
		db.Query("CREATE TABLE shopitems (id INTEGER UNIQUE NOT NULL PRIMARY KEY, name STRING, itemtype INTEGER, value INTEGER, owned INTEGER, friendowned INTEGER)")
		
		Local ini:TStream = OpenFile("UTF8::"+gAppLoc+"Media\Spend\ShopItems.ini")
		Assert ini, "Could not open ShopItems.ini"

		While Not Eof(ini)
			Local str:String = ReadLine(ini)
			Local comma:Int = 0
			
			If Left(str,1) <> ";"
				' Get name then remove name and comma from string
				comma = str.Find(",")
				Local iname:String = str[..comma]
				str = str[comma+1..]
				
				' Get type
				comma = str.Find(",")
				Local itype:String = str[..comma]
				str = str[comma+1..]
				
				' Get value
				Local ivalue:String = str
				
				' Store in db
				Local q:String = "INSERT INTO shopitems VALUES(NULL, '"+iname+"', "+itype+", "+ivalue+", 0, 0)"
				db.Query(q)
			EndIf
		Wend
		
		CloseStream ini
		
		db.Query("COMMIT;")
	End Function
	
	Function SelectShopItems()
		If TShopItem.list Then TShopItem.list.Clear()
		
		If TShopItem.idlist_cars
			TShopItem.idlist_cars.Clear()
		Else
			idlist_cars = CreateList()
		EndIf
		
		If TShopItem.idlist_property
			TShopItem.idlist_property.Clear()
		Else
			idlist_property = CreateList()
		EndIf
		
		Local prep_Q:Int = db.PrepareQuery("SELECT * FROM shopitems ORDER BY value")
		
		While db.StepQuery(prep_Q) = SQLITE_ROW
			TShopItem.Create(db.P(prep_Q, "id").ToInt(),..
				db.P(prep_Q, "name"),..
				db.P(prep_Q, "itemtype").ToInt(),..
				db.P(prep_Q, "value").ToInt(),..
				db.P(prep_Q, "owned").ToInt(),..
				db.P(prep_Q, "friendowned").ToInt())
			
			Select db.P(prep_Q, "itemtype").ToInt()
			Case CSHOPITEM_CAR			TShopItem.idlist_cars.AddLast(db.P(prep_Q, "id"))
			Case CSHOPITEM_PROPERTY		TShopItem.idlist_property.AddLast(db.P(prep_Q, "id"))
			End Select
		Wend
		db.FinalizeQuery(prep_Q)
	End Function
	
	Function Create(id:Int, name:String, itemtype:Int, value:Int, owned:Int, friendowned:Int)
	
		If Not list Then list = CreateList()
		Local NewItem:TShopItem = New TShopItem
	
		NewItem.m_Id = id
		NewItem.m_Name = name
		NewItem.m_ItemType = itemtype
		NewItem.m_Value = value
		NewItem.m_Owned = owned
		NewItem.m_FriendOwned = friendowned
		
		list.AddLast(NewItem)
	End Function
	
	Function GetSelectedItemFromList:TShopItem(sel:Int, itemtype:Int)
		Local idlist:TList
		
		Select itemtype
		Case CSHOPITEM_CAR			idlist = idlist_cars
		Case CSHOPITEM_PROPERTY		idlist = idlist_property
		End Select
			
		Local count:Int = 0
		Local id:Int = 0
		For Local l$ = EachIn idlist
			If count = sel
				id = l.ToInt()
				Exit
			EndIf
			count:+1
		Next
		
		For Local item:TShopItem = EachIn list
			If item.m_Id = id Then Return item
		Next
		
		Return Null
	End Function
	
	Function RefreshTable(itemtype:Int)
		Local tbl:fry_TTable = GetTable(itemtype)
		Local sel:Int = tbl.SelectedItem()
		If sel < 0 Then sel = 0
		
		tbl.ClearItems()
		
		If Not list Then SelectShopItems()
		
		For Local item:TShopItem = EachIn list
			If item.m_ItemType = itemtype
				tbl.AddItem([GetLocaleText(item.m_Name), TCurrency.GetString(OpCurrency, item.m_Value), String(item.m_Owned), String(item.m_FriendOwned)])
			End If
		Next
		
		tbl.SelectItem(sel)
		tbl.ShowItem(sel)
		UpdateShopImages(itemtype)
	End Function
	
	Method UpdateOwnedInDatabase()
		db.Query("BEGIN;")
		db.Query("UPDATE shopitems SET owned = "+m_Owned+", friendowned = "+m_FriendOwned+" WHERE id = "+m_Id)
		db.Query("COMMIT;")
	End Method
	
	Function CountItemsOwned:Int(itemtype:Int)
		Local owned:Int
		Local prep_Q:Int = db.PrepareQuery("SELECT owned FROM shopitems WHERE itemtype = "+String(itemtype)+" and owned > 0")
		
		While db.StepQuery(prep_Q) = SQLITE_ROW
			owned:+db.P(prep_Q, "owned").ToInt()
		Wend
		db.FinalizeQuery(prep_Q)
		
		Return owned
	End Function
	
	Function CountCarsOwnedByFriends:Int()
		Return GetSelectedItemFromList(GetTable(CSHOPITEM_CAR).SelectedItem(), CSHOPITEM_CAR).m_FriendOwned
	End Function
	
	Function GetValueOfItemsAll:Int()
		Local value:Int
		Local prep_Q:Int = db.PrepareQuery("SELECT * FROM shopitems")

		While db.StepQuery(prep_Q) = SQLITE_ROW
			Select db.P(prep_Q, "itemtype").ToInt()
			Case 1	value:+db.P(prep_Q, "value").ToInt()/2
			Case 2	value:+db.P(prep_Q, "value").ToInt()
			End Select
		Wend
		db.FinalizeQuery(prep_Q)
		
		Return value
	End Function
	
	Function GetValueOfItemsOwned:Int(itemtype:Int)
		Local value:Int
		Local q:String = "SELECT * FROM shopitems"
		If itemtype > 0 Then q:+" WHERE itemtype = "+itemtype
		Local prep_Q:Int = db.PrepareQuery(q)

		While db.StepQuery(prep_Q) = SQLITE_ROW
			value:+(db.P(prep_Q, "value").ToInt() * db.P(prep_Q, "owned").ToInt())
			value:+(db.P(prep_Q, "value").ToInt() * db.P(prep_Q, "friendowned").ToInt())
		Wend
		db.FinalizeQuery(prep_Q)
		
		Return value
	End Function

	Function UpdateShopImages(itemtype:Int)
		Local tbl:fry_TTable = GetTable(itemtype)
		Local item:TShopItem = GetSelectedItemFromList(tbl.SelectedItem(), itemtype)
		
		Select itemtype
		Case CSHOPITEM_CAR			
			imgFinancesCar = LoadMyImage(gAppLoc+"Media/Spend/Cars/"+item.m_Name+".jpg"); carowned = item.m_Owned
			If carowned 
				' Car drive your car if you have time (base this on whether you can practice)
				btn_Finances_CarsDrive.gAlpha = 1.0
			Else
				btn_Finances_CarsDrive.gAlpha = 0.5
			End If
		Case CSHOPITEM_PROPERTY		
			imgFinancesProperty = LoadMyImage(gAppLoc+"Media/Spend/Property/"+item.m_Name+".jpg"); propertyowned = item.m_Owned
		End Select
		
	End Function
	
	Function GetTable:fry_TTable(itemtype:Int)
		Select itemtype
		Case CSHOPITEM_CAR			Return tbl_Finances_Cars
		Case CSHOPITEM_PROPERTY		Return tbl_Finances_Property
		End Select
	End Function
	
	Function DrawFinancesCarImg()
		ResetDrawing()
		If Not carowned Then SetColor(64,64,64)
		If imgFinancesCar Then DrawImageRect(imgFinancesCar, 1, 1, can_Finances_CarImg.gW-2, can_Finances_CarImg.gH-2)
	End Function
	
	Function DrawFinancesPropertyImg()
		ResetDrawing()
		If Not propertyowned Then SetColor(64,64,64)
		If imgFinancesProperty Then DrawImageRect(imgFinancesProperty, 1, 1, can_Finances_PropertyImg.gW-2, can_Finances_PropertyImg.gH-2)
	End Function
	
	Function Buy(itemtype:Int)
		AppLog "TShopItem.Buy"
		
		Local tbl:fry_TTable = GetTable(itemtype)
		Local item:TShopItem = GetSelectedItemFromList(tbl.SelectedItem(), itemtype)
		
		If UpdateCash(-item.m_Value)
			If item.m_FriendOwned < 19
				If DoMessage("CMESSAGE_SHOP_SELFFRIEND", True,,GetLocaleText("Yourself"), GetLocaleText("Friend"))
					item.m_Owned:+1
					item.UpdateOwnedInDatabase()
				Else
					Local amt:Int = 10
					
					If item.m_Value >= 1000000
						amt = 50
					ElseIf item.m_Value >= 500000
						amt = 40
					ElseIf item.m_Value >= 250000
						amt = 30
					ElseIf item.m_Value >= 100000
						amt = 20
					End If
					
					UpdateRelationship(CRELATION_FRIENDS, 0.5)
					item.m_FriendOwned:+1
					item.UpdateOwnedInDatabase()
				EndIf
			Else
				item.m_Owned:+1
				item.UpdateOwnedInDatabase()
			EndIf
		EndIf
		
		RefreshTable(itemtype)
		SetUpPanel_Balance()
	End Function
End Type

Type TScreenMessage
	Global list:TList
	
	Field x:Int
	Field y:Int
	Field message:String
	Field fntsize:Int
	
	Field img:TImage
	Field starttime:Int
	Field delaytime:Int
	Field finishtime:Int
	Field alfa:Float
	Field scl:Float
	
	Function Create(x:Int = 0, y:Int = 0, ms:String = Null, img:TImage = Null, delaytime:Int, fntsize:Int, midhnd:Int = True)
	
		ms = ms.Replace("€", "")
		ms = ms.Replace("£", "")
		
		If Not list Then list = CreateList()
			
		Local newmsg:TScreenMessage = New TScreenMessage
		
		newmsg.x = x
		newmsg.y = y
		
		If x = 0 Then newmsg.x = screenW/2
		If y = 0 Then newmsg.y = (screenH/2)+230
		
		newmsg.message = ms
		newmsg.fntsize = fntsize 
		newmsg.img = img
		If img And midhnd Then MidHandleImage(newmsg.img)
		newmsg.starttime = gMillisecs
		newmsg.delaytime = delaytime
		newmsg.finishtime = gMillisecs+delaytime
		newmsg.alfa = 1.0
		newmsg.scl = 1.0
		
		list.AddLast(newmsg)
		
		AppLog "Create message: "+ms
		
	End Function
	
	Function DrawAll()
		If Not list Then Return
		
		Local lastfinish:Int
		Local lastx:Int
		Local lasty:Int
		
		For Local m:TScreenMessage = EachIn list
			' Don't overlap
			If m.starttime < lastfinish And (m.x = lastx And m.y = lasty)
				m.starttime = lastfinish+500
				m.finishtime = (lastfinish+500)+m.delaytime
			End If
			
			m.Draw()
			lastfinish = m.finishtime
			lastx = m.x
			lasty = m.y
		Next
		
		SetScale(1,1)
		SetAlpha(1)
	End Function
	
	Method Draw()
		If gMillisecs < starttime
			Return
		End If
		
		If gMillisecs > finishtime
			list.Remove(Self)
			Return
		End If
		
		Local alphastep:Float = (finishtime-starttime)/100
		If alphastep = 0 Then alphastep = 1
		
		If gMillisecs < starttime+(alphastep*25)
			alfa = ((gMillisecs-starttime)/alphastep)/25.0
		EndIf
		
		If gMillisecs > starttime+(alphastep*75)
			alfa = ((finishtime-gMillisecs)/alphastep)/25.0
		EndIf
		
		scl = 1.0 + (Float(gMillisecs-starttime)/alphastep)/200.0
		
		SetScale(scl,scl)
		SetAlpha(alfa)
		SetColor(255,255,255)
		
		If img		
			DrawImage(img, x, y)
		End If
		
		If message		
			Local fnt:TFontText
			
			Local tx:Float = x
			Local ty:Float = y
			
			Select fntSize
			Case 1	
				fnt = fnt_Small
				ty:-fntoffset_Small
			Case 2	
				fnt = fnt_Medium
				ty:-fntoffset_Medium
			End Select
			
			If img Then ty:+(ImageHeight(img)/2)*scl
			
		'	SetColor(0,0,0)
		'	fnt.Draw(message, tx, ty,1,1,scl)
			SetColor(255,255,255)
			fnt.Draw(message, tx+2, ty-2,1,1,scl)
		End If
	End Method
	
	Function ClearAll()
		If Not list Then Return
		AppLog "TScreenMessage.ClearAll"
		For Local mess:TScreenMessage = EachIn list
			mess.finishtime = 0
			mess.starttime = 0
			mess.message = ""
			mess.img = Null
		Next
		
		list.Clear()
	End Function
End Type
