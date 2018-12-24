CorkaMIX.exe is simultaneously a valid:
 * Windows Portable Executable binary
 * Adobe Reader PDF document
 * Oracle Java JAR (a CLASS inside a ZIP)/Python script
 * HTML page

it can be downloaded at http://code.google.com/p/corkami/downloads/list

sha256 2a9c7a16cdb3c3f2285afaf61072dd5e7cc022e97f351cad6234a13e5216f389

It serves no purpose, except proving that files format not starting at offset 0 are a bad idea.

It's 100% written by hand in x86 assembly, including ZIP, CLASS and PE structures.

to compile it, just run: 
	yasm -o corkamix.exe corkamix.asm

For extra fun, the various parts of the file have been shuffled around: for example, the PDF starts in the PE header, and finishes in the constant pool of the CLASS, inside the ZIP (without compression).

As Java doesn't check the validity of the ZIP (JAR)'s CRCs, they have been cleared, on purpose (this makes the ZIP pseudo-invalid).

the PE itself is sectionless, with a collapsed imports structure (check http://pe.corkami.com for more information)

the PE code contains a few 'undocumented' opcodes (check http://x86.corkami.com for more information)

the PDF is Adobe-compatible only: it has an incomplete signature, no xref, etc... (check http://pdf.corkami.com for more information)

if the file is a valid ZIP with no appended data, running it with python will handle it as an EGG, therefore it will look for a _main_.py inside the zip instead of just executing the file as a PY.
Therefore, appending a single byte will make it work as a valid PY.
However, this will prevent Java to handle the file as a JAR correctly.

Unlike any other format, it needs to be renamed as .HTM(L) to work as such.

More formats could be added inside the ZIP, but this offers no technical challenge.

No widespread image format is allowed to start beyond offset 0 (EMF, GIF, JPG, PNG, TIF, TGA, PCX, BMP...) so none of them can't be included.

Ange Albertini (@ange4771)
BSD Licence
August 2012