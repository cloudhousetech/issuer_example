defmodule OldIssuer do
  def start_link(request_sender, response_sender) do 
    Agent.start_link fn ->
      %{
        queue: [],
        active_request: :none,
        request_sender: request_sender,
        response_sender: response_sender
      }
    end
  end

  def add_request(issuer, request) do
    Agent.update issuer, fn state ->
      do_add_request state, request
    end
  end

  def add_response(issuer, response) do
    Agent.update issuer, fn state ->
      state
      |> send_response(response)
      |> send_next_request
    end
  end

  defp do_add_request(state = %{active_request: :none}, request) do
    state.request_sender.(request)
    %{state| active_request: request}
  end

  defp do_add_request(state, request) do
    %{state| queue: state.queue ++ [request]}
  end

  defp send_response(state = %{active_request: request}, response) do
    state.response_sender.({request, response})
    %{state| active_request: :none}
  end

  defp send_next_request(state = %{queue: []}) do
    state
  end

  defp send_next_request(state = %{queue: [request|requests]}) do
    state.request_sender.(request)
    %{state| active_request: request, queue: requests}
  end
end
