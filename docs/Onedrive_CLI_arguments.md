# Unofficial OneDrive command line arguments

```
/allUsers
/Background
/client= 
/configure_business
/configure_business:$tenantID
/firstSetup
/onPrem
/perMachineUpdate
/update
/RemoteBindToObjectWW
/remotedebug
/remoteport
/rz possibly
/silentConfig
/takeover
/url
/url:odopen://
/wait
/OneDrivePid:
/Shutdown
/Reset
```

If the arg doesn't work as expected try all lower case ([ref](https://superuser.com/questions/1742608/batch-script-to-pause-and-resume-one-drive-sync/1742609?noredirect=1#comment2856841_1742609)).

These switches were reverse engineered from various conversations around the web. None are guaranteed, something that works today might stop working tomorrow.



## History of this page

*This page was started from the extract below from web.archive.org, found by way of @Mokubai at [Batch Script to Pause and Resume One Drive Sync? - Super User](https://superuser.com/questions/1742608/batch-script-to-pause-and-resume-one-drive-sync/).  Since there doesn't seem to be a suitable replacement to this thread or it's ultimate aim - a doc page - Matt Wilkie gathered the material together and contributed it to the Powershell ***OneDrive-Client***  project. The info needs to live somewhere so it might as well be with the person who did the first big lift: Kevin Crouch (@PsychoData).*



**[PsychoData](https://web.archive.org/web/20220702175528/https://github.com/PsychoData)**  [on Aug 13, 2021](https://web.archive.org/web/20220702175528/https://github.com/MicrosoftDocs/OfficeDocs-SharePoint/issues/2905#issue-970562486) (edited)

I have tried to find a listing of OneDrive.exe Command  Line Arguments, but I cannot find anything. I tried opening a Microsoft Support case (Case #:1026127313) but they told me that OneDrive and they  told me "unfoortunately [sic] there are no Command-line switches for  OneDrive", even though there most definitely are. A couple examples of  Command-line parameters [here](https://web.archive.org/web/20220702175528/https://docs.microsoft.com/en-us/onedrive/plan-onedrive-enterprise#install-onedrive-on-windows-devices-by-using-scripting-methods).

It would be very helpful to update the Documentation for OneDrive to include some of  these similar to this page - [Command Line switches for Microsoft Office Products](https://web.archive.org/web/20220702175528/https://support.microsoft.com/en-us/office/command-line-switches-for-microsoft-office-products-079164cd-4ef5-4178-b235-441737deb3a6). For example:

Through experimentation and scouring dozens of docs pages,  hundreds of computer's activity, and random blogs, I have found this  list of Command Line switches/parameters for OneDrive.exe, and there may  even be several more, but I have not found them.

```
/allUsers
/Background
/client= 
/configure_business
/configure_business:$tenantID
/firstSetup
/onPrem
/perMachineUpdate
/update
/RemoteBindToObjectWW
/remotedebug
/remoteport
/rz possibly
/silentConfig
/takeover
/url
/url:odopen://
/wait
/OneDrivePid:
/Shutdown
/Reset
```

These functions could be extremely useful for IT Admins when they are scripting. For example, `Onedrive.exe /Shutdown` is extremely useful - it shuts down OneDrive gracefully, and `onedrive.exe /background` starts it back up again without throwing up the File Explorer window.

`OneDrive.exe /URL:odopen://$SharePointLibraryIDInfo` will start a SharePoint site Syncing through to File-Explorer - mostly silently.  

Or, another example, this could be used so that instead of making the user click several layers/pages deep on multiple sites to sync their libraries, the IT Admins could script it to sync the respective directories/sites.

Currently, there is very little way to know what a given parameter like `/silentConfig` does though - Does it attempt to login with the settings from Group Policy? Does it Reset the current Profile's OneDrive and THEN try to login with the Registry Settings? Is it happy to just guess that you're logged in as [johnsmith@contoso.one](https://web.archive.org/web/20220702175528/mailto:johnsmith@contoso.one) - so I'll see if I can SSO in with that?

We ****need**** actual documentation on these kinds of these Enterprise tools/features that are already in OneDrive and OneDrive.exe.



### From *Super User*

I found that 1) OneDrive command line switches must be all LOWER-CASE. e.g., Worked: "/background" and "/shutdown". DID NOT WORK: "/Background" and "/Shutdown". 2) Use combination "/background /shutdown" to prevent the File Explorer window popping up during shutdown. – [Rocky Scott](https://superuser.com/users/424079/rocky-scott "119 reputation") [Commented Nov 15, 2023](https://superuser.com/questions/1742608/batch-script-to-pause-and-resume-one-drive-sync/1742609?noredirect=1#comment2856841_1742609)
