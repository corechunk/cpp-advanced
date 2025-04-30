//#pragma once
#include "math.hpp"
#include <iostream>

void printResult(int result);  // to add funtion from another .cpp file you dont need .hpp
// just prototyping it this way works  || and u can call the function anywhere and as many times u want
// So in this project we didnt need to prototype if we had prototyped this in .hpp
// but to use class from other .cpp u must use .hpp
//protyping function means redeclaring the function like in line 5


int main(int argc, char* argv[])  // you could write  int main() only but i did this on purpose --> you can remove it btw
/* this thing takes all arguments u pass to the exe when running and stores them in argv as a string
so you can access them by argv[<index number here>] || example in line 25*/
{
    calc obj1;
    printResult(obj1.add(3, 4));



    
    if (argc > 1) {  //remove this function if you remove (int argc, char* argv[])  --> ()
        for (int i = 1; i < argc; ++i) {
            std::cout << argv[i] << " ";
        }
    }
    //std::cout << "Result: " << (argc - 1) << std::endl;
    //std::cout << argv[1] ;
    // try running the exe like:
    // app.exe apple orange banana
    // this function loops and itterate through into the argv[] and prints //apple orange banana
    // its like when you pass argument to compiler like
    // 


    return 0;
}






/*    use this as template and delete all the codes above and remove these comments from line 41 and 54 and this line too cause this line is a comment"

#include <iostream>
using namespace std;

int main()
{
    cout << "Hello, world !!\n" ;

    system("pause");
    return 0;
}

*/