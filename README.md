# Dinosaurs

This project automates downloading and compiling older versions of various
tools. The intent is to be able to maintain a collection of automatically
compiled binaries/libraries through GitHub workflows. This project uses
workflows and matrix strategies to compile versions back in time for several
architectures.

## Supported Projects

Currently, the dinosaur project supports the following projects:

+ [tcl](./tcl/README.md)
+ [tk](./tk/README.md)
+ [libjpeg](./libjpeg/README.md)
+ [zlib](./zlib/README.md)
+ [libpng](./libpng/README.md)

## Releasing Strategy

Since this is about compiling old stuff, the release of these projects were made
a long time ago. This project maintains major releases for its sub-projects,
usually the last patch version of a major/minor pair. A compressed tarball
containing the binaries will be automatically uploaded to the release. In
practice, this release uses a tag, but the location of the tag in the git tree
is irrelevant.

## Generating Binaries

### Organisation

All projects have three scripts used during the building process. By default,
these scripts use the `output` directory to store source and results of
compilation.

+ `fetch.sh` will fetch the project from a reliable source, and at a given
  version.
+ `build.sh` will build the project, at the same version
+ `pack.sh` will generate a compressed tarball with the compiled artifacts (and
  relevant metadata such as manual pages, include files, etc.) at the same
  version.

### Wrapper

[`dino.sh`](./dino.sh) is a wrapper that will call all these scripts in turn,
for a given (known) project.

### Command Line Options and Input

All scripts can be controlled through a set of environment variables, all
started with `DINO_` or by command-line options -- these have precedence. Call
each script with the `-h` short option (long options also exist) to get targeted
help. Note that most scripts recognise a common set of options, worth to mention
here are:

+ `--version` to specify the version of the project to download, compile, pack,
  etc.
+ `--arch` to specify the architecture to compile for, e.g.
  `i386-unknown-linux-glibc`.

### Cleanup

To clean up, use the [`clean.sh`](./output/clean.sh) script in the `output`
directory. Give it a list of names of supported projects as arguments. When no
argument is given, all projects will be cleaned up.
