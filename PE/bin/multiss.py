import pefile
pe = pefile.PE("multiss.exe")

pe.OPTIONAL_HEADER.Subsystem = pefile.SUBSYSTEM_TYPE["IMAGE_SUBSYSTEM_NATIVE"]
pe.OPTIONAL_HEADER.CheckSum = pe.generate_checksum()
pe.write("multiss_drv.sys")

pe.OPTIONAL_HEADER.Subsystem = pefile.SUBSYSTEM_TYPE["IMAGE_SUBSYSTEM_WINDOWS_GUI"]
pe.write("multiss_gui.exe")

pe.OPTIONAL_HEADER.Subsystem = pefile.SUBSYSTEM_TYPE["IMAGE_SUBSYSTEM_WINDOWS_CUI"]
pe.write("multiss_con.exe")
