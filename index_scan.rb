require_relative './index_loader'

class IndexScan
  END_OF_FILE = :EOF

  def initialize(file_path, target, condition)
    @file_path = file_path
    @target = target
    @condition = condition
    @current_node = nil
  end

  def next
    result = if @current_node.nil?
      IndexLoader.tuple_and_node_for_target(
        @file_path,
        @target,
        @condition,
      )
    else
      @current_node.tuple_and_node_for_target(
        @target,
        @condition,
      )
    end

    if result.nil?
      END_OF_FILE
    else
      @current_node = result.fetch(:node)
      result.fetch(:tuple)
    end
  end
end
