defmodule IslandsEngine.Game do
  @moduledoc """
  Genserver for the islands engine game
  """
  use GenServer

  alias IslandsEngine.{Board, Guesses, Rules}

  def start_link(name) when is_binary(name), do:
    GenServer.start_link(__MODULE__, name, [])

  def demo_call(game) do
    GenServer.call(game, :demo_call)
  end

  def demo_cast(pid, new_value) do
    GenServer.cast(pid, {:demo_cast, new_value})
  end

  def add_player(game, name) when is_binary(name), do:
    GenServer.call(game, {:add_player, name})

  def init(name) do
    player1 = %{name: name, board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil, board: Board.new(), guesses: Guesses.new()}
    {:ok, %{player1: player1, player2: player2, rules: %Rules{}}}
  end

  def handle_call({:add_player, name}, _from, state_data) do
    with {:ok, rules} <- Rules.check(state_data.rules, :add_player)
    do
      state_data
      |> update_player2_name(name)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state_data}
    end
  end

  def handle_call(:demo_call, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:demo_cast, new_value}, state) do
    {:noreply, Map.put(state, :test, new_value)}
  end

  def handle_info(:first, state) do
    IO.puts "This message has been handled by handle_info/2, matching on :first"
    {:noreply, state}
  end

  defp update_player2_name(state_data, name), do:
    put_in(state_data.player2.name, name)

  defp update_rules(state_data, rules), do: %{state_data | rules: rules}

  defp reply_success(state_data, reply), do: {:reply, reply, state_data}
end
