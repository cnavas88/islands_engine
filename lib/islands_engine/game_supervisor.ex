defmodule IslandsEngine.GameSupervisor do
  @moduledoc """
  Supervisor for the island game
  """
  use Supervisor

  alias IslandsEngine.Game

  # PUBLIC API

  @spec start_link(any) :: Supervisor.on_start

  def start_link(_options), do:
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @spec start_game(String.t) :: Supervisor.on_start_child

  def start_game(name), do:
    Supervisor.start_child(__MODULE__, [name])

  @spec stop_game(String.t) :: :ok | {:error, :not_found}

  def stop_game(name) do
    :ets.delete(:game_state, name)
    Supervisor.terminate_child(__MODULE__, pid_from_name(name))
  end

  # CALLBACKS

  @impl Supervisor

  def init(:ok), do:
    Supervisor.init([Game], strategy: :simple_one_for_one)

  # AUXILIARY FUNCTIONS

  @spec pid_from_name(String.t) :: pid

  defp pid_from_name(name) do
    name
    |> Game.via_tuple()
    |> GenServer.whereis()
  end
end
