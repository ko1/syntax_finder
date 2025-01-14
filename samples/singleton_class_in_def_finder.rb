require 'syntax_finder'

class SingletonClassInDefFinder < SyntaxFinder
  # use traverse instead of look
  def traverse node, in_def = nil, in_sclass = nil
    if node.type == :class_node && in_sclass && node.constant_path.type != :constant_read_node
      pp [nloc(node), nlines(node).lines.first.chomp]
    end

    if node.type == :def_node
      in_def = true; in_sclass = false
    elsif node.type == :singleton_class_node && in_def
      in_sclass = true
    end

    node.child_nodes.compact.each{|n| traverse n, in_def, in_sclass}
  end
end
