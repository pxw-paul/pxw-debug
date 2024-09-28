Class PXW.Debuggers.Timing Extends PXW.Debuggers.Basic
{

/// Keyed by classname
Property counts As %Integer [ MultiDimensional ];

/// Keyed by classnemt
Property times As %Numeric [ MultiDimensional ];

/// keyed by $stack = $lb(classname,timeSoFar,$zh lastTimeStarted)
Property stackstart As %List [ MultiDimensional ];

Property laststack As %Integer;

Method %OnNew() As %Status
{
    Kill %pxwdebcounts,%pxwdebstackstart,%pxwdebtimes
    Quit $$$OK
}

/// Only method begins an ends have any impact in for debug, the time between is measured.
/// Other messages are lost.
Method DEBUG(message As %String)
{
    If $DATA(message) {
        Set stack=$STACK
        Set keyword=$PIECE(message," ",1)
        Set classname=$PIECE(message," ",2,*)
        ; end all times that are above where we are now in the stack (means we ended without hitting an EndMethod debug call)
        Set stk=""
        If keyword="Begin" {
            Set %pxwdebcounts(classname)=$GET(%pxwdebcounts(classname))+1

            ; find previous
            Set stk=$ORDER(%pxwdebstackstart(stack),-1,prevdata)
            If stk'="" {
                ;s sclassname=$lg(prevdata,1),szh=$lg(prevdata,2)
                Set $LISTBUILD(sclassname,szh)=prevdata
                Set %pxwdebtimes(sclassname)=$GET(%pxwdebtimes(sclassname))+($ZHOROLOG-szh)
            }
            Set started=$ZHOROLOG
            Set %pxwstackstart(stack)=$LISTBUILD(classname,started)
            Set ..laststack=stack
        }
        If keyword="End" {
            If '$DATA(%pxwstackstart(stack)) $$$ThrowStatus($$$ERROR(5001,"Attempted to end a method that did not begin: "_classname))

            Set lastdata=$GET(%pxwstackstart(stack))
            Set $LISTBUILD(sclassname,szh)=lastdata
            Set %pxwdebtimes(sclassname)=$GET(%pxwdebtimes(sclassname))+($ZHOROLOG-szh)
            Kill %pxwstackstart(stack)
            
            ; update the previous start point to start unpause the clock
            Set stk=$ORDER(%pxwstackstart(stack),-1,prevdata)
            If stk'="" {
                Set $LIST(prevdata,2)=$ZHOROLOG
                Set %pxwstackstart(stk)=prevdata
            }
            
            Set ..laststack=stack
        }
    }
}

Query SelectResults() As %Query(ROWSPEC = "ClassName:%String,MethodName:%String,TotalTime:%Numeric,CountOfCalls:%Integer,AverageTime:%Numeric,PercentageOfTime:%Numeric")
{
}

ClassMethod SelectResultsExecute(ByRef qHandle As %Binary) As %Status
{
    If '$DATA(%pxwdebug) Quit $$$ERROR(5001,"No debugger object found (%pxwdebug)")
    If '%pxwdebug.%IsA(..%ClassName(1)) Quit $$$ERROR(5001,"Debugger object is not a Timing one")

    Kill ^||PXWDebugTiming
    Set cm="",totaltime=0
    ; sort add up total time
    For  {
        Set cm=$ORDER(%pxwdebcounts(cm))
        Quit:cm=""
        
        Set tt=$GET(%pxwdebtimes(cm),9999.999)
        Set totaltime=totaltime+tt
    }   
    ; sort by total time
    For  {
        Set cm=$ORDER(%pxwdebcounts(cm))
        Quit:cm=""
        
        Set class=$PIECE(cm,":",1),method=$PIECE(cm,":",2),tt=$GET(%pxwdebtimes(cm),9999.999),cc=$GET(%pxwdebcounts(cm),9999999),av=tt/cc
        Set perc=(tt/totaltime)*100
        Set Row=$LISTBUILD(class,method,tt,cc,av,perc)
        Set ^||PXWDebugTiming(tt,cm)=Row
    }   

    Set qHandle=""
    Quit $$$OK
}

ClassMethod SelectResultsFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status
{
    Set k1=$LISTGET(qHandle,1),k2=$LISTGET(qHandle,2)
    If k2'="" Goto k2loop
k1loop  Set k1=$ORDER(^||PXWDebugTiming(k1))
    If k1="" Set AtEnd=1,Row="" Quit $$$OK
k2loop  Set k2=$ORDER(^||PXWDebugTiming(k1,k2),1,Row)
    If k2="" Goto k1loop
    Set qHandle=$LISTBUILD(k1,k2)
    Quit $$$OK
}

ClassMethod SelectResultsClose(qHandle As %Binary) As %Status
{
    Kill ^||PXWDebugTiming
    Quit $$$OK
}

}
