# Defineix la URL base per descarregar fitxers
$urlBase = "https://joanpardogine.github.io/fitxers-smx2/"
$destinacioBase = "C:\SMX-Alumnes"
$desktopPath = [System.Environment]::GetFolderPath("Desktop")
$scriptPath = "$desktopPath\controlSMX.ps1"

# Crea la carpeta de destí si no existeix
if (!(Test-Path -Path $destinacioBase)) {
    New-Item -ItemType Directory -Path $destinacioBase
}

# Col·loca l'script a l'escriptori de l'alumne si no hi és
if (!(Test-Path -Path $scriptPath)) {
    Copy-Item -Path $MyInvocation.MyCommand.Path -Destination $scriptPath -Force
    Write-Output "L'script s'ha col·locat a l'escriptori per a futures execucions."
}

# Descarrega un fitxer des de l'URL i el guarda en una ubicació local
function Descarregar-Fitxer {
    param (
        [string]$nomFitxer
    )
    $urlFitxer = "$urlBase$nomFitxer"
    $destinacioFitxer = Join-Path -Path $destinacioBase -ChildPath $nomFitxer
    try {
        Invoke-WebRequest -Uri $urlFitxer -OutFile $destinacioFitxer -ErrorAction Stop
        Write-Output "S'ha descarregat el fitxer $nomFitxer a $destinacioFitxer"
    } catch {
        Write-Output "Error: No s'ha pogut descarregar el fitxer $nomFitxer de $urlFitxer"
    }
}

# Descarrega els fitxers necessaris
Descarregar-Fitxer -nomFitxer "nomsAlumnes.txt"
Descarregar-Fitxer -nomFitxer "Bginfo64.exe"
Descarregar-Fitxer -nomFitxer "smx2.bgi"

# Defineix els fitxers i carpetes necessaris
$configFile = "$destinacioBase\Registres\config.txt"
$logFile = "$destinacioBase\Registres\log.txt"

# Crea la carpeta de registres si no existeix
if (!(Test-Path -Path "$destinacioBase\Registres")) {
    New-Item -ItemType Directory -Path "$destinacioBase\Registres"
}

# Si el fitxer config.txt existeix, mostra un missatge de notificació
if (Test-Path $configFile) {
    $config = Get-Content $configFile -Raw
    Write-Output "Hola, $config! Ja has estat registrat prèviament."
    [System.Windows.Forms.MessageBox]::Show("Hola, $config! Ja has executat aquest script prèviament.", "Atenció", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    exit
}

# Carrega els alumnes des de nomsAlumnes.txt
function Carregar-Alumnes {
    $fitxerAlumnes = "$destinacioBase\nomsAlumnes.txt"
    if (Test-Path -Path $fitxerAlumnes) {
        Import-Csv -Path $fitxerAlumnes -Delimiter ',' | ForEach-Object {
            [PSCustomObject]@{
                Id = $_.Id
                Nom = $_."Nom alumne"
                Cognom = $_."Cognom alumne"
                Carpeta = $_."Nom carpeta"
            }
        }
    } else {
        Write-Output "Error: El fitxer nomsAlumnes.txt no existeix a $fitxerAlumnes."
    }
}

# Selecció de l'alumne i creació de la carpeta
$alumnes = Carregar-Alumnes
if ($alumnes) {
    Write-Output "Selecciona el teu nom d'entre els següents alumnes:"
    $i = 1
    $alumnes | ForEach-Object {
        Write-Output "$i. $($_.Nom) $($_.Cognom)"
        $i++
    }

    $seleccio = Read-Host "Introdueix el número corresponent al teu nom"
    $alumneSeleccionat = $alumnes[$seleccio - 1]

    Set-Content -Path $configFile -Value "$($alumneSeleccionat.Nom) $($alumneSeleccionat.Cognom)"

    $carpetaAlumne = "$destinacioBase\Alumnes\$($alumneSeleccionat.Carpeta)"
    if (!(Test-Path -Path $carpetaAlumne)) {
        New-Item -ItemType Directory -Path "$carpetaAlumne\Documents"
        New-Item -ItemType Directory -Path "$carpetaAlumne\Activitats"
        New-Item -ItemType Directory -Path "$carpetaAlumne\Registres"
        Write-Output "S'ha creat l'estructura de carpetes per a $($alumneSeleccionat.Nom) $($alumneSeleccionat.Cognom)"
    }

    $dataExecucio = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "[$dataExecucio] - Primera execució per $($alumneSeleccionat.Nom) $($alumneSeleccionat.Cognom)"
}

# Executa Bginfo amb la configuració smx2.bgi
$bginfoPath = Join-Path -Path $destinacioBase -ChildPath "Bginfo64.exe"
$configPath = Join-Path -Path $destinacioBase -ChildPath "smx2.bgi"
Start-Process -FilePath $bginfoPath -ArgumentList "$configPath /timer:0" -NoNewWindow

$dataExecucio = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $logFile -Value "[$dataExecucio] - Execució de l'script per $config"

Write-Output "Execució registrada correctament."
