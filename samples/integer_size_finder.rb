require 'syntax_finder'

class IntegerSizeFinder < SyntaxFinder
  def look node
    if node.type == :call_node && node.name == :'size' && 
       node.receiver&.type == :integer_node
      pp [nloc(node), nlines(node).lines.first.chomp]
    end
  end
end
