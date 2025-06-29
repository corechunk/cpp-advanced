#### Return [Previous Page](../README.md)
---

# 1. Download Clang Compiler

**Download Link**: [https://github.com/llvm/llvm-project/releases](https://github.com/llvm/llvm-project/releases)

First enter the latest version available and then 
Download the file that includes [Clang + LLVM] both for your linux operating sytem.

As I'm writting this clang version is: 20.1.3

`clang+llvm-20.1.3-x86_64-pc-windows-msvc.tar.xz`

# 2. Then Just Extract it with 7zip or any other app

- name the extracted folder as anything u want or keep it as it is
- and u can delete the .tar and .tar.xz files now

# 3. Set Environtment Variable Path
- Open the bin folder inside the extracted folder
- then copy the folder path or location

The path looks like this:
`......clang+llvm-20.1.3-x86_64-pc-windows-msvc/bin`

- search `"edit the system environment variables"`
- open `"edit the system environment variables"`
- In "advanced" tab click `"Environment Variables.."
- You will see two portion
- - One is User Variables (for the user you logged in as)
- - another portion of the window is System Variables (if you want clang for all windows users in your device)
- Now double-click the line that says "Path" 
- Then, in the prompted window choose new and paste the copied path
- Then click every ok button and exit

---
# 4. Download visualstudio build tool

Download Link: [https://visualstudio.microsoft.com/downloads/](https://visualstudio.microsoft.com/downloads/)
- Goto the bottom and under "all downloads" drop down the "tools" option and download `Build Tools for Visual Studio 2022`

or directly the download Link: [https://download.visualstudio.microsoft.com/download/pr/8fada5c7-8417-4239-acc3-bd499af09222/662cfafc84e8b026c2a0c57850d7e0ba3e736d5d774520401a63f55b9fdd7ff9/vs_BuildTools.exe](https://download.visualstudio.microsoft.com/download/pr/8fada5c7-8417-4239-acc3-bd499af09222/662cfafc84e8b026c2a0c57850d7e0ba3e736d5d774520401a63f55b9fdd7ff9/vs_BuildTools.exe)

- install what it says and inside that it will download `Build Tools for Visual Studio 2022` not the actuall `Visual Studio`

---
# 5. [ DONE ]  Check if clang is available through Terminal  [ DONE ]
run this command : 

```bash
clang --version
```


it will show something like that, just version number may differ
```
clang version 18.1.8
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /usr/local/llvm-18/bin
```
---




> You are good to go now !!
