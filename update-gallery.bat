@echo off
echo Aktualizuji gallery-data.js...
powershell -ExecutionPolicy Bypass -Command ^
  "$base = '%~dp0img_gallery'; $dirs = @('1dk','2sk','3nk','4sv','5dv','6vs','7hk','8dz','9pu'); $lines = @('const GALLERY_DATA = {'); foreach ($d in $dirs) { $path = Join-Path $base $d; $files = Get-ChildItem $path -File | Where-Object { $_.Name -ne 'files.json' } | Sort-Object { [int]($_.BaseName) } | ForEach-Object { '\"' + $_.Name + '\"' }; $list = $files -join ','; $lines += \"  'img_gallery/$d': [$list],\" }; $lines += '};'; $out = $lines -join \"`n\"; [System.IO.File]::WriteAllText('%~dp0gallery-data.js', $out, [System.Text.Encoding]::UTF8); Write-Host 'Hotovo!'"
echo.
echo gallery-data.js byl aktualizovan.
pause
