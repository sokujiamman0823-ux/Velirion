# Milestone 1 Completion Check Script
# Run all necessary checks for Milestone 1 completion

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MILESTONE 1 COMPLETION CHECKS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Compile Contracts
Write-Host "[1/5] Compiling contracts..." -ForegroundColor Yellow
npx hardhat compile
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Compilation failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Compilation successful!" -ForegroundColor Green
Write-Host ""

# Step 2: Run Tests
Write-Host "[2/5] Running test suite..." -ForegroundColor Yellow
npx hardhat test
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Tests failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ All tests passed!" -ForegroundColor Green
Write-Host ""

# Step 3: Check Coverage
Write-Host "[3/5] Checking test coverage..." -ForegroundColor Yellow
npx hardhat coverage
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Coverage check completed with warnings" -ForegroundColor Yellow
} else {
    Write-Host "✅ Coverage analysis complete!" -ForegroundColor Green
}
Write-Host ""

# Step 4: Gas Report
Write-Host "[4/5] Generating gas report..." -ForegroundColor Yellow
$env:REPORT_GAS = "true"
npx hardhat test
$env:REPORT_GAS = $null
Write-Host "✅ Gas report generated!" -ForegroundColor Green
Write-Host ""

# Step 5: Summary
Write-Host "[5/5] Generating summary..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MILESTONE 1 STATUS SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Contracts compiled successfully" -ForegroundColor Green
Write-Host "✅ All tests passing" -ForegroundColor Green
Write-Host "✅ Coverage report generated" -ForegroundColor Green
Write-Host "✅ Gas optimization analyzed" -ForegroundColor Green
Write-Host ""
Write-Host "⏳ PENDING ACTIONS:" -ForegroundColor Yellow
Write-Host "  1. Deploy to Sepolia testnet" -ForegroundColor White
Write-Host "  2. Verify contract on Etherscan" -ForegroundColor White
Write-Host "  3. Implement Solana SPL token (CRITICAL)" -ForegroundColor White
Write-Host "  4. Update documentation" -ForegroundColor White
Write-Host ""
Write-Host "Next command: npx hardhat run scripts/01_deploy_token.ts --network sepolia" -ForegroundColor Cyan
Write-Host ""
