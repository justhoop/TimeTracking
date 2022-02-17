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

$files = Get-ChildItem "*.csv"
$total = 0
foreach($file in $files){
    if (($file.name.split('.')[0] -ge (Get-SortableDate $StartDate)) -and ($file.name.split('.')[0] -le (Get-SortableDate $EndDate))) {
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
