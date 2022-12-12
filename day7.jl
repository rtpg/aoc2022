using Test
struct Cmd
    op:: String
    output:: Vector{String}
end
"Lenient comparison operator for `struct`, both mutable and immutable (type with \\eqsim)."
@generated function baseq(x, y)
    if !isempty(fieldnames(x)) && x == y
        mapreduce(n -> :(x.$n == y.$n), (a,b)->:($a && $b), fieldnames(x))
    else
        :(x == y)
    end
end

mutable struct Directory
    parent :: Union{Directory, Nothing}
    dirs:: Dict{String, Directory}
    files:: Dict{String, UInt128}
    total:: Union{UInt128, Nothing}
end

function parse_cmd!(lines)
    line = popfirst!(lines)
    if line[1] != '$'
        error("Failed to parse line")
    end
    op = line[3:end]
    output = []
    while length(lines) > 0
        line = popfirst!(lines)
        if line[1] == '$'
            # was a command
            pushfirst!(lines, line)
            break
        end
        push!(output, line)
    end
    return Cmd(op, output)
end

@test baseq(parse_cmd!(["\$ cd /"]), Cmd("cd /", []))

test_data = """
\$ cd /
\$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
\$ cd a
\$ ls
dir e
29116 f
2557 g
62596 h.lst
\$ cd e
\$ ls
584 i
\$ cd ..
\$ cd ..
\$ cd d
\$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k
"""

function parse!(txt::String)
    lines = split(txt, "\n")[begin:end-1]
    cmds = []
    while length(lines) > 0
        push!(cmds, parse_cmd!(lines))
    end
    return cmds
end

@test length(parse!(test_data)) == 10

# now we want to actually do the operations
base = Directory(
    nothing,
    Dict([]),
    Dict([]),
    nothing
)

cwd = base

function handle_ls!(dir, cmd)
    # create files that need to exist
    for line in cmd.output
        if line[begin:3] == "dir"
            name = line[5:end]
            new_dir = Directory(
                dir,
                Dict([]),
                Dict([]),
                nothing
            )
            dir.dirs[name] = new_dir
        else
            (size, name) = split(line, " ")
            dir.files[name] = parse(UInt128, size)
        end
    end
end
for cmd in parse!(read("data/7.txt", String))
    if cmd.op == "cd /"
        global cwd = base
    elseif cmd.op == "ls"
        handle_ls!(cwd, cmd)
    elseif cmd.op[begin:2] == "cd"
        dir = cmd.op[4:end]
        if dir == ".."
            global cwd = cwd.parent
        else
            # folder
            global cwd = cwd.dirs[dir]
        end
    else
        error("Unknown op $(cmd.op)")
    end
end

# at this point we have built up the tree

# let's print the tree to sanity check
function print_dir(dir, name, prefix)
    println(prefix, "- ", name, " (dir)")
    for (name, d) in pairs(dir.dirs)
        print_dir(d, name, prefix * "  ")
    end
    for (name, f) in pairs(dir.files)
        println(prefix, "- ", name, " $f (file)")
    end
end

function calc_sizes!(dir::Directory)
    # return the total size of the directory
    total_size = 0
    for (_, d) in dir.dirs
        total_size += calc_sizes!(d)
    end
    for (_, size) in dir.files
        total_size += size
    end
    dir.total = total_size
    return total_size
end

calc_sizes!(base)

function iter_dirs(name, dir::Directory)
    result = []
    for (n, d) in pairs(dir.dirs)
        append!(result, iter_dirs("$name/$n", d))
    end
    append!(result, [(dir, name)])
    return result
end

small_total = 0
for (dir, name) in iter_dirs("/", base)
    if dir.total < 100000
        # println("$name is size $(dir.total)")
        global small_total += dir.total
    end
end

println("Small Total is $small_total")

total_disk = 70000000
target_free = 30000000
used = base.total
current_free = total_disk - used
wanted_free = target_free - current_free
println("Need to free $wanted_free bytes")

all_dirs = collect(iter_dirs("/", base)) .|> elt -> elt[1]
big_dirs = filter(
    (dir::Directory) -> dir.total > wanted_free,
    all_dirs
) .|> (dir -> dir.total ) |> sort

println(big_dirs[1])
println(big_dirs[2])
