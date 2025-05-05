#!/bin/bash
clear
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
done < <(find . -type f -name "*.s" 2>/dev/null)
for file in "${assembly_files[@]}"; do
    rm -f "$file" 2>/dev/null
done
# delete all resolvedCPP files
resolvedCPP_files=()
while IFS= read -r file; do
    file_path="${file#$(pwd)/}"
    resolvedCPP_files+=("$file_path")
done < <(find . -type f -name "*.resolved.cpp" 2>/dev/null)
for file in "${resolvedCPP_files[@]}"; do
    rm -f "$file" 2>/dev/null
done
