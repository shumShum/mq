defmodule MQ.DispatcherTest do
  use ExUnit.Case
  alias MQ.{Dispatcher, WorkerSup}

  test "queue works" do
    Dispatcher.add("1")
    WorkerSup.start_worker()

    assert ["1"] == Dispatcher.handled()

    Dispatcher.add("2")
    Dispatcher.add("3")
    WorkerSup.start_worker(0, :error)
    WorkerSup.start_worker(0, :ok)

    assert ["3"] == Dispatcher.handled()
    assert "2" == Dispatcher.get()
  end
end