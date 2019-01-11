.SUFFIXES:

default:
	dmd src/*.d src/*/*.d -Isrc/ -od=build/obj -of=build/engine -L-lglfw -L-framework -LOpenGL -g -debug
