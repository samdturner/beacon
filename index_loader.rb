require 'csv'

# Takes a file from disk and builds the proper in-memory index node class
class IndexLoader
  def initialize(file_path)
    @file_path = file_path
  end

  def self.call(file_path)
    new(file_path).call
  end

  def call
    if file_array_of_arrays[0][0] == 'leaf'
      return LeafNode.new(formatted_leaf_node_values, leaf_node_file_path.first)
    end
    TrafficDirectorNode.new(
      traffic_director_values.map(&:to_i),
      traffic_director_child_node_paths
    )
  end

  private

  def file_array_of_arrays
    @file_array_of_arrays ||= CSV.read(@file_path)
  end

  def formatted_leaf_node_values
    leaf_node_values.map { |value| value.join(',') + ',' }
  end

  def leaf_node_values
    if file_array_of_arrays.length > 2
      file_array_of_arrays[2..-1]
    else
      []
    end
  end

  def leaf_node_file_path
    file_array_of_arrays[1] || []
  end

  def traffic_director_values
    file_array_of_arrays[1] || []
  end

  def traffic_director_child_node_paths
    file_array_of_arrays[2] || []
  end
end
