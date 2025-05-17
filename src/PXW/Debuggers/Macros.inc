ROUTINE PXW.Debuggers.Macros [Type=INC]
#dim %pxwdebug as PXW.Debuggers.Basic

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#If ($G(^PXW.Debuggers("ENABLED"),0)=1)

#; ---------- Macros that are used in the code to be debugged ------------------------

/// Record a message to the debug log.
#define DEBUG(%message) d:$$$debugIsON $$$debugObject.DEBUG(%message) 

/// Record a formatted string to the log.
#define DEBUGTEXT(%message) d:$$$debugIsON $$$debugObject.DEBUG($$$debugFormat(%message))

/// Record the start of the method to the debug log
#define DEBUGMethodBegin $$$DEBUG(##safeexpression("""Begin "_%classname_":"_%methodname_""""))

/// Record the end of the method to the debug log.
/// I advise that the DEBUGMethodBegin and end always match. 
/// Try to avoid calling Begin without having an End.
/// You will thank me when you come to analyse the output, also a (future) timing log may need to be able to match them.
#define DEBUGMethodEnd $$$DEBUG(##safeexpression("""End "_%classname_":"_%methodname_""""))

/// Record the stack in the debug log.
#define DEBUGStack d:$$$debugIsON $$$debugObject.DEBUGStack() 

/// If debugging break.
#define DEBUGBreak break:$$$debugIsON

/// Set sc to the given expression, if the result is an error, log it to the debug log.
#define DEBUGSC(%sc,%expr) s %sc=%expr i $$$ISERR(%sc) $$$DEBUG(##Quote(%expr)_" "_$SYSTEM.Status.GetErrorText(%sc))

#;----------- Macros used by the test harness to turn debugging on/off ----------------

/// create a new debugger instance.
#define DEBUGNew(%class) n $$$debugObject $$$DEBUGSetup(%class)

#define DEBUGSetup(%class) s $$$debugObject=$s($isobject(%class):%class,1:$system.OBJ.New($s(%class'="":%class,1:"PXW.Debuggers.Basic")))

/// No need to stop like this if you are using DEBUGNew, as the debugger will disappear on quit.
#define DEBUGStop k $$$debugObject

/// Pause debug so it can be resumed later
#define DEBUGPause i $$$debugIsON { s pxwdebpaused=$$$debugObject $$$DEBUGStop }

/// Resume debug
#define DEBUGResume i $ISOBJECT($g(pxwdebpaused)) { s $$$debugObject=pxwdebpaused k pxwdebpaused }

#define debugIsON $isobject($g($$$debugObject))

#define debugObject %pxwdeb

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#Else
#define DEBUG(%message) 
#define DEBUGTEXT(%message) 
#define DEBUGMethodBegin 
#define DEBUGMethodEnd 
#define DEBUGStack
#define DEBUGBreak 
#define DEBUGSC(%sc,%expr) s %sc=%expr
#define DEBUGNew(%class) 
#define DEBUGSetup(%class) 
#define DEBUGStop  
#define DEBUGPause
#define DEBUGResume
#define debugIsON 0
#define debugObject %pxwdeb
#EndIf

/// Format text, text can contain {var}, eg "value of a={a}, value of b={b}" will be expanded to the code to include that string, not calling a routine/class to do formatting for speed and availability of vars
/// To get double quotes in your output then put '' in the text. EG. $$$debugFormat("string=''{string}''") will give the output string="the value of string".
/// This is useful enough to be included if debug is switched on or off.
/// It may be wise to move this to a separate method/routine rather than a complex 1 liner. 
#define debugFormat(%text) ##safeexpression($xecute("(t,q,o,c,y,z,qq) s f=q_$replace(t,qq,q_q)_q while f[o { s v=$p($p(f,c,1),o,2),a=$p(f,o,1),b=$p(f,c,2,*),d=q_y_v_z_q,f=a_d_b} q f",%text,$c(34),"{","}","_(",")_","''"))