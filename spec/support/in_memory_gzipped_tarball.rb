require 'rubygems/package'
require 'zlib'

class InMemoryGzippedTarball
  include Enumerable

  NotUnzipped = Object.new

  def initialize(file)
    @file = file
    @unzipped = NotUnzipped
  end

  def each
    if NotUnzipped == @unzipped
      reader = Zlib::GzipReader.new(@file)
      @unzipped = StringIO.new(reader.read).tap do
        reader.close
      end
    end

    Gem::Package::TarReader.new(@unzipped)do |tar|
      tar.each do |tarfile|
        if tarfile.directory?
          yield tarfile.full_name, ''
        else
          yield tarfile.full_name, tarfile.read
        end
      end
    end
  ensure
    @unzipped.rewind
  end
end

