import random
import sys

if len(sys.argv) == 1:
	print("Please provide a shellcode string!")
	quit()

decode = [0xeb,0x1b,0x5f,0x48,0x8d,0x77,0x03,0xa4,0x48,0x83,
          0xee,0x03,0xa4,0x48,0x83,0xc6,0x04,0x8b,0x46,0xfe,
          0x3d,0x78,0x56,0x34,0x12,0x75,0xec,0xeb,0x05,0xe8,
          0xe0,0xff,0xff,0xff]

marker = [0x78, 0x56, 0x34, 0x12]

random.seed()
bChunks = sys.argv[1].split(',')

if len(bChunks) < 2:
	print("Shellcode should be in 0xXX,0xXX,0xXX format!")
	quit()

# Ensure even count of payload bytes
if len(bChunks)%2 != 0:
	bChunks.append(random.randint(1,255))

print("")

# Add decode header
for d in decode:
	sys.stdout.write("0x{0:02x},".format(d))

# Insert lead in byte
sys.stdout.write("0x{0:02x},".format(random.randint(1,255)))

# Do the Twist 'n Split
while len(bChunks) != 0:
	a = bChunks.pop(0)
	b = bChunks.pop(0)
	c = random.randint(1,255)
	sys.stdout.write("0x{0:02x},".format(int(b,16)))
	sys.stdout.write("0x{0:02x},".format(c))
	sys.stdout.write("0x{0:02x},".format(int(a,16)))

# Insert end marker
for m in marker:
	sys.stdout.write("0x{0:02x},".format(m))

print("\n")

# Repeat in \x format
bChunks = sys.argv[1].split(',')

# Ensure even count of payload bytes
if len(bChunks)%2 != 0:
	print
	bChunks.append(random.randint(1,255))

# Add decode header
for d in decode:
	sys.stdout.write("\\x{0:02x}".format(d))

# Insert lead in byte
sys.stdout.write("\\x{0:02x}".format(random.randint(1,255)))

# Do the Twist 'n Split
while len(bChunks) != 0:
	a = bChunks.pop(0)
	b = bChunks.pop(0)
	c = random.randint(1,255)
	sys.stdout.write("\\x{0:02x}".format(int(b,16)))
	sys.stdout.write("\\x{0:02x}".format(c))
	sys.stdout.write("\\x{0:02x}".format(int(a,16)))

# Insert end marker
for m in marker:
	sys.stdout.write("\\x{0:02x}".format(m))

print("\n")

