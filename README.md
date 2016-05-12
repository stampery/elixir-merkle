# Merkle [![hex.pm version](https://img.shields.io/hexpm/v/plug.svg?style=flat)](https://hex.pm/packages/merkle)

Implementation of binary [Merkle Tree](https://en.wikipedia.org/wiki/Merkle_tree) in Elixir.

## Installation

  1. Add merkle to your list of dependencies in `mix.exs`:

        def deps do
          [{:merkle, "~> 0.0.1"}]
        end

## Usage

### Choosing the mixing function
The mixing function is the one that gets two hashes from one floor, joins them and output the result for pushing it to the next level in the tree.

```elixir
defmodule Tree do
  # "Merkle.Mixers.sha256" simply takes two hashes, concatenates them and calculates the SHA256 hash.
  use Merkle, &Merkle.Mixers.sha256/2
end
```

All available mixers are:
* `Merkle.Mixers.sha256`
* `Merkle.Mixers.commutable_sha256`
* `Merkle.Mixers.sha3_256`
* `Merkle.Mixers.sha3_512`
* `Merkle.Mixers.commutable_sha3_256`
* `Merkle.Mixers.commutable_sha3_512`

If you use a 512 bits mixer, you will need to call `use`like this:
```elixir
  # 64 stands for the number of bytes in every hash
  use Merkle, [&Merkle.Mixers.sha3_512/2, 64]
```

Commutable mixers output the same result even if you reverse the order of the pair of hashes:
```elixir
# Result is true
Merkle.Mixers.commutable_sha256("AA", "BB") == Merkle.Mixers.commutable_sha256("BB", "AA")
```

You can also use your own mixers:
```elixir
  use Merkle, [fn (a, b) ->
    :crypto.hash(:md5, a <> b) |> Base.encode16
  end, 16]
```

### Creating a new tree
```elixir
{:ok, pid} = Tree.new
```
Or:
```elixir
pid = Tree.new!
```

### Pushing elements to a tree
```elixir
pid |> Tree.push "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"
pid |> Tree.push "38B060A751AC96384CD9327EB1B1E36A21FDB71114BE07434C0CC7BF63F6E1DA"
```
`Tree.push/1` returns `:ok` upon success or `{:error, error_name}` if something goes wrong.

Optionally, you can attach a metadata Map to hashes and retrieve it later when you get the Merkle Proof:
```elixir
pid |> Tree.push({"E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855", %{foo: "bar"}})
```

### Getting current state of a tree
```elixir
{merkle_tree, merkle_proofs} = pid |> Tree.get
```

### Closing a tree
Closing a tree ensures the existence of a single Merkle Root and returns it.
```elixir
merkle_root = pid |> Tree.close
```

### Flushing a tree
```elixir
pid |> Tree.flush
```

### Getting the Merkle Proof for a hash
Once you have finished adding hashes to your Merkle Tree and closed it by using `Tree.close/0`, you can get the Merkle Proofs for any hash in the tree like this:
```elixir
hash = "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"
root = pid |> Tree.close

{_merkle_tree, merkle_proofs} = pid |> Tree.get
{proof, _metadata} = merkle_proofs |> Map.get(hash)
```

### Verifying that a Merkle Proof is valid
In order to verify that a Merkle Proof is valid and therefore prove that the hash was in the tree, you just need the hash, the proof itself and the Merkle Root.
```elixir
# Result will be :ok or :error
result = hash |> Tree.prove(proof, root)
```
