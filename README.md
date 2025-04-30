# Folder Structure
The workspace contains two folders by default, where:
- `src`: the folder to maintain sources
- `lib`: the folder to maintain dependencies

finally this workspace contains `srp` folder, that contains a few scripts, These are: (they are in both .bat and .sh formats)
- `clear`
- `compile`
- `run`
- `dev`
- - Dont run these from the srp folder directly
- - Copy them into the main folder where `src` and `lib` folder exist
- - - then you can run them directly by clicking or from command prompt relatively

---
---
> ## Examples
>>### Running "run.bat" relatively from main/master folder if the bat file is in `srp` folder
>>```batch
>>srp\run.bat
>>```
>>
>>### Running "run.bat" directly from main/master folder if the bat file is also in the main/master folder (or you can run it by double clicking {but not from srp folder !!} )
>>```batch
>>run.bat
>>```
---
---

## How to run in you [linux:bash] / [windows:cmd/pwsh]
### You must have clang compiler in your system and the bin folder of the compiler must be added to the environment PATH variable

run these bat[windows] or bash[linux] script in this order
- clear [ clears the previous compiled objects(if exists) and binary files ]
- compile [ compiles the "\*.cpp" files --> "app" file ][or maybe not]
- run  [ starting with this will work; cause the compiled binary is given ]

## you can also run dev.sh to run all 3 at once !!

after compiling it is recommended to run the console app by :
```bash
./app
```
instead of ./run.sh
```
cause, this way you can pass arguments to the app
like --> ./app apple
here             ^   "apple" is passed to the app when running
```
 
---
# Clang Setup - most beginer friendly compiler
---
## [Windows - Setup](srp/PAGE.md)
## [Linux(ubuntu) - Setup](srp/PAGE2.md)
---



if you wanna use gcc or g++ if they are already installed and added to environment variable path
Then replace all "clang++" to "gcc" or "g++" inside all these ".bat" and ".sh" files carefully
Then it will use gcc or g++ instead.
