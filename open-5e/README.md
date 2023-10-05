# Open 5E

[Open 5E](https://open5e.com/) is a repository of 5E-compatible sources, including character options, spells, and monsters.

# The Problem

There is a multitude of sources for 5E-compatible content out there licensed under the OGL 1.0a. Some of it lives in parseable JSON, but that may or may not be compatible with the Alchemy RPG API.

# This Solution

This is a set of tools that uses the [Open 5E API](https://api.open5e.com/) and converts the JSON into a format supported by [Alchemy RPG's](https://alchemyrpg.com/) importers.

# Usage

These tools assume some working knowledge of the command line and availability of [jq](https://jqlang.github.io/jq/) in your computer's path.

## Monsters

Save a monster to a file:

`./monsters/convert.sh <monster-slug> > output.json`

From there, you can import them into Alchemy as an NPC.
