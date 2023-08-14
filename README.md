# OpenToolsAPIForms
Will add a form in the File->New->Other Gallery. The form is part of the Delphi->New category. Developed with Delphi 10 (Tokyo) but should work with Delphi 11, and possibly older versions, as well.
Any version where ToolsInf.pas and EditIntf.pas are *not* deprecated probably won't work. You'll have to check those files on your version. I only have 10.2 & 11 installed here.

![image](https://github.com/ntavendale/OpenToolsAPIForms/assets/38380983/708ee56b-2b2b-4e14-a637-4bb123f86926)

The **Delphi 10 TestApp** contains a project created in Delphi 10.4.2. In this project there is Forminheritance and it uses the property OldCreateOrder. The application will work properly when built with Delphi 10, but will not work properly when built with Delphi 11. It will compile and run, but have unexpected behaviour.

The **Delphi 11 TestApp** contains a copy of the Delphi 10 project, but modified so the CommonForm no longer inherits from TForm but from TMyCustomForm.
The TMyCustomForm implements necessary code with regards to the Constructor and Destructor to get the OldCreateOrder property to work
