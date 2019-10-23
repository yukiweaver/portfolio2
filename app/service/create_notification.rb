class CreateNotification
  include HTTParty

  API_URI = 'https://onesignal.com/api/v1/notifications'.freeze

  def self.call(*args)
    new(*args).call
  end

  def initialize(contents:, type:)
    @contents = contents
    @type     = type
  end

  def call
    HTTParty.post(API_URI, headers: headers, body: body)
  end

  private

  attr_reader :contents, :type

  def headers
    {
      'Authorization' => 'Basic MDYxZGFiZDEtZDUxMi00MGQ5LTljY2MtYzcxY2FhMzgyNzFh', # rest_api_key
      'Content-Type'  => 'application/json'
    }
  end

  def body
    {
      'app_id' => '97cc47fd-6eb0-4d36-ab4e-10948fa02037', # app_id
      # 'url'    => 'https://rails-portfolio2.herokuapp.com',
      'url'    => 'http://localhost:3000',
      'data'   => { 'type': type },
      'included_segments' => ['All'],
      'contents' => contents
    }.to_json
  end
end