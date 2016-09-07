defmodule LoggerErrorCounterBackend do
  @moduledoc """
  A `Logger` backend that publishes the number of error messages and the last error message

  In your config, simply do something like this:

  ```elixir
    config :logger_error_counter_backend, path: [:log, :errors]
  ```

  LoggerErrorCounterBackend is configured when specified, and supports the following options:

  `:point` - the `Nerves.Hub` point to publish the error count. Defaults to: []

  `:format` - the format message used to print logs. Defaults to: "$time $metadata[$level] $levelpad$message\n"

  `:metadata` - the metadata to be printed by $metadata. Defaults to an empty list (no metadata)

  `:count` - set/reset the count. Defaults to: 0

  Configuration may also be conducted using `Logger.configure_backends/2`
  """

  use GenEvent
  require Logger

  @point Application.get_env(:logger_error_counter_backend, :point, [])
  @metadata Application.get_env(:logger_error_counter_backend, :metadata, [])
  @default_format "$time $metadata[$level] $message\n"
  @level :error

  @defaults %{point: @point, format: @default_format, metadata: @metadata, count: 0}

  @doc false
  def init({__MODULE__, opts}) do
    config = configure(opts, @defaults)
    Logger.debug "#{__MODULE__} Starting at: #{inspect config.point}"
    {:ok, config}
  end

  def init(__MODULE__), do: init({__MODULE__, []})

  def handle_call({:configure, options}, state) do
    {:ok, :ok, configure(options, state)}
  end

  @doc false
  def handle_event({level, _gl, {Logger, message, timestamp, metadata}}, %{point: point, count: count} = state) do
    state = if (Logger.compare_levels(level, @level) != :lt and point) do
      entry = format_event(level, message, timestamp, metadata, state)
      publish(point, count + 1, entry)
      %{state | count: count + 1}
    else
      state
    end
    {:ok, state}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  defp configure(opts, defaults) do
    point = Dict.get(opts, :point, defaults.point)
    format = case Dict.get(opts, :format, defaults.format) do
      f when is_list(f) -> f
      f -> Logger.Formatter.compile f
    end
    metadata = Dict.get(opts, :metadata, defaults.metadata)
    count = Dict.get(opts, :count, defaults.count)
    %{point: point, format: format, metadata: metadata, count: count}
  end

  defp format_event(level, msg, ts, md, %{format: format, metadata: metadata} = _state) do
    Logger.Formatter.format(format, level, msg, ts, take_metadata(md, metadata))
    |> IO.chardata_to_string
  end

  defp take_metadata(metadata, keys) do
    metadatas = Enum.reduce(keys, [], fn key, acc ->
      case Keyword.fetch(metadata, key) do
        {:ok, val} -> [{key, val} | acc]
        :error     -> acc
      end
    end)

    Enum.reverse(metadatas)
  end

  defp publish(point, count, entry) do
    Nerves.Hub.put point, count: count, last_message: entry
  end
end
