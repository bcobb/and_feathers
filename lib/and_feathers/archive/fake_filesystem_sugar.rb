module AndFeathers
  class Archive
    #
    # A module which provides a DSL for modifying an object's +@children+
    # collection
    #
    module FakeFileSystemSugar
      #
      # Add a +Directory+ named +name+ to this entity's list of children. The
      # +name+ may simply be the name of the directory, or may be a path to the
      # directory.
      #
      # In the case of the latter, +dir+ will create the +Directory+ tree
      # specified by the path. The block parameter yielded in this case will be
      # the innermost directory.
      #
      # @example
      #   archive = Archive.new
      #   archive.dir('app') do |app|
      #     app.name == 'app'
      #     app.path == './app'
      #   end
      #
      # @example
      #   archive.dir('app/controllers/concerns') do |concerns|
      #     concerns.name == 'concerns'
      #     concerns.path == './app/controllers/concerns'
      #   end
      #
      # @param name [String] the directory name
      # @param mode [Fixnum] the directory mode
      #
      # @yieldparam directory [Archive::Directory] the newly-created +Directory+
      #
      def dir(name, mode = 16877, &block)
        name_parts = name.split(::File::SEPARATOR)

        innermost_child_name = name_parts.pop

        if name_parts.empty?
          Directory.new(name, mode, self).tap do |directory|
            block.call(directory) if block

            @children[name] = directory
          end
        else
          innermost_parent = name_parts.reduce(self) do |parent, child_name|
            parent.dir(child_name)
          end

          innermost_parent.dir(innermost_child_name, &block)
        end
      end

      #
      # The default file content block, which returns an empty string
      #
      NO_CONTENT = Proc.new { "" }

      #
      # Add a +File+ named +name+ to this entity's list of children. The +name+
      # may simply be the name of the file or may be a path to the file.
      #
      # In the case of the latter, +file+ will create the +Directory+ tree
      # which contains the +File+ specified by the path.
      #
      # Either way, the +File+'s contents will be set to the result of the
      # given block, or to a blank string if no block is given
      #
      # @example
      #   archive = Archive.new
      #   archive.file('README') do
      #     "Cool"
      #   end
      #
      # @example
      #   archive = Archive.new
      #   archive.file('app/models/user.rb') do
      #     "class User < ActiveRecord::Base\nend"
      #   end
      #
      # @param name [String] the file name
      # @param mode [Fixnum] the file mode
      #
      # @yieldreturn [String] the file contents
      #
      def file(name, mode = 33188, &content)
        content ||= NO_CONTENT

        name_parts = name.split(::File::SEPARATOR)

        file_name = name_parts.pop

        if name_parts.empty?
          File.new(name, mode, content, self).tap do |file|
            @children[name] = file
          end
        else
          dir(name_parts.join(::File::SEPARATOR)) do |parent|
            parent.file(file_name, mode, &content)
          end
        end
      end
    end
  end
end
