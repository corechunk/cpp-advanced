#!/bin/bash
clear
# only created and specially set to work // these are not defaults //
compilePath="."
scriptDebug="enable"
echoExecutionArguments="enable"

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
            compilePathLinux) compilePath="$value" ;;          #compilerPathLinux is used as "compilerPath"
            echoExecutionArguments) echoExecutionArguments="$value" ;;
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

    # Step 4: Run app.exe with all arguments
    if [[ -f "$compilePath/app.exe" ]]; then
        if [[ "$echoExecutionArguments" == "enable" ]]; then
            echo "Running $compilePath/app.exe with arguments: \"$*\""
        fi
        [[ "$echoCompileCommands" == "enable" ]] && echo "./app.exe"
        pushd "$compilePath" >/dev/null
        ./app.exe "$@"
        exit_code=$?
        popd >/dev/null
        if [[ "$scriptDebug" == "enable" && $exit_code -ne 0 ]]; then
            echo "Error: app.exe failed with exit code $exit_code"
        fi
    else
        [[ "$scriptDebug" == "enable" ]] && echo "Error: $compilePath/app.exe not found."
        exit 1
    fi
