Include PXW.Debuggers.Macros

Class PXW.Debuggers.UnitTests.Example Extends %RegisteredObject
{

ClassMethod RunTest(DebugTo = "")
{
    if DebugTo="SCREEN" {
        set deblog="PXW.Debuggers.Basic"
    } elseif DebugTo="FILE" {
        ; You may pass in an object to the New macro giving 
        ; more control of the debug object.
        set deblog=##class(PXW.Debuggers.BasicToFile).%New()
        set deblog.AddDateTime=1
    } elseif DebugTo="CONSOLE" {
        set deblog="PXW.Debuggers.Console"
    } else {
        set deblog=""
    }
    if deblog'="" $$$DEBUGNew(deblog)

    set object=##class(PXW.Debuggers.UnitTests.Example).%New()
    do object.MethodContainingMacros()
    
    if $$$debugIsON zw $$$debugObject
    $$$DEBUGStop
}

Method MethodContainingMacros()
{
    $$$DEBUGMethodBegin
    write "running method",!
    for x=1:1:10 {
        $$$DEBUG("x="_x) 
    }
    write "ending method",!
    $$$DEBUGMethodEnd
}

}
