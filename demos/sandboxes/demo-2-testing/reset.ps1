# Resets this sandbox to the buggy start state. Run from the sandbox root.

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Get-ChildItem -Filter "test_*.py" | Remove-Item -Force
Remove-Item __pycache__, .pytest_cache -Recurse -Force -ErrorAction SilentlyContinue

@'
def apply_discount(price, percent):
    """Apply a percentage discount to a price."""
    return price - (price * percent)
'@ | Set-Content pricing.py

Write-Host "Reset complete. Now: close all editors, start a new chat." -ForegroundColor Green
