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
The $$$DEBUGNew macro sets a %variable to an object.

The $$$DEBUG macro checks the variable is set, if it is then the .DEBUG() method.

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

```
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
Method MethodContainingMacros()
{
    $$$DEBUGMethodBegin
    write "running method",!
    Set x=1
    $$$DEBUG("x="_x) 
    write "ending method",!
    $$$DEBUGMethodEnd
}
```
The test harness





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
