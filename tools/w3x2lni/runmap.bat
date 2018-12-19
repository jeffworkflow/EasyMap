set mapName="newMap"
set mapPath="D:\one-map\Sylvanas"

set ydwePath="D:\fengchao\YDWE 1.31.8 MTP"

set mapName=%mapName:"=%
set mapPath=%mapPath:"=%\%mapName:"=%
set ydwePath=%ydwePath:"=%

w2l.exe obj "%mapPath%"
move "%mapPath%.w3x" "%ydwePath%\%mapName%.w3x"
cd %ydwePath%
bin\ydweconfig.exe -launchwar3 -loadfile "%mapName%.w3x"