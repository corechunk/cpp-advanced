

@echo off
setlocal EnableDelayedExpansion

:: Set default values
set "version=17"
set "compilePath=."
set "exactPaths=disable"
set "createObjects=disable"

:: Check if srp/build.txt exists
if exist "srp\build.txt" (
    :: Read and parse srp/build.txt
    for /f "tokens=1,* delims=:" %%a in (srp\build.txt) do (
        if "%%a"=="version" set "version=%%b"
        if "%%a"=="path" set "compilePath=%%b"
        if "%%a"=="exactPaths" set "exactPaths=%%b"
        if "%%a"=="createObjects" set "createObjects=%%b"
    )
)

:: Handle exactPaths and createObjects: only enable if exactly "enable", otherwise disable
if "%exactPaths%"=="enable" (
    set "exactPaths=enable"
) else (
    set "exactPaths=disable"
)
if "%createObjects%"=="enable" (
    set "createObjects=enable"
) else (
    set "createObjects=disable"
)

:: Step 0: Clear all .o and .exe files in compilePath
if exist "%compilePath%" (
    del /q "%compilePath%\*.o" "%compilePath%\*.exe" 2>nul
)

:: Step 1: Create compilePath if it doesn't exist
if not exist "%compilePath%" (
    mkdir "%compilePath%" || (
        echo Error: Failed to create directory %compilePath%
        goto :eof
    )
)

:: Step 2: Collect .cpp files from src and lib with relative paths
set "cpp_files="
for /r src %%f in (*.cpp) do (
    set "file_path=%%f"
    set "file_path=!file_path:%CD%\=!"
    set "cpp_files=!cpp_files! !file_path!"
)
for /r lib %%f in (*.cpp) do (
    set "file_path=%%f"
    set "file_path=!file_path:%CD%\=!"
    set "cpp_files=!cpp_files! !file_path!"
)
:: Echo cpp_files
echo cpp_files: !cpp_files!

:: Check if any .cpp files were found
if not "!cpp_files!"=="" (
    :: Set include flags to essential directories only
    set "include_flags=-I. -Isrc -Ilib"
    :: Echo include_flags
    echo include_flags: !include_flags!

    :: Step 3: Compile based on createObjects
    if "!createObjects!"=="enable" (
        set "obj_files="
        :: Compile each .cpp to .o
        for %%f in (!cpp_files!) do (
            :: Get relative directory path (e.g., src, lib)
            set "rel_path=%%~dpf"
            :: Remove trailing backslash and ensure relative path
            set "rel_path=!rel_path:%CD%\=!"
            if "!rel_path:~-1!"=="\" set "rel_path=!rel_path:~0,-1!"
            :: Echo rel_path
            echo rel_path for %%f: !rel_path!
            if "!exactPaths!"=="enable" (
                if not exist "%compilePath%\!rel_path!" (
                    mkdir "%compilePath%\!rel_path!" || (
                        echo Error: Failed to create directory %compilePath%\!rel_path!
                        goto :eof
                    )
                )
                echo clang++ -std=c++!version! -c "%%f" !include_flags! -o "%compilePath%\!rel_path!\%%~nf.o"
                clang++ -std=c++!version! -c "%%f" !include_flags! -o "%compilePath%\!rel_path!\%%~nf.o"
            ) else (
                echo clang++ -std=c++!version! -c "%%f" !include_flags! -o "%compilePath%\%%~nf.o"
                clang++ -std=c++!version! -c "%%f" !include_flags! -o "%compilePath%\%%~nf.o"
            )
            if !errorlevel!==0 (
                if "!exactPaths!"=="enable" (
                    set "obj_files=!obj_files! %compilePath%\!rel_path!\%%~nf.o"
                ) else (
                    set "obj_files=!obj_files! %compilePath%\%%~nf.o"
                )
            ) else (
                echo Compilation failed for %%f
                goto :eof
            )
        )
        :: Link .o files to app.exe
        if not "!obj_files!"=="" (
            echo clang++ !obj_files! -o "%compilePath%\app.exe"
            clang++ !obj_files! -o "%compilePath%\app.exe"
            if !errorlevel!==0 (
                echo Link successful.
            ) else (
                echo Link failed.
                goto :eof
            )
        ) else (
            echo No object files generated.
            goto :eof
        )
    ) else (
        :: Compile directly to app.exe
        echo clang++ -std=c++!version! !cpp_files! !include_flags! -o "%compilePath%\app.exe"
        clang++ -std=c++!version! !cpp_files! !include_flags! -o "%compilePath%\app.exe"
        if !errorlevel!==0 (
            echo Compilation successful.
        ) else (
            echo Compilation failed.
            goto :eof
        )
    )

    :: Step 4: Run app.exe with all arguments (%*)
    if exist "%compilePath%\app.exe" (
        echo Running %compilePath%\app.exe with arguments: "%*"
        "%compilePath%\app.exe" %*
        if !errorlevel! neq 0 (
            echo Error: app.exe failed with exit code !errorlevel!
        )
    ) else (
        echo Error: %compilePath%\app.exe not found.
    )
) else (
    echo No .cpp files found in src or lib directories.
)

endlocal