defmodule CloudStorage.Azure do
  @moduledoc """
  CloudStorage Azure Documentation.
  """

  @base_scheme Application.get_env(:cloudstorage, :azure_default_scheme)
  @base_url Application.get_env(:cloudstorage, :azure_default_base_url)
  @storage_account Application.get_env(:cloudstorage, :azure_default_account)
  @container Application.get_env(:cloudstorage, :azure_default_container)
  @sas_token Application.get_env(:cloudstorage, :azure_default_sas_token)
  @subscription_id Application.get_env(:cloudstorage, :azure_default_subscription)
  @resourcegroup Application.get_env(:cloudstorage, :azure_default_resourcegroup)
  @provider Application.get_env(:cloudstorage, :azure_default_provider)
  @profile Application.get_env(:cloudstorage, :azure_default_profile)
  @endpoint Application.get_env(:cloudstorage, :azure_default_endpoint)
  @tenant_id Application.get_env(:cloudstorage, :azure_default_tenant)
  @client_id Application.get_env(:cloudstorage, :azure_default_client)
  @client_secret Application.get_env(:cloudstorage, :azure_default_client_secret)
  @base_resource Application.get_env(:cloudstorage, :azure_default_base_resource)
  @base_login Application.get_env(:cloudstorage, :azure_default_base_login)

  @doc """
  List Files.
  """
  def list_blobs(full_path, storage_account \\ @storage_account, container \\ @container, sas_token \\ @sas_token) do
    base_url = @base_scheme <> storage_account <> @base_url <> container <> sas_token
    url = base_url <> "&restype=container&comp=list&prefix=" <> full_path
    HTTPoison.get(url)
    |> elem(1)
    |> Map.get(:body)
    |> XmlToMap.naive_map()
    |> Map.get("EnumerationResults")
    |> Map.get("Blobs")
    |> Map.get("Blob")
  end

  @doc """
  Get a File.
  """
  def get_blob(full_path, storage_account \\ @storage_account, container \\ @container, sas_token \\ @sas_token) do
    url = @base_scheme <> storage_account <> @base_url <> container <> "/" <> full_path <> sas_token
    HTTPoison.get(url)
    |> elem(1)
    |> Map.get(:body)
  end

  @doc """
  Send a File.
  """
  def put_blob(full_path, content \\ "", type \\ "application/octet-stream", storage_account \\ @storage_account, container \\ @container, sas_token \\ @sas_token) do
    url = @base_scheme <> storage_account <> @base_url <> container <> "/" <> full_path <> sas_token
    HTTPoison.put(url, content, ["Content-Type": type, "Content-Length": 0, "x-ms-blob-type": "BlockBlob"] )
  end

  @doc """
  Delete a File.
  """
  def delete_blob(full_path, storage_account \\ @storage_account, container \\ @container, sas_token \\ @sas_token) do
    url = @base_scheme <> storage_account <> @base_url <> container <> "/" <> full_path <> sas_token
    HTTPoison.delete(url)
  end

  @doc """
  Download a File.
  """
  def download_blob(remote_path, local_path, storage_account \\ @storage_account, container \\ @container) do
    file_content =
      get_blob(remote_path, storage_account, container)
    local_file =
      remote_path
      |> String.split("/")
      |> List.last
    full_local_path = local_path <> "/" <> local_file
    File.write(full_local_path, file_content)
  end

  @doc """
  Upload a File.
  """
  def upload_blob(local_path, remote_path, storage_account \\ @storage_account, container \\ @container) do
    {:ok, file_content} = File.read(local_path)
    file_type =
      MIME.from_path(remote_path)
    put_blob(remote_path, file_content, file_type, storage_account, container)
  end

  @doc """
  Get a Rest Token.
  """
  def get_token(tenant_id \\ @tenant_id, client_id \\ @client_id, client_secret \\ @client_secret) do
    post_url = "/oauth2/token"
    url = @base_login <> tenant_id <> post_url
    body = "grant_type=client_credentials&client_id=" <> client_id <> "&client_secret=" <> client_secret <> "&resource=" <> @base_resource
    header = ["Content-Type": "application/x-www-form-urlencoded"]
    {:ok, response} = HTTPoison.post(url, body, header)
    response.body
    |> Poison.decode!()
    |> Map.get("access_token")
  end

  @doc """
  Purge a CDN path content.
  """
  def purge_content(token, path, subscription_id \\ @subscription_id, resourcegroup \\ @resourcegroup, provider \\ @provider, profile \\ @profile, endpoint \\ @endpoint) do
    header = ["Content-Type": "application/json", "Authorization": "Bearer " <> token]
    params = "?api-version=2016-10-02"
    post_url = "/resourceGroups/" <> resourcegroup <> "/providers/" <> provider <> "/profiles/" <> profile <> "/endpoints/" <> endpoint <> "/purge" <> params
    url = @base_resource <> "subscriptions/" <> subscription_id <> post_url
    body = "{ \"contentPaths\": [\"" <> path <> "\"] }"
    {:ok, response} = HTTPoison.post(url, body, header)
    case Map.get(response, :status_code) do
      202 -> :ok
      _ -> :error
    end
  end

end
