# Defineix el camí del fitxer amb els dominis
$filePath = "C:\ruta\a\domains.txt"

# Comprova si el fitxer existeix
if (Test-Path $filePath) {
    # Llegeix tot el fitxer
    $lines = Get-Content -Path $filePath

    # Variable per emmagatzemar el tipus de registre actual
    $recordType = ""

    # Bucle per a cada línia del fitxer
    foreach ($line in $lines) {
        # Comprova si la línia defineix un nou tipus de registre
        if ($line -match "^Registres tipus (\w+)") {
            # Actualitza el tipus de registre actual
            $recordType = $matches[1]
            Write-Output "Tipus de registre actual: $recordType"
        } 
        # Si no és una línia de tipus de registre, assumeix que és una entrada de domini
        elseif ($line.Trim() -ne "") {
            Write-Output "Resultat de nslookup per a $line ($recordType):"
            
            # Executa nslookup segons el tipus de registre
            switch ($recordType) {
                "A"       { nslookup -type=A $line }
                "CNAME"   { nslookup -type=CNAME $line }
                "MX"      { nslookup -type=MX $line }
                default   { Write-Output "Tipus de registre desconegut. S'ha omès la consulta per a $line." }
            }
            
            Write-Output "----------------------------------------"
        }
    }
} else {
    Write-Output "El fitxer no existeix. Verifica la ruta."
}
