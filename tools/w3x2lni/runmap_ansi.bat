cd /d %~dp0

set mapName="newMap"
set mapPath="D:\one-map\Development"

set ydwePath="H:\Ä§ÊÞÈí¼þ\ydwe\YDWE 1.31.8 + ±©Ñ©API 1.0"

set mapName=%mapName:"=%
set mapPath=%mapPath:"=%\%mapName:"=%
set ydwePath=%ydwePath:"=%

w2l.exe obj "%mapPath%"
move "%mapPath%.w3x" "%ydwePath%\%mapName%.w3x"
cd %ydwePath%
bin\ydweconfig.exe -launchwar3 -loadfile "%mapName%.w3x"