defmodule Merkle.Mixers.Bin do
  @moduledoc """
  Different crypto Mixers for binary mode Merkle Trees.

  Mixers in binary mode process hashes as binary strings (`<<255, 186, 218>>`).
  """

  @doc """
  Good old SHA-2 with 256 bits output size.
  """
  @spec sha256(Merkle.hash, Merkle.hash) :: Merkle.hash
  def sha256(a, b) do
    :crypto.hash(:sha256, a <> b)
  end

  @doc """
  Commutable version of SHA-2 with 256 bits output size.
  """
  @spec commutable_sha256(Merkle.hash, Merkle.hash) :: Merkle.hash
  def commutable_sha256(a, b) do
    {a, b} = {a, b} |> commute
    sha256(a, b)
  end

  @doc """
  SHA-3 (FIPS-202)
  """
  @spec sha3(Merkle.hash, Merkle.hash, Integer.t) :: Merkle.hash
  def sha3(a, b, size \\ 256) do
    {:ok, hash} = :sha3.hash(size, a <> b)
    hash
  end

  @doc """
  SHA-3 (FIPS-202) with 512 bits output size.
  """
  @spec sha3_512(Merkle.hash, Merkle.hash) :: Merkle.hash
  def sha3_512(a, b) do
    sha3(a, b, 512)
  end

  @doc """
  Commutable version of SHA3 (FIPS-202) with 256 bits output size.
  """
  @spec commutable_sha3_256(Merkle.hash, Merkle.hash) :: Merkle.hash
  def commutable_sha3_256(a, b) do
    {a, b} = {a, b} |> commute
    sha3(a, b, 256)
  end

  @doc """
  Commutable version of SHA3 (FIPS-202) with 512 bits output size.
  """
  @spec commutable_sha3_512(Merkle.hash, Merkle.hash) :: Merkle.hash
  def commutable_sha3_512(a, b) do
    {a, b} = {a, b} |> commute
    sha3(a, b, 512)
  end

  # This helper commutes two hashes so "a" is the smallest and "b" the biggest
  defp commute({a, b}) do
    if a > b do
      {a, b}
    else
      {b, a}
    end
  end

end
