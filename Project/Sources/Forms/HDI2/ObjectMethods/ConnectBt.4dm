var $name:="OfficeWorker"

OBJECT SET VISIBLE:C603(*; "SpinnerMicrosoft"; True:C214)

var Provider : Object
CALL WORKER:C1389($name; Formula:C1597(Provider:=cs:C1710.OfficeProvider.new($1)); Current form window:C827)