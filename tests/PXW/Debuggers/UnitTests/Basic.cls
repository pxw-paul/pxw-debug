Include PXW.Debuggers.Macros

Class PXW.Debuggers.UnitTests.Basic Extends %UnitTest.TestCase
{

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

Method MethodValidatesInput(num As %Integer) As %Status
{
    Set sc=$$$OK
    Set:num=1 sc=$$$ERROR(5001,"General purpose error A")
    Set:num=2 sc=$$$ERROR(5001,"General purpose error B")
    Quit sc
}

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
        Do $$$AssertNotEquals(stackcount,0)  
    } Catch e {
        Close tempfile
        Use io
        Set sc=e.AsStatus()
    }
    If $GET(tempfile)'="" Do ##class(%Library.File).Delete(tempfile)

    Do $$$AssertStatusOK(sc)
}

Method TestDebuggingSc()
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

        ; this gets logged: 1 generates error A
        $$$DEBUGSC(sc,..MethodValidatesInput(1))
        Do $$$AssertStatusNotOK(sc)

        ; this does not: 99 is valid 
        $$$DEBUGSC(sc,..MethodValidatesInput(99))
        Do $$$AssertStatusOK(sc)

        ; this gets logged: 2 generates error B
        $$$DEBUGSC(sc,..MethodValidatesInput(2))
        Do $$$AssertStatusNotOK(sc) 

        Close tempfile
        Use io
        Set file=##class(%Library.File).%New(tempfile)
        Set size=file.Size

        Do $$$AssertNotEquals(size,0)

        Do file.Open("R")
        Set line1=file.ReadLine()
        Do $$$AssertEquals(line1,"..MethodValidatesInput(1) ERROR #5001: General purpose error A")
  
        Set line2=file.ReadLine()
        Do $$$AssertEquals(line2,"..MethodValidatesInput(2) ERROR #5001: General purpose error B")


    } Catch e {
        Close tempfile
        Use io
        Set sc=e.AsStatus()
    }
    If $GET(tempfile)'="" Do ##class(%Library.File).Delete(tempfile)
}

Method TestDebuggingPauseResume()
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

        ; this gets logged
        $$$DEBUG("debug is on")

        ; this does not
        $$$DEBUGPause
        $$$DEBUG("debug is off")
        $$$DEBUGResume

        ; this gets logged
        $$$DEBUG("debug is back on")

        Close tempfile
        Use io
        Set file=##class(%Library.File).%New(tempfile)
        Set size=file.Size

        Do $$$AssertNotEquals(size,0)

        Do file.Open("R")
        Set line1=file.ReadLine()
        Do $$$AssertEquals(line1,"debug is on")
  
        Set line2=file.ReadLine()
        Do $$$AssertEquals(line2,"debug is back on")


    } Catch e {
        Close tempfile
        Use io
        Set sc=e.AsStatus()
    }
    If $GET(tempfile)'="" Do ##class(%Library.File).Delete(tempfile)
}

}
