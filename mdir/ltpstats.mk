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

SRC_ltpstats := $(SRC_LTP)/ltpstats.c \
	$(SRC_libltp) \
	$(SRC_libici)

ltpstats:
	$(GCC) $(CFLAG) -I$(INC) $(SRC_ltpstats) \
	$(PLATFORM) \
	-o $(OUT_BIN)/ltpstats
