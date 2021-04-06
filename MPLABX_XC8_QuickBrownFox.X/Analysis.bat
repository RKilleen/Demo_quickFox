set ldra=C:\LDRA_Toolsuite\
set proj=%cd%

rem %ldra%contbbuildimport.exe -build_cmd=Build.bat -startin_dir="%proj%" -settings="C:\LDRA_Toolsuite\Compiler_spec\Microchip\xc8\xc8_tbmakelogparser.dat" -build -quit

start /wait %ldra%contestbed testProject -create_set=system -1q

forfiles /s /m *.c /c \"cmd /c start /wait %ldra%contestbed testProject -add_set_file=@path -1q\"
forfiles /s /m *.h /c \"cmd /c start /wait %ldra%contestbed testProject -add_set_file=@path -1q\"

start /wait %ldra%contestbed testProject -112a34567q -generate_code_review=HTML -publish_to_dir=%proj%

if errorlevel = 1 EXIT /B %ERRORLEVEL%
