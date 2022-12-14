using Test

sample = [
  3 0 3 7 3
  2 5 5 1 2
  6 5 3 3 2
  3 3 5 4 9
  3 5 3 9 0
]



# let's figure out the right dems
# imagine x = 4, y = 2 (so the 1)
# values to the left
x = 4
y = 2
@test sample[y, x] == 1
@test sample[y, begin:(x-1)] == [2, 5, 5]
@test sample[y, (x+1):end] == [2]
@test sample[begin:(y-1), x] == [7]
@test sample[(y+1):end, x] == [3, 4, 9]

@test max([1, 4, 6]...) < 7

function is_visible(grid, x, y)
  w = length(grid[1, :])
  h = length(grid[:, 1])
  if (x == 1) || (y == 1) || (x == h) || (y == w)
    return true
  end
  value = grid[y, x]
  if max(grid[y, begin:(x-1)]...) < value
    # left
    return true
  elseif max(grid[y, (x+1):end]...) < value
    # right
    return true
  elseif max(grid[begin:(y-1), x]...) < value
    # top
    return true
  elseif max(grid[(y+1):end, x]...) < value
    # bottom
    return true
  else
    return false
  end
end

coords(w, h) = [(x, y) for x in 1:h, y in 1:w]

@test coords(3, 2) == [
  (1, 1) (1, 2) (1, 3)
  (2, 1) (2, 2) (2, 3)
]

function viz_map(grid)
  w = length(grid[1, :])
  h = length(grid[:, 1])
  return [
    is_visible(grid, x, y)
    for x in 1:h,
    y in 1:w
  ]
end

file_data = """123
456
789"""

file_lines = split(file_data, "\n")
read_to_vec(lines) = transpose(hcat(
  read_line_to_vec.(lines)...
))

read_line_to_vec(line) = [parse(Int, c) for c in line]

@test read_line_to_vec("123") == [1, 2, 3]

@test read_to_vec(file_lines) == [
  1 2 3
  4 5 6
  7 8 9
]

sample = read_to_vec(readlines("data/8.txt"))
display(sample)


display("Viz Map Is")
vizzed = viz_map(sample)
display(vizzed)
print("Count was $(count(vizzed))")
