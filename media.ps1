param([string]$Action = "watch")

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Runtime.WindowsRuntime

$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
        $_.Name -eq 'AsTask' -and
        $_.GetParameters().Count -eq 1 -and
        $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
    })[0]

function Await($op, $type) {
    $task = $asTaskGeneric.MakeGenericMethod($type).Invoke($null, @($op))
    $task.Wait(-1) | Out-Null
    $task.Result
}

[void][Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager, Windows.Media.Control, ContentType = WindowsRuntime]
$managerType = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager]
$propsType = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionMediaProperties]
$manager = Await ($managerType::RequestAsync()) $managerType

function Get-State {
    $s = $manager.GetCurrentSession()
    if (-not $s) { return @{ active = $false } }
    $p = Await ($s.TryGetMediaPropertiesAsync()) $propsType
    $status = $s.GetPlaybackInfo().PlaybackStatus.ToString()
    return @{
        active  = $true
        title   = $p.Title
        artist  = $p.Artist
        playing = ($status -eq 'Playing')
    }
}

switch ($Action) {
    'watch' {
        while ($true) {
            try {
                $json = Get-State | ConvertTo-Json -Compress
                [Console]::Out.WriteLine($json)
                [Console]::Out.Flush()
            }
            catch {}
            Start-Sleep -Milliseconds 1000
        }
    }
    'toggle' { $s = $manager.GetCurrentSession(); if ($s) { [void](Await ($s.TryTogglePlayPauseAsync()) ([bool])) } }
    'next' { $s = $manager.GetCurrentSession(); if ($s) { [void](Await ($s.TrySkipNextAsync()) ([bool])) } }
    'prev' { $s = $manager.GetCurrentSession(); if ($s) { [void](Await ($s.TrySkipPreviousAsync()) ([bool])) } }
}