Include PXW.Debuggers.Macros

Class PXW.Debuggers.UnitTests.Example Extends %RegisteredObject
{

ClassMethod RunTest(DebugTo = "")
{
    If DebugTo="SCREEN" {
        Set deblog="PXW.Debuggers.Basic"
    } ElseIf DebugTo="FILE" {
        ; You may pass in an object to the New macro giving 
        ; more control of the debug object.
        Set deblog=##class(PXW.Debuggers.BasicToFile).%New()
        Set deblog.AddDateTime=1
    } ElseIf DebugTo="CONSOLE" {
        Set deblog="PXW.Debuggers.Console"
    } Else {
        Set deblog=""
    }
    If deblog'="" $$$DEBUGNew(deblog)

    Set object=##class(PXW.Debuggers.UnitTests.Example).%New()
    Do object.MethodContainingMacros()
    
    If $$$debugIsON ZWrite $$$debugObject
    $$$DEBUGStop
}

Method MethodContainingMacros()
{
 
    $$$DEBUGMethodBegin
    Write "running method",!
    For x=1:1:10 {
        $$$DEBUG("x="_x) 
    }
    Write "ending method",!
    $$$DEBUGMethodEnd
}

}
