require 'google/apis/drive_v3'
require 'google/apis/sheets_v4'
require 'googleauth'
require 'csv'

module Cpiconfiles
  class GDrive
    # Google APIの設定
    SCOPE = [
      Google::Apis::DriveV3::AUTH_DRIVE,
      Google::Apis::SheetsV4::AUTH_SPREADSHEETS
    ]

    def initialize
      # 認証
	  json_path = ENV['GCP_JSON_PATH'] 
      # authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(json_path),
        scope: SCOPE
      )
      authorizer.fetch_access_token!

      # Drive APIとSheets APIのサービスを作成
      # @drive_service = Google::Apis::DriveV3::DriveService.new
      # @drive_service.authorization = authorizer

      @sheets_service = Google::Apis::SheetsV4::SheetsService.new
      @sheets_service.authorization = authorizer

      # @service = Google::Apis::DriveV3::DriveService.new
      # @service.client_options.application_name = 'cpiconfiles'
    end

    def upload(file_path, file_name)
      # 新しいスプレッドシートをGoogle Driveに作成
      spreadsheet = @sheets_service.create_spreadsheet(
        Google::Apis::SheetsV4::Spreadsheet.new(properties: { title: file_name })
      )
      spreadsheet_id = spreadsheet.spreadsheet_id
      puts "Spreadsheet created with ID: #{spreadsheet_id}"

      # CSVファイルを読み込み、Google Sheetsにアップロード
      values = CSV.read(file_path)

      # データをシートに書き込むリクエスト
      value_range = Google::Apis::SheetsV4::ValueRange.new(values: values)
      @sheets_service.update_spreadsheet_value(
        spreadsheet_id,
        'Sheet1!A1', # シートの開始位置
        value_range,
        value_input_option: 'RAW'
      )

      puts "CSV data has been uploaded to Google Spreadsheet successfully."

    end
  end
end
