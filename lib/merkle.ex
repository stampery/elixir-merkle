defmodule Merkle do

  defmacro __using__(mixer, item_length \\ 32) do
    quote do
      require Integer

      def mix(a, b) do
        IO.inspect unquote mixer
        (unquote mixer).(a, b)
      end

      @item_length unquote(item_length)
      @empty {[[]], %{}}
      @empty_data %{}

      def start_link(name) do
        Agent.start_link(fn -> @empty end, name: name)
      end

      def new(value \\ @empty) do
        Agent.start_link(fn -> value end)
      end

      def new!(value \\ @empty) do
        {:ok, pid} = new(value)
        pid
      end

      def get(pid) do
        Agent.get(pid, &(&1))
      end

      def push(pid, item, level \\ 0)

      def push(pid) do
        item = __MODULE__.Helpers.random(@item_length)
        push(pid, item)
      end

      def push(pid, list, level) when is_list list do
        Enum.map list, fn (item) ->
          push(pid, item, level)
        end
      end

      def push(pid, {item, data}, level) do
        Agent.get_and_update(pid, fn {tree, proofs} ->
          do_push({tree, proofs, data}, item, level)
        end)
      end

      def push(pid, item, level) do
        Agent.get_and_update(pid, fn {tree, proofs} ->
          do_push({tree, proofs, @empty_data}, item, level)
        end)
      end

      def close(pid) do
        Agent.get_and_update(pid, fn {tree, proofs} ->
          do_close({tree, proofs})
        end)
      end

      def flush(pid) do
        Agent.update(pid, fn _tree -> @empty end)
      end

      def prove(hash, siblings, root) do
        if siblings |> Enum.count > 0 do
          [head | tail] = siblings
          hash = mix(hash, head)
          prove(hash, tail, root)
        else
          hash == root && :ok || :error
        end
      end

      defp do_push({tree, proofs, data}, item, level \\ 0) do
        # If hash is already in tree, reject it
        if proofs |> Map.has_key?(item) do
          {{:error, :duplicated}, {tree, proofs}}
        else
          siblings = Rlist.at(tree, level, [])

          # Push item to this level
          siblings = siblings |> Rlist.push(item)
          tree     = tree |> update_tree(siblings, item, level)

          # Calculate new siblings length
          len = siblings |> Rlist.count
          if level < 1 do
            proofs = proofs |> Map.put(item, {[], data})
          end

          if len |> Integer.is_even do
            # Get previous sibling
            prev = siblings |> Rlist.at(len - 2)
            # Mix prev and curr
            parent = mix(prev, item)

            proofs = update_proofs({tree, proofs}, data, item, prev, level)
            # Push resulting parent to next level
            {{:ok, {tree, proofs}}, _} =
              do_push({tree, proofs, nil}, parent, level + 1)
          end
          {{:ok, {tree, proofs}}, {tree, proofs}}
        end
      end

      defp do_close(pid) do
        {tree, proofs} = do_unorphan(pid)
        root = tree
          |> Rlist.last
          |> Rlist.last
        {root, {tree, proofs}}
      end

      defp do_unorphan({tree, proofs}, level \\ 0) do
        if level + 1 < Rlist.count(tree) do
          # Intermediate floors, if orphan, push to upper
          floor = Rlist.at(tree, level)
          len = Rlist.count(floor)
          # If floor length is odd, adds a "phantom sibling"
          if Integer.is_odd(len) do
            r = __MODULE__.Helpers.random(@item_length)
            {{:ok, {tree, proofs}}, _} = do_push({tree, proofs, nil}, r, level)
          end
          do_unorphan {tree, proofs}, level + 1
        else
          # Last floor, return merkle
          {tree, proofs}
        end
      end

      defp update_tree(tree, siblings, item, level) do
        # If existing level, replace it
        # Else, if new level, push it!
        if Rlist.count(tree) > level do
          tree |> Rlist.replace_at(level, siblings)
        else
          tree |> Rlist.push(siblings)
        end
      end

      defp update_proofs({tree, proofs}, data, item, prev, level \\ 0) do
        ff  = tree |> Rlist.first
        cf  = tree |> Rlist.at(level)
        ffl = ff |> Rlist.count
        cfl = cf |> Rlist.count

        # Tree height
        h  = tree |> Rlist.count
        # Range length
        rl = 2 |> :math.pow(level + 1) |> round
        # Range start
        rs = -rl + cfl * (2 |> :math.pow(level)) |> round
        # Range end
        re = (rs + rl |> min(ffl)) - 1
        # Half range
        hr = rl |> div(2)
        range = rs..re

        affected = Rlist.slice(ff, range)
        {_tree, proofs} = affected |>
          List.foldr({0, proofs}, fn (key, {acc, proofs}) ->
            {:ok, proofs} = proofs
              |> Map.get_and_update(key, fn {proof, data} ->
                item = if acc < hr, do: item, else: prev
                proof = proof |> Rlist.push(item)
                {:ok, {proof, data}}
              end)
            {acc + 1, proofs}
          end)
        proofs
      end

      defmodule Helpers do
        def random(len) do
          len
            |> :crypto.strong_rand_bytes
            |> Base.encode16
        end
      end

    end
  end

end
