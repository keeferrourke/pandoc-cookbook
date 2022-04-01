SHELL = /bin/bash

.SUFFIXES:
.SUFFIXES: .md .yml .jpg .png .svg .pdf .yaml

OUTPUT_DIR = out
DOCNAME = 'recipes.pdf'
METADATA = metadata.yml
LAYOUT = layout.yml
RECIPES = $(wildcard recipes/*.yml) $(wildcard recipes/*.yaml)
BODY = body.md
SRC_FILES = $(METADATA) $(RECIPES) $(LAYOUT)


TEMPLATE = template/tufte.latex

.PHONY: pdf tex yaml clean

pdf: tex
	@latexmk -pdf -cd -f $(OUTPUT_DIR)/$(subst pdf,tex,$(DOCNAME))

tex: $(SRC_FILES) $(OUTPUT_DIR) $(OUTPUT_DIR)/build.json
	@pandoc -o $(OUTPUT_DIR)/$(subst pdf,tex,$(DOCNAME)) \
		--metadata-file="$(OUTPUT_DIR)/build.json" \
		-f markdown \
		-t latex \
		--template="$(TEMPLATE)" \
		body.md

# Pandoc 2.11's YAML metadata file doesn't appear to respect the "<<:" merge key.
# As a work-around, we can convert to JSON and then use the JSON as the metadata-file.
$(OUTPUT_DIR)/build.json: yaml
	@yaml2json -i2 -p -s $(OUTPUT_DIR)/build.yml 2>&1 1>/dev/null

yaml: $(SRC_FILES) $(OUTPUT_DIR)
	@awk 'FNR==1{print ""}1' $(SRC_FILES) > $(OUTPUT_DIR)/build.yml

$(OUTPUT_DIR):
	-@mkdir $(OUTPUT_DIR)

clean:
	-@rm -r $(OUTPUT_DIR)

print-%:
	@echo $* = \"$($*)\"
