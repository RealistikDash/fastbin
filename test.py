from fastbin.writer import BinaryWriter

a = BinaryWriter()
for _ in range(100):
    a.write_u16(0xFFFF)

print("done")
