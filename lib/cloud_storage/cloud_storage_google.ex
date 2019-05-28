defmodule CloudStorage.Google do
  @moduledoc """
  CloudStorage Google Documentation.
  """

  use Goth.Config

  @base_bucket Application.get_env(:cloud_storage, :google_base_bucket)
  @base_scheme "https://www.googleapis.com/storage/v1/b/"
  @base_upload_scheme "https://www.googleapis.com/upload/storage/v1/b/"
  @options [timeout: 600_000, recv_timeout: 600_000]
  @project_id Application.get_env(:cloud_storage, :google_project_id)

  def init(config) do
    {:ok, Keyword.put(config, :json, json())}
  end

  defp json do
    %{
      type: Application.get_env(:cloud_storage, :google_type),
      project_id: @project_id,
      private_key_id: Application.get_env(:cloud_storage, :google_private_key_id),
      private_key:
        Application.get_env(:cloud_storage, :google_private_key)
        |> String.replace("\\n", "\n"),
      client_email: Application.get_env(:cloud_storage, :google_client_email),
      client_id: Application.get_env(:cloud_storage, :google_client_id),
      auth_uri: Application.get_env(:cloud_storage, :google_auth_uri),
      token_uri: Application.get_env(:cloud_storage, :google_token_uri),
      auth_provider_x509_cert_url: Application.get_env(:cloud_storage, :google_auth_provider_x509_cert_url),
      client_x509_cert_url: Application.get_env(:cloud_storage, :google_client_x509_cert_url)
    }
    |> Jason.encode!()
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
  Upload a File from an URL.

  ## Examples

    iex> CloudStorage.Google.url("https://www.google.com.br/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png", "accounts/logo.png")
    {:ok, "accounts/logo.png"}

  """
  def url(url, remote_path, bucket \\ @base_bucket) do
    options =
      [
        hackney: [:insecure]
      ]
    {:ok, response} =
      HTTPoison.get(url, [], options)
    case response.status_code do
      200 ->
        content =
          response.body
        type =
          response.headers
          |> List.keyfind("Content-Type", 0)
          |> elem(1)
        put(remote_path, content, type, bucket)
      _ ->
        {:error, response.status_code}
    end
  end

  @doc """
  List Files.

  ## Examples

    iex> CloudStorage.Google.list("accounts/logo.png") |> elem(1) |> List.first() |> Map.get("name")
    "accounts/logo.png"

  """
  def list(full_path \\ "", folders \\ false, bucket \\ @base_bucket) do
    header =
      header_get()
    params =
      "?prefix=#{full_path}"
    temp_url =
      "#{bucket}"
      |> Kernel.<>("/o")
    url =
      "#{@base_scheme}"
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
              |> Jason.decode!()
              |> Map.get("items")
            filter_items =
              case is_nil(temp_items) do
                true ->
                  temp_items
                false ->
                  temp_items
                  |> Enum.map(fn x ->
                    %{
                      "content-type" => x["contentType"],
                      "name" => x["name"],
                      "updated" => x["updated"]
                    }
                  end)
              end
            final_items =
              case folders do
                true ->
                  filter_items
                false ->
                  case is_nil(filter_items) do
                    true ->
                      filter_items
                    false ->
                      filter_items
                      |> Enum.filter(fn x ->
                        ~r/\/$/
                        |> Regex.match?(x["name"])
                        |> Kernel.not()
                      end)
                  end
              end
            {:ok, final_items}
          _ ->
            reason =
              items
              |> Map.get(:body)
              |> Jason.decode!()
              |> Map.get("error")
              |> Map.get("message")
            {:error, reason}
        end
      :error ->
        {:error, items.status_code}
    end
  end

  @doc """
  Get Files.

  ## Examples

    iex> CloudStorage.Google.get("accounts/logo.png") |> elem(0)
    :ok

  """
  def get(full_path, bucket \\ @base_bucket) do
    final_path =
      full_path
      |> URI.encode_www_form()
    header =
      header_get()
    temp_url =
      "#{bucket}"
      |> Kernel.<>("/o/")
      |> Kernel.<>(final_path)
    url =
      "#{@base_scheme}"
      |> Kernel.<>(temp_url)
    {status, items} =
      HTTPoison.get(url, header, @options)
    case status do
      :ok ->
        case items.status_code do
          200 ->
            file_url =
              items
              |> Map.get(:body)
              |> Jason.decode!()
              |> Map.get("mediaLink")
            {_status, item} =
              file_url
              |> HTTPoison.get()
            content =
              item
              |> Map.get(:body)
            {:ok, content}
          _ ->
            reason =
              items
              |> Map.get(:body)
              |> Jason.decode!()
              |> Map.get("error")
              |> Map.get("message")
            {:error, reason}
        end
      :error ->
        {:error, items.status_code}
    end
  end

  @doc """
  Download a File.

  ## Examples

    iex> CloudStorage.Google.download("accounts/temp_file.txt", "test")
    {:ok, "test/temp_file.txt"}

  """
  def download(remote_path, local_path, bucket \\ @base_bucket) do
    {_status, file_content} =
      get(remote_path, bucket)
    local_file =
      remote_path
      |> String.split("/")
      |> List.last
    full_local_path =
      local_path
      |> Kernel.<>("/")
      |> Kernel.<>(local_file)
    local_status =
      File.write(full_local_path, file_content)
    {local_status, full_local_path}
  end

  @doc """
  Upload a File.

  ## Examples

    iex> CloudStorage.Google.upload("test/temp_file.txt", "accounts/temp_file.txt")
    {:ok, "accounts/temp_file.txt"}

  """
  def upload(local_path, remote_path, bucket \\ @base_bucket) do
    {:ok, file_content} =
      File.read(local_path)
    file_type =
      MIME.from_path(remote_path)
    put(remote_path, file_content, file_type, bucket)
  end

  @doc """
  Delete a File.

  ## Examples

    iex> CloudStorage.Google.delete("accounts/temp_file.txt")
    {:ok, "accounts/temp_file.txt"}
    iex> CloudStorage.Google.put("accounts/temp_file.txt")
    {:ok, "accounts/temp_file.txt"}

  """
  def delete(full_path, bucket \\ @base_bucket) do
    final_path =
      full_path
      |> URI.encode_www_form()
    header =
      header_get()
    temp_url =
      "#{bucket}"
      |> Kernel.<>("/o/")
      |> Kernel.<>(final_path)
    url =
      "#{@base_scheme}"
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
              |> Jason.decode!()
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

    iex> CloudStorage.Google.put("accounts/temp_file.txt")
    {:ok, "accounts/temp_file.txt"}

  """
  def put(full_path, content \\ "", type \\ "application/octet-stream", bucket \\ @base_bucket) do
    header =
      type
      |> header_post()
    params =
      "?uploadType=media&predefinedAcl=publicRead&name=#{full_path}"
    temp_url =
      "#{bucket}"
      |> Kernel.<>("/o")
      |> Kernel.<>(params)
    url =
      "#{@base_upload_scheme}"
      |> Kernel.<>(temp_url)
    {status, item} =
      HTTPoison.post(url, content, header, @options)
    case status do
      :ok ->
        case item.status_code do
          200 ->
            {:ok, full_path}
          _ ->
            reason =
              item
              |> Map.get(:body)
              |> Jason.decode!()
              |> Map.get("error")
              |> Map.get("message")
            {:error, reason}
        end
      :error ->
        {:error, item.status_code}
    end
  end

  @doc """
  Purge a CDN path content.

  ## Examples

    iex> CloudStorage.Google.purge("/accounts/temp_file.txt")
    {:ok, "/accounts/temp_file.txt"}

  """
  def purge(full_path, bucket \\ @base_bucket) do
    header =
      "application/json"
      |> header_post()
    body =
      %{
        path: full_path
      }
      |> Jason.encode!()
    url =
      "https://www.googleapis.com/compute/v1/projects/"
      |> Kernel.<>("#{@project_id}")
      |> Kernel.<>("/global/urlMaps/")
      |> Kernel.<>("#{bucket}-balancer")
      |> Kernel.<>("/invalidateCache")
    {status, item} =
      HTTPoison.post(url, body, header)
    case status do
      :ok ->
        case item.status_code do
          200 ->
            {:ok, full_path}
          _ ->
            reason =
              item
              |> Map.get(:body)
              |> Jason.decode!()
              |> Map.get("error")
              |> Map.get("message")
            {:error, reason}
        end
      :error ->
        {:error, item.status_code}
    end
  end

end
