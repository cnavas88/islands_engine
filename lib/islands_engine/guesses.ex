defmodule IslandsEngine.Guesses do
  @moduledoc """
  Module for create the guesses.
  """
  alias IslandsEngine.{Coordinate, Guesses}

  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  @spec new :: %Guesses{}

  def new, do:
    %Guesses{hits: MapSet.new(), misses: MapSet.new()}

  @spec add(%Guesses{}, :hit | :miss, %Coordinate{}) :: %Guesses{}

  def add(%Guesses{} = guesses, :hit, %Coordinate{} = coordinate), do:
    update_in(guesses.hits, &MapSet.put(&1, coordinate))
  def add(%Guesses{} = guesses, :miss, %Coordinate{} = coordinate), do:
    update_in(guesses.misses, &MapSet.put(&1, coordinate))
end
