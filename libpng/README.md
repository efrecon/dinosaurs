# Collection of Ancient libpng Releases

The scripts in this directory can be used to download, build and pack back into
compressed tar archives older versions of libpng. If missing, they will
automatically (temporary) download and build zlib as it is a required
dependency. The version downloaded is the one that was just made before the
libpng release. Downloading uses the SourceForge official [files] of the libpng
[project]. Building uses a Docker image and requires that your user is able to
build and run containers. GitHub workflow [automation] arranges to build the
latest minor versions of all library branches.

  [files]: https://sourceforge.net/projects/libpng/files/
  [project]: https://sourceforge.net/projects/libpng/
  [automation]: ../.github/workflows/libpng.yml
