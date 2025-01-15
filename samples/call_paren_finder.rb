require 'syntax_finder'

# Check call with paren or no paren

class CallParenFinder < SyntaxFinder
  def look node
    if node.type == :call_node
      has_params = !node.arguments.nil?
      has_paren = !node.opening_loc.nil?
      inc paren: has_paren, params: has_params
    end
  end
end
