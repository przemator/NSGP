' Clipboard
'
Const CF_TEXT:Int = 1
Const CF_BITMAP:Int = 2
Const CF_METAFILEPICT:Int = 3
Const CF_SYLK:Int = 4
Const CF_DIF:Int = 5
Const CF_TIFF:Int = 6
Const CF_OEMTEXT:Int = 7
Const CF_DIB:Int = 8
Const CF_PALETTE:Int = 9
Const CF_PENDATA:Int = 10
Const CF_RIFF:Int = 11
Const CF_WAVE:Int = 12
Const CF_UNICODETEXT:Int = 13
Const CF_ENHMETAFILE:Int = 14
Const CF_HDROP:Int = 15
Const CF_LOCALE:Int = $10
Const CF_MAX:Int = 17
Const CF_DIBV5:Int = 17

Extern "win32"
	Function OpenClipboard:Int( hwnd:Int = 0) = "OpenClipboard@4"
	Function CloseClipboard:Int() = "CloseClipboard@0"
	Function GetClipboardData:Int( format:Int) = "GetClipboardData@4"
	Function SetClipboardData:Int( format:Int, handle:Int) = "SetClipboardData@8"
	Function EmptyClipboard:Int() = "EmptyClipboard@0"		
	Function IsClipboardFormatAvailable:Int( format:Int) = "IsClipboardFormatAvailable@4"
EndExtern


'
' Global Memory
'
Const GMEM_FIXED:Int = 0  
Const GMEM_MOVEABLE:Int = 2  
Const GMEM_NOCOMPACT:Int = $10  
Const GMEM_NODISCARD:Int = $20  
Const GMEM_ZEROINIT:Int = $40  
Const GMEM_MODIFY:Int = $80
Const GMEM_DISCARDABLE:Int = $100  
Const GMEM_NOT_BANKED:Int = $1000  
Const GMEM_SHARE:Int = $2000  
Const GMEM_DDESHARE:Int = $2000  
Const GMEM_NOTIFY:Int = $4000  
Const GMEM_LOWER:Int = GMEM_NOT_BANKED  
Const GMEM_VALID_FLAGS:Int = 32626  
Const GMEM_INVALID_HANDLE:Int = $8000
Const GHND:Int = GMEM_MOVEABLE | GMEM_ZEROINIT  
Const GPTR:Int = GMEM_FIXED | GMEM_ZEROINIT

Extern "win32"
	Function GlobalAlloc:Int( flags:Int, size:Int) = "GlobalAlloc@8"
	Function GlobalReAlloc:Int( mem:Int, size:Int, flags:Int) = "GlobalReAlloc@8"
	Function GlobalSize:Int( mem:Int) = "GlobalSize@4"
	Function GlobalFlags:Int( mem:Int) = "GlobalFlags@4"
	Function GlobalLock:Byte Ptr( mem:Int) = "GlobalLock@4"
	Function GlobalHandle:Int( mem:Byte Ptr) = "GlobalHandle@4"
	Function GlobalUnlock:Int( mem:Int) = "GlobalUnlock@4"
	Function GlobalFree:Int( mem:Int) = "GlobalFree@4"
EndExtern


Function WriteClipboardText( s:String)
	If s = Null Then Return 
	If OpenClipboard() Then
		Local data:Int = GlobalAlloc( GMEM_MOVEABLE, s.Length + 1)
		Local p:Byte Ptr = GlobalLock( data)
		MemCopy( p, s.ToCString(), s.Length + 1)
		GlobalUnlock( data)
		EmptyClipboard()
		SetClipboardData( CF_TEXT, data)
		CloseClipboard()
		GlobalFree( data)
	EndIf
EndFunction

Function ReadClipboardText:String()
	Local s:String
	If OpenClipboard() Then
		If IsClipboardFormatAvailable( CF_TEXT) Then
			Local data:Int = GetClipboardData( CF_TEXT)
			Local p:Byte Ptr = GlobalLock( data)
			s = String.FromCString( p)
			GlobalUnlock( data)
		EndIf
		CloseClipboard()
	EndIf
	Return s
EndFunction

'WriteClipboardText( "Hello World!")
'Print "read: " + ReadClipboardText()