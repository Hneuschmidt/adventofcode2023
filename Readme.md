# Advent of Code 2023

My solutions for 2023's [Advent of Code](https://adventofcode.com/) challenges.
I am using (and learning) the [Julia programming language](https://julialang.org/)
to solve the 2023 puzzles.

The main module `aoc23` exports functions `day1, day2, ...` that take no arguments
and print out solutions to both parts of each puzzle.
The puzzle inputs are not included in this repository.
The solution to each day expects to find a file with the puzzle input
under `src/inputs/day<n>.txt` where `<n>` is the day's number (01, 02, ...)

To run a single part of a specific day (say, day 3), import it directly
from the corresponding module:

```Julia
import aoc23.day03module: part1, part2
```

Note that the module names and input files (unlike each day's function)
use zero-prefixed numbers for single digit days.
