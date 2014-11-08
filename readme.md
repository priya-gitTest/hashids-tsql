# Hashids
A small set of TSQL functions to generate YouTube-like hashes from one or many numbers. 
Use hashids when you do not want to expose your database ids to the user.

[http://www.hashids.org/](http://www.hashids.org/)

## What is it?

hashids (Hash ID's) creates short, unique, decryptable hashes from unsigned integers.

This project is a port to TSQL of the other projects found via [http://www.hashids.org/](http://www.hashids.org/).
The .NET and Javascript versions of Hashids are the primary reference projects for this port.

## Status

The SQL functions generated by hashids-tsql can currently encode numbers, but not decode them. The mssql database 
project (called HashidsTsql) contains 3 functions: consistentShuffle, encode1 and hash. To generate a new encode1 
function with your custom salt, use the hashids-tsql generator.

## TSQL Function Naming

TSQL does not have function overloading, so the single `encode` function that is common in other hashids.org libraries
is instead represented here as a set of `encode` functions with slight variations in name, declaration and possibly even
return value.

The basic forms of `encode` for TSQL are:

- `encode(int) string`
- `encode(int, int) string`
- `encode(table) string`

In TSQL, the `encode` functions that take 1 or 2 integers will be much more useful than the one that takes a table
because typically, you don't want to construct a table variable just to pass 1 or 2 integers into a function.
   
## TODO

- Rename functions to follow new pattern: `encode1,2,3,Split,Table ... encode1A,2A,3A,SplitA,TableA` where the functions ending in A return `varchar`.
- Create `encode2` which encodes 2 numbers, so that each table can have it's own unique set of hashes.
- Create `encode-A` functions that return `varchar` instead of `nvarchar`.
- Create TSQL functions for decoding and integrate them into the hashids-tsql generator.
- See other minor technical TODO items in hashids-tsql/app.js.