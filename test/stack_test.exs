defmodule MQ.StackTest do
  use ExUnit.Case

  alias MQ.Stack

  test "simple stack functions" do
    stack = Stack.init()

    assert {nil, ^stack} = Stack.pop(stack)
    assert 0 == Stack.size(stack)

    stack =
      stack
      |> Stack.push("1")
      |> Stack.push("2")

    assert 2 == Stack.size(stack)
    assert {"2", stack} = Stack.pop(stack)
    assert 1 == Stack.size(stack)

    stack =
      stack
      |> Stack.push("3")

    assert {"3", stack} = Stack.pop(stack)
    assert {"1", stack} = Stack.pop(stack)
    assert {nil, ^stack} = Stack.pop(stack)
  end

  test "persistant stack functions" do
    stack = Stack.init_stack()

    stack =
      stack
      |> Stack.push("3", 1)
      |> Stack.push("5", 2)

    assert {"5", stack} = Stack.pop(stack, 3)

    stack =
      stack
      |> Stack.push("6", 3)
      |> Stack.push("1", 5)

    assert {"3", stack} = Stack.pop(stack, 4)
    assert {"6", stack} = Stack.pop(stack, 5)

    stack =
      stack
      |> Stack.push("9", 7)

    assert 1 = Stack.size(stack, 9)
  end
end
