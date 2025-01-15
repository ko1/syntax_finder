require 'syntax_finder'

# Check def with paren or no paren

class DefParenFinder < SyntaxFinder
  def look node
    if node.type == :def_node
      has_params = !node.parameters.nil?
      has_paren = !node.lparen_loc.nil?
      inc paren: has_paren, params: has_params
    end
  end
end
