defmodule MQ.WorkerSup do
  use Supervisor

  def start_link(), do: Supervisor.start_link(__MODULE__, [], name: __MODULE__)

  def start_worker(delay \\ 0, result \\ :ok),
    do: Supervisor.start_child(__MODULE__, [delay, result])

  def init(_) do
    Supervisor.init(
      [worker(MQ.Worker, [], restart: :temporary)],
      strategy: :simple_one_for_one,
      max_restarts: 0,
      max_seconds: 1
    )
  end
end