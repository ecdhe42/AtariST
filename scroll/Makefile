VASM_FLAGS=-Ftos -devpac -spaces

all: ascroll1.tos bscroll1.tos ascroll2.tos ascroll3.tos ascroll4.tos ascroll5.tos

ascroll1.tos: scroll1.s genmicros.pi1
	vasmm68k_mot $(VASM_FLAGS) scroll1.s -o $@

bscroll1.tos: scroll1b.s genmicros.pi1
	vasmm68k_mot $(VASM_FLAGS) scroll1b.s -o $@

ascroll2.tos: scroll2.s scroll2_tilemap.s goldrunner_screen.bin goldrunner_rsc.bin
	vasmm68k_mot $(VASM_FLAGS) scroll2.s -o $@

scroll2_tilemap.s: goldrunner.tmx
	python create_scroll2_tilemap.py

ascroll3.tos: scroll3.s scroll3_row_0shift.s scroll3_row_1shift.s scroll3_row_2shift.s genesis_rsc.bin
	vasmm68k_mot $(VASM_FLAGS) scroll3.s -o $@

ascroll4.tos: scroll4.s AtariST.pi1
	vasmm68k_mot $(VASM_FLAGS) scroll4.s -o $@

ascroll5.tos: scroll5.s AtariST.pi1
	vasmm68k_mot $(VASM_FLAGS) scroll5.s -o $@

clean:
	rm -f ascroll1.tos
	rm -f ascroll1b.tos
	rm -f ascroll2.tos
	rm -f ascroll3.tos
	rm -f ascroll4.tos
