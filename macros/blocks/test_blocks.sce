
Files=glob("*/*.sci");
exclude =["scicos_blk_draw_axes";
	  "pde_set";
	  "bplatform2";
	  "m_sin"  ;
	  "anim_pen"];

bugs=m2s([]);

for i=1:size(Files,"*")
  fname =Files(i);
  block =file("tail",file("root",fname));
  if part(block,1)== "_" then continue;end
  if or(block==exclude)  then continue;end
  xpause(1000,%t);
  printf("blk=%s(""define"");\n",block);
  ok=execstr("o="+block+"(""define"");",errcatch=%t);
  if ~ok then
    bugs.concatd[sprintf("blk=%s(""define"")",block)];
    lasterror();
    continue;
  end
  [blk,ok]=do_silent_eval_block(o);
  if ~ok then
    bugs.concatd[sprintf("blk=%s(""define"");blk=%s(""set"",blk);",block,block)];
  end
end

// second pass with bugs 
printf("we have encountered %d pbs (See bugs variable)\n",size(bugs,"*"));
