SET PROJECT_Path=%CD%
SET BIOS_Name=HPT60.bin
SET InPut_Sign_BIOS_Name=0891A.bin
SET OutPut_Sign_BIOS_Name=0891A.fd
SET Winflash_Name=891A.exe
SET Shellflash_Name=891A.efi
SET Sign_Tool_Version=InsydeBiosPackager_1.1.1.1010
SET Winflash_Tool_Version=HPFlashWin_6.31.01
SET Shellflash_Tool_Version=HPFlashShell_6.08.00
SET Sign_Key_Name=0891A.sig
@REM [-start-210204-William-Implement-PDRomless-feature-by-add-new-version-PD-FW-into-BIOS-image-add-] @REM
find /v "/" ..\Include\H19Project.h > string
for /f "tokens=2,3" %%a in ('findstr "H19_TI_PD_VERSION" string') do set %%a=%%b
del string
SET TI_PD_VERSION=%H19_TI_PD_VERSION:"=%
SET Pd_Image_File_Path=..\..\HPT60\Binary\H19BinaryFile\TI_PD\%TI_PD_VERSION%\0891APD0.bin
SET Pd_Image_Sign_File_Path=..\..\HPT60\Binary\H19BinaryFile\TI_PD\%TI_PD_VERSION%\0891APD0.sig
@REM [-start-210511-William-Implement-ME-Redundancy-feature-add-] @REM
SET ME_Image_File_Path=..\..\HPT60\BIOS\0891AME0.bin
SET ME_Image_Sign_File_Path=..\..\HPT60\BIOS\0891AME0.sig
@REM [-end-210511-William-Implement-ME-Redundancy-feature-add-] @REM
@REM [-end-210204-William-Implement-PDRomless-feature-by-add-new-version-PD-FW-into-BIOS-image-add-] @REM

cd ..\..
SET TOOL_Path=%CD%\Flash_Tool
SET Sign_Tool_Path=%TOOL_Path%\%Sign_Tool_Version%
SET Winflash_Tool_Path=%TOOL_Path%\%Winflash_Tool_Version%
SET Shellflash_Tool_Path=%TOOL_Path%\%Shellflash_Tool_Version%
cd %PROJECT_Path%
REM === Copy file ==============================
del %InPut_Sign_BIOS_Name%
del %Winflash_Name%
del %Shellflash_Name%

copy %Winflash_Tool_Path%\platform_B.ini %Winflash_Tool_Path%\platform.ini
copy %PROJECT_Path%\%BIOS_Name%.s12 %Sign_Tool_Path%\%Sign_Key_Name%
copy %BIOS_Name% %Sign_Tool_Path%\%InPut_Sign_BIOS_Name%
REM === Combin Sign Key =======================
cd %TOOL_Path%\%Sign_Tool_Version%
@REM [-start-210204-William-Implement-PDRomless-feature-by-add-new-version-PD-FW-into-BIOS-image-modify-] @REM
@REM [-start-210511-William-Implement-ME-Redundancy-feature-add-] @REM
start /wait InsydeBiosPackager.exe ib:%InPut_Sign_BIOS_Name% is:%Sign_Key_Name% id:%Pd_Image_File_Path%,%Pd_Image_Sign_File_Path% id:%ME_Image_File_Path%,%ME_Image_Sign_File_Path% ob:%OutPut_Sign_BIOS_Name%
@REM [-end-210511-William-Implement-ME-Redundancy-feature-add-] @REM
@REM [-end-210204-William-Implement-PDRomless-feature-by-add-new-version-PD-FW-into-BIOS-image-modify-] @REM
copy %OutPut_Sign_BIOS_Name% %Winflash_Tool_Path%\%InPut_Sign_BIOS_Name%
copy %OutPut_Sign_BIOS_Name% %Shellflash_Tool_Path%\%InPut_Sign_BIOS_Name%
copy %OutPut_Sign_BIOS_Name% %PROJECT_Path%\%InPut_Sign_BIOS_Name%
del %BIOS_Name%
del %InPut_Sign_BIOS_Name%
del %OutPut_Sign_BIOS_Name%
del %Sign_Key_Name%
cd..

REM === Package windows flash =================
cd %Winflash_Tool_Path%\Tools
iFdPacker.exe -winsrc %Winflash_Tool_Path% -winini -b 64 -fv %Winflash_Tool_Path%\%InPut_Sign_BIOS_Name% -output %Winflash_Name%
del %Winflash_Name%
del %Winflash_Tool_Path%\%InPut_Sign_BIOS_Name%
cd..
copy %Winflash_Name% %PROJECT_Path%
del %Winflash_Name%

REM === Package shell flash ===================
cd %TOOL_Path%\%Shellflash_Tool_Version%\Tools
iFdPacker.exe -shlsrc %Shellflash_Tool_Path% -shlini -fv %Shellflash_Tool_Path%\%InPut_Sign_BIOS_Name% -arg "-uefi -all" -output %Shellflash_Name%
copy %Shellflash_Name% %PROJECT_Path%
del %Shellflash_Name%
del %Shellflash_Tool_Path%\%InPut_Sign_BIOS_Name%
cd..

cd %PROJECT_Path%