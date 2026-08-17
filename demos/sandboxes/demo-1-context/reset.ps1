# Resets this sandbox to the cold-start state. Run from the sandbox root.

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (Test-Path .github\copilot-instructions.md) {
    New-Item -ItemType Directory -Force _staged | Out-Null
    Move-Item .github\copilot-instructions.md _staged\copilot-instructions.md -Force
}
Remove-Item .github -Recurse -Force -ErrorAction SilentlyContinue

Set-Content src\services\invoiceService.ts "// Invoice creation lives here."

Write-Host "Reset complete. Now: close all editors, start a new chat." -ForegroundColor Green
