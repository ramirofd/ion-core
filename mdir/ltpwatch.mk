# Include ICI Source
include $(MDIR)/libici.mk

# test if inclusion is successful
ifndef LIBICI_INCLUDED
$(error libici.mk is not found or not included, cannot build.)
endif

# Include LTP Source
include $(MDIR)/libltp.mk

# test if inclusion is successful
ifndef LIBLTP_INCLUDED
$(error libltp.mk is not found or not included, cannot build.)
endif

SRC_ltpwatch := $(SRC_LTP)/ltpwatch.c \
	$(SRC_libltp) \
	$(SRC_libici)

ltpwatch:
	$(GCC) $(CFLAG) -I$(INC) $(SRC_ltpwatch) \
	$(PLATFORM) \
	-o $(OUT_BIN)/ltpwatch
