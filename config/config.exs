use Mix.Config

config :cloud_storage,
  azure_api_version: "2017-10-12",
  azure_default_account: System.get_env("AZURE_ACCOUNT") || "",
  azure_default_base_login: "https://login.microsoftonline.com/",
  azure_default_base_resource: "https://management.azure.com/",
  azure_default_base_url: ".blob.core.windows.net/",
  azure_default_client_secret: System.get_env("AZURE_CLIENT_SECRET") || "",
  azure_default_client: System.get_env("AZURE_CLIENT_ID") || "",
  azure_default_container: System.get_env("AZURE_CONTAINER") || "",
  azure_default_endpoint: System.get_env("AZURE_ENDPOINT") || "",
  azure_default_profile: System.get_env("AZURE_PROFILE") || "",
  azure_default_provider: System.get_env("AZURE_PROVIDER") || "",
  azure_default_resourcegroup: System.get_env("AZURE_RESOURCE_GROUP") || "",
  azure_default_sas_token: System.get_env("AZURE_SAS_TOKEN") || "",
  azure_default_scheme: "https://",
  azure_default_subscription: System.get_env("AZURE_SUBSCRIPTION") || "",
  azure_default_tenant: System.get_env("AZURE_TENANT") || "",
  google_type: "service_account",
  google_project_id: System.get_env("GOOGLE_STORAGE_PROJECT_ID") || "",
  google_private_key_id: System.get_env("GOOGLE_STORAGE_PRIVATE_KEY_ID") || "",
  google_private_key: System.get_env("GOOGLE_STORAGE_PRIVATE_KEY") || "",
  google_client_email: System.get_env("GOOGLE_STORAGE_CLIENT_EMAIL") || "",
  google_client_id: System.get_env("GOOGLE_STORAGE_CLIENT_ID") || "",
  google_auth_uri: "https://accounts.google.com/o/oauth2/auth",
  google_token_uri: "https://oauth2.googleapis.com/token",
  google_auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
  google_client_x509_cert_url: System.get_env("GOOGLE_STORAGE_CLIENT_CERT_URL") || "",
  google_scope_default: "https://www.googleapis.com/auth/cloud-platform",
  google_base_bucket: System.get_env("GOOGLE_STORAGE_BASE_BUCKET") || ""

config :goth,
  config_module: CloudStorage.Google,
  disabled: false
