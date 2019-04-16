class Pingas::Failures::HTTP < Exception
  def initialize(url, response)
    body = if b = response.body?
             "\nreceived response body: BODY\n#{b}\nBODY"
           else
             ""
           end
    super "request to #{url} failed: #{response.status_message}." + body
  end
end
