#! /usr/bin/env elixir
defmodule Day08 do
  @moduledoc """
  --- Day 8: Handheld Halting ---

  Your flight to the major airline hub reaches cruising altitude without incident. While you consider checking the
  in-flight menu for one of those drinks that come with a little umbrella, you are interrupted by the kid sitting next
  to you.

  Their handheld game console won't turn on! They ask if you can take a look.

  You narrow the problem down to a strange infinite loop in the boot code (your puzzle input) of the device. You should
  be able to fix it, but first you need to be able to run the code in isolation.

  The boot code is represented as a text file with one instruction per line of text. Each instruction consists of an
  operation (acc, jmp, or nop) and an argument (a signed number like +4 or -20).

  acc increases or decreases a single global value called the accumulator by the value given in the argument. For
  example, acc +7 would increase the accumulator by 7. The accumulator starts at 0. After an acc instruction, the
  instruction immediately below it is executed next.

  jmp jumps to a new instruction relative to itself. The next instruction to execute is found using the argument as an
  offset from the jmp instruction; for example, jmp +2 would skip the next instruction, jmp +1 would continue to the
  instruction immediately below it, and jmp -20 would cause the instruction 20 lines above to be executed next.

  nop stands for No OPeration - it does nothing. The instruction immediately below it is executed next.

  For example, consider the following program:

      nop +0
      acc +1
      jmp +4
      acc +3
      jmp -3
      acc -99
      acc +1
      jmp -4
      acc +6

  These instructions are visited in this order:

      nop +0  | 1
      acc +1  | 2, 8(!)
      jmp +4  | 3
      acc +3  | 6
      jmp -3  | 7
      acc -99 |
      acc +1  | 4
      jmp -4  | 5
      acc +6  |

  First, the nop +0 does nothing. Then, the accumulator is increased from 0 to 1 (acc +1) and jmp +4 sets the next
  instruction to the other acc +1 near the bottom. After it increases the accumulator from 1 to 2, jmp -4 executes,
  setting the next instruction to the only acc +3. It sets the accumulator to 5, and jmp -3 causes the program to
  continue back at the first acc +1.

  This is an infinite loop: with this sequence of jumps, the program will run forever. The moment the program tries to
  run any instruction a second time, you know it will never terminate.

  Immediately before the program would run an instruction a second time, the value in the accumulator is 5.

  Run your copy of the boot code. Immediately before any instruction is executed a second time, what value is in the
  accumulator?
  """

  defp read_input_file() do
    {:ok, code_file} = File.read("input.txt")

    code_file
    |> String.split("\n")
    |> Stream.reject(&(&1 == ""))
    |> Stream.map(&String.split/1)
    |> Stream.map(fn [op, arg] -> [op, String.to_integer(arg)] end)
    |> Stream.with_index(0)
    |> Enum.reduce(%{}, fn {instruction, index}, acc -> Map.put(acc, index, instruction) end)
  end

  defp run_line(nil), do: nil

  defp run_line({code, line, acc, visited}) do
    if Enum.member?(visited, line),
      do: {{:repeats, acc}, nil},
      else: run_line({code, line, acc, visited}, Map.get(code, line))
  end

  defp run_line({code, line, acc, visited}, ["nop", _arg]),
    do: run_line({code, line + 1, acc, MapSet.put(visited, line)})

  defp run_line({code, line, acc, visited}, ["acc", arg]),
    do: run_line({code, line + 1, acc + arg, MapSet.put(visited, line)})

  defp run_line({code, line, acc, visited}, ["jmp", arg]),
    do: run_line({code, line + arg, acc, MapSet.put(visited, line)})

  defp run_line({_code, _line, acc, _visited}, nil), do: {{:halts, acc}, nil}

  defp run_code(code) do
    {code, 0, 0, MapSet.new()}
    |> Stream.unfold(&run_line/1)
    |> Enum.to_list()
    |> List.first()
  end

  def part_1() do
    read_input_file()
    |> run_code()
    |> (fn {_halts?, acc} -> acc end).()
  end

  defp generate_code_variations(code), do: Stream.unfold({code, 0}, &next_code_variation/1)

  def next_code_variation({code, line}) do
    case Map.get(code, line) do
      ["nop", arg] -> {Map.put(code, line, ["jmp", arg]), {code, line + 1}}
      ["jmp", arg] -> {Map.put(code, line, ["nop", arg]), {code, line + 1}}
      ["acc", _arg] -> next_code_variation({code, line + 1})
      _ -> nil
    end
  end

  defp halts?(code) do
    code
    |> run_code()
    |> (fn {halts?, _acc} -> halts? == :halts end).()
  end

  def part_2() do
    read_input_file()
    |> generate_code_variations()
    |> Stream.filter(&halts?/1)
    |> Enum.take(1)
    |> List.first()
    |> run_code()
    |> (fn {_halts?, acc} -> acc end).()
  end
end

IO.inspect(Day08.part_1())
IO.inspect(Day08.part_2())
