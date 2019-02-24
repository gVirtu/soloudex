defmodule SoLoudEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :soloudex,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      compilers: [:elixir_make | Mix.compilers],
      make_env: fn ->
        %{"MAX_WAVSTREAMS" => "#{Application.get_env(:soloudex, :max_wavstreams, 256)}"}
      end,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SoLoudEx.Application, []}
    ]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.5.0"}
    ]
  end
end
