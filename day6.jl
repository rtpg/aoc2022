using Test;

function first_start_loc(data)
    for i in range(4, length(data) + 1)
        if length(Set(data[i-3:i])) == 4
            return i
        end
    end
end

@testset "First Start Loc" begin
    @test first_start_loc("mjqjpqmgbljsphdztnvjfqwrcgsmlb") == 7
    @test first_start_loc("bvwbjplbgvbhsrlpgdmjqwftvncz") == 5
    @test first_start_loc("nppdvjthqldpwncqszvftbrmjlhg") == 6
end

function start_of_msg_loc(data)
    for i in range(14, length(data) + 1)
        if length(Set(data[i-13:i])) == 14
            return i
        end
    end
end

@testset "Start of msg" begin
    @test start_of_msg_loc("mjqjpqmgbljsphdztnvjfqwrcgsmlb") == 19
    @test start_of_msg_loc("bvwbjplbgvbhsrlpgdmjqwftvncz") == 23
    @test start_of_msg_loc("nppdvjthqldpwncqszvftbrmjlhg") == 23
end
println("First Packet At: ", first_start_loc(read("data/6.txt")))
println("First Message At: ", start_of_msg_loc(read("data/6.txt")))
