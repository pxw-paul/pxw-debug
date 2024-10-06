# pxw-debug
This is a set of macros used to aid with debugging code by logging messages at set points in the code.

How often have you written code the logs where your code has got to and trace variable values?
```
    write "at this point x="_x,!
```
Then you have to remove them later. 

These macros replace this sort of thing with 
```
    $$$DEBUG("at this point x="_x)
```

When your code is run the macros will do nothing unless you have turned debug on. To do this call the macro
```
    $$$DEBUGNew("")
```


Once this macro is run the debugging macro will be active.

## How does it work?
The macros only work if ^PXW.Debuggers("ENABLED")=1.

The $$$DEBUGNew macro sets a %variable to an object.

The $$$DEBUG macro checks the variable is set, if it is then calls the .DEBUG() method.

## What happens to the message?
The $$$DEBUGNew("") macro by default sets the object to PXW.Debuggers.Basic which will just write the message to the current device.
You could instead use another debug log that creates a file and writes the message there.
```
    $$$DEBUGNew("PXW.Debuggers.BasicToFile")
```
See the class itself to see how to control where the files go.

## Debug to other places.
You could put your debug messages to anywhere you like simply by creating a subclass of PXW.Debuggers.Basic and overwrite the DEBUG method. Eg. it would be very simple to log the messages in a global or database. 

## Example usage.
This is best used in a test harness where the test sets up the debug to use and calls the method being tested. The output from the debug can be checked. When the method runs for real no debug output will be generated because the debug will not be on. 

The test harness:
```
Include PXW.Debuggers.Macros

classmethod RunTest(DebugTo="") {

    if DebugTo="FILE" {
        set deblog="PXW.Debuggers.BasicToFile"
    } elseif DebugTo="SCREEN" {
        set deblog="PXW.Debuggers.Basic"
    } else {
        set deblog=""
    }
    if deblog'="" $$$DEBUGNew(deblog)

    set object=##class(PXW.Debuggers.UnitTests.Example).%New()
    do object.MethodContainingMacros()
    
    if $$$debugIsON zw $$$debugObject
    $$$DEBUGStop
}
```
The code where logging is required:
```
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
```
## Finally
Because the marcos are constantly checking for the existence of an object even when there is no active debugger they take a little bit of time.

Once all the debugging is done you can disable all the macros with:
```
SET ^PXW.Debuggers("ENABLED")=0
or
KILL ^PXW.Debuggers("ENABLED")
```
Then recompile everything. The macros will then not compile any code and will add that little bit more speed.

Note to self: After a bit of to-ing and fro-ing I decided on ENABLING rather than DISABLING, but that may change...

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation

Clone/git pull the repo into any local directory

```
$ git clone https://github.com/intersystems-community/intersystems-iris-dev-template.git
```

Open the terminal in this directory and call the command to build and run InterSystems IRIS in container:
*Note: Users running containers on a Linux CLI, should use "docker compose" instead of "docker-compose"*
*See [Install the Compose plugin](https://docs.docker.com/compose/install/linux/)*



```
$ docker-compose up -d
```

To open IRIS Terminal do:

```
$ docker-compose exec iris iris session iris -U IRISAPP
IRISAPP>
```

To exit the terminal, do any of the following:

```
Enter HALT or H (not case-sensitive)
```



## Running unit tests

Use ZPM to run the tests
```
zpm:IRISAPP>test pxw-debug

[IRISAPP|pxw-debug]     Reload START (/home/irisowner/dev/)
[IRISAPP|pxw-debug]     Reload SUCCESS
[pxw-debug]     Module object refreshed.
[IRISAPP|pxw-debug]     Validate START
[IRISAPP|pxw-debug]     Validate SUCCESS
[IRISAPP|pxw-debug]     Compile START
[IRISAPP|pxw-debug]     Compile SUCCESS
[IRISAPP|pxw-debug]     Activate START
[IRISAPP|pxw-debug]     Configure START
[IRISAPP|pxw-debug]     Configure SUCCESS
[IRISAPP|pxw-debug]     Activate SUCCESS
[IRISAPP|pxw-debug]     Test START
Use the following URL to view the result:
http://172.23.0.4:52773/csp/sys/%25UnitTest.Portal.Indices.cls?Index=5&$NAMESPACE=IRISAPP
All PASSED

[IRISAPP|pxw-debug]     Test SUCCESS
```
The test cover the basic and the basic to file classes. The tests use all of the macros available the. 
