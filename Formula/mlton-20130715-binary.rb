# Installs a binary build of MLton.
# Since MLton is written in Standard ML, building from source would
# require an existing Standard ML compiler/interpreter for
# bootstrapping.

class Mlton20130715Binary < Formula
  desc "Whole-program, optimizing compiler for Standard ML"
  homepage "http://mlton.org"
  url "https://downloads.sourceforge.net/project/mlton/mlton/20130715/mlton-20130715-2.amd64-darwin.gmp-static.tgz"
  sha256 "16a6d4e300f45f4af094692cf8033390e4634fa4c072caf6e9c288234100ad22"

  # We download and install the version of MLton which is statically
  # linked to libgmp, but all generated executables will require gmp
  # anyway, hence the dependency
  depends_on "gmp"

  patch :DATA

  def install
    cd "local" do
      inreplace "bin/mlton", "lib='/usr/local/lib/mlton'", "lib='#{prefix}/lib/mlton'"
      inreplace "bin/mlton", "homebrewCCOpts=''", "homebrewCCOpts='-I#{Formula["gmp"].opt_prefix}/include'"
      inreplace "bin/mlton", "homebrewLinkOpts=''", "homebrewLinkOpts='-L#{Formula["gmp"].opt_prefix}/lib'"
      mv "man", "share"
      prefix.install Dir["*"]
    end
  end

  test do
    (testpath/"hello.sml").write <<-'EOS'.undent
      val () = print "Hello, world!\n"
    EOS
    system "#{bin}/mlton", "hello.sml"
    system "./hello"
  end
end

__END__
diff --git a/local/bin/mlton b/local/bin/mlton
index 099f110..1a468c3 100755
--- a/local/bin/mlton
+++ b/local/bin/mlton
@@ -80,18 +80,8 @@ doit () {
 # You may need to add a line with -link-opt '-L/path/to/libgmp' so
 # that the linker can find libgmp.
 
-# The darwin linker complains (loudly) about non-existent library
-# search paths.
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
+homebrewCCOpts=''
+homebrewLinkOpts=''
 
 doit "$lib" \
         -ar-script "$lib/static-library"                         \
@@ -106,10 +96,7 @@ doit "$lib" \
         -target-cc-opt alpha                                     \
                 '-mieee -mbwx -mtune=ev6 -mfp-rounding-mode=d'   \
         -target-cc-opt amd64 '-m64'                              \
-        -target-cc-opt darwin                                    \
-                '-I/usr/local/include
-                 -I/opt/local/include
-                 -I/sw/include'                                  \
+        -target-cc-opt darwin "$homebrewCCOpts"                  \
         -target-cc-opt freebsd '-I/usr/local/include'            \
         -target-cc-opt netbsd '-I/usr/pkg/include'               \
         -target-cc-opt openbsd '-I/usr/local/include'            \
@@ -127,7 +114,7 @@ doit "$lib" \
         -target-link-opt amd64 '-m64'                            \
         -target-link-opt alpha                                   \
                 '-mieee -mbwx -mtune=ev6 -mfp-rounding-mode=d'   \
-        -target-link-opt darwin "$darwinLinkOpts"                \
+        -target-link-opt darwin "$hombrewLinkOpts"               \
         -target-link-opt freebsd '-L/usr/local/lib/'             \
         -target-link-opt aix '-maix64'                           \
         -target-link-opt ia64 "$ia64hpux"                        \
