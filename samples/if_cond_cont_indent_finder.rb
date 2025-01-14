require 'syntax_finder'

# Check indentation with `if` and `and`/`or`

class IfCondContIndnetFinder < SyntaxFinder
  def look node
    if node.type == :if_node
      inc :if
      inc :then if node.then_keyword_loc
      cond = node.predicate

      case cond.type
      when :and_node, :or_node
        inc op: cond.operator_loc.slice
        d = cond.location.end_line - cond.location.start_line
        if d > 0
          base = node.location.start_column
          rest_lines = nlines(cond).lines[1..]
          inc indent: rest_lines.map{|line|
            /^(\s*)/ =~ line
            $1.size - base
          }.min
          # puts nlines(cond)
        end
      end
    end
  end
end

