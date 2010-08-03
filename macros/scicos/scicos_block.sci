function blk=scicos_block(graphics=scicos_graphics(),
  model=scicos_model(),
  gui='',doc=list())
  //Block data structure initialization
  blk=tlist(['Block','graphics','model','gui','doc'],graphics,model,gui, doc)
endfunction

