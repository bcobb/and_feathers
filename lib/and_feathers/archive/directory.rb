require 'and_feathers/archive/fake_filesystem_sugar'

module AndFeathers
  class Archive
    #
    # Represents a Directory inside the archive
    #
    class Directory
      include Archive::FakeFileSystemSugar
      include Enumerable

      attr_reader :name, :mode

      #
      # @!attribute [r] name
      #   @return [String] the directory name
      #
      # @!attribute [r] mode
      #   @return [Fixnum] the directory mode
      #

      #
      # Creates a new +Directory+
      #
      # @param name [String] the directory name
      # @param mode [Fixnum] the directory mode
      # @param parent [Directory, Archive] the parent entity of this directory
      #
      def initialize(name, mode, parent)
        @name = name
        @mode = mode
        @parent = parent
        @children = {}
      end

      #
      # This +Directory+'s path
      #
      # @return [String]
      #
      def path
        ::File.join(@parent.path, name)
      end

      def path_from(relative_path)
        path.sub(/^#{Regexp.escape(relative_path)}\/?/, '')
      end

      #
      # Iterates through this +Directory+'s children down to each leaf child.
      #
      # @yieldparam child [File, Directory]
      #
      def each(&block)
        files, subdirectories = @children.partition do |_, child|
          child.is_a?(File)
        end

        files.map(&:last).each(&block)

        subdirectories.map(&:last).each do |subdirectory|
          block.call(subdirectory)

          subdirectory.each(&block)
        end
      end
    end
  end
end
