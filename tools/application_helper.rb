require 'link_to'
require 'page_tool'
require 'sys_menu_tool'

require 'view_get_from_db'  
=begin
  require 'view_def_hash'
  require 'sys_menu_hash'
  require 'view_get_from_hash'
=end
require 'file_tool'
require 'data_tool'
module ApplicationHelper 
############## Public methods only ############## 
  def zz_tt_obj(obj,attr='title')
    if obj.i18n
      tt(obj.send(attr))
    else
      obj.send(attr)
    end
  end
  def get_body_header()
    var=['header',cookies[:locale]].join(':')
    get_setting(var)||tt('header')
  end
  def get_setting(var_name)
    value=Setting[var_name]
    return YAML.load(value) if value
    return nil
  end
  def show_article(article_id) 
    article = Article.find(article_id)
    article.content.html_safe 
  end
  def slide_article(article_id) 
    article = Article.find(article_id)
    content = article.content 
    #content=content.gsub("\r\n","\n").gsub("br /","\n")  
    content=content.gsub("<br />","`") 
    ar=[]
    bottom_string=article.title

    page = Nokogiri::HTML(content)  
    page.css('p').each do |p|
      #p.css("br").each do |e|
      content=p.content
      #content=content.gsub("<br />","\n") 
      #content=content.gsub("<br />","-")
      content.split('`').each do |e|
        ar<<e
      end     
    end 
    slide_array(ar,bottom_string)
  end

  def slide_array(data,bottom_string) 
    if data.nil? || data.empty?
      display(tt('no_data'))      
    else
      render partial:'shared/slide.array',
      locals:{data:data,bottom_string:bottom_string}
    end
  end      
  def slide_columns(data,columns,bottom_string)  
    if data.nil? || data.empty?
      display(tt('no_data'))      
    else
      render partial:'shared/slide.columns',
      locals:{data:data,columns:columns,bottom_string:bottom_string}
    end
  end 

  def photo_slide(photot_ary,bottom_string)  
     render partial:'shared/slide.photo',
     locals:{data:photot_ary,bottom_string:bottom_string}
  end
  def gallery_photo_slide(gallery_id,bottom_string)  
    if Gallery.where(id:gallery_id).exists?
      gallery=Gallery.find(gallery_id)
      render partial:'shared/slide.photo',
      locals:{data:gallery.media,bottom_string:bottom_string}
    else
      display('No data') 
    end
  end  
  def index_me(objs,sort_column,sort_direction, columns=nil, captions=nil, header=nil)
    myview=get_my_template('selfed')
    params[:myview]=myview     
    unless myview.nil? 
      render :template =>myview
    else                 
      render 'shared/index', :objs=>@objs, 
      :sort_column=>sort_column, :sort_direction=>sort_direction,
      :columns=>@columns, :header=>@header,:captions=>@captions,:actions=>@actions     
    end
  end
  def show_me(obj,columns=nil,captions=nil, header=nil)
    myview=get_my_template('selfed')
    params[:myview]=myview   
    unless myview.nil? 
      render :template =>myview
    else  
      render 'shared/show', :obj=>@obj,:columns=>@columns,
      :captions=>@captions,:header=>@header,:actions=>@actions
    end
  end  
  def form_me(obj,columns=nil,captions=nil, header=nil)   
    myview=get_my_template('selfed')
    params[:myview]=myview   
    unless myview.nil? 
      render :template =>myview
    else              
      render 'shared/form', :obj=>@obj,:columns=>@columns,
      :captions=>@captions,:header=>@header,:actions=>@actions
    end
  end    
  def link2actions(actions=nil,id=nil,controller=nil,data={})
    if user_signed_in?
      actions ||=@actions
      controller ||=get_controller()
      id ||=get_id()   
      render 'shared/actions', :actions=>actions,:id=>id,:controller=>controller,data:data
    end
  end  
  def link2action(act,id=nil,controller=nil,data=nil)
    isbig=true  
    id||=get_id()         
    if act == 'delete'  
      controller ||=get_controller()
      if id 
        return link2delete(controller,id,isbig)
      else 
        return ''
      end
    end  
    #name:'group',action_scope:'index::::admin/users'
    # /groups/1/users
    data||={}
    act,scope,label,carry,nested_res=act.split(':')
=begin      
    unless scope.nil? || scope.empty?
      data.merge!({:scope=>scope})
    end
=end  
    case scope
    when nil,''
    when 'false','FALSE'
    # Skip false action
    #  new:false,edit:false etc      
      return ''
    else
      data.merge!({:scope=>scope})
    end

    if carry && params[:scope]
      data.merge!({:scope=>params[:scope]})
    end

    params["#{act}_data"]=data
    if label.nil?||label.empty?
      label ="#{act}_#{scope}"
      label.chomp!('_') 
    end 
    label = tt(label)     
    begin 
      if nested_res.nil?||nested_res.empty?
        link_to_controller_action(controller,act,label,id,isbig,data)  
      else
        controller||=get_controller_ns()
        id||=get_id()
        url="/#{controller}/#{id}/#{nested_res}"  
        params["#{act}_#{scope}_url"]=url                
        link_to label, url, class:'btn btn-primary'
      end

    rescue StandardError => e
      error=e.message
      error+="</br>controller=#{controller}" 
      error+="</br>act=#{act}" 
      error+="</br>label=#{label}" 
      error+="</br>id=#{id}</br>"                  
      logger.error(error)
      error.html_safe
    end

  end    
  def tt(key,transform=true)
    return ''  if key.nil?
    return key unless key.is_a?(String)
    return key if key =~ /^[0-9.]+$/
    return ''  if key.empty?     
    if transform   
      I18n.t(key, :default => key.sub('_',' ').titleize)
    else
      I18n.t(key, :default => key)      
    end
  end 
  def lstt(key)
    return '' if key.empty?
    kk=key.downcase.singularize
    t(kk, :default => key)
  end   
  def tts(str,keep_split_char=false,split_char=nil)
    if split_char 
      ar=str.split(split_char)
    else
      ar=str.split(/([\s,.;:&'?])/)      
    end
    ar=ar.map{|x|tt(x)}
    if keep_split_char
      return ar.join(split_char)
    else
      return ar.join('')
    end      
  end      
end