require 'byebug'
require_relative './index_loader'

# Directs traffic when searching for values that meet a particular condition
class TrafficDirectorNode
  attr_reader :director_values, :child_node_paths

  def initialize(director_values, child_node_paths)
    @director_values = director_values
    @child_node_paths = child_node_paths
  end

  def tuple_and_node_for_target(target, condition)
    @director_values.each_with_index do |director_value, director_idx|
      if potential_match_in_subtree?(target, director_value, condition)
        return IndexLoader.tuple_and_node_for_target(
          @child_node_paths[director_idx],
          target,
          condition,
        )
      end
    end

    nil
  end

  def ==(other)
    other.is_a?(TrafficDirectorNode) &&
      @director_values == other.director_values &&
      @child_node_paths == other.child_node_paths
  end

  private

  def potential_match_in_subtree?(target, director_value, condition)
    case condition
    when :EQUAL
      director_value >= target
    when :GREATER
      director_value > target
    when :LESS
      @director_values.first == director_value
    end
  end
end

# Bottom level nodes which contain the actual row data
class LeafNode
  attr_reader :tuples, :next_node_file_path

  def initialize(tuples, next_node_file_path)
    @tuples = tuples
    @next_node_file_path = next_node_file_path
    @tuple_idx = 0
  end

  def tuple_and_node_for_target(target, condition)
    @tuples.drop(@tuple_idx).each_with_index do |tuple, _idx|
      @tuple_idx += 1
      if match?(condition, tuple.split(',')[0].to_i, target)
        return { node: self, tuple: tuple }
      end
    end

    if @next_node_file_path.nil?
      nil
    else
      IndexLoader.tuple_and_node_for_target(
        @next_node_file_path,
        target,
        condition,
      )
    end
  end

  def ==(other)
    other.is_a?(LeafNode) &&
      @tuples == other.tuples &&
      @next_node_file_path == other.next_node_file_path
  end

  private

  def match?(condition, tuple_value, target)
    case condition
    when :EQUAL
      tuple_value == target
    when :GREATER
      tuple_value > target
    when :LESS
      tuple_value < target
    end
  end
end
