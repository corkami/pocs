all: common XP W7

beta: no_dd64.exe debug.exe sfence.sys

common: exports imports dll gaps tls bound entrypoint down many misc resource delay relocs dotnet

exports: ownexports.exe ownexports2.exe exportsdata.exe exportobf.exe exports_doc.exe exports_order.exe

many: 96emptysections.exe 96workingsections.exe bigSoRD.exe

dll: dll.dll dll-ld.exe dll-dynld.exe dllweirdexp.dll dllweirdexp-ld.exe dllemptyexp.dll \
    dllemptyexp-ld.exe dllord.dll dllord-ld.exe dll-dynunicld.exe dllnoreloc.dll dllnoreloc-ld.exe \
    dllnoexp.dll dllnoexp-dynld.exe dllfw.dll dllfw-ld.exe dllfwloop.dll dllfwloop-ld.exe \
    dll-webdavld.exe dupsec.exe secinsec.exe bigib.exe dllnomain.dll dllnomain-ld.exe \
    dllnomain2.dll dllnomain2-dynld.exe dllnullep.dll dllnullep-ld.exe dllnullep-dynld.exe \
    dllnegep.dll dllnegep-ld.exe ctxt.dll ctxt-ld.exe

relocs: ibkernel.exe reloccrypt.exe ibkmanual.exe ibreloc.exe fakerelocs.exe

misc: normal.exe truncatedlast.exe pdf.exe tiny.exe bigsec.exe shuffledsect.exe truncsectbl.exe \
    quine.exe bigalign.exe foldedhdr.exe compiled.exe duphead.exe \
    no0code.exe fakeregs.exe fakeregslib.dll gui.exe multiss.exe multiss_gui.exe no_dd.exe \
    maxvals.exe pdf_zip_pe.exe winver.exe weirdsord.exe hdrcode.exe mini.exe \
	dump_imports.exe

down: appendedsecttbl.exe appendedhdr.exe footer.exe bottomsecttbl.exe

entrypoint: virtEP.exe dllextep.dll dllextep-ld.exe nullEP.exe

bound: dllbound.dll dllbound-ld.exe dllbound-redirld.exe

tls: tls.exe tls_obfuscation.exe tls_import.exe mz.exe tls_onthefly.exe tls_aoi.exe \
    tls_aoiOSDET.exe tls_exiting.exe tls_noEP.exe tls_reloc.exe tls_k32.exe tls_virtEP.exe

delay: delayimports.exe delaycorrupt.exe delayfake.exe

gaps: appendeddata.exe hiddenappdata1.exe hiddenappdata2.exe slackspace.exe virtgap.exe

resource: manifest resource.exe resource2.exe reshdr.exe namedresource.exe resourceloop.exe \
    resource_string.exe d_resource-ld.exe d_resource.dll version

manifest: manifest.exe manifest_bsod.exe manifest_broken.exe
version: version_mini.exe version_std.exe version_cust.exe

imports: imports.exe imports_noint.exe imports_noext.exe imports_mixed.exe impbyord.exe \
    imports_badterm.exe imports_vterm.exe imports_nothunk.exe imports_multidesc.exe \
    imports_iatindesc.exe imports_virtdesc.exe importshint.exe nothing.dll \
	nothing-ld.exe d_tiny.dll d_tiny-ld.exe d_nonnull.dll d_nonnull-ld.exe sc.exe \
	hard_imports.exe

XP: tinyXP.exe maxsecXP.exe nosectionXP.exe nullSOH-XP.exe virtsectblXP.exe tinydllXP.dll \
    tinydllXP-ld.exe ibnullXP.exe dllbound-redirldXP.exe dllbound2.dll reloccryptXP.exe \
    dosZMXP.exe driver.sys tinydrivXP.sys virtrelocXP.exe exe2pe.exe imports_tinyXP.exe \
    importsdotXP.exe

W7: tinyW7.exe tinyW7x64.exe tinyW7_3264.exe maxsec_lowaligW7.exe nosectionW7.exe maxsecW7.exe \
    appsectableW7.exe apphdrW7.exe foldedhdrW7.exe normal64.exe 65535sects.exe imports_apimsW7.exe \
    ibrelocW7.exe ibknoreloc64.exe imports_tinyW7.exe manyimportsW7.exe imports_relocW7.exe \
	exceptions.exe seh_change64.exe

dotnet: tinynet.exe dotnet20.exe mscoree.exe fakenet.exe

multiss_gui.exe: multiss.exe
	c:\python26\python multiss.py

65535sects.exe: ..\mkpe.py
	c:\python26\python ..\mkpe.py 65535

%.exe: ..\%.asm
	yasm -o $@ $<

%.dll: ..\%.asm
	yasm -o $@ $<

%.sys: ..\%.asm
	yasm -o $@ $<
	c:\python26\python fixsum.py $@
