defmodule CloudStorage do
  @moduledoc """
  CloudStorage Documentation.
  """

  @base_bucket Application.get_env(:cloud_storage, :google_base_bucket)

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
  """
  def list(storage, full_path \\ "", folders \\ false, bucket \\ @base_bucket) do
    module =
      storage
      |> module()
    fun =
      __ENV__
      |> fun()
    args =
      [
        full_path,
        folders,
        bucket
      ]
    apply(module, fun, args)
  end

  @doc """
  Delete a File.
  """
  def delete(storage, full_path \\ "", bucket \\ @base_bucket) do
    module =
      storage
      |> module()
    fun =
      __ENV__
      |> fun()
    args =
      [
        full_path,
        bucket
      ]
    apply(module, fun, args)
  end

  @doc """
  Send a File.
  """
  def put(storage, full_path, content \\ "", type \\ "application/octet-stream", bucket \\ @base_bucket) do
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
        type,
        bucket
      ]
    apply(module, fun, args)
  end

  @doc """
  Upload a File from an URL.
  """
  def url(storage, url, remote_path, bucket \\ @base_bucket) do
    module =
      storage
      |> module()
    fun =
      __ENV__
      |> fun()
    args =
      [
        url,
        remote_path,
        bucket
      ]
    apply(module, fun, args)
  end

  @doc """
  Upload a File.
  """
  def upload(storage, local_path, remote_path, bucket \\ @base_bucket) do
    module =
      storage
      |> module()
    fun =
      __ENV__
      |> fun()
    args =
      [
        local_path,
        remote_path,
        bucket
      ]
    apply(module, fun, args)
  end

  @doc """
  Download a File.
  """
  def download(storage, remote_path, local_path, bucket \\ @base_bucket) do
    module =
      storage
      |> module()
    fun =
      __ENV__
      |> fun()
    args =
      [
        remote_path,
        local_path,
        bucket
      ]
    apply(module, fun, args)
  end

  @doc """
  Get a File.
  """
  def get(storage, full_path, bucket \\ @base_bucket) do
    module =
      storage
      |> module()
    fun =
      __ENV__
      |> fun()
    args =
      [
        full_path,
        bucket
      ]
    apply(module, fun, args)
  end

  @doc """
  Purge a File.
  """
  def purge(storage, full_path, bucket \\ @base_bucket) do
    module =
      storage
      |> module()
    fun =
      __ENV__
      |> fun()
    args =
      [
        full_path,
        bucket
      ]
    apply(module, fun, args)
  end

end
