require 'and_feathers'
require 'and_feathers/gzipped_tarball'
require 'support/in_memory_gzipped_tarball'

describe AndFeathers do

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
        './redis',
        './redis/cookbooks',
        './redis/cookbooks/redis',
        './redis/cookbooks/redis/README',
        './redis/cookbooks/redis/CHANGELOG',
        './redis/cookbooks/redis/metadata.rb',
        './redis/cookbooks/redis/recipes',
        './redis/cookbooks/redis/recipes/default.rb',
        './redis/cookbooks/redis/templates',
        './redis/cookbooks/redis/templates/default'
      ]
    end

    it 'iterates through each directory breadth-first' do
      expect(archive.to_a.map(&:path)).to eql(tree)
    end

    it 'can build an in-memory tarred/gzipped IO stream' do
      tarball = archive.to_io(AndFeathers::GzippedTarball)
      reader = InMemoryGzippedTarball.new(tarball)

      expect(reader.to_a.map(&:first)).to eql(tree)
      expect(reader.to_a.map(&:last).reject(&:empty?)).to eq([
        'README contents',
        'CHANGELOG contents',
        'metadata.rb contents',
        'default.rb contents'
      ])
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
        './cookbooks',
        './cookbooks/redis',
        './cookbooks/redis/README',
        './cookbooks/redis/CHANGELOG',
        './cookbooks/redis/metadata.rb',
        './cookbooks/redis/recipes',
        './cookbooks/redis/recipes/default.rb',
        './cookbooks/redis/templates',
        './cookbooks/redis/templates/default'
      ]
    end

    it 'iterates through each directory breadth-first' do
      expect(archive.to_a.map(&:path)).to eql(tree)
    end

    it 'can build an in-memory tarred/gzipped IO stream' do
      tarball = archive.to_io(AndFeathers::GzippedTarball)
      reader = InMemoryGzippedTarball.new(tarball)

      expect(reader.to_a.map(&:first)).to eql(tree)
      expect(reader.to_a.map(&:last).reject(&:empty?)).to eq([
        'README contents',
        'CHANGELOG contents',
        'metadata.rb contents',
        'default.rb contents'
      ])
    end
  end
end
