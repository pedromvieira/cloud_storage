use Mix.Config

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
