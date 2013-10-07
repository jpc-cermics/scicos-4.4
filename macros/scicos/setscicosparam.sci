function [ok]=setscicosparam(dt,fic)
// setscicosparam : write binary data in rdnom_params.dat
// file generated by Scicos CodeGeneration.
//
// input : dt : a list that encloses the name and the values
//         of the scicos variables to be written in the parameters
//         file
//
//         fic : path+name of the data file
//
// output : ok : a flag to say if the operation is succesfull

   ok=%f;

   if dt.type<>'SicosParam' then
     error('Type of data list doesn''t match.');
   end

   if ~file('exists',fic) then
     error('File doesn''t exists.');
   end

   [path,fname,extension]=fileparts(fic)
   fic_xml=path+'/'+fname+'.xml';

   if ~file('exists',fic_xml) then
     error('Xml file doesn''t exists.');
   end

   [dt_old,data]=getscicosparam(fic);

   if length(dt)<>length(dt_old) then
     error('Bad size for data list.');
   end

   for i=dt.__keys'
     if ~dt_old.iskey[i] then
       error('Bad name for component of data list : '+i+'.');
     end
     if ~isequal(size(dt(i)),size(dt_old(i))) then
       error('Bad size for component of data list : '+i+'. Must be '+sci2exp(size(dt_old(i)))+'.');
     end
     if ~isequal(typeof(dt(i)),typeof(dt_old(i))) then
       error('Bad type for component of data list : '+i+'. Must be '+typeof(dt_old(i))+'.');
     end
   end
   
   fd=fopen(fic,mode='wb');
   
   for i=data(:,1)'
     j=find(data(:,1)==i);
     select evstr(data(j,4))
       case 10 then typ='dl';
       case 11 then typ='dl';
       case 84 then typ='ll';
       case 82 then typ='sl';
       case 81 then typ='cl';
       case 814 then typ='ull';
       case 812 then typ='usl';
       case 811 then typ='ucl';
     end
     fd.put[dt(i),type=typ]
   end
   
   fd.close[];
   ok=%t

endfunction
