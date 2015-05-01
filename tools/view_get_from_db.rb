module ApplicationHelper
	ACTS=['show','edit','delete','index','new','copy'] 	
	#Use instance variable to avoid repeative database access
  def carry_scope(acts=nil,scope=nil)
    scope||= get_scope
    return if  scope.nil?
    acts.each_with_index do |act,index|
      if act.start_with?('new')
        acts[index]="#{act}?scope=#{scope}"
      end
    end 
  end

	def get_actions(action=nil,controller=nil,id=nil)
    action ||= get_action		
		id ||=get_id()
		acts=get_actions_all(controller)
		acts
	end	
  def exclude_actions(acts,action=nil)
    action ||=get_action  
    if(['index','new'].include?(action))
      acts.delete_if {|w|w.start_with?('show')||
        w.start_with?('edit')||
        w.start_with?('delete')||   
        w.start_with?('copy')}                  
      # delete actions starting with these            
    end  
    # Delete current one with scope
    opt=get_scope()           
    case action
    when 'new'
      acts.delete_if {|w|w.start_with?(action)} 
    when 'show','edit','index'
      if acts.include?(action) && opt.nil?
        acts.delete(action)  
      else
        action="#{action}:#{opt}"  
        acts.delete_if {|w|w.start_with?(action)}         
      end                       
    else
    end               
  end  
  def get_columns_captions(column_string=nil) 
    # "email;vname|wname;groups.first.name|name;active"
    # Each column pair seperated by ;
    # Column and caption seperated by |
    # Column first, caption can be missed
    # Get this string as argument or from db  	
  	if column_string.nil? || column_string.empty?
	    cfg=get_cfg_by_action()
	    if cfg.any?
	      column_name='cols'
	      cfg = cfg[0][column_name]
	      if cfg.nil? || cfg.empty?
	        columns= captions =get_all_cols()
	        return columns,captions
	      else
	      	column_string=cfg
	      	params[:columns]=columns   	      	
	        #columns = cfg.split(/[;,]/) #split(';\s')  
	        #columns = cfg.split(';') #split(';\s') 
	      end 
	    else
	      columns= captions =get_all_cols()

	      return columns,captions       
	    end	    
	  end # column_string.nil?
	  columns =[]
	  captions=[]	  
    eles=column_string.split(';')
    eles.each do |ele|
    	next if ele.nil?||ele.empty?
      parts=ele.split('=')
      columns  << parts[0]
      captions << (parts[1]||parts[0])      
    end 	   
	  return columns,captions       
  end
###################### Tools ######################
	def get_cfg_by_action(controller=nil,action=nil,scope=nil)
    action ||= get_action		
		scope  ||= get_scope	
		action ='edit' if action =='create' || action=='update'
		action_scope=[action,scope].join(':')
		action_scope.chomp!(':')
		if action_scope =='new'
			cfg=get_cfg_by_controller(controller).by_action(action_scope)
			if cfg.nil?||cfg.empty?
				action_scope='edit'
				cfg=get_cfg_by_controller(controller).by_action(action_scope)
			end
		else 
			cfg=get_cfg_by_controller(controller).by_action(action_scope)
			if cfg.nil?||cfg.empty?
				# By action without scope
				cfg=get_cfg_by_controller(controller).by_action(action)
			end			
		end
		#params[action_scope]=cfg
		cfg
	end	
	def get_cfg_by_controller(controller=nil)	
		controller ||= get_controller().singularize			
		@cfg_by_controller=ViewAdm.by_controller(controller)
	end		

	def get_actions_useful(acts=nil,action=nil,controller=nil,id=nil)
		action ||=get_action			
		#if(id.nil?) #index,new	
		if(['index','new'].include?(action))
			acts.delete_if {|w|w=~/^edit/}
			acts.delete_if {|w|w=~/^show/}
			acts.delete_if {|w|w=~/^copy/}
			acts.delete_if {|w|w=~/^delete/}			
			# delete actions starting with these						
		end

		# Skip false action
		#  new:false,edit:false etc
=begin
		skip them in the action_links		
		ACTS.each do |act|		
			if acts.delete("#{act}:false")
				acts.delete(act)
			end	
		end	
=end		
		# Skip current action with scope
		# Delete current one with scope
		opt=get_scope()		
		unless opt.nil?
			action="#{action}:#{opt}"
		end
		# Delete current one with scope
		acts.delete(action)			
		acts
	end	
	def get_actions_all(controller)
		return @actions_all if @actions_all 

		cfg=get_cfg_by_controller(controller)
		if  cfg.nil? || cfg.empty?
			acts = ACTS.dup		
		else		
			#acts =cfg.map{|x|x.action_scope}
			acts=[]
			cfg.each do |row|
				act=[row.action_scope,row.label].join(':')
				act.chomp!(':')
				acts << act
			end
			acts.concat(ACTS)
			acts=acts.uniq				
		end
		#params[:acts_all]=acts.join(';')	
		@actions_all=acts
	end	

	def get_all_cols(controller=nil)
		controller ||=get_controller
		cols=controller.classify.constantize.column_names
		cols.delete("id")
		cols.delete("created_at")
		cols.delete("updated_at")		
		cols
	end		
end