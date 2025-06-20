property UTC:={MicrosoftTimeZone: "UTC"; IANA: "Etc/UTC"; SDT: "Z"; DST: "Z"}  // Default UTC time zone fallback
property _current : Object  // Will store the currently detected time zone object

// Class constructor, called on instantiation
Class constructor()
	This:C1470._get()  // Attempt to detect and set the current system time zone
	
	// Getter function that returns the current time zone object, or UTC as fallback
Function get current() : Object
	return This:C1470._current || This:C1470.UTC
	
	// Internal method to detect the system's current time zone and store it in This._current
Function _get()
	var $myWinWorker : Object  // SystemWorker for executing shell commands
	var $timeZones:=This:C1470._loadTimeZones()  // Load the full time zone mapping
	
	Try
		// If running on Windows
		If (Is Windows:C1573)
			// Use PowerShell to get current time zone in JSON format
			$myWinWorker:=4D:C1709.SystemWorker.new("powershell -Command \"Get-TimeZone | ConvertTo-Json\"")
			var $currentTZ:=JSON Parse:C1218($myWinWorker.wait(1).response)  // Parse result
			$myWinWorker.terminate()
			
			// Match the returned time zone ID to the Microsoft time zone mapping
			This:C1470._current:=$timeZones.query("MicrosoftTimeZone=:1"; $currentTZ.Id).first()
		End if 
		
		// If running on macOS
		If (Is macOS:C1572)
			// Use shell to resolve the /etc/localtime symlink (which points to the time zone)
			$myWinWorker:=4D:C1709.SystemWorker.new("readlink /etc/localtime")
			var $zoneInfo:=$myWinWorker.wait(1).response
			$myWinWorker.terminate()
			
			// Extract the last two components (e.g., "Europe/Paris")
			var $split:=Split string:C1554($zoneInfo; "/")
			var $current:=$split[$split.length-2]+"/"+$split[$split.length-1]
			$split:=Split string:C1554($current; "\n")
			$current:=$split[0]
			
			// Match it to the IANA time zone mapping
			This:C1470._current:=$timeZones.query("IANA[]=:1"; $current).first()
		End if 
	End try
	
	// Formats a date and time in ISO format and appends the time zone offset
Function dateTimeWithOffset($date : Date; $time : Time) : Text
	var $timeZones:=This:C1470.current  // Get current time zone
	var $utc:=String:C10($date; ISO date:K1:8; $time)  // Format as ISO string
	return $utc+This:C1470.getOffset($date)  // Append offset (e.g., "+02:00")
	
	// Returns the appropriate time zone offset for a given date
Function getOffset($date : Date) : Text
	If (This:C1470._isDST($date))
		// Return daylight saving time offset (DST)
		return String:C10(This:C1470.current.DST)
	Else 
		// Return standard time offset (SDT)
		return String:C10(This:C1470.current.SDT)
	End if 
	
	// Determines whether a given date is in the Daylight Saving Time (DST) period
Function _isDST($date : Date) : Boolean
	var $DSTStart:=Add to date:C393(!00-00-00!; Year of:C25($date); 3; 31)  // Start with March 31 of the year
	var $DSTEnd:=Add to date:C393(!00-00-00!; Year of:C25($date); 10; 31)  // Start with October 31 of the year
	
	// Move backwards to find the last Sunday in March
	While (Day number:C114($DSTStart)#1)
		$DSTStart-=1
	End while 
	
	// Move backwards to find the last Sunday in October
	While (Day number:C114($DSTEnd)#1)
		$DSTEnd-=1
	End while 
	
	// Return true if date is within the DST range
	return (($DSTStart<=$date) && ($date<$DSTEnd))
	
	// Loads the list of time zones from a JSON file stored in the Resources folder
Function _loadTimeZones() : Collection
	var $myDoc:=Document to text:C1236(Folder:C1567(fk resources folder:K87:11).file("TimeZone.json").platformPath)  // Load file content
	return JSON Parse:C1218($myDoc)  // Parse JSON into collection
	