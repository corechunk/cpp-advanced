#### Return [Previous Page](../README.md)
---

# Shortcut for Step [ 1 to 5 ] to download clang and add it to environment variable path
```bash
sudo apt install clang
```

# 1. Download Clang Compiler

**Download Link**: [https://github.com/llvm/llvm-project/releases](https://github.com/llvm/llvm-project/releases)


First enter the latest version available and then 
Download the file that includes [Clang + LLVM] both for your linux operating sytem.

As I'm writting this clang version is: 20.1.3
- but, you are safe with version 20.1.3 that includes this file mentioned below \[says ubuntu in it\]
```
clang+llvm-18.1.8-x86_64-linux-gnu-ubuntu-18.04.tar.xz
```
After downloading go to the directory through command line or with GUI file manager and open that location by :
```
right clicking inside the directory where the file is downloaded
```
```
then choose ---> "Open in Terminal"
```
---
# 2. Extract the downloaded tar.xz file 
run this command : (in the directory you downloaded the file )

```bash
tar -xvf clang+llvm-18.1.8-x86_64-linux-gnu-ubuntu-22.04.tar.gz
```
Then rename the folder to a managable name (example:- clang-18)
```bash
mv clang+llvm-18.1.8-x86_64-linux-gnu-ubuntu-22.04 clang-18
```
---
# 3. Now move the folder into "usr/local"

```bash
mv clang-18 usr/local
```
---
# 4. Now append the compiler's bin folder to environment PATH variable "usr/local/clang-18/bin"

```bash
echo 'export PATH="$PATH:/usr/local/llvm-18/bin"' >> ~/.bashrc
```
now, source the .bashrc file if your terminal dont source from it
```bash
source ~/.bashrc
```
---
# 5. [ DONE ]  Check if clang is available through Terminal  [ DONE ]
run this command : 

```bash
clang --version
```


if it doesn't show
this type of messege : (then follow next)
```
clang version 18.1.8
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /usr/local/llvm-18/bin
```
---
# [fix]** libtinfo5 or any version of libtinfo is ** missing?? **
if you are missing libtinfo5 :
```
sudo apt install libtinfo5
```
---
# [fix]** if apt can't find libtinfo5 or any version of libtinfo 
1. check ubuntu version : (if its ubuntu 24.04 then, libtinfo5 is removed from repository)
```bash
lsb_release -a
```
2. Check if you have libtinfo5
```bash
ls /lib/x86_64-linux-gnu/libtinfo*
```
3. Download libtinfo5 with 'wget'
```bash
wget http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb
```
4. Install the downloaded .deb package
```bash
sudo dpkg -i libtinfo5_6.3-2ubuntu0.1_amd64.deb
```
5. to resolve any missing dependencies :

```bash
sudo apt update
sudo apt install -f
sudo apt upgrade
```
6. Now check if libtinfo5 exists : (in the list that shows after you run the command)

```bash
ls /lib/x86_64-linux-gnu/libtinfo*
```

7. Now, clang should work : [ give it a try ]

```bash
clang --version
```
