defmodule ECS.EntityFactory do
  @moduledoc """
  Holds all functions to create prefab entities
  """

  def bunny do
    ECS.Entity.build([
      ECS.Component.new(:"ECS.TimeComponent", %{age: 0}),
      ECS.Component.new(:"ECS.PositionComponent", %{x: 0, y: 0}),
      ECS.Component.new(:"ECS.VelocityComponent", %{x: 0, y: 0})
    ])
  end
end
