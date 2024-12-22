#!/usr/bin/elixir

defmodule Solution do
  def secret_2000th(secret) do
    Enum.reduce(
      1..2000,
      secret,
      fn _, cur ->
        next_secret(cur)
      end
    )
  end

  def next_secret(secret) do
    secret =
      (secret * 64)
      |> Bitwise.bxor(secret)
      |> rem(16_777_216)

    secret =
      div(secret, 32)
      |> Bitwise.bxor(secret)
      |> rem(16_777_216)

    (secret * 2048)
    |> Bitwise.bxor(secret)
    |> rem(16_777_216)
  end
end

IO.stream()
|> Enum.map(&String.trim/1)
|> Enum.map(&String.to_integer/1)
|> Enum.map(&Solution.secret_2000th/1)
|> Enum.sum()
|> IO.inspect()
