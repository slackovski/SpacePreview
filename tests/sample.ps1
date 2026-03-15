# PowerShell script example
[CmdletBinding()]
param(
    [Parameter(Mandatory)][int]$UserId,
    [string]$ApiBase = "https://api.example.com"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-User {
    param([int]$Id, [string]$Base)

    $uri = "$Base/users/$Id"
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Get
        return $response
    }
    catch [System.Net.WebException] {
        Write-Error "Failed to fetch user $Id: $_"
        return $null
    }
}

$user = Get-User -Id $UserId -Base $ApiBase
if ($user) {
    Write-Host "Hello, $($user.name)!" -ForegroundColor Green
} else {
    Write-Warning "User $UserId not found."
}
