all:
		mkdir -p tools
		$(CC) $(LDFLAGS) -o tools/fillmem src/fillmem.c
		$(CC) $(LDFLAGS) -o tools/procloop src/procloop.c -lm
