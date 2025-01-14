relative 'syntax_finder'

# Cound up all of regexps.

class RegexpFinder < SyntaxFinder
  def look node
    if node.type == :regular_expression_node
      # pp [[nloc(node), nlines(node).lines]] unless @@opt[:quiet]
      inc :regexp
      inc node.unescaped
    end
  end
end
