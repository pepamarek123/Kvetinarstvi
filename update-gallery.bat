@echo off
echo === Aktualizace fotogalerie ===
echo.

echo [1/3] Aktualizuji aktuality-data.js z aktuality.txt...
powershell -ExecutionPolicy Bypass -Command "$txt = [System.IO.File]::ReadAllText('%~dp0aktuality.txt', [System.Text.Encoding]::UTF8); $out = '// Automaticky generováno z aktuality.txt skriptem update-gallery.bat`n// Tento soubor slouží jako záloha pro file:// protokol`nconst AKTUALITY_DATA = `'' + $txt.Replace('`'', '\`'') + '`';`n'; [System.IO.File]::WriteAllText('%~dp0aktuality-data.js', $out, [System.Text.Encoding]::UTF8); Write-Host 'aktuality-data.js aktualizovan.'"

echo.
echo [2/3] Aktualizuji gallery-data.js...
powershell -ExecutionPolicy Bypass -Command "$base = '%~dp0img_gallery'; $dirs = @('1dk','2sk','3nk','4sv','5dv','6vs','7hk','8dz','9pu'); $lines = @('const GALLERY_DATA = {'); foreach ($d in $dirs) { $path = Join-Path $base $d; $files = Get-ChildItem $path -File | Where-Object { $_.Name -notmatch 'files\.json' -and $_.Extension -match '\.(jpg|jpeg|png|JPG|JPEG|PNG)' } | Sort-Object { [int]($_.BaseName) } | ForEach-Object { '\"' + $_.Name + '\"' }; $list = $files -join ','; $lines += \"  'img_gallery/$d': [$list],\" }; $lines += '};'; $out = $lines -join \"`n\"; [System.IO.File]::WriteAllText('%~dp0gallery-data.js', $out, [System.Text.Encoding]::UTF8); Write-Host 'gallery-data.js aktualizovan.'"

echo.
echo [3/3] Generuji nahledove obrazky (pouze nove)...
powershell -ExecutionPolicy Bypass -File "%~dp0generate-thumbs.ps1"

echo.
echo === Hotovo! ===
pause
