using BinaryProvider # requires BinaryProvider 0.4.0 or later

const forcecompile = get(ENV, "JULIA_SPECIALFUNCTIONS_BUILD_SOURCE", "false") == "true"

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get(filter(!isequal("verbose"), ARGS), 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libopenspecfun"], :openspecfun),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaMath/OpenspecfunBuilder/releases/download/v0.5.3-2"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) =>
        ("$bin_prefix/Openspecfun.v0.5.3.aarch64-linux-gnu.tar.gz",
         "37278d3b54f18a137d58306a98744d5ef43f814c4f6fa131194014febe043284"),
    Linux(:aarch64, :musl) =>
        ("$bin_prefix/Openspecfun.v0.5.3.aarch64-linux-musl.tar.gz",
         "cefcf2b5ed21aeb773948bc386c5ec960cbf47b5d8fd9f348daff3575f2c6307"),
    Linux(:armv7l, :glibc, :eabihf) =>
        ("$bin_prefix/Openspecfun.v0.5.3.arm-linux-gnueabihf.tar.gz",
         "e3fa98d8e8eea4e5df021cab860db330f43a3258a51d0e59961c3ffe7fa05a69"),
    Linux(:armv7l, :musl, :eabihf) =>
        ("$bin_prefix/Openspecfun.v0.5.3.arm-linux-musleabihf.tar.gz",
         "e8a27506bd2efd5dd85ee7cfd439156ac8684a629a4342926a09014742009faa"),
    Linux(:i686, :glibc) =>
        ("$bin_prefix/Openspecfun.v0.5.3.i686-linux-gnu.tar.gz",
         "aee7d9f3f848742565e8d99d17559598c25a55de681868ecdc0ca47a2eacb3ff"),
    Linux(:i686, :musl) =>
        ("$bin_prefix/Openspecfun.v0.5.3.i686-linux-musl.tar.gz",
         "a835fa77f1fb7562bc73da0fe327d219efac62ad27391b4ed7292c3493f4aa8d"),
    Windows(:i686) =>
        ("$bin_prefix/Openspecfun.v0.5.3.i686-w64-mingw32.tar.gz",
         "c3170f31a5a9e987383d6403592a625cc4b4111ac1102b9a80f67ecb95cab3e7"),
    Linux(:powerpc64le, :glibc) =>
        ("$bin_prefix/Openspecfun.v0.5.3.powerpc64le-linux-gnu.tar.gz",
         "7e6c0c94189f49dcbad70ee96244122fcf1fe37551de5c3d4c6328f683eaa53f"),
    MacOS(:x86_64) =>
        ("$bin_prefix/Openspecfun.v0.5.3.x86_64-apple-darwin14.tar.gz",
         "9a460562201c34d6b7e5a6b458471caf8e78b08f5c8bb9902931752311f62dd8"),
    Linux(:x86_64, :glibc) =>
        ("$bin_prefix/Openspecfun.v0.5.3.x86_64-linux-gnu.tar.gz",
         "0fa48e302326684dae1a77d6a30ee484f46cb540f859b536ff1e2ae132653764"),
    Linux(:x86_64, :musl) =>
        ("$bin_prefix/Openspecfun.v0.5.3.x86_64-linux-musl.tar.gz",
         "13f582d37b5e045684af2018a9cbb78caa9b41583d5b8eedb6d57b98dd61264e"),
    FreeBSD(:x86_64) =>
        ("$bin_prefix/Openspecfun.v0.5.3.x86_64-unknown-freebsd11.1.tar.gz",
         "689ea7e02bc6fa89d692bd7280a1852c0e7319d915b0a87d7f439b6b6bb2a487"),
    Windows(:x86_64) =>
        ("$bin_prefix/Openspecfun.v0.5.3.x86_64-w64-mingw32.tar.gz",
         "82316ed5b4d26c7aef93f77459a434ea5aeac55d27d9c2ea08c0b3d843c2208f"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key()) && !forcecompile
    url, tarball_hash = download_info[platform_key()]
    if !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
        unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
    end
    if unsatisfied
        rm(joinpath(@__DIR__, "usr", "lib"); force=true, recursive=true)
    end
end

if unsatisfied || forcecompile
    include("scratch.jl")
else
    # Write out a deps.jl file that will contain mappings for our products
    write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
end