property events:=[]
property OAuth2provider : Object
property currentTimeZone:=cs:C1710.TimeZone.new()


//****************************************************
// Returns the current system time zone as an object
Function timeZone() : Object
	return This:C1470.currentTimeZone.current
	
	
	//****************************************************
	// Returns the list of events and the IANA time zone name
Function getEvents() : Object
	var $result:={events: This:C1470.events; timeZone: This:C1470.currentTimeZone.current.IANA[0]}
	return $result
	
	
	//****************************************************
	// Opens the event creation window and adds a new event to Google Calendar
Function addEvent($info) : Object
	var $status : Object
	var $myEvent:=This:C1470._openEventManagementWindow($info)  // Open the event creation dialog
	
	If ($myEvent#Null:C1517)
		If (Form:C1466.trace)
			TRACE:C157
		End if 
		
		var $calendar : Object:=cs:C1710.NetKit.Google.new(This:C1470.OAuth2provider).calendar  // Initialize the calendar object
		
		$status:=$calendar.createEvent($myEvent)  // Send the event to Google Calendar
		
		If ($status.success)
			return This:C1470._customizeEvent($status; "creation")  // Format event for calendar display
		End if 
	End if 
	
	return {}
	
	
	//****************************************************
	// Updates an existing event using user input
Function updateEvent($info) : Object
	var $status : Object
	var $myEvent:=This:C1470._openEventManagementWindow($info.event; "update")  // Open update dialog
	
	If ($myEvent#Null:C1517)
		If (Form:C1466.trace)
			TRACE:C157
		End if 
		var $calendar : Object:=cs:C1710.NetKit.Google.new(This:C1470.OAuth2provider).calendar
		
		var $eventTmp:=$calendar.getEvent({eventId: $myEvent.id; timeZone: This:C1470.currentTimeZone.current.IANA[0]})  // Retrieve original event
		$eventTmp.summary:=$myEvent.summary
		$eventTmp.start:=$myEvent.start
		$eventTmp.end:=$myEvent.end
		
		$status:=$calendar.updateEvent($myEvent; {fullUpdate: True:C214})  // Update the event on Google Calendar
		
		If ($status.success)
			return This:C1470._customizeEvent($status; "update")  // Format for calendar display
		End if 
	End if 
	
	return {}
	
	
	//****************************************************
	// Adds extra fields for calendar interface usage (e.g., UI display)
Function _customizeEvent($status : Object; $action : Text) : Object
	$status.event.action:=$action  // Save the type of operation (creation/update)
	
	If (String:C10($status.event.start.date)="")  // Check if the event has no 'date' field (i.e., not all-day)
		$status.event.isAllDay:=False:C215
	Else 
		$status.event.isAllDay:=True:C214
		// Convert start and end to ISO datetime string
		$status.event.start.dateTime:=This:C1470._formatDate($status.event.start.date)
		$status.event.end.dateTime:=This:C1470._formatDate($status.event.end.date)
	End if 
	$status.event.subject:=$status.event.summary
	
	return $status.event  // Return the enriched event object
	
	
	//****************************************************
	// Handles UI dialog for event creation/update
Function _openEventManagementWindow($info) : Object
	var $event:={}  // UI event structure
	
	$event.start:={}
	$event.end:={}
	
	var $eventIn:=$info.event=Null:C1517 ? $info : $info.event  // Handle input structure
	
	$event.id:=$eventIn.id || ""  // Set ID if present
	$event.subject:=$eventIn.title || ""  // Set subject/title
	
	If ($info.allDay)
		// Set dates only for all-day event
		$event.start.date:=Date:C102($eventIn.date || This:C1470._formatDate($eventIn.start))
		$event.start.time:=?00:00:00?
		
		$event.end.date:=Date:C102($eventIn.date || This:C1470._formatDate($eventIn.end || $eventIn.start))
		// Adjust end date for UI display (Google uses exclusive end date)
		$event.end.date:=$event.end.date=$event.start.date ? $event.end.date : $event.end.date-1
		$event.end.time:=?00:00:00?
		$event.allDay:=True:C214
	Else 
		// Set date and time for timed event
		$event.start.date:=Date:C102($eventIn.start)
		$event.start.time:=Time:C179($eventIn.start)
		$event.end.date:=Date:C102($eventIn.end || $eventIn.start)
		$event.end.time:=Time:C179($eventIn.end || $eventIn.start)
		$event.allDay:=False:C215
	End if 
	
	// Open the form for editing event details
	var $win:=Open form window:C675("EventDetails"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("EventDetails"; $event)
	CLOSE WINDOW:C154
	
	If (Bool:C1537(OK))
		// Create Google Calendar-compatible event structure
		var $myEvent:={id: $event.id; start: {timeZone: This:C1470.currentTimeZone.current.IANA[0]}; end: {timeZone: This:C1470.currentTimeZone.current.IANA[0]}; summary: ""}
		
		If ($event.allDay)
			// Format for all-day: only date (Google requires +1 day for exclusive end)
			$myEvent.start.date:=String:C10($event.start.date; "yyyy-MM-dd")
			$myEvent.end.date:=String:C10($event.end.date+1; "yyyy-MM-dd")
		Else 
			// Format with full datetime using timezone offset
			$myEvent.start.dateTime:=This:C1470.currentTimeZone.dateTimeWithOffset($event.start.date; $event.start.time)
			$myEvent.end.dateTime:=This:C1470.currentTimeZone.dateTimeWithOffset($event.end.date; $event.end.time)
		End if 
		
		$myEvent.summary:=$event.subject
		
		return $myEvent  // Return formatted event
	End if 
	
	return Null:C1517  // Cancelled dialog
	
	
	//****************************************************
	// Converts date string to ISO datetime format (adds T00:00:00)
Function _formatDate($date : Text) : Text
	var $regex:="^\\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\\d|3[01])$"
	
	If (Match regex:C1019($regex; $date))  // Check for yyyy-mm-dd format
		$date+="T00:00:00"  // Append time part
	End if 
	
	return $date  // Return formatted date
	