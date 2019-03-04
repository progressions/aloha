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
    Application.get_env(:aloha, :hello).()
  end
end
