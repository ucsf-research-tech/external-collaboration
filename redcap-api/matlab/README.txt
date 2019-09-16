Use urlread to read/write record and download files

For file upload, use redcapreadpost included in this folder. redcapreadpost is a modification of urlreadpost which is available in this folder or from MATLAB Central at  http://www.mathworks.com/matlabcentral/fileexchange/27189-urlreadpost-url-post-method-with-binary-file-uploading

urlreadpost can upload files. It will however insist on using dummy as the file name displayed on REDCap. redcapreadpost remove that restriction by allowing you to specify the display file name.