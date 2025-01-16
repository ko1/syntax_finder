require 'syntax_finder'

# counts empty rescue body

class RescueEmptyBodyFinder < SyntaxFinder
  def look node
    if node.type == :rescue_node
      inc :rescue
      unless node.statements
        if $VERBOSE
          inc [:empty_body, node.exceptions&.map{|n| n.slice}]
        else
          inc :empty_body
        end
      end
    end
  end
end
