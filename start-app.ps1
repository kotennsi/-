$ErrorActionPreference = 'Stop'
$appRoot = [System.IO.Path]::GetFullPath($PSScriptRoot)
$port = 8765
$baseUrl = "http://127.0.0.1:$port/"
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $port)
$contentTypes = @{
  '.html' = 'text/html; charset=utf-8'
  '.js' = 'text/javascript; charset=utf-8'
  '.webmanifest' = 'application/manifest+json; charset=utf-8'
  '.svg' = 'image/svg+xml'
  '.png' = 'image/png'
  '.css' = 'text/css; charset=utf-8'
}

try {
  $listener.Start()
  Write-Host "計算室を起動しました: $baseUrl"
  Write-Host 'この画面を閉じると、アプリ用のローカルサーバーが停止します。'
  Start-Process $baseUrl
  while ($true) {
    $client = $listener.AcceptTcpClient()
    try {
      $stream = $client.GetStream()
      $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::ASCII, $false, 1024, $true)
      $requestLine = $reader.ReadLine()
      while (($header = $reader.ReadLine()) -ne '') { if ($null -eq $header) { break } }
      $parts = $requestLine -split ' '
      if ($parts.Count -lt 2 -or $parts[0] -ne 'GET') {
        $status = '405 Method Not Allowed'
        $bytes = [System.Text.Encoding]::UTF8.GetBytes('Method not allowed')
        $mime = 'text/plain; charset=utf-8'
      } else {
        $requestPath = $parts[1].Split('?')[0]
        $relativePath = [System.Uri]::UnescapeDataString($requestPath.TrimStart('/'))
        if ([string]::IsNullOrWhiteSpace($relativePath)) { $relativePath = 'index.html' }
        $filePath = [System.IO.Path]::GetFullPath((Join-Path $appRoot $relativePath))
        $rootPrefix = $appRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
        $outsideRoot = $filePath.IndexOf($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase) -ne 0
        $fileExists = Test-Path -LiteralPath $filePath -PathType Leaf
        if ($outsideRoot -or -not $fileExists) {
          $status = '404 Not Found'
          $bytes = [System.Text.Encoding]::UTF8.GetBytes('Not found')
          $mime = 'text/plain; charset=utf-8'
        } else {
          $status = '200 OK'
          $extension = [System.IO.Path]::GetExtension($filePath).ToLowerInvariant()
          $mime = 'application/octet-stream'
          if ($contentTypes.ContainsKey($extension)) { $mime = $contentTypes[$extension] }
          $bytes = [System.IO.File]::ReadAllBytes($filePath)
        }
      }
      $extraHeaders = ""
      if ($parts.Count -gt 1 -and $parts[1].StartsWith("/sw.js")) { $extraHeaders = "Service-Worker-Allowed: /`r`nCache-Control: no-cache`r`n" }
      $headerText = "HTTP/1.1 $status`r`nContent-Type: $mime`r`nContent-Length: $($bytes.Length)`r`nConnection: close`r`n$extraHeaders`r`n"
      $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($headerText)
      $stream.Write($headerBytes, 0, $headerBytes.Length)
      $stream.Write($bytes, 0, $bytes.Length)
      $stream.Flush()
    } catch {
      Write-Host "リクエストを処理できませんでした: $($_.Exception.Message)"
    } finally {
      if ($reader) { $reader.Dispose() }
      $client.Dispose()
    }
  }
} finally {
  $listener.Stop()
}
