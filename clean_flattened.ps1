# PowerShell script to clean flattened Solidity files for Etherscan verification
# This removes duplicate SPDX licenses and pragma statements

Write-Host "Cleaning flattened Solidity files..." -ForegroundColor Green

$files = Get-ChildItem -Path "flattened_contracts" -Filter "*_flattened.sol"

foreach ($file in $files) {
    Write-Host "Processing: $($file.Name)" -ForegroundColor Cyan
    
    $content = Get-Content $file.FullName -Raw
    
    # Remove all "Original license: SPDX_License_Identifier: MIT" comments
    $content = $content -replace '// Original license: SPDX_License_Identifier: MIT\r?\n', ''
    
    # Keep only the first SPDX license identifier
    $spdxCount = 0
    $lines = $content -split "`r?`n"
    $cleanedLines = @()
    
    foreach ($line in $lines) {
        if ($line -match '^// SPDX-License-Identifier:') {
            $spdxCount++
            if ($spdxCount -eq 1) {
                $cleanedLines += $line
            }
            # Skip subsequent SPDX lines
        } else {
            $cleanedLines += $line
        }
    }
    
    $content = $cleanedLines -join "`n"
    
    # Remove duplicate pragma solidity statements (keep only the first one)
    $pragmaCount = 0
    $lines = $content -split "`n"
    $cleanedLines = @()
    
    foreach ($line in $lines) {
        if ($line -match '^pragma solidity') {
            $pragmaCount++
            if ($pragmaCount -eq 1) {
                $cleanedLines += $line
            }
            # Skip subsequent pragma lines
        } else {
            $cleanedLines += $line
        }
    }
    
    $content = $cleanedLines -join "`n"
    
    # Remove excessive blank lines (more than 2 consecutive)
    $content = $content -replace '(\r?\n){3,}', "`n`n"
    
    # Save cleaned content
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
    
    Write-Host "  ✓ Cleaned successfully" -ForegroundColor Green
}

Write-Host "`nAll files cleaned!" -ForegroundColor Green
Write-Host "Files are ready for Etherscan verification" -ForegroundColor Yellow
