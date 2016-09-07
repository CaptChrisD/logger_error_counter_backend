defmodule LoggerErrorCounterBackendTest do
  use ExUnit.Case
  require Logger

  Logger.add_backend LoggerErrorCounterBackend

  #Reset Hub point values, format, count, and metadata
  setup do
    Nerves.Hub.update [], log_info: nil
    Logger.configure_backend LoggerErrorCounterBackend, [format: "$metadata[$level] $message\n", count: 0, metadata: []]
  end

  test "basic error message" do
    Logger.error "Test"
    :timer.sleep 50
    {_, info} = Nerves.Hub.fetch [:log_info]
    assert info[:count] == 1
    assert info[:last_message] == "[error] Test\n"
  end

  test "add metadata" do
    Logger.configure_backend LoggerErrorCounterBackend, [metadata: [:line]]
    Logger.error "Another Test"
    :timer.sleep 50
    {_, info} = Nerves.Hub.fetch [:log_info]
    assert info[:count] == 1
    assert info[:last_message] == "line=23 [error] Another Test\n"
  end

  test "multiple events" do
    Logger.configure_backend LoggerErrorCounterBackend, [metadata: [:line]]
    Logger.error "First Test"
    :timer.sleep 50
    {_, info} = Nerves.Hub.fetch [:log_info]
    assert info[:count] == 1
    assert info[:last_message] == "line=32 [error] First Test\n"
    Logger.error "Second Test"
    :timer.sleep 50
    {_, info} = Nerves.Hub.fetch [:log_info]
    assert info[:count] == 2
    assert info[:last_message] == "line=37 [error] Second Test\n"
  end
end
