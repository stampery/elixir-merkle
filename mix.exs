defmodule Merkle.Mixfile do
  use Mix.Project

  def project do
    [app: :merkle,
     version: "0.1.0",
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
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/stampery/elixir-merkle"}]
  end

  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev},
     {:rlist, "~> 0.0.2"},
     {:sha3, "~> 2.0.0"}]
  end
end
