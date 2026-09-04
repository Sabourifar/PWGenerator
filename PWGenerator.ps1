$ErrorActionPreference = 'Stop'
[Console]::Title = "PWGenerator"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$script:SYM_OK     = [string][char]0x2713
$script:SYM_ERR    = [string][char]0x2717
$script:SYM_WARN   = [string][char]0x26A0
$script:SYM_PROMPT = [string][char]0x203A
$script:SYM_BULLET = [string][char]0x00B7
$script:CH_H       = [string][char]0x2500

$script:RuleWidth = 120

$script:Rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()

$script:UpperChars  = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
$script:LowerChars  = 'abcdefghijklmnopqrstuvwxyz'
$script:NumberChars = '0123456789'
$script:SymbolChars = '!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~'

$script:SaveFile = if ($PSScriptRoot) { Join-Path $PSScriptRoot 'Passwords.txt' } else { 'Passwords.txt' }

function Write-SectionHeader {
    param([string]$Label)
    $prefix = "  $Label "
    $dashCount = $script:RuleWidth - $prefix.Length
    if ($dashCount -lt 1) { $dashCount = 1 }
    Write-Host "$prefix$($script:CH_H * $dashCount)"
}

function Write-AppHeader {
    Write-Host "  PWGenerator v26.09 $($script:SYM_BULLET) by Sabourifar"
    Write-Host ''
}

function Write-NumberedRow {
    param([string]$Num, [string]$Text)
    Write-Host ("  " + $Num.PadLeft(2) + "   " + $Text)
}

function Write-KeyRow {
    param([string]$Key, [string]$Text)
    Write-Host ("   " + $Key.PadRight(12) + $Text)
}

function Get-Prompt {
    param([string]$Label)
    return "  $Label $($script:SYM_PROMPT) "
}

function Read-Trimmed {
    param([string]$Prompt)
    Write-Host -NoNewline $Prompt
    $val = Read-Host
    return $val.Trim()
}

function Write-ErrorLine {
    param([string]$Text)
    Write-Host "  $($script:SYM_ERR) $Text" -ForegroundColor Red
}

function Write-OkLine {
    param([string]$Text)
    Write-Host "  $($script:SYM_OK) $Text" -ForegroundColor Green
}

function Get-SecureRandomInt {
    param([int]$Max)
    if ($Max -le 1) { return 0 }
    $bytes = [byte[]]::new(4)
    $limit = [uint32]::MaxValue - ([uint32]::MaxValue % [uint32]$Max)
    do {
        $script:Rng.GetBytes($bytes)
        $val = [BitConverter]::ToUInt32($bytes, 0)
    } while ($val -ge $limit)
    return [int]($val % $Max)
}

function New-Password {
    param([int]$Length, [bool]$Upper, [bool]$Lower, [bool]$Numbers, [bool]$Symbols)

    $sets = @()
    if ($Upper)   { $sets += , $script:UpperChars }
    if ($Lower)   { $sets += , $script:LowerChars }
    if ($Numbers) { $sets += , $script:NumberChars }
    if ($Symbols) { $sets += , $script:SymbolChars }

    $activeCount = $sets.Count
    $base = [math]::Floor($Length / $activeCount)
    $remainder = $Length % $activeCount

    $chars = [System.Collections.Generic.List[char]]::new()
    foreach ($set in $sets) {
        $count = $base
        if ($remainder -gt 0) { $count++; $remainder-- }
        for ($i = 0; $i -lt $count; $i++) {
            $idx = Get-SecureRandomInt $set.Length
            $chars.Add($set[$idx])
        }
    }

    for ($i = $chars.Count - 1; $i -gt 0; $i--) {
        $j = Get-SecureRandomInt ($i + 1)
        $tmp = $chars[$i]; $chars[$i] = $chars[$j]; $chars[$j] = $tmp
    }

    return -join $chars
}

function Save-Password {
    param([string]$Password)
    [System.IO.File]::AppendAllLines($script:SaveFile, @("Password: $Password", "="))
}

function Save-PasswordWithInfo {
    param([string]$Title, [string]$Username, [string]$Password)
    [System.IO.File]::AppendAllLines($script:SaveFile, @("Title: $Title", "Username: $Username", "Password: $Password", "="))
}

function Read-PasswordLength {
    Write-KeyRow 'Enter' 'Back'
    Write-KeyRow '0' 'Quit'
    Write-Host ''
    while ($true) {
        $in = Read-Trimmed (Get-Prompt 'Length (4-80)')
        Write-Host ''
        if ($in -eq '') { return $null }
        if ($in -eq '0') { exit 0 }
        $n = 0
        if ([int]::TryParse($in, [ref]$n) -and $n -ge 4 -and $n -le 80) { return $n }
        Write-ErrorLine 'Length must be a whole number between 4 and 80.'
        Write-Host ''
    }
}

function Read-YesNo {
    param([string]$Question)
    while ($true) {
        $in = Read-Trimmed (Get-Prompt "$Question Y/n")
        Write-Host ''
        if ($in -eq '') { return $null }
        if ($in -eq '0') { exit 0 }
        if ($in -in 'y', 'yes') { return $true }
        if ($in -in 'n', 'no') { return $false }
        Write-ErrorLine 'Please answer Y or N.'
        Write-Host ''
    }
}

function Read-CharsetSelection {
    Write-KeyRow 'Enter' 'Back'
    Write-KeyRow '0' 'Quit'
    Write-Host ''
    while ($true) {
        $upper = Read-YesNo 'Include uppercase letters?'
        if ($null -eq $upper) { return $null }
        $lower = Read-YesNo 'Include lowercase letters?'
        if ($null -eq $lower) { return $null }
        $numbers = Read-YesNo 'Include numbers?'
        if ($null -eq $numbers) { return $null }
        $symbols = Read-YesNo 'Include symbols?'
        if ($null -eq $symbols) { return $null }

        if (-not ($upper -or $lower -or $numbers -or $symbols)) {
            Write-ErrorLine 'Select at least one character set.'
            Write-Host ''
            continue
        }
        return @{ Upper = $upper; Lower = $lower; Numbers = $numbers; Symbols = $symbols }
    }
}

function Show-MainMenu {
    Clear-Host
    Write-AppHeader
    Write-SectionHeader 'MAIN MENU'
    Write-Host ''
    Write-NumberedRow '1' 'Secure password (recommended)'
    Write-NumberedRow '2' 'Custom password'
    Write-NumberedRow '0' 'Quit'
    Write-Host ''
    while ($true) {
        $choice = Read-Trimmed (Get-Prompt 'Select an option')
        Write-Host ''
        switch ($choice) {
            '1' { Start-SecureFlow; return }
            '2' { Start-CustomFlow; return }
            '0' { exit 0 }
            default { Write-ErrorLine 'Invalid option. Please try again.'; Write-Host '' }
        }
    }
}

function Start-SecureFlow {
    Clear-Host
    Write-SectionHeader 'PASSWORD LENGTH'
    Write-Host ''
    $length = Read-PasswordLength
    if ($null -eq $length) { Show-MainMenu; return }
    $pw = New-Password -Length $length -Upper $true -Lower $true -Numbers $true -Symbols $true
    Show-PasswordScreen -Password $pw -Length $length -Upper $true -Lower $true -Numbers $true -Symbols $true
}

function Start-CustomFlow {
    Clear-Host
    Write-SectionHeader 'PASSWORD LENGTH'
    Write-Host ''
    $length = Read-PasswordLength
    if ($null -eq $length) { Show-MainMenu; return }

    Clear-Host
    Write-SectionHeader 'CHARACTER SET'
    Write-Host ''
    $sel = Read-CharsetSelection
    if ($null -eq $sel) { Show-MainMenu; return }

    $pw = New-Password -Length $length -Upper $sel.Upper -Lower $sel.Lower -Numbers $sel.Numbers -Symbols $sel.Symbols
    Show-PasswordScreen -Password $pw -Length $length -Upper $sel.Upper -Lower $sel.Lower -Numbers $sel.Numbers -Symbols $sel.Symbols
}

function Show-PasswordScreen {
    param([string]$Password, [int]$Length, [bool]$Upper, [bool]$Lower, [bool]$Numbers, [bool]$Symbols)
    Clear-Host
    Write-SectionHeader 'GENERATED PASSWORD'
    Write-Host ''
    Write-Host "  $Password" -ForegroundColor Cyan
    Write-Host ''
    Write-NumberedRow '1' 'Generate another'
    Write-NumberedRow '2' 'Save password'
    Write-NumberedRow '3' 'Save with login info'
    Write-Host ''
    Write-KeyRow 'Enter' 'Back to main menu'
    Write-KeyRow '0' 'Quit'
    Write-Host ''
    while ($true) {
        $choice = Read-Trimmed (Get-Prompt 'Select an option')
        Write-Host ''
        switch ($choice) {
            '1' {
                $pw2 = New-Password -Length $Length -Upper $Upper -Lower $Lower -Numbers $Numbers -Symbols $Symbols
                Show-PasswordScreen -Password $pw2 -Length $Length -Upper $Upper -Lower $Lower -Numbers $Numbers -Symbols $Symbols
                return
            }
            '2' { Show-SaveScreen -Password $Password; return }
            '3' { Show-SaveWithInfoScreen -Password $Password; return }
            '' { Show-MainMenu; return }
            '0' { exit 0 }
            default { Write-ErrorLine 'Invalid option. Please try again.'; Write-Host '' }
        }
    }
}

function Show-SaveScreen {
    param([string]$Password)
    Clear-Host
    Write-SectionHeader 'SAVE PASSWORD'
    Write-Host ''
    Write-Host '  Saving password...'
    try {
        Save-Password -Password $Password
        Write-OkLine "Saved to $($script:SaveFile)."
        Write-Host "  $($script:SYM_WARN) Passwords.txt stores everything in plain text — keep it secure." -ForegroundColor Yellow
    } catch {
        Write-ErrorLine 'Failed to save password.'
    }
    Write-Host ''
    Write-KeyRow 'Enter' 'Back to main menu'
    Write-KeyRow '0' 'Quit'
    Write-Host ''
    while ($true) {
        $choice = Read-Trimmed (Get-Prompt 'Select an option')
        Write-Host ''
        if ($choice -eq '') { Show-MainMenu; return }
        if ($choice -eq '0') { exit 0 }
        Write-ErrorLine 'Invalid option. Please try again.'
        Write-Host ''
    }
}

function Show-SaveWithInfoScreen {
    param([string]$Password)
    Clear-Host
    Write-SectionHeader 'SAVE WITH LOGIN INFO'
    Write-Host ''
    Write-KeyRow 'Enter' 'Back to main menu'
    Write-KeyRow '0' 'Quit'
    Write-Host ''

    $title = Read-Trimmed (Get-Prompt 'Title')
    Write-Host ''
    if ($title -eq '') { Show-MainMenu; return }
    if ($title -eq '0') { exit 0 }

    $username = Read-Trimmed (Get-Prompt 'Username')
    Write-Host ''
    if ($username -eq '') { Show-MainMenu; return }
    if ($username -eq '0') { exit 0 }

    Clear-Host
    Write-SectionHeader 'SAVE WITH LOGIN INFO'
    Write-Host ''
    Write-Host '  Saving password...'
    try {
        Save-PasswordWithInfo -Title $title -Username $username -Password $Password
        Write-OkLine "Saved to $($script:SaveFile)."
        Write-Host "  $($script:SYM_WARN) Passwords.txt stores everything in plain text — keep it secure." -ForegroundColor Yellow
    } catch {
        Write-ErrorLine 'Failed to save password.'
    }
    Write-Host ''
    Write-KeyRow 'Enter' 'Back to main menu'
    Write-KeyRow '0' 'Quit'
    Write-Host ''
    while ($true) {
        $choice = Read-Trimmed (Get-Prompt 'Select an option')
        Write-Host ''
        if ($choice -eq '') { Show-MainMenu; return }
        if ($choice -eq '0') { exit 0 }
        Write-ErrorLine 'Invalid option. Please try again.'
        Write-Host ''
    }
}

Show-MainMenu