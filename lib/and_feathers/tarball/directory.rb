require 'and_feathers/tarball/contains_files'
require 'and_feathers/tarball/contains_directories'

module AndFeathers
  class Tarball
    #
    # Represents a Directory inside the tarball
    #
    class Directory
      include Tarball::ContainsFiles
      include Tarball::ContainsDirectories

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
      # @param parent [Directory, Tarball] the parent entity of this directory
      #
      def initialize(name, mode, parent)
        @name = name
        @mode = mode
        @parent = parent
        @children = []
      end

      #
      # This +Directory+'s path
      #
      # @return [String]
      #
      def path
        ::File.join(@parent.path, name)
      end

      #
      # Iterates through this +Directory+'s children down to each leaf child.
      #
      # @yieldparam child [File, Directory]
      #
      def each(&block)
        files, subdirectories = @children.partition do |child|
          child.is_a?(File)
        end

        files.each(&block)

        subdirectories.each do |subdirectory|
          block.call(subdirectory)

          subdirectory.each(&block)
        end
      end
    end
  end
end
