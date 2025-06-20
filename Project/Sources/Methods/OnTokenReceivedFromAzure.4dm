//%attributes = {}
#DECLARE($windowRef : Integer; $OAuth2 : Object)
var $page:=Get 4D folder:C485(Current resources folder:K5:16)+"events.htm"
var $name:="OfficeWorker"
var $event : Object

// Gets the events of the default calendar
var $events:=GetEvents_Office($OAuth2)

var $caldendarEvents:=[]

// Create event object for calendar interface usage
For each ($event; $events)
	var $ev:={id: $event.id; title: $event.subject; start: $event.start.dateTime; end: $event.end.dateTime; allDay: $event.isAllDay}
	$caldendarEvents.push($ev)
End for each 

CALL FORM:C1391($windowRef; Formula:C1597(Form:C1466.OfficeAccessorManager.events:=$1); $caldendarEvents)
CALL FORM:C1391($windowRef; Formula:C1597(WA OPEN URL:C1020(*; "OfficeWebArea"; $page)))
CALL FORM:C1391($windowRef; Formula:C1597(OBJECT SET VISIBLE:C603(*; "SpinnerMicrosoft"; False:C215)))