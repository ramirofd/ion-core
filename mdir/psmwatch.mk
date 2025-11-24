SRC_psmwatch := \
	$(SRC_ICI)/psmwatch.c \
	$(SRC_ICI)/platform.c \
	$(SRC_ICI)/platform_sm.c \
	$(SRC_ICI)/ion_network.c \
	$(SRC_ICI)/memmgr.c \
	$(SRC_ICI)/psm.c \
	$(SRC_ICI)/smlist.c \
	$(SRC_ICI)/sptrace.c

psmwatch:
	$(GCC) $(CFLAG) -I$(INC) $(SRC_psmwatch) \
	$(PLATFORM) \
	-o $(OUT_BIN)/psmwatch
