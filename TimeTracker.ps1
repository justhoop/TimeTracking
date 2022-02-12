function Get-SortableDate {
    [CmdletBinding()]
    param (
        [Parameter()]
        [DateTime]
        $date
    )
    $now = get-date -Date $date
    $month = $now.Month.ToString()
    if ($month.Length -eq 1) { $month = "0" + $month }  
    $day = $now.Day.ToString()
    if ($day.Length -eq 1) { $day = "0" + $day }  
    $result = $now.Year.ToString() + "-" + $month + "-" + $day
    return $result
}

function Get-Time {
    param (
        [TimeSpan]$span
    )
    $hours = $span.Hours
    $minutes = $span.Minutes
    If ($minutes -gt 52) {
        $hours += 1
        return $hours.ToString()
    }
    elseif (($minutes -gt 7) -and ($minutes -lt 23) ) {
        return $hours.ToString() + ".25"
    }
    elseif (($minutes -gt 22) -and ($minutes -lt 38)) {
        return $hours.ToString() + ".50"
    }
    elseif (($minutes -gt 37) -and ($minutes -lt 53)) {
        return $hours.ToString() + ".75"
    }
    else {
        return $hours.ToString()
    }
}

$today = Get-Date
$today = Get-SortableDate -date $today
$files = Get-ChildItem -Path ".\" -Filter "*.csv"
if ($files -match $today) {
    $now = Get-Date
    $entry = [PSCustomObject]@{
        Start = $now
        Stop  = $now
        Total = ""
    }
    $entry | Export-Csv ".\$today.csv" -Append
}
while ($true) {
    $files = Get-ChildItem -Path ".\" -Filter "*.csv"
    if ($files -match $today) {
        $entry = Import-Csv -Path ($files | Where-Object { $_.Name -eq "$today.csv" }).fullname
        $entry[-1].Stop = Get-Date
        $span = New-TimeSpan -Start $entry[-1].Start -End $entry[-1].Stop
        $entry[-1].Total = Get-Time -span $span
        $entry | Export-Csv ".\$today.csv"
        $total = 0
        $complete = $false
        foreach ($time in $entry) {
            $total += [double]$time.total
            if (($total -ge 8) -and ($complete -eq $false)) {
                Add-Type -AssemblyName PresentationCore, PresentationFramework
                [System.Windows.MessageBox]::Show("$total hours", "Time")
                $complete = $true
            }
        }
    }
    else {
        $now = Get-Date
        $entry = [PSCustomObject]@{
            Start = $now
            Stop  = $now
            Total = ""
        }
        $entry | Export-Csv ".\$today.csv"
    }
    Start-Sleep -Seconds 180
}


