require 'and_feathers/file'
require 'and_feathers/directory'
require 'and_feathers/version'

#
# The entry-point to the builder DSL
#
module AndFeathers
  #
  # Builds a new archive. If +base+ is not given, the archives's contents
  # would be extracted to intermingle with whichever directory contains the
  # archive. If +base+ is given, the archive's contents will live inside a
  # directory with that name.
  #
  # @param base [String] name of the base directory containing the archive's
  #   contents
  # @param base_mode [Fixnum] the mode of the base directory
  #
  # @yieldparam archive [AndFeathers::Directory]
  #
  def self.build(base = nil, base_mode = 16877, &block)
    if base && base_mode
      Directory.new(base, base_mode).tap do |archive|
        block.call(archive)
      end
    else
      Directory.new('.', base_mode).tap do |archive|
        block.call(archive)
      end
    end
  end

  #
  # Builds a new archive from the directory at the given +path+. The
  # innermost directory is taken to be the parent folder of the archive's
  # contents.
  #
  # @param path [String] path to the directory to archive
  #
  # @yieldparam archive [AndFeathers::Directory] the loaded archive
  #
  def self.from_path(path, &block)
    if !::File.exists?(path)
      raise ArgumentError, "#{path} does not exist"
    end

    directories, files = ::Dir[::File.join(path, '**/*')].partition do |path|
      ::File.directory?(path)
    end

    full_path = ::File.expand_path(path)
    root = full_path.split(::File::SEPARATOR).last
    mode = ::File.stat(full_path).mode

    Directory.new(root, mode).tap do |archive|
      directories.map do |directory|
        [
          directory.sub(/^#{Regexp.escape(path)}\/?/, ''),
          ::File.stat(directory).mode
        ]
      end.each do |directory, mode|
        archive.dir(directory, mode)
      end

      files.each do |file|
        mode = ::File.stat(file).mode

        ::File.open(file, 'rb') do |io|
          content = io.read

          archive.file(file.sub(/^#{Regexp.escape(path)}\/?/, ''), mode) do
            content
          end
        end
      end

      block.call(archive) if block
    end
  end
end
