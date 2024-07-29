@echo off
setlocal
for /f "tokens=2 delims=:" %%i in ('chcp') do set "CP=%%~i"
set "CP=%CP:~1%"
chcp 65001>nul

for /f "tokens=3 skip=1" %%i in ('reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Nls\Language /v Default') do set "LANGID=%%~i"
if "%LANGID%"=="0419" ( set "LANG=ru" ) else ( set "LANG=en" )

set "A1={BD7A2E7B-21CB-41b2-A086-B309680C6B7E}"
set "A2={3134ef9c-6b18-4996-ad04-ed5912e00eb5}"
set "A3={437ff9c0-a07f-4fa0-af80-84b6c6440a16}"
set "ACT="
set "FOLD="

:argloop
	if "%~1"=="/?" call :PrintHelp_%LANG% & goto :exit
	if "%~1"=="/l" call :PrintActions_%LANG% & goto :exit
	if "%~1"=="/a" set "ACT=%~2" & shift /1
	if "%~1"=="/f" set "FOLD=%~2" & shift /1
	if "%~1"=="/o" call :OpenFolder "%~2" & goto :exit
if not "%~1"=="" shift /1 & goto :argloop

if "%ACT%"=="" call :PrintActions_%LANG% & choice /c 1234 > nul & call set ACT=%%ERRORLEVEL%%
echo.
if "%FOLD%"=="" if "%LANG%"=="en" set /p "FOLD=Folder path: "
if "%FOLD%"=="" if "%LANG%"=="ru" set /p "FOLD=Путь к папке: "

if "%ACT%"=="4" call :RecycleBin "%FOLD%" & goto :exit

call set "EXT=.%%A%ACT%%%"
if exist "%FOLD%\" ( move "%FOLD%" "%FOLD%%EXT%">nul ) else ( md "%FOLD%%EXT%">nul ) 

:exit
chcp %CP%>nul
exit /b

:PrintActions_en
	echo.[1] Unopenable folder
	echo.[2] Immutable folder ^(renaming and deletion options disabled^)
	echo.[3] Command folder
	echo.[4] Recycle bin folder
goto :eof

:PrintActions_ru
	echo.[1] Неоткрываемая папка
	echo.[2] Неизменяемая папка ^(опции переименования и удаления отключены^)
	echo.[3] Папка команд
	echo.[4] Папка корзины
goto :eof


:PrintHelp_en
	echo.Usage: %~n0 [/a ^<action^>] [/f ^<folder^>]
	echo.
	echo.               /a ^<action^>    Specifies the action to be invoked.
	echo.               /f ^<folder^>    Specifies the path to the folder.
	echo.                              If the folder exists, it will be renamed; otherwise it will be created.
	echo.
	echo.       %~n0 /l
	echo.
	echo.               Prints available actions.
	echo.
	echo.       %~n0 /o ^<folder^>
	echo.
	echo.               Renames the folder so that Explorer can open it, and opens it.
goto :eof

:PrintHelp_ru
	echo.Использование: %~n0 [/a ^<действие^>] [/f ^<папка^>]
	echo.
	echo.                       /a ^<действие^>   Указывает действие, которое необходимо выполнить.
	echo.                       /f ^<папка^>      Указывает путь к папке.
	echo.                                       Если папка существует, она будет переименована, иначе она будет создана.
	echo.
	echo.               %~n0 /l
	echo.
	echo.                       Выводит доступные действия.
	echo.
	echo.               %~n0 /o ^<folder^>
	echo.
	echo.                       Переименовывает папку так, чтобы Проводник смог открыть её, и открывает её.
goto :eof

:OpenFolder
	if exist "%~1\desktop.ini" call :OpenRbFolder "%~1" & goto :eof
	set "FOLD=%~dpn1"
	set "EXT=%~x1"
	set "PREF=_wfutil_%RANDOM%%RANDOM%%RANDOM%"
	move "%FOLD%%EXT%" "%FOLD%%PREF%">nul
	explorer "%FOLD%%PREF%"
	if "%LANG%"=="en" echo.Press any key to rename the folder back...
	if "%LANG%"=="ru" echo.Нажмите любую клавишу, чтобы переименовать папку обратно...
	pause>nul
	move "%FOLD%%PREF%" "%FOLD%%EXT%">nul
goto :eof

:OpenRbFolder
	attrib -s -h "%~1\desktop.ini"
	move "%~1\desktop.ini" "%~1\desktop.ini.2">nul
	explorer "%~1"
	if "%LANG%"=="en" echo.Press any key to rename the folder back...
	if "%LANG%"=="ru" echo.Нажмите любую клавишу, чтобы переименовать папку обратно...
	pause>nul
	move "%~1\desktop.ini.2" "%~1\desktop.ini">nul
	attrib +s +h "%~1\desktop.ini"
	attrib +r "%~1"
goto :eof

:RecycleBin
	(
		echo.[.ShellClassInfo]
		echo.CLSID={645FF040-5081-101B-9F08-00AA002F954E}
		echo.LocalizedResourceName=@%%SystemRoot%%\system32\shell32.dll,-8964
	)> "%~1\desktop.ini"
	attrib +s +h "%~1\desktop.ini"
	attrib +r "%~1"
goto :eof
