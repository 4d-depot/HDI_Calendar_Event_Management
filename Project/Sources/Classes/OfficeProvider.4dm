property windowRef : Integer
property OAuth2 : cs:C1710.NetKit.OAuth2Provider

Class constructor($windowRef : Integer)
	
	This:C1470.windowRef:=$windowRef
	
	var $myCredentials:=ds:C1482.Credentials.get(2)
	var $credential:={}
	
	$credential.name:="Microsoft"
	$credential.permission:="signedIn"
	$credential.clientId:=$myCredentials.ClientID
	$credential.redirectURI:="http://127.0.0.1:50993/authorize/"
	$credential.scope:="https://graph.microsoft.com/.default"
	$credential.authenticationPage:=Folder:C1567(fk web root folder:K87:15).file("authenticate/authentication.htm")
	
	$credential.prompt:="select_account"
	
	$credential.timeout:=120
	
	This:C1470.OAuth2:=cs:C1710.NetKit.OAuth2Provider.new($credential)
	This:C1470._UpdateFormContext()
	
	This:C1470.getToken()
	
	// *******************************************************************
Function getToken()
	
	If (Try(This:C1470.OAuth2.getToken())#Null:C1517)
		This:C1470._UpdateFormContext()
	End if 
	
	// Call a method to manage the display
	OnTokenReceivedFromAzure(This:C1470.windowRef; This:C1470.OAuth2)
	
	// Save the OAuth2Provider with the updated token in the main process
Function _UpdateFormContext()
	
	CALL FORM:C1391(This:C1470.windowRef; Formula:C1597(Form:C1466.OfficeAccessorManager.OAuth2provider:=$1); This:C1470.OAuth2)
	
	