module Tenant::AssignmentsHelper
  def event_color(assignment)
    case assignment.status.capitalize
      when 'Done'
        '#9e9e9e'
      when 'Open'
        '#009659'
      when 'In Progress'
        '#5765b0'
      else
        '#5765b0'#'#000000' #TODO, find cause
    end
  end

  def event_text_color(assignment)
    'white'
  end

  def assignment_recurrence(assignment)
    ret = (assignment && assignment.recurrence.present?) ? "<i class='fa fa-repeat'></i>" : ''
    case assignment.try(:recurrence)
      when 'd'
        ret << ' 1 d'
      when 'w'
        ret << ' 1 wk'
      when '2w'
        ret << ' 2 wk'
      when 'm'
        ret << ' 1 mn'
      when 'y'
        ret << ' 1 yr'
    end
    ret.html_safe
  end
end