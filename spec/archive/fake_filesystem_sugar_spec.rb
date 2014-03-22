require 'and_feathers'

module AndFeathers
  class Archive
    describe FakeFileSystemSugar do
      it 'allows for manually nesting directories' do
        archive = Archive.new
        archive.dir('a') do |a|
          a.dir('b') do |b|
            b.dir('c')
          end
        end

        expect(archive.to_a.map(&:path)).to eql(['./a', './a/b', './a/b/c'])
      end

      it 'allows for convenient nesting of directories' do
        archive = Archive.new
        archive.dir('a/b/c')

        expect(archive.to_a.map(&:path)).to eql(['./a', './a/b', './a/b/c'])
      end

      it 'only creates a given path once' do
        archive = Archive.new
        archive.dir('a/b/c')
        archive.dir('a/b/c/d')

        expect(archive.to_a.map(&:path)).
          to eql(['./a', './a/b', './a/b/c', './a/b/c/d'])
      end

      it 'takes the most recent duplicate directory as authoritative' do
        archive = Archive.new
        archive.dir('a/b/c')
        archive.dir('a/b/d')

        expect(archive.to_a.map(&:path)).to eql(['./a', './a/b', './a/b/d'])
      end

      it 'allows for manually nesting files in directories' do
        archive = Archive.new
        archive.dir('a') do |a|
          a.dir('b') do |b|
            b.dir('c') do |c|
              c.file 'README'
            end
          end
        end

        expect(archive.to_a.map(&:path)).
          to eql(['./a', './a/b', './a/b/c', './a/b/c/README'])
      end

      it 'allows for convenient nesting of files in directories' do
        archive = Archive.new
        archive.file('a/b/c/README')

        expect(archive.to_a.map(&:path)).
          to eql(['./a', './a/b', './a/b/c', './a/b/c/README'])
      end

      it 'only creates a given file once' do
        archive = Archive.new
        archive.file('a/README')
        archive.file('a/README')

        expect(archive.to_a.map(&:path)).to eql(['./a', './a/README'])
      end

      it 'takes the most recent file as the authoritative file' do
        archive = Archive.new
        archive.file('a/README') { '1' }
        archive.file('a/README') { '2' }

        readme = archive.to_a.find { |e| e.is_a?(File) }

        expect(readme.read).to eql('2')
      end
    end
  end
end
