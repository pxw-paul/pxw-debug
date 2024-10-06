Class PXW.Debuggers.Console Extends PXW.Debuggers.Basic
{

Method DEBUG(message As %Library.String) [ Language = objectscript ]
{
	Set flag=0
	Set severity=-1
	Do ##class(%SYS.System).WriteToConsoleLog(message,flag,severity)
}

}
