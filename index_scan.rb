require 'byebug'

class IndexScan
  END_OF_FILE = :EOF

  def initialize(current_node, target, condition)
    @current_node = current_node
    @target = target
    @condition = condition
  end

  def next
    result = @current_node.tuple_and_node_for_target(@target, @condition)

    if result.nil?
      END_OF_FILE
    else
      @current_node = result.next_leaf_node
      result.tuple
    end
  end
end
