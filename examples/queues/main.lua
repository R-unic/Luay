using(luay.std)

function main()
    local q = Queue()
    q:Enqueue("lil uzi vert")
    q:Enqueue("j cole")
    q:Enqueue("smokepurpp")
    repr(q)
    q:Dequeue()
    repr(q)
end