@ECHO OFF
COLOR
TITLE Configuring Qt
CLS
SETLOCAL
REM Qt version, default is 5.11.0
SET "_QT_VERSION=%1"
REM win32-clang-g++, win32-clang-msvc, win32-g++, win32-icc, win32-icc-k1om or win32-msvc, default is win32-msvc
SET "_QT_COMPILER=%2"
REM x86 or x64, default is x64
SET "_TARGET_ARCH=%3"
REM dll or lib, default is dll
SET "_BUILD_TYPE=%4"
REM debug, release or debug-and-release, default is release
SET "_COMP_MODE=%5"
REM Qt source code directory, default is ".\src"
SET "_ROOT=%6"
REM Qt install directory, default is ".\qt"
SET "_INSTALL_DIR=%7"
REM Extra configure parameters, default is empty
SET "_EXTRA_PARAMS=%8"
IF /I "%_QT_VERSION%" == "" SET "_QT_VERSION=5.11.0"
IF /I "%_ROOT%" == "" SET "_ROOT=%~dp0src"
IF /I "%_QT_COMPILER%" == "" SET "_QT_COMPILER=win32-msvc"
IF /I "%_TARGET_ARCH%" == "" SET "_TARGET_ARCH=x64"
IF /I "%_COMP_MODE%" == "" SET "_COMP_MODE=release"
IF /I "%_BUILD_TYPE%" == "" SET "_BUILD_TYPE=dll"
IF /I "%_INSTALL_DIR%" == "" SET "_INSTALL_DIR=%~dp0Qt_%_QT_VERSION%_%_QT_COMPILER%_%_TARGET_ARCH%_%_BUILD_TYPE%_%_COMP_MODE%"
IF /I "%_QT_VERSION:~0,2%" == "1." ECHO This script does NOT support Qt1! && GOTO Fin
IF /I "%_QT_VERSION:~0,2%" == "2." ECHO This script does NOT support Qt2! && GOTO Fin
IF /I "%_QT_VERSION:~0,2%" == "3." ECHO This script does NOT support Qt3! && GOTO Fin
IF /I "%_QT_VERSION:~0,2%" == "4." ECHO This script does NOT support Qt4! && GOTO Fin
IF EXIST "%_INSTALL_DIR%" RD /S /Q "%_INSTALL_DIR%"
SET "_COMP_MODE=-%_COMP_MODE%"
IF /I "%_BUILD_TYPE%" == "lib" (
    REM According to Qt official wiki,
    REM QWebEngine module cannot be compiled statically, so we have to skip it.
    REM --------------------------------------------------------------------
    REM If you are using MinGW/MinGW-w64,
    REM adding "-static-runtime" will result in compilation failure,
    REM I don't know why, you'd better remove it manually.
    SET "_BUILD_TYPE=-static -static-runtime -skip qtwebengine"
) ELSE (
    REM If you want to compile QWebEngine,
    REM you have to change your system locale to English(United States).
    REM And don't forget to change it back after compiling Qt.
    REM -------------------------------------------------------
    REM And according to Qt official wiki,
    REM QWebEngine module can only be compiled by VS2017 now,
    REM all other compilers are not supported,
    REM including VS2015 and Intel C++ Compiler(ICC)
    REM (only on Windows platform and building Qt 5.11+).
    SET "_BUILD_TYPE=-shared"
)
REM Using the latest MSVC compiler on Windows platform is the best choice,
REM you will finish the compilation with no errors and warnings.
REM You may fail to compile some repositories if you are using
REM Intel C++ Compiler(ICC), your only choice is to skip them.
SET "_VC_BAT_PATH=%VS2017INSTALLDIR%\VC\Auxiliary\Build\vcvarsall.bat"
IF NOT EXIST "%_VC_BAT_PATH%" SET "_VC_BAT_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\Preview\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
IF NOT EXIST "%_VC_BAT_PATH%" SET "_VC_BAT_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\Preview\Professional\VC\Auxiliary\Build\vcvarsall.bat"
IF NOT EXIST "%_VC_BAT_PATH%" SET "_VC_BAT_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\Preview\Community\VC\Auxiliary\Build\vcvarsall.bat"
IF NOT EXIST "%_VC_BAT_PATH%" SET "_VC_BAT_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
IF NOT EXIST "%_VC_BAT_PATH%" SET "_VC_BAT_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat"
IF NOT EXIST "%_VC_BAT_PATH%" SET "_VC_BAT_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat"
IF NOT EXIST "%_VC_BAT_PATH%" SET "_VC_BAT_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat"
REM IF NOT EXIST "%_VC_BAT_PATH%" SET "_VC_BAT_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
REM IF NOT EXIST "%_VC_BAT_PATH%" SET "_VC_BAT_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\Shared\14.0\VC\vcvarsall.bat"
IF NOT EXIST "%_VC_BAT_PATH%" SET "_VC_BAT_PATH=%VS140COMNTOOLS%..\..\VC\vcvarsall.bat"
IF NOT EXIST "%_VC_BAT_PATH%" SET "_VC_BAT_PATH=%VCINSTALLDIR%\vcvarsall.bat"
IF NOT EXIST "%_VC_BAT_PATH%" SET _VC_BAT_PATH=
IF NOT EXIST "%_VC_BAT_PATH%" ECHO Cannot find [vcvarsall.bat], if you did't install VS in it's default location, please change this script && GOTO Fin
IF /I "%_QT_COMPILER:~0,9%" == "win32-icc" SET "_VC_BAT_PATH=%ProgramFiles(x86)%\IntelSWTools\compilers_and_libraries\windows\bin\ipsxe-comp-vars.bat"
IF NOT EXIST "%_VC_BAT_PATH%" ECHO You are using Intel C++ Compiler, however, this script cannot find [ipsxe-comp-vars.bat], if you didn't install ICC in it's default location, please change this script && GOTO Fin
REM Cross compile example for i686-w64-mingw32-g++(MinGW-w64):
REM configure -xplatform win32-g++ -device-option CROSS_COMPILE=i686-w64-mingw32-
REM It means you should use "-xplatform" instead of "-platform" and
REM add "-device-option CROSS_COMPILE=".
REM The compilation may fail because some exe file names are not
REM correct and thus the build system can't find them.
REM Don't worry, just change their file names to what they should be.
REM -------------------------------------
REM Use "-optimize-size" to reduce the binary file size,
REM however, it will affect the performance of the code, but not much.
REM This parameter is not supported by Qt 5.6 and older Qt versions,
REM but you can also replace all "-O2" with "-O1" in "msvc-desktop.conf"
REM to achieve the same effect, the file is located in "qtbase\mkspecs\common".
REM ----------------------------------------
REM Use "-ltcg" means to enable Link Time Code Generation,
REM which is the "Whole program/application optimization" in VC++.
REM I recommend you enable LTCG, because this will not only reduce
REM the binary size but also make your code faster.
REM But enable LTCG will slow down the compilation process and
REM increase the CPU and memory use.
REM ---------------------------------------
REM Remove "-nomake tools" if you want to build Qt Designer,
REM Qt Linguist and Qt Assistant.
REM ----------------------------------------
REM According to Qt official wiki, use "-opengl dynamic" is highly recommended,
REM but you will need libEGL.dll, libGLESv2.dll, opengl32sw.dll
REM and d3dcompiler_47.dll, which is about 20~30MB.
REM --------------------------------------------
REM Remember to remove "-silent" if you are building Qt 5.6 and older
REM Qt versions, it is a newly added parameter and cannot be recognized
REM by previous Qt configuration system.
SET "_CFG_PARAMS=-opensource -confirm-license %_COMP_MODE% %_BUILD_TYPE% -platform %_QT_COMPILER% -make-tool jom -silent -nomake examples -nomake tests -opengl dynamic -prefix ^"%_INSTALL_DIR%^" %_EXTRA_PARAMS%"
REM The last version of Qt that supports Windows XP is Qt 5.6,
REM you have to add "-target xp" to explicitly enable it,
REM from Qt 5.7+ the configure system had removed this parameter,
REM and Qt itself didn't support Windows XP anymore either.
IF /I "%_QT_VERSION:~0,4%" == "5.0." SET "_CFG_PARAMS=%_CFG_PARAMS% -target xp"
IF /I "%_QT_VERSION:~0,4%" == "5.1." SET "_CFG_PARAMS=%_CFG_PARAMS% -target xp"
IF /I "%_QT_VERSION:~0,4%" == "5.2." SET "_CFG_PARAMS=%_CFG_PARAMS% -target xp"
IF /I "%_QT_VERSION:~0,4%" == "5.3." SET "_CFG_PARAMS=%_CFG_PARAMS% -target xp"
IF /I "%_QT_VERSION:~0,4%" == "5.4." SET "_CFG_PARAMS=%_CFG_PARAMS% -target xp"
IF /I "%_QT_VERSION:~0,4%" == "5.5." SET "_CFG_PARAMS=%_CFG_PARAMS% -target xp"
IF /I "%_QT_VERSION:~0,4%" == "5.6." SET "_CFG_PARAMS=%_CFG_PARAMS% -target xp"
SET "_CFG_BAT=%_ROOT%\configure.bat"
REM If you don't have jom, use nmake instead, which is provided by Visual Studio.
REM nmake is very slow, I recommend you use jom, you can download the latest jom
REM from it's official download link:
REM download.qt.io/official_releases/jom/jom.zip
REM Remember to add it's path to your system path variables
REM or just put it into "src\gnuwin32\bin", this directory will be added to
REM the PATH variable temporarily during the compiling process.
REM If you have to use nmake, you can pass "-mp" to configure command line,
REM which can use multiple processors for compilation, and remember to
REM remove "-make-tool jom" and replace all "jom" with "nmake" in your script.
SET "_MAKE_TOOL=jom"
IF /I "%_QT_COMPILER:~-3%" == "g++" SET "_MAKE_TOOL=mingw32-make"
SET "_D3D_COMPILER_XX_DLL=%ProgramFiles(x86)%\Windows Kits\10\Redist\D3D\%_TARGET_ARCH%\d3dcompiler_47.dll"
TITLE Configure finished
CLS
ECHO The configuring process have finished successfully
ECHO Your configuration is:
ECHO ---------------------------------------
ECHO Compiler: %_QT_COMPILER%
ECHO Target architecture: %_TARGET_ARCH%
ECHO Source code directory: %_ROOT%
ECHO Install directory: %_INSTALL_DIR%
IF /I "%_QT_COMPILER:~-3%" NEQ "g++" ECHO Compiler batch script: %_VC_BAT_PATH%
ECHO Build tool: %_MAKE_TOOL%
ECHO Qt configuration parameters: %_CFG_PARAMS%
ECHO ---------------------------------------
ECHO If everything is all right, press any key to generate the build script
ECHO If anything is wrong, please close this window and re-run it
SET "yyyy=%date:~,4%"
SET "mm=%date:~5,2%"
SET "day=%date:~8,2%"
SET "YYYYmmdd=%yyyy%%mm%%day%"
SET "YYYYmmdd=%YYYYmmdd: =0%"
SET "hh=%time:~0,2%"
SET "mi=%time:~3,2%"
SET "ss=%time:~6,2%"
SET "hhmiss=%hh%%mi%%ss%"
SET "hhmiss=%hhmiss: =0%"
SET "hhmiss=%hhmiss::=0%"
SET "hhmiss=%hhmiss: =0%"
SET "_BUILD_BAT=%_INSTALL_DIR%_%YYYYmmdd%%hhmiss%.bat"
ECHO Your build script will be saved to: %_BUILD_BAT%
PAUSE
IF /I "%_QT_COMPILER:~0,9%" == "win32-icc" (
    IF /I "%_TARGET_ARCH%" == "x64" (
        REM If you are using VS2015, please change "vs2017" to "vs2015"
        SET "_TARGET_ARCH=intel64 vs2017"
    ) ELSE (
        REM If you are using VS2015, please change "vs2017" to "vs2015"
        SET "_TARGET_ARCH=ia32 vs2017"
    )
)
IF EXIST "%_BUILD_BAT%" DEL /F /Q "%_BUILD_BAT%"
> "%_BUILD_BAT%" (
    @ECHO @ECHO OFF
    @ECHO COLOR
    @ECHO TITLE Building Qt from source code
    @ECHO CLS
    @ECHO SETLOCAL
    IF /I "%_QT_COMPILER:~-3%" NEQ "g++" @ECHO CALL "%_VC_BAT_PATH%" %_TARGET_ARCH%
    @ECHO SET "PATH=%_ROOT%\qtbase\bin;%_ROOT%\gnuwin32\bin;%%PATH%%"
    @ECHO REM SET "_ICU_DIR="
    @ECHO REM SET "_OPENSSL_DIR="
    @ECHO REM SET "PATH=%%_ICU_DIR%%\bin;%%_OPENSSL_DIR%%\bin;%%PATH%%"
    @ECHO CD /D "%_ROOT%"
    @ECHO IF EXIST build RD /S /Q build
    @ECHO MD build
    @ECHO CD build
    @ECHO CALL "%_CFG_BAT%" %_CFG_PARAMS%
    @ECHO REM CALL "%_CFG_BAT%" %_CFG_PARAMS% -icu -I "%%_ICU_DIR%%\include" -L "%%_ICU_DIR%%\lib" -openssl-linked -I "%%_OPENSSL_DIR%%\include" -L "%%_OPENSSL_DIR%%\lib"
    @ECHO IF %%ERRORLEVEL%% NEQ 0 GOTO ErrHappen
    IF /I "%_QT_COMPILER:~-3%" == "g++" (
        @ECHO %_MAKE_TOOL% -j 4 ^&^& %_MAKE_TOOL% install
    ) ELSE (
        @ECHO %_MAKE_TOOL% ^&^& %_MAKE_TOOL% install
    )
    @ECHO IF %%ERRORLEVEL%% NEQ 0 GOTO ErrHappen
    @ECHO IF EXIST "%_D3D_COMPILER_XX_DLL%" COPY /Y "%_D3D_COMPILER_XX_DLL%" "%_INSTALL_DIR%\bin\d3dcompiler_47.dll"
    @ECHO REM Remember to download "opengl32sw.dll" from "http://download.qt.io/development_releases/prebuilt/llvmpipe/windows/".
    @ECHO ^> "%_INSTALL_DIR%\bin\qt.conf" ^(
    @ECHO     @ECHO [Paths]
    @ECHO     @ECHO Prefix=..
    REM @ECHO     @ECHO HostPrefix=..
    REM @ECHO     @ECHO Sysroot=
    REM @ECHO     @ECHO SysrootifyPrefix=false
    REM @ECHO     @ECHO TargetSpec=%_QT_COMPILER%
    REM @ECHO     @ECHO HostSpec=%_QT_COMPILER%
    @ECHO     @ECHO Documentation=../../Docs/Qt-%_QT_VERSION%
    @ECHO     @ECHO Examples=../../Examples/Qt-%_QT_VERSION%
    REM @ECHO     @ECHO [DevicePaths]
    REM @ECHO     @ECHO Prefix=..
    REM @ECHO     @ECHO [EffectivePaths]
    REM @ECHO     @ECHO Prefix=..
    @ECHO ^)
    @ECHO ^> "%_INSTALL_DIR%\bin\qtenv2.bat" ^(
    @ECHO     @ECHO @echo off
    @ECHO     @ECHO echo Setting up environment for Qt usage...
    @ECHO     @ECHO set PATH=^%%%%~dp0;^%%%%PATH^%%%%
    @ECHO     @ECHO cd /D ^%%%%~dp0..
    @ECHO     @ECHO echo Remember to call vcvarsall.bat to complete environment setup!
    @ECHO ^)
    @ECHO CD /D "%_ROOT%"
    @ECHO RD /S /Q build
    @ECHO TITLE Compiling process finished
    @ECHO CLS
    @ECHO ECHO Compiling process have finished successfully
    @ECHO ECHO All binaries have been installed to: %_INSTALL_DIR%
    @ECHO GOTO Fin
    @ECHO :ErrHappen
    @ECHO TITLE Compiling process aborted
    @ECHO ECHO ============================================================
    @ECHO ECHO Something wrong happened during the compiling process
    @ECHO ECHO and the process have aborted because of this
    @ECHO ECHO Please check the log file for more information
    @ECHO ECHO Press any key to exit this program
    @ECHO GOTO Fin
    @ECHO :Fin
    @ECHO ENDLOCAL
    @ECHO IF %%ERRORLEVEL%% NEQ 0 ^(
    @ECHO PAUSE
    @ECHO EXIT /B
    @ECHO ^) ELSE ^(
    @ECHO DEL /F %%0
    @ECHO ^)
)
CLS
ECHO Build script have been saved to: %_BUILD_BAT%
ECHO Press any key to run it, or you can close this window and run it manually
PAUSE
CALL "%_BUILD_BAT%"
GOTO Fin

:Fin
ENDLOCAL
PAUSE
EXIT /B
