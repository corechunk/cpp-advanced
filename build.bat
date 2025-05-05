cls
@echo off
setlocal EnableDelayedExpansion

:: only created and specially set to work // these are not defaults //
set "compiler=g++"
set "version=17"
set "compilePath=."
set "exactPaths=disable"
set "createObjects=disable"

set "optionReading=disable"
set "echoOptions=disable"

set "echoCppFiles=disable"
set "echoObjectFiles=disable"

set "echoIncludePaths=disable"
set "echoRelativePaths=disable"

set "echoCompileCommands=enable"

set "scriptDebug=enable"
set "echoExecutionArguments=enable"

:: additional options by users && viewed depending on the options we created before
set "include_paths="
set "library_paths="
set "libraries="

set "target_triple="
set "extra_flags="

set "halt=disable"
set "route="

:: Check if srp/build.txt exists
if exist "srp\build.txt" (

    :: Read and parse srp/build.txt, preserving spaces in values
    for /f "tokens=1,* delims=:" %%a in (srp\build.txt) do (
        set "key=%%a"
        set "value=%%b"
        :: Trim whitespace and carriage returns from key, preserve value as-is
        for /f "tokens=*" %%k in ("!key!") do set "key=%%k"
        for /f "tokens=*" %%v in ("!value!") do set "value=%%v"
        :: evaluated 19 variables from build.txt except compilePathWindows
        if "!key!"=="compiler" set "compiler=!value!"
        if "!key!"=="version" set "version=!value!"
        if "!key!"=="compilePathLinux" set "compilePath=!value!"
        if "!key!"=="exactPaths" set "exactPaths=!value!"
        if "!key!"=="createObjects" set "createObjects=!value!"
        if "!key!"=="optionReading" set "optionReading=!value!"
        if "!key!"=="echoOptions" set "echoOptions=!value!"
        if "!key!"=="echoCppFiles" set "echoCppFiles=!value!"
        if "!key!"=="echoIncludePaths" set "echoIncludePaths=!value!"
        if "!key!"=="echoRelativePaths" set "echoRelativePaths=!value!"
        if "!key!"=="echoCompileCommands" set "echoCompileCommands=!value!"
        if "!key!"=="scriptDebug" set "scriptDebug=!value!"
        if "!key!"=="echoExecutionArguments" set "echoExecutionArguments=!value!"
        if "!key!"=="echoObjectFiles" set "echoObjectFiles=!value!"
        if "!key!"=="include_paths" set "include_paths=!value!"
        if "!key!"=="library_paths" set "library_paths=!value!"
        if "!key!"=="libraries" set "libraries=!value!"
        if "!key!"=="target_triple" set "target_triple=!value!"
        if "!key!"=="extra_flags" set "extra_flags=!value!"
    )

    :: echo and parse srp/build.txt, preserving spaces in values
    if "!optionReading!"=="enable" (
        echo ## these are live reading  :: [ see what is being read from the build.txt ]
        echo :
        echo :
        for /f "delims=" %%l in (srp\build.txt) do (
            :: values might have multiple flag like -g and -o togather with space  // so space are needed
            echo %%l
        )
        :: echo :
        :: echo :
    )
)

:: Validate and set defaults only if not explicitly enable/disable
for %%v in (exactPaths createObjects optionReading echoOptions echoCppFiles echoIncludePaths echoRelativePaths echoCompileCommands scriptDebug echoExecutionArguments echoObjectFiles) do (
    if not "!%%v!"=="enable" if not "!%%v!"=="disable" (
        if "%%v"=="echoCompileCommands" (
            set "%%v=enable"
        ) else if "%%v"=="scriptDebug" (
            set "%%v=enable"
        ) else if "%%v"=="echoExecutionArguments" (
            set "%%v=enable"
        ) else (
            set "%%v=disable"
        )
        :: echoCompileCommands|scriptDebug|echoExecutionArguments) eval "$var=enable" ;;
        :: *) eval "$var=disable" ;;
    )
)
if "!compiler!"=="" set "compiler=g++"
if "!compilePath!"=="" set "compilePath=."

:: Set target flag based on target_triple
set "target="
if not "!target_triple!"=="" set "target=-target !target_triple!"

:: Set halt and route based on extra_flags
echo !extra_flags! | findstr /i "\-E \-\-emit-llvm" >nul && (
    set "halt=enable"
    set "route=-E"
)
echo !extra_flags! | findstr /i "\-S" >nul && (
    set "halt=enable"
    set "route=-S"
)

:: Warn if createObjects=disable and halt=enable
if "!createObjects!"=="disable" if "!halt!"=="enable" (
    echo ERROR: -E or -S requires createObjects=enable in build.txt.
    exit /b 1
)

:: Debug output for variables
if "!echoOptions!"=="enable" (
    echo . \# these are variables printing
    echo .
    echo compiler: !compiler!
    echo version: !version!
    :: echo compilePathWindows: $compilePathWindows    ~not used in this script
    echo compilePath: !compilePath!          # compilerPathLinux from 'build.txt' is used as compilerPath in this script
    echo exactPaths: !exactPaths!
    echo createObjects: !createObjects!
    echo .
    echo include_paths: !include_paths!
    echo library_paths: !library_paths!
    echo libraries: !libraries!
    echo target_triple: !target_triple!
    echo extra_flags: !extra_flags!
    echo .
    echo optionReading: !optionReading!
    echo echoOptions: !echoOptions!
    echo .
    echo echoCppFiles: !echoCppFiles!
    echo echoObjectFiles: !echoObjectFiles!
    echo .
    echo echoIncludePaths: !echoIncludePaths!
    echo echoRelativePaths: !echoRelativePaths!
    echo .
    echo echoCompileCommands: !echoCompileCommands!
    echo .
    echo scriptDebug: !scriptDebug!
    echo echoExecutionArguments: !echoExecutionArguments!
    echo .
    echo .
)

:: Step 0: # delete all object files     // takes millisecond to find all files if quantity is not like 50 files  // it is blazing fast
set "obj_files="
for /r . %%f in (*.o) do (
    set "file_path=%%f"
    set "file_path=!file_path:%CD%\=!"
    del "!file_path!" 2>nul
)
:: delete all exe files
set "exe_files="
for /r . %%f in (*.exe) do (
    set "file_path=%%f"
    set "file_path=!file_path:%CD%\=!"
    del "!file_path!" 2>nul
)
:: delete all files without an extension
set "linuxExecutable_files="
for /r . %%f in (*) do (
    set "file_path=%%f"
    set "file_path=!file_path:%CD%\=!"
    set "ext=%%~xf"
    if "!ext!"=="" (
        del "!file_path!" 2>nul
    )
)
:: delete all .s and .resolved.cpp files
for /r . %%f in (*.s) do (
    set "file_path=%%f"
    set "file_path=!file_path:%CD%\=!"
    del "!file_path!" 2>nul
)
for /r . %%f in (*.resolved.cpp) do (
    set "file_path=%%f"
    set "file_path=!file_path:%CD%\=!"
    del "!file_path!" 2>nul
)

:: Step 1: Create compilePath if it doesn't exist
if not exist "!compilePath!" (
    mkdir "!compilePath!" || (
        if "!scriptDebug!"=="enable" (
            echo Error: Failed to create directory !compilePath!
        )
        exit /b 1
    )
)

:: Step 2: Collect .cpp files from src and lib with relative paths
set "cpp_files="
for /r . %%f in (*.cpp) do (
    set "file_path=%%f"
    set "file_path=!file_path:%CD%\=!"
    set "cpp_files=!cpp_files! "!file_path!""
)
:: Echo cpp_files
if "!echoCppFiles!"=="enable" (
    echo cpp_files: !cpp_files!
)

:: Check if any .cpp files were found
if not "!cpp_files!"=="" (
    :: Set include flags with user-specified paths
    set "include_flags=-I. -Isrc -Ilib !include_paths!"
    :: Echo include_flags
    if "!echoIncludePaths!"=="enable" (
        echo include_flags: !include_flags!
    )

    :: Step 3: Compile based on createObjects
    if "!createObjects!"=="enable" (
        set "obj_files="
        :: Compile each .cpp to .o, .resolved.cpp, or .s
        for %%f in (!cpp_files!) do (
            :: Get relative directory path (e.g., src, lib)
            set "rel_path=%%~dpf"
            set "rel_path=!rel_path:%CD%\=!"
            if "!rel_path:~-1!"=="\" set "rel_path=!rel_path:~0,-1!"
            :: Echo rel_path
            if "!echoRelativePaths!"=="enable" (
                echo rel_path for %%f: !rel_path!
            )
            if "!exactPaths!"=="enable" (
                mkdir "!compilePath!\!rel_path!" || (
                    if "!scriptDebug!"=="enable" (
                        echo Error: Failed to create directory !compilePath!\!rel_path!
                    )
                    exit /b 1
                )
                :: Three-way branch based on route
                if "!route!"=="-E" (
                    if "!echoCompileCommands!"=="enable" (
                        echo !compiler! !target! -std=c++!version! !extra_flags! -E "%%f" !include_flags! -o "!compilePath!\!rel_path!\%%~nf.resolved.cpp"
                    )
                    !compiler! !target! -std=c++!version! !extra_flags! -E "%%f" !include_flags! -o "!compilePath!\!rel_path!\%%~nf.resolved.cpp"
                ) else if "!route!"=="-S" (
                    if "!echoCompileCommands!"=="enable" (
                        echo !compiler! !target! -std=c++!version! !extra_flags! -S "%%f" !include_flags! -o "!compilePath!\!rel_path!\%%~nf.s"
                    )
                    !compiler! !target! -std=c++!version! !extra_flags! -S "%%f" !include_flags! -o "!compilePath!\!rel_path!\%%~nf.s"
                ) else (
                    if "!echoCompileCommands!"=="enable" (
                        echo !compiler! !target! -std=c++!version! !extra_flags! -c "%%f" !include_flags! -o "!compilePath!\!rel_path!\%%~nf.o"
                    )
                    !compiler! !target! -std=c++!version! !extra_flags! -c "%%f" !include_flags! -o "!compilePath!\!rel_path!\%%~nf.o"
                    if !errorlevel!==0 (
                        set "obj_files=!obj_files! "!compilePath!\!rel_path!\%%~nf.o""
                    ) else if "!scriptDebug!"=="enable" (
                        echo Compilation failed for %%f
                        exit /b 1
                    ) else (
                        echo Warning: Compilation failed silently for %%f ^(scriptDebug=disable^)
                    )
                )
            ) else (
                :: Three-way branch based on route
                if "!route!"=="-E" (
                    if "!echoCompileCommands!"=="enable" (
                        echo !compiler! !target! -std=c++!version! !extra_flags! -E "%%f" !include_flags! -o "!compilePath!\%%~nf.resolved.cpp"
                    )
                    !compiler! !target! -std=c++!version! !extra_flags! -E "%%f" !include_flags! -o "!compilePath!\%%~nf.resolved.cpp"
                ) else if "!route!"=="-S" (
                    if "!echoCompileCommands!"=="enable" (
                        echo !compiler! !target! -std=c++!version! !extra_flags! -S "%%f" !include_flags! -o "!compilePath!\%%~nf.s"
                    )
                    !compiler! !target! -std=c++!version! !extra_flags! -S "%%f" !include_flags! -o "!compilePath!\%%~nf.s"
                ) else (
                    if "!echoCompileCommands!"=="enable" (
                        echo !compiler! !target! -std=c++!version! !extra_flags! -c "%%f" !include_flags! -o "!compilePath!\%%~nf.o"
                    )
                    !compiler! !target! -std=c++!version! !extra_flags! -c "%%f" !include_flags! -o "!compilePath!\%%~nf.o"
                    if !errorlevel!==0 (
                        set "obj_files=!obj_files! "!compilePath!\%%~nf.o""
                    ) else if "!scriptDebug!"=="enable" (
                        echo Compilation failed for %%f
                        exit /b 1
                    ) else (
                        echo Warning: Compilation failed silently for %%f ^(scriptDebug=disable^)
                    )
                )
            )
        )
        :: Echo obj_files
        if "!echoObjectFiles!"=="enable" (
            echo obj_files: !obj_files!
        )
        :: Link .o files to app if halt=disable
        if "!halt!"=="disable" (
            if not "!obj_files!"=="" (
                if "!echoCompileCommands!"=="enable" (
                    echo !compiler! !target! !obj_files! -o "!compilePath!\app.exe" !library_paths! !libraries!
                )
                !compiler! !target! !obj_files! -o "!compilePath!\app.exe" !library_paths! !libraries!
                if "!scriptDebug!"=="enable" (
                    if !errorlevel!==0 (
                        echo Link successful.
                    ) else (
                        echo Link failed.
                        exit /b 1
                    )
                )
            ) else (
                if "!scriptDebug!"=="enable" (
                    echo No object files generated.
                    exit /b 1
                )
            )
        )
    ) else (
        :: Compile directly to app
        if "!echoCompileCommands!"=="enable" (
            echo !compiler! !target! -std=c++!version! !extra_flags! !cpp_files! !include_flags! -o "!compilePath!\app.exe" !library_paths! !libraries!
        )
        !compiler! !target! -std=c++!version! !extra_flags! !cpp_files! !include_flags! -o "!compilePath!\app.exe" !library_paths! !libraries!
        if !errorlevel! neq 0 (
            if "!scriptDebug!"=="enable" (
                echo Compilation failed.
                exit /b 1
            )
        ) else if "!scriptDebug!"=="enable" (
            echo Compilation successful.
        )
    )

    :: Step 4: Run app with all arguments
    if exist "!compilePath!\app.exe" (
        if "!echoExecutionArguments!"=="enable" (
            echo Running !compilePath!\app.exe with arguments: "%*"
        )
        pushd "!compilePath!"
        app.exe %*
        set "exit_code=!errorlevel!"
        popd
        if "!scriptDebug!"=="enable" if !exit_code! neq 0 (
            echo Error: app failed with exit code !exit_code!
        )
    ) else (
        if "!scriptDebug!"=="enable" (
            echo Error: !compilePath!\app.exe not found.
            exit /b 1
        )
    )
) else (
    if "!scriptDebug!"=="enable" (
        echo No .cpp files found in src or lib directories.
        exit /b 1
    )
)

endlocal
