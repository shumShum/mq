defmodule MQ.StackTest do
  use ExUnit.Case

  alias MQ.Queue

  test "queue functions" do
    queue = Queue.init()

    queue =
      queue
      |> Queue.push("1")
      |> Queue.push("2")

    assert {"1", queue} = Queue.pop(queue)
    refute Queue.empty(queue)

    queue =
      queue
      |> Queue.push("3")

    assert {"2", queue} = Queue.pop(queue)
    assert {"3", queue} = Queue.pop(queue)
    assert Queue.empty(queue)
  end
end
