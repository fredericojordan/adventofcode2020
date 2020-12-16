#! /usr/bin/env elixir
defmodule Day11 do
  @moduledoc """
  --- Day 11: Seating System ---

  Your plane lands with plenty of time to spare. The final leg of your journey is a ferry that goes directly to the
  tropical island where you can finally start your vacation. As you reach the waiting area to board the ferry, you
  realize you're so early, nobody else has even arrived yet!

  By modeling the process people use to choose (or abandon) their seat in the waiting area, you're pretty sure you can
  predict the best place to sit. You make a quick map of the seat layout (your puzzle input).

  The seat layout fits neatly on a grid. Each position is either floor (.), an empty seat (L), or an occupied seat (#).
  For example, the initial seat layout might look like this:

      L.LL.LL.LL
      LLLLLLL.LL
      L.L.L..L..
      LLLL.LL.LL
      L.LL.LL.LL
      L.LLLLL.LL
      ..L.L.....
      LLLLLLLLLL
      L.LLLLLL.L
      L.LLLLL.LL

  Now, you just need to model the people who will be arriving shortly. Fortunately, people are entirely predictable and
  always follow a simple set of rules. All decisions are based on the number of occupied seats adjacent to a given seat
  (one of the eight positions immediately up, down, left, right, or diagonal from the seat). The following rules are
  applied to every seat simultaneously:

      If a seat is empty (L) and there are no occupied seats adjacent to it, the seat becomes occupied.
      If a seat is occupied (#) and four or more seats adjacent to it are also occupied, the seat becomes empty.
      Otherwise, the seat's state does not change.
      Floor (.) never changes; seats don't move, and nobody sits on the floor.

  After one round of these rules, every seat in the example layout becomes occupied:

      #.##.##.##
      #######.##
      #.#.#..#..
      ####.##.##
      #.##.##.##
      #.#####.##
      ..#.#.....
      ##########
      #.######.#
      #.#####.##

  After a second round, the seats with four or more occupied adjacent seats become empty again:

      #.LL.L#.##
      #LLLLLL.L#
      L.L.L..L..
      #LLL.LL.L#
      #.LL.LL.LL
      #.LLLL#.##
      ..L.L.....
      #LLLLLLLL#
      #.LLLLLL.L
      #.#LLLL.##

  This process continues for three more rounds:

      #.##.L#.##
      #L###LL.L#
      L.#.#..#..
      #L##.##.L#
      #.##.LL.LL
      #.###L#.##
      ..#.#.....
      #L######L#
      #.LL###L.L
      #.#L###.##

      #.#L.L#.##
      #LLL#LL.L#
      L.L.L..#..
      #LLL.##.L#
      #.LL.LL.LL
      #.LL#L#.##
      ..L.L.....
      #L#LLLL#L#
      #.LLLLLL.L
      #.#L#L#.##

      #.#L.L#.##
      #LLL#LL.L#
      L.#.L..#..
      #L##.##.L#
      #.#L.LL.LL
      #.#L#L#.##
      ..L.L.....
      #L#L##L#L#
      #.LLLLLL.L
      #.#L#L#.##

  At this point, something interesting happens: the chaos stabilizes and further applications of these rules cause no
  seats to change state! Once people stop moving around, you count 37 occupied seats.

  Simulate your seating area by applying the seating rules repeatedly until no seats change state. How many seats end up
  occupied?

  --- Part Two ---

  As soon as people start to arrive, you realize your mistake. People don't just care about adjacent seats - they care
  about the first seat they can see in each of those eight directions!

  Now, instead of considering just the eight immediately adjacent seats, consider the first seat in each of those eight
  directions. For example, the empty seat below would see eight occupied seats:

      .......#.
      ...#.....
      .#.......
      .........
      ..#L....#
      ....#....
      .........
      #........
      ...#.....

  The leftmost empty seat below would only see one empty seat, but cannot see any of the occupied ones:

      .............
      .L.L.#.#.#.#.
      .............

  The empty seat below would see no occupied seats:

      .##.##.
      #.#.#.#
      ##...##
      ...L...
      ##...##
      #.#.#.#
      .##.##.

  Also, people seem to be more tolerant than you expected: it now takes five or more visible occupied seats for an
  occupied seat to become empty (rather than four or more from the previous rules). The other rules still apply:
  empty seats that see no occupied seats become occupied, seats matching no rule don't change, and floor never changes.

  Given the same starting layout as above, these new rules cause the seating area to shift around as follows:

      L.LL.LL.LL
      LLLLLLL.LL
      L.L.L..L..
      LLLL.LL.LL
      L.LL.LL.LL
      L.LLLLL.LL
      ..L.L.....
      LLLLLLLLLL
      L.LLLLLL.L
      L.LLLLL.LL

      #.##.##.##
      #######.##
      #.#.#..#..
      ####.##.##
      #.##.##.##
      #.#####.##
      ..#.#.....
      ##########
      #.######.#
      #.#####.##

      #.LL.LL.L#
      #LLLLLL.LL
      L.L.L..L..
      LLLL.LL.LL
      L.LL.LL.LL
      L.LLLLL.LL
      ..L.L.....
      LLLLLLLLL#
      #.LLLLLL.L
      #.LLLLL.L#

      #.L#.##.L#
      #L#####.LL
      L.#.#..#..
      ##L#.##.##
      #.##.#L.##
      #.#####.#L
      ..#.#.....
      LLL####LL#
      #.L#####.L
      #.L####.L#

      #.L#.L#.L#
      #LLLLLL.LL
      L.L.L..#..
      ##LL.LL.L#
      L.LL.LL.L#
      #.LLLLL.LL
      ..L.L.....
      LLLLLLLLL#
      #.LLLLL#.L
      #.L#LL#.L#

      #.L#.L#.L#
      #LLLLLL.LL
      L.L.L..#..
      ##L#.#L.L#
      L.L#.#L.L#
      #.L####.LL
      ..#.#.....
      LLL###LLL#
      #.LLLLL#.L
      #.L#LL#.L#

      #.L#.L#.L#
      #LLLLLL.LL
      L.L.L..#..
      ##L#.#L.L#
      L.L#.LL.L#
      #.LLLL#.LL
      ..#.L.....
      LLL###LLL#
      #.LLLLL#.L
      #.L#LL#.L#

  Again, at this point, people stop shifting around and the seating area reaches equilibrium. Once this occurs, you
  count 26 occupied seats.

  Given the new visibility method and the rule change for occupied seats becoming empty, once equilibrium is reached,
  how many seats end up occupied?
  """

  defp read_input_file() do
    {:ok, seats_file} = File.read("input.txt")

    seats_file
    |> String.split("\n")
    |> Stream.reject(&(&1 == ""))
    |> Enum.map(&String.graphemes/1)
  end

  defp test_input() do
    [
      "L.LL.LL.LL",
      "LLLLLLL.LL",
      "L.L.L..L..",
      "LLLL.LL.LL",
      "L.LL.LL.LL",
      "L.LLLLL.LL",
      "..L.L.....",
      "LLLLLLLLLL",
      "L.LLLLLL.L",
      "L.LLLLL.LL"
    ]
    |> Enum.map(&String.graphemes/1)
  end

  defp count_occupied(vicinity) do
    vicinity
    |> Enum.map(fn seats -> Enum.count(seats, &(&1 == "#")) end)
    |> Enum.sum()
  end

  defp run_rule({".", _count}), do: "."
  defp run_rule({"L", 0}), do: "#"
  defp run_rule({"#", count}) when count > 4, do: "L"
  defp run_rule({state, _count}), do: state

  defp condense(chunk) do
    chunk
    |> Enum.map(fn line -> {Enum.at(Enum.at(line, 1), 1), count_occupied(line)} end)
    |> Enum.map(&run_rule/1)
  end

  defp chunk_threes(enum) do
    line_len = Enum.count(List.first(enum))
    empty_line = List.duplicate(".", line_len)

    [
      [empty_line, Enum.at(enum, 0), Enum.at(enum, 1)]
    ] ++ Enum.chunk_every(enum, 3, 1, [empty_line])
  end

  defp run_seating_round(disposition) do
    disposition
    |> chunk_threes()
    |> Enum.map(fn chunk -> Enum.zip(chunk) end)
    |> Enum.map(fn chunk -> Enum.map(chunk, &Tuple.to_list/1) end)
    |> Enum.map(&chunk_threes/1)
    |> Enum.map(&condense/1)
  end

  def part_1() do
    read_input_file()
    |> Stream.iterate(&run_seating_round/1)
    |> Stream.transform(nil, fn i, acc ->
      if i == acc, do: {:halt, i}, else: {[i], i}
    end)
    |> Enum.take(-1)
    |> List.first()
    |> count_occupied()
  end

  def part_2() do
    # cmon
  end
end

IO.inspect(Day11.part_1())
IO.inspect(Day11.part_2())
