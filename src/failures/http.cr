# An error representing a failed HTTP request.
#
# A request is considered "failed" when it's response does not match the
# configured expectations.
#
# For example, a request can be configured to expect a 404 (Not found) status
# response from the server. In such a case, a request whose status code
# indicates failure would not be considered a failure. Conversely, a request
# which is configured to expect a particular output but has not *would* be
# considered a failure even if its status code was `200 OK`.
class Pingas::Failures::HTTP < Pingas::Failures::Exception
  getter msg : String do
    "request to #{@url} failed: #{@response.status_message}." +
      if b = @response.body?
        "\nreceived response body: BODY\n#{b}\nBODY"
      else
        ""
      end
  end

  property severity : Severity

  def initialize(@url : URI, @response : ::HTTP::Client::Response, @severity)
    super msg
  end
end
