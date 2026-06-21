@echo off
set BASENAME=game
set PROJECT_DIR=d:\COAL_Project_Phase1
set DOSBOX_EXE=D:\Visa_Agency\DOSBox-0.74-3\DOSBox.exe

echo Launching DOSBox for %BASENAME%.asm...
echo Close the DOSBox window when you are done to automatically clean up!

REM Create a temporary DOS batch file to handle compilation inside DOSBox
(
    echo d:\8086\MASM.EXE %BASENAME%.asm, %BASENAME%.obj; ^> build.log
    echo d:\8086\LINK.EXE %BASENAME%.obj; ^>^> build.log
    echo type build.log
    echo if errorlevel 1 goto done
    echo %BASENAME%.exe
    echo :done
) > run_temp.bat

start /wait "" "%DOSBOX_EXE%" ^
    -c "mount d %PROJECT_DIR%" ^
    -c "d:" ^
    -c "run_temp.bat"

echo.
echo ====== DOSBOX COMPILER OUTPUT ======
if exist build.log type build.log
echo ====================================
echo.

echo Cleaning up generated files for %BASENAME%...
if exist "%BASENAME%.obj" del "%BASENAME%.obj"
if exist "%BASENAME%.exe" del "%BASENAME%.exe"
if exist "%BASENAME%.MAP" del "%BASENAME%.MAP"
if exist "%BASENAME%.lst" del "%BASENAME%.lst"
if exist "run_temp.bat" del "run_temp.bat"

echo Clean up complete!
