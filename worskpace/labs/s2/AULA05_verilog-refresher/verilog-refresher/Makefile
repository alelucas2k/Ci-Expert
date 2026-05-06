# BLOCK    ?= adder32

# # RTL
# RTL_FILES = rtl/$(BLOCK).v

# # TB
# TB_FILES  = tb/tb_$(BLOCK).v

# # VCS
# FSDB_FILE = $(BLOCK)
# VCS_KDB   = -kdb 
# VCS_DEBUG = -debug_access+all
# VCS_FLAGS = -full64 -l ./vcs_logger.log $(VCS_KDB) $(VCS_DEBUG) -timescale=1ns/1ps

# vcs:
# 	vcs $(VCS_FLAGS) $(RTL_FILES) $(TB_FILES) 

# run: 
# 	./simv +FSDB=$(BLOCK).fsdb

# gui:
# 	./simv -gui

# verdi_wf:
# 	verdi -play cmd/$(BLOCK).cmd

# verdi_wf_easy:
# 	verdi -nologo -ssf $(BLOCK).fsdb

# verdi_sc:
# 	verdi -play schematic-top.cmd

# vcs_clean:
# 	rm -rf csrc *.daidir simv *.log *.key *.conf *.rc *.fsdb verdiLog/

# --- Variáveis Gerais ---
BLOCK     ?= adder32
RTL_FILES  = rtl/$(BLOCK).sv
TB_FILES   = tb/tb_$(BLOCK).sv

# --- Configurações VCS / VERDI (Antigas) ---
FSDB_FILE  = $(BLOCK)
VCS_KDB    = -kdb 
VCS_DEBUG  = -debug_access+all
VCS_FLAGS  = -full64 -l ./vcs_logger.log $(VCS_KDB) $(VCS_DEBUG) -timescale=1ns/1ps

# --- Configurações Icarus Verilog (Novas) ---
IV_COMPILER = iverilog
IV_SIMULATOR = vvp
IV_FLAGS    = -g2012 -DICARUS # Suporte para SystemVerilog
IV_OUT      = $(BLOCK).out
VCD_FILE    = $(BLOCK).vcd

# ==============================================================================
# REGRAS VCS & VERDI
# ==============================================================================
vcs:
	vcs $(VCS_FLAGS) $(RTL_FILES) $(TB_FILES) 

run: 
	./simv +FSDB=$(BLOCK).fsdb

gui:
	./simv -gui

verdi_wf:
	verdi -play cmd/$(BLOCK).cmd

verdi_wf_easy:
	verdi -nologo -ssf $(BLOCK).fsdb

verdi_sc:
	verdi -play schematic-top.cmd

# ==============================================================================
# REGRAS ICARUS VERILOG & GTKWAVE
# ==============================================================================
iv_compile:
	$(IV_COMPILER) $(IV_FLAGS) -o $(IV_OUT) $(RTL_FILES) $(TB_FILES)

iv_run: iv_compile
	$(IV_SIMULATOR) $(IV_OUT)

iv_wave:
	gtkwave $(VCD_FILE)

iv_all: iv_compile iv_run iv_wave


# ==============================================================================
# LIMPEZA
# ==============================================================================
clean: vcs_clean iv_clean

vcs_clean:
	rm -rf csrc *.daidir simv *.log *.key *.conf *.rc *.fsdb verdiLog/

iv_clean:
	rm -rf  *.out *.vcd