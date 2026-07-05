require "test_helper"

class BookClassifierTest < ActiveSupport::TestCase
  setup do
    @book = books(:one)
    @classifier = BookClassifier.new(book: @book)
  end

  test "classify updates the book from the api response and returns true" do
    response = http_response("200", {
      content: [{ type: "text", text: { classification: "fiction", genres: ["Science Fiction", "Fantasy"] }.to_json }]
    }.to_json)

    result = @classifier.stub(:post_request, response) do
      @classifier.classify
    end

    assert result
    @book.reload

    assert_equal "fiction", @book.classification
    assert_equal "Science Fiction,Fantasy", @book.genres
  end

  test "classify returns false on an unsuccessful response" do
    response = http_response("429", { error: { type: "rate_limit_error" } }.to_json, Net::HTTPTooManyRequests)

    result = @classifier.stub(:post_request, response) do
      @classifier.classify
    end

    assert_not result
    assert_nil @book.reload.classification
  end

  test "classify returns false when the response is not parseable" do
    response = http_response("200", "not json")

    result = @classifier.stub(:post_request, response) do
      @classifier.classify
    end

    assert_not result
    assert_nil @book.reload.classification
  end

  test "classify does not persist a classification outside the vocabulary" do
    response = http_response("200", {
      content: [{ type: "text", text: { classification: "cookbook", genres: ["Cooking"] }.to_json }]
    }.to_json)

    result = @classifier.stub(:post_request, response) do
      @classifier.classify
    end

    assert_not result
    assert_nil @book.reload.classification
  end

  private

  def http_response(code, body, klass = Net::HTTPOK)
    response = klass.new("1.1", code, nil)
    response.define_singleton_method(:body) { body }
    response
  end
end
