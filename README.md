# Pandoc Cookbook

This is a WIP project to typeset a recipe book using Pandoc as a front-end for LaTeX.
Recipes and document layout are defined entirely in YAML and are used to populate a tufte-book LaTeX template.

## Recipe format

The recipe format is loosely based on the [Open Recipe Format](https://open-recipe-format.readthedocs.io/en/latest/index.html) with the following differences (subject to further change):

 - Additional optional fields `cookware`, `type`, and `categories` are added to each recipe.
   Recipes will be indexed by type and category tags when the output document is produced.

 - The field `recipe_name` is simply called `name` and `recipe_uuid` is unsupported.

 - Recipe sources are represented differently:

   ```yml
   source: # All fields optional.
     url: https://example.com
     book:
       title: Book title
       authors:
        - first: First name
          last: Last name
     other: Other or additional information on the source.
   ```

 - The `oven_time` field is not used.
   This is far too restrictive to account for the many things one may want to time while cooking.
   Instead, a `times` block is used as follows:

   ```yml
   times:
	 - name: Cook time
	   hh: 1           # hours (optional)
	   mm: 30          # minutes (optional)
	   ss: 15          # seconds (optional)
   ```

 - A new `oven` block is introduced, which can identify whether a convection fan is used, what the
 starting temperature should be, and optionally what unit the oven temp is described by.

   ```yml
   oven:
     fan: on  # on, off, or false to omit rendering
     temp: 375
     degrees: F # Assumed to F (Fahrenheit) if omitted, but can be overridden.
   ```

 - The `ingredient` dict structure is slightly simplified.
   Substitutions are represented differently.
   A full example follows.

   ```yml
   ingredients:
     - name: Carrot
	   amount: 1
	   unit: ea.
	   processing: sliced
	   notes: The tastiest root vegetable.
	   substitutions:
	     hint: Pick one or more
         list: # A list of ingredients (as above) without the substitutions field.
           - name: Potato
           - name: Turnip
           - name: Onion
   ```

 - The `steps` list is split into `prep` and `method` lists.
   Hazard control points are not currently supported.

## Template use

The included Pandoc LaTeX template is based on the tufte-book class which is usually included in LaTeX distributions.
This book class makes extensive use of margin notes, which I like for recipes.

There are however several issues with this class, and at the moment several compilation steps are required to create a good output PDF.
It is also a highly specialized template, which does not adhere to all of the expectations of the default Pandoc LaTeX template.

Three types of YAML files are used in this template.

 1. **metadata.yml** contains document metadata.
    Title, subtitle, author information, copyright information, and some other directives for typesetting the book.

    This file must begin with a YAML document stream delimiter `---`
 2. **layout.yml** lays out the recipes into chapters.
    A chapter currently consists of a `name` string and `recipes` list.
    To keep the source files organized appropriately, YAML anchors are used to refer to the recipes.

    This file must end with a YAML document stream terminator `...`

 3. **recipes** are defined in their own YAML files according to the recipe format above.
    There is nothing that restricts having multiple recipes per file, or even from including the recipes directly in the layout.yml file, but for simplicity, the examples in this repository define one recipe per file as a named dict.
    Markdown and LaTeX can be written directly in the YAML and will be rendered appropriately.

The included Makefile will:

 1. Concatenate `metadata.yml`, all recipe YAML files, and `layout.yml` in this order.
 1. The resulting YAML document is converted to JSON, then used as a Pandoc metadata-file to fill in the tufte LaTeX template.
    The conversion to JSON is important since Pandoc's metadata file processing doesn't seem to respect the merge dict key (`<<`).
 1. Produce an output `.tex` file.
 1. Compile the tex file to a PDF using `latexmk`

A full example of a recipe book is included in the `example` directory of this repository.

## Dependencies

To use this template, you'll need:

 - GNU Make
 - TeXLive with `pdflatex` and `latexmk` (xelatex is not currently supported).
 - Pandoc v2.11 or higher.
 - `yaml2json` (get it with `npm install -g yamljs`).

## License

The template and recipes included in this repository are licensed under the CC-BY-NC-SA 3.0 International license.

## Related works

If you want to produce individual PDF documents for each YAML recipe, check out [iwismer/pandoc-recipe-template](https://github.com/iwismer/pandoc-recipe-template) which inspired this project.
