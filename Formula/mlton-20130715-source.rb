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

  # Support configuring GMP location (https://github.com/MLton/mlton/issues/134)
  # upstream merge commit:
  patch do
    url "https://github.com/MatthewFluet/mlton/commit/6e79342cdcf2e15193d95fcd3a46d164b783aed4.diff"
    sha256 "2d44891eaf3fdecd3b0f6de2bdece463c71c425100fbac2d00196ad159e5c707"
  end

  def install
    # Import the corresponding upstream binary release to 'bootstrap'.
    bootstrap = buildpath/"bootstrap"
    bootstrap_bin = bootstrap/"usr/local/bin"
    bootstrap_lib = bootstrap/"usr/local/lib"
    mkdir bootstrap
    resource("bootstrap").stage(bootstrap/"usr")
    cp "bin/mlton-script", bootstrap_bin/"mlton"
    inreplace bootstrap_bin/"mlton", /^lib=.*/, "lib='#{bootstrap_lib}/mlton'"
    inreplace bootstrap_bin/"mlton", /^gmpIncDir=.*/, "gmpIncDir='#{Formula["gmp"].opt_prefix}/include'"
    inreplace bootstrap_bin/"mlton", /^gmpLibDir=.*/, "gmpLibDir='#{Formula["gmp"].opt_prefix}/lib'"
    chmod "a+x", bootstrap_bin/"mlton"
    ENV.prepend_path "PATH", bootstrap_bin

    # Support parallel builds (https://github.com/MLton/mlton/issues/132)
    ENV.deparallelize
    system "make", "WITH_GMP=#{Formula["gmp"].opt_prefix}", "all-no-docs"
    system "make", "WITH_GMP=#{Formula["gmp"].opt_prefix}", "DESTDIR=", "PREFIX=#{prefix}", "MAN_PREFIX_EXTRA=/share", "install-no-docs"
  end

  test do
    (testpath/"hello.sml").write <<-'EOS'.undent
      val () = print "Hello, Homebrew!\n"
    EOS
    system "#{bin}/mlton", "hello.sml"
    assert_equal "Hello, Homebrew!\n", `./hello`
  end
end
