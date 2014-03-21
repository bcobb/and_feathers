require 'and_feathers/tarball/contains_files'
require 'and_feathers/tarball/contains_directories'
require 'rubygems/package'
require 'zlib'

module AndFeathers
  #
  # The base tarball representation
  #
  class Tarball
    include ContainsFiles
    include ContainsDirectories
    include Enumerable

    #
    # @!attribute [r] path
    #   @return [String] the base tarball path
    #

    attr_reader :path

    #
    # Creates a new +Tarball+
    #
    # @param path [String] the base tarball path
    #
    def initialize(path = '.')
      @path = path
      @children = []
    end

    #
    # Iterates through each entity in the tarball, depth-first
    #
    # @yieldparam child [File, Directory]
    #
    def each(&block)
      @children.each do |child|
        block.call(child)
        child.each(&block)
      end
    end

    #
    # Returns this +Tarball+ as a GZipped and tarred +StringIO+
    #
    # @return [StringIO]
    #
    def to_io
      tarball_io = StringIO.new("")

      Gem::Package::TarWriter.new(tarball_io) do |tar|
        each do |child|
          case child
          when File
            tar.add_file(child.path, child.mode) do |file|
              file.write child.read
            end
          when Directory
            tar.mkdir(child.path, child.mode)
          end
        end
      end

      gzip_io = StringIO.new("")

      Zlib::GzipWriter.new(gzip_io).tap do |writer|
        writer.write(tarball_io.tap(&:rewind).string)
        writer.close
      end

      StringIO.new(gzip_io.string)
    end
  end
end
