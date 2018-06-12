# frozen_string_literal: true

# Implement a nested loop join
# Implement a hash join
# Implement a sort merge join
# What are the pros and cons of various strategies?
# Query plan should be implemented as a tree

class NestedLoopJoin
  END_OF_FILE = 'EOF'

  def initialize(left_child, right_child, &condition)
    @left_child = left_child
    @right_child = right_child
    @condition = condition
    @current_left_tuple = nil
    @take_new_left_tuple = true
    @take_new_right_tuple = true
    @inner_iteration = 0
    @right_tuples = []
  end

  def next
    loop do
      set_left_tuple
      return END_OF_FILE if @current_left_tuple == END_OF_FILE

      loop do
        right_tuple = next_right_tuple

        if right_tuple == END_OF_FILE
          @take_new_left_tuple = true
          break
        end
        @inner_iteration += 1

        return @current_left_tuple + right_tuple if @condition.call(@current_left_tuple, right_tuple)
      end
      @inner_iteration = 0
      @take_new_right_tuple = false
    end
  end

  private

  def set_left_tuple
    if @take_new_left_tuple
      @take_new_left_tuple = false
      @current_left_tuple = @left_child.next
    end
  end

  def next_right_tuple
    if @take_new_right_tuple
      @right_tuples.push(@right_child.next)
      @right_tuples.last
    else
      @right_tuples[@inner_iteration]
    end
  end
end
