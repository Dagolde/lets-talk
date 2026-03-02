@echo off
echo Cleaning up temporary files to free disk space...

echo Cleaning Flutter build cache...
if exist "mobile\build" rmdir /s /q "mobile\build"
if exist "mobile\.dart_tool" rmdir /s /q "mobile\.dart_tool"

echo Cleaning Laravel cache...
if exist "backend\bootstrap\cache" rmdir /s /q "backend\bootstrap\cache"
if exist "backend\storage\logs" del /q "backend\storage\logs\*.log"

echo Cleaning Windows temp files...
del /q /f "%TEMP%\*.*" 2>nul
del /q /f "%TEMP%\*" 2>nul

echo Cleaning Flutter temp files...
if exist "%LOCALAPPDATA%\Temp\flutter_tools*" rmdir /s /q "%LOCALAPPDATA%\Temp\flutter_tools*"

echo Disk cleanup completed!
echo.
echo Available disk space:
wmic logicaldisk get size,freespace,caption

pause
