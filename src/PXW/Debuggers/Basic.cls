Class PXW.Debuggers.Basic Extends %RegisteredObject
{

/// Tends to be called more often with all sorts of data passed in
Method DEBUG(message As %String)
{
	Write message,!
}

/// Dump the current stack to the output
Method DEBUGStack()
{
	For i=0:1:$STACK(-1) {
		Set com=$STACK(i),pla=$STACK(i,"PLACE"),mco=$STACK(i,"MCODE")
		If $LENGTH(com)>$GET(maxcom) Set maxcom=$LENGTH(com)
		If $LENGTH(pla)>$GET(maxpla) Set maxpla=$LENGTH(pla)
	}
	Set $PIECE(spc," ",99)=""
	For i=0:1:$STACK(-1) {
		Set com=$STACK(i),pla=$STACK(i,"PLACE"),mco=$STACK(i,"MCODE")
		Set $EXTRACT(com,maxcom+1)="",$EXTRACT(pla,maxpla+1)=""
		Do ..DEBUG("STACK:"_$JUSTIFY(i,3)_":"_com_":"_pla_":"_mco)
	}
}

}
