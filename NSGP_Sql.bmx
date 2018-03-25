' Sql Functions

Function GetDatabaseInt:Int(fld:String, tbl:String, id:Int)
	If id < 1 Then Return 0
	Local num:Int = 0
	
	Local q:String = "SELECT "+fld+" FROM "+tbl+" WHERE id="+id
	Local prep_Select:Int = db.PrepareQuery(q)
	If db.StepQuery(prep_SELECT) = SQLITE_ROW Then num = db.P(prep_Select, fld).ToInt()
	db.FinalizeQuery(prep_Select)
	
'	Applog q+":"+num
	Return num
End Function

Function GetDatabaseFloat:Float(fld:String, tbl:String, id:Int)
	If id < 1 Then Return 0
	Local num:Float = 0
	
	Local prep_Select:Int = db.PrepareQuery("SELECT "+fld+" FROM "+tbl+" WHERE id="+id)
	If db.StepQuery(prep_SELECT) = SQLITE_ROW Then num = db.P(prep_Select, fld).ToFloat()
	db.FinalizeQuery(prep_Select)
	
	Return num
End Function

Function GetDatabaseString:String(fld:String, tbl:String, id:Int)
	If id < 1 Then Return ""
	Local str:String
	
	Local prep_Select:Int = db.PrepareQuery("SELECT "+fld+" FROM "+tbl+" WHERE id="+id)
	If db.StepQuery(prep_SELECT) = SQLITE_ROW Then str = db.P(prep_Select, fld)
	db.FinalizeQuery(prep_Select)
	
	Return str
End Function

Function UpdateDatabaseInt(tbl:String, fld:String, data:Int, id:Int = 0)
	db.Query("BEGIN;")
	Local s:String = 0
	If id = 0
		s = "UPDATE "+tbl+" SET "+fld+"='"+data+"'"
	Else
		s = "UPDATE "+tbl+" SET "+fld+"='"+data+"' WHERE id="+id
	End If
	AppLog s
	db.Query(s)
	db.Query("COMMIT;")
End Function

Function UpdateDatabaseFloat(tbl:String, fld:String, data:Float, id:Int = 0)
	db.Query("BEGIN;")
	Local s:String = 0
	If id = 0
		s = "UPDATE "+tbl+" SET "+fld+"='"+data+"'"
	Else
		s = "UPDATE "+tbl+" SET "+fld+"='"+data+"' WHERE id="+id
	End If
	AppLog s
	db.Query(s)
	db.Query("COMMIT;")
End Function

Function UpdateDatabaseString(tbl:String, fld:String, data:String, id:Int = 0)
	db.Query("BEGIN;")
	Local s:String = 0
	If id = 0
		s = "UPDATE "+tbl+" SET "+fld+"='"+data+"'"
	Else
		s = "UPDATE "+tbl+" SET "+fld+"='"+data+"' WHERE id="+id
	End If
	AppLog s
	db.Query(s)
	db.Query("COMMIT;")
End Function