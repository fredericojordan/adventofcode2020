#! /usr/bin/env elixir
defmodule Day16 do
  @moduledoc """
  --- Day 16: Ticket Translation ---
  As you're walking to yet another connecting flight, you realize that one of the legs of your re-routed trip coming up
  is on a high-speed train. However, the train ticket you were given is in a language you don't understand. You should
  probably figure out what it says before you get to the train station after the next flight.

  Unfortunately, you can't actually read the words on the ticket. You can, however, read the numbers, and so you figure
  out the fields these tickets must have and the valid ranges for values in those fields.

  You collect the rules for ticket fields, the numbers on your ticket, and the numbers on other nearby tickets for the
  same train service (via the airport security cameras) together into a single document you can reference (your puzzle
  input).

  The rules for ticket fields specify a list of fields that exist somewhere on the ticket and the valid ranges of values
  for each field. For example, a rule like class: 1-3 or 5-7 means that one of the fields in every ticket is named class
  and can be any value in the ranges 1-3 or 5-7 (inclusive, such that 3 and 5 are both valid in this field, but 4 is
  not).

  Each ticket is represented by a single line of comma-separated values. The values are the numbers on the ticket in the
  order they appear; every ticket has the same format. For example, consider this ticket:

      .--------------------------------------------------------.
      | ????: 101    ?????: 102   ??????????: 103     ???: 104 |
      |                                                        |
      | ??: 301  ??: 302             ???????: 303      ??????? |
      | ??: 401  ??: 402           ???? ????: 403    ????????? |
      '--------------------------------------------------------'

  Here, ? represents text in a language you don't understand. This ticket might be represented as
  101,102,103,104,301,302,303,401,402,403; of course, the actual train tickets you're looking at are much more
  complicated. In any case, you've extracted just the numbers in such a way that the first number is always the same
  specific field, the second number is always a different specific field, and so on - you just don't know what each
  position actually means!

  Start by determining which tickets are completely invalid; these are tickets that contain values which aren't valid
  for any field. Ignore your ticket for now.

  For example, suppose you have the following notes:

      class: 1-3 or 5-7
      row: 6-11 or 33-44
      seat: 13-40 or 45-50

      your ticket:
      7,1,14

      nearby tickets:
      7,3,47
      40,4,50
      55,2,20
      38,6,12

  It doesn't matter which position corresponds to which field; you can identify invalid nearby tickets by considering
  only whether tickets contain values that are not valid for any field. In this example, the values on the first nearby
  ticket are all valid for at least one field. This is not true of the other three nearby tickets: the values 4, 55, and
  12 are are not valid for any field. Adding together all of the invalid values produces your ticket scanning error
  rate: 4 + 55 + 12 = 71.

  Consider the validity of the nearby tickets you scanned. What is your ticket scanning error rate?

  --- Part Two ---

  Now that you've identified which tickets contain invalid values, discard those tickets entirely. Use the remaining
  valid tickets to determine which field is which.

  Using the valid ranges for each field, determine what order the fields appear on the tickets. The order is consistent
  between all tickets: if seat is the third field, it is the third field on every ticket, including your ticket.

  For example, suppose you have the following notes:

      class: 0-1 or 4-19
      row: 0-5 or 8-19
      seat: 0-13 or 16-19

      your ticket:
      11,12,13

      nearby tickets:
      3,9,18
      15,1,5
      5,14,9

  Based on the nearby tickets in the above example, the first position must be row, the second position must be class,
  and the third position must be seat; you can conclude that in your ticket, class is 12, row is 11, and seat is 13.

  Once you work out which field is which, look for the six fields on your ticket that start with the word departure.
  What do you get if you multiply those six values together?
  """

  defp read_input_file() do
    {:ok, input} = File.read("input.txt")

    [fields, [_my_header, my_ticket], [_nearby_header | nearby_tickets]] =
      input
      |> String.split("\n\n")
      |> Enum.map(&String.split(&1, "\n"))

    [fields, my_ticket, Enum.reject(nearby_tickets, &(&1 == ""))]
  end

  defp parse_field_ranges(field_string, fields_map) do
    [[field_name | ranges]] =
      Regex.scan(~r/^(.+): ([\d]+-[\d]+) ?o?r? ?([\d]+-[\d]+)/, field_string,
        capture: :all_but_first
      )

    Map.put(
      fields_map,
      field_name,
      Enum.map(ranges, fn range ->
        range |> String.split("-") |> Enum.map(&String.to_integer/1)
      end)
    )
  end

  defp contains([min, max], value), do: min <= value and value <= max

  defp get_field_range(value, field_ranges) do
    field_ranges
    |> Enum.filter(fn {_field_name, ranges} -> Enum.any?(ranges, &contains(&1, value)) end)
  end

  defp get_field_name(value, field_ranges) do
    get_field_range(value, field_ranges)
    |> Enum.map(fn {field_name, _ranges} -> field_name end)
  end

  defp get_invalid_value(ticket, field_ranges) do
    ticket
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.filter(fn value -> get_field_range(value, field_ranges) == [] end)
  end

  def part_1() do
    [fields, _my_ticket, nearby_tickets] = read_input_file()

    field_ranges =
      fields
      |> Enum.reduce(%{}, &parse_field_ranges/2)

    nearby_tickets
    |> Enum.map(&get_invalid_value(&1, field_ranges))
    |> List.flatten()
    |> Enum.sum()
  end

  defp get_possible_fields(values, field_ranges) do
    [first_ticket | rest] =
      values
      |> Tuple.to_list()
      |> Enum.map(&get_field_name(String.to_integer(&1), field_ranges))

    Enum.filter(first_ticket, fn x -> Enum.all?(rest, &(x in &1)) end)
  end

  defp reduce_possibilities({_list, []}), do: nil

  defp reduce_possibilities({list, possibilities}) do
    {[field_name], index} =
      possibilities
      |> Enum.filter(fn {fields, _index} -> Enum.count(fields) == 1 end)
      |> List.first()

    new_possibilities =
      possibilities
      |> Enum.map(fn {possible_fields, index} ->
        {List.delete(possible_fields, field_name), index}
      end)
      |> Enum.reject(fn {names, _index} -> names == [] end)

    {list ++ [{field_name, index}], {list ++ [{field_name, index}], new_possibilities}}
  end

  def part_2() do
    [fields, my_ticket, nearby_tickets] = read_input_file()

    field_ranges = Enum.reduce(fields, %{}, &parse_field_ranges/2)

    field_values =
      nearby_tickets
      |> Enum.filter(&(get_invalid_value(&1, field_ranges) == []))
      |> Enum.map(&String.split(&1, ","))
      |> Enum.zip()

    field_positions =
      {
        [],
        field_values
        |> Enum.map(&get_possible_fields(&1, field_ranges))
        |> Enum.with_index()
      }
      |> Stream.unfold(&reduce_possibilities/1)
      |> Enum.take(-1)
      |> List.first()

    indexes =
      field_positions
      |> Enum.filter(fn {name, _index} -> name =~ "departure" end)
      |> Enum.map(fn {_name, index} -> index end)

    indexes
    |> Enum.map(fn x -> Enum.at(String.split(my_ticket, ","), x) end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(&Kernel.*/2)
  end
end

IO.inspect(Day16.part_1())
IO.inspect(Day16.part_2())
