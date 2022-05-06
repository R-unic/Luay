
function main()
    local q = std.Queue.new()
    q:Enqueue("lil uzi vert")
    q:Enqueue("j cole")
    q:Enqueue("smokepurpp")
    repr(q)
    q:Dequeue()
    repr(q)
end