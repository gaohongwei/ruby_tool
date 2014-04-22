s="link_to 'New Part', new_part_path"
s.sub(/link_to (.*),(.*)/,'\1\2')
s.sub(/link_to (.*),(.*)/,'t(\1),\2')
s.sub(/link_to (.*),(.*)/,'link_to t(\1),\2')

ps={pold:"link_to (.*),(.*)",pnew:"link_to t(\\1),\\2"}
s.sub(/#{ps[:pold]}/, "#{ps[:pnew]}")
var='abc'
if s =~/^#{var}/ 
  
end

###  .*,  Agressive
###  .*?, Non-Agressive

#######################################
## Add id according to class name
#file_names = ['foo.txt', 'bar.txt']
file_names=Dir.glob("template/*.html")
file_names.each do |file_name|
  text = File.read(file_name)
  #puts text.gsub(/search_regexp/, "replace string")
  #<div class="xtab scan_tab tab_btn" onclick="doAction('scan', null);">
  t=text.gsub(/<div class=\"xtab (.*?) (.*?)\"/,'<div id="\1" class="xtab \1 \2"')
  #puts "id=" + $1 unless $1.nil?
  puts t
  if text != t 
    puts file_name
  File.open(file_name, "w") {|file| file.puts t}
  end
end
##################
