std = {
    endl = "\n";
    repr = function(v, level) end;
    getfenv = function(f) end;
    setfenv = function(f, table) end;
    values = function(t) end;
    printf = function(msg, ...) end;
    bind = function(fn, self, ...) end;

    String = {};
    Vector = {};
    List = {};
    Map = {};
    Stack = {};
    EventEmitter = {};
    Error = {};

    Stream = {
        Stream = {};
        Readable = {};
        ReadableState = {}
    };

    stdin = {};
    stdout = {};
}

util = {

}

Process = {
    MemoryUsage = function() end;
    RSS = function() end;
    On = function(event, callback) end;
    Once = function(event, callback) end;
    Off = function(event, callback) end;
    Emit = function(event, ...) end;
    AddEventListener = function(event, callback) end;
    RemoveEventListener = function(event, callback) end;
    argc = 1 | 2;
    argv = {};
    env = {
        LUAY_ENV = "production"
    }
}