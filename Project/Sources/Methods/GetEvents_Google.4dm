//%attributes = {"preemptive":"capable"}
#DECLARE($windowRef : Integer; $OAuth2 : Object) : Collection

var $calendar : Object:=cs:C1710.NetKit.Google.new($OAuth2).calendar
var $myEvent; $myCalendar; $eventsTmp : Object
var $timeZone:=cs:C1710.TimeZone.new()

// calculate the date range to be used
var $startDate:=String:C10(Add to date:C393(!00-00-00!; Year of:C25(Current date:C33); 1; 1); ISO date GMT:K1:10)
var $endDate:=String:C10(Current date:C33()+31; ISO date GMT:K1:10)

// Collection of all the events to display
var $events:=[]

// Get all the events of the calendar
$eventsTmp:=$calendar.getEvents({top: 100; singleEvents: True:C214; startDateTime: $startDate; endDateTime: $endDate; timeZone: $timeZone.current.IANA[0]})

If (($eventsTmp.success=True:C214) && ($eventsTmp.events.length>0))
	var $last:=False:C215
	Repeat 
		
		
		// Add the events received to the events list
		$events.combine($eventsTmp.events)
		
		// Check if all events are retrieved
		If ($eventsTmp.isLastPage)
			$last:=True:C214
		Else 
			// Get the next event if necessary
			$eventsTmp.next()
		End if 
	Until ($last)
End if 

// Parse all the events to calculate the date and time attributes
For each ($myEvent; $events)
	If ($myEvent.status#"cancelled")
		If (String:C10($myEvent.start.date)="")
			
			$myEvent.isAllDay:=False:C215
			
		Else 
			
			$myEvent.isAllDay:=True:C214
			$myEvent.start.dateTime:=Date:C102($myEvent.start.date+"T00:00:00.0000")
			$myEvent.end.dateTime:=Date:C102($myEvent.end.date+"T00:00:00.0000")
			
		End if 
		
	End if 
	
End for each 

//$events:=$events.orderBy("start.date asc,start.time asc")

return $events


