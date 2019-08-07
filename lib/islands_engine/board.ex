defmodule IslandsEngine.Board do
  @moduledoc """
  Module for create the board, in this board the players put the islands
  and guesses.
  """
  alias IslandsEngine.{Coordinate, Island}

  @type guess_response :: {:hit | :miss, %Island{} | :none, :win | :no_win, map}

  @spec new :: map

  def new, do: %{}

  @spec position_island(map, atom, %Island{}) ::
  {:error, :overlapping_island} | map

  def position_island(board, key, %Island{} = island) do
    case overlaps_existing_island?(board, key, island) do
      true  -> {:error, :overlapping_island}
      false -> Map.put(board, key, island)
    end
  end

  @spec overlaps_existing_island?(map, atom, %Island{}) :: list

  defp overlaps_existing_island?(board, new_key, new_island) do
    Enum.any?(board, fn {key, island} ->
      key != new_key and Island.overlaps?(island, new_island)
    end)
  end

  @spec all_islands_positioned?(map) :: boolean

  def all_islands_positioned?(board), do:
    Enum.all?(Island.types, &(Map.has_key?(board, &1)))

  @spec guess(map, %Coordinate{}) :: guess_response

  def guess(board, %Coordinate{} = coordinate) do
    board
    |> check_all_islands(coordinate)
    |> guess_response(board)
  end

  @spec check_all_islands(map, %Coordinate{}) :: {atom, %Island{}} | false

  defp check_all_islands(board, coordinate) do
    Enum.find_value(board, :miss, fn {key, island} ->
      case Island.guess(island, coordinate) do
        {:hit, island} -> {key, island}
        :miss          -> false
      end
    end)
  end

  @spec guess_response(tuple | :miss, map) :: guess_response

  defp guess_response({key, island}, board) do
    board = %{board | key => island}
    {:hit, forest_check(board, key), win_check(board), board}
  end
  defp guess_response(:miss, board), do: {:miss, :none, :no_win, board}

  @spec forest_check(map, atom) :: atom | :none

  defp forest_check(board, key) do
    case forested?(board, key) do
      true  -> key
      false -> :none
    end
  end

  @spec forested?(map, atom) :: boolean

  defp forested?(board, key) do
    board
    |> Map.fetch!(key)
    |> Island.forested?()
  end

  @spec win_check(map) :: :win | :no_win

  defp win_check(board) do
    case all_forested?(board) do
      true  -> :win
      false -> :no_win
    end
  end

  @spec all_forested?(map) :: boolean

  defp all_forested?(board), do:
    Enum.all?(board, fn {_key, island} -> Island.forested?(island) end)
end
