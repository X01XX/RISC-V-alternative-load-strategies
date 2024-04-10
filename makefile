OBJS = main.o tools.o

main: $(OBJS)
	ld -o main $(OBJS)

%.o : %.S
	as $< -o $@

