require 'syntax_finder'

# Count up all `if` statements and `then` keywords.

class IfThenFinder < SyntaxFinder
  def look node
    if node.type == :if_node
      inc :if
      inc :then if node.then_keyword_loc
    end
  end
end
