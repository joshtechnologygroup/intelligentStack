class StackApi
  def self.get_unanswered_post
    url = 'https://api.stackexchange.com/2.2/questions/unanswered?order=desc&sort=activity&site=stackoverflow&key=BipPk3LoVirifKeqxobNlw(('
    # Typhoeus::Request.get(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res = http.get(uri.request_uri)
    JSON.parse(res.body)['items'].first
  end
end
