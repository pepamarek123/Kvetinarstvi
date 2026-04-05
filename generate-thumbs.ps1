Add-Type -AssemblyName System.Drawing

$base   = "$PSScriptRoot\img_gallery"
$dirs   = @('1dk','2sk','3nk','4sv','5dv','6vs','7hk','8dz','9pu')
$width  = 180
$height = 135

$encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
           Where-Object { $_.MimeType -eq 'image/jpeg' }
$params  = New-Object System.Drawing.Imaging.EncoderParameters(1)
$params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
    [System.Drawing.Imaging.Encoder]::Quality, 75L)

foreach ($d in $dirs) {
    $src  = Join-Path $base $d
    $dest = Join-Path $base "thumbs\$d"
    New-Item -Force -ItemType Directory $dest | Out-Null

    $files = Get-ChildItem $src -File | Where-Object { $_.Extension -match '\.(jpg|jpeg|png|JPG|JPEG|PNG)' }
    $total = $files.Count
    $i     = 0

    foreach ($file in $files) {
        $i++
        $outFile = Join-Path $dest $file.Name
        if (Test-Path $outFile) {
            Write-Host "  [$i/$total] Preskakuji: $($file.Name)" -ForegroundColor DarkGray
            continue
        }

        try {
            $img   = [System.Drawing.Image]::FromFile($file.FullName)
            $thumb = New-Object System.Drawing.Bitmap($width, $height)
            $g     = [System.Drawing.Graphics]::FromImage($thumb)
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $g.DrawImage($img, 0, 0, $width, $height)
            $thumb.Save($outFile, $encoder, $params)
            $g.Dispose(); $thumb.Dispose(); $img.Dispose()
            Write-Host "  [$i/$total] OK: $($file.Name)" -ForegroundColor Green
        } catch {
            Write-Host "  [$i/$total] CHYBA: $($file.Name) - $_" -ForegroundColor Red
        }
    }
    Write-Host "Adresar $d hotov." -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Generovani nahledu dokonceno!" -ForegroundColor Yellow
