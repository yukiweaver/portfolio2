class CreateNotification
  # include HTTParty

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
      'Authorization' => 'NmY0NzNmZmMtMWVmZS00NjdmLTlhMzEtYmEwNjg2OWQ4MzE2', # rest_api_key
      'Content-Type'  => 'application/json'
    }
  end

  def body
    {
      'app_id' => 'a1b14bdf-ad97-4398-a3af-7afdc22b2760', # app_id
      'url'    => 'https://rails-portfolio2.herokuapp.com',
      'data'   => { 'type': type },
      'included_segments' => ['All'],
      'contents' => contents
    }.to_json
  end
end