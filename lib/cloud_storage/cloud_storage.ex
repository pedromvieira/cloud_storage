defmodule CloudStorage do
  @moduledoc """
  CloudStorage Documentation.
  """

  alias CloudStorage.Azure
  alias CloudStorage.Google

  defp module(storage) do
    case storage do
      :azure ->
        Azure
      :google ->
        Google
    end
  end

  defp fun(enum) do
    enum
    |> Map.get(:function)
    |> elem(0)
  end

  @doc """
  Get a Rest Token.

  ## Examples

    iex> CloudStorage.get_token(:azure) |> is_nil()
    false

  """
  def get_token(storage) do
    module =
      storage
      |> module()
    fun =
      __ENV__
      |> fun()
    args =
      []
    apply(module, fun, args)
  end

  @doc """
  List Files.

  ## Examples

    iex> CloudStorage.list(:azure, "temp_file.txt") |> elem(1) |> List.first() |> Map.get("name")
    "temp_file.txt"

  """
  def list(storage, full_path \\ "", folders \\ false) do
    module =
      storage
      |> module()
    fun =
      __ENV__
      |> fun()
    args =
      [
        full_path,
        folders
      ]
    apply(module, fun, args)
  end

  @doc """
  Delete a File.

  ## Examples

    iex> CloudStorage.delete(:azure, "temp_file.txt")
    {:ok, "temp_file.txt"}
    iex> CloudStorage.put(:azure, "temp_file.txt")
    {:ok, "temp_file.txt"}

  """
  def delete(storage, full_path \\ "") do
    module =
      storage
      |> module()
    fun =
      __ENV__
      |> fun()
    args =
      [
        full_path
      ]
    apply(module, fun, args)
  end

  @doc """
  Send a File.

  ## Examples

    iex> CloudStorage.put(:azure, "temp_file.txt")
    {:ok, "temp_file.txt"}

  """
  def put(storage, full_path, content \\ "", type \\ "application/octet-stream") do
    module =
      storage
      |> module()
    fun =
      __ENV__
      |> fun()
    args =
      [
        full_path,
        content,
        type
      ]
    apply(module, fun, args)
  end

end
