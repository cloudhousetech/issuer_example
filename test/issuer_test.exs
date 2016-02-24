defmodule IssuerTest do
  use ExUnit.Case

  test "Couples request and response" do
    {:ok, issuer} = Issuer.start_link request_sender, response_sender
    Issuer.add_request issuer, "Q"
    assert_receive {:request, "Q"}
    Issuer.add_response issuer, "A"
    assert_receive {:response, {"Q", "A"}}
    refute_receive _
  end

  test "Requests are queued" do
    {:ok, issuer} = Issuer.start_link request_sender, response_sender
    Issuer.add_request issuer, "Q1"
    assert_receive {:request, "Q1"}
    Issuer.add_request issuer, "Q2"
    refute_receive _
    Issuer.add_request issuer, "Q3"
    refute_receive _
    Issuer.add_response issuer, "A1"
    assert_receive {:response, {"Q1", "A1"}}
    assert_receive {:request, "Q2"}
    refute_receive _
    Issuer.add_response issuer, "A2"
    assert_receive {:response, {"Q2", "A2"}}
    assert_receive {:request, "Q3"}
    refute_receive _
    Issuer.add_response issuer, "A3"
    assert_receive {:response, {"Q3", "A3"}}
    refute_receive _
  end

  def request_sender do
    me = self
    fn x -> send me, {:request, x} end 
  end

  def response_sender do
    me = self
    fn x -> send me, {:response, x} end 
  end
end


