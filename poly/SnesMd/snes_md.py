with open("2048_nomus.bin", "rb") as f:
    md = f.read()
with open("sprite.smc", "rb") as f:
    snes = f.read()

d = md[0:0x200] + snes[0x200:0x460] + md[0x460:0x4CD8] + snes[0x4CD8:]
with open("snes_md.bin", "wb") as f:
    f.write(d)
