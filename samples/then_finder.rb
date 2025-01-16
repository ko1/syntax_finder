require 'syntax_finder'

# Count up all `then` keywords in `if`, `unless`, `when`, `in`

class ThenFinder < SyntaxFinder
  def look node
    case node.type
    when :if_node
      if node.if_keyword_loc
        inc :if_node
        inc [:then, node.type] if node.then_keyword_loc
      else
        inc :':?'
      end
    when :unless_node, :when_node
      inc node.type
      inc [:then, node.type] if node.then_keyword_loc
    when :in_node
      inc node.type
      inc [:then, node.type] if node.then_loc
    when :rescue_node
      # not supported yet
    end
  end
end
