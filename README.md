# Knowledge Graph Construction

Challenge: https://zenodo.org/records/11577087

## Basic setup

Implementation of the RML Mapper is going to rely on test-cases for compliance
checks, which are contained in corresponding RML modules.

Each RML module is defined in a separate repository:

https://github.com/kg-construct/rml-core/
* [RML-Core](https://github.com/kg-construct/rml-core) 
* [RML-IO](https://github.com/kg-construct/rml-io)
* [RML-CC](https://github.com/kg-construct/rml-cc)
* [RML-FNML](https://github.com/kg-construct/rml-fnml)
* [RML-Star](https://github.com/kg-construct/rml-star)

These modules are included as Git submodules, therefore this repository has to
be cloned correspondingly:

```sh
git clone https://github.com/achmutov/knowledge-graph-construction --recurse-submodules --shallow-submodules
```

## Data analysis

1. Enter `viz` directory:

```sh
cd viz
```

2. Run jupyter notebook:

```sh
uv run --locked jupyter notebook index.ipynb
```
