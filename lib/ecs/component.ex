defmodule ECS.Component do
  @moduledoc """
  A base for creating new Components.
  """

  defstruct [:id, :state]

  @type id :: pid()
  @type component_type :: String.t()
  @type state :: map()
  @type t :: %ECS.Component{
          # Component Agent ID
          id: id,
          state: state
        }

  # Component interface
  @callback new(state) :: t

  defmacro __using__(_options) do
    quote do
      # Require Components to implement interface
      @behaviour ECS.Component
    end
  end

  @doc "Create a new agent to keep the state"
  @spec new(component_type, state) :: t
  def new(component_type, initial_state) do
    {:ok, pid} = ECS.Component.Agent.start_link(initial_state)
    # Register component for systems to reference
    ECS.Registry.insert(component_type, pid)

    %{
      id: pid,
      state: initial_state
    }
  end

  @doc "Retrieves state"
  @spec get(id) :: t
  def get(pid) do
    state = ECS.Component.Agent.get(pid)

    %{
      id: pid,
      state: state
    }
  end

  @doc "Updates state"
  @spec update(id, state) :: t
  def update(pid, new_state) do
    ECS.Component.Agent.set(pid, new_state)

    %{
      id: pid,
      state: new_state
    }
  end
end
