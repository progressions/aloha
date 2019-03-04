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
    {mod, fun, args} = Application.get_env(:aloha, :hello)
    apply(mod, fun, args)
  end

  def hello_world do
    :world
  end
end
