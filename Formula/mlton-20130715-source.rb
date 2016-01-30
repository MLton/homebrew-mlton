class Mlton20130715Source < Formula
  desc "Whole-program, optimizing compiler for Standard ML"
  homepage "http://mlton.org"
  url "https://downloads.sourceforge.net/project/mlton/mlton/20130715/mlton-20130715.src.tgz"
  version "20130715"
  sha256 "215857ad11d44f8d94c27f75e74017aa44b2c9703304bcec9e38c20433143d6c"

  depends_on "gmp"

  resource "bootstrap" do
    url "https://downloads.sourceforge.net/project/mlton/mlton/20130715/mlton-20130715-2.amd64-darwin.gmp-static.tgz"
    sha256 "16a6d4e300f45f4af094692cf8033390e4634fa4c072caf6e9c288234100ad22"
  end

  patch :DATA

  def install
    inreplace "bin/mlton-script", "gmpHomebrewCCOpts=''", "gmpHomebrewCCOpts='-I#{Formula["gmp"].opt_prefix}/include'"
    inreplace "bin/mlton-script", "gmpHomebrewLinkOpts=''", "gmpHomebrewLinkOpts='-L#{Formula["gmp"].opt_prefix}/lib'"
    inreplace "runtime/Makefile", "GMP_HOMEBREW_XCFLAGS :=", "GMP_HOMEBREW_XCFLAGS := -I#{Formula["gmp"].opt_prefix}/include"

    bootstrap = buildpath/"bootstrap"
    bootstrap_bin = bootstrap/"usr/local/bin"
    bootstrap_lib = bootstrap/"usr/local/lib"
    mkdir bootstrap
    resource("bootstrap").stage(bootstrap/"usr")
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
      val () = print "Hello, world!\n"
    EOS
    system "#{bin}/mlton", "hello.sml"
    system "./hello"
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
