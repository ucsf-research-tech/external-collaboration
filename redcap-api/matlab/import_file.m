SERVICE='https://YOUR_REDCAP_INSTALLATION/api/';
TOKEN='YOUR_API_TOKEN';

disp('************************');
disp('Upload a file to a subject record');
disp('************************');

fp=fopen('FILE_TO_UPLOAD');
fdata=fread(fp, inf, 'char');
fclose(fp);

[reply, status] =  redcapreadpost( ...
  SERVICE, ...
  'NAME_OF_FILE_BEING_UPLOADED', ...
  { 'token', TOKEN,  ...
    'content', 'file', ...
    'action', 'import', ...
    'overwriteBehaviour', 'normal', ...
    'record', 'RECORD', ...
    'field', 'FIELD_NAME', ...
    'file', fdata, ...
  } ...
)
