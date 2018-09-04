defmodule MQ do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(MQ.Dispatcher, []),
      supervisor(MQ.WorkerSup, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: MQ.Supervisor)
  end
end