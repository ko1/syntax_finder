require 'syntax_finder'

# cound `assert*(params)` and `assert params` patterns.`

class AssertEqualParenFinder < SyntaxFinder
  def look node
    if node.type == :call_node && 
       /^assert/ =~ node.name && node.arguments
    then
      if node.opening_loc
        inc :paren
      else
        inc :no_paren
      end
    end
  end
end
