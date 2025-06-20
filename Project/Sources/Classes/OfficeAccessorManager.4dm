property events:=[]  // List of events handled by the class
property OAuth2provider : Object  // OAuth2 provider object for authentication
property currentTimeZone:=cs:C1710.TimeZone.new().current  // Get the current time zone object


//****************************************************
// Returns the current time zone object
Function timeZone() : Object
	return This:C1470.currentTimeZone
	
	
	//****************************************************
	// Returns the list of events and the current IANA time zone string
Function getEvents() : Object
	return {events: This:C1470.events; timeZone: This:C1470.currentTimeZone.IANA[0]}
	
	
	//****************************************************
	// Opens the event creation dialog and sends the event to Microsoft Calendar
Function addEvent($info) : Object
	var $status : Object
	var $myEvent:=This:C1470._openEventManagementWindow($info; "creation")  // Open creation form
	
	If ($myEvent#Null:C1517)
		If (Form:C1466.trace)
			TRACE:C157
		End if 
		var $calendar : Object:=cs:C1710.NetKit.Office365.new(This:C1470.OAuth2provider).calendar  // Init Microsoft calendar
		
		$status:=$calendar.createEvent($myEvent)  // Send event to Microsoft Calendar
		
		If ($status.success)
			$status.event.action:="creation"  // Mark as created event
			return $status.event  // Return created event
		End if 
	End if 
	
	return {}  // Return empty if cancelled or failed
	
	
	//****************************************************
	// Updates an existing Microsoft calendar event
Function updateEvent($info) : Object
	var $status : Object
	var $myEvent:=This:C1470._openEventManagementWindow($info.event; "update")  // Open update form
	
	If ($myEvent#Null:C1517)
		If (Form:C1466.trace)
			TRACE:C157
		End if 
		
		var $calendar : Object:=cs:C1710.NetKit.Office365.new(This:C1470.OAuth2provider).calendar
		
		$status:=$calendar.updateEvent($myEvent)  // Send update to Microsoft Calendar
		
		If ($status.success)
			$status.event.action:="update"  // Mark as updated event
			return $status.event  // Return updated event
		End if 
	End if 
	
	return {}  // Return empty if cancelled or failed
	
	
	//****************************************************
	// Opens the form for creating or editing an event
Function _openEventManagementWindow($info) : Object
	var $event:={}  // UI-bound event structure
	
	$event.start:={}
	$event.end:={}
	
	var $eventIn:=$info.event=Null:C1517 ? $info : $info.event  // Determine if input is direct or wrapped
	
	// Populate UI event object with default or incoming values
	$event.id:=$eventIn.id || ""
	$event.subject:=$eventIn.title || ""
	
	If ($info.allDay)
		// Set all-day event start and end times
		$event.start.date:=Date:C102($eventIn.date || This:C1470._formatDate($eventIn.start))
		$event.start.time:=Time:C179($eventIn.date || This:C1470._formatDate($eventIn.start))
		
		$event.end.date:=$event.start.date  // Same day for all-day
		$event.end.time:=$event.start.time
		$event.allDay:=True:C214
	Else 
		// Set start and end with date + time for timed event
		$event.start.date:=Date:C102($eventIn.start)
		$event.start.time:=Time:C179($eventIn.start)
		$event.end.date:=Date:C102($eventIn.end || $eventIn.start)
		$event.end.time:=Time:C179($eventIn.end || $eventIn.start)
		$event.allDay:=False:C215
	End if 
	
	// Show EventDetails form for editing
	var $win:=Open form window:C675("EventDetails"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("EventDetails"; $event)
	CLOSE WINDOW:C154
	
	If (Bool:C1537(OK))
		// Create a Microsoft Calendar event object with appropriate format
		var $myEvent:={id: $event.id; start: {timeZone: This:C1470.currentTimeZone.MicrosoftTimeZone}; end: {timeZone: This:C1470.currentTimeZone.MicrosoftTimeZone}; subject: ""; isAllDay: False:C215}
		
		If ($event.allDay)
			// Format all-day event: only date is needed
			$myEvent.start.dateTime:=String:C10($event.start.date; ISO date:K1:8)
			$myEvent.end.dateTime:=String:C10($event.end.date; ISO date:K1:8; ?24:00:00?)  // 24:00:00 to represent full-day duration
		Else 
			// Format with full datetime for timed event
			$myEvent.start.dateTime:=String:C10($event.start.date; ISO date:K1:8; Time:C179($event.start.time))
			$myEvent.end.dateTime:=String:C10($event.end.date; ISO date:K1:8; Time:C179($event.end.time))
		End if 
		
		$myEvent.isAllDay:=$event.allDay
		$myEvent.subject:=$event.subject
		
		return $myEvent  // Return the final event object
	End if 
	
	return Null:C1517  // Return null if dialog was cancelled
	
	
	//****************************************************
	// Ensures a date is in yyyy-MM-dd format and appends T00:00:00 if necessary
Function _formatDate($date : Text) : Text
	var $regex:="^\\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\\d|3[01])$"
	
	If (Match regex:C1019($regex; $date))  // Check for proper format
		$date+="T00:00:00"  // Append midnight time for ISO datetime
	End if 
	
	return $date  // Return formatted date
	