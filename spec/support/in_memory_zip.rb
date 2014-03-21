require 'zip'

class InMemoryZip
  include Enumerable

  NotUnzipped = Object.new

  def initialize(io)
    @io = io
    @unzipped = NotUnzipped
    @entries = []
  end

  def each
    if NotUnzipped == @unzipped
      ::Zip::InputStream.open(@io) do |zip|
        while entry = zip.get_next_entry
          @entries.push([entry, zip.read])
        end
      end

      @unzipped = true
    end

    @entries.each do |entry, content|
      yield entry.name, content
    end
  end
end
