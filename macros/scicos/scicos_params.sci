function params=scicos_params(wpar=[600,450,0,0,600,450],title= 'Untitled',...
			      tf=100000,tol=[1.d-4,1.d-6,1.d-10,tf+1,0,0],context='',...
			      void1=[],options=default_options(), void2=[], void3=[],doc=list())
  //   params=tlist(['params','wpar','title','tol','tf','context',
  // 		'void1','options','void2','void3','doc'],
  // 	       wpar,title,tol,tf,context,void1,options,void2,
  // 	       void3,doc)
  params=hash_create(params=%t,wpar=wpar,title=title,tol=tol,tf=tf,context=context,void1=void1,options=options,void2=void2,void3=void3,doc=doc);
endfunction
