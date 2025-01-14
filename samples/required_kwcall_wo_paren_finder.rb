require 'syntax_finder'

class ReqKWwoParenFinder < SyntaxFinder
  def look node
    if node.type == :call_node &&
       node.opening_loc.nil? &&
       node.arguments &&
       node.arguments.arguments.any?{|n| n.type == :keyword_hash_node && n.elements.any?{|e|
         e.type == :assoc_node &&
         e.operator_loc.nil? &&
         e.key.location.start_line != e.value.location.start_line}}

      inc :found
      puts "# #{nloc(node)}"
      puts '> ' + nlines(node).lines.join('> ')
    end
  end
end
