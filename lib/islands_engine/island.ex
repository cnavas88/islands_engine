defmodule IslandsEngine.Island do
  @moduledoc """
  Define an island
  """
  alias IslandsEngine.{Coordinate, Island}

  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct [:coordinates, :hit_coordinates]

  @spec new(atom, %Coordinate{}) :: %Island{} | {:ok, %Island{}} | any

  def new, do: %Island{coordinates: MapSet.new(), hit_coordinates: MapSet.new()}
  def new(type, %Coordinate{} = upper_left) do
    with [_|_] = offsets <- offsets(type),
         %MapSet{} = coordinates <- add_coordinates(offsets, upper_left)
    do
      {:ok, %Island{coordinates: coordinates, hit_coordinates: MapSet.new()}}
    else
      error -> error
    end
  end

  @spec types() :: [atom]

  def types, do: [:atoll, :dot, :l_shape, :s_shape, :square]

  @spec overlaps?(%Island{}, %Island{}) :: boolean

  def overlaps?(existing_island, new_island), do:
    not MapSet.disjoint?(existing_island.coordinates, new_island.coordinates)

  @spec guess(%Island{}, %Coordinate{}) :: {:hit, %Island{}} | :miss

  def guess(island, coordinate) do
    case MapSet.member?(island.coordinates, coordinate) do
      true ->
        hit_coordinates = MapSet.put(island.hit_coordinates, coordinate)
        {:hit, %{island | hit_coordinates: hit_coordinates}}

      false ->
        :miss
    end
  end

  @spec forested?(%Island{}) :: boolean

  def forested?(island), do:
    MapSet.equal?(island.coordinates, island.hit_coordinates)

  @spec offsets(atom) :: [tuple] | {:error, :invalid_island_type}

  defp offsets(:square), do: [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  defp offsets(:atoll), do: [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]
  defp offsets(:dot), do: [{0, 0}]
  defp offsets(:l_shape), do: [{0, 0}, {1, 0}, {2, 0}, {2, 1}]
  defp offsets(:s_shape), do: [{0, 1}, {0, 2}, {1, 0}, {1, 1}]
  defp offsets(_), do: {:error, :invalid_island_type}

  @spec add_coordinates(list, %Coordinate{}) :: list

  defp add_coordinates(offsets, upper_left) do
    Enum.reduce_while(offsets, MapSet.new(), fn offset, acc ->
      add_coordinate(acc, upper_left, offset)
    end)
  end

  @spec add_coordinate(MapSet.t, %Coordinate{}, tuple) ::
  {:cont, MapSet.t} | {:halt, {:error, :invalid_coordinate}}

  defp add_coordinate(coordinates, %Coordinate{row: row, col: col},
       {row_offset, col_offset}) do
    case Coordinate.new(row + row_offset, col + col_offset) do
      {:ok, coordinate} ->
        {:cont, MapSet.put(coordinates, coordinate)}

      {:error, :invalid_coordinate} ->
        {:halt, {:error, :invalid_coordinate}}
    end
  end
end
