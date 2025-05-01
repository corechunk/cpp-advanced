#!/bin/bash

# Set default values
version=17
compilePath="."
exactPaths="disable"
createObjects="disable"
optionReading="disable"
echoOptions="disable"
echoCppFiles="disable"
echoIncludePaths="disable"
echoRelativePaths="disable"
echoCompileCommands="enable"
scriptDebug="enable"
echoExecutionArguments="enable"
echoObjectFiles="disable"

# Check if srp/build.txt exists
if [[ -f "srp/build.txt" ]]; then
    # Read and parse srp/build.txt, handling missing trailing newline
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines or lines without a colon
        [[ -z "$line" || "$line" != *":"* ]] && continue
        key=$(echo "$line" | cut -d':' -f1 | tr -d '[:space:]\r')
        value=$(echo "$line" | cut -d':' -f2- | tr -d '[:space:]\r')
        if [[ "$optionReading" == "enable" ]]; then
            echo "Read: key='$key', value='$value'"  # Debug output
        fi
        case "$key" in
            version) version="$value" ;;
            compilePathLinux) compilePath="$value" ;;
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
        esac
    done < <(cat "srp/build.txt" | tr -d '\r')
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

# Debug output for variables
if [[ "$echoOptions" == "enable" ]]; then
    echo "version: $version"
    echo "compilePath: $compilePath"
    echo "exactPaths: $exactPaths"
    echo "createObjects: $createObjects"
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
    echo .
    echo .
fi

# Step 0: Clear all .o and .exe files in compilePath
if [[ -d "$compilePath" ]]; then
    rm -f "$compilePath"/*.o "$compilePath"/*.exe 2>/dev/null
fi

# Step 1: Create compilePath if it doesn't exist
if [[ ! -d "$compilePath" ]]; then
    mkdir -p "$compilePath" || {
        if [[ "$scriptDebug" == "enable" ]]; then
            echo "Error: Failed to create directory $compilePath"
        fi
        exit 1
    }
fi

# Step 2: Collect .cpp files from src and lib with relative paths
cpp_files=()
while IFS= read -r file; do
    file_path="${file#$(pwd)/}"
    cpp_files+=("$file_path")
done < <(find src lib -type f -name "*.cpp")
# Echo cpp_files
if [[ "$echoCppFiles" == "enable" ]]; then
    echo "cpp_files: ${cpp_files[*]}"
fi

# Check if any .cpp files were found
if [[ ${#cpp_files[@]} -gt 0 ]]; then
    # Set include flags to essential directories only
    include_flags="-I. -Isrc -Ilib"
    # Echo include_flags
    if [[ "$echoIncludePaths" == "enable" ]]; then
        echo "include_flags: $include_flags"
    fi

    # Step 3: Compile based on createObjects
    if [[ "$createObjects" == "enable" ]]; then
        obj_files=()
        # Compile each .cpp to .o
        for file in "${cpp_files[@]}"; do
            # Get relative directory path (e.g., src, lib)
            rel_path=$(dirname "$file")
            # Echo rel_path
            if [[ "$echoRelativePaths" == "enable" ]]; then
                echo "rel_path for $file: $rel_path"
            fi
            if [[ "$exactPaths" == "enable" ]]; then
                mkdir -p "$compilePath/$rel_path" || {
                    if [[ "$scriptDebug" == "enable" ]]; then
                        echo "Error: Failed to create directory $compilePath/$rel_path"
                    fi
                    exit 1
                }
                if [[ "$echoCompileCommands" == "enable" ]]; then
                    echo "clang++ -std=c++$version -c \"$file\" $include_flags -o \"$compilePath/$rel_path/$(basename "${file%.*}").o\""
                fi
                clang++ -std=c++"$version" -c "$file" $include_flags -o "$compilePath/$rel_path/$(basename "${file%.*}").o"
                # Always collect obj_files if compilation succeeds
                if [[ $? -eq 0 ]]; then
                    obj_files+=("$compilePath/$rel_path/$(basename "${file%.*}").o")
                elif [[ "$scriptDebug" == "enable" ]]; then
                    echo "Compilation failed for $file"
                    exit 1
                else
                    echo "Warning: Compilation failed silently for $file (scriptDebug=disable)"
                fi
            else
                if [[ "$echoCompileCommands" == "enable" ]]; then
                    echo "clang++ -std=c++$version -c \"$file\" $include_flags -o \"$compilePath/$(basename "${file%.*}").o\""
                fi
                clang++ -std=c++"$version" -c "$file" $include_flags -o "$compilePath/$(basename "${file%.*}").o"
                # Always collect obj_files if compilation succeeds
                if [[ $? -eq 0 ]]; then
                    obj_files+=("$compilePath/$(basename "${file%.*}").o")
                elif [[ "$scriptDebug" == "enable" ]]; then
                    echo "Compilation failed for $file"
                    exit 1
                else
                    echo "Warning: Compilation failed silently for $file (scriptDebug=disable)"
                fi
            fi
        done
        # Echo obj_files
        if [[ "$echoObjectFiles" == "enable" ]]; then
            echo "obj_files: ${obj_files[*]}"
        fi
        # Link .o files to app.exe
        if [[ ${#obj_files[@]} -gt 0 ]]; then
            if [[ "$echoCompileCommands" == "enable" ]]; then
                echo "clang++ ${obj_files[*]} -o \"$compilePath/app.exe\""
            fi
            clang++ "${obj_files[@]}" -o "$compilePath/app.exe"
            if [[ "$scriptDebug" == "enable" ]]; then
                if [[ $? -eq 0 ]]; then
                    echo "Link successful."
                else
                    echo "Link failed."
                    exit 1
                fi
            fi
        else
            if [[ "$scriptDebug" == "enable" ]]; then
                echo "No object files generated."
                exit 1
            fi
        fi
    else
        # Compile directly to app.exe
        if [[ "$echoCompileCommands" == "enable" ]]; then
            echo "clang++ -std=c++$version ${cpp_files[*]} $include_flags -o \"$compilePath/app.exe\""
        fi
        clang++ -std=c++"$version" "${cpp_files[@]}" $include_flags -o "$compilePath/app.exe"
        if [[ "$scriptDebug" == "enable" ]]; then
            if [[ $? -eq 0 ]]; then
                echo "Compilation successful."
            else
                echo "Compilation failed."
                exit 1
            fi
        fi
    fi

    # Step 4: Run app.exe with all arguments
    if [[ -f "$compilePath/app.exe" ]]; then
        if [[ "$echoExecutionArguments" == "enable" ]]; then
            echo "Running $compilePath/app.exe with arguments: \"$*\""
        fi
        "$compilePath/app.exe" "$@"
        if [[ "$scriptDebug" == "enable" ]]; then
            if [[ $? -ne 0 ]]; then
                echo "Error: app.exe failed with exit code $?"
            fi
        fi
    else
        if [[ "$scriptDebug" == "enable" ]]; then
            echo "Error: $compilePath/app.exe not found."
        fi
    fi
else
    if [[ "$scriptDebug" == "enable" ]]; then
        echo "No .cpp files found in src or lib directories."
    fi
fi