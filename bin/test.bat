@echo off
echo normal.exe:& normal.exe
echo compiled.exe:& compiled.exe
echo truncsectbl.exe:& truncsectbl.exe
echo bigalign.exe:& bigalign.exe
echo.
echo PE with many sections:
echo 96emptysections.exe:& 96emptysections.exe
echo 96workingsections.exe:& 96workingsections.exe
echo.
echo TLS:
echo tls.exe:& tls.exe
echo tls_import.exe (displayed afterwards, but working):& tls_import.exe
echo tls_onthefly.exe:& tls_onthefly.exe
echo tls_obfuscation.exe:& tls_obfuscation.exe
echo tls_aoi.exe:& tls_aoi.exe
echo tls_exiting.exe:& tls_exiting.exe
echo tls_noEP.exe:& tls_noEP.exe
echo tls_virtEP.exe:& tls_virtEP.exe
echo tls_reloc.exe:& tls_reloc.exe
echo tls_k32.exe:& tls_k32.exe
echo.
echo Exports:
echo exportobf.exe:& exportobf.exe
echo exportsdata.exe:& exportsdata.exe
echo.
echo Imports loading:
echo imports.exe:& imports.exe
echo imports_noint.exe:& imports_noint.exe
echo imports_badterm.exe:& imports_badterm.exe
echo imports_vterm.exe:& imports_vterm.exe
echo imports_noext.exe:& imports_noext.exe
echo imports_mixed.exe:& imports_mixed.exe
echo imports_nothunk.exe:& imports_nothunk.exe
echo importshint.exe:& importshint.exe
echo impbyord.exe:& impbyord.exe
echo imports_iatindesc.exe:& imports_iatindesc.exe
echo imports_virtdesc.exe:& imports_virtdesc.exe
echo.
echo DLL loading:
echo  * statically loaded DLL and export call
echo dll-ld.exe:& dll-ld.exe
echo dll-dynld.exe:& dll-dynld.exe
echo dll-dynunicld.exe:& dll-dynunicld.exe
echo dllweirdexp-ld.exe:& dllweirdexp-ld.exe
echo dllemptyexp-ld.exe:& dllemptyexp-ld.exe
echo dllord-ld.exe:& dllord-ld.exe
echo dllnoreloc-ld.exe:& dllnoreloc-ld.exe
echo dllnoexp-dynld.exe:& dllnoexp-dynld.exe
echo ownexports.exe:& ownexports.exe
echo dllnomain-ld.exe:& dllnomain-ld.exe
echo dllnomain2-dynld.exe:& dllnomain2-dynld.exe
echo dllnullep-dynld.exe:& dllnullep-dynld.exe
echo dllnullep-ld.exe:& dllnullep-dynld.exe
rem BROKEN for now
rem echo dllnegep-ld.exe:& dllnegep-ld.exe 

echo.
echo export forwarding:
echo dllfw-ld.exe:& dllfw-ld.exe
echo dllfwloop-ld.exe:& dllfwloop-ld.exe
echo.
echo bound imports:
echo dllbound-ld.exe:& dllbound-ld.exe
echo dllbound-redirld.exe:& dllbound-redirld.exe
echo.
echo tiny PE
echo tiny.exe:& tiny.exe
echo.
echo ImageBase:
echo ibkernel.exe:& ibkernel.exe
echo ibkmanual.exe:& ibkmanual.exe
echo bigib.exe:& bigib.exe
echo reloccrypt.exe:& reloccrypt.exe
echo fakerelocs.exe:& fakerelocs.exe
echo.
echo EntryPoint:
echo nullEP.exe:& nullEP.exe
echo virtEP.exe:& virtEP.exe
echo dllextep-ld.exe:& dllextep-ld.exe
echo.
echo sections:
echo bigsec.exe:& bigsec.exe
echo bigSoRD.exe:& bigSoRD.exe
echo dupsec.exe:& dupsec.exe
echo duphead.exe:& duphead.exe
echo secinsec:& secinsec.exe
echo appendedsecttbl.exe:& appendedsecttbl.exe
echo appendedhdr.exe:& appendedhdr.exe
echo footer.exe:& footer.exe
echo bottomsecttbl.exe:& bottomsecttbl.exe
echo truncatedlast.exe:& truncatedlast.exe
echo shuffledsect.exe:& shuffledsect.exe
echo.
echo gaps:
echo slackspace.exe:& slackspace.exe
echo appendeddata.exe:& appendeddata.exe
echo hiddenappdata1.exe:& hiddenappdata1.exe
echo hiddenappdata2.exe:& hiddenappdata2.exe
echo virtgap.exe:& virtgap.exe
echo foldedhdr.exe:& foldedhdr.exe
echo.
echo resources:
echo resource.exe:& resource.exe
echo resource2.exe:& resource2.exe
echo namedresource.exe:& namedresource.exe
echo reshdr.exe:& reshdr.exe
echo resourceloop.exe:& resourceloop.exe
echo resource_string.exe:& resource_string.exe
echo.
echo delay imports:
echo delayimports.exe:& delayimports.exe
echo delaycorrupt.exe:& delaycorrupt.exe
echo delayfake.exe:& delayfake.exe
echo.
echo register corruptions:
echo fakeregs.exe:& fakeregs.exe
echo.
echo data PEs:
echo d_tiny-ld.exe:& d_tiny-ld.exe
echo d_nonnull-ld.exe:& d_nonnull-ld.exe
echo d_resource-ld.exe:& d_resource-ld.exe
echo maxvals.exe:& maxvals.exe
echo.
echo manifest:
echo manifest.exe:& manifest.exe
echo manifest_bsod.exe:& manifest_bsod.exe
echo manifest_broken.exe:& manifest_broken.exe

echo misc:
echo no_dd.exe:& no_dd.exe
echo winver.exe:& winver.exe
echo weirdsord.exe:& weirdsord.exe
echo.
rem echo multiss_gui.exe:& multiss_con.exe
rem dll-webdavld.exe disabled until found a suitable host
rem pdf.exe / pdf_zip_pe.exe disabled because of the non-console output
rem quine.exe disabled because creates an extra window
