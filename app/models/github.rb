require "net/https"

module Github
  extend self
  def get_oauth_token(authorization_code)
    http = Net::HTTP.new(GITHUB_CONFIG['host'], 443)
    http.use_ssl = true
    path = GITHUB_CONFIG['access_token_path']
    data = "client_id=#{GITHUB_CONFIG['client_id']}&client_secret=#{GITHUB_CONFIG['client_secret']}&code=#{authorization_code}"
    resp, response_body = http.post(path, data)

    result = nil
    if resp.code.to_i == 200
      response_hash = Rack::Utils.parse_query(response_body)
      if response_hash["access_token"]
        result = response_hash["access_token"]
      end
    end
    result
  end

  def get_login(access_token)
    http = Net::HTTP.new(GITHUB_CONFIG['api_endpoint'], 443)
    http.use_ssl = true
    path = GITHUB_CONFIG['user_info_path'] % access_token
    resp, response_body = http.get(path)

    result = nil
    if resp.code.to_i == 200
      result = JSON.parse(response_body)["login"]
    end
    result
  end
end
