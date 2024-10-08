require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

module Cpiconfiles
  class GoogleDrive
    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
    APPLICATION_NAME = 'Google Drive API Ruby Quickstart'.freeze
    CREDENTIALS_PATH = ENV.fetch('JSON_GCPX', '').freeze # 'path/to/credentials.json'.freeze
    # The file token.yaml stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    TOKEN_PATH = 'token.yaml'.freeze
    SCOPE = Google::Apis::DriveV3::AUTH_DRIVE

    def self.get_credentials
      CREDENTIALS_PATH
    end

    def initialize
      ##
      # Ensure valid credentials, either by restoring from the saved credentials
      # files or initiating an OAuth2 authorization. If authorization is required,
      # the user's default browser will be launched to approve the request.
      #
      # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials

      # Initialize the API
      @service = Google::Apis::DriveV3::DriveService.new
      @service.client_options.application_name = APPLICATION_NAME
      @service.authorization = authorize
    end

    def authorize
      client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
      authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
      user_id = 'default'
      credentials = authorizer.get_credentials(user_id)
      if credentials.nil?
        url = authorizer.get_authorization_url(base_url: OOB_URI)
        code = gets
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id:, code:, base_url: OOB_URI
        )
      end
      credentials
    end

    def upload(file_path)
      # Upload a file
      metadata = Google::Apis::DriveV3::File.new(name: 'My Report',
                                                 mime_type: 'application/vnd.google-apps.spreadsheet')
      # file_path = 'path/to/file/report.csv'

      # Upload the file
      result = service.create_file(metadata, upload_source: file_path, content_type: 'text/csv')
    end
  end
end
