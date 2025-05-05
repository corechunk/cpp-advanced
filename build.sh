#!/bin/bash
clear
# only created and specially set to work // these are not defaults //
compiler="g++"
version=17
compilePath="."
exactPaths="disable"
createObjects="disable"

optionReading="disable"
echoOptions="disable"

echoCppFiles="disable"
echoObjectFiles="disable"

echoIncludePaths="disable"
echoRelativePaths="disable"

echoCompileCommands="enable"

scriptDebug="enable"
echoExecutionArguments="enable"

# additional options by users && viewed depending on the options we created before
include_paths=""
library_paths=""
libraries=""

target_triple=""
extra_flags=""

halt="disable"
route=""

# Check if srp/build.txt exists
if [[ -f "srp/build.txt" ]]; then

    # Read and parse srp/build.txt, preserving spaces in values
    while IFS=':' read -r key value || [[ -n "$key" ]]; do
        # Skip empty lines or lines without a colon
        [[ -z "$key" ]] && continue
        # Trim whitespace and carriage returns from key, preserve value as-is
        key=$(echo "$key" | tr -d '[:space:]\r')
        value=$(echo "$value" | tr -d '\r')
        case "$key" in                                         #evaluated 19 variables from build.txt except compilePathWindows
            compiler) compiler="$value" ;;
            version) version="$value" ;;
            compilePathLinux) compilePath="$value" ;;          #compilerPathLinux is used as "compilerPath"
            exactPaths) exactPaths="$value" ;;
            createObjects) createObjects="$value" ;;
            optionReading) optionReading="$value" ;;
            echoOptions) echoOptions="$value" ;;
            echoCppFiles) echoCppFiles="$value" ;;
            echoIncludePaths) echoIncludePaths="$value" ;;
            echoRelativePaths) echoRelativePaths="$value" ;;
            echoCompileCommands) echoCompileCommands="$value" ;;
            scriptDebug) scriptDebug="$value" ;;
            echoExecutionArguments) echoExecutionArguments="$value" ;;
            echoObjectFiles) echoObjectFiles="$value" ;;
            include_paths) include_paths="$value" ;;
            library_paths) library_paths="$value" ;;
            libraries) libraries="$value" ;;
            target_triple) target_triple="$value" ;;
            extra_flags) extra_flags="$value" ;;
        esac
    done < <(cat "srp/build.txt")

    # echo and parse srp/build.txt, preserving spaces in values
    if [[ "$optionReading" == "enable" ]]; then
        echo \#\# these are live reading  :: [ see what is being read from the build.txt ]
        echo :
        echo :
        while IFS=':' read -r key value || [[ -n "$key" ]]; do
            # Trim whitespace and carriage returns from key, preserve value as-is
            key=$(echo "$key" | tr -d '[:space:]\r')
            value=$(echo "$value" | tr -d '\r')
                                                 #values might have multiple flag like -g and -o togather with space  // so space are needed
            if [[ "$optionReading" == "enable" ]]; then
                #[[ -z "$key" ]] && continue    # line skipping is commented out // for better space as build.txt while printing
                echo "$key : $value"
            fi
        done < <(cat "srp/build.txt")
        #echo :
        #echo :
    fi
fi

# Validate and set defaults only if not explicitly enable/disable
for var in exactPaths createObjects optionReading echoOptions echoCppFiles echoIncludePaths echoRelativePaths echoCompileCommands scriptDebug echoExecutionArguments echoObjectFiles; do
    if [[ "${!var}" != "enable" && "${!var}" != "disable" ]]; then
        case "$var" in
            echoCompileCommands|scriptDebug|echoExecutionArguments) eval "$var=enable" ;;
            *) eval "$var=disable" ;;
        esac
    fi
done
if [[ -z "$compiler" ]]; then
    compiler="g++"
fi
if [[ -z "$compilePath" ]]; then
    compilePath="."
fi

# Set target flag based on target_triple
target=""
[[ -n "$target_triple" ]] && target="-target $target_triple"

# Set halt and route based on extra_flags
if [[ "$extra_flags" =~ -E|--emit-llvm ]]; then
    halt="enable"
    route="-E"
elif [[ "$extra_flags" =~ -S ]]; then
    halt="enable"
    route="-S"
fi

# Warn if createObjects=disable and halt=enable
if [[ "$createObjects" == "disable" && "$halt" == "enable" ]]; then
    echo "ERROR: -E or -S requires createObjects=enable in build.txt."
    exit 1
fi

# Debug output for variables
if [[ "$echoOptions" == "enable" ]]; then
    echo . \# these are variables printing
    echo .
    echo "compiler: $compiler"
    echo "version: $version"
    #echo "compilePathWindows: $compilePathWindows"    ~not used in this script
    echo "compilePath: $compilePath          # compilerPathLinux from 'build.txt' is used as compilerPath in this script"
    echo "exactPaths: $exactPaths"
    echo "createObjects: $createObjects"
    echo .
    echo "include_paths: $include_paths"
    echo "library_paths: $library_paths"
    echo "libraries: $libraries"
    echo "target_triple: $target_triple"
    echo "extra_flags: $extra_flags"
    echo .
    echo "optionReading: $optionReading"
    echo "echoOptions: $echoOptions"
    echo .
    echo "echoCppFiles: $echoCppFiles"
    echo "echoObjectFiles: $echoObjectFiles"
    echo .
    echo "echoIncludePaths: $echoIncludePaths"
    echo "echoRelativePaths: $echoRelativePaths"
    echo .
    echo "echoCompileCommands: $echoCompileCommands"
    echo .
    echo "scriptDebug: $scriptDebug"
    echo "echoExecutionArguments: $echoExecutionArguments"
    echo "."
    echo "."
fi

# Step 0: # delete all object files     // takes millisecond to find all files if quantity is not like 50 files  // it is blazing fast
obj_files=()
while IFS= read -r file; do
    file_path="${file#$(pwd)/}"
    obj_files+=("$file_path")
done < <(find . -type f -name "*.o" 2>/dev/null)
for file in "${obj_files[@]}"; do
    rm -f "$file" 2>/dev/null
done
# delete all exe files
exe_files=()
while IFS= read -r file; do
    file_path="${file#$(pwd)/}"
    exe_files+=("$file_path")
done < <(find . -type f -name "*.exe" 2>/dev/null)
for file in "${exe_files[@]}"; do
    rm -f "$file" 2>/dev/null
done
# delete all files without an extension
linuxExecutable_files=()
while IFS= read -r file; do
    file_path="${file#$(pwd)/}"
    linuxExecutable_files+=("$file_path")
done < <(find . -type f -not -name "*.*" 2>/dev/null)
for file in "${linuxExecutable_files[@]}"; do
    rm -f "$file" 2>/dev/null
done
# delete all assembly files
assembly_files=()
while IFS= read -r file; do
    file_path="${file#$(pwd)/}"
    assembly_files+=("$file_path")
done < <(find . -type f -not -name "*.s" 2>/dev/null)
for file in "${assembly_files[@]}"; do
    rm -f "$file" 2>/dev/null
done
# delete all resolvedCPP files
resolvedCPP_files=()
while IFS= read -r file; do
    file_path="${file#$(pwd)/}"
    resolvedCPP_files+=("$file_path")
done < <(find . -type f -not -name "*.resolved.cpp" 2>/dev/null)
for file in "${resolvedCPP_files[@]}"; do
    rm -f "$file" 2>/dev/null
done

# Step 1: Create compilePath if it doesn't exist
if [[ ! -d "$compilePath" ]]; then
    mkdir -p "$compilePath" || {
        [[ "$scriptDebug" == "enable" ]] && echo "Error: Failed to create directory $compilePath"
        exit 1
    }
fi

# Step 2: Collect .cpp files from src and lib with relative paths
cpp_files=()
while IFS= read -r file; do
    file_path="${file#$(pwd)/}"
    cpp_files+=("$file_path")
done < <(find . -type f -name "*.cpp" 2>/dev/null)
# Echo cpp_files
if [[ "$echoCppFiles" == "enable" ]]; then
    echo "cpp_files: ${cpp_files[*]}"
fi

# Check if any .cpp files were found
if [[ ${#cpp_files[@]} -gt 0 ]]; then
    # Set include flags with user-specified paths
    include_flags="-I. -Isrc -Ilib $include_paths"
    # Echo include_flags
    if [[ "$echoIncludePaths" == "enable" ]]; then
        echo "include_flags: $include_flags"
    fi

    # Step 3: Compile based on createObjects
    if [[ "$createObjects" == "enable" ]]; then
        obj_files=()
        # Compile each .cpp to .o, .resolved.cpp, or .s
        for file in "${cpp_files[@]}"; do
            # Get relative directory path (e.g., src, lib)
            rel_path=$(dirname "$file")
            # Echo rel_path
            if [[ "$echoRelativePaths" == "enable" ]]; then
                echo "rel_path for $file: $rel_path"
            fi
            if [[ "$exactPaths" == "enable" ]]; then
                mkdir -p "$compilePath/$rel_path" || {
                    [[ "$scriptDebug" == "enable" ]] && echo "Error: Failed to create directory $compilePath/$rel_path"
                    exit 1
                }
                # Three-way branch based on route
                if [[ "$route" == "-E" ]]; then
                    [[ "$echoCompileCommands" == "enable" ]] && echo "$compiler $target -std=c++$version $extra_flags -E \"$file\" $include_flags -o \"$compilePath/$rel_path/$(basename "${file%.*}").resolved.cpp\""
                    $compiler $target -std=c++"$version" $extra_flags -E "$file" $include_flags -o "$compilePath/$rel_path/$(basename "${file%.*}").resolved.cpp"
                elif [[ "$route" == "-S" ]]; then
                    [[ "$echoCompileCommands" == "enable" ]] && echo "$compiler $target -std=c++$version $extra_flags -S \"$file\" $include_flags -o \"$compilePath/$rel_path/$(basename "${file%.*}").s\""
                    $compiler $target -std=c++"$version" $extra_flags -S "$file" $include_flags -o "$compilePath/$rel_path/$(basename "${file%.*}").s"
                else
                    [[ "$echoCompileCommands" == "enable" ]] && echo "$compiler $target -std=c++$version $extra_flags -c \"$file\" $include_flags -o \"$compilePath/$rel_path/$(basename "${file%.*}").o\""
                    $compiler $target -std=c++"$version" $extra_flags -c "$file" $include_flags -o "$compilePath/$rel_path/$(basename "${file%.*}").o"
                    if [[ $? -eq 0 ]]; then
                        obj_files+=("$compilePath/$rel_path/$(basename "${file%.*}").o")
                    elif [[ "$scriptDebug" == "enable" ]]; then
                        echo "Compilation failed for $file"
                        exit 1
                    else
                        echo "Warning: Compilation failed silently for $file (scriptDebug=disable)"
                    fi
                fi
            else
                # Three-way branch based on route
                if [[ "$route" == "-E" ]]; then
                    [[ "$echoCompileCommands" == "enable" ]] && echo "$compiler $target -std=c++$version $extra_flags -E \"$file\" $include_flags -o \"$compilePath/$(basename "${file%.*}").resolved.cpp\""
                    $compiler $target -std=c++"$version" $extra_flags -E "$file" $include_flags -o "$compilePath/$(basename "${file%.*}").resolved.cpp"
                elif [[ "$route" == "-S" ]]; then
                    [[ "$echoCompileCommands" == "enable" ]] && echo "$compiler $target -std=c++$version $extra_flags -S \"$file\" $include_flags -o \"$compilePath/$(basename "${file%.*}").s\""
                    $compiler $target -std=c++"$version" $extra_flags -S "$file" $include_flags -o "$compilePath/$(basename "${file%.*}").s"
                else
                    [[ "$echoCompileCommands" == "enable" ]] && echo "$compiler $target -std=c++$version $extra_flags -c \"$file\" $include_flags -o \"$compilePath/$(basename "${file%.*}").o\""
                    $compiler $target -std=c++"$version" $extra_flags -c "$file" $include_flags -o "$compilePath/$(basename "${file%.*}").o"
                    if [[ $? -eq 0 ]]; then
                        obj_files+=("$compilePath/$(basename "${file%.*}").o")
                    elif [[ "$scriptDebug" == "enable" ]]; then
                        echo "Compilation failed for $file"
                        exit 1
                    else
                        echo "Warning: Compilation failed silently for $file (scriptDebug=disable)"
                    fi
                fi
            fi
        done
        # Echo obj_files
        if [[ "$echoObjectFiles" == "enable" ]]; then
            echo "obj_files: ${obj_files[*]}"
        fi
        # Link .o files to app if halt=disable
        if [[ "$halt" == "disable" ]]; then
            if [[ ${#obj_files[@]} -gt 0 ]]; then
                [[ "$echoCompileCommands" == "enable" ]] && echo "$compiler $target ${obj_files[@]} -o \"$compilePath/app\" $library_paths $libraries"
                $compiler $target "${obj_files[@]}" -o "$compilePath/app" $library_paths $libraries
                if [[ "$scriptDebug" == "enable" ]]; then
                    if [[ $? -eq 0 ]]; then
                        echo "Link successful."
                    else
                        echo "Link failed."
                        exit 1
                    fi
                fi
            else
                [[ "$scriptDebug" == "enable" ]] && echo "No object files generated."
                exit 1
            fi
        fi
    else
        # Compile directly to app
        [[ "$echoCompileCommands" == "enable" ]] && echo "$compiler $target -std=c++$version $extra_flags ${cpp_files[*]} $include_flags -o \"$compilePath/app\" $library_paths $libraries"
        $compiler $target -std=c++"$version" $extra_flags "${cpp_files[@]}" $include_flags -o "$compilePath/app" $library_paths $libraries
        if [[ $? -ne 0 ]]; then
            [[ "$scriptDebug" == "enable" ]] && echo "Compilation failed."
            exit 1
        elif [[ "$scriptDebug" == "enable" ]]; then
            echo "Compilation successful."
        fi
    fi

    # Step 4: Run app with all arguments
    if [[ -f "$compilePath/app" ]]; then
        if [[ "$echoExecutionArguments" == "enable" ]]; then
            echo "Running $compilePath/app with arguments: \"$*\""
        fi
        pushd "$compilePath" >/dev/null
        ./app "$@"
        exit_code=$?
        popd >/dev/null
        if [[ "$scriptDebug" == "enable" && $exit_code -ne 0 ]]; then
            echo "Error: app failed with exit code $exit_code"
        fi
    else
        [[ "$scriptDebug" == "enable" ]] && echo "Error: $compilePath/app not found."
        exit 1
    fi
else
    [[ "$scriptDebug" == "enable" ]] && echo "No .cpp files found in src or lib directories."
    exit 1
fi
