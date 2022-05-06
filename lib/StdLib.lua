local Lists = require "std.ListTypes"
local Standard = require "std.StandardTypes" (Lists)

---@param fn function
---@vararg ...
local function spawn(fn, ...)
    local e = Standard.EventEmitter()
    e:Once("callFn", fn)
    e:Emit("callFn", ...)
    e:Destroy()
end

---@class Input : Class
local Input = class "Input" do
    ---@return Input
    function Input.new()
        return Input:constructor(function(self)
            ---@return String
            function self.meta.__shr(_, prompt)
                io.write(prompt)
                io.flush()
                return io.read()
            end

            function self.meta.__tostring()
                return "<stdin>"
            end
        end)
    end
end

---@class Output : Class
local Output = class "Output" do
    ---@return Output
    function Output.new()
        return constructor(Output, function(self)
            function self.meta.__shl(_, content)
                io.write(content)
                return self
            end

            function self.meta.__tostring()
                return "<stdout>"
            end
        end)
    end
end

local lout = Output()
local lin = Input()
do
    extend(Process, Standard.EventEmitter())
    Process.stdout = lout
    Process.stdin = lin

    ---@param code? integer
    function Process:Exit(code)
        self:Emit("exit", code or 1)
        throw(Standard.Error(""))
    end
end

---@class std
---@field String String
---@field Function Function
---@field Event Event
---@field EventEmitter EventEmitter
---@field Error Error
---@field Vector Vector
---@field List List
---@field Stack Stack
---@field Map Map
---@field Queue Queue
---@field Deque Deque
---@field Set Set
---@field LinkedList LinkedList
---@field LinkedNode LinkedNode
---@field MultiMap MultiMap
---@field lout Output
---@field lin Input
---@field endl "\\n"
---@field repr fun(data: any, level: number): void
---@field printf fun(str: string): void
std = {}
namespace "std" {
    String = Standard.String;
    Function = Standard.Function;
    Event = Standard.Event;
    Error = Standard.Error;
    EventEmitter = Standard.EventEmitter;
    Vector = Lists.Vector;
    List = Lists.List;
    Stack = Lists.Stack;
    Map = Lists.Map;
    Queue = Lists.Queue;
    Deque = Lists.Deque;
    Set = Lists.Set;
    LinkedList = Lists.LinkedList;
    LinkedNode = Lists.LinkedNode;
    MultiMap = Lists.MultiMap;

    lout = lout;
    lin = lin;
    endl = "\n";

    spawn = spawn;
}