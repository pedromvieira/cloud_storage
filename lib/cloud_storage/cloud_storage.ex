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
