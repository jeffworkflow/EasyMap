@echo off
cd /d %~dp0

set war3Path=E:\Warcraft III Frozen Throne
set ydwePath=D:\fengchao\YDWE 1.31.8 MTP

set mapOutPath=%war3Path%\maps\vscode

set mapPath=%~dpn1
set mapName=%~n1

cd %ydwePath%
bin\ydweconfig.exe -launchwar3 


