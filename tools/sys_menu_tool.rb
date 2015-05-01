module ApplicationHelper 
  LOGINS=[
    #id:'QqConnect',url:'/auth/qq_connect'}
    {id:'QQ',url:'/auth/qq'},       
    {id:'Google',url:'/auth/google'},
    {id:'Linkedin',url:'/auth/linkedin'},
    {id:'Facebook',url:'/auth/facebook'},  
    #{id:'Twitter',url:'/auth/twitter'},           
  ]      
  SHARES_CN=[
    #id:'',label:'QqConnect',url:'/auth/qq_connect'}
    {id:'sweibo',label:'新浪微博',url:'http://service.weibo.com/share/share.php?url=%s&title=%s'},       
    {id:'tweibo',label:'腾讯微博',url:'http://v.t.qq.com/share/share.php?url=%s&title=%s'},  
    {id:'qzone',label:'QQ空间',url:'http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url=%s&title=%s'},      
    {id:'renren',label:'人人网',url:'http://share.renren.com/share/buttonshare?link=%s&title=%s'}, 
    #{id:'penyou',label:'朋友网',url:''}, 
    {id:'douban',label:'豆瓣',url:'http://www.douban.com/recommend/?url=%s&title=%s'},        
    {id:'netease',label:'网易微博',url:'http://t.163.com/article/user/checkLogin.do?link=%s&info=%s'},          
    #{id:'',label:'Twitter',url:'/auth/twitter'},           
  ]
  SHARES_US=[
    {id:'facebook',label:'Facebook',url:'https://www.facebook.com/sharer/sharer.php?u=%s'},       
    {id:'google',label:'Google',url:'https://plus.google.com/share?url=%s'},   
    {id:'linkedin',label:'Linkedin',url:'http://www.linkedin.com/shareArticle?mini=true&url=%s&title=%s&summary=%s'},       
    {id:'twitter',label:'Twitter',url:'http://twitter.com/home?status=%2$s %3$s %1$s'},   
  ]     
  def menu_bar
      render 'shared/menu_db'       
      #render 'shared/menu_hash' 
  end  
  def search_area(caption_columns=nil)
    if user_signed_in? && caption_columns
      render(partial: '/shared/search', 
        locals: {placeholder: tt('placeholder'),
          caption_columns:caption_columns})
    end
  end  
  def submit_button(f,label=tt('submit'))
    render 'common/submit', :f=>f,:label=>label
  end  
  def link_act(label, apath,opt={})
  	ar=apath.split('#')
  	if ar.size >1
  	link_to(label,{controller: ar[0], action: ar[1]},opt)	
  	else
  	link_to(label,apath,opt)	
  	end		
  end
end