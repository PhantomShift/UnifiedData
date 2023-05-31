# UnifiedData
Very very simple module for managing trivial data that is shared from the server to the client.
The use-case is for when the server has a large but mostly non-volatile amount of data that needs to be synced
to all clients and inconvenient to facilitate outside of code.

## Documentation
Documentation can be found at https://phantomshift.github.io/UnifiedData/

## Usage
Intended to be placed in ReplicatedStorage, but should work as long as the same ModuleScript is visible from both the Server and Client.

You can either build the model yourself or grab the `rbxm` from this repo (which should be the same as building it yourself if I haven't been lazy).
Build artifacts can be found in the [GitHub Actions tab](https://github.com/PhantomShift/UnifiedData/actions).

Alternatively, the code can be copied manually. If doing so, ensure that the following hierarchy and names is recreated:
 - UnifiedData `ModuleScript`
    - Client `ModuleScript`
    - DataFolder `Folder`
    - Server `ModuleScript`
    - Shared `ModuleScript`

### Building
UnifiedData depends on [rojo](https://github.com/rojo-rbx/rojo) for building from source.
```bash
rojo build -o "UnifiedData.rbxmx"
```