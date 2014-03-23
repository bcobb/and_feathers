RSpec.configure do |config|
  config.after(:suite) do
    Dir['spec/tmp/*.{zip,tgz}'].each do |archive|
      File.unlink(archive)
    end
  end
end
