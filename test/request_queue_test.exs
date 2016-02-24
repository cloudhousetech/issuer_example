defmodule RequestQueueTest do
  use ExUnit.Case

  test "Add request" do
    assert RequestQueue.add_request("Rq1", %{active: :none,  queue: []}) == 
      {[send_request: "Rq1"],              %{active: "Rq1",  queue: []}}

    assert RequestQueue.add_request("Rq1", %{active: "Rq0",  queue: []}) == 
      {[],                                 %{active: "Rq0",  queue: ["Rq1"]}}
    
    assert RequestQueue.add_request("Rq2", %{active: "Rq0",  queue: ["Rq1"]}) == 
      {[],                                 %{active: "Rq0",  queue: ["Rq1", "Rq2"]}}
    
    assert RequestQueue.add_request("Rq3", %{active: "Rq0",  queue: ["Rq1", "Rq2"]}) == 
      {[],                                 %{active: "Rq0",  queue: ["Rq1", "Rq2", "Rq3"]}}
  end
  
  test "Add response" do
    assert RequestQueue.add_response("Rs1",                  %{active: "Rq1",  queue: []}) == 
      {[send_response: {"Rq1", "Rs1"}],                      %{active: :none,  queue: []}}

    assert RequestQueue.add_response("Rs1",                  %{active: "Rq1",  queue: ["Rq2"]}) == 
      {[send_response: {"Rq1", "Rs1"}, send_request: "Rq2"], %{active: "Rq2",  queue: []}}

    assert RequestQueue.add_response("Rs1",                  %{active: "Rq1",  queue: ["Rq2", "Rq3"]}) == 
      {[send_response: {"Rq1", "Rs1"}, send_request: "Rq2"], %{active: "Rq2",  queue: ["Rq3"]}}
  end
end
