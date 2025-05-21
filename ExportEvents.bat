@echo off
cd /d C:\Temp\EventCollector

:: Force PowerShell script execution with Admin (UAC prompt)
PowerShell -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"C:\Temp\EventCollector\ExportEvents.ps1\"' -Verb RunAs"
