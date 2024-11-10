# Llegeix el fitxer nomsAlumnes.txt i carrega els alumnes
$alumnesFile = "nomsAlumnes.txt"
$configFile = "Registres/config.txt"
$logFile = "Registres/log.txt"

# Crea la carpeta de registres si no existeix
if (!(Test-Path -Path "Registres")) {
    New-Item -ItemType Directory -Path "Registres"
}

# Funció per carregar els alumnes
function Carregar-Alumnes {
    Import-Csv -Path $alumnesFile -Delimiter ',' | ForEach-Object {
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
    # Si l'alumne ja està guardat, el recupera
    $config = Get-Content $configFile -Raw
    Write-Output "Hola, $config! Ja has estat registrat prèviament."
} else {
    # Mostra el llistat d'alumnes
    $alumnes = Carregar-Alumnes
    Write-Output "Selecciona el teu nom d'entre els següents alumnes:"
    $i = 1
    $alumnes | ForEach-Object {
        Write-Output "$i. $($_.Nom) $($_.Cognom)"
        $i++
    }

    # Llegeix la selecció de l'alumne
    $seleccio = Read-Host "Introdueix el número corresponent al teu nom"
    $alumneSeleccionat = $alumnes[$seleccio - 1]

    # Guarda el nom de l'alumne al fitxer de configuració
    Set-Content -Path $configFile -Value "$($alumneSeleccionat.Nom) $($alumneSeleccionat.Cognom)"

    # Crea l'estructura de carpetes
    $carpetaAlumne = "Alumnes\$($alumneSeleccionat.Carpeta)"
    if (!(Test-Path -Path $carpetaAlumne)) {
        New-Item -ItemType Directory -Path "$carpetaAlumne\Documents"
        New-Item -ItemType Directory -Path "$carpetaAlumne\Activitats"
        New-Item -ItemType Directory -Path "$carpetaAlumne\Registres"
        Write-Output "S'ha creat l'estructura de carpetes per a $($alumneSeleccionat.Nom) $($alumneSeleccionat.Cognom)"
    }

    # Registra l'execució al fitxer de log
    $dataExecucio = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "[$dataExecucio] - Primera execució per $($alumneSeleccionat.Nom) $($alumneSeleccionat.Cognom)"
}

# Registra la data i hora de l'execució
$dataExecucio = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $logFile -Value "[$dataExecucio] - Execució de l'script per $config"

Write-Output "Execució registrada correctament."
