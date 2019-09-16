SERVICE='https://YOUR_REDCAP_INSTALLATION/api/';
TOKEN='YOUR_API_TOKEN';

disp('************************');
disp('PULL data as flat csv');
disp('************************');
urlread( ...
	SERVICE, ...
	'post', ...
	{ 'token',   TOKEN,    ...
	  'content', 'record', ...
	  'format',  'csv',    ...
	  'type',    'flat',   ...
	} ...
)
