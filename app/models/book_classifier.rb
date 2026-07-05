# Classifies a book as fiction/nonfiction and assigns genres from the
# controlled vocabulary in Book::GENRES, using the Claude API.
#
# Uses Net::HTTP rather than the official anthropic gem because the gem
# requires Ruby >= 3.2 and this app runs 3.1.
class BookClassifier
  MODEL = "claude-haiku-4-5".freeze
  API_URL = "https://api.anthropic.com/v1/messages".freeze

  RESPONSE_SCHEMA = {
    type: "object",
    properties: {
      classification: { type: "string", enum: Book::CLASSIFICATIONS },
      genres: { type: "array", items: { type: "string", enum: Book::GENRES } }
    },
    required: %w[classification genres],
    additionalProperties: false
  }.freeze

  attr_reader :book

  def initialize(book:)
    @book = book
  end

  def classify
    result = request_classification
    return false unless result

    book.update(
      classification: result["classification"],
      genres: Array(result["genres"]).join(",")
    )
  end

  private

  def request_classification
    response = post_request
    return nil unless response.is_a?(Net::HTTPSuccess)

    body = JSON.parse(response.body)
    JSON.parse(body.dig("content", 0, "text"))
  rescue JSON::ParserError, TypeError, SocketError, Timeout::Error, SystemCallError
    nil
  end

  def post_request
    uri = URI(API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 60

    request = Net::HTTP::Post.new(uri, headers)
    request.body = payload.to_json
    http.request(request)
  end

  def headers
    {
      "x-api-key" => ENV.fetch("ANTHROPIC_API_KEY", nil),
      "anthropic-version" => "2023-06-01",
      "content-type" => "application/json"
    }
  end

  def payload
    {
      model: MODEL,
      max_tokens: 256,
      output_config: { format: { type: "json_schema", schema: RESPONSE_SCHEMA } },
      messages: [{ role: "user", content: prompt }]
    }
  end

  def prompt
    <<~PROMPT
      Classify this book as fiction or nonfiction and pick 1-3 genres from the allowed list.

      Title: #{book.title}
      Author: #{book.author}
    PROMPT
  end
end
