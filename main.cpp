#ifdef WINDOWS
#include <direct.h>
#define GetCurrentDir _getcwd
#else
#include <unistd.h>
#define GetCurrentDir getcwd
#endif

#include "common.hpp"

void memUsage(double& vm_usage, double& resident_set)
{
   vm_usage = 0.0;
   resident_set = 0.0;
   ifstream stat_stream("/proc/self/stat", ios_base::in);
   string pid, comm, state, ppid, pgrp, session, tty_nr;
   string tpgid, flags, minflt, cminflt, majflt, cmajflt;
   string utime, stime, cutime, cstime, priority, nice;
   string O, itrealvalue, starttime;
   unsigned long vsize;
   long rss;

   stat_stream >> pid >> comm >> state >> ppid >> pgrp >> session >> tty_nr
   >> tpgid >> flags >> minflt >> cminflt >> majflt >> cmajflt
   >> utime >> stime >> cutime >> cstime >> priority >> nice
   >> O >> itrealvalue >> starttime >> vsize >> rss;
   stat_stream.close();

   long page_size_kb = sysconf(_SC_PAGE_SIZE) / 1024;
   vm_usage = vsize / 1024.0;
   resident_set = rss * page_size_kb;
}

bool replace(string& str, const string& from, const string& to)
{
    size_t start_pos = str.find(from);
    if(start_pos == string::npos)
        return false;

    str.replace(start_pos, from.length(), to);
    return true;
}

void replaceForPkgPath(string &str)
{
    string identifier = "?.lua";
    replace(str, "main.lua", identifier);
    replace(str, "Main.lua", identifier);
    replace(str, "init.lua", identifier);
    replace(str, "Init.lua", identifier);
}

int process_exit()
{
    exit(1);
    return 0;
}

int process_memoryUsage(lua_State *L)
{
    double vm, rss;
    memUsage(vm, rss);
    lua_pushnumber(L, vm);
    return 1;
}

int process_rss(lua_State *L)
{
    double vm, rss;
    memUsage(vm, rss);
    lua_pushnumber(L, rss);
    return 1;
}

static void stackDump (lua_State *L)
{
    printf("{");
    int top = lua_gettop(L);
    for (int i = 1; i <= top; i++)
    {
        int t = lua_type(L, i);
        switch (t) 
        {
            case LUA_TSTRING:  /* strings */
                printf("`%s'", lua_tostring(L, i));
                break;
            case LUA_TBOOLEAN:  /* booleans */
                printf(lua_toboolean(L, i) ? "true" : "false");
                break;
            case LUA_TNUMBER:  /* numbers */
                printf("%g", lua_tonumber(L, i));
                break;
            default:  /* other values */
                printf("%s", lua_typename(L, t));
                break;
        }
        printf(", ");
    }
    printf("}\n");
}

int luay_cwd(lua_State *L)
{
    char buff[FILENAME_MAX]; //create string buffer to hold path
    GetCurrentDir(buff, FILENAME_MAX);
    string cwd(buff);
    lua_pushstring(L, cwd.c_str());
    return 1;
}

int luay_wait(lua_State *L)
{
    lua_Number secs = luaL_checknumber(L, 1);
    this_thread::sleep_for(chrono::seconds((int)secs));
    return 0;
}

class Luay
{
public:
    lua_State *L;
    int argc;
    char** argv;

    Luay(int argc, char** argv)
    {
        this->L = luaL_newstate();
        this->argc = argc;
        this->argv = argv;
    }

    string cwd()
    {
        char buff[FILENAME_MAX]; //create string buffer to hold path
        GetCurrentDir(buff, FILENAME_MAX);
        string cwd(buff);
        return cwd;
    }

    void peekStack()
    {
        stackDump(this->L);
    }

    void executeMainFn()
    {
        lua_getglobal(this->L, "main");
        this->pushArgs();

        if (lua_isnil(this->L, this->top() - 2)) // if main is nil
        {
            lua_getglobal(this->L, "Program");
            lua_pushliteral(this->L, "Main");
            if (lua_isnil(this->L, this->top() - 1)) // if program is nil
                return this->error("Your program lacks a 'main' function or 'Program' class with 'Main' method, therefore it can not run.");

            lua_gettable(this->L, this->top() - 1); // Program["Main"]
            lua_getglobal(this->L, "Program"); // self
            this->pushArgs();
            if (lua_pcall(this->L, 3, 0, 0) == LUA_OK)
                this->popTop();
            else
                this->error();
            
        }
        else
        {
            if (lua_pcall(this->L, 2, 0, 0) != LUA_OK)
               this->error();
        }
    }

    void close()
    {
        lua_close(this->L);
    }

    void openLibs()
    {
        const struct luaL_Reg ProcessLib[] = {
            {"MemoryUsage", process_memoryUsage},
            {"RSS", process_rss}
        };

        this->table();
        this->pushProcessEnv();
        this->pushProcessArgs();
        luaL_setfuncs(this->L, ProcessLib, 0);
        lua_setglobal(this->L, "Process");
        
        lua_pushcfunction(this->L, luay_cwd);
        lua_setglobal(this->L, "cwd");

        luay_cwd(this->L);
        lua_setglobal(this->L, "__dirname");

        lua_pushcfunction(this->L, luay_wait);
        lua_setglobal(this->L, "wait");

        this->doLuaFile("lib/main.lua");
    }

    void openDefaultLibs()
    {
        luaL_openlibs(this->L);
    }

    string joinPath(string left, string right)
    {
        return left + "/" + right;
    }

    void doLuaFile(string fileName)
    {
        string filePath = this->joinPath(this->cwd(), fileName);
        ifstream luayPathFile("/home/dawnv/dev/lua-sandbox/luaypath");
        string luayPath((istreambuf_iterator<char>(luayPathFile)),
                       (istreambuf_iterator<char>()));;

        string fullFilePath = this->joinPath(luayPath, fileName);
        string pathStr = fileName == "lib/main.lua" ? fullFilePath : filePath;
        string fileStr = pathStr;
        replaceForPkgPath(pathStr);

        this->doString("package.path = package.path .. ';" + pathStr + "'");
        if (luaL_dofile(this->L, fileStr.c_str()) != LUA_OK)
            this->error();
    }

    void doString(string str)
    {
        if (luaL_dostring(this->L, str.c_str()) != LUA_OK)
            this->error();
    }

    void doFile(string fileName)
    {
        this->doLuaFile(fileName);
        this->executeMainFn();
    }

    int top()
    {
        return lua_gettop(this->L);
    }

    void popTop()
    {
        lua_pop(this->L, this->top());
    }

    void error(string msg = "")
    {
        if (msg.empty())
            puts(lua_tostring(this->L, this->top()));
        else
            puts(("[Luay] " + msg).c_str());
        
        this->popTop();
        process_exit();
    }

    void table()
    {
        lua_newtable(this->L);
    }

    void setTable(int top = -3)
    {
        lua_settable(this->L, top);
    }

    void pushArgs()
    {
        lua_pushinteger(this->L, this->argc);
        this->table();
        int top = this->top();
        int offset = 1;
        for (int i = offset; i <= this->argc - offset; i++)
        {
            string arg = this->argv[i];
            lua_pushnumber(this->L, i);
            lua_pushstring(this->L, arg.c_str());
            this->setTable(top);
        }
    }

    void pushProcessArgs()
    {
        // {<process>}
        lua_pushliteral(this->L, "argc");
        lua_pushinteger(this->L, this->argc);
        this->setTable();

        lua_pushliteral(this->L, "argv");
        this->table();

        int top = this->top();
        int offset = 1;
        for (int i = offset; i <= this->argc - offset; i++)
        {
            string arg = this->argv[i];
            lua_pushnumber(this->L, i);
            lua_pushstring(this->L, arg.c_str());
            this->setTable(top);
        }

        this->setTable();
    }

    void pushProcessEnv()
    {
        lua_pushliteral(this->L, "env");       // {...}, "env"
        lua_newtable(this->L);                 // {...}, "env", {}
        lua_pushliteral(this->L, "LUAY_ENV");  // {...}, "env", {}, "LUAY_ENV"
        lua_pushstring(this->L, "production"); // {...}, "env", {}, "LUAY_ENV", "production"
        this->setTable();             // {...}, "env", {["LUAY_ENV"] = "production"}
        this->setTable();               // {<process>}
    }
};
    
int main(int argc, char** argv)
{
    Luay luay(argc, argv);

    char* fileDir = luay.argv[1];
    if (luay.argc < 1 || luay.argc > 2)
    {
        puts("Usage: luay <file>\n");
        return 0;
    }
    else
    {
        luay.openDefaultLibs();
        luay.openLibs();
        luay.doFile(fileDir);
    }

    luay.close();
    return 0;
}