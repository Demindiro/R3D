.SUFFIXES:

sources = source/*.d source/r3d/*.d source/r3d/*/*.d
headers = -Isource/ -Isource/*/ -Isource/*/*/

default:
	dmd $(sources) $(headers) -od=build/obj -of=build/engine -L-lglfw -L-framework -LOpenGL -g -debug
