@echo off

set source=D:\one-map\EasyMap\resource\
set target=D:\one-map\EasyMap\scripts\jf\effect_file.lua


echo local str = [[ > "%target%"
dir /b %source%*.mdx  %source%*.mdl >> "%target%"
echo ]] >> "%target%"
echo return str >> "%target%"
 