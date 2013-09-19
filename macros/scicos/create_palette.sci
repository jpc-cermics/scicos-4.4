function routines=create_palette(bidon)
// This function is used in 
// macros/blocks/palettes 
// to build the set of predefined palettes 
// 
  if nargin < 1 then bidon='all';end
  scicos_ver=get_scicos_version();
  lisf=glob('*.sci');
  if nargin == 0 then
    // create a palette whose name will be the 
    // name of the current directory
    // search the current directory for all the *.sci 
    // and load the blocks functions 
    Path=getcwd();
    to_del=[]
    for i=1:size(lisf,'*')
      fil=lisf(i)
      // we just check here if execution is ok 
      // the fact that this file is a block definition 
      // will be check latter in build_palette.
      eok=exec(fil,errcatch=%t);
      if ~eok then
	to_del=[to_del i];
	lasterror();
      end
    end
    lisf(to_del)=[];
    routines=build_palette(lisf,Path, file('tail',Path)+'.cos');
  else
    // use predefined names 
    savepwd=getcwd()
    Path=file('join',[get_scicospath();'macros';'blocks';'palettes']);
    chdir(Path)
    path=file('join',[get_scicospath();'macros';'blocks']);
    if bidon=='all' then
      bidon=scicos_get_palette_content('all');
    else
      bidon=bidon(:)'
    end
    routines=[];
    for i=1:size(bidon,'*') 
      txt = bidon(i);
      printf('Constructing %s\n',txt)
      lisf=scicos_get_palette_content(txt);
      if isempty(lisf) then 
	printf('Palette '+txt+' does not exists\n')
      else 
	// here we could decide to create a .cos or a .cosf 
	routines=[routines;build_palette(lisf,path,txt+'.cos')];
      end
    end
    chdir(savepwd)
  end
  routines=unique(routines);
endfunction

function [routines]=build_palette(lisf,path,fname)
  scs_m=get_new_scs_m()
  X=0
  Y=0
  yy=0
  sep=30
  routines=m2s([]);
  for k=1:size(lisf,'*')
    fil = lisf(k);
    // check if fil contains a block definition
    blk=[];
    cmd=sprintf("blk=%s(''define'');",file('root',fil));
    if ~exists('needcompile') then needcompile=0;end
    eok=execstr(cmd,errcatch=%t);
    if ~eok then
      //message(['Error: define failed';catenate(lasterror())]);
      to_del=[to_del i];
      lasterror();
      continue
    end
    if type(blk,'short')<>'h' then 
      to_del=[to_del i];
      lasterror();
      continue
    end
    routines=[routines;blk.model.sim(1)]
    blk.graphics.sz=20*blk.graphics.sz;
    blk.graphics.orig=[X Y]
    X=X+blk.graphics.sz(1)+sep
    yy=max(yy,blk.graphics.sz(2))
    if X>400 then X=0,Y=Y+yy+sep,yy=0,end
    scs_m.objs($+1)=blk;
  end
  // save in file 
  [ok,scs_m]=scicos_save_in_file(fname,scs_m,list(),scicos_ver);
endfunction

function lisf=scicos_get_palette_content(txt)
// return the objet present in palette named txt 
// or the palettes names if txt == 'all' 
  if txt=='all' then
    // return the palette names 
    lisf= ['Sources'; 'Sinks' ;  'Branching'; 'Non_linear';  'Lookup_Tables'; 
	   'Events' ;  'Threshold';  'Others'; 'Linear'; 'OldBlocks' ; 'DemoBlocks' ;
	   'Modelica' ;  'Modelica Electrical';   'Modelica Hydraulics' ;  'Modelica Linear';
	   'Matrix' ; 'Integer';  'Iterators' ];
  else
    H=scicos_default_palettes();
    if H.contents.iskey[txt] then 
      lisf = H.contents(txt);
    else
      lisf = m2s([]);
    end
  end
endfunction
