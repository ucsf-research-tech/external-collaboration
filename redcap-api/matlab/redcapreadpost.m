function [output,status] = redcapreadpost(urlChar, filename, params)
%REDCAPREADPOST Returns the contents of a URL POST method as a string.
%   S = REDCAPREADPOST('URL',PARAMS) passes information to the REDCAP API as
%   a POST request.  PARAMS is a cell array of param/value pairs. 
%   
%   Unlike stock urlread, this version uses the multipart/form-data
%   encoding, and can thus post file content.  File data is 
%   encoded as a value element of numerical type (e.g. uint8)
%   in PARAMS. filename is used as the file name to be displayed in 
%   REDCap when upload a file using API file upload. For example:
%
%   f = fopen('music.mp3');
%   d = fread(f,Inf,'*uint8');  % Read in byte stream of MP3 file
%   fclose(f);
%   str = urlreadpost('http://developer.echonest.com/api/upload', ...
%           {'file',dd,'version','3','api_key','API-KEY','wait','Y'});
%
%   ... will upload the mp3 file to the Echo Nest Analyze service.
%
%  Modified from Dan Ellis' urlreadpost() function. Note that
%  unlike URLREADPOST, there is a second parameter called filename
% 
%  http://www.mathworks.com/matlabcentral/fileexchange/27189-urlreadpost-url-post-method-with-binary-file-uploading
%  
%  URLREADPOST is distributed under BSD license
%  URLREADPOST will also work for REDCap file upload. However, your filename
%  is set to 'dummy'. That's why I created REDCAPREADPOST to  give uploaded
%  file its own specific name.
%
%
% This function requires Java.
%
% Tested using REDCAP 4.7.1 and Matlab R2010b
%
% 
%  2010-04-07 Dan Ellis dpwe@ee.columbia.edu (URLREADPOST. Downloaded by CO on 2012-04-27)
%  2012-05-02 Cinly Ooi co224@cam.ac.uk. Distributed under BSD license.

if ~usejava('jvm')
   error('MATLAB:redcapreadpost:NoJvm','REDCAPREADPOST requires Java.');
end

import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

% Be sure the proxy settings are set.
com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings

% Check number of inputs and outputs.
error(nargchk(3,3,nargin))
error(nargoutchk(0,2,nargout))
if ~ischar(urlChar)
    error('MATLAB:redcapreadpost:InvalidInput','The first input, the URL, must be a character array.');
end

% Do we want to throw errors or catch them?
if nargout == 2
    catchErrors = true;
else
    catchErrors = false;
end

% Set default outputs.
output = '';
status = 0;

% Create a urlConnection.
[urlConnection,errorid,errormsg] = urlreadwrite(mfilename,urlChar);
if isempty(urlConnection)
    if catchErrors, return
    else error(errorid,errormsg);
    end
end

% POST method.  Write param/values to server.
% Modified for multipart/form-data 2010-04-06 dpwe@ee.columbia.edu
%    try
        urlConnection.setDoOutput(true);
        boundary = '***********************';
        urlConnection.setRequestProperty( ...
            'Content-Type',['multipart/form-data; boundary=',boundary]);
        printStream = java.io.PrintStream(urlConnection.getOutputStream);
        % also create a binary stream
        dataOutputStream = java.io.DataOutputStream(urlConnection.getOutputStream);
        eol = [char(13),char(10)];
        for i=1:2:length(params)
          printStream.print(['--',boundary,eol]);
          printStream.print(['Content-Disposition: form-data; name="',params{i},'"']);
          if ~ischar(params{i+1})
            % binary data is uploaded as an octet stream
            % Echo Nest API demands a filename in this case
            printStream.print(['; filename="' filename '"',eol]);
            printStream.print(['Content-Type: application/octet-stream',eol]);
            printStream.print([eol]);
            dataOutputStream.write(params{i+1},0,length(params{i+1}));
            printStream.print([eol]);
          else
            printStream.print([eol]);
            printStream.print([eol]);
            printStream.print([params{i+1},eol]);
          end
        end
        printStream.print(['--',boundary,'--',eol]);
        printStream.close;
%    catch
%        if catchErrors, return
%        else error('MATLAB:redcapreadpost:ConnectionFailed','Could not POST to URL.');
%        end
%    end

% Read the data from the connection.
try
    inputStream = urlConnection.getInputStream;
    byteArrayOutputStream = java.io.ByteArrayOutputStream;
    % This StreamCopier is unsupported and may change at any time.
    isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
    isc.copyStream(inputStream,byteArrayOutputStream);
    inputStream.close;
    byteArrayOutputStream.close;
    output = native2unicode(typecast(byteArrayOutputStream.toByteArray','uint8'),'UTF-8');
catch
    if catchErrors, return
    else error('MATLAB:redcapreadpost:ConnectionFailed','Error downloading URL. Your network connection may be down or your proxy settings improperly configured.');
    end
end

status = 1;
