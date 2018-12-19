@echo off
cd /d %~dp0

set war3Path=E:\Warcraft3
set ydwePath=D:\fengchao\YDWE 1.31.8 MTP

set mapOutPath=%war3Path%\maps\vscode

set mapPath=%~dpn1
set mapName=%~n1


md %mapOutPath%

w2l.exe obj "%mapPath%"
move "%mapPath%.w3x" "%mapOutPath%\%mapName%.w3x"
cd %ydwePath%
echo %mapOutPath%\%mapName%.w3x
bin\ydweconfig.exe -launchwar3 -loadfile "%mapOutPath%\%mapName%.w3x"


