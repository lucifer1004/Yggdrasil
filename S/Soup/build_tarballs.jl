using BinaryBuilder
using Pkg: PackageSpec

name = "Soup"
version = v"3.2.1"

# Collection of sources required to build Soup
sources = [
    ArchiveSource("https://download.gnome.org/sources/libsoup/$(version.major).$(version.minor)/libsoup-$(version).tar.xz",
                  "b1eb3d2c3be49fbbd051a71f6532c9626bcecea69783190690cd7e4dfdf28f29"),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/libsoup-*/

mkdir build_glib && cd build_glib
meson --cross-file="${MESON_TARGET_TOOLCHAIN}" \
    --buildtype=release \
    ..
ninja -j${nproc}
ninja install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products = [
    LibraryProduct(["libsuop"], :libsoup),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    # Host gettext needed for "msgfmt"
    HostBuildDependency("Gettext_jll"),
    Dependency("Glib_jll"; compat="2.74.0"),
    Dependency("SQLite_jll"),
    Dependency("nghttp2_jll"),
    Dependency("brotli_jll"),
    Dependency("libpsl_jll"),
    Dependency("LibUnwind_jll"),
    Dependency(PackageSpec(; name = "GlibNetworking_jll",  uuid = "99fd4003-298c-58dc-a8c7-c8e9475755a1", url = "https://github.com/lucifer1004/GlibNetworking_jll.jl.git")),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6")
