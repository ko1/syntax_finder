require 'syntax_finder'

class ReqKWwoParenFinder < SyntaxFinder
  def look node
    if node.type == :def_node &&
       node.lparen_loc.nil? &&
       node.parameters&.keywords&.last&.type == :required_keyword_parameter_node &&
       node.parameters&.block.nil?

      inc :found
      pp [nloc(node), nlines(node).lines.first.chomp]
    end
  end
end
