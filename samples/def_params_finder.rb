require 'syntax_finder'

# Check def with paren or no paren

class DefParamsFinder < SyntaxFinder
  def look node
    if node.type == :def_node
      inc :def
      if node.parameters
        params = {
          required: node.parameters.requireds.size,
          optional: node.parameters.optionals.size,
          rest: !node.parameters.rest.nil?,
          posts: node.parameters.posts.size,
          keywords: node.parameters.keywords.size,
          keyword_rest: !node.parameters.keyword_rest.nil?
        }.reject { |_, v| v == 0 || v == false }
      else
        params = {required: 0}
      end

      unless inc params
        note params, nloc(node)
      end
    end
  end
end
