defmodule MQ.Stack do
  @moduledoc """
    Based on https://goo.gl/chGEVM
  """

  @init_stack [%{prev: nil, size: 0, value: nil}]

  def init(), do: @init_stack

  def push(stack, %{value: _, prev: _, size: _} = item), do: [item | stack]

  def push(stack, value), do: push(stack, value, length(stack))

  def push(stack, value, i) do
    case Enum.at(stack, length(stack) - i) do
      %{size: size} -> push(stack, %{value: value, prev: i, size: size + 1})
      _ -> {:error, stack}
    end
  end

  def pop(stack), do: pop(stack, length(stack))

  def pop(stack, i) do
    case Enum.at(stack, length(stack) - i) do
      nil ->
        {nil, stack}

      %{prev: nil} ->
        {nil, stack}

      res ->
        prev = Enum.at(stack, length(stack) - res.prev)
        poped_stack = push(stack, prev)
        {res.value, poped_stack}
    end
  end

  def size(stack), do: size(stack, length(stack))

  def size(stack, i) do
    case Enum.at(stack, length(stack) - i) do
      %{size: size} -> size
      _ -> :error
    end
  end
end
