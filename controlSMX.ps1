function AfegirMissatgeAlFitxer {
    param (
        [string]$nomFitxer,
        [string]$missatgeRebut
    )
    $dataExecucio = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $nomFitxer -Value "$dataExecucio : $missatgeRebut"
}

# Detecta si l'script s'està executant en mode de consola
if (-not $Host.UI.RawUI) {
    # Rellança l'script en mode de consola visible
    Start-Process powershell -ArgumentList "-NoExit", "-File `"$PSCommandPath`""
    exit
}

# Defineix la URL base per descarregar fitxers i la ubicació del fitxer de configuració
$urlBase = "https://joanpardogine.github.io/fitxers-smx2/"
$destinacioBase = "C:\SMX-Alumnes"
$desktopPath = [System.Environment]::GetFolderPath("Desktop")
$scriptPath = "$destinacioBase\controlSMX.ps1"

# Crea un accés directe a l'script a l'escriptori si no existeix
# $shortcutPath = "$desktopPath\controlSMX.lnk"
# if (!(Test-Path -Path $shortcutPath)) {
#     $wshell = New-Object -ComObject WScript.Shell
#     $shortcut = $wshell.CreateShortcut($shortcutPath)
#     $shortcut.TargetPath = $scriptPath
#     $shortcut.WorkingDirectory = $destinacioBase
#     $shortcut.WindowStyle = 1
#     $shortcut.Description = "Executa el script controlSMX"
#     $shortcut.Save()
#     Write-Output "S'ha creat un accés directe a l'escriptori per l'script controlSMX."
# }

# Defineix els fitxers necessaris i la carpeta de registres
$configFile = "$destinacioBase\Registres\config.txt"
$logFile = "$destinacioBase\Registres\log.txt"

# Crea la carpeta de registres si no existeix
if (!(Test-Path -Path "$destinacioBase\Registres")) {
    New-Item -ItemType Directory -Path "$destinacioBase\Registres"
}

# Si el fitxer config.txt existeix, mostra el missatge de notificació i surt
if (Test-Path $configFile) {
    $config = Get-Content $configFile -Raw
    Write-Output "Hola, $config! Ja has executat aquest script prèviament."
    Read-Host "Prem qualsevol tecla per sortir..."
    exit
}

# Descarrega el fitxer nomsAlumnes.txt
$nomsAlumnesFile = "$destinacioBase\nomsAlumnes.txt"
if (!(Test-Path -Path $nomsAlumnesFile)) {
    $urlFitxer = "$urlBase/nomsAlumnes.txt"
    Invoke-WebRequest -Uri $urlFitxer -OutFile $nomsAlumnesFile -ErrorAction Stop
    Write-Output "S'ha descarregat el fitxer nomsAlumnes.txt a $nomsAlumnesFile"
}

# Mostra la llista d'alumnes i permet que l'usuari seleccioni el seu nom
$nomsAlumnes = Import-Csv -Path $nomsAlumnesFile -Delimiter ','
Write-Output "Selecciona el teu nom d'entre els següents alumnes"
for ($i = 0; $i -lt $nomsAlumnes.Count; $i++) {
    Write-Output "$($i + 1) - $($nomsAlumnes[$i].'NomAlumne') $($nomsAlumnes[$i].'CognomAlumne')"
}

$index = Read-Host "Introdueix el número corresponent al teu nom: "
$alumneSeleccionat = $nomsAlumnes[$index - 1]

# Guarda el nom de l'alumne al fitxer config.txt per controlar l'execució
Set-Content -Path $configFile -Value "$($alumneSeleccionat.'NomAlumne') $($alumneSeleccionat.'CognomAlumne')"
Write-Output "Benvingut, $($alumneSeleccionat.'NomAlumne') $($alumneSeleccionat.'CognomAlumne')! La teva configuració s'ha registrat correctament."

# Crea estructura de carpetes per l'alumne
$carpetaAlumne = "$destinacioBase\Alumnes\$($alumneSeleccionat.'Nom carpeta')"
if (!(Test-Path -Path $carpetaAlumne)) {
    New-Item -ItemType Directory -Path $carpetaAlumne
    Write-Output "S'ha creat la carpeta per l'alumne a $carpetaAlumne"
}


$missatge = $"Script executat per $($alumneSeleccionat.'NomAlumne') $($alumneSeleccionat.'CognomAlumne')"

Write-Output "$logFile = {$logFile}"
Write-Output "$alumneSeleccionat = {$alumneSeleccionat}"
Write-Output "$cadena = {$cadena}"

AfegirMissatgeAlFitxer -nomFitxer $logFile -missatge $missatge

# Descarrega i executa Bginfo64.exe amb el fitxer de configuració
$bgInfoExe = "$destinacioBase\Bginfo64.exe"
$bgInfoConfig = "$destinacioBase\smx2.bgi"

if (!(Test-Path -Path $bgInfoExe)) {
    Invoke-WebRequest -Uri "$urlBase/Bginfo64.exe" -OutFile $bgInfoExe -ErrorAction Stop
    Write-Output "S'ha descarregat el fitxer Bginfo64.exe"
}
if (!(Test-Path -Path $bgInfoConfig)) {
    Invoke-WebRequest -Uri "$urlBase/smx2.bgi" -OutFile $bgInfoConfig -ErrorAction Stop
    Write-Output "S'ha descarregat el fitxer smx2.bgi"
}

# Executa Bginfo amb la configuració especificada
Start-Process -FilePath $bgInfoExe -ArgumentList "$bgInfoConfig /timer:0" -NoNewWindow
Write-Output "Bginfo s'ha executat correctament amb la configuració especificada."

# Espera que l'usuari premi una tecla abans de tancar la finestra de consola
Read-Host "Prem qualsevol tecla per sortir..."
