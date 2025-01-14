require 'syntax_finder'

class IntegerRangeFinder < SYntaxFinder
  def look node
    if node.type == :range_node
       left = node.left 
       right = node.right

       if((left.nil? || left.type == :integer_node) &&
          (right.nil? || right.type == :integer_node))

        inc :integer_range
        # pp [[nloc(node), nlines(node).lines]] unless @@opt[:quiet]
        inc [left&.value, right&.value].inspect
       end
    end
  end
end
