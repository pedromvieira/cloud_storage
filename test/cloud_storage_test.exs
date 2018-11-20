defmodule CloudStorageTest do
  use ExUnit.Case
  doctest CloudStorage.Azure
  doctest CloudStorage.Google
  doctest CloudStorage
end
