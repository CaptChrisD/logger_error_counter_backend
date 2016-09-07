# LoggerErrorCounterBackend

Simple module to publish via `Nerves.Hub` the number of `Logger.error` events occured since boot
as well as last error message.

Uses [`Nerves.Hub`](https://github.com/nerves-project/nerves_hub) to store the count of errors

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `logger_error_counter_backend` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:logger_error_counter_backend, "~> 0.1.0"}]
    end
    ```

  2. Add backend to Logger

    ```elixir
      Logger.add_backend LoggerErrorCounterBackend
    ```

## Configuration

  In your config, simply do something like this:

  ```elixir
    config :logger_error_counter_backend, point: [:logger, :error_info]
  ```

  LoggerErrorCounterBackend is configured when specified, and supports the following options:

  `:point` - the `Nerves.Hub` point to publish the error count. Defaults to: []

  `:format` - the format message used to print logs. Defaults to: "$time $metadata[$level] $levelpad$message\n"

  `:metadata` - the metadata to be printed by $metadata, See Logger docs for available list. Defaults to an empty list (no metadata)

  `:count` - set/reset the count. Defaults to: 0

  Configuration may also be conducted using `Logger.configure_backends/2`
