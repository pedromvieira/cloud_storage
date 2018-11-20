# CloudStorage

Elixir package to interact via REST API with Microsoft Azure Storage and Google Cloud Storage. [https://hex.pm/packages/cloud_storage](https://hex.pm/packages/cloud_storage).

## Installation (AZURE)

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

3. Generate a Application ID and Key for your Application via Portal:

```

  https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#create-an-azure-active-directory-application

```

4. Add `cloud_storage` to your list of dependencies in `mix.exs`:

```elixir

def deps do
  [
    {:cloud_storage, "~> 0.4.0"}
  ]
end

```

5. Update your configuration:

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

## Usage (AZURE)

```elixir

  iex> CloudStorage.Azure.put("temp_file.txt")

  iex> CloudStorage.Azure.get("temp_file.txt")

  iex> CloudStorage.Azure.list("temp_file.txt")

```

## Installation (GOOGLE)

1. Create a Service Account with Storage Object Admin:

```

  https://console.cloud.google.com/iam-admin/serviceaccounts

```

2. Create a Load Balancer:

```

  https://console.cloud.google.com/net-services/loadbalancing/loadBalancers/list

```

3. Create a Storage and give permissions to your Service Account (Storage Object Admin) and to allUsers (Storage Object Viewer):

```

  https://console.cloud.google.com/storage/browser

```

4. Add `cloud_storage` to your list of dependencies in `mix.exs`:

```elixir

def deps do
  [
    {:cloud_storage, "~> 0.4.0"}
  ]
end

```

5. Update your configuration:

```elixir

config :cloud_storage,
  google_type: "service_account",
  google_project_id: System.get_env("GOOGLE_STORAGE_PROJECT_ID"),
  google_private_key_id: System.get_env("GOOGLE_STORAGE_PRIVATE_KEY_ID"),
  google_private_key: System.get_env("GOOGLE_STORAGE_PRIVATE_KEY"),
  google_client_email: System.get_env("GOOGLE_STORAGE_CLIENT_EMAIL"),
  google_client_id: System.get_env("GOOGLE_STORAGE_CLIENT_ID")
  google_auth_uri: "https://accounts.google.com/o/oauth2/auth",
  google_token_uri: "https://oauth2.googleapis.com/token",
  google_auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
  google_client_x509_cert_url: System.get_env("GOOGLE_STORAGE_CLIENT_CERT_URL")
  google_scope_default: "https://www.googleapis.com/auth/cloud-platform",
  google_base_bucket: System.get_env("GOOGLE_STORAGE_BASE_BUCKET")

```

## Usage (GOOGLE)

```elixir

  iex> CloudStorage.put(:azure, "temp_file.txt")

  iex> CloudStorage.get(:azure, "temp_file.txt")

  iex> CloudStorage.list(:google, "temp_file.txt")

```

## News

- **2018/11/23**
  - Add Google Cloud Storage Support.
- **2018/11/13**
  - Fix Get Token & updated API VERSION.
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

    Copyright © 2018 Pedro Vieira <pedro@vieira.net>

    This work is free. You can redistribute it and/or modify it under the
    terms of the MIT License. See the LICENSE file for more details.