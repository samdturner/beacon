# Returns only items which return true
class Selection
end

# Returns only a subset of columns
class Projection

end

# Should read only one page of a file at a time
# Challenging with CSV format
class FileScan
  def initialize(filename)
    @page = File.open(filename)
  end

  def next
    @page.shift
  end
end

class Sort

end

class Distinct
  attr_reader :previous_value

  def initialize
    @previous_value = nil
  end
end


# Stretch Goals
# - Implement out of core sorting
# - Convert CSV to a file format more suitable for reading pages
# - Implement update
# - Implement insert
# - Implement delete