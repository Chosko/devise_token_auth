require 'test_helper'

#  was the web request successful?
#  was the user redirected to the right page?
#  was the user successfully authenticated?
#  was the correct object stored in the response?
#  was the appropriate message delivered in the json payload?

class DeviseTokenAuth::TokenValidationsControllerTest < ActionDispatch::IntegrationTest
  describe DeviseTokenAuth::TokenValidationsController do
    before do
      @resource = users(:confirmed_email_user)
      @resource.skip_confirmation!
      @resource.save!

      @auth_headers = @resource.create_new_auth_token

      @token     = @auth_headers['access-token']
      @client_id = @auth_headers['client']
      @expiry    = @auth_headers['expiry']

      # ensure that request is not treated as batch request
      age_token(@resource, @client_id)

    end

    describe 'vanilla user' do
      before do
        get '/auth/validate_token', {}, @auth_headers
        @resp = JSON.parse(response.body)
      end

      test "token valid" do
        assert_equal 200, response.status
      end
    end

    describe 'using namespaces' do
      before do
        get '/api/v1/auth/validate_token', {}, @auth_headers
        @resp = JSON.parse(response.body)
      end

      test "token valid" do
        assert_equal 200, response.status
      end
    end

    describe 'failure' do
      before do
        get '/api/v1/auth/validate_token', {}, @auth_headers.merge({"access-token" => "12345"})
        @resp = JSON.parse(response.body)
      end

      test "request should fail" do
        assert_equal 401, response.status
      end

      test "response should contain errors" do
        assert @resp['errors']
        assert_equal @resp['errors'], [I18n.t("devise_token_auth.token_validations.invalid")]
      end
    end

  end
end
