# Dinosaurs

This project automates downloading and compiling older versions of various
tools. The intent is to be able to maintain a collection of automatically
compiled binaries/libraries through GitHub workflows (TBD).

For the time being, you can try compiling tcl. The implementation uses the
GitHub mirror and the ability to automatically download a version of a
repository at a given tag as a compressed tar file.

To download and compile the default `8.0.5` version -- which is 25 years old,
run the following from the root directory of this project. This requires a
working Docker environment and the ability for your user to create containers.

```shell
./tcl/fetch.sh
./tcl/build.sh
```

The version can be passed as an argument to the scripts, so you could try
another version (untested, unlikely to work at this point). You can also build
for other architectures, for example, try specifying `--arch=linux-i386` as an
option to the build script.
