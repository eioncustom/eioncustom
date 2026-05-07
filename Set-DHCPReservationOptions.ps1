<#
.SYNOPSIS
    Sets DHCP reservation options 066 (Boot Server) and 067 (Boot File Name)
    for a list of hosts from a CSV file.

.DESCRIPTION
    Reads a CSV with columns: Hostname, MACAddress
    Looks up each host's reservation in the specified DHCP scope and sets
    Option 066 = 172.31.44.83 and Option 067 = bootx64.efi

.EXAMPLE
    .\Set-DHCPReservationOptions.ps1 -CsvPath .\hosts.csv
#>

param(
    [Parameter(Mandatory)]
    [string]$CsvPath,

    [string]$ScopeId = "172.31.40.0",
    [string]$BootServer = "172.31.44.83",
    [string]$BootFile = "bootx64.efi"
)

# Validate CSV exists
if (-not (Test-Path $CsvPath)) {
    Write-Error "CSV file not found: $CsvPath"
    exit 1
}

$hosts = Import-Csv -Path $CsvPath

if (-not ($hosts | Get-Member -Name "Hostname" -ErrorAction SilentlyContinue) -or
    -not ($hosts | Get-Member -Name "MACAddress" -ErrorAction SilentlyContinue)) {
    Write-Error "CSV must have 'Hostname' and 'MACAddress' columns."
    exit 1
}

# Get all reservations in the scope once for efficient lookup
$reservations = Get-DhcpServerv4Reservation -ScopeId $ScopeId -ErrorAction Stop

$successCount = 0
$failCount = 0

foreach ($entry in $hosts) {
    $hostname = $entry.Hostname.Trim()
    $mac = $entry.MACAddress.Trim() -replace "[:\-\.]", ""  # Normalize MAC

    # Match reservation by MAC address
    $reservation = $reservations | Where-Object {
        ($_.ClientId -replace "[:\-\.]", "") -eq $mac
    }

    if (-not $reservation) {
        Write-Warning "No reservation found for $hostname (MAC: $mac) in scope $ScopeId - skipping."
        $failCount++
        continue
    }

    $reservedIP = $reservation.IPAddress

    try {
        # Set Option 066 - Boot Server Host Name
        Set-DhcpServerv4OptionValue -ReservedIP $reservedIP -OptionId 66 -Value $BootServer -ErrorAction Stop

        # Set Option 067 - Bootfile Name
        Set-DhcpServerv4OptionValue -ReservedIP $reservedIP -OptionId 67 -Value $BootFile -ErrorAction Stop

        Write-Host "[OK] $hostname ($reservedIP) - Options 066/067 set successfully." -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Warning "[FAIL] $hostname ($reservedIP) - $($_.Exception.Message)"
        $failCount++
    }
}

Write-Host ("`nComplete: $successCount succeeded, $failCount failed.") -ForegroundColor Cyan
