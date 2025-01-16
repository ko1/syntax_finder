require 'syntax_finder'

# Count up all `if` statements (if/elsif/?:) and `then` keywords.

class IfThenFinder < SyntaxFinder
  def look node
    if node.type == :if_node
      if node.if_keyword_loc # if or elsif
        inc node.if_keyword_loc.slice
        if node.then_keyword_loc
          inc 'then'
          # inc path: @file
        end
      else
        # a ? b : c
        inc '?:'
      end
    end
  end
end
