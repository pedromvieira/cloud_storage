# CloudStorage

Elixir package to interact via REST API with Azure Storage and CDN Endpoint. [https://hex.pm/packages/cloud_storage](https://hex.pm/packages/cloud_storage).

## Installation

1. Setup your Azure Subscription, CDN Endpoint and Application via CLI or Portal:

```

   az login
   az ad sp create-for-rbac --name "MyApp" --password "MyPassword"
    "appId": [MyObjectID]
   az role assignment create --assignee [MyObjectID] --role "CDN Endpoint Contributor"
   az storage account keys list --account-name [ACCOUNT] --resource-group [RESOURCE]
    "value:" [KEY]  

```

2. Generate a Shared Access Signature in your Storage Account via CLI or Portal:

```

  az storage container generate-sas --permissions dlrw --account-name phishxcdn --expiry "2019-12-31" --account-key [KEY] --name [CONTAINER] --https-only

```

3. Add `cloud_storage` to your list of dependencies in `mix.exs`:

```elixir

def deps do
  [
    {:cloud_storage, "~> 0.3.2"}
  ]
end

```

4. Update your configuration:

```elixir

config :cloud_storage,
  azure_default_scheme: "https://",
  azure_default_base_url: ".blob.core.windows.net/",
  azure_default_account: System.get_env("AZURE_ACCOUNT"),
  azure_default_container: System.get_env("AZURE_CONTAINER"),
  azure_default_sas_token: System.get_env("AZURE_SAS_TOKEN"),
  azure_default_subscription: System.get_env("AZURE_SUBSCRIPTION"),
  azure_default_resourcegroup: System.get_env("AZURE_RESOURCE_GROUP"),
  azure_default_provider: System.get_env("AZURE_PROVIDER"),
  azure_default_profile: System.get_env("AZURE_PROFILE"),
  azure_default_endpoint: System.get_env("AZURE_ENDPOINT"),
  azure_default_tenant: System.get_env("AZURE_TENANT"),
  azure_default_client: System.get_env("AZURE_CLIENT_ID"),
  azure_default_client_secret: System.get_env("AZURE_CLIENT_SECRET"),
  azure_default_base_resource: "https://management.azure.com/",
  azure_default_base_login: "https://login.microsoftonline.com/"

```

## Usage

```elixir

  iex> CloudStorage.Azure.put_blob("temp_file.txt")
  :ok

  iex> CloudStorage.Azure.get_blob("temp_file.txt")
  ""

  iex> CloudStorage.Azure.list_blobs("temp_file.txt") |> Map.get("Name")
  "temp_file.txt"

  iex> CloudStorage.Azure.download_blob("temp_file.txt","test")
  :ok

  iex> CloudStorage.Azure.upload_blob("test/temp_file.txt","temp_file.txt")
  :ok

  iex> CloudStorage.Azure.delete_blob("temp_file.txt")
  :ok

  iex> CloudStorage.Azure.get_token()

  iex> CloudStorage.Azure.get_token() |> CloudStorage.Azure.purge_content("/temp_file.txt")

  iex> CloudStorage.Azure.url_upload "https://www.google.com.br/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png", "logo.png")

```

## News

- **2018/04/01**
  - Allow URL Upload with insecure HTTPS from source.
- **2017/09/13**
  - Upload Azure CLI.
- **2017/08/15**
  - Upload from URL and Updated Docs.
- **2017/08/11**
  - Initial version


## Documentation

Docs can be found at [https://hexdocs.pm/cloud_storage](https://hexdocs.pm/cloud_storage).

## License

    Copyright © 2017 Pedro Vieira <pedro@vieira.net>

    This work is free. You can redistribute it and/or modify it under the
    terms of the MIT License. See the LICENSE file for more details.