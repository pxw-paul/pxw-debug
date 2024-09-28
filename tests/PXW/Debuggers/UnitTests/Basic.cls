Include PXW.Debuggers.Macros

Class PXW.Debuggers.UnitTests.Basic Extends %UnitTest.TestCase
{

Method TestDebuggingOff()
{
    ; Output of basic debugging goes to the current device so create a tempfile to capture
    Set sc=$$$OK
    Set io=$IO
    Set tempfile=##class(%File).TempFilename("txt")
    Try {
        Open tempfile:"WN"
        Use tempfile
        Do ..MethodContainingMacros()
        Close tempfile
        Use io

        Set file=##class(%Library.File).%New(tempfile)
        Set size=file.Size

        Do $$$AssertEquals(size,0)
    } Catch e {
        Close tempfile
        Use io
        Set sc=e.AsStatus()
    }
    If $GET(tempfile)'="" Do ##class(%Library.File).Delete(tempfile)

    Do $$$AssertStatusOK(sc)
}

Method TestDebuggingOn()
{
    ; turn on debugging
    $$$DEBUGNew("")

    ; Output of basic debugging goes to the current device so create a tempfile to capture
    Set sc=$$$OK
    Set io=$IO
    Set tempfile=##class(%File).TempFilename("txt")
    Try {
        Open tempfile:"WN"
        Use tempfile
        Do ..MethodContainingMacros()
        Close tempfile
        Use io
        Set file=##class(%Library.File).%New(tempfile)
        Set size=file.Size

        Do $$$AssertNotEquals(size,0)

        Do file.Open("R")
        Set line1=file.ReadLine()
        Do $$$AssertEquals(line1,"Begin PXW.Debuggers.UnitTests.Basic:MethodContainingMacros")
 
        Set line2=file.ReadLine()
        Do $$$AssertEquals(line2,"x=1")

        Set line3=file.ReadLine()
        Do $$$AssertEquals(line3,"End PXW.Debuggers.UnitTests.Basic:MethodContainingMacros")

        While 'file.AtEnd {
            Set stackline=file.ReadLine()
            Do $$$LogMessage(stackline)
        }

    } Catch e {
        Close tempfile
        Use io
        Set sc=e.AsStatus()
    }
    If $GET(tempfile)'="" Do ##class(%Library.File).Delete(tempfile)

    Do $$$AssertStatusOK(sc)
}

Method TestDebuggingStack()
{
    ; turn on debugging
    $$$DEBUGNew("")

    ; Output of basic debugging goes to the current device so create a tempfile to capture
    Set sc=$$$OK
    Set io=$IO
    Set tempfile=##class(%File).TempFilename("txt")
    Try {
        Open tempfile:"WN"
        Use tempfile
        Do ..MethodContainingStackMacro()
        Close tempfile
        Use io
        Set file=##class(%Library.File).%New(tempfile)
        Set size=file.Size

        Do $$$AssertNotEquals(size,0)

        Do file.Open("R")
        Set stackcount=0
        While 'file.AtEnd {
            Set stackcount=stackcount+1
            Set stackline=file.ReadLine()
            Do $$$LogMessage(stackline)
            Do:stackline'="" $$$AssertTrue($PIECE(stackline,":",1)="STACK")
        }
        do $$$AssertNotEquals(stackcount,0)  
    } Catch e {
        Close tempfile
        Use io
        Set sc=e.AsStatus()
    }
    If $GET(tempfile)'="" Do ##class(%Library.File).Delete(tempfile)

    Do $$$AssertStatusOK(sc)
}

Method MethodContainingMacros()
{
    $$$DEBUGMethodBegin
    Set x=1
    $$$DEBUG("x="_x) 
    $$$DEBUGMethodEnd
}

Method MethodContainingStackMacro()
{
    $$$DEBUG("STACK: begin")
    $$$DEBUGStack
    $$$DEBUG("STACK: end")
}

}
