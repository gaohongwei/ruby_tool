s="link_to 'New Part', new_part_path"
s.sub(/link_to (.*),(.*)/,'\1\2')
s.sub(/link_to (.*),(.*)/,'t(\1),\2')
s.sub(/link_to (.*),(.*)/,'link_to t(\1),\2')

ps={pold:"link_to (.*),(.*)",pnew:"link_to t(\\1),\\2"}
s.sub(/#{ps[:pold]}/, "#{ps[:pnew]}")
var='abc'
if s =~/^#{var}/ 
  
end
