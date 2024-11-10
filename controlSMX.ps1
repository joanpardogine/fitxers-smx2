# Defineix la URL base per descarregar fitxers
$urlBase = "https://joanpardogine.github.io/fitxers-smx2/"
$destinacioBase = "C:\SMX-Alumnes"

# Crea la carpeta de destí si no existeix
if (!(Test-Path -Path $destinacioBase)) {
    New-Item -ItemType Directory -Path $destinacioBase
}

# Descarrega un fitxer des de l'URL i el guarda en una ubicació local
function Descarregar-Fitxer {
    param (
        [string]$nomFitxer
    )
    $urlFitxer = "$urlBase$nomFitxer"
    $destinacioFitxer = Join-Path -Path $destinacioBase -ChildPath $nomFitxer
    Invoke-WebRequest -Uri $urlFitxer -OutFile $destinacioFitxer -ErrorAction Stop
    Write-Output "S'ha descarregat el fitxer $nomFitxer a $destinacioFitxer"
}

# Descarrega el fitxer nomsAlumnes.txt
Descarregar-Fitxer -nomFitxer "nomsAlumnes.txt"

# Defineix els fitxers i carpetes necessaris
$configFile = "$destinacioBase\Registres\config.txt"
$logFile = "$destinacioBase\Registres\log.txt"

# Crea la carpeta de registres si no existeix
if (!(Test-Path -Path "$destinacioBase\Registres")) {
    New-Item -ItemType Directory -Path "$destinacioBase\Registres"
}

# Funció per carregar els alumnes des de nomsAlumnes.txt
function Carregar-Alumnes {
    Import-Csv -Path "$destinacioBase\nomsAlumnes.txt" -Delimiter ',' | ForEach-Object {
        [PSCustomObject]@{
            Id = $_.Id
            Nom = $_."Nom alumne"
            Cognom = $_."Cognom alumne"
            Carpeta = $_."Nom carpeta"
        }
    }
}

# Comprova si l'alumne ja ha estat seleccionat
if (Test-Path $configFile) {
    # Recupera l'alumne seleccionat anteriorment
    $config = Get-Content $configFile -Raw
    Write-Output "Hola, $config! Ja has estat registrat prèviament."
} else {
    # Mostra el llistat d'alumnes per a la selecció
    $alumnes = Carregar-Alumnes
    Write-Output "Selecciona el teu nom d'entre els següents alumnes:"
    $i = 1
    $alumnes | ForEach-Object {
        Write-Output "$i. $($_.Nom) $($_.Cognom)"
        $i++
    }

    # Llegeix la selecció d'alumne
    $seleccio = Read-Host "Introdueix el número corresponent al teu nom"
    $alumneSeleccionat = $alumnes[$seleccio - 1]

    # Guarda el nom de l'alumne a config.txt
    Set-Content -Path $configFile -Value "$($alumneSeleccionat.Nom) $($alumneSeleccionat.Cognom)"

    # Crea l'estructura de carpetes personalitzada
    $carpetaAlumne = "$destinacioBase\Alumnes\$($alumneSeleccionat.Carpeta)"
    if (!(Test-Path -Path $carpetaAlumne)) {
        New-Item -ItemType Directory -Path "$carpetaAlumne\Documents"
        New-Item -ItemType Directory -Path "$carpetaAlumne\Activitats"
        New-Item -ItemType Directory -Path "$carpetaAlumne\Registres"
        Write-Output "S'ha creat l'estructura de carpetes per a $($alumneSeleccionat.Nom) $($alumneSeleccionat.Cognom)"
    }

    # Registra la primera execució
    $dataExecucio = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "[$dataExecucio] - Primera execució per $($alumneSeleccionat.Nom) $($alumneSeleccionat.Cognom)"
}

# Registra la data i hora de l'execució
$dataExecucio = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $logFile -Value "[$dataExecucio] - Execució de l'script per $config"

Write-Output "Execució registrada correctament."
