# frozen_string_literal: true

require "test_helper"

class PurgeTest < Imgix::Test
  def test_runtime_error_without_api_key
    assert_raises(RuntimeError) do
      mock_client(api_key: nil).purge(mock_image)
    end
  end

  def test_purger_version_warns
    stub_request(:post, endpoint).with(body: body).to_return(status: 200)

    assert_output(nil, deprecation_warning) do
      mock_client(api_key: "10adc394").purge("/images/demo.png")
    end
  end

  def test_successful_purge
    stub_request(:post, endpoint).with(body: body).to_return(status: 200)

    mock_client(api_key: "10adc394").purge("/images/demo.png")

    assert_requested(
      :post,
      endpoint,
      body: "url=https%3A%2F%2Fdemo.imgix.net%2Fimages%2Fdemo.png",
      headers: mock_headers,
      times: 1
    )
  end

  private

  def mock_client(api_key: "")
    Imgix::Client.new(
      domain: "demo.imgix.net",
      api_key: api_key,
      include_library_param: false
    )
  end

  def mock_headers
    {
      "Accept" => "*/*",
      "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "Authorization" => "Basic MTBhZGMzOTQ6",
      "Content-Type" => "application/x-www-form-urlencoded",
      "User-Agent" => "imgix rb-#{Imgix::VERSION}"
    }
  end

  def mock_image
    "https://demo.imgix.net/images/demo.png"
  end

  def endpoint
    "https://api.imgix.com/v2/image/purger"
  end

  def body
    { "url" => mock_image }
  end

  def deprecation_warning
    "Warning: Your `api_key` will no longer work after upgrading to\n" \
    "imgix-rb version >= 4.0.0.\n"
  end
end
