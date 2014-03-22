require 'and_feathers'

describe AndFeathers do

  describe 'building an archive with a base directory' do
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

    it 'iterates through each directory depth-first' do
      expect(archive.to_a.map(&:path)).to eql(tree)
    end

    it 'loads file content' do
      files = archive.to_a.select { |e| e.is_a?(AndFeathers::File) }
      expect(files.map(&:read)).to eql(
        [
          'README contents',
          'CHANGELOG contents',
          'metadata.rb contents',
          'default.rb contents'
        ]
      )
    end
  end

  describe 'building an archive without a base directory' do
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

    it 'iterates through each directory depth-first' do
      expect(archive.to_a.map(&:path)).to eql(tree)
    end

    it 'loads file content' do
      files = archive.to_a.select { |e| e.is_a?(AndFeathers::File) }
      expect(files.map(&:read)).to eql(
        [
          'README contents',
          'CHANGELOG contents',
          'metadata.rb contents',
          'default.rb contents'
        ]
      )
    end
  end

  describe 'loading an archive from an existing tree' do
    let(:tree) do
      [
        './archiveme/README.md',
        './archiveme/lib',
        './archiveme/lib/archiveme.rb'
      ]
    end

    it 'iterates through a directory depth-first' do
      archive = AndFeathers.from_path('spec/fixtures/archiveme')

      expect(archive.to_a.map(&:path)).to eql(tree)
    end

    it 'loads file content' do
      archive = AndFeathers.from_path('spec/fixtures/archiveme')

      files = archive.to_a.select { |e| e.is_a?(AndFeathers::File) }

      expect(files.map(&:read)).to eql(
        ["# Hello\n", "class Archiveme\nend\n"]
      )
    end

    it 'iterates through "." in the same way' do
      archive = []

      Dir.chdir('spec/fixtures/archiveme') do
        archive = AndFeathers.from_path('.')
      end

      expect(archive.to_a.map(&:path)).to eql(tree)
    end

    it 'raises when the given path does not exist' do
      expect do
        AndFeathers.from_path('app')
      end.to raise_error(ArgumentError)
    end

    it 'yields the resulting archive for modification', focus: true  do
      archive = AndFeathers.from_path('spec/fixtures/archiveme')
      archive.file('lib/archiveme/version.rb') do
        "class Archiveme\n  VERSION='0.0.1'\nend"
      end
      archive.dir('tmp')

      new_tree = [
        './archiveme/lib/archiveme',
        './archiveme/lib/archiveme/version.rb',
        './archiveme/tmp'
      ]

      expect(archive.to_a.map(&:path)).to eql(tree + new_tree)
    end
  end
end
