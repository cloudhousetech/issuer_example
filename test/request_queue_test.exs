defmodule RequestQueueTest do
  use ExUnit.Case

  test "Add request" do
    assert RequestQueue.add_request("Q1", %{active: :none, queue: []}) == 
      {[send_request: "Q1"],              %{active: "Q1",  queue: []}}

    assert RequestQueue.add_request("Q1", %{active: "Q0",  queue: []}) == 
      {[],                                %{active: "Q0",  queue: ["Q1"]}}
    
    assert RequestQueue.add_request("Q2", %{active: "Q0",  queue: ["Q1"]}) == 
      {[],                                %{active: "Q0",  queue: ["Q1", "Q2"]}}
    
    assert RequestQueue.add_request("Q3", %{active: "Q0",  queue: ["Q1", "Q2"]}) == 
      {[],                                %{active: "Q0",  queue: ["Q1", "Q2", "Q3"]}}
  end
  
  test "Add response" do
    assert RequestQueue.add_response("A1",                %{active: "Q1",  queue: []}) == 
      {[send_response: {"Q1", "A1"}],                     %{active: :none, queue: []}}

    assert RequestQueue.add_response("A1",                %{active: "Q1",  queue: ["Q2"]}) == 
      {[send_response: {"Q1", "A1"}, send_request: "Q2"], %{active: "Q2",  queue: []}}

    assert RequestQueue.add_response("A1",                %{active: "Q1",  queue: ["Q2", "Q3"]}) == 
      {[send_response: {"Q1", "A1"}, send_request: "Q2"], %{active: "Q2",  queue: ["Q3"]}}
  end
end
