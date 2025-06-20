//%attributes = {}
Form:C1466.spinner:=1

Form:C1466.OfficeAccessorManager:=cs:C1710.OfficeAccessorManager.new()
Form:C1466.GoogleAccessorManager:=cs:C1710.GoogleAccessorManager.new()
Form:C1466.trace:=False:C215

// Load an empty object to ban the use of $4d
WA SET CONTEXT:C1848(*; "OfficeWebArea"; Form:C1466.OfficeAccessorManager)
// Load an empty object to ban the use of $4d
WA SET CONTEXT:C1848(*; "GoogleWebArea"; Form:C1466.GoogleAccessorManager)

var $page:=Get 4D folder:C485(Current resources folder:K5:16)+"events.htm"
WA OPEN URL:C1020(*; "OfficeWebArea"; $page)

WA OPEN URL:C1020(*; "GoogleWebArea"; $page)

