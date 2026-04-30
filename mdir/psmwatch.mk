# Include ICI Source
include $(MDIR)/libici.mk

ifndef LIBICI_INCLUDED
$(error libici.mk is not found or not included, cannot build.)
endif

SRC_psmwatch := \
	$(SRC_ICI)/psmwatch.c \
	$(SRC_libici)

psmwatch:
	$(GCC) $(CFLAG) -I$(INC) $(SRC_psmwatch) \
	$(PLATFORM) \
	-o $(OUT_BIN)/psmwatch
