.SUFFIXES:

sources   = source/r3d/*.d source/r3d/*/*.d
headers   = -Isource/ -Isource/*/ -Isource/*/*/
libraries = -L-lglfw -L-framework -LOpenGL
DC = dmd $(sources) $(headers) -od=build/obj -of=build/engine $(libraries)


default: test

test:
	$(DC) examples/main.d examples/*/*.d -g -debug

release:
	$(DC) -O -release -inline
