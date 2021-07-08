---@param f function
getfenv = function(f) end;
---@param f function
---@param table table
setfenv = function(f, table) end;
---@param module string
---@return unknown
---@return unknown loaderdata
import = function(module) end;
---@param lib table
---@return nil
using = function(lib) end;
---@param t table
---@return function
values = function(t) 
    return function() end 
end;

---@return string
cwd = function() end;
---@type string
__dirname = cwd()

cwd = function() end;

---@param name string
---@return function
function namespace(name) end;

function singleton(name) end;

luay = {
    std = {
        endl = "\n";
        repr = function(v, level) end;
        printf = function(msg, ...) end;

        String = {};
        Vector = {};
        List = {};
        Map = {};
        Stack = {};
        EventEmitter = {};
        Error = {};
        
        stream = {
            Stream = {};
            Readable = {};
            ReadableState = {}
        };
        
        stdin = {};
        stdout = {};
    };

    util = {
        ---@param fn function
        ---@param self any
        ---@vararg ...
        ---@return function
        bind = function(fn, self, ...) 
            return function(self) end 
        end;
    };

    Process = {
        ---@return integer
        MemoryUsage = function() end;
        ---@return integer
        RSS = function() end;
        ---@type integer
        argc = {};
        argv = {};
        env = {
            LUAY_ENV = "production"
        }
    }
}