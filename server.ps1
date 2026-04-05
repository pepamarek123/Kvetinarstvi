$port = if ($env:PORT) { $env:PORT } else { 8080 }
$root = $PSScriptRoot

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".png"  = "image/png"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".json" = "application/json"
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Server running at http://localhost:$port/"

while ($listener.IsListening) {
    $context  = $listener.GetContext()
    $request  = $context.Request
    $response = $context.Response
    $response.Headers.Add("Access-Control-Allow-Origin", "*")

    $localPath = $request.Url.LocalPath

    # ── API: výpis souborů v adresáři ──
    if ($localPath -eq "/api/list") {
        $dirParam = $request.QueryString["path"]
        # Bezpečnostní kontrola – žádné '..'
        if ($dirParam -and $dirParam -notmatch "\.\.") {
            $dirFull = Join-Path $root ($dirParam.Replace("/", "\"))
            if (Test-Path $dirFull -PathType Container) {
                $exts = @(".jpg", ".jpeg", ".png", ".gif", ".JPG", ".JPEG", ".PNG")
                $files = Get-ChildItem $dirFull | Where-Object {
                    $exts -contains $_.Extension
                } | Sort-Object Name | ForEach-Object { $_.Name }
                $fileList = ($files | ForEach-Object { "`"$_`"" }) -join ","
                $json = "[$fileList]"
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
                $response.ContentType     = "application/json"
                $response.ContentLength64 = $bytes.Length
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            } else {
                $response.StatusCode = 404
            }
        } else {
            $response.StatusCode = 400
        }
        $response.Close()
        continue
    }

    # ── Statické soubory ──
    if ($localPath -eq "/") { $localPath = "/index.html" }
    $filePath = Join-Path $root ($localPath.TrimStart("/").Replace("/", "\"))

    if (Test-Path $filePath -PathType Leaf) {
        $ext  = [System.IO.Path]::GetExtension($filePath).ToLower()
        $mime = if ($mimeTypes[$ext]) { $mimeTypes[$ext] } else { "application/octet-stream" }
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $response.ContentType     = $mime
        $response.ContentLength64 = $bytes.Length
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $response.StatusCode = 404
    }

    $response.Close()
}
