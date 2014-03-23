require 'and_feathers'
require 'and_feathers/zip'
require 'support/in_memory_zip'

describe AndFeathers::Zip do
  describe 'an archive with a base directory' do
    let(:archive) do
      AndFeathers.build('redis') do |redis|
        redis.dir('cookbooks') do |cookbooks|
          cookbooks.dir('redis') do |redis|
            redis.file('README') { 'README contents' }
            redis.file('CHANGELOG') { 'CHANGELOG contents' }
            redis.file('metadata.rb') { 'metadata.rb contents' }
            redis.dir('recipes') do |recipes|
              recipes.file('default.rb') { 'default.rb contents' }
            end
            redis.dir('templates') do |templates|
              templates.dir('default')
            end
          end
        end
      end
    end

    let(:tree) do
      [
        './redis/',
        './redis/cookbooks/',
        './redis/cookbooks/redis/',
        './redis/cookbooks/redis/README',
        './redis/cookbooks/redis/CHANGELOG',
        './redis/cookbooks/redis/metadata.rb',
        './redis/cookbooks/redis/recipes/',
        './redis/cookbooks/redis/recipes/default.rb',
        './redis/cookbooks/redis/templates/',
        './redis/cookbooks/redis/templates/default/'
      ]
    end

    it 'can build an in-memory zip IO stream' do
      zip = archive.to_io(AndFeathers::Zip)
      reader = InMemoryZip.new(zip)

      expect(reader.to_a.map(&:first)).to eql(tree)
    end

    it 'produces an in-memory IO stream that can be saved to disk' do
      file = ::File.join("spec", "tmp", "#{Time.now.to_f}.zip")
      zip = archive.to_io(AndFeathers::Zip)

      ::File.open(file, 'w+') { |f| f << zip.read }

      zipped_files = []

      ::Zip::File.open(file) do |files|
        files.each do |file|
          zipped_files << file.name
        end
      end

      expect(zipped_files).to eql(tree)
    end
  end

  describe 'an archive without a base directory' do
    let(:archive) do
      AndFeathers.build do |redis|
        redis.dir('cookbooks') do |cookbooks|
          cookbooks.dir('redis') do |redis|
            redis.file('README') { 'README contents' }
            redis.file('CHANGELOG') { 'CHANGELOG contents' }
            redis.file('metadata.rb') { 'metadata.rb contents' }
            redis.dir('recipes') do |recipes|
              recipes.file('default.rb') { 'default.rb contents' }
            end
            redis.dir('templates') do |templates|
              templates.dir('default')
            end
          end
        end
      end
    end

    let(:tree) do
      [
        './',
        './cookbooks/',
        './cookbooks/redis/',
        './cookbooks/redis/README',
        './cookbooks/redis/CHANGELOG',
        './cookbooks/redis/metadata.rb',
        './cookbooks/redis/recipes/',
        './cookbooks/redis/recipes/default.rb',
        './cookbooks/redis/templates/',
        './cookbooks/redis/templates/default/'
      ]
    end

    it 'can build an in-memory zip IO stream' do
      zip = archive.to_io(AndFeathers::Zip)
      reader = InMemoryZip.new(zip)

      expect(reader.to_a.map(&:first)).to eql(tree)
      expect(reader.to_a.map(&:last).reject(&:empty?)).to eq([
        'README contents',
        'CHANGELOG contents',
        'metadata.rb contents',
        'default.rb contents'
      ])
    end

    it 'produces an in-memory IO stream that can be saved to disk' do
      file = ::File.join("spec", "tmp", "#{Time.now.to_f}.zip")
      zip = archive.to_io(AndFeathers::Zip)

      ::File.open(file, 'w+') { |f| f << zip.read }

      zipped_files = []

      ::Zip::File.open(file) do |files|
        files.each do |file|
          zipped_files << file.name
        end
      end

      expect(zipped_files).to eql(tree)
    end
  end
end
