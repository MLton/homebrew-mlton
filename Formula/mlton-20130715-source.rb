
# MLton is a self-hosting compiler for Standard ML.
# In order to build from source, this formula uses the corresponding
# upstream binary release to bootstrap.

class Mlton20130715Source < Formula
  desc "Whole-program, optimizing compiler for Standard ML"
  homepage "http://mlton.org"
  url "https://downloads.sourceforge.net/project/mlton/mlton/20130715/mlton-20130715.src.tgz"
  version "20130715"
  sha256 "215857ad11d44f8d94c27f75e74017aa44b2c9703304bcec9e38c20433143d6c"

  depends_on "gmp"

  # The corresponding upstream binary release used to bootstrap.
  resource "bootstrap" do
    url "https://downloads.sourceforge.net/project/mlton/mlton/20130715/mlton-20130715-2.amd64-darwin.gmp-static.tgz"
    sha256 "16a6d4e300f45f4af094692cf8033390e4634fa4c072caf6e9c288234100ad22"
  end

  # The upstream source release hard codes common locations for GMP;
  # on darwin, these include '/opt/local' (MacPorts) and '/sw' (Fink).
  # Replace these with placeholders for the Homebrew GMP location.
  patch :DATA

  def install
    # Finish configuring source release with Homebrew GMP location.
    inreplace "bin/mlton-script", "gmpHomebrewCCOpts=''", "gmpHomebrewCCOpts='-I#{Formula["gmp"].opt_prefix}/include'"
    inreplace "bin/mlton-script", "gmpHomebrewLinkOpts=''", "gmpHomebrewLinkOpts='-L#{Formula["gmp"].opt_prefix}/lib'"
    inreplace "runtime/Makefile", "GMP_HOMEBREW_XCFLAGS :=", "GMP_HOMEBREW_XCFLAGS := -I#{Formula["gmp"].opt_prefix}/include"

    # Import the corresponding upstream binary release to 'bootstrap'.
    bootstrap = buildpath/"bootstrap"
    bootstrap_bin = bootstrap/"usr/local/bin"
    bootstrap_lib = bootstrap/"usr/local/lib"
    mkdir bootstrap
    resource("bootstrap").stage(bootstrap/"usr")
    # The binary release assumes that the MLton support files are in
    # '/usr/local/lib/mlton' and that GMP is in '/usr/local',
    # '/opt/local' (MacPorts), or '/sw' (Fink).
    # Would like to patch/inreplace the
    # 'bootstrap/usr/local/bin/mlton' script as is done above for the
    # source release, but the Homebrew patch API does not support
    # patching external resources.  Since the binary and source
    # releases correspond, the 'bootstrap/usr/local/bin/mlton' script
    # is identical to the (original, un-patched/un-inreplaced)
    # 'bin/mlton-script', modulo a 'lib=...' that determines the
    # location of the MLton support files.  Therefore, use the
    # (patched/inreplaced) 'bin/mlton-script' for the
    # 'bootstrap/usr/local/bin/mlton' script, updating 'lib=...' to
    # the location of the bootstrap MLton support files.
    cp "bin/mlton-script", bootstrap_bin/"mlton"
    inreplace bootstrap_bin/"mlton", /^lib=.*/, "lib='#{bootstrap_lib}/mlton'"
    chmod "a+x", bootstrap_bin/"mlton"
    ENV.prepend_path "PATH", bootstrap_bin

    ENV.deparallelize
    system "make", "all-no-docs"
    system "make", "install-no-docs", "DESTDIR=", "PREFIX=#{prefix}", "MAN_PREFIX_EXTRA=/share"
  end

  test do
    (testpath/"hello.sml").write <<-'EOS'.undent
      val () = print "Hello, Homebrew!\n"
    EOS
    system "#{bin}/mlton", "hello.sml"
    assert_equal "Hello, Homebrew!\n", `./hello`
  end
end

__END__
diff --git a/bin/mlton-script b/bin/mlton-script
index ed4cc38..dd0cc10 100644
--- a/bin/mlton-script
+++ b/bin/mlton-script
@@ -82,16 +82,8 @@ doit () {
 
 # The darwin linker complains (loudly) about non-existent library
 # search paths.
-darwinLinkOpts=''
-if [ -d '/usr/local/lib' ]; then
-        darwinLinkOpts="$darwinLinkOpts -L/usr/local/lib"
-fi
-if [ -d '/opt/local/lib' ]; then
-        darwinLinkOpts="$darwinLinkOpts -L/opt/local/lib"
-fi
-if [ -d '/sw/lib' ]; then
-        darwinLinkOpts="$darwinLinkOpts -L/sw/lib"
-fi
+gmpHomebrewCCOpts=''
+gmpHomebrewLinkOpts=''
 
 doit "$lib" \
         -ar-script "$lib/static-library"                         \
@@ -106,10 +98,7 @@ doit "$lib" \
         -target-cc-opt alpha                                     \
                 '-mieee -mbwx -mtune=ev6 -mfp-rounding-mode=d'   \
         -target-cc-opt amd64 '-m64'                              \
-        -target-cc-opt darwin                                    \
-                '-I/usr/local/include
-                 -I/opt/local/include
-                 -I/sw/include'                                  \
+        -target-cc-opt darwin "$gmpHomebrewCCOpts"               \
         -target-cc-opt freebsd '-I/usr/local/include'            \
         -target-cc-opt netbsd '-I/usr/pkg/include'               \
         -target-cc-opt openbsd '-I/usr/local/include'            \
@@ -127,7 +116,7 @@ doit "$lib" \
         -target-link-opt amd64 '-m64'                            \
         -target-link-opt alpha                                   \
                 '-mieee -mbwx -mtune=ev6 -mfp-rounding-mode=d'   \
-        -target-link-opt darwin "$darwinLinkOpts"                \
+        -target-link-opt darwin "$gmpHomebrewLinkOpts"           \
         -target-link-opt freebsd '-L/usr/local/lib/'             \
         -target-link-opt aix '-maix64'                           \
         -target-link-opt ia64 "$ia64hpux"                        \
diff --git a/runtime/Makefile b/runtime/Makefile
index c3f177f..1b0cda1 100644
--- a/runtime/Makefile
+++ b/runtime/Makefile
@@ -143,7 +143,8 @@ EXE := .exe
 endif
 
 ifeq ($(TARGET_OS), darwin)
-XCFLAGS += -I/usr/local/include -I/sw/include -I/opt/local/include
+GMP_HOMEBREW_XCFLAGS :=
+XCFLAGS += $(GMP_HOMEBREW_XCFLAGS)
 endif
 
 ifeq ($(TARGET_OS), freebsd)
