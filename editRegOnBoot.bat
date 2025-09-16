@echo off
echo Last run: %time% > "C:\PolicyBypass\lastrun.log"
regedit.exe /s "C:\PolicyBypass\policyBypass.reg"