require 'rubygems/package'
require 'zlib'

module AndFeathers
  #
  # Conforms to the interface expected by +Archive#to_io+ in the service of
  # turning +Archive+s into gzipped tarballs
  #
  class GzippedTarball
    #
    # Yields a +GzippedTarball+ ready for adding files and directories.
    #
    # @yieldparam package [GzippedTarball]
    #
    # @return [StringIO]
    #
    def self.open(&block)
      tarball_io = StringIO.new("")

      Gem::Package::TarWriter.new(tarball_io) do |tar|
        yield new(tar)
      end

      gzip_io = StringIO.new("")

      Zlib::GzipWriter.new(gzip_io).tap do |writer|
        writer.write(tarball_io.tap(&:rewind).string)
        writer.close
      end

      StringIO.new(gzip_io.string)
    end

    #
    # Creates a new +GzippedTarball+. Provides the interface required by
    # +AndFeathers::Directory#to_io+
    #
    # @param tarball [Gem::Package::TarWriter]
    #
    def initialize(tarball)
      @tarball = tarball
    end

    #
    # Adds the given file to the tarball
    #
    # @param file [AndFeathers::File]
    #
    def add_file(file)
      @tarball.add_file(file.path, file.mode) do |tarred_file|
        tarred_file.write file.read
      end
    end

    #
    # Adds the given directory to the tarball
    #
    # @param directory [AndFeathers::Directory]
    #
    def add_directory(directory)
      @tarball.mkdir(directory.path, directory.mode)
    end
  end
end
