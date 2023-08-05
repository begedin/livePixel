defmodule ECS.Registry do
  @moduledoc """
  # ECS.Registry

  Component registry. Used by systems to locate components of its type.

  ## Examples

  ```
  iex> {:ok, r} = ECS.Registry.start
  iex> :ok = ECS.Registry.insert("test", r)
  iex> [pid] = ECS.Registry.get("test")
  ```
  """

  def start do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def insert(component_type, component_pid) do
    Agent.update(__MODULE__, fn registry ->
      components = Map.get(registry, component_type, []) ++ [component_pid]
      Map.put(registry, component_type, components)
    end)
  end

  def get(component_type) do
    Agent.get(__MODULE__, fn registry ->
      Map.get(registry, component_type, [])
    end)
  end
end
