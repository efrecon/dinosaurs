# Collection of Ancient Tk Releases

The scripts in this directory can be used to download, build and pack back into
compressed tar archives older versions of Tk. If missing, they will
automatically (temporary) download and build Tcl as it is a required dependency.
Downloading uses the GitHub [mirror] of the Tcl/Tk project. Building uses a
Docker image and requires that your user is able to build and run containers.
GitHub workflow [automation] arranges to build the latest minor versions of the
8.x generation.

  [mirror]: https://github.com/tcltk/tk
  [automation]: ../.github/workflows/tk.yml
