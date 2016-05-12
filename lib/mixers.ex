defmodule Merkle.Mixers do
  @moduledoc """
  Different crypto Mixers for binary Merkle Trees.
  """

  @doc """
  Good old SHA-2 with 256 bits output size.
  """
  def sha256(a, b) do
    :crypto.hash(:sha256, a <> b)
  end

  @doc """
  Commutable version of SHA-2 with 256 bits output size.
  """
  def commutable_sha256(a, b) do
    {a, b} = {a, b} |> commute
    sha256(a, b)
  end

  @doc """
  SHA-3 (Keccak)
  """
  def sha3(a, b, size \\ 256) do
    :sha3.hexhash(size, a <> b)
  end

  @doc """
  SHA-3 (Keccak) with 512 bits output size.
  """
  def sha3_512(a, b) do
    sha3(a, b, 512)
  end

  @doc """
  Commutable version of SHA3 (Keccak) with 256 bits output size.
  """
  def commutable_sha3_256(a, b) do
    {a, b} = {a, b} |> commute
    sha3(a, b, 256)
  end

  @doc """
  Commutable version of SHA3 (Keccak) with 512 bits output size.
  """
  def commutable_sha3_512(a, b) do
    {a, b} = {a, b} |> commute
    sha3(a, b, 512)
  end

  # This helper commutes two hashes so "a" is the biggest and "b" the smallest
  defp commute({a, b}) do
    if :binary.decode_unsigned(a) > :binary.decode_unsigned(b) do
      {a, b}
    else
      {b, a}
    end
  end

end
