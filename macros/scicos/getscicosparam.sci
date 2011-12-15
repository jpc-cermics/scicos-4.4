function [dt,data]=getscicosparam(fic)
// getscicosparam : read binary data in rdnom_params.dat
// file generated by Scicos CodeGeneration.
//
// input : fic : path+name of the data file
//
// output : dt : a list that encloses the name and the values
//          of the scicos variables enclosed in the parameters
//          file
//
//          data : a string matrix that gives the name, dimensions
//                 and type of Scicos variables enclosed in the
//                 parameters file.

   data = [];
   dt=[];

   if fileinfo(fic)==[] then
     error('File doesn''t exists.');
   end

   [path,fname,extension]=fileparts(fic)
   fic_xml=path+fname+'.xml';

   if fileinfo(fic_xml)==[] then
     error('Xml file doesn''t exists.');
   end

   txt = mgetl(fic_xml);
   data = [];

   function [data]=start_handl(data,el,attr)
     if el=='ScicosVar' then
       data=[data;
             attr(2) attr(4) attr(6) attr(8)]
     end
   endfunction

   function [data]=end_handl(data,el)

   endfunction

   %ptr=XML_ParserCreate();
   XML_SetUserData(%ptr,'data');
   XML_SetElementHandler(%ptr,'start_handl','end_handl');
   XML_Parse(%ptr, txt);

   dt=tlist(['SicosParam',data(:,1)']);
   fd=mopen(fic,'rb');

   for i=1:size(data,1)
     sz=evstr(data(i,2))*evstr(data(i,3));
     select evstr(data(i,4))
       case 10 then typ='dl';
       case 11 then typ='dl',sz=sz*2;
       case 84 then typ='ll';
       case 82 then typ='sl';
       case 81 then typ='cl';
       case 814 then typ='ull';
       case 812 then typ='usl';
       case 811 then typ='ucl';
     end
     dt(1+i)=matrix(mget(sz,typ,fd),evstr(data(i,2)),evstr(data(i,3)));
   end

   mclose(fd);
endfunction