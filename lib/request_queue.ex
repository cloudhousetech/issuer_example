defmodule RequestQueue do
  def initial_state do 
    %{active: :none, queue: []}
  end

  def add_request(request, state = %{active: :none}) do
    {[send_request: request], %{state| active: request}}
  end

  def add_request(request, state) do 
    {[], %{state| queue: state.queue ++ [request]}}
  end

  def add_response(response, %{active: request, queue: []}) do
    {[send_response: {request, response}], %{active: :none, queue: []}}
  end

  def add_response(response, %{active: request, queue: [head|tail]}) do 
    {[send_response: {request, response}, send_request: head], %{active: head, queue: tail}}
  end
end
