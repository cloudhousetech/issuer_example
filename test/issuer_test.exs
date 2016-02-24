defmodule IssuerTest do
  use ExUnit.Case
  alias OldIssuer, as: Issuer

  test "Couples request and response" do
    {:ok, issuer} = Issuer.start_link request_sender, response_sender
    Issuer.add_request issuer, "Request"
    assert_receive {:request, "Request"}
    Issuer.add_response issuer, "Response"
    assert_receive {:response, {"Request", "Response"}}
  end

  test "Requests are queued" do
    {:ok, issuer} = Issuer.start_link request_sender, response_sender
    Issuer.add_request issuer, "Request1"
    assert_receive {:request, "Request1"}
    Issuer.add_request issuer, "Request2"
    refute_receive _
    Issuer.add_request issuer, "Request3"
    refute_receive _
    Issuer.add_response issuer, "Response1"
    assert_receive {:response, {"Request1", "Response1"}}
    assert_receive {:request, "Request2"}
    refute_receive _
    Issuer.add_response issuer, "Response2"
    assert_receive {:response, {"Request2", "Response2"}}
    assert_receive {:request, "Request3"}
    refute_receive _
    Issuer.add_response issuer, "Response3"
    assert_receive {:response, {"Request3", "Response3"}}
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


