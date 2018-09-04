defmodule MQ.Worker do
  use GenServer
  require Logger

  def start_link(delay, result),
    do: GenServer.start_link(__MODULE__, [delay, result])

  def init([delay, result]) do
    GenServer.cast(self(), :go)
    {:ok, %{delay: delay, result: result, message: MQ.Dispatcher.get()}}
  end

  def handle_cast(:go, state) do
    :timer.sleep(state.delay)

    cond do
      is_nil(state.message) -> Logger.info("No messages")
      state.result == :ok -> MQ.Dispatcher.ack(state.message)
      true -> MQ.Dispatcher.reject(state.message)
    end

    {:stop, :normal, state}
  end
end