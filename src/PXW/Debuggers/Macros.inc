ROUTINE PXW.Debuggers.Macros [Type=INC]
#dim %pxwdebug as PXW.Debuggers.Basic

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#If ($G(^PXW.Debuggers("DISABLED"),0)=0)

/// record a message to the debug log
#define DEBUG(%message) d:$$$debugIsON $$$debugObject.DEBUG(%message) 

/// record the stack in the debug log 
#define DEBUGStack d:$$$debugIsON $$$debugObject.DEBUGStack() 

#define DEBUGSetup(%class) s $$$debugObject=$s($isobject(%class):%class,1:$system.OBJ.New($s(%class'="":%class,1:"PXW.Debuggers.Basic")))

/// create a new debugger instance
#define DEBUGNew(%class) n $$$debugObject $$$DEBUGSetup(%class)

/// if debugging break
#define DEBUGBreak break:$$$debugIsON

///
#define DEBUGMethodBegin $$$DEBUG(##safeexpression("""Begin "_%classname_":"_%methodname_""""))
///
#define DEBUGMethodEnd $$$DEBUG(##safeexpression("""End "_%classname_":"_%methodname_""""))

/// no need to stop like this if you are using DEBUGNew, as the debugger will disappear on quit
#define DEBUGStop k $$$debugObject

#define debugIsON $isobject($g($$$debugObject))

#define debugObject %pxwdeb

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#Else
#define DEBUG(%message) 
#define DEBUGStack
#define DEBUGSetup(%class) 
#define DEBUGNew(%class) 
#define DEBUGBreak 
#define DEBUGMethodBegin 
#define DEBUGMethodEnd 
#define DEBUGStop 
#define debugIsON 0
#define debugObject %pxwdebug
#EndIf

