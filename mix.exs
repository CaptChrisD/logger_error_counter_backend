defmodule LoggerErrorCounterBackend.Mixfile do

  @version "0.1.0"

  use Mix.Project

  def project do
    [ app: :logger_error_counter_backend,
      version: @version,
      elixir: "~> 1.0",
      deps: deps(),
      description: "Adds backend to Logger that publishes error count and last message with Nerves.Hub",
      package: package(),
      name: "LoggerErrorCounterBackend",
      docs: [
        source_ref: "v#{@version}", main: "LoggerErrorCounterBackend",
        source_url: "https://github.com/CaptChrisD/logger_error_counter_backend",
#       main: "extra-readme",
        extras: [ "README.md", "CHANGELOG.md"] ]]
  end

  def application do
    [applications: [:nerves_hub]]
  end

  defp deps, do: [
    {:ex_doc, "~> 0.11", only: :dev},
    {:nerves_hub, github: "nerves-project/nerves_hub"}
  ]

  defp package do
    [ maintainers: ["Chris Dutton"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/CaptChrisD/logger_error_counter_backend"},
      files: ~w(lib config) ++ ~w(README.md CHANGELOG.md LICENSE mix.exs) ]
  end

end
