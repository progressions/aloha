defmodule Aloha do
  @moduledoc """
  Documentation for Aloha.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Aloha.hello()
      :world

  """
  def hello do
    [module: mod, function: fun] = Application.get_env(:aloha, :hello)
    apply(mod, fun, [])
  end

  def hello_world do
    :world
  end
end
