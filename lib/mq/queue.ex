defmodule MQ.Queue do
  @moduledoc """
    Based on https://goo.gl/3ci77e
  """

  defstruct l_stack: [],
            l2_stack: [],
            r_stack: [],
            rc_stack: [],
            rc2_stack: [],
            s_stack: [],
            recopy: false,
            to_copy: 0,
            copied: false

  @type t :: %__MODULE__{
          l_stack: list,
          l2_stack: list,
          r_stack: list,
          rc_stack: list,
          rc2_stack: list,
          s_stack: list,
          recopy: atom,
          to_copy: integer,
          copied: atom
        }

  alias MQ.Stack

  def init() do
    %__MODULE__{
      l_stack: Stack.init(),
      l2_stack: Stack.init(),
      r_stack: Stack.init(),
      rc_stack: Stack.init(),
      rc2_stack: Stack.init(),
      s_stack: Stack.init(),
      recopy: false,
      to_copy: 0,
      copied: false
    }
  end

  def empty(state), do: !state.recopy && Stack.size(state.r_stack) == 0

  def push(%{recopy: true} = state, value) do
    %{state | l2_stack: Stack.push(state.l2_stack, value)}
    |> check_normal()
  end

  def push(%{recopy: false} = state, value) do
    {_, rc2_stack} = Stack.pop(state.rc2_stack)

    %{state | l_stack: Stack.push(state.l_stack, value), rc2_stack: rc2_stack}
    |> check_recopy()
  end

  def pop(%{recopy: true} = state) do
    {value, rc_stack} = Stack.pop(state.rc_stack)

    if state.to_copy > 0 do
      %{state | rc_stack: rc_stack, to_copy: state.to_copy - 1}
    else
      {_, r_stack} = Stack.pop(state.r_stack)
      {_, rc2_stack} = Stack.pop(state.rc2_stack)

      %{state | rc_stack: rc_stack, r_stack: r_stack, rc2_stack: rc2_stack}
    end
    |> check_normal()
    |> (fn state -> {value, state} end).()
  end

  def pop(%{recopy: false} = state) do
    {value, r_stack} = Stack.pop(state.r_stack)
    {_, rc_stack} = Stack.pop(state.rc_stack)
    {_, rc2_stack} = Stack.pop(state.rc2_stack)

    %{state | r_stack: r_stack, rc_stack: rc_stack, rc2_stack: rc2_stack}
    |> check_recopy()
    |> (fn state -> {value, state} end).()
  end

  defp check_recopy(state) do
    recopy = Stack.size(state.l_stack) > Stack.size(state.r_stack)

    if recopy do
      %{
        state
        | recopy: recopy,
          to_copy: Stack.size(state.r_stack),
          copied: false
      }
      |> check_normal()
    else
      %{state | recopy: recopy}
    end
  end

  defp check_normal(state) do
    with todo <- 3,
         {state, todo} <- copy_r_to_s(state, todo),
         {state, todo} <- copy_l_to_r_and_rc2(state, todo),
         {state, _} <- copy_s_to_r_and_rc2(state, todo) do
      if Stack.size(state.s_stack) == 0 do
        %{
          state
          | l_stack: state.l2_stack,
            l2_stack: state.l_stack,
            rc_stack: state.rc2_stack,
            rc2_stack: state.rc_stack,
            recopy: false
        }
      else
        %{state | recopy: true}
      end
    end
  end

  defp copy_r_to_s(%{copied: true} = state, todo), do: {state, todo}
  defp copy_r_to_s(state, 0), do: {state, 0}

  defp copy_r_to_s(state, todo) do
    case Stack.pop(state.r_stack) do
      {nil, _} ->
        {state, todo}

      {value, r_stack} ->
        %{state | s_stack: Stack.push(state.s_stack, value), r_stack: r_stack}
        |> copy_r_to_s(todo - 1)
    end
  end

  defp copy_l_to_r_and_rc2(state, 0), do: {state, 0}

  defp copy_l_to_r_and_rc2(state, todo) do
    case Stack.pop(state.l_stack) do
      {nil, _} ->
        {state, todo}

      {value, l_stack} ->
        %{
          state
          | copied: true,
            r_stack: Stack.push(state.r_stack, value),
            rc2_stack: Stack.push(state.rc2_stack, value),
            l_stack: l_stack
        }
        |> copy_l_to_r_and_rc2(todo - 1)
    end
  end

  defp copy_s_to_r_and_rc2(state, 0), do: {state, 0}

  defp copy_s_to_r_and_rc2(state, todo) do
    case Stack.pop(state.s_stack) do
      {nil, _} ->
        {state, todo}

      {value, s_stack} ->
        if state.to_copy > 0 do
          %{
            state
            | r_stack: Stack.push(state.r_stack, value),
              rc2_stack: Stack.push(state.rc2_stack, value),
              s_stack: s_stack,
              to_copy: state.to_copy - 1
          }
        else
          %{state | s_stack: s_stack}
        end
        |> copy_s_to_r_and_rc2(todo - 1)
    end
  end
end
