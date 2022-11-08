# Readme

## Developer instructions

### Running tests

Using CMake

```sh
cd ./tests/
cmake -B ./build/ -S .
cmake --build ./build/
ctest --test-dir ./build/
```

Using QtCreator

- Open `./CMakeLists.txt`
- Choose a QT kit to run the tests (e.g. `Desktop Qt 5.14.2 GCC 64bit`)
  - If on apple silicon and using `Qt5.14` set `CMAKE_OSX_ARCHITECTURES` env var to `x86_64`
- Set `%{sourceDir}/tests` as Working Directory for the `TestStatusQ` target
- In the *Test Results* panel choose Run All Tests or just run the *TestStatusQ* target

## TODO

- [ ] TestHelpers library
- [ ] Consolidate and integrate with https://github.com/status-im/desktop-ui-tests
- [ ] Separate projects per scope: TestControls, TestComponents
