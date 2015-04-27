@ECHO OFF
REM Copyright 2015 DataStax
REM
REM Licensed under the Apache License, Version 2.0 (the "License");
REM you may not use this file except in compliance with the License.
REM You may obtain a copy of the License at
REM
REM http://www.apache.org/licenses/LICENSE-2.0
REM
REM Unless required by applicable law or agreed to in writing, software
REM distributed under the License is distributed on an "AS IS" BASIS,
REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM See the License for the specific language governing permissions and
REM limitations under the License.

REM Enable delayed expansion (multiple var assignments) and local variables
SETLOCAL ENABLEDELAYEDEXPANSION

SET BATCH_DIRECTORY=%~D0%~P0
SET ABSOLUTE_BATCH_DIRECTORY=%~DP0
SET BATCH_FILENAME=%~N0%~X0

REM Exit code constants
SET EXIT_CODE_INVALID_SYSTEM_ARCHITECTURE=1
SET EXIT_CODE_MISSING_VISUAL_STUDIO=2
SET EXIT_CODE_MISSING_BUILD_DEPENDENCY=3
SET EXIT_CODE_INVALID_BUILD_DEPENDENCY_VERSION=4
SET EXIT_CODE_CLONE_FAILED=5
SET EXIT_CODE_CHECKOUT_FAILED=6
SET EXIT_CODE_BUILD_DEPENDENCY_FAILED=7
SET EXIT_CODE_BUILD_DRIVER_FAILED=8
SET EXIT_CODE_INVALID_VERSION=9
SET EXIT_CODE_PACKAGE_FAILED=10

REM Argument constants
SET ARGUMENT_BUILD_TYPE_DEBUG=--DEBUG
SET ARGUMENT_BUILD_TYPE_RELEASE=--RELEASE
SET ARGUMENT_DISABLE_CLEAN_BUILD=--DISABLE-CLEAN
SET ARGUMENT_ENABLE_BUILD_PACKAGES=--ENABLE-PACKAGES
SET ARGUMENT_PHP_VERSION=--PHP-VERSION
SET ARGUMENT_TARGET_ARCHITECTURE_32BIT=--X86
SET ARGUMENT_TARGET_ARCHITECTURE_64BIT=--X64
SET ARGUMENT_ENABLE_ZLIB=--ENABLE-ZLIB
SET ARGUMENT_USE_BOOST_ATOMIC=--USE-BOOST-ATOMIC
SET ARGUMENT_HELP=--HELP

REM Option/Value constants
SET ARCHITECTURE_32BIT=32
SET ARCHITECTURE_64BIT=64
SET BUILD_TYPE_DEBUG=DEBUG
SET BUILD_TYPE_RELEASE=RELEASE
SET LIBRARY_TYPE_SHARED=SHARED
SET LIBRARY_TYPE_STATIC=STATIC
SET TRUE=1
SET FALSE=0
SET YES=1
SET NO=2

REM Determine the system architecture (32/64 bit)
SET ARCHITECTURE_REGISTRY_LOCATION_QUERY=HKLM\HARDWARE\DESCRIPTION\System\CentralProcessor\0
REG QUERY %ARCHITECTURE_REGISTRY_LOCATION_QUERY% | FIND /I "x86" > NUL && SET SYSTEM_ARCHITECTURE=%ARCHITECTURE_32BIT% || SET SYSTEM_ARCHITECTURE=%ARCHITECTURE_64BIT%

REM Dependency executable constants
SET BISON=bison.exe
SET "DOWNLOAD_URL_BISON=http://gnuwin32.sourceforge.net/downlinks/bison.php"
SET CMAKE=cmake.exe
SET "DOWNLOAD_URL_CMAKE=http://www.cmake.org/download"
SET GIT=git.exe
SET "DOWNLOAD_URL_GIT=http://git-scm.com/downloads"
SET PERL=perl.exe
SET "DOWNLOAD_URL_PERL=https://www.perl.org/get.html#win32"
SET PYTHON=python.exe
SET "DOWNLOAD_URL_PYTHON=https://www.python.org/downloads/"
SET DEVENV=devenv.exe
SET MSBUILD=msbuild.exe
SET NMAKE=nmake.exe
SET "DOWNLOAD_URL_VISUAL_STUDIO=http://go.microsoft.com/?linkid=9832256"
SET ZIP=7z.exe
SET "DOWNLOAD_URL_ZIP=http://www.7-zip.org/download.html"

REM Minimum version build dependency constants
SET MINIMUM_VERSION_REQUIRED_CMAKE=2.8.0
SET MINIMUM_VERSION_REQUIRED_PYTHON=2.7.0

REM Build constants
SET BUILD_DIRECTORY=build
SET "ABSOLUTE_BUILD_DIRECTORY=%BATCH_DIRECTORY%\%BUILD_DIRECTORY%"
SET BUILD_PACKAGE_PREFIX=cassandra-php-driver
SET DRIVER_DRIVER_DIRECTORY=driver
SET PACKAGES_DIRECTORY=packages
SET "ABSOLUTE_PACKAGES_DIRECTORY=%ABSOLUTE_BUILD_DIRECTORY%\%PACKAGES_DIRECTORY%"

REM Library directory constants
SET LIBRARY_INCLUDE_DIRECTORY=include
SET LIBRARY_BINARY_DIRECTORY=lib
SET LIBRARY_RUNTIME_DIRECTORY=bin
SET "ABSOLUTE_DRIVER_LIBRARY_DIRECTORY=%ABSOLUTE_BUILD_DIRECTORY%\%LIBRARY_BINARY_DIRECTORY%"

REM Build dependency constants
SET DEPENDENCIES_DIRECTORY=dependencies
SET "ABSOLUTE_DEPENDENCIES_DIRECTORY=%ABSOLUTE_BUILD_DIRECTORY%\%DEPENDENCIES_DIRECTORY%"
SET DEPENDENCIES_SOURCE_DIRECTORY=src
SET DEPENDENCIES_LIBRARIES_DIRECTORY=libs
SET CPP_DRIVER_DIRECTORY=cpp-driver
SET MPIR_REPOSITORY_URL=https://github.com/wbhart/mpir.git
SET MPIR_DIRECTORY=mpir
SET MPIR_BRANCH_TAG_VERSION=mpir-2.6.0
SET PHP_REPOSITORY_URL=https://github.com/php/php-src.git
SET PHP_DIRECTORY=php
SET PHP_5_4_BRANCH_TAG_VERSION=php-5.4.40
SET PHP_5_5_BRANCH_TAG_VERSION=php-5.5.24
SET PHP_5_6_BRANCH_TAG_VERSION=php-5.6.8
SET "ABSOLUTE_DEPENDENCIES_CPP_DRIVER_SOURCE_DIRECTORY=%ABSOLUTE_BATCH_DIRECTORY%\..\%LIBRARY_BINARY_DIRECTORY%\%CPP_DRIVER_DIRECTORY%"
SET "ABSOLUTE_DEPENDENCIES_CPP_DRIVER_LIBRARIES_DIRECTORY=%ABSOLUTE_BUILD_DIRECTORY%\%DEPENDENCIES_DIRECTORY%\%DEPENDENCIES_LIBRARIES_DIRECTORY%\%CPP_DRIVER_DIRECTORY%"
SET "ABSOLUTE_DEPENDENCIES_LIBUV_LIBRARIES_DIRECTORY=%ABSOLUTE_BUILD_DIRECTORY%\%DEPENDENCIES_DIRECTORY%\%DEPENDENCIES_LIBRARIES_DIRECTORY%\libuv"
SET "ABSOLUTE_DEPENDENCIES_OPENSSL_LIBRARIES_DIRECTORY=%ABSOLUTE_BUILD_DIRECTORY%\%DEPENDENCIES_DIRECTORY%\%DEPENDENCIES_LIBRARIES_DIRECTORY%\openssl"
SET "ABSOLUTE_DEPENDENCIES_MPIR_SOURCE_DIRECTORY=%ABSOLUTE_BUILD_DIRECTORY%\%DEPENDENCIES_DIRECTORY%\%DEPENDENCIES_SOURCE_DIRECTORY%\%MPIR_DIRECTORY%"
SET "ABSOLUTE_DEPENDENCIES_MPIR_LIBRARIES_DIRECTORY=%ABSOLUTE_BUILD_DIRECTORY%\%DEPENDENCIES_DIRECTORY%\%DEPENDENCIES_LIBRARIES_DIRECTORY%\%MPIR_DIRECTORY%"
SET "ABSOLUTE_DEPENDENCIES_PHP_SOURCE_DIRECTORY=%ABSOLUTE_BUILD_DIRECTORY%\%DEPENDENCIES_DIRECTORY%\%DEPENDENCIES_SOURCE_DIRECTORY%\%PHP_DIRECTORY%"
SET "ABSOLUTE_DEPENDENCIES_PHP_LIBRARIES_DIRECTORY=%ABSOLUTE_BUILD_DIRECTORY%\%DEPENDENCIES_DIRECTORY%\%DEPENDENCIES_LIBRARIES_DIRECTORY%\%PHP_DIRECTORY%"

REM Log filename constants
SET LOG_DIRECTORY=log
SET "ABSOLUTE_LOG_DIRECTORY=%ABSOLUTE_BUILD_DIRECTORY%\%LOG_DIRECTORY%"
SET "LOG_CPP_DRIVER_BUILD=%ABSOLUTE_LOG_DIRECTORY%\cpp-driver.log"
SET "LOG_MPIR_BUILD=%ABSOLUTE_LOG_DIRECTORY%\mpir.log"
SET "LOG_PHP_BUILD=%ABSOLUTE_LOG_DIRECTORY%\php.log"
SET "LOG_DRIVER_BUILD=%ABSOLUTE_LOG_DIRECTORY%\driver.log"

REM Build defaults (can be updated via command line)
SET BUILD_TYPE=%BUILD_TYPE_RELEASE%
SET ENABLE_BUILD_PACKAGES=%FALSE%
SET ENABLE_CLEAN_BUILD=%TRUE%
SET PHP_VERSION=5_6
SET LIBRARY_TYPE=%LIBRARY_TYPE_SHARED%
SET TARGET_ARCHITECTURE=%SYSTEM_ARCHITECTURE%
SET ENABLE_ZLIB=%FALSE%
SET USE_BOOST_ATOMIC=%FALSE%

REM Parse command line arguments
:ARGUMENT_LOOP
IF NOT [%1] == [] (
  REM Get the current argument
  CALL :UPPERCASE %1 ARGUMENT
  SHIFT

  REM Build type (debug/release)
  IF "!ARGUMENT!" == "!ARGUMENT_BUILD_TYPE_DEBUG!" (
    SET BUILD_TYPE=!BUILD_TYPE_DEBUG!
  )
  IF "!ARGUMENT!" == "!ARGUMENT_BUILD_TYPE_RELEASE!" (
    SET BUILD_TYPE=!BUILD_TYPE_RELEASE!
  )

  REM Target architecture (32/64 bit)
  IF "!ARGUMENT!" == "!ARGUMENT_TARGET_ARCHITECTURE_32BIT!" (
    SET TARGET_ARCHITECTURE=!ARCHITECTURE_32BIT!
  )
  IF "!ARGUMENT!" == "!ARGUMENT_TARGET_ARCHITECTURE_64BIT!" (
    REM Ensure the 64-bit build would be able to proceed
    IF NOT !SYSTEM_ARCHITECTURE! EQU !ARCHITECTURE_64BIT! (
      ECHO Invalid System Architecture: Unable to build 64-bit project on 32-bit OS
      EXIT /B !EXIT_CODE_INVALID_SYSTEM_ARCHITECTURE!
    )
    SET TARGET_ARCHITECTURE=!ARCHITECTURE_64BIT!
  )

  REM Enable package build
  IF "!ARGUMENT!" == "!ARGUMENT_ENABLE_BUILD_PACKAGES!" (
    SET ENABLE_BUILD_PACKAGES=!TRUE!

    REM Make sure the version information exists
    IF [%2] == [] (
      ECHO Invalid Version: Version must be supplied when enabling packages
      EXIT /B !EXIT_CODE_INVALID_VERSION!
    ) ELSE (
      REM Get the version information
      SET "BUILD_PACKAGE_VERSION=%2"
      SHIFT
    )
  )

  REM PHP version (5.4, 5.5, and 5.6)
  IF "!ARGUMENT!" == "!ARGUMENT_PHP_VERSION!" (
    REM Make sure the version information exists
    IF [%2] == [] (
      ECHO Invalid Version: Version must be supplied when choosing PHP version
      EXIT /B !EXIT_CODE_INVALID_VERSION!
    ) ELSE (
      REM Ensure the PHP version is valid
      IF NOT "%2" == "5.4" (
        IF NOT "%2" == "5.5" (
          IF NOT "%2" == "5.6" (
            ECHO Invalid Version: Version not within range [5.4, 5.5, or 5.6]
            EXIT /B !EXIT_CODE_INVALID_VERSION!
          )
        )
      )

      REM Get the version information and format for branch/tag variable use
      IF "%2" == "5.4" (
        SET PHP_VERSION=5_4
      )
      IF "%2" == "5.5" (
        SET PHP_VERSION=5_5
      )
      IF "%2" == "5.6" (
        SET PHP_VERSION=5_6
      )
      SHIFT
    )
  )

  REM Disable clean build
  IF "!ARGUMENT!" == "!ARGUMENT_DISABLE_CLEAN_BUILD!" (
    SET ENABLE_CLEAN_BUILD=!FALSE!
  )

  REM Enable the use of zlib library in the cpp-driver
  IF "!ARGUMENT!" == "!ARGUMENT_ENABLE_ZLIB!" (
    SET ENABLE_ZLIB=!TRUE!
  )

  REM Enable the use of Boost atomics library in the cpp-driver
  IF "!ARGUMENT!" == "!ARGUMENT_USE_BOOST_ATOMIC!" (
    SET USE_BOOST_ATOMIC=!TRUE!
  )

  REM Help message
  IF "!ARGUMENT!" == "!ARGUMENT_HELP!" (
    CALL :DISPLAYHELP 0
    EXIT /B
  )

  REM Continue to loop through the command line arguments
  GOTO :ARGUMENT_LOOP
)

REM Set the PHP branch/tag version to use
FOR %%A IN (!PHP_VERSION!) DO (
  SET "PHP_BRANCH_TAG_VERSION=!PHP_%%A_BRANCH_TAG_VERSION!"
)

REM Determine Visual Studio Version(s) available
SET "VISUAL_STUDIO_INTERNAL_VERSIONS=120 110 100"
SET "VISUAL_STUDIO_INTERNAL_SHORTHAND_VERSIONS=12 11 10"
SET "VISUAL_STUDIO_VERSIONS=2013 2012 2010"
SET INDEX=0
FOR %%A IN (!VISUAL_STUDIO_INTERNAL_VERSIONS!) DO (
  SET /A INDEX+=1
  IF DEFINED VS%%ACOMNTOOLS SET "AVAILABLE_VISUAL_STUDIO_VERSIONS=!AVAILABLE_VISUAL_STUDIO_VERSIONS! !INDEX!"
)

REM Determine Windows SDK Version(s) available
SET "WINDOWS_SDK_VERSIONS=v7.1 v8.0 v8.1"
IF DEFINED WindowsSDKDir (
  IF DEFINED WindowsSDKVersionOverride (
    CALL :GETVALUE WindowsSDKVersionOverride WINDOWS_SDK_VERSION
    SET INDEX=0
    FOR %%A IN (!WINDOWS_SDK_VERSIONS!) DO (
      SET /A INDEX+=1
      CALL :GETARRAYELEMENT WINDOWS_SDK_VERSIONS !INDEX! CHECK_WINDOWS_SDK_VERSION
      IF "!WINDOWS_SDK_VERSION!" == "!CHECK_WINDOWS_SDK_VERSION!" SET WINDOWS_SDK_FOUND=!TRUE!
    )
  )
)

REM Display discovered Visual Studio version(s) and Windows SDK version
set NUMBER_OF_VERSIONS=0
FOR %%A IN (!AVAILABLE_VISUAL_STUDIO_VERSIONS!) DO (
  SET /A NUMBER_OF_VERSIONS+=1
)
IF DEFINED WINDOWS_SDK_FOUND SET /A NUMBER_OF_VERSIONS+=1

REM Determine if build can proceed
IF !NUMBER_OF_VERSIONS! EQU 0 (
  ECHO Visual Studio Not Found: Install Visual Studio 2010 - 2013 to complete build
  ECHO.
  ECHO	!DOWNLOAD_URL_VISUAL_STUDIO!
  CHOICE /N /T 15 /D N /M "Would you like to download Visual Studio 2013 Express now?"
  IF !ERRORLEVEL! EQU !YES! START !DOWNLOAD_URL_VISUAL_STUDIO!
  EXIT /B !EXIT_CODE_MISSING_VISUAL_STUDIO!
)

REM Ensure additional build dependencies are installed
SET "PATH=!PATH!;!SYSTEMDRIVE!\GnuWin32\bin"
CALL :GETFULLPATH "!BISON!" BISON_FOUND
IF NOT DEFINED BISON_FOUND (
  ECHO Bison Not Found in PATH: Bison is required to complete build
  ECHO Ensure Bison is installed in !SYSTEMDRIVE!\GnuWin32
  ECHO.
  ECHO	!DOWNLOAD_URL_BISON!
  CHOICE /N /T 15 /D N /M "Would you like to download Bison now?"
  IF !ERRORLEVEL! EQU !YES! START !DOWNLOAD_URL_BISON!
  EXIT /B !EXIT_CODE_MISSING_BUILD_DEPENDENCY!
)
CALL :GETFULLPATH "!CMAKE!" CMAKE_FOUND
IF NOT DEFINED CMAKE_FOUND (
  ECHO CMake Not Found in PATH: CMake v!MINIMUM_VERSION_REQUIRED_CMAKE! is required to complete build
  ECHO.
  ECHO	!DOWNLOAD_URL_CMAKE!
  CHOICE /N /T 15 /D N /M "Would you like to download CMake now?"
  IF !ERRORLEVEL! EQU !YES! START !DOWNLOAD_URL_CMAKE!
  EXIT /B !EXIT_CODE_MISSING_BUILD_DEPENDENCY!
) ELSE (
  FOR /F "TOKENS=1,2,3* DELIMS= " %%A IN ('!CMAKE! --version') DO IF NOT DEFINED CMAKE_VERSION SET CMAKE_VERSION=%%C
  CALL :COMPAREVERSION !CMAKE_VERSION! !MINIMUM_VERSION_REQUIRED_CMAKE!
  IF !ERRORLEVEL! EQU -1 (
    ECHO Invalid CMake Version Found: CMake v!MINIMUM_VERSION_REQUIRED_CMAKE! is required to complete build
    ECHO.
    ECHO	!DOWNLOAD_URL_CMAKE!
    CHOICE /N /T 15 /D N /M "Would you like to download CMake now?"
    IF !ERRORLEVEL! EQU !YES! START !DOWNLOAD_URL_CMAKE!
    EXIT /B !EXIT_CODE_INVALID_BUILD_DEPENDENCY_VERSION!
  )
)
CALL :GETFULLPATH "!GIT!" GIT_FOUND
IF NOT DEFINED GIT_FOUND (
  ECHO Git Not Found in PATH: Git is required to complete build
  ECHO.
  ECHO	!DOWNLOAD_URL_GIT!
  CHOICE /N /T 15 /D N /M "Would you like to download Git now?"
  IF !ERRORLEVEL! EQU !YES! START !DOWNLOAD_URL_GIT!
  EXIT /B !EXIT_CODE_MISSING_BUILD_DEPENDENCY!
)
CALL :GETFULLPATH "!PERL!" PERL_FOUND
IF NOT DEFINED PERL_FOUND (
  ECHO Perl Not Found in PATH: Perl is required to complete build
  ECHO.
  ECHO	!DOWNLOAD_URL_PERL!
  CHOICE /N /T 15 /D N /M "Would you like to download Perl now?"
  IF !ERRORLEVEL! EQU !YES! START !DOWNLOAD_URL_PERL!
  EXIT /B !EXIT_CODE_MISSING_BUILD_DEPENDENCY!
)
CALL :GETFULLPATH "!PYTHON!" PYTHON_FOUND
IF NOT DEFINED PYTHON_FOUND (
  ECHO Python Not Found in PATH: Python v!MINIMUM_VERSION_REQUIRED_PYTHON! is required to complete build
  ECHO.
  ECHO	!DOWNLOAD_URL_PYTHON!
  CHOICE /N /T 15 /D N /M "Would you like to download Python now?"
  IF !ERRORLEVEL! EQU !YES! START !DOWNLOAD_URL_PYTHON!
  EXIT /B !EXIT_CODE_MISSING_BUILD_DEPENDENCY!
) ELSE (
  FOR /F "TOKENS=1,2* DELIMS= " %%A IN ('!PYTHON! --version 2^>^&1') DO IF NOT DEFINED PYTHON_VERSION SET PYTHON_VERSION=%%B
  CALL :COMPAREVERSION !PYTHON_VERSION! !MINIMUM_VERSION_REQUIRED_PYTHON!
  IF !ERRORLEVEL! EQU -1 (
    ECHO Invalid Python Version Found: Python v!MINIMUM_VERSION_REQUIRED_PYTHON! is required to complete build
    ECHO.
    ECHO	!DOWNLOAD_URL_PYTHON!
    CHOICE /N /T 15 /D N /M "Would you like to download Python now?"
    IF !ERRORLEVEL! EQU !YES! START !DOWNLOAD_URL_PYTHON!
    EXIT /B !EXIT_CODE_INVALID_BUILD_DEPENDENCY_VERSION!
  )
  REM Python v3.x does not work properly with GYP (libuv build dependency)
  CALL :COMPAREVERSION !PYTHON_VERSION! 3.0.0
  IF !ERRORLEVEL! GEQ 0 (
    ECHO Invalid Python Version Found: Python v3.x is not supported
    ECHO.
    ECHO	!DOWNLOAD_URL_PYTHON!
    CHOICE /N /T 15 /D N /M "Would you like to download Python now?"
    IF !ERRORLEVEL! EQU !YES! START !DOWNLOAD_URL_PYTHON!
    EXIT /B !EXIT_CODE_INVALID_BUILD_DEPENDENCY_VERSION!
  )
)

REM Determine if we should allow the user to choose compiler version
IF "!ENABLE_BUILD_PACKAGES!" == "!FALSE!" (
  IF !NUMBER_OF_VERSIONS! GTR 1 (
    REM Display discovered Visual Studio versions for selection
    SET INDEX=0
    SET SELECTION_OPTIONS=
    FOR %%A IN (!AVAILABLE_VISUAL_STUDIO_VERSIONS!) DO (
      SET /A INDEX+=1
      SET "SELECTION_OPTIONS=!SELECTION_OPTIONS!!INDEX!"
      CALL :GETARRAYELEMENT VISUAL_STUDIO_VERSIONS %%A VISUAL_STUDIO_VERSION
      ECHO !INDEX!^) Visual Studio !VISUAL_STUDIO_VERSION!
    )

    REM Display discovered Windows SDK version for selection
    IF DEFINED WINDOWS_SDK_FOUND (
      SET /A INDEX+=1
      SET "SELECTION_OPTIONS=!SELECTION_OPTIONS!!INDEX!"
      SET WINDOWS_SDK_SELECTION_OPTION=!INDEX!
      ECHO !INDEX!^) Windows SDK !WINDOWS_SDK_VERSION!
    )

    REM Add the exit option
    ECHO E^) Exit
    SET "SELECTION_OPTIONS=!SELECTION_OPTIONS!E"

    REM Present selection to the user
    CHOICE /C !SELECTION_OPTIONS! /N /T 60 /D E /M "Please Select a Compiler:"
    IF !ERRORLEVEL! GTR !NUMBER_OF_VERSIONS! (
      EXIT /B
    )
    ECHO.

    REM Determine the selection
    IF !ERRORLEVEL! NEQ !WINDOWS_SDK_SELECTION_OPTION! (
      CALL :GETARRAYELEMENT AVAILABLE_VISUAL_STUDIO_VERSIONS !ERRORLEVEL! USER_SELECTION
      CALL :GETARRAYELEMENT VISUAL_STUDIO_INTERNAL_VERSIONS !USER_SELECTION! VISUAL_STUDIO_INTERNAL_VERSION
      CALL :GETARRAYELEMENT VISUAL_STUDIO_INTERNAL_SHORTHAND_VERSIONS !USER_SELECTION! VISUAL_STUDIO_INTERNAL_SHORTHAND_VERSION
      CALL :GETARRAYELEMENT VISUAL_STUDIO_VERSIONS !USER_SELECTION! VISUAL_STUDIO_VERSION

      REM Ensure the other versions of VSXXXCOMNTOOLS are undefined (unset)
      FOR %%A IN (!VISUAL_STUDIO_INTERNAL_VERSIONS!) DO (
        IF NOT %%A EQU !VISUAL_STUDIO_INTERNAL_VERSION! SET VS%%ACOMNTOOLS=
      )

      REM Ensure the Windows SDK version is undefined (unset)
      IF DEFINED WindowsSDKDir SET WindowsSDKDir=
    ) ELSE (
      SET WINDOWS_SDK_SELECTED=!TRUE!
    )
  ) ELSE (
    IF NOT DEFINED WINDOWS_SDK_FOUND (
      CALL :GETARRAYELEMENT VISUAL_STUDIO_INTERNAL_VERSIONS !AVAILABLE_VISUAL_STUDIO_VERSIONS! VISUAL_STUDIO_INTERNAL_VERSION
      CALL :GETARRAYELEMENT VISUAL_STUDIO_INTERNAL_SHORTHAND_VERSIONS !AVAILABLE_VISUAL_STUDIO_VERSIONS! VISUAL_STUDIO_INTERNAL_SHORTHAND_VERSION
      CALL :GETARRAYELEMENT VISUAL_STUDIO_VERSIONS !AVAILABLE_VISUAL_STUDIO_VERSIONS! VISUAL_STUDIO_VERSION
    ) ELSE (
      SET WINDOWS_SDK_SELECTED=!TRUE!
    )
  )

  REM Ensure the environment is setup correctly; if Windows SDK build environment
  IF DEFINED WINDOWS_SDK_FOUND (
    CALL :CONFIGUREWINDOWSSDKENVIRONMENT !BUILD_TYPE! !TARGET_ARCHITECTURE!
  )

  REM Setup the Visual Studio environment for compiling
  IF NOT DEFINED WINDOWS_SDK_SELECTED (
    CALL :CONFIGUREVISUALSTUDIOENVIRONMENT !VISUAL_STUDIO_INTERNAL_VERSION! !TARGET_ARCHITECTURE!
  )
  CALL :GETFULLPATH "!DEVENV!" DEVENV_FOUND
  CALL :GETFULLPATH "!MSBUILD!" MSBUILD_FOUND
  CALL :GETFULLPATH "!NMAKE!" NMAKE_FOUND

  REM Display summary of build options
  ECHO Build Type:          !BUILD_TYPE!
  ECHO Clean Build:         !ENABLE_CLEAN_BUILD!
  ECHO PHP Version:         !PHP_BRANCH_TAG_VERSION!
  ECHO Target Architecture: !TARGET_ARCHITECTURE!
  IF NOT DEFINED WINDOWS_SDK_SELECTED (
    ECHO Visual Studio:       !VISUAL_STUDIO_VERSION!
  ) ELSE (
    ECHO Windows SDK:         !WINDOWS_SDK_VERSION!
  )
  ECHO C/C++ Driver
  ECHO   zlib Enabled:      !ENABLE_ZLIB!
  ECHO   Use Boost Atomic:  !USE_BOOST_ATOMIC!
  ECHO.
) ELSE (
  REM Ensure package properties are set (ignore commandline arguments)
  SET BUILD_TYPE=!BUILD_TYPE_RELEASE!
  SET ENABLE_CLEAN_BUILD=!TRUE!
  SET ENABLE_ZLIB=!FALSE!

  REM Add common 7-zip locations to system path
  SET "PATH=!PATH!;!PROGRAMFILES!\7-zip;!PROGRAMFILES(X86)!\7-zip"

  REM Check for 7-zip to perform package installation
  CALL :GETFULLPATH "!ZIP!" ZIP_FOUND
  IF NOT DEFINED ZIP_FOUND (
    ECHO 7-zip Not Found in PATH: 7-zip is required to build packages
    ECHO.
    ECHO	!DOWNLOAD_URL_ZIP!
    CHOICE /N /T 15 /D N /M "Would you like to download 7-zip now?"
    IF !ERRORLEVEL! EQU !YES! START !DOWNLOAD_URL_ZIP!
    EXIT /B !EXIT_CODE_MISSING_BUILD_DEPENDENCY!
  )
)

REM Determine if the build should be cleaned
IF !ENABLE_CLEAN_BUILD! EQU !TRUE! (
  CALL :CLEANDIRECTORY "!ABSOLUTE_BUILD_DIRECTORY!" "Cleaning build directory"
  CALL :CLEANDIRECTORY "!ABSOLUTE_DEPENDENCIES_CPP_DRIVER_SOURCE_DIRECTORY!" "Cleaning cpp-driver submodule directory"
  ECHO.
)

REM Prepare the build directories
IF NOT EXIST "!ABSOLUTE_BUILD_DIRECTORY!" MKDIR "!ABSOLUTE_BUILD_DIRECTORY!"
IF NOT EXIST "!ABSOLUTE_DEPENDENCIES_DIRECTORY!" MKDIR "!ABSOLUTE_DEPENDENCIES_DIRECTORY!"
IF NOT EXIST "!ABSOLUTE_LOG_DIRECTORY!" MKDIR "!ABSOLUTE_LOG_DIRECTORY!"

REM Move to the dependencies directory
PUSHD "!ABSOLUTE_DEPENDENCIES_DIRECTORY!" > NUL

ECHO Cloning Library Dependencies

REM Initialize and update the cpp-driver submodule
IF NOT EXIST "!ABSOLUTE_DEPENDENCIES_CPP_DRIVER_SOURCE_DIRECTORY!\include\cassandra.h" (
  PUSHD "!ABSOLUTE_BATCH_DIRECTORY!\.." > NUL
  ECHO | SET /P=Update cpp-driver submodule ... 
  !GIT! submodule update --init --recursive > "!LOG_CPP_DRIVER_BUILD!" 2>&1
  IF !ERRORLEVEL! EQU 0 (
    ECHO done.
    POPD
    POPD
  ) ELSE (
    ECHO FAILED!
    ECHO 	See !LOG_CPP_DRIVER_BUILD! for more details
    EXIT /B !EXIT_CODE_CLONE_FAILED!
  )
)

REM Clone MPIR and checkout the appropriate tag
IF NOT EXIST "!ABSOLUTE_DEPENDENCIES_MPIR_SOURCE_DIRECTORY!" (
  ECHO | SET /P=Cloning MPIR ... 
  !GIT! clone !MPIR_REPOSITORY_URL! "!ABSOLUTE_DEPENDENCIES_MPIR_SOURCE_DIRECTORY!" > "!LOG_MPIR_BUILD!" 2>&1
  IF !ERRORLEVEL! EQU 0 (
    ECHO done.
    PUSHD "!ABSOLUTE_DEPENDENCIES_MPIR_SOURCE_DIRECTORY!" > NUL
    ECHO | SET /P=Checking out !MPIR_BRANCH_TAG_VERSION! ... 
    ECHO. >> !LOG_MPIR_BUILD!
    !GIT! checkout !MPIR_BRANCH_TAG_VERSION! >> "!LOG_MPIR_BUILD!" 2>&1
    IF !ERRORLEVEL! EQU 0 (
      ECHO done.
    ) ELSE (
      ECHO FAILED!
      ECHO 	See !LOG_MPIR_BUILD! for more details
      EXIT /B !EXIT_CODE_CHECKOUT_FAILED!
    )
    POPD
  ) ELSE (
    ECHO FAILED!
    ECHO 	See !LOG_MPIR_BUILD! for more details
    EXIT /B !EXIT_CODE_CLONE_FAILED!
  )
)

REM Clone PHP and checkout the appropriate tag
IF NOT EXIST "!ABSOLUTE_DEPENDENCIES_PHP_SOURCE_DIRECTORY!" (
  ECHO | SET /P=Cloning PHP ... 
  !GIT! clone !PHP_REPOSITORY_URL! "!ABSOLUTE_DEPENDENCIES_PHP_SOURCE_DIRECTORY!" > "!LOG_PHP_BUILD!" 2>&1
  IF !ERRORLEVEL! EQU 0 (
    ECHO done.
    PUSHD "!ABSOLUTE_DEPENDENCIES_PHP_SOURCE_DIRECTORY!" > NUL
    ECHO | SET /P=Checking out !PHP_BRANCH_TAG_VERSION! ... 
    ECHO. >> !LOG_PHP_BUILD!
    !GIT! checkout !PHP_BRANCH_TAG_VERSION! >> "!LOG_PHP_BUILD!" 2>&1
    IF !ERRORLEVEL! EQU 0 (
      ECHO done.
    ) ELSE (
      ECHO FAILED!
      ECHO 	See !LOG_PHP_BUILD! for more details
      EXIT /B !EXIT_CODE_CHECKOUT_FAILED!
    )
    POPD
  ) ELSE (
    ECHO FAILED!
    ECHO 	See !LOG_PHP_BUILD! for more details
    EXIT /B !EXIT_CODE_CLONE_FAILED!
  )
)

REM Move back to working directory
POPD

REM Determine if the packages are being built
ECHO.
IF "!ENABLE_BUILD_PACKAGES!" == "!FALSE!" (
  ECHO Building Library Dependencies

  REM Determine if the cpp-driver needs to be built
  IF NOT EXIST "!ABSOLUTE_DEPENDENCIES_CPP_DRIVER_LIBRARIES_DIRECTORY!" (
    SET CPP_DRIVER_TARGET_COMPILER=!VISUAL_STUDIO_INTERNAL_VERSION!
    IF !WINDOWS_SDK_SELECTED! EQU !TRUE! SET CPP_DRIVER_TARGET_COMPILER=WINSDK
    CALL :BUILDCPPDRIVER "!ABSOLUTE_DEPENDENCIES_CPP_DRIVER_SOURCE_DIRECTORY!" !CPP_DRIVER_TARGET_COMPILER! "!ABSOLUTE_DEPENDENCIES_CPP_DRIVER_LIBRARIES_DIRECTORY!" !TARGET_ARCHITECTURE! !ENABLE_ZLIB! !USE_BOOST_ATOMIC! "!LOG_CPP_DRIVER_BUILD!"
    IF !ERRORLEVEL! NEQ 0 EXIT /B !ERRORLEVEL!
  )

  REM Determine if the MPIR library needs to be built
  IF NOT EXIST "!ABSOLUTE_DEPENDENCIES_MPIR_LIBRARIES_DIRECTORY!" (
    CALL :BUILDMPIR "!ABSOLUTE_DEPENDENCIES_MPIR_SOURCE_DIRECTORY!" "!ABSOLUTE_DEPENDENCIES_MPIR_LIBRARIES_DIRECTORY!" "!TARGET_ARCHITECTURE!" "!LOG_MPIR_BUILD!"
    IF !ERRORLEVEL! NEQ 0 EXIT /B !ERRORLEVEL!
  )

  REM Determine if the driver needs to be built
  IF NOT EXIST "!ABSOLUTE_DRIVER_LIBRARY_DIRECTORY!" (
    CALL :BUILDDRIVER "!ABSOLUTE_DEPENDENCIES_PHP_SOURCE_DIRECTORY!" "!ABSOLUTE_BATCH_DIRECTORY!" "!ABSOLUTE_DRIVER_LIBRARY_DIRECTORY!" "!ABSOLUTE_DEPENDENCIES_CPP_DRIVER_LIBRARIES_DIRECTORY!" "!ABSOLUTE_DEPENDENCIES_LIBUV_LIBRARIES_DIRECTORY!" "!ABSOLUTE_DEPENDENCIES_OPENSSL_LIBRARIES_DIRECTORY!" "!ABSOLUTE_DEPENDENCIES_MPIR_LIBRARIES_DIRECTORY!" "!LOG_DRIVER_BUILD!"
    IF !ERRORLEVEL! NEQ 0 EXIT /B !ERRORLEVEL!
  )

  REM Display success message with location to built driver library
  ECHO.
  ECHO Driver has been successfully built [!TARGET_ARCHITECTURE!-bit !BUILD_TYPE!]
  ECHO 	!ABSOLUTE_DRIVER_LIBRARY_DIRECTORY!
  GOTO :EOF
) ELSE (
  REM Ensure the Windows SDK version is undefined (unset)
  IF DEFINED WindowsSDKDir SET WindowsSDKDir=

  REM Store current Visual Studio tools environment variables
  FOR %%A IN (!VISUAL_STUDIO_INTERNAL_VERSIONS!) DO (
    SET "STORED_VS%%ACOMNTOOLS=!VS%%ACOMNTOOLS!"
  )

  REM Iterate through all available Visual Studio versions
  SET INDEX=0
  SET "STORED_PATH=!PATH!"
  FOR %%A IN (!AVAILABLE_VISUAL_STUDIO_VERSIONS!) DO (
    SET /A INDEX+=1
    CALL :GETARRAYELEMENT VISUAL_STUDIO_VERSIONS %%A VISUAL_STUDIO_VERSION
    CALL :GETARRAYELEMENT AVAILABLE_VISUAL_STUDIO_VERSIONS !INDEX! USER_SELECTION
    CALL :GETARRAYELEMENT VISUAL_STUDIO_INTERNAL_VERSIONS !USER_SELECTION! VISUAL_STUDIO_INTERNAL_VERSION
    CALL :GETARRAYELEMENT VISUAL_STUDIO_INTERNAL_SHORTHAND_VERSIONS !USER_SELECTION! VISUAL_STUDIO_INTERNAL_SHORTHAND_VERSION
    CALL :GETARRAYELEMENT VISUAL_STUDIO_VERSIONS !USER_SELECTION! VISUAL_STUDIO_VERSION	

    REM Determine if both 32 and 64-bit targets can be built
    SET AVAILABLE_TARGET_ARCHITECTURES=!ARCHITECTURE_32BIT!
    IF !SYSTEM_ARCHITECTURE! EQU !ARCHITECTURE_64BIT! (
      SET "AVAILABLE_TARGET_ARCHITECTURES=!AVAILABLE_TARGET_ARCHITECTURES! !ARCHITECTURE_64BIT!"
    )

    REM Ensure the other versions of VSXXXCOMNTOOLS are undefined (unset)
    FOR %%B IN (!VISUAL_STUDIO_INTERNAL_VERSIONS!) DO (
      SET VS%%BCOMNTOOLS=
      IF %%B EQU !VISUAL_STUDIO_INTERNAL_VERSION! SET "VS%%BCOMNTOOLS=!STORED_VS%%BCOMNTOOLS!"
    )

    REM Iterate through all available target architectures
    FOR %%C IN (!AVAILABLE_TARGET_ARCHITECTURES!) DO (
      REM Setup the Visual Studio environment
      CALL :CONFIGUREVISUALSTUDIOENVIRONMENT !VISUAL_STUDIO_INTERNAL_VERSION! %%C
      CALL :GETFULLPATH "!DEVENV!" DEVENV_FOUND
      CALL :GETFULLPATH "!MSBUILD!" MSBUILD_FOUND
      CALL :GETFULLPATH "!NMAKE!" NMAKE_FOUND

      REM Create the base installation locations
      SET DRIVER_PACKAGE_INSTALLATION_DIRECTORY=win%%C\msvc!VISUAL_STUDIO_INTERNAL_VERSION!
      SET DEPENDENCY_PACKAGE_INSTALLATION_DIRECTORY=!DRIVER_PACKAGE_INSTALLATION_DIRECTORY!\!DEPENDENCIES_DIRECTORY!
      SET "ABSOLUTE_CPP_DRIVER_DEPENDENCY_LIBUV_PACKAGE_INSTALLATION_DIRECTORY=!ABSOLUTE_PACKAGES_DIRECTORY!\!DEPENDENCY_PACKAGE_INSTALLATION_DIRECTORY!\!LIBUV_DIRECTORY!\!LIBRARY_TYPE_STATIC!"
      SET "ABSOLUTE_CPP_DRIVER_DEPENDENCY_OPENSSL_PACKAGE_INSTALLATION_DIRECTORY=!ABSOLUTE_PACKAGES_DIRECTORY!\!DEPENDENCY_PACKAGE_INSTALLATION_DIRECTORY!\!OPENSSL_DIRECTORY!\!LIBRARY_TYPE_STATIC!"
      SET "ABSOLUTE_CPP_DRIVER_PACKAGE_INSTALLATION_DIRECTORY=!ABSOLUTE_PACKAGES_DIRECTORY!\!DEPENDENCY_PACKAGE_INSTALLATION_DIRECTORY!\!CPP_DRIVER_DIRECTORY!"
      SET "ABSOLUTE_DRIVER_PACKAGE_INSTALLATION_DIRECTORY=!ABSOLUTE_PACKAGES_DIRECTORY!\!DRIVER_PACKAGE_INSTALLATION_DIRECTORY!"

      REM Build the cpp-driver
      IF !VISUAL_STUDIO_VERSION! EQU 2010 SET USE_BOOST_ATOMIC=!TRUE!
      SET CPP_DRIVER_TARGET_COMPILER=!VISUAL_STUDIO_INTERNAL_VERSION!
      CALL :BUILDCPPDRIVER "!ABSOLUTE_DEPENDENCIES_CPP_DRIVER_SOURCE_DIRECTORY!" !CPP_DRIVER_TARGET_COMPILER! "!ABSOLUTE_CPP_DRIVER_PACKAGE_INSTALLATION_DIRECTORY!" !TARGET_ARCHITECTURE! !FALSE! !USE_BOOST_ATOMIC! "!LOG_CPP_DRIVER_BUILD!"
      IF !ERRORLEVEL! NEQ 0 EXIT /B !ERRORLEVEL!

      REM Skip a line on the display
      ECHO.

      REM Build the zip packages for the current target architecture and Visual Studio version
      ECHO | SET /P=Building the driver package for Win%%C MSVC!VISUAL_STUDIO_INTERNAL_VERSION! ...
      ECHO !ZIP! a -tzip !ABSOLUTE_PACKAGES_DIRECTORY!\!BUILD_PACKAGE_PREFIX!-!BUILD_PACKAGE_VERSION!-win%%C-msvc!VISUAL_STUDIO_INTERNAL_VERSION!.zip -r !ABSOLUTE_DRIVER_PACKAGE_INSTALLATION_DIRECTORY!\ -xr^^!!DEPENDENCIES_DIRECTORY! >> "!LOG_PACKAGE_BUILD!"
      !ZIP! a -tzip "!ABSOLUTE_PACKAGES_DIRECTORY!\!BUILD_PACKAGE_PREFIX!-!BUILD_PACKAGE_VERSION!-win%%C-msvc!VISUAL_STUDIO_INTERNAL_VERSION!.zip" -r "!ABSOLUTE_DRIVER_PACKAGE_INSTALLATION_DIRECTORY!\*" -xr^^!!DEPENDENCIES_DIRECTORY! >> "!LOG_PACKAGE_BUILD!" 2>&1
      IF NOT !ERRORLEVEL! EQU 0 (
        ECHO FAILED!
        ECHO 	See !LOG_PACKAGE_BUILD! for more details
        EXIT /B !EXIT_CODE_PACKAGE_FAILED!
      )
      ECHO done.
      ECHO.

      REM Reset the system PATH
      SET "PATH=!STORED_PATH!"
    )
  )
)

REM Disable delayed expansion
ENDLOCAL

REM Exit the batch operation (Ensures below functions are skipped)
EXIT /B

REM Convert a string to uppercase
REM
REM @param string String to convert to uppercase
REM @param return Uppercase converted string
:UPPERCASE [string] [return]
  SET "UPPERCASE_ALPHABET=A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
  SET RETURN=%~1
  FOR %%A IN (!UPPERCASE_ALPHABET!) DO SET RETURN=!RETURN:%%A=%%A!
  SET %2=!RETURN!
  GOTO:EOF

REM Convert a string to lowercase
REM
REM @param string String to convert to lowercase
REM @param return Lowercase converted string
:LOWERCASE [string] [return]
  SET "LOWERCASE_ALPHABET=a b c d e f g h i j k l m n o p q r s t u v w x y z"
  SET RETURN=%~1
  FOR %%A IN (!LOWERCASE_ALPHABET!) DO SET RETURN=!RETURN:%%A=%%A!
  SET %2=!RETURN!
  GOTO:EOF

REM Display the help message and exit with error code
:DISPLAYHELP
  CALL :UPPERCASE !BATCH_FILENAME! BATCH_FILENAME_UPPERCASE
  ECHO Usage: !BATCH_FILENAME_UPPERCASE! [OPTION...]
  ECHO.
  ECHO     !ARGUMENT_BUILD_TYPE_DEBUG!                           Enable debug build
  ECHO     !ARGUMENT_BUILD_TYPE_RELEASE!                         Enable release build ^(default^)
  ECHO     !ARGUMENT_DISABLE_CLEAN_BUILD!                   Disable clean build
REM	ECHO     !ARGUMENT_ENABLE_BUILD_PACKAGES! [version]       Enable package generation
  ECHO     !ARGUMENT_PHP_VERSION! [version]           PHP version 5.4, 5.5, or 5.6
  IF !SYSTEM_ARCHITECTURE! EQU !ARCHITECTURE_32BIT! (
    ECHO     !ARGUMENT_TARGET_ARCHITECTURE_32BIT!                             Target 32-bit build ^(default^)
    ECHO     !ARGUMENT_TARGET_ARCHITECTURE_64BIT!                             Target 64-bit build
  ) ELSE (
    ECHO     !ARGUMENT_TARGET_ARCHITECTURE_32BIT!                             Target 32-bit build
    ECHO     !ARGUMENT_TARGET_ARCHITECTURE_64BIT!                             Target 64-bit build ^(default^)
  )
  ECHO.
  ECHO     C/C++ Driver Options
  ECHO       !ARGUMENT_ENABLE_ZLIB!                   Enable zlib
  ECHO       !ARGUMENT_USE_BOOST_ATOMIC!              Use Boost atomic
  ECHO.
  ECHO     !ARGUMENT_HELP!                            Display this message
  EXIT /B

REM Get an element from an array
REMMESSAGE("Unable to locate DataStax C/C++ driver");
REM @param array Global array to iterate through
REM @param index Index to retrieve
REM @param return Variable to assign retrieved value
:GETARRAYELEMENT [array] [index] [return]
  FOR /F "TOKENS=%~2" %%A IN ("!%~1!") DO SET %~3=%%A
  EXIT /B

REM Get a value from a key=value pair in an environment variable
REM
REM @param pair Key/Value pair to parse
REM @param return Value parsed from key/value pair
:GETVALUE [pair] [return]
  FOR /F "TOKENS=1,2* DELIMS==" %%A IN ('SET %~1') DO SET %~2=%%B
  EXIT /B

REM Get full path for a given executable in the system PATH
REM
REM @param executable Executable to search for in PATH
REM @param return Full path with executable
:GETFULLPATH [executable] [return]
  FOR %%A IN ("%~1") DO SET %~2=%%~$PATH:A
  EXIT /B

REM Compare two version numbers
REM
REM @param version-one Version to compare against another version number
REM @param version-two Version to compare against another version number
REM @return 1 if version-one > version-two
REM         0 if version-one == version-two
REM         -1 if version-one < version-two
:COMPAREVERSION [version-one] [version-two]
  CALL :GETVERSIONINFORMATION %~1 VERSION_ONE_MAJOR VERSION_ONE_MINOR VERSION_ONE_PATCH
  CALL :GETVERSIONINFORMATION %~2 VERSION_TWO_MAJOR VERSION_TWO_MINOR VERSION_TWO_PATCH
  IF !VERSION_ONE_MAJOR! GTR !VERSION_TWO_MAJOR! EXIT /B 1
  IF !VERSION_ONE_MAJOR! LSS !VERSION_TWO_MAJOR! EXIT /B -1
  IF NOT DEFINED VERSION_ONE_MINOR IF NOT DEFINED VERSION_TWO_MINOR EXIT /B 0
  IF !VERSION_ONE_MINOR! GTR !VERSION_TWO_MINOR! EXIT /B 1
  IF !VERSION_ONE_MINOR! LSS !VERSION_TWO_MINOR! EXIT /B -1
  IF NOT DEFINED VERSION_ONE_PATCH IF NOT DEFINED VERSION_TWO_PATCH EXIT /B 0
  IF !VERSION_ONE_PATCH! GTR !VERSION_TWO_PATCH! EXIT /B 1
  IF !VERSION_ONE_PATCH! LSS !VERSION_TWO_PATCH! EXIT /B -1
  EXIT /B 0

REM Get version breakdown [major.minor.patch]
REM
REM @param version String representing the full version
REM @param return-major Major version number parsed from version
REM @param return-minor Minor version number parsed from version
REM @param return-patch Patch version number parsed from version
:GETVERSIONINFORMATION [version] [return-major] [return-minor] [return-patch]
  FOR /F "TOKENS=1,2,3* DELIMS=." %%A IN ("%~1") DO (
    SET %~2=%%A
    SET %~3=%%B
    SET %~4=%%C
  )
  EXIT /B

REM Configure the Windows SDK environment
REM
REM @param build-type Debug or release
REM @param target-architecture 32 or 64-bit
:CONFIGUREWINDOWSSDKENVIRONMENT [build-type] [target-architecture]
  REM Ensure Windows SDK environment is configured correctly
  IF "%~1" == "!BUILD_TYPE_DEBUG!" CALL SetEnv /Debug > NUL 2>&1
  IF "%~1" == "!BUILD_TYPE_RELEASE!" CALL SetEnv /Release > NUL 2>&1
  IF "%~2" == "!ARCHITECTURE_32BIT!" CALL SetEnv /x86 > NUL 2>&1
  IF "%~2" == "!ARCHITECTURE_64BIT!" CALL SetEnv /x64 > NUL 2>&1
  EXIT /B

REM Configure Visual Studio environment
REM
REM @param internal-version Visual Studio interal version (e.b 100, 110,
REM                         120, ...etc)
REM @param target-architecture 32 or 64-bit
:CONFIGUREVISUALSTUDIOENVIRONMENT [internal-version] [target-architecture]
  SET VISUAL_STUDIO_ENVIRONMENT_VARIABLE=VS%~1COMNTOOLS
  CALL :GETVALUE !VISUAL_STUDIO_ENVIRONMENT_VARIABLE! VISUAL_STUDIO_COMMON_TOOLS_DIRECTORY
  IF %~2 EQU !ARCHITECTURE_32BIT! (
    IF NOT EXIST "!VISUAL_STUDIO_COMMON_TOOLS_DIRECTORY!\vsvars32.bat" (
      ECHO Unable to Setup 32-bit Build Environment: !VISUAL_STUDIO_COMMON_TOOLS_DIRECTORY!\vsvars32.bat is missing
      EXIT /B !EXIT_CODE_MISSING_VISUAL_STUDIO!
    )
    CALL "!VISUAL_STUDIO_COMMON_TOOLS_DIRECTORY!\vsvars32.bat"
  ) ELSE (
    IF NOT EXIST "!VISUAL_STUDIO_COMMON_TOOLS_DIRECTORY!\..\..\VC\bin\x86_amd64\vcvarsx86_amd64.bat" (
      ECHO Unable to Setup 64-bit Build Environment: !VISUAL_STUDIO_COMMON_TOOLS_DIRECTORY!\..\..\VC\bin\x86_amd64\vcvarsx86_amd64.bat is missing
      EXIT /B !EXIT_CODE_MISSING_VISUAL_STUDIO!
    )
    CALL "!VISUAL_STUDIO_COMMON_TOOLS_DIRECTORY!\..\..\VC\bin\x86_amd64\vcvarsx86_amd64.bat"
  )
  EXIT /B

REM Clean/Delete a directory
REM
REM @param directory Directory to clean
REM @param message Message to display during clean
:CLEANDIRECTORY [directory] [message]
  IF EXIST "%~1" (
    ECHO | SET /P=%~2 ... 
    RMDIR /S /Q "%~1" > NUL 2>&1
    IF NOT EXIST "%~1" (
      ECHO done.
    ) ELSE (
      ECHO not fully cleaned ... directory is in use.
    )
  )
  EXIT /B

REM Shorten a directory/path
REM
REM @param directory Directory to shorten
REM @parem return-directory Shortened directory
:SHORTENPATH [directory] [return-directory]
  FOR %%A IN ("%~1") DO SET %~2=%%~SA
  EXIT /B

REM Build the driver library
REM
REM @param source-directory Location of driver source
REM @param target-compiler Target compiler to use for compiling the cpp-driver
REM @param install-directory Installation location of the cpp-driver
REM @param target-architecture 32 or 64-bit
REM @param enable-zlib True if zlib should be enabled; false otherwise
REM @param use-boost-atomic True if Boost atomic library should be used; false
REM                         otherwise
REM @param log-filename Absolute path and filename for log output
:BUILDCPPDRIVER [source-directory] [target-compiler] [install-directory] [target-architecture] [enable-zlib] [use-boost-atomic] [log-filename]
  REM Create cpp-driver variables from arguments
  SET "CPP_DRIVER_SOURCE_DIRECTORY=%~1"
  SHIFT
  SET "CPP_DRIVER_TARGET_COMPILER=%~1"
  SHIFT
  SET "CPP_DRIVER_INSTALLATION_DIRECTORY=%~1"
  SHIFT
  SET "CPP_DRIVER_TARGET_ARCHITECTURE=%~1"
  SHIFT
  SET "CPP_DRIVER_ENABLE_ZLIB=%~1"
  SHIFT
  SET "CPP_DRIVER_USE_BOOST_ATOMIC=%~1"
  SHIFT
  SET "CPP_DRIVER_LOG_FILENAME=%~1"

  REM Build the cpp-driver
  ECHO | SET /P=Building and installing cpp-driver ... 
  PUSHD "!CPP_DRIVER_SOURCE_DIRECTORY!" > NUL
  SET "CPP_DRIVER_BUILD_COMMAND_LINE=--TARGET-COMPILER !CPP_DRIVER_TARGET_COMPILER! --INSTALL-DIR !CPP_DRIVER_INSTALLATION_DIRECTORY! --STATIC"
  IF !CPP_DRIVER_TARGET_ARCHITECTURE! EQU !ARCHITECTURE_64BIT! (
    SET "CPP_DRIVER_BUILD_COMMAND_LINE=!CPP_DRIVER_BUILD_COMMAND_LINE! --X64"
  ) ELSE (
    SET "CPP_DRIVER_BUILD_COMMAND_LINE=!CPP_DRIVER_BUILD_COMMAND_LINE! --X86"
  )
  IF !CPP_DRIVER_ENABLE_ZLIB! EQU !TRUE! (
    SET "CPP_DRIVER_BUILD_COMMAND_LINE=!CPP_DRIVER_BUILD_COMMAND_LINE! --ENABLE-ZLIB"
  )
  IF !CPP_DRIVER_USE_BOOST_ATOMIC! EQU !TRUE! (
    SET "CPP_DRIVER_BUILD_COMMAND_LINE=!CPP_DRIVER_BUILD_COMMAND_LINE! --USE-BOOST-ATOMIC"
  )
  ECHO vc_build.bat !CPP_DRIVER_BUILD_COMMAND_LINE! >> "!CPP_DRIVER_LOG_FILENAME!" 2>&1
  CALL vc_build.bat !CPP_DRIVER_BUILD_COMMAND_LINE! >> "!CPP_DRIVER_LOG_FILENAME!" 2>&1
  IF NOT !ERRORLEVEL! EQU 0 (
    ECHO FAILED!
    ECHO 	See !CPP_DRIVER_LOG_FILENAME! for more details
    EXIT /B !EXIT_CODE_BUILD_DEPENDENCY_FAILED!
  )
  POPD
  ECHO done.
  EXIT /B

REM Build the MPIR library
REM
REM @param source-directory Location of MPIR source
REM @param install-directory Installation location of MPIR library
REM @param target-architecture 32 or 64-bit
REM @param log-filename Absolute path and filename for log output
:BUILDMPIR [source-directory] [install-directory] [target-architecture] [log-filename]
  REM Create MPIR variables from arguments
  SET "MPIR_SOURCE_DIRECTORY=%~1"
  SHIFT
  SET "MPIR_INSTALLATION_DIRECTORY=%~1"
  SHIFT
  SET "MPIR_TARGET_ARCHITECTURE=%~1"
  SHIFT
  SET "MPIR_LOG_FILENAME=%~1"

  REM Attempt to upgrade the solution
  PUSHD "!MPIR_SOURCE_DIRECTORY!" > NUL
  IF DEFINED DEVENV_FOUND (
    ECHO | SET /P=Upgrading MPIR solution ... 
    !DEVENV! !build.vc10\mpir.sln /upgrade >> "!MPIR_LOG_FILENAME!" 2>&1
    IF NOT !ERRORLEVEL! EQU 0 (
      ECHO FAILED!
      ECHO 	See !MPIR_LOG_FILENAME! for more details
      EXIT /B !EXIT_CODE_BUILD_DEPENDENCY_FAILED!
    )
    ECHO done.
  )
  REM Build MPIR
  ECHO | SET /P=Building MPIR ... 
  SET MPIR_PLATFORM_ARCHITECTURE=Win32
  IF !MPIR_TARGET_ARCHITECTURE! EQU !ARCHITECTURE_64BIT! SET MPIR_PLATFORM_ARCHITECTURE=x64
  ECHO !MSBUILD! build.vc10\mpir.sln /T:lib_mpir_gc /P:Configuration=!BUILD_TYPE! /P:Platform=!MPIR_PLATFORM_ARCHITECTURE! /CLP:NoSummary;NoItemAndPropertyList;Verbosity=minimal /NOLOGO >> "!MPIR_LOG_FILENAME!" 2>&1
  !MSBUILD! build.vc10\mpir.sln /T:lib_mpir_gc /P:Configuration=!BUILD_TYPE! /P:Platform=!MPIR_PLATFORM_ARCHITECTURE! /CLP:NoSummary;NoItemAndPropertyList;Verbosity=minimal /NOLOGO >> "!MPIR_LOG_FILENAME!" 2>&1
  IF NOT !ERRORLEVEL! EQU 0 (
    ECHO FAILED!
    ECHO 	See !MPIR_LOG_FILENAME! for more details
    EXIT /B !EXIT_CODE_BUILD_DEPENDENCY_FAILED!
  )
  ECHO done.
  REM Install MPIR
  ECHO | SET /P=Installing MPIR ... 
  IF NOT EXIST "!MPIR_INSTALLATION_DIRECTORY!\include" MKDIR "!MPIR_INSTALLATION_DIRECTORY!\include"
  XCOPY /Y gmp.h "!MPIR_INSTALLATION_DIRECTORY!\include" >> "!MPIR_LOG_FILENAME!" 2>&1
  IF NOT !ERRORLEVEL! EQU 0 (
    ECHO FAILED!
    ECHO 	See !MPIR_LOG_FILENAME! for more details
    RMDIR /S /Q "!MPIR_INSTALLATION_DIRECTORY!"
    EXIT /B !EXIT_CODE_BUILD_DEPENDENCY_FAILED!
  )
  XCOPY /Y mpir.h "!MPIR_INSTALLATION_DIRECTORY!\include" >> "!MPIR_LOG_FILENAME!" 2>&1
  IF NOT !ERRORLEVEL! EQU 0 (
    ECHO FAILED!
    ECHO 	See !MPIR_LOG_FILENAME! for more details
    RMDIR /S /Q "!MPIR_INSTALLATION_DIRECTORY!"
    EXIT /B !EXIT_CODE_BUILD_DEPENDENCY_FAILED!
  )
  IF NOT EXIST "!MPIR_INSTALLATION_DIRECTORY!\lib" MKDIR "!MPIR_INSTALLATION_DIRECTORY!\lib"
  XCOPY /Y build.vc10\!MPIR_PLATFORM_ARCHITECTURE!\!BUILD_TYPE!\*.* "!MPIR_INSTALLATION_DIRECTORY!\lib" >> "!MPIR_LOG_FILENAME!" 2>&1
  IF NOT !ERRORLEVEL! EQU 0 (
    ECHO FAILED!
    ECHO 	See !MPIR_LOG_FILENAME! for more details
    RMDIR /S /Q "!MPIR_INSTALLATION_DIRECTORY!"
    EXIT /B !EXIT_CODE_BUILD_DEPENDENCY_FAILED!
  )
  POPD
  ECHO done.
  EXIT /B

REM Build the driver extension
REM
REM @param php-source-directory Location of PHP source
REM @param extension-source-directory Location of driver extension source
REM @param install-directory Installation location of driver extension library
REM @param cpp-driver-library-directory Library directory for cpp-driver
REM @param libuv-library-directory Library directory for libuv
REM @param openssl-library-directory Library directory for OpenSSL; empty
REM                                  string indicates OpenSSL disabled
REM @param mpir-library-directory Library directory for MPIR
REM @param log-filename Absolute path and filename for log output
:BUILDDRIVER [php-source-directory] [extension-source-directory] [install-directory] [cpp-driver-library-directory] [libuv-library-directory] [openssl-library-directory] [mpir-library-directory] [log-filename]
  REM Create php-driver variables from arguments
  SET "PHP_DRIVER_PHP_SOURCE_DIRECTORY=%~1"
  SHIFT
  SET "PHP_DRIVER_EXTENSION_SOURCE_DIRECTORY=%~1"
  SHIFT
  SET "PHP_DRIVER_INSTALLATION_DIRECTORY=%~1"
  SHIFT
  SET "PHP_DRIVER_CPP_DRIVER_LIBRARY_DIRECTORY=%~1"
  SHIFT
  SET "PHP_DRIVER_LIBUV_LIBRARY_DIRECTORY=%~1"
  SHIFT
  SET "PHP_DRIVER_OPENSSLLIBRARY_DIRECTORY=%~1"
  SHIFT
  SET "PHP_DRIVER_MPIR_LIBRARY_DIRECTORY=%~1"
  SHIFT
  SET "PHP_DRIVER_LOG_FILENAME=%~1"

  PUSHD "!PHP_DRIVER_PHP_SOURCE_DIRECTORY!" > NUL
  ECHO | SET /P=PHPIZE driver extension ... 
  ECHO CALL buildconf.bat --force --add-modules-dir="!PHP_DRIVER_EXTENSION_SOURCE_DIRECTORY!\.." >> "!PHP_DRIVER_LOG_FILENAME!" 2>&1
  CALL buildconf.bat --force --add-modules-dir="!PHP_DRIVER_EXTENSION_SOURCE_DIRECTORY!\.." >> "!PHP_DRIVER_LOG_FILENAME!" 2>&1
  IF NOT !ERRORLEVEL! EQU 0 (
    ECHO FAILED!
    ECHO 	See !PHP_DRIVER_LOG_FILENAME! for more details
    EXIT /B !EXIT_CODE_BUILD_DRIVER_FAILED!
  )
  ECHO done.
  ECHO | SET /P=Configure build and enable driver extension ... 
  ECHO configure.bat --with-prefix="!PHP_DRIVER_INSTALLATION_DIRECTORY!" --disable-all --enable-cli --enable-cassandra=shared --with-cassandra-cpp-driver="!PHP_DRIVER_CPP_DRIVER_LIBRARY_DIRECTORY!" --with-libuv-libs="!PHP_DRIVER_LIBUV_LIBRARY_DIRECTORY!" --with-openssl-libs="!PHP_DRIVER_OPENSSLLIBRARY_DIRECTORY!" --with-mpir="!PHP_DRIVER_MPIR_LIBRARY_DIRECTORY!" >> "!PHP_DRIVER_LOG_FILENAME!" 2>&1
  CALL configure.bat --with-prefix="!PHP_DRIVER_INSTALLATION_DIRECTORY!" --disable-all --enable-cli --enable-cassandra=shared --with-cassandra-cpp-driver="!PHP_DRIVER_CPP_DRIVER_LIBRARY_DIRECTORY!" --with-libuv-libs="!PHP_DRIVER_LIBUV_LIBRARY_DIRECTORY!" --with-openssl-libs="!PHP_DRIVER_OPENSSLLIBRARY_DIRECTORY!" --with-mpir="!PHP_DRIVER_MPIR_LIBRARY_DIRECTORY!" >> "!PHP_DRIVER_LOG_FILENAME!" 2>&1
  IF NOT !ERRORLEVEL! EQU 0 (
    ECHO FAILED!
    ECHO 	See !PHP_DRIVER_LOG_FILENAME! for more details
    EXIT /B !EXIT_CODE_BUILD_DRIVER_FAILED!
  )
  ECHO done.
  ECHO | SET /P=Building PHP executable and driver extension ... 
  !NMAKE! all >> "!PHP_DRIVER_LOG_FILENAME!" 2>&1
  IF NOT !ERRORLEVEL! EQU 0 (
    ECHO FAILED!
    ECHO 	See !PHP_DRIVER_LOG_FILENAME! for more details
    EXIT /B !EXIT_CODE_BUILD_DRIVER_FAILED!
  )
  ECHO done.
   ECHO | SET /P=Installing PHP executable and driver extension ... 
  !NMAKE! install >> "!PHP_DRIVER_LOG_FILENAME!" 2>&1
  IF NOT !ERRORLEVEL! EQU 0 (
    ECHO FAILED!
    ECHO 	See !PHP_DRIVER_LOG_FILENAME! for more details
    EXIT /B !EXIT_CODE_BUILD_DRIVER_FAILED!
  )
  ECHO done.
  POPD
