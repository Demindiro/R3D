.SUFFIXES:

DC := dmd
UNAME := $(shell uname -s)

sources   := $(shell find source -name '*.d')
includes  := source/ $(shell find source/examples -type d)
includes  := $(includes:%=-I%)
ifeq ($(UNAME),Darwin)
	libraries := -L-lglfw -L-framework -LOpenGL
endif
ifeq ($(UNAME),Linux)
	libraries := -L-lglfw -L-lOpenGL
endif

obj_output := $(sources:source/%.d=build/obj/%.o)
doc_output := $(sources:source/%.d=doc/%.html)
cov_output := $(sources:source/%.d=build/cov/%)


override DC += $(DFLAGS) $(includes)


default: example

example: build/example

doc: $(doc_output)

cov: $(cov_output)


build/obj/%.o: source/%.d
	@echo '  DMD   $<'
	@$(DC) $< -c -of=$@

doc/%.html: source/%.d
	@echo '  DOC   $<'
	@$(DC) $< -D -Df=$@ -o-

build/cov/%: source/%.d $(obj_output)
	@echo '  COV   $<'
	@$(DC) $(filter-out $(subst cov,obj,$@).o,$(obj_output)) $(libraries) $< \
		-cov -unittest -of=$@

build/example: $(obj_output)
	@echo '  DMDLD'
	@$(DC) $(obj_output) $(libraries) -of=$@
