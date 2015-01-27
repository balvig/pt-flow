class TaskRow < PT::DataRow
  def method_missing(method)
    str = super
    return unless str.size > 0
    case @record.story_type
    when 'feature' then str.cyan.bold
    when 'chore' then str
    when 'bug' then str.red
    when 'release' then "< #{str} >".white_on_blue
    else str
    end
  end
end
