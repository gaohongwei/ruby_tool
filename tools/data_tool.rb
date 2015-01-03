module ApplicationHelper 
  def  get_nested(item,attributes) 
  # t=Task.first
  # get_nested(t,[:name,:id])    
    me={}
    for att in attributes do
      att=att.to_s
      if att.include?('.')
        att_new=att.split('.').join('_')
        me[att_new]=get_attr(item,att)       
      else 
        me[att]=item.send(att)
      end
    end

    if item.children.size > 0
      kids||=[]
      item.children.each do |c|
        kids<<get_nested(c,attributes)
      end
      me[:kids]=kids 
    end

    me
  end
end