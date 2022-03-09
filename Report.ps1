[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $StartDate,
    [string]
    $EndDate
)

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

function Update-RecordedTime{
    param (
        [string]$today
    )
    $changed = $false
    $day = Import-Csv ".\$today.csv"
    foreach($entry in $day){
        $span = New-TimeSpan -Start $entry.Start -End $entry.Stop
        $hours = Get-Time -span $span
        if (-not($hours -eq $entry.Total)){
            $entry.total = $hours
            $changed = $true
        }
    }
    if ($changed) {
        $day | Export-Csv ".\$today.csv"
    }
}

$files = Get-ChildItem "*.csv"
$total = 0
foreach($file in $files){
    if (($file.name.split('.')[0] -ge (Get-SortableDate $StartDate)) -and ($file.name.split('.')[0] -le (Get-SortableDate $EndDate))) {
        Update-RecordedTime $file.name.split('.')[0]
        $day = Import-Csv $file
        $hours = 0
        foreach($entry in $day){
            $hours += $entry.Total
        }
        $day = [PSCustomObject]@{
            Date = $file.name.split('.')[0]
            Hours = $hours
        }
        $total += [float]$hours
        $day
    }
}
write-host "Total hours"$total
