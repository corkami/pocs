this is Corkami PE files corpus:
a set of handmade files showing the various possibilities of the Portable Executable format,
under Windows.

All these files are clean and working.
However, they are hand-made and push the PE file format to its limits,
so they might be detected as malicious or as corrupted files.

it's documented at http://pe.corkami.com

Ange Albertini
@angealbertini (@corkami for news only)

BSD Licence, 2009-2013

Ranking (YMMV)
*.. = common
**. = non-standard
*** = complex


 *.. compiled.exe             complete PE example, as if compiled via MASM, including RichHeader, full headers + dos stub...

 *.. normal.exe               a 'normal' PE - sections, code, imports. Header is not full
 *.. normal64.exe              64b version

 **. mini.exe                 a PE defined with as few elements as possible (alignments = 1/1)

 **. bigalign.exe             big alignments (10000h/20000000h)
 **. bigib.exe                IMAGEBASE equ 7efd0000h ; 7ffd0000h also works under XP
 **. bigsec.exe               PE with virtually big section (0x10001000)
 **. bigSoRD.exe              PE with oversized SizeOfRawData (0xFFFF0200)
 **. bottomsecttbl.exe        section table at the bottom of the PE

 *.. lowsubsys.exe            a PE with a subsystem version of 3.10

 **. 65535sects.exe           65536 physical sections, all executed

 **. 96emptysections.exe      PE with 96 sections (95 empty sections)
 **. 96workingsections.exe    PE with 96 code sections, fully used

 *.. appendeddata.exe         a PE with appended data
 **. appendedhdr.exe          PE with NT headers in appended data (in extended header via SizeOfHeader)
 **. apphdrW7.exe             PE with NT headers in appended data (W7)
 **. appendedsecttbl.exe      section table outside the PE, in appended data (but in the header itself, for XP compatibility)
 **. appsectableW7.exe        unlike XP, the header doesn't need to be extended until the bottom of the file !W8

 **. footer.exe               NT Headers at the bottom of the file

 *** ctxt.dll                 a DLL modifying the caller's context via lpvReserved
      ctxt-ld.exe                loader

EntryPoint
 **. nullEP.exe               PE with null EntryPoint (MZ is executed as dec ebp, pop edx)
 *** virtEP.exe               PE with EntryPoint in virtual space (there will be a virtual 00 before the first physical C0, so 00C0 will be executed as `add al, al`)

DLL: (relocations, EntryPoint...)
 *.. dll.dll                  a simple DLL with relocations
      dll-ld.exe               static loader
      dll-dynld.exe            dynamic loader
      dll-dynunicld.exe        dynamic unicode loader
 **.  dll-webdavld.exe         WEBDav loader

 **. dllemptyexp.dll          DLL with empty export name
      dllemptyexp-ld.exe        loader

 **. dllextep.dll             DLL with no relocations for external EntryPoint execution
      dllextep-ld.exe          loader

 *.. dllfw.dll                forwarding DLL with minimal export table, and relocations
      dllfw-ld.exe              loader

 **. dllfwloop.dll            forwarding DLL with forwarding loop
      dllfwloop-ld.exe          loader

 **. dllnegep.dll             DLL with a negative entrypoint - that is *NOT* called
      dllnegep-ld.exe           loader

 **. dllnoexp.dll             DLL with no export tables, only DLL main
      dllnoexp-dynld.exe        loader

 *** dllnomain.dll            a DLL with no DLLMain (no IMAGE_FILE_DLL)
      dllnomain-ld.exe          static loader
 *** dllnomain2.dll           a DLL with no DLLMain (no IMAGE_FILE_DLL), and no imports (to be loaded dynamically)
      dllnomain2-dynld.exe      dynamic loader

 **. dllnoreloc.dll           DLL with no relocations (unneeded)
      dllnoreloc-ld.exe         loader

 **. dllnullep.dll            DLL with a null entrypoint - that is *NOT* called
      dllnullep-ld.exe         static loader
      dllnullep-dynld.exe      dynamic loader

 **. dllfakess.dll            a DLL with a fake subsystem
      dllfakess-ld.exe         static loader
      dllfakess-dynld.exe      dynamic loader

 **. dllmaxvals.dll           a DLL with maximum values
      dllmaxvals-ld.exe        static loader
      dllmaxvals-dynld.exe     dynamic loader

 **. dllcfgdup.dll            a DLL using Guard ControlFlow, but with duplicate entry
      dllcfgdup-dynld.exe      dynamic loader

 **. cfgbogus.exe             a PE with a bogus ControlFlow Guard table (Subsystem version too old)

Subsystems
 *.. gui.exe                  a simple GUI PE
 **. driver.sys               a simple driver (section, relocation, imports, checksum)

 *** multiss.exe              a multi-subsystem PE (that displays a message) no matter what its subsystem is set to.
      multiss_con.exe          console !W8
      multiss_gui.exe          gui !W8
      multiss_drv.sys          driver

 *.. aslr.dll                 a DLL with DYNAMIC_BASE set and used
      aslr-ld.exe              loader
 **. skippeddynbase.exe       a PE with ignored DYNAMIC_BASE, because RELOCS_STRIPPED is set

Section table (PE Geometry):
 **. duphead.exe              a PE with a section mapping the header
 **. dupsec.exe               a PE with several sections with the same physical space, and the header too

 *** foldedhdr.exe            NT headers is partially overwritten by section space, as if the sections were folded back on the header.
 *** foldedhdrW7.exe          Windows 7 version

 **. hiddenappdata1.exe       a PE with appended data hidden by an extra almost virtual section
 **. hiddenappdata2.exe       a PE with appended data hidden by an enlarged last section

 **. truncatedlast.exe        last section truncated
 **. truncsectbl.exe          section table is truncated by sizeofheaders
 **. shuffledsect.exe         a PE with sections in wrong order in the section table
 **. slackspace.exe           slack space between sections
 **. secinsec.exe             a PE with a small section physically inside a bigger one
 **. virtgap.exe              a PE with a huge virtual gap between physical section
 *** virtsectblXP.exe         with 85 sections, with the section table outside the file

 **. maxsec_lowaligW7.exe     Low Alignment PE for Vista-W7, with 6666 sections
 **. maxsecW7.exe             PE with 8192 used code sections
 **.  maxsecXP.exe             Low Alignment PE for XP, with 96 sections

 **. no_dd.exe                a PE without any data directory (loading imports manually) !W8
 **. no_dd64.exe               64b version
 **. no0code.exe              no null before code ends => headers are relocated far enough so that e_lfanew contains no 0 !W8
 **. nosectionW7.exe          Low Alignment PE for , with no section !W8
      nosectionXP.exe          XP version

 *** nothing.dll              a DLL with code and no sections, no EntryPoint, no imports (crashing w/W8)
      nothing-ld.exe           loader

 **. nullSOH-XP.exe           null SizeOfOptionalHeader which means the Section table is overlapping the Optional header (XP only)
 *.. nullvirt.exe             a PE with a virtually null section

 **. tinyXP.exe               a tiny PE: sectionless, PE header overlapping dos headers, truncated optional header, 97 bytes XP only.
 **. tinydll.dll              same thing, DLL version
      tinydll-ld.exe            loader
 **. tinydllXP.dll              same thing, XP version
      tinydllXP-ld.exe            loader
 **. tinydrivXP.sys           same thing, driver version
 **. tinygui.exe              GUI version, using MessageBox and ExitProcess with contiguous code !W8

 **. tiny.exe                 a universal tiny PE, working from XP to W8 64b
 **. tinyW7.exe               a tiny PE, W7 32b compatible. just need a full optional header, so padding until 252 bytes is required.
 **. tinyW7_3264.exe          a 32b tiny PE, W7 64b compatible (requires a bigger padding, 268 bytes) !W8
 **. tinyW7x64.exe            a 64b tiny PE, in 268 bytes !W8

 *** weirdsord.exe            a PE where 4K is read from the section for no apparent reason

 **. winver.exe               a PE using Win32VersionValue to override OS version numbers

 *.. no_dep.exe               a PE executing code on the stack successfully
 *.. dep.exe                  a PE executing code on the stack, and failing because of DEP
 *.. no_seh.exe               a PE with DllCharacteristics set to NO_SEH, but using a Vectored Exception Handler

 *.. memshared.dll            a DLL with a MEM_SHARED section
      memshared-ld.exe         loader, waiting for X launches to terminate

DataDirectory 0: Export
 **. ownexports.exe           calling its own exports
 **. ownexportsdot.exe        calling its own exports, but with a trailing characters in the import name (may generate crashes)
 **. ownexports2.exe          calling its own virtual and header exports
 **. exportobf.exe            PE with fake exports to disrupt disassembly
 **. exports_doc.exe          PE with exports as internal documentation
 **. exports_order.exe        a PE with exports not alphabetically sorted
 *** exportsdata.exe          PE with its own exports, used to store data, restored on imports resolving

 **. dllord.dll               DLL with exports by ordinal and heavily export corrupted structure
     dllord-ld.exe             loader

 **. dllweirdexp.dll          DLL with weird export (very long, fake, obfuscation (anti-Hiew))
     dllweirdexp-ld.exe        loader

DataDirectory 1: Import
 *.. imports.exe              standard imports
 *.. impbyord.exe             PE importing by ordinal (his own exports)
 *.. imports_apimsW7.exe      imports with Windows 7 redirection via apisetschema.dll
 *.. imports_mixed.exe        mixed case imports
 *.. imports_noext.exe        imports with dll without file extensions (>2K)
 *.. imports_multidesc.exe    a PE with multiple import descriptors for the same DLL
 *.. imports_noint.exe        imports with no INT
 **. imports_badterm.exe      PE with a 'bad' imports terminator, just the dll name is empty
 **. imports_bogusIAT.exe     bogus IAT content but INT is correct
 **. imports_corruptedIAT.exe IAT with corrupted pointers but INT is correct
 **. imports_nnIAT.exe        IAT is not null-terminated but INT is correct
 **. importsdotXP.exe         a PE using trailing characters in its imports (XP/W8 only)
 **. imports_nothunk.exe      imports with a bogus DLL with missing thunks in the tables
 *** imports_relocW7.exe      PE with a kernel range IMAGEBASE, and relocations to fix (manually pre-corrupted) imports
 *** hard_imports.exe         a PE that calls imports by comparing kernel32 timestamp with known list
      dump_imports.exe         tool to extract data for hard_imports

 **. imports_iatindesc.exe    imports with IAT inside descriptors (smallest 'standard' imports structure)
 **. imports_tinyW7.exe       imports with all tricks to make it as small as possible !W8
 **. imports_tinyXP.exe        XP version

 **. imports_virtdesc.exe     PE with 1st import descriptor starting in virtual space
 **. imports_vterm.exe        import terminator in virtual space
 **. importshint.exe          exports with the same name - and the right one is called via hints

DataDirectory 2: Resource
 *.. resource.exe             resources loaded by IDs as integers
 *.. resource2.exe            resource loaded by its IDs as strings
 *.. namedresource.exe        resource, loaded by name
 **. reshdr.exe               resource in the header, and shuffled resource structure
 **. resourceloop.exe         recursive resource directory

 Resource type: RT_STRING
 *.. resource_string.exe      string resource

 Resource type: RT_ICON and RT_GROUP_ICON
 *.. resource_icon.exe        icon resource and group

 Resource type: RT_VERSION
 *.. version_std.exe          'standard' version information (with duplicate entries)
 **. version_cust.exe         a PE with version customized minimal info - only to make the version tab appear
 **. version_mini.exe         a PE with version minimal info

 Resource type: RT_MANIFEST
 *.. manifest.exe             a PE with a minimal MANIFEST resource (CreateActCtx successfull)
 **. manifest_broken.exe      a PE with a checked broken MANIFEST resource (ignored)
 **. manifest_bsod.exe        a PE with a checked MANIFEST resource, that triggers a crash on execution (kb 921337)

DataDirectory 3: Exception
 *.. exceptions.exe           a 64b PE using SEH via its exceptions DD
 **. seh_change64.exe         a 64b PE updating its exceptions DD on the fly

DataDirectory 5: Relocations
 **. fakerelocs.exe           a PE with unused corrupted relocations
 *** virtrelocXP.exe          fake virtual relocations
 **. ibnullXP.exe             null IMAGEBASE (XP only) + relocations
 **. ibkernel.exe             kernel range IMAGEBASE + relocations
 **. ibknoreloc64.exe         a PE32+ with kernel imagebase and RIP-relative code (no relocations)
 *** ibkmanual.exe            kernel range IMAGEBASE, but no relocations, only manually-fixed in advance offsets

 **. reloc4.exe               a PE using relocation type 4 (parameter ignored from W2k to W7, used in W8)
 **. reloc9.exe               a PE using relocation type 9 (different results under XP and W7, unsupported under W8)
 *** reloccrypt.exe           a PE storing its code via relocations patch, with extra fake or rarely used relocations
 *** reloccryptXP.exe          XP version
 *** reloccryptW8.exe          W8 version

 *** ibreloc.exe              relocation is applied to ImageBase in memory, which corrects the wrong entrypoint
 *** ibrelocW7.exe            >XP version !W8

 *** lfanew_relocW7.exe       relocation is applied to e_lfanew in memory => another PE header is then pointed to, which contains the actual imports in the 2nd part of DataDirectories !W8
 *** lfanew_relocXP.exe       XP version

 **. relocsstripped.exe       a PE using relocations even if RELOCS_STRIPPED is set
 **. relocsstripped64.exe     PE32+ version

 *** relocOSdet.exe           combining relocations type 9 and 4 to detect OSes

DataDirectory 6: Debug
 *.. debug.exe                a PE with a Debug Directory (and missing symbols)

DataDirectory 7: Architecture/Copyright
 *.. copyright.exe            a PE with an Architecture DataDirectory entry used for Copyright/Description

DataDirectory 9: Thread local storage
 *.. tls.exe                  standard Thread Local Storage callbacks
 *.. tls64.exe                standard Thread Local Storage callbacks in 64 bits
 **. tls_noEP.exe             TLS PE with ExitProcess call, and no entrypoint at all
 **. tls_exiting.exe          TLS PE with ExitProcess call, and ignored EntryPoint code, even though the TLS is called again after...
 **. tls_import.exe           TLS using an import IAT entry as callbacks => API called with IMAGEBASE as param => WinExec can thus execute MZ.exe
      mz.exe                   executed by tls_import
 **. tls_k32.exe              TLS but only imports to k32 (TLS ignored)
 **. tls_obfuscation.exe      file with extra fake TLS to disturb disassembly (first callbacks triggers an exception)
 **. tls_onthefly.exe         PE with TLS updating on-the-fly the callback list
 **. tls_reloc.exe            Kernel ImageBase + TLS that needs relocation
 **. tls_virtEP.exe           random EntryPoint, and the TLS just allocates virtual space before it's called
 **. tls_aoi.exe              TLS AddressOfIndex is used to patch a dword to 0
 *** tls_aoiOSDET.exe         AddressOfIndex is used to patch turn an import descriptor to a terminator => the OS' different behaviors will alterate imports loading
 *** manyimportsW7.exe        file with too many fake imports, which are 'ignored' on loading by TLS AddressOfIndex

DataDirectory A: Load config
 *.. safeseh.exe              a PE making use of SafeSEH (succeeding or not)
 **. safeseh_fly.exe          a PE modifying its HandlerTable on the fly before triggering an exception

 *.. ldrsnaps.exe             a PE enabling LoaderSnaps via its LoadConfig DataDirectory
 *.. ldrsnaps64.exe            64b version

 *.. ss63.exe                 a PE with a Subsystem 6.3 (which enforces a LoadConfig directory and a valid cookie)
 *.. ss63nocookie.exe         the same but with no cookie and GuardFlags set to IMAGE_GUARD_SECURITY_COOKIE_UNUSED


DataDirectory B: Bound imports
 *.. dllbound-ld.exe          dll loader with bound imports
 **. dllbound-redirld.exe     dll loader with corrupted bound imports to call unexpected API
 **. dllbound-redirldXP.exe   dll loader with corrupted bound imports to call an unexpected API from another DLL
      dllbound.dll             DLL with 2 exports (one normal one 'fake') to test imports binding
      dllbound2.dll            extra DLL to test corruption at dll level (different name, different timestamp)

DataDirectory D: Delay imports
 *.. delayimports.exe         PE with delay imports
 **. delaycorrupt.exe         PE with corrupted delay imports, all set to zero
 **. delayfake.exe            fake delay imports data obfuscation

DataDirectory E: COM Descriptor
 *.. dotnet20.exe             a 'compiled', dissected and manually rebuild, .Net 2.0 PE
 **. tinynet.exe              a tiny .Net PE - with only NumberOfRvaAndSizes=2, 4 streams...
 **. fakenet.exe              a PE with fake .NET EntryPoint, imports but no COM directory
 **. mscoree.exe              a non-managed PE with MSCOREE imports

DataFile DLLs (loaded via LoadLibraryEx with LOAD_LIBRARY_AS_DATAFILE parameter, not resolving imports or executing DLLMain)
 *** d_tiny.dll               a minimal DataFile DLL :only contains MZ, PE and 1 byte of e_lfanew
      d_tiny-ld.exe             loader
 *** d_nonnull.dll            a DataFile DLL containing no null byte
      d_nonnull-ld.exe          loader
 *** d_resource.dll           a DataFile DLL with working resources (most values set to FF while resources are usable)
      d_resource-ld.exe           loader

Special
 **. maxvals.exe              a PE with a maximal values in the headers
 **. standard.exe             a PE with a bit of everything, useful as a all-in-one tutorial PE 'crackme'.

 **. dosZMXP.exe              a non-PE EXE with ZM signature
 *** exe2pe.exe               a non-PE EXE whose DOS stubs patches itself back to PE and relaunch as PE
 *** hdrcode.exe              a PE which header is completely executed (to calculate a fibonacci number via FPU) - NO jump over header data !W8

 *** quine.exe                a working PE file, made entirely in assembly, with no need of a compiler, with its own source embedded, which it displays on execution, via 'typing' its own binary.

 **. fakeregs.exe             corrupting registers as much as possible, during TLS and EP
 **. fakeregslib.dll          loaded DLL corrupting registers as much as possible, during TLS and DllMain

 **. pdf.exe                  a tiny PE with a PDF, copying itself and launching itself under acrobat
 **. pdf_zip_pe.exe           see CorkaMiX

 *.. hdrdata.exe              a PE with data between header and first section

 **. sc.exe                    simple shellcode target

in progress:
     debug.exe                debug data directory
     no_dd64                  self-loading imports in 64 bits
