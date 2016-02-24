defmodule Issuer do
  def start_link(request_sender, response_sender) do 
    Agent.start_link fn ->
      %{
        queue: RequestQueue.initial_state, 
        request_sender: request_sender,
        response_sender: response_sender
      }
    end
  end

  def add_request(issuer, request) do
    Agent.update issuer, fn state ->
      request
      |> RequestQueue.add_request(state.queue)
      |> execute_actions(state)
    end
  end

  def add_response(issuer, response) do
    Agent.update issuer, fn state ->
      response
      |> RequestQueue.add_response(state.queue)
      |> execute_actions(state)
    end
  end

  def execute_actions({actions, queue}, state) do
    Enum.each(actions, fn action -> execute_action(action, state) end)
    %{state| queue: queue}
  end

  def execute_action({:send_request, request}, %{request_sender: request_sender}) do
    request_sender.(request) 
  end

  def execute_action({:send_response, response}, %{response_sender: response_sender}) do
    response_sender.(response) 
  end
end
