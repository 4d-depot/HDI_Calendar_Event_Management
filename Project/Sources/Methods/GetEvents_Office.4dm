//%attributes = {"preemptive":"capable"}
#DECLARE($OAuth2 : Object) : Collection

var $calendar : Object:=cs:C1710.NetKit.Office365.new($OAuth2).calendar
var $myEvent; $myCalendar; $eventsTmp : Object
var $timeZone:=cs:C1710.TimeZone.new()

// calculates the date range to be used
var $startDate:=String:C10(Add to date:C393(!00-00-00!; Year of:C25(Current date:C33); 1; 1); ISO date:K1:8)
var $endDate:=String:C10(Current date:C33()+31; ISO date:K1:8)


// Collection of all the events to display
var $events:=[]

// Gets the default calendar events according to the start and end dates
$eventsTmp:=$calendar.getEvents({startDateTime: $startDate; endDateTime: $endDate; timeZone: $timeZone.current.MicrosoftTimeZone})

If ($eventsTmp.success=True:C214)
	var $last:=False:C215
	Repeat 
		
		// Add the events received to the events list
		$events.combine($eventsTmp.events)
		
		
		$last:=$eventsTmp.isLastPage
		
		// Check if all events are retrieved
		If (Not:C34($eventsTmp.isLastPage))
			$eventsTmp.next()
		End if 
		
	Until ($last || ($eventsTmp.success=False:C215))
	
End if 

return $events

