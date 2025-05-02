Copy
# C++ Multi-File Build System

This repository, "cpp-advanced," provides a lightweight build system for multi-file C++ projects, using `build.bat` (Windows) and `build.sh` (Linux/macOS) to automate compilation and execution without relying on complex tools like CMake. Configurable via `srp/build.txt`, it supports `clang++` by default (extendable to `g++` or others) and compiles `.cpp` files from `src` and `lib` into a single executable (`app` or `app.exe`). The included C++ codebase serves as a generic example, making the project ideal for non-beginners who want a simple, customizable build process.

## Table of Contents
- [Features](#features)
- [Why This Build System?](#why-this-build-system)
- [Prerequisites](#prerequisites)
- [Setting Up the Environment](#setting-up-the-environment)
  - [Clang with Windows/Linux(Ubuntu)](#clang-setup:)
  - [Mingw with Windows/Linux(Ubuntu)](#mingw-setup:)
- [Getting Started](#getting-started)
  - [Windows](#windows)
  - [Linux/macOS](#linuxmacos)
- [Project Structure](#project-structure)
- [How the Build System Works](#how-the-build-system-works)
- [Build Configuration (`srp/build.txt`)](#build-configuration-srpbuildtxt)
- [Usage](#usage)
- [Extending the Project](#extending-the-project)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Features
- **Simple Build Scripts**: Automate compilation with `build.bat` (Windows) and `build.sh` (Linux/macOS).
- **Highly Configurable**: Customize build settings via `srp/build.txt` (e.g., C++ standard, compiler paths, debug options).
- **Cross-Platform**: Supports Windows, Linux, and macOS with `clang++` (configurable for `g++` or others).
- **No Build Tool Dependency**: Eliminates the need for CMake or similar tools.
- **Generic Example**: Includes a sample multi-file C++ codebase in `src` and `lib` for testing.

## Why This Build System?
Compiling multi-file C++ projects often requires complex tools like CMake, which can be daunting for non-beginners. This project offers:
- **Simplicity**: Automates compilation with minimal setup using batch and bash scripts.
- **Flexibility**: Extensive configuration options for compiler, paths, and build behavior.
- **Transparency**: Clear, editable scripts and configuration file for easy customization.
- **Educational Value**: Demonstrates scripting for build automation, ideal for learning.

## Prerequisites
To use this build system, you need:
- A C++ compiler (preferably `clang++`, but `g++` or MSVC can be used with script modifications):
  - **Windows**: Clang or MinGW (`g++`)
  - **Linux/macOS**: Clang or `g++`
- Git to clone the repository.
- A terminal or command prompt to run the build scripts.
- 7zip (Windows) or `tar` (Linux/macOS) for extracting Clang archives.

## Setting Up the Environment

### Clang setup:
* For Windows: [visit this page](srp/PAGE.md)
* For Linux (Ubuntu): [visit this page](srp/PAGE2.md)
### Mingw Setup
* For Windows: [coming soon](srp/PAGE3.md)
* For Linux (Ubuntu): [coming soon](srp/PAGE4.md)

## Getting Started

### Cloning the Repository
Clone the repository to your local machine:
>>```bash
>>git clone https://github.com/Miraj13123/cpp-advanced.git
>>cd cpp-advanced
>>```
## Windows
### 1. Configure Build Settings (Optional):
* Edit srp/build.txt to customize settings like version, compilePathWindows, or extra_flags.

### 2. Run the Build Script:
* Open a Command Prompt or PowerShell in the project directory.
* Execute:

>>```cmd
>>build.bat
>>```

* The script compiles .cpp files from src and lib into app.exe in the specified compile path (default: binW).
### 3. Run the Program:
* Navigate to the compile path (e.g., binW) and run:
>>```cmd
>>app.exe [arg1 arg2 ...]
>>```
## Linux/macOS

### 1. Configure Build Settings (Optional):

* Edit srp/build.txt to customize settings like version, compilePathLinux, or extra_flags.

### 2. Run the Build Script:
* Open a terminal in the project directory.

* **Make the script executable:**
>>```bash
>>chmod +x build.sh
>>```
* **Execute:**
>>```bash
>>./build.sh
>>```

* **The script compiles .cpp files from src and lib into app in the specified compile path (default: binL).**

### 3. **Run the Program:**

* Navigate to the compile path (e.g., binL) and run:
>>```bash
>>./app [arg1 arg2 ...]
>>```

---
---
# Project Structure
```Copy
cpp-advanced/
├── include/           # Header files for the example C++ codebase
│   ├── *.h
├── src/              # Source files for the example C++ codebase
│   ├── main.cpp
│   ├── *.cpp
├── lib/              # Dependency source files (if any)
│   ├── *.cpp
├── srp/              # Build configuration and setup guides
│   ├── build.txt     # Build configuration file
│   ├── PAGE.md       # Windows setup guide
│   ├── PAGE2.md      # Linux setup guide
├── build.bat         # Build script for Windows
├── build.sh          # Build script for Linux/macOS
├── README.md         # Project documentation
└── LICENSE           # License file (if applicable)
```
* include/: Header files for the example C++ code.
* src/: Primary source files, including main.cpp.
* lib/: Source files for dependencies (compiled alongside src).
* srp/: Configuration file (build.txt) and setup guides (PAGE.md, PAGE2.md).
* build.bat/build.sh: Scripts to compile and link source files.
## How the Build System Works
The build system automates compilation of multi-file C++ projects using build.bat (Windows) and build.sh (Linux/macOS):

* ### Process:
1. Clears previous build artifacts (.o, .exe, .s) in the compile path (e.g., binW or binL).
2. Creates the compile path if missing.
3. Collects .cpp files from src and lib.
4. Compiles based on createObjects:
  * If enabled, compiles to .o files and links to app.exe or app (if halt="disable").
  * If disabled, compiles directly to the executable.
5. Supports special modes (e.g., preprocessing with -E, assembly with -S) via extra_flags.
6. Runs the executable with provided arguments if compilation succeeds.

* ## Configuration:
  * Controlled by srp/build.txt, which defines settings like C++ standard, compiler paths, and debug options.
* ## Advantages:
  * Automates multi-file compilation with minimal setup.
  * Highly configurable for various build scenarios.
  * Transparent scripts and configuration for easy modification.

## Build Configuration (srp/build.txt)
The `srp/build.txt` file allows extensive customization with the following settings:

| Key                     | Default Value          | Description                                                                 |
|-------------------------|------------------------|-----------------------------------------------------------------------------|
| version                 | 17                     | C++ standard (e.g., 17 for C++17, 20 for C++20).                            |
| compilePathWindows      | binW                   | Windows directory for build artifacts (e.g., .o, app.exe).                  |
| compilePathLinux        | binL                   | Linux/macOS directory for build artifacts (e.g., .o, app).                  |
| exactPaths              | enable                 | If enabled, uses exact paths for compilation; else, relative paths.         |
| createObjects           | enable                 | If enabled, compiles to object files (.o) before linking.                   |
| target_triple           | x86_64-w64-mingw32     | Target architecture for cross-compilation (e.g., for MinGW on Windows).     |
| echoCompileCommands     | enable                 | If enabled, prints compilation commands for debugging.                      |
| include_paths           | (empty)                | Additional include directories (comma-separated).                           |
| library_paths           | (empty)                | Additional library directories (comma-separated).                           |
| libraries               | (empty)                | Libraries to link against (comma-separated, e.g., pthread).                 |
| extra_flags             | (empty)                | Additional compiler flags (e.g., -E for preprocessing, -S for assembly).    |
| halt                    | disable                | If enabled, halts after compiling to .o files without linking.              |
| echoDebug               | enable                 | If enabled, prints debug information during build.                          |
| echoVars                | enable                 | If enabled, prints variable values from build.txt.                          |
| echoFiles               | enable                 | If enabled, prints collected source file names.                             |
| echoIncludePaths        | enable                 | If enabled, prints include paths used.                                      |
| echoLibraryPaths        | enable                 | If enabled, prints library paths used.                                      |
| echoLibraries           | enable                 | If enabled, prints libraries linked.                                        |
| echoExtraFlags          | enable                 | If enabled, prints extra compiler flags used.                               |
| echoTargetTriple        | enable                 | If enabled, prints target triple used.                                      |

## Usage
### 1. Running the Example:
* After building, navigate to the compile path (e.g., binW or binL) and run:
cmd

```cmd
## By the way, arg/arguments are optional
app.exe [arg1 arg2 ...]  # Windows
./app [arg1 arg2 ...]    # Linux/macOS

# Instead you could pass arguments to the scripts as scripts handle them internally:
build.bat [arg1 arg2 ...]  # Windows
build.sh [arg1 arg2 ...]  # Linux/MacOS
```
* The output depends on the C++ codebase in src and lib.
### 2. Using with Your Own Code:
* Replace src and lib with your own .cpp files and include with .h files.
* Update srp/build.txt for custom settings (e.g., include_paths, libraries).
* Run build.bat or build.sh to compile.
### 3. Passing Arguments:
* You can run the build.bat/build.sh directly to pass arguments, as scripts handle them internally.

## Extending the Project
To adapt the build system for a different C++ codebase:

1. Clear or replace include, src, and lib with your own files.
2. Ensure a main.cpp (or equivalent entry point) exists in src.
3. Update srp/build.txt for specific needs (e.g., library_paths, extra_flags).
4. Modify build.bat or build.sh to:
   * Use a different compiler (e.g., replace clang++ with g++).
   * Add flags (e.g., -std=c++20, -O2).
   * Change the output executable name (e.g., from app to myapp).
5. Run the build script to compile and test your code.
## Troubleshooting
* Compilation Errors:
  * Check console output for issues (e.g., missing headers, undefined symbols).
  * Verify clang++ (or specified compiler) is in your PATH.
  * Ensure srp/build.txt settings are valid (e.g., correct paths, supported version).
* Script Issues:
  * Inspect build.bat or build.sh for path or flag errors.
  * Enable debug options in build.txt (e.g., echoCompileCommands, echoDebug) to diagnose.
* Missing Dependencies:
  * If using libraries, update libraries and library_paths in build.txt.
* Unfinished Project:
  * The project is incomplete, so test thoroughly and adapt as needed.
## Contributing
Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch (git checkout -b feature/your-feature).
3. Make changes (e.g., improve scripts, enhance build.txt parsing, update documentation).
4. Commit changes (git commit -m "Add your message").
5. Push to your branch (git push origin feature/your-feature).
6. Open a Pull Request with a detailed description.

Please ensure changes maintain simplicity and include clear documentation.

## License
This project is licensed under the MIT License. See the  file for details.
