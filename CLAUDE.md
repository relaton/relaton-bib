# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RelatonBib is a Ruby gem that implements the [BibliographicItem model](https://github.com/metanorma/relaton-models#bibliography-uml-models) for bibliographic reference management. It's part of the Relaton ecosystem and serves as the base library for other Relaton gems.

## Common Commands

```bash
# Install dependencies
bundle install

# Run all tests
bundle exec rake spec

# Run a single test file
bundle exec rspec spec/relaton_bib/bibliographic_item_spec.rb

# Run a specific test by line number
bundle exec rspec spec/relaton_bib/bibliographic_item_spec.rb:42

# Run linting
bundle exec rubocop

# Auto-fix linting issues
bundle exec rubocop -a

# Interactive console
bin/console
```

## Architecture

### Serialization Layer (lutaml-model)

The codebase uses [lutaml-model](https://github.com/lutaml/lutaml-model) for serialization. Each model class in `lib/relaton/bib/model/` inherits from `Lutaml::Model::Serializable` and declares attributes with XML/YAML/JSON mappings.

### Constant loading (autoload)

Model and converter constants are wired via Ruby `autoload` from a central manifest,
[lib/relaton/bib/model_autoload.rb](lib/relaton/bib/model_autoload.rb). This makes load order
irrelevant and avoids circular requires between mutually-referencing classes (e.g. `OrganizationType`
↔ `Subdivision`). **When adding a new model class, add an `autoload` entry to the manifest** rather
than a `require_relative` in a sibling file. The manifest also eagerly loads `lutaml/model`/`lutaml/xml`
and runs the `Lutaml::Model::Config.configure` block so the XML adapter is set regardless of which
class is referenced first. Exceptions that keep `require_relative`: files that only *reopen* an
already-defined module to add methods (the converter method-partials under
`lib/relaton/bib/converter/*/`), which `autoload` cannot express.

### Core Classes

**`Relaton::Bib::Item`** ([lib/relaton/bib/model/item.rb](lib/relaton/bib/model/item.rb)) - The main serialization class defining all bibliographic attributes and their XML mappings. Uses `ItemData` as its underlying model.

**`Relaton::Bib::ItemData`** ([lib/relaton/bib/item_data.rb](lib/relaton/bib/item_data.rb)) - The data container class that holds bibliographic data and provides conversion methods (`to_xml`, `to_yaml`, `to_bibtex`, `to_rfcxml`). This separation allows the same data to be serialized differently (bibitem vs bibdata).

**`Relaton::Bib::Bibitem`** and **`Relaton::Bib::Bibdata`** - Variants of `Item` with different XML root elements and attributes (bibitem excludes `ext`, bibdata excludes `id`).

### Component Models

Each bibliographic attribute has its own class in `lib/relaton/bib/model/`:

- `Title`, `LocalizedString`, `LocalizedMarkedUpString` - text with language/script
- `Contributor`, `Person`, `Organization` - contributors and affiliations
- `Docidentifier` - document IDs (DOI, ISBN, etc.)
- `Date` - publication dates with custom `StringDate` type
- `Relation` - related documents (circular reference with Item)
- `Ext` - extension data (doctype, ICS codes, structured identifiers)

### Parsing

- **`HashParserV1`** ([lib/relaton/bib/hash_parser_v1.rb](lib/relaton/bib/hash_parser_v1.rb)) - Converts legacy Hash/YAML format to `ItemData`
- **`Converter::BibXml`** ([lib/relaton/bib/converter/bibxml.rb](lib/relaton/bib/converter/bibxml.rb)) - Parses RFC BibXML format via `Relaton::Bib::Converter::BibXml.to_item`
- **lutaml-model native** - `Item.from_xml`, `Item.from_yaml`, `Item.from_json` handle current format

### Rendering

- **`Renderer::BibtexBuilder`** - Converts `ItemData` to BibTeX format
- **`Converter::BibXml`** - Converts `ItemData` to an `Rfcxml::V3` model object via
  `Relaton::Bib::Converter::BibXml.from_item`; call `to_xml` on the result (this is what
  `ItemData#to_rfcxml` does). Two output shapes share one class hierarchy:
  - `ToRfcxml` / `ToRfcxmlReferencegroup` (default) emit **BibXML**, the shape the Relaton
    data repositories publish. It keeps the RFC 7991-deprecated `<format>` element, so it
    must stay byte-compatible — every relaton data fetcher's `"bibxml"` format is
    `entry.to_rfcxml`. Do not change its output.
  - `ToRfcxmlV3` / `ToRfcxmlReferencegroupV3` (`v3: true`) subclass those and emit strict
    **RFC 7991**: no `<format>`, plus `<stream>`, `ascii*` attributes and `<refcontent>`.
    New v3-only behaviour belongs in the subclass, so the default path stays untouched by
    construction and `spec/relaton/bib/converter/bibxml_spec.rb` keeps passing unedited.
- **lutaml-model native** - `to_xml`, `to_yaml`, `to_json` via the serialization classes

### Usage Pattern

```ruby
# Parse from YAML
item = Relaton::Bib::Item.from_yaml(yaml_string)

# Parse from XML
item = Relaton::Bib::Bibitem.from_xml(xml_string)
item = Relaton::Bib::Bibdata.from_xml(xml_string)

# Parse from RFC XML
item = Relaton::Bib::Converter::BibXml.to_item(xml_string)

# Convert to different formats (returns string)
item.to_xml                    # as <bibitem>
item.to_xml(bibdata: true)     # as <bibdata>
item.to_yaml
item.to_bibtex
item.to_rfcxml                 # BibXML (what the data repos publish)
item.to_rfcxml(v3: true)       # strict RFC 7991 / xml2rfc v3
item.to_rfcxml(anchor: "ISO712", include_keywords: false)
```

## Code Style

- Follows Ribose OSS Ruby style guide (inherited via `.rubocop.yml`)
- Target Ruby version: 3.2+ (`required_ruby_version` in the gemspec, `TargetRubyVersion` in `.rubocop.yml`)
- Uses YARD documentation comments
