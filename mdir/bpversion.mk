SRC_bpversion := \
	$(SRC_BPV7)/bpversion.c

bpversion:
	$(GCC) $(CFLAG) -I$(INC) $(SRC_bpversion) \
	$(PLATFORM) \
	-o $(OUT_BIN)/bpversion
