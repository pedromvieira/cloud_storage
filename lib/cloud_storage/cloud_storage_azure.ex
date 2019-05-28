defmodule CloudStorage.Azure do
  @moduledoc """
  CloudStorage Azure Documentation.
  """

  @azure_api_version Application.get_env(:cloud_storage, :azure_api_version)
  @base_login Application.get_env(:cloud_storage, :azure_default_base_login)
  @base_resource Application.get_env(:cloud_storage, :azure_default_base_resource)
  @base_scheme Application.get_env(:cloud_storage, :azure_default_scheme)
  @base_url Application.get_env(:cloud_storage, :azure_default_base_url)
  @client_id Application.get_env(:cloud_storage, :azure_default_client)
  @client_secret Application.get_env(:cloud_storage, :azure_default_client_secret)
  @container Application.get_env(:cloud_storage, :azure_default_container)
  @endpoint Application.get_env(:cloud_storage, :azure_default_endpoint)
  @options [timeout: 600_000, recv_timeout: 600_000]
  @profile Application.get_env(:cloud_storage, :azure_default_profile)
  @provider Application.get_env(:cloud_storage, :azure_default_provider)
  @resourcegroup Application.get_env(:cloud_storage, :azure_default_resourcegroup)
  @sas_token Application.get_env(:cloud_storage, :azure_default_sas_token)
  @storage_account Application.get_env(:cloud_storage, :azure_default_account)
  @subscription_id Application.get_env(:cloud_storage, :azure_default_subscription)
  @tenant_id Application.get_env(:cloud_storage, :azure_default_tenant)

  @doc """
  Upload a File from an URL.

  ## Examples

    iex> CloudStorage.Azure.url("https://www.google.com.br/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png", "accounts/logo.png")
    {:ok, "accounts/logo.png"}

  """
  def url(url, remote_path, _bucket \\ nil) do
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
        put(remote_path, content, type)
      _ ->
        {:error, response.status_code}
    end
  end


  @doc """
  Send a File.

  ## Examples

    iex> CloudStorage.Azure.put("accounts/temp_file.txt")
    {:ok, "accounts/temp_file.txt"}

  """
  def put(full_path, content \\ "", type \\ "application/octet-stream", _bucket \\ nil) do
    header =
      [
        "Content-Type": type,
        "Content-Length": 0,
        "x-ms-blob-type": "BlockBlob"
      ]
    url =
      full_path
      |> blob_url()
    {:ok, response} =
      HTTPoison.put(url, content, header, @options)
    case response.status_code do
      201 ->
        {:ok, full_path}
      _ ->
        {:error, response.status_code}
    end
  end

  @doc """
  List Files.

  ## Examples

    iex> CloudStorage.Azure.list("accounts/temp_file.txt") |> elem(1) |> List.first() |> Map.get("name")
    "accounts/temp_file.txt"

  """
  def list(full_path \\ "", _folders \\ false, _bucket \\ nil) do
    base_url =
      "#{@base_scheme}"
      |> Kernel.<>("#{@storage_account}")
      |> Kernel.<>("#{@base_url}")
      |> Kernel.<>("#{@container}")
      |> Kernel.<>("?")
      |> Kernel.<>("#{@sas_token}")
    url =
      base_url
      |> Kernel.<>("&restype=container&comp=list&prefix=")
      |> Kernel.<>(full_path)
    items =
      url
      |> HTTPoison.get()
      |> elem(1)
      |> Map.get(:body)
      |> XmlToMap.naive_map()
      |> Map.get("EnumerationResults")
      |> Map.get("Blobs")
      |> Map.get("Blob")
    temp_items =
      items
      |> is_map()
      |> case do
        true ->
          [items]
        false ->
          items
      end
    final_items =
      case is_nil(temp_items) do
        true ->
          temp_items
        false ->
          temp_items
          |> Enum.map(fn x ->
            %{
              "content-type" => x["Properties"]["Content-Type"],
              "name" => x["Name"],
              "updated" => x["Properties"]["Last-Modified"] |> time_to_local()
            }
          end)
      end
    {:ok, final_items}
  end

  defp time_to_local(datetime) do
    {:ok, timestamp} =
      datetime
      |> Timex.parse("{WDshort}, {D} {Mshort} {YYYY} {h24}:{m}:{s} {Zname}")
    timestamp
    |> Timex.format!("{ISO:Extended:Z}")
  end

  @doc """
  Get a File.

  ## Examples

    iex> CloudStorage.Azure.get("accounts/temp_file.txt")
    {:ok, ""}

  """
  def get(full_path, _bucket \\ nil) do
    url =
      full_path
      |> blob_url()
    content =
      url
      |> HTTPoison.get(@options)
      |> elem(1)
      |> Map.get(:body)
    {:ok, content}
  end

  defp blob_url(full_path) do
    "#{@base_scheme}"
    |> Kernel.<>("#{@storage_account}")
    |> Kernel.<>("#{@base_url}")
    |> Kernel.<>("#{@container}")
    |> Kernel.<>("/")
    |> Kernel.<>(full_path)
    |> Kernel.<>("?")
    |> Kernel.<>("#{@sas_token}")
  end

  @doc """
  Download a File.

  ## Examples

    iex> CloudStorage.Azure.download("accounts/temp_file.txt", "test")
    {:ok, "test/temp_file.txt"}

  """
  def download(remote_path, local_path, _bucket \\ nil) do
    {_status, file_content} =
      get(remote_path)
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

    iex> CloudStorage.Azure.upload("test/temp_file.txt", "accounts/temp_file.txt")
    {:ok, "accounts/temp_file.txt"}

  """
  def upload(local_path, remote_path, _bucket \\ nil) do
    {:ok, file_content} =
      File.read(local_path)
    file_type =
      MIME.from_path(remote_path)
    put(remote_path, file_content, file_type)
  end

  @doc """
  Delete a File.

  ## Examples

    iex> CloudStorage.Azure.delete("accounts/temp_file.txt")
    {:ok, "accounts/temp_file.txt"}
    iex> CloudStorage.Azure.put("accounts/temp_file.txt")
    {:ok, "accounts/temp_file.txt"}

  """
  def delete(full_path, _bucket \\ nil) do
    url =
      full_path
      |> blob_url()
    {:ok, response} =
      HTTPoison.delete(url)
    case response.status_code do
      202 ->
        {:ok, full_path}
      _ ->
        {:error, response.status_code}
    end
  end

  @doc """
  Get a Rest Token.

  ## Examples

    iex> CloudStorage.Azure.get_token() |> is_nil()
    false

  """
  def get_token() do
    header =
      [
        "Content-Type": "application/x-www-form-urlencoded"
      ]
    post_url =
      "/oauth2/token"
    url =
      "#{@base_login}"
      |> Kernel.<>("#{@tenant_id}")
      |> Kernel.<>(post_url)
    body =
      "grant_type=client_credentials&client_id="
      |> Kernel.<>("#{@client_id}")
      |> Kernel.<>("&client_secret=")
      |> Kernel.<>("#{@client_secret}")
      |> Kernel.<>("&resource=")
      |> Kernel.<>("#{@base_resource}")
    {:ok, response} =
      HTTPoison.post(url, body, header)
    response.body
    |> Jason.decode!()
    |> Map.get("access_token")
  end

  @doc """
  Purge a CDN path content.

  ## Examples

    iex> CloudStorage.Azure.purge("/temp_file.txt")
    {:ok, "/temp_file.txt"}

  """
  def purge(full_path, _bucket \\ nil) do
    token =
      get_token()
    header =
      [
        "Content-Type": "application/json",
        "Authorization": "Bearer #{token}"
      ]
    params =
      "?api-version=#{@azure_api_version}"
    post_url =
      "/resourceGroups/"
      |> Kernel.<>("#{@resourcegroup}")
      |> Kernel.<>("/providers/")
      |> Kernel.<>("#{@provider}")
      |> Kernel.<>("/profiles/")
      |> Kernel.<>("#{@profile}")
      |> Kernel.<>("/endpoints/")
      |> Kernel.<>("#{@endpoint}")
      |> Kernel.<>("/purge")
      |> Kernel.<>(params)
    url =
      "#{@base_resource}"
      |> Kernel.<>("subscriptions/")
      |> Kernel.<>("#{@subscription_id}")
      |> Kernel.<>(post_url)
    body =
      "{ \"contentPaths\": [\"#{full_path}\"] }"
    {:ok, response} =
      HTTPoison.post(url, body, header)
    case response.status_code do
      202 ->
        {:ok, full_path}
      _ ->
        {:error, response.status_code}
    end
  end

end
