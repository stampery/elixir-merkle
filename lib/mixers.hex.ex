defmodule Merkle.Mixers.Hex do
  @moduledoc """
  Different crypto Mixers for hexadecimal mode Merkle Trees.

  Mixers in hexadecimal mode process hashes as Base16 strings (`"FABADA"`).
  """

  @doc """
  Good old SHA-2 with 256 bits output size.
  """
  @spec sha256(Merkle.digest, Merkle.digest) :: Merkle.digest
  def sha256(a, b) do
    :crypto.hash(:sha256, a <> b) |> Base.encode16
  end

  @doc """
  Commutable version of SHA-2 with 256 bits output size.
  """
  @spec commutable_sha256(Merkle.digest, Merkle.digest) :: Merkle.digest
  def commutable_sha256(a, b) do
    {a, b} = {a, b} |> commute
    sha256(a, b)
  end

  @doc """
  SHA-3 (FIPS-202)
  """
  @spec sha3(Merkle.digest, Merkle.digest, Integer.t) :: Merkle.digest
  def sha3(a, b, size \\ 256) do
    :sha3.hexhash(size, a <> b)
  end

  @doc """
  SHA-3 (FIPS-202) with 512 bits output size.
  """
  @spec sha3_512(Merkle.digest, Merkle.digest) :: Merkle.digest
  def sha3_512(a, b) do
    sha3(a, b, 512)
  end

  @doc """
  Commutable version of SHA3 (FIPS-202) with 256 bits output size.
  """
  @spec commutable_sha3_256(Merkle.digest, Merkle.digest) :: Merkle.digest
  def commutable_sha3_256(a, b) do
    {a, b} = {a, b} |> commute
    sha3(a, b, 256)
  end

  @doc """
  Commutable version of SHA3 (FIPS-202) with 512 bits output size.
  """
  @spec commutable_sha3_512(Merkle.digest, Merkle.digest) :: Merkle.digest
  def commutable_sha3_512(a, b) do
    {a, b} = {a, b} |> commute
    sha3(a, b, 512)
  end

  # This helper commutes two hashes so "a" is the biggest and "b" the smallest
  defp commute({a, b}) do
    if a > b do
      {a, b}
    else
      {b, a}
    end
  end

end
