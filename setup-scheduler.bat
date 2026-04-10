@echo off
chcp 65001 >nul
echo ============================================================
echo  Nastaveni automatickeho spousteni update-gallery.bat
echo ============================================================
echo.

:: Nastaveni
set TASK_NAME=KvetinarstviUpdate
set SCRIPT_PATH=C:\Users\pepa\Repository\Kvetinarstvi\update-gallery.bat

:: Smazat starou ulohu pokud existuje
schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1

:: Vytvorit novou ulohu – spustit kazde 2 hodiny, kazdy den
schtasks /create ^
  /tn "%TASK_NAME%" ^
  /tr "cmd.exe /c \"%SCRIPT_PATH%\"" ^
  /sc hourly ^
  /mo 2 ^
  /st 08:00 ^
  /du 0016:00 ^
  /ru "%USERNAME%" ^
  /rl HIGHEST ^
  /f

if %errorlevel% equ 0 (
    echo.
    echo [OK] Uloha "%TASK_NAME%" uspesne vytvorena.
    echo      Skript se bude spoustet kazde 2 hodiny od 8:00 do 24:00.
    echo.
    echo  Pro zmenu intervalu spustte tento soubor znovu
    echo  nebo upravte ulohu v "Spravci uloh" systemu Windows.
) else (
    echo.
    echo [CHYBA] Nepodarilo se vytvorit ulohu.
    echo  Zkuste spustit tento soubor jako Administrator:
    echo  Pravym tlacitkem -^> Spustit jako spravce
)

echo.
pause
