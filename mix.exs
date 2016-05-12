defmodule Merkle.Mixfile do
  use Mix.Project

  def project do
    [app: :merkle,
     version: "0.0.2",
     elixir: "~> 1.2",
     description: description,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: package]
  end

  defp description do
    """
    Implementation of binary Merkle Tree in Elixir.
    """
  end

  def application do
    [applications: [:crypto, :sha3]]
  end

  defp package do
    [maintainers: ["Adán Sánchez de Pedro Crespo"],
     licenses: ["AGPL"],
     links: %{"GitHub" => "https://github.com/stampery/elixir-merkle"}]
  end

  defp deps do
    [{:rlist, "~> 0.0.1"},
     {:sha3, "~> 1.0.0"}]
  end
end
