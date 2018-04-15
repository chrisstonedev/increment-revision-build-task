@ECHO off

REM Require directory parameter.
IF "%1"=="" (
  ECHO You must pass the directory containing AssemblyInfo.cs as a parameter.
  GOTO :EOF
)
SET DIRECTORY=%1

REM Append a backslash if one is not already the last character of the provided parameter.
IF "%DIRECTORY:~-1%" NEQ "\" (SET DIRECTORY=%DIRECTORY%\)

REM Set file path variables.
SET INPUTFILE=%DIRECTORY%AssemblyInfo.cs
SET OUTPUTFILE=%DIRECTORY%AssemblyInfo.tmp

REM Find the line in the assembly info that refers to the file version and store the line contents.
FOR /F "tokens=4 delims=." %%A IN ('FIND "AssemblyFileVersion" %INPUTFILE%') DO SET ENDOFREVISIONLINE=%%A

REM Remove an expected double quote in the string.
SET ENDOFREVISIONLINE=%ENDOFREVISIONLINE:"=%

REM Isolate the revision number by itself.
FOR /F "tokens=1 delims=)" %%A IN ("%ENDOFREVISIONLINE%") DO SET OLDREVISION=%%A

REM The new version is incremented by one.
SET /A NEWREVISION=%OLDREVISION%+1

REM Fetch the template for the new and old lines.
FOR /F "tokens=1,2,3 delims=." %%A IN ('FIND "AssemblyFileVersion" %INPUTFILE%') DO SET LINETEMPLATE=%%A.%%B.%%C.

REM Store a value to be the expected line in the file...
SET OLDLINE=%LINETEMPLATE%%OLDREVISION%")]

REM ...but then remove quotes from it to make the string comparison work better later.
SET OLDLINE=%OLDLINE:"=%

REM Store a value to be the new line needed in the file.
SET NEWLINE=%LINETEMPLATE%%NEWREVISION%")]

REM Create a new file based on the contents of the existing file.
REM If the line matches the expected string we are to replace, use the new line.
REM Otherwise, use the line as it is found in the original file.
>"%OUTPUTFILE%" (
  FOR /F "tokens=*" %%A IN ('TYPE %INPUTFILE% ^| FIND /v ""') DO (
    SET CURRENTLINE=%%A
    SETLOCAL ENABLEDELAYEDEXPANSION
    SET CURRENTLINE=!CURRENTLINE:^"=!
    IF "!CURRENTLINE!"=="%OLDLINE%" (ECHO !NEWLINE!) ELSE (ECHO %%A)
    ENDLOCAL
  )
)

REM Replace the original AssemblyInfo.cs file with the new one created.
MOVE /Y %OUTPUTFILE% %INPUTFILE%