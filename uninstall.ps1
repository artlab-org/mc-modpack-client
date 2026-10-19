# artlab MC modpack uninstall (Windows)
$ErrorActionPreference = "Stop"
$MODS_DIR = "$env:APPDATA\.minecraft\mods"
$SLUGS = @("fabric-api","sodium","iris","lithium","ferrite-core","krypton","modmenu","cloth-config","distanthorizons","fabric-language-kotlin","viafabric","chunky")

Write-Host "Suppression des mods artlab de $MODS_DIR"
foreach ($slug in $SLUGS) {
    Get-ChildItem -Path $MODS_DIR -Filter "*$slug*" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  Remove $($_.Name)"
        Remove-Item $_.FullName -Force
    }
}
Write-Host "Done. Redemarre ton launcher."
