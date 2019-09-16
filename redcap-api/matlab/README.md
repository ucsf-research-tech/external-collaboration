# `redcap-api` - ARS external-collaboration
A mirror of the ```redcap-api``` code snippets provided by the REDCap Consortium.

Note that several of these appear to be quite out of date.  

*Important*: The ```matlab``` code snippets are no longer provided by the Consortium as examples - UCSF had an old copy of these for a consult in 2017; we have restored them here for review.

## Original `readme.txt`
Use urlread to read/write record and download files

For file upload, use redcapreadpost included in this folder. redcapreadpost is a modification of urlreadpost which is available in this folder or from MATLAB Central at  http://www.mathworks.com/matlabcentral/fileexchange/27189-urlreadpost-url-post-method-with-binary-file-uploading

urlreadpost can upload files. It will however insist on using dummy as the file name displayed on REDCap. redcapreadpost remove that restriction by allowing you to specify the display file name.

## Notes from Consortium discussion in ~2015

Useurlreadto read/write record and download file.

For file upload, use redcapreadpostwhichisattachedasapi_matlab.zip. redcapreadpostisamodificationofurlreadpostwhichisavailableinsidethesamezipattachmentorfromMATLAB Central athttp://www.mathworks.com/matlabcentral/fileexchange/27189-urlreadpost-url-post-method-with-binary-file-uploading

urlreadpostcanuploadfiles. Itwillhoweverinsistonusingdummyasthe file name displayed on REDCap.redcapreadpostremove that restriction by allowing you to specify the display file name.

See also urlread2 at Matlab File Exchange. (On Oct 4th2012, the link is http://www.mathworks.com/matlabcentral/fileexchange/35693-urlread2 with a blog post on http://undocumentedmatlab.com/blog/expanding-urlreads-capabilities/ describing its function). Ithasthepotentialtoreplaceredcapredpost,urlreadpostandurlrread. However, I (Cinly Ooi) had never tested its claims.

## Notes from @andy.martin on 2017-05 

>We had luck using webread which allows some more flexibility in the headers (although we aren't using it) - but this worked:

```matlab
disp('************************');
disp('Download a file from a subject record');
disp('************************');
options = weboptions('RequestMethod','post');
data = webread(...
'https://redcap.stanford.edu/api/',...
'token', 'xxx', ...
'content', 'record',...
'records', '1',...
'format', 'csv',...
'returnFormat', 'csv', options);
% WRITE CSV FILE
fid = fopen('test.csv','w')
fprintf(fid,'%s',data)
fclose(fid)
```