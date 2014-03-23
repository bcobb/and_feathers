require 'and_feathers/file'
require 'and_feathers/directory'

module AndFeathers
  describe Directory do
    it 'can be unioned with another directory' do
      one = Directory.new
      one.dir('a') do |a|
        a.file('b/c')
        a.dir('c')
      end

      two = Directory.new
      two.file('a/b/d')

      three = one | two

      expect(three.to_a.map(&:path)).
        to eql(['./a', './a/b', './a/b/c', './a/b/d', './a/c'])
    end

    it 'allows for manually nesting directories' do
      directory = Directory.new
      directory.dir('a') do |a|
        a.dir('b') do |b|
          b.dir('c')
        end
      end

      expect(directory.to_a.map(&:path)).to eql(['./a', './a/b', './a/b/c'])
    end

    it 'allows for convenient nesting of directories' do
      directory = Directory.new
      directory.dir('a/b/c')

      expect(directory.to_a.map(&:path)).to eql(['./a', './a/b', './a/b/c'])
    end

    it 'only creates a given path once' do
      directory = Directory.new
      directory.dir('a/b/c')
      directory.dir('a/b/c/d')

      expect(directory.to_a.map(&:path)).
        to eql(['./a', './a/b', './a/b/c', './a/b/c/d'])
    end

    it 'takes the most recent duplicate directory as authoritative' do
      directory = Directory.new
      directory.dir('a/b/c')
      directory.dir('a/b/d')

      expect(directory.to_a.map(&:path)).to eql(['./a', './a/b', './a/b/d'])
    end

    it 'allows for manually nesting files in directories' do
      directory = Directory.new
      directory.dir('a') do |a|
        a.dir('b') do |b|
          b.dir('c') do |c|
            c.file 'README'
          end
        end
      end

      expect(directory.to_a.map(&:path)).
        to eql(['./a', './a/b', './a/b/c', './a/b/c/README'])
    end

    it 'allows for convenient nesting of files in directories' do
      directory = Directory.new
      directory.file('a/b/c/README')

      expect(directory.to_a.map(&:path)).
        to eql(['./a', './a/b', './a/b/c', './a/b/c/README'])
    end

    it 'only creates a given file once' do
      directory = Directory.new
      directory.file('a/README')
      directory.file('a/README')

      expect(directory.to_a.map(&:path)).to eql(['./a', './a/README'])
    end

    it 'takes the most recent file as the authoritative file' do
      directory = Directory.new
      directory.file('a/README') { '1' }
      directory.file('a/README') { '2' }

      readme = directory.to_a.find { |e| e.is_a?(File) }

      expect(readme.read).to eql('2')
    end
  end
end
