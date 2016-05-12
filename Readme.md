[![Build status](https://ci.appveyor.com/api/projects/status/u958pps82xgh0wua?svg=true)](https://ci.appveyor.com/project/beatcracker/wsscompressedstructure)


# `WssCompressedStructure` PowerShell module

This module allows you to get/set `XML field schema`/`Content Types` for SharePoint list directly in the content database.
They are stored in database as [WSS Compressed Structures](https://msdn.microsoft.com/en-us/library/hh661051.aspx).
Requires PowerShell 3.0 or higher.

# Quick how-to:

This example shows how to modify XML field schema for list with ID `cff8ae4b-a78d-444c-8efd-5fe290821cb9`, which is stored in Sharepoint content database `SP_CONTENT` on server `SQLSRV`.

How to find list guid: [how to find Sharepoint Guid of a list](http://stackoverflow.com/questions/19630267/how-to-find-sharepoint-guid-of-a-list) , [Get the List id (Guid) for a list by name in SP 2010 Programatically](http://sharepoint.stackexchange.com/questions/70058/get-the-list-id-guid-for-a-list-by-name-in-sp-2010-programatically).

* Download module as Zip (unblock zip file before unpacking) or clone this repo using Git
* Import module: `Import-Module -Path 'X:\Path\To\WssCompressedStructure\Module'`
* Backup `XML field schema` blob for SharePoint to file: 

        Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -ContentTypes -ListId 'cff8ae4b-a78d-444c-8efd-5fe290821cb9' | Export-WssCompressedStructureBinary -DestinationPath 'X:\Wss\'

* Export `XML field schema` for SharePoint list to file: 

        Get-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -ContentTypes -ListId 'cff8ae4b-a78d-444c-8efd-5fe290821cb9' | Expand-WssCompressedStructure -DestinationPath 'X:\Wss\'

* Modify file `cff8ae4b-a78d-444c-8efd-5fe290821cb9.xml` to your needs
* Update `XML field schema` in database for this list:

        New-WssCompressedStructure -Path 'X:\Wss\cff8ae4b-a78d-444c-8efd-5fe290821cb9.xml' | Set-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -Fields -ListId 'cff8ae4b-a78d-444c-8efd-5fe290821cb9'

* If something goes wrong, restore `XML field schema` from blob:

        'X:\Wss\cff8ae4b-a78d-444c-8efd-5fe290821cb9.bin' | Import-WssCompressedStructureBinary | Set-SpListWssCompressedStructure -ServerInstance SQLSRV -Database SP_CONTENT -Fields -ListId 'cff8ae4b-a78d-444c-8efd-5fe290821cb9'

# WARNING:
 
This can **BREAK YOUR SHAREPOINT INSTALLATION** and will put it in the **UNSUPPORTED STATE**, use with **EXTREME CAUTION!**

## Details:

* http://mossblogger.blogspot.com/2010/06/administration-supported-database.html
* http://www.collabshow.com/2010/08/12/were-serious-dont-modify-your-database-or-face-consequences/
* http://sharepoint.stackexchange.com/questions/96291/is-accessing-sharepoint-content-database-in-code-advisable