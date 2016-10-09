defmodule Mensendi.Mixfile do
  use Mix.Project

  def project do
    [app: :mensendi,
     version: "0.0.1",
     name: "Mensendi",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/jgsmith/mensendi",
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :timex]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:dogma, "~> 0.1", only: :dev},
      {:earmark, "~> 1.0", override: true, only: :dev},
      {:ex_doc, "~>0.12", only: :dev},
      {:timex, "~> 3.0"}
    ]
  end
end
