using Test


@test fill(nothing, 2) == [nothing, nothing]

function tower_line(line)
    num_rows = div((length(line) + 1), 4)
    result = fill(' ', num_rows)
    for idx in 1:num_rows
        char :: Char = line[4 * (idx - 1) + 2]
        if char != " "
            result[idx] = char
        end
    end
    result = map(x -> if x == ' ' nothing else x end, result)
    return result
end
@test tower_line("[V]     [B]                     [F]") == [
    'V', nothing, 'B', nothing, nothing, nothing, nothing, nothing, 'F'
]


clean(line) = collect(Iterators.dropwhile(==(nothing), line))

@test clean([nothing, nothing, 'A', 'B']) == ['A', 'B']

function rotate_array(lines)
    return collect(eachcol(permutedims(hcat(lines...))))
end

function get_towers(lines)
    return clean.(rotate_array(lines))
end
test_tower = [
    ['A', nothing, 'B', nothing],
    ['C', 'D',     'E', nothing],
    ['F', 'G',     'H', 'I'    ],
    ['J', 'K',     'L', 'M'    ],
]

@test rotate_array(test_tower) == [
    ['A', 'C', 'F', 'J'],
    [nothing, 'D', 'G', 'K'],
    ['B', 'E', 'H', 'L'],
    [nothing, nothing, 'I', 'M']
]

@test get_towers([
    ['A', nothing, 'B', nothing],
    ['C', 'D',     'E', nothing],
    ['F', 'G',     'H', 'I'    ],
    ['J', 'K',     'L', 'M'    ],
]) == [
    ['A', 'C', 'F', 'J'],
    ['D', 'G', 'K'],
    ['B', 'E', 'H', 'L'],
    ['I', 'M']
]


function parse_tower(s)
    return get_towers(tower_line.(split(s, '\n')))
end

@test parse_tower(
"""    [D]    \n\
[N] [C]    \n\
[Z] [M] [P]"""
) == [
    ['N', 'Z'],
    ['D', 'C', 'M'],
    ['P']
]

function parse_instruction(line)
    # move 1 from 8 to 4
    parts = split(line, " ")
    return (
        parse(Int, parts[2]),
        parse(Int, parts[4]),
        parse(Int, parts[6])
    )
end

@test parse_instruction("move 1 from 8 to 4") == (1, 8, 4)
@test parse_instruction("move 13 from 8 to 7") == (13, 8, 7)

function remove_last_line(text)
    lines = split(text, "\n")
    return join(lines[begin:end-1], "\n")
end

@test remove_last_line("a\nb\nc\nd") === "a\nb\nc"

data = read("./data/5.txt", String)
(state, instructions) = split(data, "\n\n")
# remove the last line (the numbers)
state = remove_last_line(state)
state = parse_tower(state)
display(state)


function popfirstn!(arr, n)
    result = []
    while n > 0
        push!(result, popfirst!(arr))
        n -= 1
    end
    return result
end

@testset "pop tests" begin
    a = [1, 2, 3, 4]
    @test popfirstn!(a, 2) == [1, 2]
    pushfirst!(a, [5, 6]...)
    @test a == [5, 6, 3, 4]
end

for instruction in parse_instruction.(split(instructions[begin:end-1], "\n"))
    (amount, from, to) = instruction

    to_move = popfirstn!(state[from], amount)
    pushfirst!(state[to], to_move...)
end

# time to get the message
println(join(first.(state), ""))
print("Done.")
