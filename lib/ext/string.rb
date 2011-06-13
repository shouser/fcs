#
# Author::      Steve Houser,  steve@tilting.at
# Description:: Add Final Cut Server specific elements to ruby strings.
#

require 'date'

class String
  
  # Converts a string containing several common date time formats to a final cut server style date time or if the contents of the string don't match any known styles return false
  def to_fcs_style_time
    case date = self
    when /^\d{2}\/\d{2}\/\d{4}\s\d{2}:\d{2}:\d{2}$/; return DateTime.strptime(date+DateTime.now.zone, "%m/%d/%Y %H:%M:%S%Z").rfc3339.to_s.gsub(/\+00:00$/, "Z")
    when /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)\s(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s\d{2}\s\d{2}:\d{2}:\d{2}\s[A-Z]{3}\s\d{4}$/; return DateTime.strptime(date, "%a %b %d %H:%M:%S %Z %Y").rfc3339.to_s.gsub(/\+00:00$/, "Z")
    when /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun),\s\d{2}\s(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s\d{4}\s\d{2}:\d{2}:\d{2}\s[A-Z]{3}$/; return DateTime.strptime(date,"%a, %d %b %Y %H:%M:%S %Z").rfc3339.to_s.gsub(/\+00:00$/, "Z")
    when /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/; return DateTime.strptime(date).rfc3339.to_s.gsub(/\+00:00$/, "Z")
      when /^\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\sUTC$/; DateTime.strptime(date, "%Y-%m-%d %H:%M:%S %Z").rfc3339.to_s.gsub(/\+00:00$/, "Z")
    when /^now$/; return "now"
    else; return false
    end
  end
  
  #
  # Interprets the current string as a boolean. It uses a case-insensitive comparison, so
  # the allowed values below can be in any case.
  #
  # ==== Supported values
  # true::      'true', 'yes', 't', 'y'
  # false::     'false', 'no', 'f', 'n'
  #
  def to_bool
    return false if self =~ /(^false$)|(^no$)|(^f$)|(^n$)/i
    return true if self =~ /(^true$)|(^yes$)|(^t$)|(^y$)/i
    return nil
  end
  
end