Include PXW.Debuggers.Macros

Class PXW.Debuggers.UnitTests.BasicToFile Extends %UnitTest.TestCase
{

Method MethodContainingMacros()
{
    $$$DEBUGMethodBegin
    Set x=1
    Write "hello"
    $$$DEBUG("x="_x)
    $$$DEBUGMethodEnd
}

Method MethodContainingStackMacro()
{
    $$$DEBUG("STACK: begin")
    $$$DEBUGStack 
    write "goodbye"
    $$$DEBUG("STACK: end")
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

        Do $$$AssertEquals(size,5) ; hello should be in the temp file
        
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
    #dim debugger as PXW.Debuggers.BasicToFile
    if ##class(PXW.Debuggers.BasicToFile).GetDirectory()="" {
        set olddir=##class(PXW.Debuggers.BasicToFile).SetDirectory("/tmp/")
    }
    ; turn on debugging
    $$$DEBUGNew("PXW.Debuggers.BasicToFile")
    
    ; Output of debug goes to the dubug file, other output should go to the tempfile created below
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
        Set tempsize=file.Size

        Do $$$AssertEquals(tempsize,5) ; hello should be in the temp file

        set debugger=$g($$$debugObject)
        set debugfilename=debugger.file
        do ..LogMessage("debugger.file="_debugfilename)

        k debugger
        $$$DEBUGStop

        set debugfile=##class(%Library.File).%New(debugfilename)
        Do debugfile.Open("R")
        Set line1=debugfile.ReadLine()
        Do $$$AssertEquals(line1,"Begin PXW.Debuggers.UnitTests.BasicToFile:MethodContainingMacros")
 
        Set line2=debugfile.ReadLine()
        Do $$$AssertEquals(line2,"x=1")

        Set line3=debugfile.ReadLine()
        Do $$$AssertEquals(line3,"End PXW.Debuggers.UnitTests.BasicToFile:MethodContainingMacros")

    } Catch e {
        Close tempfile
        Use io
        Set sc=e.AsStatus()
    }
    If $GET(tempfile)'="" Do ##class(%Library.File).Delete(tempfile,.return),..LogMessage("delete temp="_return)
    If $GET(debugfilename)'="" Do ##class(%Library.File).Delete(debugfilename,.return),..LogMessage("delete debug="_return)

    do:$d(olddir) ##class(PXW.Debuggers.BasicToFile).SetDirectory(olddir)
    Do $$$AssertStatusOK(sc)
}

Method TestDebuggingStack()
{
    #dim debugger as PXW.Debuggers.BasicToFile
    if ##class(PXW.Debuggers.BasicToFile).GetDirectory()="" {
        set olddir=##class(PXW.Debuggers.BasicToFile).SetDirectory("/tmp/")
    }
    ; turn on debugging
    $$$DEBUGNew("PXW.Debuggers.BasicToFile")

    ; Output of debug goes to the dubug file, other output should go to the tempfile created below
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

        Do $$$AssertEquals(size,7) ; goodbye should be in the temp file

        set debugger=$g($$$debugObject)
        set debugfilename=debugger.file
        do ..LogMessage("debugger.file="_debugfilename)

        ; looking at the file so kill the debug session to get the file closed
        k debugger
        $$$DEBUGStop

        set debugfile=##class(%Library.File).%New(debugfilename)
        Do debugfile.Open("R")
        Set stackcount=0
        While 'debugfile.AtEnd {
            Set stackcount=stackcount+1
            Set stackline=debugfile.ReadLine()
            Do $$$LogMessage(stackline)
            Do:stackline'="" $$$AssertTrue($PIECE(stackline,":",1)="STACK")
        }
        do $$$AssertNotEquals(stackcount,0)  
    } Catch e {
        Close tempfile
        Use io
        Set sc=e.AsStatus()
    }
    If $GET(tempfile)'="" Do ##class(%Library.File).Delete(tempfile,.return),..LogMessage("delete temp="_return)
    If $GET(debugfilename)'="" Do ##class(%Library.File).Delete(debugfilename,.return),..LogMessage("delete debug="_return)

    do:$d(olddir) ##class(PXW.Debuggers.BasicToFile).SetDirectory(olddir)

    Do $$$AssertStatusOK(sc)
}

Method TestToSpecificFile()
{
    
    set debug=##class(PXW.Debuggers.BasicToFile).%New()
    set debugfilename=debug.GetDirectory()_"unittest.txt"
    do debug.SetFilename(debugfilename)
    $$$DEBUGNew(debug)
    do ..MethodContainingMacros()

    set debugfilename=debug.file
    do $$$AssertEquals(debug.file,debugfilename)

    k debug
    $$$DEBUGStop

    set debugfile=##class(%Library.File).%New(debugfilename)
    Do debugfile.Open("R")
    Set line1=debugfile.ReadLine()
    Do $$$AssertEquals(line1,"Begin PXW.Debuggers.UnitTests.BasicToFile:MethodContainingMacros")

    Set line2=debugfile.ReadLine()
    Do $$$AssertEquals(line2,"x=1")

    Set line3=debugfile.ReadLine()
    Do $$$AssertEquals(line3,"End PXW.Debuggers.UnitTests.BasicToFile:MethodContainingMacros")
}

}
