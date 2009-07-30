class File
  def self.lines_for_file(file)
    lines = []
    File.open(file, 'r') do |fh|
      lines = fh.read.split("\n")
    end

    lines
  end
end

