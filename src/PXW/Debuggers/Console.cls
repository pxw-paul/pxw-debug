Class PXW.Debuggers.Console Extends PXW.Debuggers.Basic
{

Method LOG(message As %Library.String) [ Language = objectscript ]
{
	Set flag=0
	Set severity=0
	Do ##class(%SYS.System).WriteToConsoleLog(message,flag,severity)
}

Method DEBUG(message As %Library.String) [ Language = objectscript ]
{
	Set flag=0
	Set severity=-1
	Do ##class(%SYS.System).WriteToConsoleLog(message,flag,severity)
}

}
