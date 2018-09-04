defmodule MQ.Dispatcher do
  use GenServer
  require Logger

  alias MQ.Queue

  def init(_), do: {:ok, %{handled: [], queue: Queue.init()}}

  def handle_call(:handled, _, state),
    do: {:reply, state.handled, state}

  def handle_call(:get, _, state) do
    {value, queue} = Queue.pop(state.queue)
    {:reply, value, %{state | queue: queue}}
  end

  def handle_cast({:add, value}, state),
    do: {:noreply, %{state | queue: Queue.push(state.queue, value)}}

  def handle_cast({:ack, value}, state) do
    Logger.info("Acknowledged msg: #{inspect(value)}")
    {:noreply, %{state | handled: [value | state.handled]}}
  end

  def handle_cast({:reject, value}, state) do
    Logger.error("Rejected msg: #{inspect(value)}")
    {:noreply, %{state | queue: Queue.push(state.queue, value)}}
  end

  def start_link(), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def get(), do: GenServer.call(__MODULE__, :get)
  def add(msg), do: GenServer.cast(__MODULE__, {:add, msg})
  def ack(msg), do: GenServer.cast(__MODULE__, {:ack, msg})
  def reject(msg), do: GenServer.cast(__MODULE__, {:reject, msg})

  def handled(), do: GenServer.call(__MODULE__, :handled)
end
