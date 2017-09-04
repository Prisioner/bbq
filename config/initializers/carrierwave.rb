if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_provider = 'fog/aws'                        # required
    config.fog_credentials = {
        provider:                         'AWS',
        google_storage_access_key_id:     ENV['S3_ACCESS_KEY'],
        google_storage_secret_access_key: ENV['S3_SECRET_KEY']
    }
    config.fog_directory = ENV['S3_BUCKET_NAME']
  end
end
