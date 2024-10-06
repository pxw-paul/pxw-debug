Class PXW.Debuggers.BasicToFile Extends PXW.Debuggers.Basic
{

Property currentIO As %String;

Property file As %String;

Method DEBUG(message As %String)
{
    Do ..UseFile()
    Try {
        Write message,!
    } Catch e {
    }
    Do ..UseIO()
}

Method SetFilename(Filename As %String)
{
    Do ..UseFile(Filename)
    Do ..UseIO()
}

/// Sets the default directory of the output, returns the old value
ClassMethod SetDirectory(Directory As %String) As %String
{
    Set old=$GET(^PXW.Debuggers("BasicToFile"))
    Set ^PXW.Debuggers("BasicToFile")=Directory
    Quit old
}

ClassMethod GetDirectory() As %String
{
    Quit $GET(^PXW.Debuggers("BasicToFile"))
}

/// Needs ^PXW.Debuggers("BasicToFile")="/durable/"
Method UseFile(ForcedFilename As %String)
{
    If ..file="" {
        If $DATA(ForcedFilename) {
            Set filename=ForcedFilename
        } Else {
            ; allow this to crash if the directory is not set up
            Set filedir=^PXW.Debuggers("BasicToFile") 
            if ##class(%Library.File).DirectoryExists(filedir)=0 {
                set sc=##class(%File).CreateDirectory(^PXW.Debuggers("BasicToFile"),.ret)
                set ^PXW.Debuggers("BasicToFile","dirCreated")=$lb(sc,ret,$h)
            }
            Set filename=filedir_"debug_"_$TRANSLATE($ZDATETIME($HOROLOG,8,1)," :","_")_"_"_$JOB_".txt"
        }
        Set ..file=filename
        Open ..file:"WN"
    } 
    If ..currentIO="" Set ..currentIO=$IO
    Use ..file
}

Method UseIO()
{
    Use ..currentIO
    Set ..currentIO=""
}

/// This callback method is invoked by the <METHOD>%Close</METHOD> method to 
/// provide notification that the current object is being closed.
/// 
/// <P>The return value of this method is ignored.
Method %OnClose() As %Status [ Private, ServerOnly = 1 ]
{
	If ..file'="" {
        Close ..file
        Set ..file=""
    }
    Quit $$$OK
}

}
