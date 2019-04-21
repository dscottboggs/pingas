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
