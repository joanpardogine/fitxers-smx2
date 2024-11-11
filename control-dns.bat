@echo off
setlocal enabledelayedexpansion

REM Defineix el camí del fitxer amb els dominis
set "filePath=C:\ruta\a\domains.txt"

REM Comprova si el fitxer existeix
if not exist "%filePath%" (
    echo El fitxer no existeix. Verifica la ruta.
    exit /b
)

REM Variables
set "recordType="

REM Llegeix el fitxer línia per línia
for /f "tokens=*" %%A in (%filePath%) do (
    set "line=%%A"

    REM Comprova si la línia defineix un nou tipus de registre
    echo !line! | findstr /b /c:"Registres tipus" >nul
    if !errorlevel! == 0 (
        REM Extreu el tipus de registre
        for /f "tokens=3" %%B in ("!line!") do set "recordType=%%B"
        echo Tipus de registre actual: !recordType!
    ) else (
        REM Si la línia no està buida, assumeix que és una entrada de domini
        if not "!line!" == "" (
            echo Resultat de nslookup per a !line! (!recordType!):

            REM Executa nslookup segons el tipus de registre
            if "!recordType!" == "A" (
                nslookup -type=A !line!
            ) else if "!recordType!" == "CNAME" (
                nslookup -type=CNAME !line!
            ) else if "!recordType!" == "MX" (
                nslookup -type=MX !line!
            ) else (
                echo Tipus de registre desconegut. S'ha omès la consulta per a !line!.
            )

            echo ----------------------------------------
        )
    )
)
endlocal
