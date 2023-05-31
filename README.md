# UnifiedData
Very very simple module for managing trivial data that is shared from the server to the client.
The use-case is for when the server has a large but mostly non-volatile amount of data that needs to be synced
to all clients and inconvenient to facilitate outside of code.

## Documentation
Most of the relevant code in this module is documented, meant to be parsed by [moonwave](https://github.com/evaera/moonwave).
However at the moment I have not set up any infrastructure for hosting it anywhere.
Reading the source code should be good enough by nature of how much is written for moonwave to parse,
and there is an [example](./docs/intro) in `docs/intro.md`, but if you desire something more human-readable,
you can use moonwave and run `moonwave dev` for a generated documentation site.

## Usage
Intended to be placed in ReplicatedStorage, but should work as long as the same ModuleScript is visible from both the Server and Client.

You can either build the model yourself or grab the `rbxm` from this repo (which should be the same as building it yourself if I haven't been lazy).
Build artifacts can be found in the [GitHub Actions tab](https://github.com/PhantomShift/UnifiedData/actions).

Alternatively, the code can be copied manually. If doing so, ensure that the following hierarchy and names is recreated:
 - [UnifiedData](./src/init) `ModuleScript`
    - [Client](./src/Client) `ModuleScript`
    - DataFolder `Folder`
    - [Server](./src/Server) `ModuleScript`
    - [Shared](./src/Shared) `ModuleScript`

### Building
UnifiedData depends on [rojo](https://github.com/rojo-rbx/rojo) for building from source.
```bash
rojo build -o "UnifiedData.rbxmx"
```