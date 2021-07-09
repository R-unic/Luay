#ifndef luay_common
#define luay_common

using namespace std;

#include <lua.hpp>
#include <windows.h>
#include <string>
#include <string.h>
#include <cstdlib>
#include <cmath>
#include <fstream>
#include <iostream>
#include <ios>
#include <streambuf>
#include <chrono>
#include <thread>

string split(string base, string delimiter)
{
    return base.substr(0, base.find(delimiter));
}

#endif