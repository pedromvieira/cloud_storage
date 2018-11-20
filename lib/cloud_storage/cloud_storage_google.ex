defmodule CloudStorage.Google do
  @moduledoc """
  CloudStorage Google Documentation.
  """

  use Goth.Config

  @base_scheme "https://www.googleapis.com/storage/v1/b/"
  @base_upload_scheme "https://www.googleapis.com/upload/storage/v1/b/"
  @base_bucket Application.get_env(:cloud_storage, :google_base_bucket)
  @project_id Application.get_env(:cloud_storage, :google_project_id)

  def init(config) do
    {:ok, Keyword.put(config, :json, json())}
  end

  def json do
    %{
      type: Application.get_env(:cloud_storage, :google_type),
      project_id: @project_id,
      private_key_id: Application.get_env(:cloud_storage, :google_private_key_id),
      private_key: Application.get_env(:cloud_storage, :google_private_key),
      client_email: Application.get_env(:cloud_storage, :google_client_email),
      client_id: Application.get_env(:cloud_storage, :google_client_id),
      auth_uri: Application.get_env(:cloud_storage, :google_auth_uri),
      token_uri: Application.get_env(:cloud_storage, :google_token_uri),
      auth_provider_x509_cert_url: Application.get_env(:cloud_storage, :google_auth_provider_x509_cert_url),
      client_x509_cert_url: Application.get_env(:cloud_storage, :google_client_x509_cert_url)
    }
    |> Poison.encode!()
  end

  @doc """
  Get a Rest Token.

  ## Examples

    iex> CloudStorage.Google.get_token() |> is_nil()
    false

  """
  def get_token do
    {:ok, token} =
      Goth.Token.for_scope(Application.get_env(:cloud_storage, :google_scope_default))
    token
  end

  defp header_get do
    token =
      get_token()
      |> Map.get(:token)
    [
      {"Authorization", "Bearer #{token}"},
    ]
  end

  defp header_post(type) do
    token =
      get_token()
      |> Map.get(:token)
    [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", type}
    ]
  end

  @doc """
  List Files.

  ## Examples

    iex> CloudStorage.Google.list("temp_file.txt") |> elem(1) |> List.first() |> Map.get("name")
    "temp_file.txt"

  """
  def list(full_path \\ "", folders \\ false) do
    header =
      header_get()
    params =
      "?prefix=#{full_path}"
    temp_url =
      @base_bucket
      |> Kernel.<>("/o")
    url =
      @base_scheme
      |> Kernel.<>(temp_url)
      |> Kernel.<>(params)
    {status, items} =
      HTTPoison.get(url, header)
    case status do
      :ok ->
        case items.status_code do
          200 ->
            temp_items =
              items
              |> Map.get(:body)
              |> Poison.decode!()
              |> Map.get("items")
              |> Enum.map(fn x ->
                %{
                  "content-type" => x["contentType"],
                  "name" => x["name"],
                  "updated" => x["updated"]
                }
              end)
            final_items =
              case folders do
                true ->
                  temp_items
                false ->
                  temp_items
                  |> Enum.filter(fn x ->
                    ~r/\/$/
                    |> Regex.match?(x["name"])
                    |> Kernel.not()
                  end)
              end
            {:ok, final_items}
          _ ->
            reason =
              items
              |> Map.get(:body)
              |> Poison.decode!()
              |> Map.get("error")
              |> Map.get("message")
            {:error, reason}
        end
      :error ->
        {:error, items.status_code}
    end
  end

  @doc """
  Delete a File.

  ## Examples

    iex> CloudStorage.Google.delete("temp_file.txt")
    {:ok, "temp_file.txt"}
    iex> CloudStorage.Google.put("temp_file.txt")
    {:ok, "temp_file.txt"}

  """
  def delete(full_path) do
    header =
      header_get()
    temp_url =
      @base_bucket
      |> Kernel.<>("/o/")
      |> Kernel.<>(full_path)
    url =
      @base_scheme
      |> Kernel.<>(temp_url)
    {status, item} =
      HTTPoison.delete(url, header)
    case status do
      :ok ->
        case item.status_code do
          204 ->
            {:ok, full_path}
          _ ->
            reason =
              item
              |> Map.get(:body)
              |> Poison.decode!()
              |> Map.get("error")
              |> Map.get("message")
            {:error, reason}
        end
      :error ->
        {:error, item.status_code}
    end
  end

  @doc """
  Send a File.

  ## Examples

    iex> CloudStorage.Google.put("temp_file.txt")
    {:ok, "temp_file.txt"}

  """
  def put(full_path, content \\ "", type \\ "application/octet-stream") do
    header =
      type
      |> header_post()
    params =
      "?uploadType=media&predefinedAcl=publicRead&name=#{full_path}"
    temp_url =
      @base_bucket
      |> Kernel.<>("/o")
      |> Kernel.<>(params)
    url =
      @base_upload_scheme
      |> Kernel.<>(temp_url)
    {status, item} =
      HTTPoison.post(url, content, header)
    case status do
      :ok ->
        case item.status_code do
          200 ->
            {:ok, full_path}
          _ ->
            reason =
              item
              |> Map.get(:body)
              |> Poison.decode!()
              |> Map.get("error")
              |> Map.get("message")
            {:error, reason}
        end
      :error ->
        {:error, item.status_code}
    end
  end

end
